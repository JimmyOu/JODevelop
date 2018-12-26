//
//  NEMonitorCallTraceCell.m
//  SnailReader
//
//  Created by JimmyOu on 2018/12/20.
//  Copyright © 2018 com.netease. All rights reserved.
//

#import "NEMonitorCallTraceCell.h"
#import "SMCallTraceTimeCostModel.h"
NSString *const kNEMonitorCallTraceCellIndentifier = @"kNEMonitorCallTraceCellIndentifier";

@interface NEMonitorCallTraceCell()

@property (nonatomic, strong) UILabel *nameLabel;
@property (nonatomic, strong) UILabel *detailsLabel;

@end
@implementation NEMonitorCallTraceCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
     self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self ) {
        self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        self.nameLabel = [[UILabel alloc] init];
        self.nameLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:12];
        [self.contentView addSubview:self.nameLabel];
        
        self.detailsLabel = [[UILabel alloc] init];
        self.detailsLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:10];
        self.detailsLabel.textColor = [UIColor colorWithWhite:0.65 alpha:1.0];
        [self.contentView addSubview:self.detailsLabel];
    }
    return self;
}

- (void)setModel:(SMCallTraceTimeCostModel *)model {
    if (_model != model) {
        _model = model;
        [self setNeedsLayout];
    }
}
- (void)layoutSubviews
{
    [super layoutSubviews];
    
    const CGFloat kVerticalPadding = 8.0;
    const CGFloat kLeftPadding = 10.0;
    
    CGFloat textOriginX = kLeftPadding;
    CGFloat availableTextWidth = self.contentView.bounds.size.width - textOriginX;
    
    self.nameLabel.text = [self nameLabelText];
    CGSize nameLabelPreferredSize = [self.nameLabel sizeThatFits:CGSizeMake(availableTextWidth, CGFLOAT_MAX)];
    self.nameLabel.frame = CGRectMake(textOriginX, kVerticalPadding, availableTextWidth, nameLabelPreferredSize.height);
    self.nameLabel.textColor = [UIColor blackColor];
    
    self.detailsLabel.text = [self detailsLabelText];
    CGSize transactionLabelPreferredSize = [self.detailsLabel sizeThatFits:CGSizeMake(availableTextWidth, CGFLOAT_MAX)];
    CGFloat transactionDetailsOriginX = textOriginX;
    CGFloat transactionDetailsLabelOriginY = CGRectGetMaxY(self.contentView.bounds) - kVerticalPadding - transactionLabelPreferredSize.height;
    CGFloat transactionDetailsLabelWidth = self.contentView.bounds.size.width - transactionDetailsOriginX;
    self.detailsLabel.frame = CGRectMake(transactionDetailsOriginX, transactionDetailsLabelOriginY, transactionDetailsLabelWidth, transactionLabelPreferredSize.height);
}

- (NSString *)nameLabelText
{
    return [NSString stringWithFormat:@"%@[%@ %@]",(self.model.isClassMethod ? @"+":@"-"),self.model.className,self.model.methodName];
}


- (NSString *)detailsLabelText
{
    NSMutableArray *detailComponents = [NSMutableArray array];
    
    NSString *timeCost = [NSString stringWithFormat:@"平均耗时:%.2f ms",self.model.timeCost * 1000];
    
    if ([timeCost length] > 0) {
        [detailComponents addObject:timeCost];
    }
    
    
    NSString *callDepth = [NSString stringWithFormat:@"调用深度:%d",(int)self.model.callDepth];
    if ([callDepth length] > 0) {
        [detailComponents addObject:callDepth];
    }

    NSString *frequency = [NSString stringWithFormat:@"调用频次:%d",(int)self.model.frequency];
    if (frequency) {
        [detailComponents addObject:frequency];
    }
    
    return [detailComponents componentsJoinedByString:@" ・ "];
}


+ (CGFloat)preferredCellHeight {
    return 65;
}


@end
