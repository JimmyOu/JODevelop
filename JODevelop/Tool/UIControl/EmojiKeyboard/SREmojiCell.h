//
//  SREmojiContainer.h
//  JODevelop
//
//  Created by JimmyOu on 2018/2/5.
//  Copyright © 2018年 JimmyOu. All rights reserved.
//

#import <UIKit/UIKit.h>

#define colorWithIntegerRGB(r,g,b) [UIColor colorWithRed:r/255.0f green:g/255.0f blue:b/255.0f alpha:1.0]
#define kEmojiBtnTag               (100)
#define kEmojiTopMargin            (19.f)
#define kEmojiLeftMargin           (15.f)
#define kEmojiButtonVMargin        (16.f)
#define kEmojiButtonWidth          (35.f)
#define kEmojiButtonHeight         (30.f)
#define kEmojiFontSize             (30.f)
#define kEmojiMAxRow               (3)
#define kEmojiMAxRowBtn            (8)
#define kEmojiPageBtnCount         (kEmojiMAxRow * kEmojiMAxRowBtn - 1)

@class SREmojiCell;

@protocol EmojiCellDelegate <NSObject>

@optional
- (void)EmojiInputAtCell:(SREmojiCell *)cell text:(NSString *)text;
- (void)EmojiInputDel:(SREmojiCell *)cell;

@end

@interface SREmojiCell : UICollectionViewCell

@property(nonatomic, weak) id<EmojiCellDelegate> delegate;

@property (nonatomic, assign) BOOL isBlackStyle;

- (void)SetupButtons:(NSArray *)textArr;

@end
