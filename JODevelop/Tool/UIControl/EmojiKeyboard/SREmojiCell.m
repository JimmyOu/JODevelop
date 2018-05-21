//
//  SREmojiContainer.h
//  JODevelop
//
//  Created by JimmyOu on 2018/2/5.
//  Copyright © 2018年 JimmyOu. All rights reserved.
//

#import "SREmojiCell.h"


@implementation SREmojiCell

- (void)SetupButtons:(NSArray *)textArr {
    NSArray *viewsToRemove = [self.contentView subviews];
    for (UIView *v in viewsToRemove) {
        [v removeFromSuperview];
    }
    
    float hMargin = ([UIScreen mainScreen].bounds.size.width - kEmojiLeftMargin * 2 - kEmojiButtonWidth * kEmojiMAxRowBtn) / (kEmojiMAxRowBtn - 1);
    for (int row = 0; row < kEmojiMAxRow; row++) {
        float offset = kEmojiLeftMargin;
        for (int j = 0; j < kEmojiMAxRowBtn; j++) {
            if ((row * kEmojiMAxRowBtn + j) > [textArr count])
                return;
           
            UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(offset, kEmojiTopMargin + (kEmojiButtonHeight + kEmojiButtonVMargin) * row, kEmojiButtonWidth, kEmojiButtonHeight)];
//            NSLog(@"%f", (kEmojiButtonHeight + kEmojiButtonVMargin) * row + kEmojiTopMargin);
            [[button titleLabel] setFont:[UIFont systemFontOfSize:kEmojiFontSize]];
            offset += (hMargin + kEmojiButtonWidth);
            if (self.isBlackStyle) {
                [button setBackgroundColor:[UIColor clearColor]];
            } else {
                [button setBackgroundColor:colorWithIntegerRGB(0xf5, 0xf5, 0xf5)];
            }

            NSString *title = nil;
            if ((row * kEmojiMAxRowBtn + j) < [textArr count]) {
                title = [textArr objectAtIndex:(row * kEmojiMAxRowBtn + j)];
                button.tag = 0;
            }
            else {
                [button setImage:[UIImage imageNamed:@"emoji_delete"] forState:UIControlStateNormal];
                [button setImage:[UIImage imageNamed:@"emoji_delete_press"] forState:UIControlStateHighlighted];
                button.tag = kEmojiBtnTag;
            }
            [button setTitle:title forState:UIControlStateNormal];
            [button addTarget:self action:@selector(btnPressed:) forControlEvents:UIControlEventTouchUpInside];
            [self.contentView addSubview:button];
        }
    }
}

- (void)btnPressed:(id)sender {
    UIButton *btn = (UIButton *)sender;
    if (btn.tag == kEmojiBtnTag) {
        if ([_delegate respondsToSelector:@selector(EmojiInputDel:)]) {
            [_delegate performSelector:@selector(EmojiInputDel:) withObject:self];
        }
    } else {
        if ([_delegate respondsToSelector:@selector(EmojiInputAtCell: text:)]) {
            [_delegate performSelector:@selector(EmojiInputAtCell: text:) withObject:self withObject:btn.titleLabel.text];
        }
    }
}
@end
