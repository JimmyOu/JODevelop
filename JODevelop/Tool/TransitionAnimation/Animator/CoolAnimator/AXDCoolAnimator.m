//
//  AXDCoolAnimator.m
//  JODevelop
//
//  Created by JimmyOu on 17/4/27.
//  Copyright © 2017年 JimmyOu. All rights reserved.
//

#import "AXDCoolAnimator.h"
#import "AXDCoolAnimator+Explode.h"
#import "AXDCoolAnimator+Fold.h"
#import "AXDCoolAnimator+Lines.h"
#import "AXDCoolAnimator+MiddlePageFlip.h"
#import "AXDCoolAnimator+PageFlip.h"
#import "AXDCoolAnimator+Portal.h"
#import "AXDCoolAnimator+Scanning.h"

@interface AXDCoolAnimator ()

@property (nonatomic, weak) UIView *pageFlipTempView;

@end
@implementation AXDCoolAnimator{
    AXDCoolTransitionAnimatorType _type;
}
- (void)dealloc {
    NSLog(@"%@ dealloc",[self class]);
}

+ (instancetype)animatorWithType:(AXDCoolTransitionAnimatorType)type {
    return [[self alloc] initWithTransitionType:type];
}

- (instancetype)initWithTransitionType:(AXDCoolTransitionAnimatorType)type{
    self = [super init];
    if (self) {
        _type = type;
        _foldCount = 4;
    }
    return self;
}
- (void)setToAnimation:(id<UIViewControllerContextTransitioning>)transitionContext fromVC:(UIViewController *)fromVC toVC:(UIViewController *)toVC fromView:(UIView *)fromView toView:(UIView *)toView {
    switch (_type) {
        case AXDCoolTransitionAnimatorTypePageFlip: {
            [self setPageFlipToAnimation:transitionContext];
            break;
        }
        case AXDCoolTransitionAnimatorTypePageMiddleFlipFromLeft: {
            [self setMiddlePageFlipToAnimation:transitionContext direction:AXDMiddlePageFlipDirectionLeft];
            break;
        }
        case AXDCoolTransitionAnimatorTypePageMiddleFlipFromRight: {
            [self setMiddlePageFlipToAnimation:transitionContext direction:AXDMiddlePageFlipDirectionRight];
            break;
        }
        case AXDCoolTransitionAnimatorTypePageMiddleFlipFromTop: {
            [self setMiddlePageFlipToAnimation:transitionContext direction:AXDMiddlePageFlipDirectionTop];
            break;
        }
        case AXDCoolTransitionAnimatorTypePageMiddleFlipFromBottom: {
            [self setMiddlePageFlipToAnimation:transitionContext direction:AXDMiddlePageFlipDirectionBottom];
            break;
        }
        case AXDCoolTransitionAnimatorTypePortal: {
            [self setPortalToAnimation:transitionContext];
            break;
        }
        case AXDCoolTransitionAnimatorTypeFoldFromLeft: {
            [self setFoldToAnimation:transitionContext leftFlag:YES];
            break;
        }
        case AXDCoolTransitionAnimatorTypeFoldFromRight: {
            [self setFoldToAnimation:transitionContext leftFlag:NO];
            break;
        }
        case AXDCoolTransitionAnimatorTypeExplode: {
            [self setExplodeToAnimation:transitionContext];
            break;
        }
        case AXDCoolTransitionAnimatorTypeHorizontalLines: {
            [self setLinesToAnimation:transitionContext vertical:NO];
            break;
        }
        case AXDCoolTransitionAnimatorTypeVerticalLines: {
            [self setLinesToAnimation:transitionContext vertical:YES];
            break;
        }
        case AXDCoolTransitionAnimatorTypeScanningFromLeft: {
            [self setScanningToAnimation:transitionContext direction:0];
            break;
        }
        case AXDCoolTransitionAnimatorTypeScanningFromRight: {
            [self setScanningToAnimation:transitionContext direction:1];
            break;
        }
        case AXDCoolTransitionAnimatorTypeScanningFromTop: {
            [self setScanningToAnimation:transitionContext direction:2];
            break;
        }
        case AXDCoolTransitionAnimatorTypeScanningFromBottom: {
            [self setScanningToAnimation:transitionContext direction:3];
            break;
        }
    }
}

- (void)setBackAnimation:(id<UIViewControllerContextTransitioning>)transitionContext fromVC:(UIViewController *)fromVC toVC:(UIViewController *)toVC fromView:(UIView *)fromView toView:(UIView *)toView {
    switch (_type) {
        case AXDCoolTransitionAnimatorTypePageFlip: {
            [self setPageFlipBackAnimation:transitionContext];
            break;
        }
        case AXDCoolTransitionAnimatorTypePageMiddleFlipFromLeft: {
            [self setMiddlePageFlipBackAnimation:transitionContext direction:AXDMiddlePageFlipDirectionRight];
            break;
        }
        case AXDCoolTransitionAnimatorTypePageMiddleFlipFromRight: {
            [self setMiddlePageFlipBackAnimation:transitionContext direction:AXDMiddlePageFlipDirectionLeft];
            break;
        }
        case AXDCoolTransitionAnimatorTypePageMiddleFlipFromTop: {
            [self setMiddlePageFlipBackAnimation:transitionContext direction:AXDMiddlePageFlipDirectionBottom];
            break;
        }
        case AXDCoolTransitionAnimatorTypePageMiddleFlipFromBottom: {
            [self setMiddlePageFlipBackAnimation:transitionContext direction:AXDMiddlePageFlipDirectionTop];
            break;
        }
        case AXDCoolTransitionAnimatorTypePortal: {
            [self setPortalBackAnimation:transitionContext];
            break;
        }
        case AXDCoolTransitionAnimatorTypeFoldFromLeft: {
            [self setFoldBackAnimation:transitionContext leftFlag:NO];
            break;
        }
        case AXDCoolTransitionAnimatorTypeFoldFromRight: {
            [self setFoldBackAnimation:transitionContext leftFlag:YES];
            break;
        }
        case AXDCoolTransitionAnimatorTypeExplode: {
            [self setExplodeBackAnimation:transitionContext];
            break;
        }
        case AXDCoolTransitionAnimatorTypeHorizontalLines: {
            [self setLinesBackAnimation:transitionContext vertical:NO];
            break;
        }
        case AXDCoolTransitionAnimatorTypeVerticalLines: {
            [self setLinesBackAnimation:transitionContext vertical:YES];
            break;
        }
        case AXDCoolTransitionAnimatorTypeScanningFromLeft: {
            [self setScanningBackAnimation:transitionContext direction:1];
            break;
        }
        case AXDCoolTransitionAnimatorTypeScanningFromRight: {
            [self setScanningBackAnimation:transitionContext direction:0];
            break;
        }
        case AXDCoolTransitionAnimatorTypeScanningFromTop: {
            [self setScanningBackAnimation:transitionContext direction:3];
            break;
        }
        case AXDCoolTransitionAnimatorTypeScanningFromBottom: {
            [self setScanningBackAnimation:transitionContext direction:2];
            break;
        }
    }
}

@end
