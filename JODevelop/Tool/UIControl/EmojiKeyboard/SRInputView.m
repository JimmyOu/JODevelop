//
//  SRInputView.m
//  JODevelop
//
//  Created by JimmyOu on 2018/2/5.
//  Copyright © 2018年 JimmyOu. All rights reserved.
//

#import "SRInputView.h"
#import "Masonry.h"
#import "SREmojiContainer.h"
#import "UIView+Extension.h"
#import "UIColor+Extension.h"

static const CGFloat kHeightOfEmojiView = 200;

@interface SRInputView() <EmojiContainerDelegate>
@property (strong, nonatomic) UIButton *emojiV;
@property (strong, nonatomic) UIButton *keyboardV;
@property (strong, nonatomic) UIButton *completeBtn;
@property (weak, nonatomic) id<UITextInput> inputV;
@property (strong, nonatomic) SREmojiContainer *container;
@property (weak, nonatomic) UIView *parentV;
@end

@implementation SRInputView


- (instancetype)initWithTextInput:(id<UITextInput>)input {
    if (self = [super initWithFrame:CGRectZero]) {
        [self setupUI];
        self.backgroundColor = [UIColor colorWithHexString:@"f4f5f7"];
        self.inputV = input;
        [self registerNotifications];
    }
    return self;
}
- (void)dealloc {
    [self unregister];
}
- (void)registerNotifications {
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardFrameWillChange:)
                                                 name:UIKeyboardWillChangeFrameNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWasShown:)
                                                 name:UIKeyboardDidShowNotification
                                               object:nil];
}
- (void)unregister {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
- (void)didMoveToSuperview {
    self.parentV = self.superview;
    if (!self.container.superview) {
        [self.parentV addSubview:self.container];
        [self.container mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.mas_equalTo(self);
            make.height.mas_equalTo(kHeightOfEmojiView);
            make.top.mas_equalTo(self.mas_bottom);
            make.left.mas_equalTo(self);
        }];
    }
}

- (void)keyboardFrameWillChange:(NSNotification *)notification {

    CGRect keyboarbRect = [[notification userInfo][UIKeyboardFrameEndUserInfoKey] CGRectValue];
    // 隐藏键盘
    if (keyboarbRect.origin.y >= [UIScreen mainScreen].bounds.size.height) {
        // 当前正显示颜文字键盘，则不执行
        if (!self.emojiV.selected) {
            [self mas_updateConstraints:^(MASConstraintMaker *make) {
                make.bottom.mas_equalTo(self.parentV);
            }];
        }
    } else {
        // 显示键盘
        [self setYanButtonSelected:NO];
        if (!self.emojiV.selected) {
            [self mas_updateConstraints:^(MASConstraintMaker *make) {
                make.bottom.mas_equalTo(self.parentV).offset(-keyboarbRect.size.height);
            }];
        }
        //
        //        if (!self.yanInputButton.isSelected) {
        //            if (IS_IPHONEX) {
        //                [self.commentViewBottomLayoutConstraint setConstant:keyboarbRect.size.height - 34.f];
        //            } else {
        //                [self.commentViewBottomLayoutConstraint setConstant:keyboarbRect.size.height];
        //            }
        //        }
    }
    
    [UIView animateWithDuration:0.2f
                     animations:^{
                         [self.parentV layoutIfNeeded];
                     }];
}

- (void)keyboardWasShown:(NSNotification *)notification {
    
}

- (void)setupUI {
    CGFloat kmagin = 10;
    [self addSubview:self.emojiV];
    [self.emojiV mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self).offset(kmagin);
        make.centerY.mas_equalTo(self);
    }];
    [self addSubview:self.keyboardV];
    [self.keyboardV mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.emojiV.mas_right).offset(kmagin);
        make.centerY.mas_equalTo(self);
    }];
    [self addSubview:self.completeBtn];
    [self.completeBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(self).offset(-kmagin);
        make.centerY.mas_equalTo(self);
    }];
}
- (UIButton *)keyboardV {
    if (!_keyboardV) {
        _keyboardV = [UIButton buttonWithType:UIButtonTypeCustom];
        [_keyboardV addTarget:self action:@selector(keyboardClick) forControlEvents:UIControlEventTouchUpInside];
        [_keyboardV setBackgroundImage:[UIImage imageNamed:@"emoji_keyboard"] forState:UIControlStateNormal];
        [_keyboardV setBackgroundImage:[UIImage imageNamed:@"emoji_keyboard_selected"] forState:UIControlStateSelected];
    }
    return _keyboardV;
}
- (UIButton *)emojiV {
    if (!_emojiV) {
        _emojiV = [UIButton buttonWithType:UIButtonTypeCustom];
        [_emojiV addTarget:self action:@selector(emojiClick) forControlEvents:UIControlEventTouchUpInside];
        [_emojiV setBackgroundImage:[UIImage imageNamed:@"emojiBtn_normal"] forState:UIControlStateNormal];
        [_emojiV setBackgroundImage:[UIImage imageNamed:@"emojiBtn_selected"] forState:UIControlStateSelected];
    }
    return _emojiV;
}
- (UIButton *)completeBtn {
    if (!_completeBtn) {
        _completeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_completeBtn addTarget:self action:@selector(complete) forControlEvents:UIControlEventTouchUpInside];
        [_completeBtn setTitle:@"完成" forState:UIControlStateNormal];
        [_completeBtn setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
        _completeBtn.titleLabel.font = [UIFont systemFontOfSize:15];
    }
    return _completeBtn;
}

#pragma mark - EmojiContainerDelegate
- (void)inputStringInView:(SREmojiContainer *)view text:(NSString *)text {
    [self.inputV insertText:text];
}

- (void)delBtnPressedInView:(SREmojiContainer *)view {
    [self.inputV deleteBackward];
}

- (void)complete {
    [self.parentV endEditing:YES];
    if (self.delegate && [self.delegate respondsToSelector:@selector(didClickComplete)]) {
        [self.delegate didClickComplete];
    }
}
- (void)emojiClick {
    [self setYanButtonSelected:YES];
    self.keyboardV.selected = NO;
    [self mas_updateConstraints:^(MASConstraintMaker *make) {
        make.bottom.mas_equalTo(self.parentV).offset(-kHeightOfEmojiView);
    }];
    [self.parentV endEditing:YES]; // 这个必须放在setYanButtonSelected后面
    [self.parentV layoutIfNeeded];
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(didClickEmojiView)]) {
        [self.delegate didClickEmojiView];
    }
}
- (void)keyboardClick {
    [self setYanButtonSelected:NO];
    self.keyboardV.selected = YES;
    [self.inputV performSelector:@selector(becomeFirstResponder)];
    if (self.delegate && [self.delegate respondsToSelector:@selector(didClickKeyboard)]) {
        [self.delegate didClickKeyboard];
    }
}

- (void)setYanButtonSelected:(BOOL)selected {
    self.emojiV.selected = selected;
    if (selected) {
        self.container.hidden = NO;
    } else {
        self.container.hidden = YES;
    }
}
- (SREmojiContainer *)container {
    if (!_container) {
        _container = [[SREmojiContainer alloc] init];
        _container.delegate = self;
    }
    return _container;
}

@end
