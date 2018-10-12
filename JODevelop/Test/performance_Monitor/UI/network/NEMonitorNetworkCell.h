//
//  NEMonitorNetworkCell.h
//  SnailReader
//
//  Created by JimmyOu on 2018/8/23.
//  Copyright © 2018年 com.netease. All rights reserved.
//

#import <UIKit/UIKit.h>
@class NEHTTPModel;
extern NSString *const kNEMonitorNetworkCellIndentifier;

@interface NEMonitorNetworkCell : UITableViewCell

@property (strong, nonatomic) NEHTTPModel *model;

+ (CGFloat)preferredCellHeight;

@end
