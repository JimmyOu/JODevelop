//
//  NECustomHttpProtocol.h
//  SnailReader
//
//  Created by JimmyOu on 2018/12/21.
//  Copyright © 2018 com.netease. All rights reserved.
//

#import <Foundation/Foundation.h>
@protocol NECustomHttpProtocolDelegate;
NS_ASSUME_NONNULL_BEGIN

@interface NECustomHttpProtocol : NSURLProtocol

+ (void)start;
+ (void)finished;
+ (void)setDelegate:(id<NECustomHttpProtocolDelegate>)newValue;
+ (id<NECustomHttpProtocolDelegate>)delegate;
@property (atomic, strong, readonly ) NSURLAuthenticationChallenge *    pendingChallenge;
- (void)resolveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge withCredential:(NSURLCredential *)credential;

@end

@protocol NECustomHttpProtocolDelegate <NSObject>

@optional
/*! Called by an CustomHTTPProtocol instance to ask the delegate whether it's prepared to handle
 *  a particular authentication challenge.  Can be called on any thread.
 *  \param protocol The protocol instance itself; will not be nil.
 *  \param protectionSpace The protection space for the authentication challenge; will not be nil.
 *  \returns Return YES if you want the -customHTTPProtocol:didReceiveAuthenticationChallenge: delegate
 *  callback, or NO for the challenge to be handled in the default way.
 */
- (BOOL)customHTTPProtocol:(NECustomHttpProtocol *)protocol canAuthenticateAgainstProtectionSpace:(NSURLProtectionSpace *)protectionSpace;

/*! Called by an CustomHTTPProtocol instance to request that the delegate process on authentication
 *  challenge. Will be called on the main thread. Unless the challenge is cancelled (see below)
 *  the delegate must eventually resolve it by calling -resolveAuthenticationChallenge:withCredential:.
 *  \param protocol The protocol instance itself; will not be nil.
 *  \param challenge The authentication challenge; will not be nil.
 */

- (void)customHTTPProtocol:(NECustomHttpProtocol *)protocol didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge;

/*! Called by an CustomHTTPProtocol instance to cancel an issued authentication challenge.
 *  Will be called on the main thread.
 *  \param protocol The protocol instance itself; will not be nil.
 *  \param challenge The authentication challenge; will not be nil; will match the challenge
 *  previously issued by -customHTTPProtocol:canAuthenticateAgainstProtectionSpace:.
 */

- (void)customHTTPProtocol:(NECustomHttpProtocol *)protocol didCancelAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge;

/*! Called by the CustomHTTPProtocol to log various bits of information.
 *  Can be called on any thread.
 *  \param protocol The protocol instance itself; nil to indicate log messages from the class itself.
 *  \param format A standard NSString-style format string; will not be nil.
 *  \param arguments Arguments for that format string.
 */

- (void)customHTTPProtocol:(NECustomHttpProtocol *)protocol logWithFormat:(NSString *)format arguments:(va_list)arguments;

@end

NS_ASSUME_NONNULL_END
