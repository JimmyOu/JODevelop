//
//  JOPromise.h
//  JODevelop
//
//  Created by JimmyOu on 2018/1/16.
//  Copyright © 2018年 JimmyOu. All rights reserved.
//

#import <Foundation/Foundation.h>
/**
 * Promise 语义承诺。
 *
 * Promise 的起源：在JavaScript的世界中，所有代码都是单线程执行的，由于这个“缺陷”，导致JavaScript的所有网络操作，浏览器事件，
 * 都必须是异步执行，而最常见的异步操作的写法就是用回调函数来实现，这样，在描述一个较为复杂的包含多步异步操作的业务时，很容易产生
 * 回调地狱。为了解决这个问题，ES6 标准库中新增了一个 Promise 对象。
 *
 * 在逻辑抽象的层面上来理解，即任一个异步操作的执行，最终肯定会得到一个结果，要不成功，要不失败。
 * 所谓Promise，简单来说就是一个容器，里面保存着某个未来才会结束的事件（通常是一个异步操作）的结果。
 * 从语法上说，Promise是一个对象，它可以获取异步操作的消息。Promise提供统一的API，各种异步操作都可以用同样的方法进行处理。
 *
 * Promise对象有以下两个特点：
 *
 * 1）对象的状态不受外界影响。Promise对象代表一个异步操作，有三种状态：Pending（进行中）、Resolved（已完成）和 Rejected（已失败），
 * 只有异步操作的结果，可以决定当前是哪一种状态，任何其他操作都无法改变这个状态。这也是 Promise 这个名字的由来，它的语义就是“承诺”，
 * 表示其他手段无法改变。
 *
 * 2）一旦状态改变，就不会再变，任何时候都可以得到这个结果。Promise 对象的状态改变，只有两种可能：从 Pending 变为 Resolved 和
 * 从 Pending 变为 Rejected。只要这两种情况发生，状态就凝固了，不会再变了，会一直保持这个结果。就算改变已经发生了，你再对 Promise
 * 对象添加回调函数，也会立即得到这个结果。这与事件（Event）完全不同，事件的特点是，如果你错过了它，再去监听，是得不到结果的。
 *
 * 有了 Promise 对象，就可以将异步操作以同步操作的流程表达出来，避免了回调地狱的发生。
 *
 * Promise 也有一些缺点。首先，无法取消 Promise，一旦新建它就会立即执行，无法中途取消。其次，如果不设置回调函数，Promise内部抛出的错误，
 * 不会反应到外部。第三，当处于 Pending 状态时，无法得知目前进展到哪一个阶段（刚刚开始还是即将完成）。
 *
 * resolve 函数的作用是，将Promise对象的状态从“未完成”变为“成功”（即从Pending变为Resolved），在异步操作成功时调用，
 * 并将异步操作的结果，作为参数传递出去。
 *
 * reject函数的作用是，将Promise对象的状态从“未完成”变为“失败”（即从Pending变为Rejected），在异步操作失败时调用，
 * 并将异步操作报出的错误，作为参数传递出去。
 *
 * Promise 实例生成以后，可以用 then 方法和 catch 方法分别指定 Resolved 状态和 Reject 状态的回调函数。
 * 为了用链式写法来完整描述一个多步骤的业务，then 方法中可以再次返回一个 Promise 对象...
 */
@class JOPromise;
typedef id (^handlerRun)(id value);
typedef void (^handlerResolve)(id value);
typedef void (^handlerError)(NSError *error);
typedef void (^handlerReject)(NSError *error);
typedef JOPromise *(^handlerMap)(id value);
typedef BOOL (^handlerFilter)(id value);
typedef JOPromise *(handlerReduce)(id item, id acc);
typedef void (^handlerProgress)(double progress, id value);
typedef void (^handlerPromise)(handlerResolve resolve, handlerReject reject);
typedef void (^handlerProgressPromise)(handlerResolve resolve, handlerReject reject, handlerProgress progress);

@interface JOPromise : NSObject

+ (instancetype)promise:(handlerPromise)handler;
+ (instancetype)resolve:(id)value;
+ (instancetype)reject:(id)value;

- (void)resolve:(id)value;
- (void)reject:(NSError *)error;

@end

#pragma mark - 常规Promise特性
/**
 * p = [JOPromise promise:^(handlerResolve resolve, handlerReject reject) {
 *          [http post... finished:^(NSDictionary *response, NSError *error){
 *              if (!error) {
 *                  resolve(response);
 *              }
 *              else {
 *                  reject(error);
 *              }
 *          }]
 *     }];
 *
 * p.then(^id (NSDictionary *value){
 *            NSLog(@"post response = %@", [value toJson]);
 *            return nil;
 *        });
 */
@interface JOPromise (then)
- (JOPromise *(^)(handlerRun))then;
@end
/**
 * p = [JOPromise promise:^(handlerResolve resolve, handlerReject reject) {
 *          [http post... finished:^(NSDictionary *response, NSError *error){
 *              if (!error) {
 *                  resolve(response);
 *              }
 *              else {
 *                  reject(error);
 *              }
 *          }]
 *     }];
 *
 * p.catch(^(NSError* error){
 *            NSLog(@"post error = %@", error.localizedDescription);
 *        });
 */
@interface JOPromise (catch)
- (JOPromise *(^)(handlerError))catch;
@end
/**
 * p = [JOPromise promise:^(handlerResolve resolve, handlerReject reject) {
 *          NSLog(@"time = %f", [[NSDate date] timeIntervalSince1970]);
 *          resolve(@"test after");
 *     }];
 *
 * p.after(3)
 *  .then(^id (NSString *value){
 *            NSLog(@"time = %f", [[NSDate date] timeIntervalSince1970]);
 *            NSLog(@"then value = %@", value);
 *            return nil;
 *        });
 */
@interface JOPromise (after)
- (JOPromise *(^)(NSTimeInterval))after;
@end
/**
 * p = [JOPromise promise:^(handlerResolve resolve, handlerReject reject) {
 *          [http post... finished:^(NSDictionary *response, NSError *error){
 *              if (!error) {
 *                  resolve(response);
 *              }
 *              else {
 *                  reject(error);
 *              }
 *          }]
 *     }].then(^id (NSDictionary *value){
 *            NSLog(@"post response = %@", [value toJson]);
 *            return nil;
 *        })
 *       .catch(^(NSError* error){
 *            NSLog(@"post error = %@", error.localizedDescription);
 *        })
 *       .finally(^{
 *            NSLog(@"无论前面发生了什么，finally最终都会执行");
 *       });
 */
@interface JOPromise (finally)
- (void (^)(dispatch_block_t))finally;
@end

/**
 * p = [JOPromise promise:^(handlerResolve resolve, handlerReject reject) {
 *          [http post... finished:^(NSDictionary *response, NSError *error){
 *              if (!error) {
 *                  resolve(response);
 *              }
 *              else {
 *                  reject(error);
 *              }
 *          }]
 *     }].timeout(3)
 *       .then(^id(id value){
 *          NSLog(@"timeout Promise 框架内会默认传递一个字典 ：value = @{@"Timeout" : @(seconds)}");
 *
 *          Do Something when Timeout...
 *
 *          return nil;
 *       })
 */
@interface JOPromise (timeout)
- (JOPromise *(^)(NSTimeInterval))timeout;
@end
/**
 * static NSUInteger retryCount = 0;
 * p = [JOPromise promise:^(handlerResolve resolve, handlerReject reject) {
 *          retryCount++;
 *
 *          if (retryCount == 2) {
 *               resolve(@"success");
 *          }
 *          else {
 *               reject([NSError errorWithReason:@"needRetry"]);
 *          }
 *     }].retry(3)
 *       .then(^id(id value){
 *          NSLog(@"value = %@, retryCount = %d", value, retryCount);
 *          return nil;
 *       })
 */
@interface JOPromise (retry)
- (JOPromise *(^)(NSUInteger))retry;
@end

#pragma mark - 将多个Promise实例，包装成一个新的Promise实例
/**
 *  p = [JOPromise all:@[p1, p2, p3]];
 *  p 的状态由 p1、p2、p3 决定，分成两种情况：
 *  1、只有 p1、p2、p3 的状态都变成 Resolved，p 的状态才会变成 Resolved，此时 p1、p2、p3 的返回值组成一个数组，传递给p的回调函数。
 *  2、只要 p1、p2、p3 之中有一个被 Rejected，p 的状态就变成 Rejected，此时第一个被 Reject 的实例的返回值，会传递给 p 的回调函数。
 */
@interface JOPromise (all)
+ (instancetype)all:(NSArray<JOPromise *> *)promises;
@end

/**
 *  p = [JOPromise race:@[p1, p2, p3]];
 *  只要 p1、p2、p3 之中有一个实例率先改变状态，p 的状态就跟着改变。那个率先改变的 Promise 实例的返回值，就传递给 p 的回调函数。
 */
@interface JOPromise(race)
+ (instancetype)race:(NSArray<JOPromise *> *)promises;
@end

#pragma 数组相关
/**
 *  将 mapHandler 作用到 array 的每个元素上，并传递作用之后的 array
 */
@interface JOPromise(map)
+ (instancetype)map:(NSArray *)array mapHandler:(handlerMap)handler;
@end

/**
 *  用 filterHandler 过滤 array，并传递过滤之后的 array
 */
@interface JOPromise (filter)
+ (instancetype)filter:(NSArray *)array filterHandler:(handlerFilter)handler;
@end

/**
 *  用 reduceHandler 作为累加器，将 array 中的值（下标从小到大）开始合并，并传递最终合并之后的值
 */
@interface JOPromise (reduce)
+ (instancetype)reduce:(NSArray *)array reduceHandler:(handlerReduce)handler initialValue:(id)initialValue;
@end

@interface JOProgressPromise: JOPromise
@property(nonatomic, readonly) handlerProgress progressHandler;

+ (instancetype)promise:(handlerProgressPromise)block;
- (JOPromise *(^)(handlerProgress))progress;
- (void)progress:(double)progress value:(id)value;

@end





