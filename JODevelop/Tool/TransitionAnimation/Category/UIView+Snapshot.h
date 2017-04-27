//
//  UIView+Snapshot.h
//  JODevelop
//
//  Created by JimmyOu on 17/4/27.
//  Copyright © 2017年 JimmyOu. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (Snapshot)

@property (nonatomic, readonly) UIImage *snapshotImage;
@property (nonatomic, strong) UIImage *contentImage;

@end
