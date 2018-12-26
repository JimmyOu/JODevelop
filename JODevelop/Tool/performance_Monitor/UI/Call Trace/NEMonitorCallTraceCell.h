//
//  NEMonitorCallTraceCell.h
//  SnailReader
//
//  Created by JimmyOu on 2018/12/20.
//  Copyright © 2018 com.netease. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
@class SMCallTraceTimeCostModel;

extern NSString *const kNEMonitorCallTraceCellIndentifier;
@interface NEMonitorCallTraceCell : UITableViewCell

@property (strong, nonatomic) SMCallTraceTimeCostModel *model;

+ (CGFloat)preferredCellHeight;

@end

NS_ASSUME_NONNULL_END
