//
//  PlayAndCacheVC.m
//  JODevelop
//
//  Created by JimmyOu on 2018/5/21.
//  Copyright © 2018年 JimmyOu. All rights reserved.
//

#import "PlayAndCacheVC.h"

#import "JOVideoPlayerCachePath.h"
#import "UIView+JOWebVideoPlayer.h"

//   https://r2---sn-i3belnez.googlevideo.com/videoplayback?signature=E08C138D227411FDBEC09CEE820A188F5D6B7150.8201041F84C991BF72B125DB4D2E3CDFD0A85EAC&requiressl=yes&sparams=dur,ei,id,initcwndbps,ip,ipbits,itag,lmt,mime,mm,mn,ms,mv,pl,ratebypass,requiressl,source,expire&initcwndbps=1903750&fvip=2&fexp=23724337&source=youtube&mime=video/mp4&key=yt6&expire=1525854068&c=WEB&ei=FFvyWvmZIs7bgAOizYSIAQ&lmt=1521254475452279&pl=26&id=o-AKMY1eebBf57PxaVbejHYHj6lJJIMiSxKLwmhjCsZBgG&dur=218.337&mt=1525832334&mv=m&itag=22&ms=au,onr&ip=103.65.40.65&mm=31,26&mn=sn-i3belnez,sn-npoe7n7z&ipbits=0&ratebypass=yes&signature=(null)

//    https://easyreadfs.nosdn.127.net/1520239274501/98634cb4262d47fe858e43ec45373734.mp4

//http://p8gvtitzu.bkt.clouddn.com/dimash.mp4

static NSString *url = @"https://easyreadfs.nosdn.127.net/1520239274501/98634cb4262d47fe858e43ec45373734.mp4";

@interface PlayAndCacheVC ()

@property (nonatomic, strong) UIView *showView;

@property (strong, nonatomic) NSMutableArray *buttonArray;

@end

@implementation PlayAndCacheVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    NSLog(@"document: %@",[JOVideoPlayerCachePath videoCachePath]);
    
    self.showView = [[UIView alloc] init];
    self.showView.backgroundColor = [UIColor redColor];
    self.showView.frame = CGRectMake(0, 200, kScreenWidth, 200);
    [self.view addSubview:self.showView];
    
    self.buttonArray = [NSMutableArray array];
    
    UIButton *button1 = [UIButton buttonWithType:UIButtonTypeCustom];
    button1.frame = CGRectMake(50, 100, 70, 50);
    [button1 setTitle:@"Remote" forState:UIControlStateNormal];
    button1.backgroundColor = [UIColor darkGrayColor];
    [button1 setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [button1 addTarget:self action:@selector(playClick) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button1];
    
    
    
    UIButton *button2 = [UIButton buttonWithType:UIButtonTypeCustom];
    button2.frame = CGRectMake(250, 100, 70, 50);
    [button2 setTitle:@"Local" forState:UIControlStateNormal];
    button2.backgroundColor = [UIColor darkGrayColor];
    [button2 setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [button2 addTarget:self action:@selector(playLocal) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button2];
    
    
    UIButton *button3 = [UIButton buttonWithType:UIButtonTypeCustom];
    button3.frame = CGRectMake(kScreenWidth/2 - 50, 20, 100, 50);
    [button3 setTitle:@"clearCache" forState:UIControlStateNormal];
    button3.backgroundColor = [UIColor darkGrayColor];
    [button3 setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [button3 addTarget:self action:@selector(clearLocal) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button3];
    
    [self.buttonArray addObject:button1];
    [self.buttonArray addObject:button2];
    [self.buttonArray addObject:button3];
    
}

- (void)playClick {
//    [[JOPlayer sharedInstance] playWithUrl:[NSURL URLWithString:url] showView:self.showView];
    [self.showView jo_playVideoWithURL:[NSURL URLWithString:url]];
}
- (void)clearLocal {
    NSString *dir = [JOVideoPlayerCachePath videoCachePath];
    [[NSFileManager defaultManager] removeItemAtPath:dir error:nil];
}

- (void)playLocal {
    
    NSString *localFile = [JOVideoPlayerCachePath videoCachePathForKey:url];
    NSURL *localURL = [NSURL fileURLWithPath:localFile];
//    [[JOPlayer sharedInstance] playWithUrl:localURL showView:self.showView];
}

- (void)fullScreen {
    [self.buttonArray enumerateObjectsUsingBlock:^(UIButton *obj, NSUInteger idx, BOOL * _Nonnull stop) {
        obj.hidden = YES;
    }];
}
- (void)halfScreen {
    [self.buttonArray enumerateObjectsUsingBlock:^(UIButton *obj, NSUInteger idx, BOOL * _Nonnull stop) {
        obj.hidden = NO;
    }];
}


@end
