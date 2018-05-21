//
//  JOVideoPlayerCompat.m
//  JODevelop
//
//  Created by JimmyOu on 2018/5/15.
//  Copyright © 2018年 JimmyOu. All rights reserved.
//

#import "JOVideoPlayerCompat.h"
#import <MobileCoreServices/MobileCoreServices.h>

NSString *const JOVideoPlayerDownloadStartNotification = @"JOVideoPlayerDownloadStartNotification";
NSString *const JOVideoPlayerDownloadReceiveResponseNotification = @"JOVideoPlayerDownloadReceiveResponseNotification";
NSString *const JOVideoPlayerDownloadStopNotification = @"JOVideoPlayerDownloadStartNotification";
NSString *const JOVideoPlayerDownloadFinishNotification = @"JOVideoPlayerDownloadStartNotification";
NSString *const JOVideoPlayerErrorDomain = @"com.joVideoPlayer.www";
const NSRange JOInvalidRange = {NSNotFound, 0};

void JODispatchSyncOnMainThread(dispatch_block_t block) {
    if (!block) {
        return;
    }
    if ([NSThread isMainThread]) {
        block();
    } else {
        dispatch_sync(dispatch_get_main_queue(), block);
    }
}

void JODispatchASyncOnMainThread(dispatch_block_t block) {
    if (!block) {
        return;
    }
    if ([NSThread isMainThread]) {
        block();
    } else {
        dispatch_async(dispatch_get_main_queue(), block);
    }
}

BOOL JOValidByteRange(NSRange range) {
    return ((range.location != NSNotFound) || (range.length > 0));
}

BOOL JOValidFileRange(NSRange range) {
    return ((range.location != NSNotFound) && range.length > 0 && range.length != NSUIntegerMax);
}

BOOL JORangeCanMerge(NSRange range1, NSRange range2) {
    return (NSMaxRange(range1) == range2.location) || (NSMaxRange(range2) == range1.location) || NSIntersectionRange(range1, range2).length > 0;
}


NSString* JORangeToHTTPRangeHeader(NSRange range) {
    if (JOValidByteRange(range)) {
        if (range.location == NSNotFound) {
            return [NSString stringWithFormat:@"bytes=-%tu",range.length];
        }
        else if (range.length == NSUIntegerMax) {
            return [NSString stringWithFormat:@"bytes=%tu-",range.location];
        }
        else {
            return [NSString stringWithFormat:@"bytes=%tu-%tu",range.location, NSMaxRange(range) - 1];
        }
    }
    else {
        return nil;
    }
}

NSError *JOErrorWithDescription(NSString *description) {
    assert(description);
    if(!description.length){
        return nil;
    }
    
    return [NSError errorWithDomain:JOVideoPlayerErrorDomain
                               code:0 userInfo:@{
                                                 NSLocalizedDescriptionKey : description
                                                 }];
}

@implementation NSURL (StripQuery)

- (NSString *)absoluteStringByStrippingQuery{
    NSString *absoluteString = [self absoluteString];
    NSUInteger queryLength = [[self query] length];
    NSString* strippedString = (queryLength ? [absoluteString substringToIndex:[absoluteString length] - (queryLength + 1)] : absoluteString);
    
    if ([strippedString hasSuffix:@"?"]) {
        strippedString = [strippedString substringToIndex:absoluteString.length-1];
    }
    return strippedString;
}

@end

@implementation NSHTTPURLResponse (JOVideoPlayer)

- (long long)jo_fileLength {
    NSString *range = [self allHeaderFields][@"Content-Range"];
    if (range) {
        NSArray *ranges = [range componentsSeparatedByString:@"/"];
        if (ranges.count > 0) {
            NSString *lenthString = [[ranges lastObject] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
            return [lenthString longLongValue];
        }
    } else {
        return [self expectedContentLength];
    }
    return 0;
}
- (BOOL)jo_supportRange {
    return [self allHeaderFields][@"Content-Range"] != nil;
}

@end

@implementation NSFileHandle (JOVideoPlayer)
- (BOOL)jo_safeWriteData:(NSData *)data {
    NSInteger retry = 3;
    size_t bytesLeft = data.length;
    const void *bytes = [data bytes];
    int fileDescriptor = [self fileDescriptor];
    while (bytesLeft > 0 && retry > 0) {
        ssize_t amountSent = write(fileDescriptor, bytes + data.length - bytesLeft, bytesLeft);
        if (amountSent < 0) {
            // write failed.
            NSLog(@"Write file failed");
            break;
        }
        else {
            bytesLeft = bytesLeft - amountSent;
            if (bytesLeft > 0) {
                // not finished continue write after sleep 1 second.
                NSLog(@"Write file retry");
                sleep(1);  //probably too long, but this is quite rare.
                retry--;
            }
        }
    }
    return bytesLeft == 0;
}
@end

@implementation AVAssetResourceLoadingRequest (JOVideoPlayer)
- (void)jo_fillContentInformationWithResponse:(NSHTTPURLResponse *)response {
    if (!response) {
        return;
    }
    
    self.response = response;
    if (!self.contentInformationRequest) {
        return;
    }
    
    NSString *mimeType = [response MIMEType];
    CFStringRef contentType = UTTypeCreatePreferredIdentifierForTag(kUTTagClassMIMEType, (__bridge CFStringRef)(mimeType), NULL);
    self.contentInformationRequest.byteRangeAccessSupported = [response jo_supportRange];
    self.contentInformationRequest.contentType = CFBridgingRelease(contentType);
    self.contentInformationRequest.contentLength = [response jo_fileLength];
}
@end

