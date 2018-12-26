//
//  NECustomHttpProtocol.m
//  SnailReader
//
//  Created by JimmyOu on 2018/12/21.
//  Copyright © 2018 com.netease. All rights reserved.
//

#import "NECustomHttpProtocol.h"
#import "NEURLSessionDemux.h"
#import "NECacheStoragePolicy.h"
#import "CanonicalRequest.h"
#import "NEHTTPModel.h"
#import "NEMonitorUtils.h"
typedef void (^ChallengeCompletionHandler)(NSURLSessionAuthChallengeDisposition disposition, NSURLCredential * credential);

@interface NECustomHttpProtocol()<NSURLSessionDataDelegate>
@property (atomic, strong, readwrite) NSThread *                        clientThread;       ///< The thread on which we should call the client.
@property (atomic, copy,   readwrite) NSArray *                         modes;
@property (atomic, strong, readwrite) NSURLSessionDataTask *            task;
@property (atomic, strong, readwrite) NSURLAuthenticationChallenge *    pendingChallenge;
@property (atomic, copy,   readwrite) ChallengeCompletionHandler        pendingChallengeCompletionHandler;

@property (nonatomic, strong) NSDate               *startDate;
@property (nonatomic, strong) NSURLResponse        *response;
@property (nonatomic, strong) NSMutableData        *data;
@property (strong, nonatomic) NEHTTPModel *model;

@end
@implementation NECustomHttpProtocol

static id<NECustomHttpProtocolDelegate> sDelegate;

+ (void)start
{
    [NSURLProtocol registerClass:self];
}

+ (void)finished
{
    [NSURLProtocol unregisterClass:self];
}

+ (id<NECustomHttpProtocolDelegate>)delegate
{
    id<NECustomHttpProtocolDelegate> result;
    
    @synchronized (self) {
        result = sDelegate;
    }
    return result;
}

+ (void)setDelegate:(id<NECustomHttpProtocolDelegate>)newValue
{
    @synchronized (self) {
        sDelegate = newValue;
    }
}

/*! Returns the session demux object used by all the protocol instances.
 *  \details This object allows us to have a single NSURLSession, with a session delegate,
 *  and have its delegate callbacks routed to the correct protocol instance on the correct
 *  thread in the correct modes.  Can be called on any thread.
 */
+ (NEURLSessionDemux *)sharedDemux
{
    static dispatch_once_t      sOnceToken;
    static NEURLSessionDemux * sDemux;
    dispatch_once(&sOnceToken, ^{
        NSURLSessionConfiguration *     config;
        
        config = [NSURLSessionConfiguration defaultSessionConfiguration];
        // You have to explicitly configure the session to use your own protocol subclass here
        // otherwise you don't see redirects <rdar://problem/17384498>.
        config.protocolClasses = @[ self ];
        sDemux = [[NEURLSessionDemux alloc] initWithConfiguration:config];
    });
    return sDemux;
}
+ (void)customHTTPProtocol:(NECustomHttpProtocol *)protocol logWithFormat:(NSString *)format, ... NS_FORMAT_FUNCTION(2, 3)
// All internal logging calls this routine, which routes the log message to the
// delegate.
{
    // protocol may be nil
    id<NECustomHttpProtocolDelegate> strongDelegate;
    
    strongDelegate = [self delegate];
    if ([strongDelegate respondsToSelector:@selector(customHTTPProtocol:logWithFormat:arguments:)]) {
        va_list arguments;
        
        va_start(arguments, format);
        [strongDelegate customHTTPProtocol:protocol logWithFormat:format arguments:arguments];
        va_end(arguments);
    }
}

#pragma mark * NSURLProtocol overrides
static NSString * kOurRecursiveRequestFlagProperty = @"com.apple.dts.CustomHTTPProtocol";
+ (BOOL)canInitWithRequest:(NSURLRequest *)request
{
    BOOL        shouldAccept;
    NSURL *     url;
    NSString *  scheme;
    
    // Check the basics.  This routine is extremely defensive because experience has shown that
    // it can be called with some very odd requests <rdar://problem/15197355>.
    
    shouldAccept = (request != nil);
    if (shouldAccept) {
        url = [request URL];
        shouldAccept = (url != nil);
    }
    if ( ! shouldAccept ) {
        [self customHTTPProtocol:nil logWithFormat:@"decline request (malformed)"];
    }
    
    // Decline our recursive requests.
    
    if (shouldAccept) {
        shouldAccept = ([self propertyForKey:kOurRecursiveRequestFlagProperty inRequest:request] == nil);
        if ( ! shouldAccept ) {
            [self customHTTPProtocol:nil logWithFormat:@"decline request %@ (recursive)", url];
        }
    }
    
    // Get the scheme.
    
    if (shouldAccept) {
        scheme = [[url scheme] lowercaseString];
        shouldAccept = (scheme != nil);
        
        if ( ! shouldAccept ) {
            [self customHTTPProtocol:nil logWithFormat:@"decline request %@ (no scheme)", url];
        }
    }
    
    // Look for "http" or "https".
    
    if (shouldAccept) {
        shouldAccept = [scheme isEqual:@"http"] || [scheme isEqual:@"https"];
        
        if ( ! shouldAccept ) {
            [self customHTTPProtocol:nil logWithFormat:@"decline request %@ (scheme mismatch)", url];
        } else {
            [self customHTTPProtocol:nil logWithFormat:@"accept request %@", url];
        }
    }
    
    return shouldAccept;
}
+ (NSURLRequest *)canonicalRequestForRequest:(NSURLRequest *)request
{
    NSURLRequest *      result;
    
//    assert(request != nil);
    // can be called on any thread
    
    // Canonicalising a request is quite complex, so all the heavy lifting has
    // been shuffled off to a separate module.
    
    result = CanonicalRequestForRequest(request);
    
    [self customHTTPProtocol:nil logWithFormat:@"canonicalized %@ to %@", [request URL], [result URL]];
    
    return result;
}

- (instancetype)initWithRequest:(NSURLRequest *)request cachedResponse:(NSCachedURLResponse *)cachedResponse client:(id<NSURLProtocolClient>)client {
    assert(request != nil);
    // cachedResponse may be nil
    assert(client != nil);
    // can be called on any thread
    
    self = [super initWithRequest:request cachedResponse:cachedResponse client:client];
    if (self != nil) {
        // All we do here is log the call.
        [[self class] customHTTPProtocol:self logWithFormat:@"init for %@ from <%@ %p>", [request URL], [client class], client];
    }
    return self;

}

- (void)dealloc
{
    // can be called on any thread
    [[self class] customHTTPProtocol:self logWithFormat:@"dealloc"];
    assert(self->_task == nil);                     // we should have cleared it by now
    assert(self->_pendingChallenge == nil);         // we should have cancelled it by now
    assert(self->_pendingChallengeCompletionHandler == nil);    // we should have cancelled it by now
}

- (void)startLoading
{
    NSMutableURLRequest *   recursiveRequest;
    NSMutableArray *        calculatedModes;
    NSString *              currentMode;
    
    // At this point we kick off the process of loading the URL via NSURLSession.
    // The thread that calls this method becomes the client thread.
    
    assert(self.clientThread == nil);           // you can't call -startLoading twice
    assert(self.task == nil);
    
    // Calculate our effective run loop modes.  In some circumstances (yes I'm looking at
    // you UIWebView!) we can be called from a non-standard thread which then runs a
    // non-standard run loop mode waiting for the request to finish.  We detect this
    // non-standard mode and add it to the list of run loop modes we use when scheduling
    // our callbacks.  Exciting huh?
    //
    // For debugging purposes the non-standard mode is "WebCoreSynchronousLoaderRunLoopMode"
    // but it's better not to hard-code that here.
    
//    assert(self.modes == nil);
    calculatedModes = [NSMutableArray array];
    [calculatedModes addObject:NSDefaultRunLoopMode];
    currentMode = [[NSRunLoop currentRunLoop] currentMode];
    if ( (currentMode != nil) && ! [currentMode isEqual:NSDefaultRunLoopMode] ) {
        [calculatedModes addObject:currentMode];
    }
    self.modes = calculatedModes;
//    assert([self.modes count] > 0);
    
    // Create new request that's a clone of the request we were initialised with,
    // except that it has our 'recursive request flag' property set on it.
    
    recursiveRequest = [[self request] mutableCopy];
//    assert(recursiveRequest != nil);
    
    [[self class] setProperty:@YES forKey:kOurRecursiveRequestFlagProperty inRequest:recursiveRequest];
    
    //record start -->
    self.startDate = [NSDate date];
    self.data = [NSMutableData data];
    self.model = [[NEHTTPModel alloc] init];
    self.model.ne_request = self.request;
    self.model.startDateString = [NEMonitorUtils stringWithDate:[NSDate date]];
    self.model.myID = [NSString stringWithFormat:@"%@",[NEMonitorUtils nextRequestID]];
    
    if (currentMode == nil) {
        [[self class] customHTTPProtocol:self logWithFormat:@"start %@", [recursiveRequest URL]];
    } else {
        [[self class] customHTTPProtocol:self logWithFormat:@"start %@ (mode %@)", [recursiveRequest URL], currentMode];
    }
    
    // Latch the thread we were called on, primarily for debugging purposes.
    
    self.clientThread = [NSThread currentThread];
    
    // Once everything is ready to go, create a data task with the new request.
    
    self.task = [[[self class] sharedDemux] dataTaskWithRequest:recursiveRequest delegate:self modes:self.modes];
//    assert(self.task != nil);
    
    [self.task resume];
}

- (void)stopLoading {
    
    //end recording
    self.model.ne_response      = (NSHTTPURLResponse *)self.response;
    self.model.statusCodeString = [NEMonitorUtils statusCodeStringFromURLResponse:(NSHTTPURLResponse *)self.response];
    self.model.endDateString = [NEMonitorUtils stringWithDate:[NSDate date]];
    NSDate *from = [NEMonitorUtils dateFromString:self.model.startDateString];
    NSTimeInterval duraiton = [NEMonitorUtils timeIntervalFrom:from toDate:[NSDate date]];
    self.model.formateDuation = [NEMonitorUtils formateStringFromRequestDuration:duraiton];
    self.model.data = self.data;
    NSString *mimeType      = self.response.MIMEType;
    if ([mimeType isEqualToString:@"application/json"]) {
        self.model.receiveJSONData = [NEMonitorUtils responseJSONFromData:self.data];
    } else if ([mimeType isEqualToString:@"text/javascript"]) {
        // try to parse json if it is jsonp request
        NSString *jsonString = [[NSString alloc] initWithData:self.data encoding:NSUTF8StringEncoding];
        // formalize string
        if ([jsonString hasSuffix:@")"]) {
            jsonString = [NSString stringWithFormat:@"%@;", jsonString];
        }
        if ([jsonString hasSuffix:@");"]) {
            NSRange range = [jsonString rangeOfString:@"("];
            if (range.location != NSNotFound) {
                range.location++;
                range.length = [jsonString length] - range.location - 2; // removes parens and trailing semicolon
                jsonString = [jsonString substringWithRange:range];
                NSData *jsonData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
                self.model.receiveJSONData = [NEMonitorUtils responseJSONFromData:jsonData];
            }
        }
        
    }else if ([mimeType isEqualToString:@"application/xml"] ||[mimeType isEqualToString:@"text/xml"]){
        NSString *xmlString = [[NSString alloc]initWithData:self.data encoding:NSUTF8StringEncoding];
        if (xmlString && xmlString.length>0) {
            self.model.receiveJSONData = xmlString;//example http://webservice.webxml.com.cn/webservices/qqOnlineWebService.asmx/qqCheckOnline?qqCode=2121
        }
    }
    [self.model synchronize];
    
    // The implementation just cancels the current load (if it's still running).
    
//    [[self class] customHTTPProtocol:self logWithFormat:@"stop (elapsed %.1f)", [NSDate timeIntervalSinceReferenceDate] - self.startTime];
    
//    assert(self.clientThread != nil);           // someone must have called -startLoading
    
    // Check that we're being stopped on the same thread that we were started
    // on.  Without this invariant things are going to go badly (for example,
    // run loop sources that got attached during -startLoading may not get
    // detached here).
    //
    // I originally had code here to bounce over to the client thread but that
    // actually gets complex when you consider run loop modes, so I've nixed it.
    // Rather, I rely on our client calling us on the right thread, which is what
    // the following assert is about.
    
//    assert([NSThread currentThread] == self.clientThread);
    
    [self cancelPendingChallenge];
    if (self.task != nil) {
        [self.task cancel];
        self.task = nil;
        // The following ends up calling -URLSession:task:didCompleteWithError: with NSURLErrorDomain / NSURLErrorCancelled,
        // which specificallys traps and ignores the error.
    }
    // Don't nil out self.modes; see property declaration comments for a a discussion of this.
}
#pragma mark * Authentication challenge handling
- (void)performOnThread:(NSThread *)thread modes:(NSArray *)modes block:(dispatch_block_t)block
{
    // thread may be nil
    // modes may be nil
//    assert(block != nil);
    
    if (thread == nil) {
        thread = [NSThread mainThread];
    }
    if ([modes count] == 0) {
        modes = @[ NSDefaultRunLoopMode ];
    }
    [self performSelector:@selector(onThreadPerformBlock:) onThread:thread withObject:[block copy] waitUntilDone:NO modes:modes];
}
- (void)onThreadPerformBlock:(dispatch_block_t)block
{
//    assert(block != nil);
    block();
}

- (void)didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge completionHandler:(ChallengeCompletionHandler)completionHandler
{
//    assert(challenge != nil);
//    assert(completionHandler != nil);
//    assert([NSThread currentThread] == self.clientThread);
    
    [[self class] customHTTPProtocol:self logWithFormat:@"challenge %@ received", [[challenge protectionSpace] authenticationMethod]];
    
    [self performOnThread:nil modes:nil block:^{
        [self mainThreadDidReceiveAuthenticationChallenge:challenge completionHandler:completionHandler];
    }];
}
- (void)mainThreadDidReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge completionHandler:(ChallengeCompletionHandler)completionHandler
{
//    assert(challenge != nil);
//    assert(completionHandler != nil);
//    assert([NSThread isMainThread]);
    
    if (self.pendingChallenge != nil) {
        
        // Our delegate is not expecting a second authentication challenge before resolving the
        // first.  Likewise, NSURLSession shouldn't send us a second authentication challenge
        // before we resolve the first.  If this happens, assert, log, and cancel the challenge.
        //
        // Note that we have to cancel the challenge on the thread on which we received it,
        // namely, the client thread.
        
        [[self class] customHTTPProtocol:self logWithFormat:@"challenge %@ cancelled; other challenge pending", [[challenge protectionSpace] authenticationMethod]];
        assert(NO);
        [self clientThreadCancelAuthenticationChallenge:challenge completionHandler:completionHandler];
    } else {
        id<NECustomHttpProtocolDelegate>  strongDelegate;
        
        strongDelegate = [[self class] delegate];
        
        // Tell the delegate about it.  It would be weird if the delegate didn't support this
        // selector (it did return YES from -customHTTPProtocol:canAuthenticateAgainstProtectionSpace:
        // after all), but if it doesn't then we just cancel the challenge ourselves (or the client
        // thread, of course).
        
        if ( ! [strongDelegate respondsToSelector:@selector(customHTTPProtocol:canAuthenticateAgainstProtectionSpace:)] ) {
            [[self class] customHTTPProtocol:self logWithFormat:@"challenge %@ cancelled; no delegate method", [[challenge protectionSpace] authenticationMethod]];
            assert(NO);
            [self clientThreadCancelAuthenticationChallenge:challenge completionHandler:completionHandler];
        } else {
            
            // Remember that this challenge is in progress.
            
            self.pendingChallenge = challenge;
            self.pendingChallengeCompletionHandler = completionHandler;
            
            // Pass the challenge to the delegate.
            
            [[self class] customHTTPProtocol:self logWithFormat:@"challenge %@ passed to delegate", [[challenge protectionSpace] authenticationMethod]];
            [strongDelegate customHTTPProtocol:self didReceiveAuthenticationChallenge:self.pendingChallenge];
        }
    }
}
- (void)clientThreadCancelAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge completionHandler:(ChallengeCompletionHandler)completionHandler
{
#pragma unused(challenge)
//    assert(challenge != nil);
//    assert(completionHandler != nil);
//    assert([NSThread isMainThread]);
    
    [self performOnThread:self.clientThread modes:self.modes block:^{
        completionHandler(NSURLSessionAuthChallengeCancelAuthenticationChallenge, nil);
    }];
}

- (void)cancelPendingChallenge
{
    assert([NSThread currentThread] == self.clientThread);
    
    // Just pass the work off to the main thread.  We do this so that all accesses
    // to pendingChallenge are done from the main thread, which avoids the need for
    // extra synchronisation.
    
    [self performOnThread:nil modes:nil block:^{
        if (self.pendingChallenge == nil) {
            // This is not only not unusual, it's actually very typical.  It happens every time you shut down
            // the connection.  Ideally I'd like to not even call -mainThreadCancelPendingChallenge when
            // there's no challenge outstanding, but the synchronisation issues are tricky.  Rather than solve
            // those, I'm just not going to log in this case.
            //
            // [[self class] customHTTPProtocol:self logWithFormat:@"challenge not cancelled; no challenge pending"];
        } else {
            id<NECustomHttpProtocolDelegate>  strongeDelegate;
            NSURLAuthenticationChallenge *  challenge;
            
            strongeDelegate = [[self class] delegate];
            
            challenge = self.pendingChallenge;
            self.pendingChallenge = nil;
            self.pendingChallengeCompletionHandler = nil;
            
            if ([strongeDelegate respondsToSelector:@selector(customHTTPProtocol:didCancelAuthenticationChallenge:)]) {
                [[self class] customHTTPProtocol:self logWithFormat:@"challenge %@ cancellation passed to delegate", [[challenge protectionSpace] authenticationMethod]];
                [strongeDelegate customHTTPProtocol:self didCancelAuthenticationChallenge:challenge];
            } else {
                [[self class] customHTTPProtocol:self logWithFormat:@"challenge %@ cancellation failed; no delegate method", [[challenge protectionSpace] authenticationMethod]];
                // If we managed to send a challenge to the client but can't cancel it, that's bad.
                // There's nothing we can do at this point except log the problem.
                assert(NO);
            }
        }
    }];
}

- (void)resolveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge withCredential:(NSURLCredential *)credential
{
//    assert(challenge == self.pendingChallenge);
//    // credential may be nil
//    assert([NSThread isMainThread]);
//    assert(self.clientThread != nil);
    
    if (challenge != self.pendingChallenge) {
        [[self class] customHTTPProtocol:self logWithFormat:@"challenge resolution mismatch (%@ / %@)", challenge, self.pendingChallenge];
        // This should never happen, and we want to know if it does, at least in the debug build.
        assert(NO);
    } else {
        ChallengeCompletionHandler  completionHandler;
        
        // We clear out our record of the pending challenge and then pass the real work
        // over to the client thread (which ensures that the challenge is resolved on
        // the same thread we received it on).
        
        completionHandler = self.pendingChallengeCompletionHandler;
        self.pendingChallenge = nil;
        self.pendingChallengeCompletionHandler = nil;
        
        [self performOnThread:self.clientThread modes:self.modes block:^{
            if (credential == nil) {
                [[self class] customHTTPProtocol:self logWithFormat:@"challenge %@ resolved without credential", [[challenge protectionSpace] authenticationMethod]];
                completionHandler(NSURLSessionAuthChallengePerformDefaultHandling, nil);
            } else {
                [[self class] customHTTPProtocol:self logWithFormat:@"challenge %@ resolved with <%@ %p>", [[challenge protectionSpace] authenticationMethod], [credential class], credential];
                completionHandler(NSURLSessionAuthChallengeUseCredential, credential);
            }
        }];
    }
}


#pragma mark * NSURLSession delegate callbacks
- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task willPerformHTTPRedirection:(NSHTTPURLResponse *)response newRequest:(NSURLRequest *)newRequest completionHandler:(void (^)(NSURLRequest * _Nullable))completionHandler {
    NSMutableURLRequest *    redirectRequest;
    
#pragma unused(session)
#pragma unused(task)
//    assert(task == self.task);
//    assert(response != nil);
//    assert(newRequest != nil);
//#pragma unused(completionHandler)
//    assert(completionHandler != nil);
//    assert([NSThread currentThread] == self.clientThread);
    self.response = response;
    [[self class] customHTTPProtocol:self logWithFormat:@"will redirect from %@ to %@", [response URL], [newRequest URL]];
    
    // The new request was copied from our old request, so it has our magic property.  We actually
    // have to remove that so that, when the client starts the new request, we see it.  If we
    // don't do this then we never see the new request and thus don't get a chance to change
    // its caching behaviour.
    //
    // We also cancel our current connection because the client is going to start a new request for
    // us anyway.
    
    assert([[self class] propertyForKey:kOurRecursiveRequestFlagProperty inRequest:newRequest] != nil);
    
    redirectRequest = [newRequest mutableCopy];
    [[self class] removePropertyForKey:kOurRecursiveRequestFlagProperty inRequest:redirectRequest];
    
    // Tell the client about the redirect.
    
    [[self client] URLProtocol:self wasRedirectedToRequest:redirectRequest redirectResponse:response];
    
    // Stop our load.  The CFNetwork infrastructure will create a new NSURLProtocol instance to run
    // the load of the redirect.
    
    // The following ends up calling -URLSession:task:didCompleteWithError: with NSURLErrorDomain / NSURLErrorCancelled,
    // which specificallys traps and ignores the error.
    
    [self.task cancel];
    
    [[self client] URLProtocol:self didFailWithError:[NSError errorWithDomain:NSCocoaErrorDomain code:NSUserCancelledError userInfo:nil]];
}

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didReceiveChallenge:(NSURLAuthenticationChallenge *)challenge completionHandler:(void (^)(NSURLSessionAuthChallengeDisposition, NSURLCredential * _Nullable))completionHandler {
    BOOL        result;
    id<NECustomHttpProtocolDelegate> strongeDelegate;
    
#pragma unused(session)
#pragma unused(task)
//    assert(task == self.task);
//    assert(challenge != nil);
//    assert(completionHandler != nil);
//    assert([NSThread currentThread] == self.clientThread);
    
    // Ask our delegate whether it wants this challenge.  We do this from this thread, not the main thread,
    // to avoid the overload of bouncing to the main thread for challenges that aren't going to be customised
    // anyway.
    
    strongeDelegate = [[self class] delegate];
    
    result = NO;
    if ([strongeDelegate respondsToSelector:@selector(customHTTPProtocol:canAuthenticateAgainstProtectionSpace:)]) {
        result = [strongeDelegate customHTTPProtocol:self canAuthenticateAgainstProtectionSpace:[challenge protectionSpace]];
    }
    
    // If the client wants the challenge, kick off that process.  If not, resolve it by doing the default thing.
    
    if (result) {
        [[self class] customHTTPProtocol:self logWithFormat:@"can authenticate %@", [[challenge protectionSpace] authenticationMethod]];
        
        [self didReceiveAuthenticationChallenge:challenge completionHandler:completionHandler];
    } else {
        [[self class] customHTTPProtocol:self logWithFormat:@"cannot authenticate %@", [[challenge protectionSpace] authenticationMethod]];
        
        completionHandler(NSURLSessionAuthChallengePerformDefaultHandling, nil);
    }
}

- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveResponse:(NSURLResponse *)response completionHandler:(void (^)(NSURLSessionResponseDisposition))completionHandler
{
    NSURLCacheStoragePolicy cacheStoragePolicy;
    NSInteger               statusCode;
    if (self.task == nil) {
        return;
    }
#pragma unused(session)
#pragma unused(dataTask)
//    assert(dataTask == self.task);
//    assert(response != nil);
//    assert(completionHandler != nil);
//    assert([NSThread currentThread] == self.clientThread);
    self.response = response;
    
    // Pass the call on to our client.  The only tricky thing is that we have to decide on a
    // cache storage policy, which is based on the actual request we issued, not the request
    // we were given.
    
    if ([response isKindOfClass:[NSHTTPURLResponse class]]) {
        cacheStoragePolicy = CacheStoragePolicyForRequestAndResponse(self.task.originalRequest, (NSHTTPURLResponse *) response);
        statusCode = [((NSHTTPURLResponse *) response) statusCode];
    } else {
        assert(NO);
        cacheStoragePolicy = NSURLCacheStorageNotAllowed;
        statusCode = 42;
    }
    
    [[self class] customHTTPProtocol:self logWithFormat:@"received response %zd / %@ with cache storage policy %zu", (ssize_t) statusCode, [response URL], (size_t) cacheStoragePolicy];
    
    [[self client] URLProtocol:self didReceiveResponse:response cacheStoragePolicy:cacheStoragePolicy];
    
    completionHandler(NSURLSessionResponseAllow);
}

- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveData:(NSData *)data
{
#pragma unused(session)
#pragma unused(dataTask)
//    assert(dataTask == self.task);
//    assert(data != nil);
//    assert([NSThread currentThread] == self.clientThread);
    
    // Just pass the call on to our client.
    
    [[self class] customHTTPProtocol:self logWithFormat:@"received %zu bytes of data", (size_t) [data length]];
    
    [[self client] URLProtocol:self didLoadData:data];
    [self.data appendData:data];
}

- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask willCacheResponse:(NSCachedURLResponse *)proposedResponse completionHandler:(void (^)(NSCachedURLResponse *))completionHandler
{
#pragma unused(session)
#pragma unused(dataTask)
//    assert(dataTask == self.task);
//    assert(proposedResponse != nil);
//    assert(completionHandler != nil);
//    assert([NSThread currentThread] == self.clientThread);
    
    // We implement this delegate callback purely for the purposes of logging.
    
    [[self class] customHTTPProtocol:self logWithFormat:@"will cache response"];
    
    completionHandler(proposedResponse);
}

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error
// An NSURLSession delegate callback.  We pass this on to the client.
{
    self.model.error = error;
//#pragma unused(session)
//#pragma unused(task)
//    assert( (self.task == nil) || (task == self.task) );        // can be nil in the 'cancel from -stopLoading' case
//    assert([NSThread currentThread] == self.clientThread);
    
    // Just log and then, in most cases, pass the call on to our client.
    
    if (error == nil) {
        [[self class] customHTTPProtocol:self logWithFormat:@"success"];
        
        [[self client] URLProtocolDidFinishLoading:self];
    } else if ( [[error domain] isEqual:NSURLErrorDomain] && ([error code] == NSURLErrorCancelled) ) {
        // Do nothing.  This happens in two cases:
        //
        // o during a redirect, in which case the redirect code has already told the client about
        //   the failure
        //
        // o if the request is cancelled by a call to -stopLoading, in which case the client doesn't
        //   want to know about the failure
    } else {
        [[self class] customHTTPProtocol:self logWithFormat:@"error %@ / %d", [error domain], (int) [error code]];
        
        [[self client] URLProtocol:self didFailWithError:error];
    }
    
    // We don't need to clean up the connection here; the system will call, or has already called,
    // -stopLoading to do that.
}




@end
