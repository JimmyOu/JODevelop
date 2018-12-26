//
//  AXDScrollPageConst.h
//  JODevelop
//
//  Created by JimmyOu on 2017/5/11.
//  Copyright © 2017年 JimmyOu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, AXDPageCachePolicy) {
    AXDPageCachePolicyNoLimit    = 0,   // No limit
    AXDPageCachePolicyMemory  = 1,   // Low Memory but may block when scroll
    AXDPageCachePolicyBalanced   = 3,   // Balanced ↑ and ↓
    AXDPageCachePolicyPolicyHigh       = 5 ,   // High
    AXDPageCachePolicyPolicyVeryHigh       = 7 ,   // High
    AXDPageCachePolicyPolicyHighest       = 9    // High
};

typedef NS_ENUM(NSUInteger, AXDPagePreloadPolicy) {
    AXDPagePreloadPolicyNever     = 0, // Never pre-load controller.
    AXDPagePreloadPolicyNeighbour = 1, // Pre-load the controller next to the current.
    AXDPagePreloadPolicyNear      = 2  // Pre-load 2 controllers near the current.
};



// 常量
extern const CGFloat kAXDSegmentHeight;
extern const CGFloat kAXDSegmentTitleFontSize;
extern const CGFloat kAXDSegmentTitleFontMargin;
extern const CGFloat kAXDSegmentScrollLineHeight;



