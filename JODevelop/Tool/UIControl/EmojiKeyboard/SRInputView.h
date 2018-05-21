//
//  SRInputView.h
//  JODevelop
//
//  Created by JimmyOu on 2018/2/5.
//  Copyright © 2018年 JimmyOu. All rights reserved.
// 出现带表情的键盘

#import <UIKit/UIKit.h>

@protocol SRInputViewDelegate<NSObject>
- (void)didClickEmojiView;
- (void)didClickKeyboard;
- (void)didClickComplete;
@end
@interface SRInputView : UIView

@property (readonly) UIButton *emojiV;
@property (readonly) UIButton *keyboardV;
@property (readonly) UIButton *completeBtn;

@property (weak, nonatomic) id<SRInputViewDelegate> delegate;

- (instancetype)initWithTextInput:(id<UITextInput>)input;


@end
