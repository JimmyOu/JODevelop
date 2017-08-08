//
//  AppDelegate.m
//  JODevelop
//
//  Created by JimmyOu on 17/4/13.
//  Copyright © 2017年 JimmyOu. All rights reserved.
//

#import "AppDelegate.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    NSLog(@"%s",__func__);
    
    [self setup3DTouch:application];
    return YES;
}
- (void)application:(UIApplication *)application performActionForShortcutItem:(UIApplicationShortcutItem *)shortcutItem completionHandler:(void (^)(BOOL))completionHandler {
    NSLog(@"%s",__func__);
    
    if (shortcutItem) {
        UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        UIViewController *toVC = [storyBoard instantiateViewControllerWithIdentifier:@"3DTouchVC"];
        //判断设置的快捷选项标签唯一标识，根据不同标识执行不同操作
        if([shortcutItem.type isEqualToString:@"One"]){
            NSLog(@"第一个按钮");
        } else if ([shortcutItem.type isEqualToString:@"Two"]) {
            //进入搜索界面
            NSLog(@"第二个按钮");
        } else if ([shortcutItem.type isEqualToString:@"Three"]) {
            //进入分享界面
            NSLog(@"第三个按钮");
        }
        
        toVC.title = shortcutItem.localizedTitle;
        
        
        UINavigationController *navi = (UINavigationController *) self.window.rootViewController;
        [navi pushViewController:toVC animated:YES];
    }
    
    if (completionHandler) {
        completionHandler(YES);
    }
}

- (void)setup3DTouch:(UIApplication *)application
{
    /**
     type 该item 唯一标识符
     localizedTitle ：标题
     localizedSubtitle：副标题
     icon：icon图标 可以使用系统类型 也可以使用自定义的图片
     userInfo：用户信息字典 自定义参数，完成具体功能需求
     */
        UIApplicationShortcutIcon *icon1 = [UIApplicationShortcutIcon iconWithTemplateImageName:@"run"];
       UIApplicationShortcutIcon *icon2 = [UIApplicationShortcutIcon iconWithTemplateImageName:@"scan"];
       UIApplicationShortcutIcon *icon3 = [UIApplicationShortcutIcon iconWithTemplateImageName:@"wifi"];

    UIApplicationShortcutItem *runItem = [[UIApplicationShortcutItem alloc] initWithType:@"One" localizedTitle:@"跑步" localizedSubtitle:@"跑步详细信息" icon:icon1 userInfo:nil];
    
    UIApplicationShortcutItem *scanItem = [[UIApplicationShortcutItem alloc] initWithType:@"Two" localizedTitle:@"扫描" localizedSubtitle:@"无线详细信息" icon:icon2 userInfo:nil];
    
    UIApplicationShortcutItem *wifiItem = [[UIApplicationShortcutItem alloc] initWithType:@"Three" localizedTitle:@"无线" localizedSubtitle:@"无线详细信息" icon:icon3 userInfo:nil];
    /** 将items 添加到app图标 */
    application.shortcutItems = @[runItem,scanItem,wifiItem];
}

- (void)applicationWillResignActive:(UIApplication *)application {
NSLog(@"%s",__func__);
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
NSLog(@"%s",__func__);
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    NSLog(@"%s",__func__);
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    NSLog(@"%s",__func__);
}


- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    NSLog(@"%s",__func__);
}


@end
