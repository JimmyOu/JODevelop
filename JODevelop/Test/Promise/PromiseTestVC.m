//
//  PromiseTestVC.m
//  JODevelop
//
//  Created by JimmyOu on 2018/1/22.
//  Copyright © 2018年 JimmyOu. All rights reserved.
//

#import "PromiseTestVC.h"
#import "JOPromise.h"

@interface PromiseTestVC ()

@end

@implementation PromiseTestVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    //模拟网络请求
}

#pragma mark - Test
//测试3个异步串联操作，第二个失败
- (IBAction)testAsynWithError {
    //异步操作的串联，解决回调地狱问题
    __weak typeof(self) weakSelf = self;
    [JOPromise promise:^(handlerResolve resolve, handlerReject reject) {
        
        //第一个异步操作
        [weakSelf asyncOperation:4
                   operationName:@"1"
                          params:nil
                           block:^(id value, NSError *error) {
                               if (!error) {
                                   resolve(value);
                               } else {
                                   reject(error);
                               }
                           }];
        
    }]
    .then(^id (NSDictionary *value) {
        NSLog(@"post response = %@", value);
        //第二个异步操作
        return [JOPromise promise:^(handlerResolve resolve, handlerReject reject) {
            
            [weakSelf asyncOperation:3
                       operationName:@"2"
                              params:@{@"param1":value}
                               block:^(id value, NSError *error) {
                                   if (!error) {
                                       resolve(value);
                                   } else {
                                       reject(error);
                                   }
                               }
                           needError:YES];
        }];
        
    })
    .then(^id (NSDictionary *value) {
        NSLog(@"post response = %@", value);
        //第3个异步操作
        return [JOPromise promise:^(handlerResolve resolve, handlerReject reject) {
            
            [weakSelf asyncOperation:2
                       operationName:@"3"
                              params:@{@"param1":value}
                               block:^(id value, NSError *error) {
                                   if (!error) {
                                       resolve(value);
                                   } else {
                                       reject(error);
                                   }
                               }];
        }];
        
    })
    .catch(^(NSError* error) { //一旦有一个异步操作出现错误，就会调用catch来捕捉错误。
        NSLog(@"error = %@",error);
    });
}


//测试3个异步串联操作，业务场景：异步之间的依赖关系
- (IBAction)testAsyns {
    //异步操作的串联，解决回调地狱问题
    __weak typeof(self) weakSelf = self;
    [JOPromise promise:^(handlerResolve resolve, handlerReject reject) {
        
        //第一个异步操作
        [weakSelf asyncOperation:4
                   operationName:@"1"
                          params:nil
                           block:^(id value, NSError *error) {
                               if (!error) {
                                   resolve(value);
                               } else {
                                   reject(error);
                               }
                           }];
        
    }]
    .then(^id (NSDictionary *value) {
        NSLog(@"post response = %@", value);
        //第二个异步操作
        return [JOPromise promise:^(handlerResolve resolve, handlerReject reject) {
            
            [weakSelf asyncOperation:3
                       operationName:@"2"
                              params:@{@"param1":value}
                               block:^(id value, NSError *error) {
                                   if (!error) {
                                       resolve(value);
                                   } else {
                                       reject(error);
                                   }
                               }];
        }];
        
    })
    .then(^id (NSDictionary *value) {
        NSLog(@"post response = %@", value);
        //第3个异步操作
        return [JOPromise promise:^(handlerResolve resolve, handlerReject reject) {
            
            [weakSelf asyncOperation:2
                       operationName:@"3"
                              params:@{@"param1":value}
                               block:^(id value, NSError *error) {
                                   if (!error) {
                                       resolve(value);
                                   } else {
                                       reject(error);
                                   }
                               }];
        }];
        
    })
    .catch(^(NSError* error) { //一旦有一个异步操作出现错误，就会调用catch来捕捉错误。
        NSLog(@"error = %@",error);
    });
}


//测试一个异步操作
- (IBAction)testThen {
    __weak typeof(self) weakSelf = self;
    JOPromise *promise = [JOPromise promise:^(handlerResolve resolve, handlerReject reject) {
        
        [weakSelf asyncOperation:4
                   operationName:@"1"
                          params:nil
                           block:^(id value, NSError *error) {
                               if (!error) {
                                   resolve(value);
                               } else {
                                   reject(error);
                               }
                           }];
        
    }];
    promise.then(^id (NSDictionary *value) {
        NSLog(@"post response = %@", value);
        return nil;
    }).catch(^(NSError* error) { //一旦有一个异步操作出现错误，就会调用catch来捕捉错误。
        NSLog(@"error = %@",error);
    }).finally(^{
        NSLog(@"无论前面发生了什么，finally最终都会执行");
    });;
}

//after,延迟执行then
- (IBAction)testAfter:(UIButton *)btn {
    __weak typeof(self) weakSelf = self;
    [JOPromise promise:^(handlerResolve resolve, handlerReject reject) {
        
        [weakSelf asyncOperation:4
                   operationName:@"1"
                          params:nil
                           block:^(id value, NSError *error) {
                               if (!error) {
                                   resolve(value);
                               } else {
                                   reject(error);
                               }
                           }];
        
    }]
    .after(3)
    .then(^id (NSDictionary *value) {
        NSLog(@"post response = %@", value);
        return nil;
    });
}

//timeout,异步超时
- (IBAction)testTimeout:(UIButton *)btn {
    __weak typeof(self) weakSelf = self;
    [JOPromise promise:^(handlerResolve resolve, handlerReject reject) {
        
        [weakSelf asyncOperation:4
                   operationName:@"1"
                          params:nil
                           block:^(id value, NSError *error) {
                               if (!error) {
                                   resolve(value);
                               } else {
                                   reject(error);
                               }
                           }];
        
    }]
    .timeout(3)
    .then(^id (NSDictionary *value) {
        
        if ([value isKindOfClass:[NSDictionary class]] && value[@"Timeout"] != nil) { //超时了，这个异步还没结束
            NSLog(@" Do Something when Timeout...");
        } else { //未超时提前结束
            NSLog(@"value = %@", value);
        }
        return nil;
    });
}
//retry,异步重试
- (IBAction)testRetry {
    //场景1:比如一个异步操作最多可以重试4次（失败4次），然后第二次就成功，成功调用then
    static NSUInteger retryCount = 0;
    __weak typeof(self) weakSelf = self;
    [JOPromise promise:^(handlerResolve resolve, handlerReject reject) {
        retryCount++;
        if (retryCount == 2) {
            [weakSelf asyncOperation:4
                       operationName:[NSString stringWithFormat:@"%d",retryCount]
                              params:nil
                               block:^(id value, NSError *error) {
                                   if (!error) {
                                       resolve(value);
                                   } else {
                                       reject(error);
                                   }
                               }];
        }
        else {
            [weakSelf asyncOperation:4
                       operationName:[NSString stringWithFormat:@"%d",retryCount]
                              params:nil
                               block:^(id value, NSError *error) {
                                   if (!error) {
                                       resolve(value);
                                   } else {
                                       reject(error);
                                   }
                               }
                           needError:YES];
        }
    }].retry(3)
    .then(^id(id value){
        NSLog(@"value = %@, retryCount = %d", value, retryCount);
        return nil;
    }).catch(^(NSError* error) { //一旦有一个异步操作出现错误，就会调用catch来捕捉错误。
        NSLog(@"error = %@",error);
    });
    
    //场景2: 四次全部失败调用catch
    //    static NSUInteger retryCount = 0;
    //    __weak typeof(self) weakSelf = self;
    //    [JOPromise promise:^(handlerResolve resolve, handlerReject reject) {
    //        retryCount++;
    //        [weakSelf asyncOperation:4
    //                   operationName:[NSString stringWithFormat:@"%d",retryCount]
    //                          params:nil
    //                           block:^(id value, NSError *error) {
    //                               if (!error) {
    //                                   resolve(value);
    //                               } else {
    //                                   reject(error);
    //                               }
    //                           }
    //                       needError:YES];
    //    }].retry(3)
    //    .then(^id(id value){
    //        NSLog(@"value = %@, retryCount = %d", value, retryCount);
    //        return nil;
    //    }).catch(^(NSError* error) { //一旦有一个异步操作出现错误，就会调用catch来捕捉错误。
    //        NSLog(@"error = %@",error);
    //    });
}

//All，业务场景：多个异步成功完成后才需要做事儿。
- (IBAction)testAll {
    __weak typeof(self) weakSelf = self;
    JOPromise *p1 = [JOPromise promise:^(handlerResolve resolve, handlerReject reject) {
        [weakSelf asyncOperation:4
                   operationName:@"1"
                          params:nil
                           block:^(id value, NSError *error) {
                               if (!error) {
                                   resolve(value);
                               } else {
                                   reject(error);
                               }
                           }];
        
    }];
    JOPromise *p2 = [JOPromise promise:^(handlerResolve resolve, handlerReject reject) {
        
        [weakSelf asyncOperation:1
                   operationName:@"2"
                          params:nil
                           block:^(id value, NSError *error) {
                               if (!error) {
                                   resolve(value);
                               } else {
                                   reject(error);
                               }
                           }];
        
    }];
    JOPromise *p3 = [JOPromise promise:^(handlerResolve resolve, handlerReject reject) {
        
        [weakSelf asyncOperation:3
                   operationName:@"3"
                          params:nil
                           block:^(id value, NSError *error) {
                               if (!error) {
                                   resolve(value);
                               } else {
                                   reject(error);
                               }
                           }];
        
    }];
    
    [JOPromise all:@[p1,p2,p3]].then(^id (id value) {
        NSLog(@"AllFinished value = %@", value);
        //第二个异步操作
        return nil;
    })
    .catch(^(NSError* error) { //一旦有一个异步操作出现错误，就会调用catch来捕捉错误。
        NSLog(@"error = %@",error);
    });;
}

//测试race
- (IBAction)testRace {
    __weak typeof(self) weakSelf = self;
    JOPromise *p1 = [JOPromise promise:^(handlerResolve resolve, handlerReject reject) {
        [weakSelf asyncOperation:4
                   operationName:@"1"
                          params:nil
                           block:^(id value, NSError *error) {
                               if (!error) {
                                   resolve(value);
                               } else {
                                   reject(error);
                               }
                           }];
        
    }];
    JOPromise *p2 = [JOPromise promise:^(handlerResolve resolve, handlerReject reject) {
        
        [weakSelf asyncOperation:1
                   operationName:@"2"
                          params:nil
                           block:^(id value, NSError *error) {
                               if (!error) {
                                   resolve(value);
                               } else {
                                   reject(error);
                               }
                           }];
        
    }];
    JOPromise *p3 = [JOPromise promise:^(handlerResolve resolve, handlerReject reject) {
        
        [weakSelf asyncOperation:3
                   operationName:@"3"
                          params:nil
                           block:^(id value, NSError *error) {
                               if (!error) {
                                   resolve(value);
                               } else {
                                   reject(error);
                               }
                           }];
        
    }];
    
    [JOPromise race:@[p1,p2,p3]].then(^id (id value) {
        NSLog(@"first success value = %@", value);
        //第二个异步操作
        return nil;
    })
    .catch(^(NSError* error) { //一旦有一个异步操作出现错误，就会调用catch来捕捉错误。
        NSLog(@"first error = %@",error);
    });;
}

#pragma mark - Aysnc
//一个异步操作,不带error
- (void)asyncOperation:(NSTimeInterval)neededTime
         operationName:(NSString *)name
                params:(NSDictionary *)params
                 block:(void(^)(id value , NSError *error))finishBlock {
    [self asyncOperation:neededTime operationName:name params:params block:finishBlock needError:NO];
}

- (void)asyncOperation:(NSTimeInterval)neededTime
         operationName:(NSString *)name
                params:(NSDictionary *)params
                 block:(void(^)(id value , NSError *error))finishBlock
             needError:(BOOL)needError {
    
    NSLog(@"*********** %@ start - aysncOperation***********",name);
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(neededTime * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        NSLog(@"*********** %@ end - aysncOperation***********",name);
        NSString *value = [NSString stringWithFormat:@"%@value",name];
        if (!needError) {
            finishBlock(value,nil);
        } else {
            NSError *error = [NSError errorWithDomain:@"" code:1001 userInfo:@{@"reason":@"请求失败"}];
            finishBlock(nil,error);
        }
    });
}





@end
