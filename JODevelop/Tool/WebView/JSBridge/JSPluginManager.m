//
//  JSPluginManager.m
//  JOFoundation
//
//  Created by JimmyOu on 16/11/8.
//  Copyright © 2016年 JimmyOu. All rights reserved.
//

#import "JSPluginManager.h"
#import "JSSuperPlugin.h"
#import "NSDictionary+Extension.h"
#import "JSResult.h"
@interface JSPluginManager ()
@property (nonatomic, strong) NSMutableDictionary<NSString *,Class> *plugins;
@end
@implementation JSPluginManager
+ (instancetype)sharedInstance
{
    static JSPluginManager *pluginManager = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        pluginManager = [[self alloc] init];
    });
    
    return pluginManager;
}

- (void)registerPlugin:(NSString *)namespace pluginClass:(Class)pluginClass {
    self.plugins[namespace] = pluginClass;
}

- (void)dispatchJSCall:(NSDictionary *)jsCall completion:(void (^)(NSString *, JSResult *))completion {
    if (jsCall && jsCall.count > 0 && [jsCall contains:@"module"] && [jsCall contains:@"method"]) {
        
        NSString *module = jsCall[@"module"];
        NSString *method = jsCall[@"method"];
        
        if (![self.plugins contains:module]) {
            if (completion) {
                completion(jsCall[@"callback"], [JSResult resultWithError:ERR_CODE_MODULE_NOT_EXISTS errMessage:ERR_INFO_MODULE_NOT_EXISTS]);
            }
            return;
        }
        
        JSSuperPlugin *plugin = (JSSuperPlugin *)[[self.plugins[module] alloc] init];
        plugin.pluginManager    = self;
        [plugin executeJSCall:method
                       params:jsCall[@"params"]
                   jsCallback:jsCall[@"callback"]
                   completion:completion];
    } else {
        if (completion) {
            completion(jsCall[@"callback"], [JSResult resultWithError:ERR_CODE_CALL_ERROR errMessage:ERR_INFO_CALL_ERROR]);
        }
    }
}
#pragma mark - setter - getter
- (NSMutableDictionary<NSString *, Class> *)plugins
{
    if (nil == _plugins) {
        _plugins = [NSMutableDictionary dictionary];
    }
    
    return _plugins;
}

@end
