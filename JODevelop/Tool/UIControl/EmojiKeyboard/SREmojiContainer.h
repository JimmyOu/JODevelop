//
//  SREmojiContainer.h
//  JODevelop
//
//  Created by JimmyOu on 2018/2/5.
//  Copyright © 2018年 JimmyOu. All rights reserved.
//

#import <UIKit/UIKit.h>
@class SREmojiContainer;
@protocol EmojiContainerDelegate <NSObject>
@optional
- (void)inputStringInView:(SREmojiContainer *)view text:(NSString *)text;
- (void)delBtnPressedInView:(SREmojiContainer *)view;

@end

@interface SREmojiContainer : UIView

@property (nonatomic, weak) id<EmojiContainerDelegate> delegate;

@end
