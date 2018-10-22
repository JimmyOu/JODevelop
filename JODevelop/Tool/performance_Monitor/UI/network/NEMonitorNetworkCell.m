//
//  NEMonitorNetworkCell.m
//  SnailReader
//
//  Created by JimmyOu on 2018/8/23.
//  Copyright © 2018年 com.netease. All rights reserved.
//

#import "NEMonitorNetworkCell.h"
#import "NEHTTPModel.h"
#import "NEMonitorUtils.h"

NSString *const kNEMonitorNetworkCellIndentifier = @"kNEMonitorNetworkCellIndentifier";

@interface NEMonitorNetworkCell()
@property (nonatomic, strong) UILabel *nameLabel;
@property (nonatomic, strong) UILabel *pathLabel;
@property (nonatomic, strong) UILabel *transactionDetailsLabel;


@end

@implementation NEMonitorNetworkCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        
        self.nameLabel = [[UILabel alloc] init];
        self.nameLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:12];
        [self.contentView addSubview:self.nameLabel];
        
        self.pathLabel = [[UILabel alloc] init];
        self.pathLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:12];
        self.pathLabel.textColor = [UIColor colorWithWhite:0.4 alpha:1.0];
        [self.contentView addSubview:self.pathLabel];
        
        self.transactionDetailsLabel = [[UILabel alloc] init];
        self.transactionDetailsLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:10];
        self.transactionDetailsLabel.textColor = [UIColor colorWithWhite:0.65 alpha:1.0];
        [self.contentView addSubview:self.transactionDetailsLabel];
    }
    return self;
}
- (void)setModel:(NEHTTPModel *)model {
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
    self.nameLabel.textColor = self.model.error ? [UIColor redColor] : [UIColor blackColor];
    
    self.pathLabel.text = [self pathLabelText];
    CGSize pathLabelPreferredSize = [self.pathLabel sizeThatFits:CGSizeMake(availableTextWidth, CGFLOAT_MAX)];
    CGFloat pathLabelOriginY = ceil((self.contentView.bounds.size.height - pathLabelPreferredSize.height) / 2.0);
    self.pathLabel.frame = CGRectMake(textOriginX, pathLabelOriginY, availableTextWidth, pathLabelPreferredSize.height);
    
    self.transactionDetailsLabel.text = [self transactionDetailsLabelText];
    CGSize transactionLabelPreferredSize = [self.transactionDetailsLabel sizeThatFits:CGSizeMake(availableTextWidth, CGFLOAT_MAX)];
    CGFloat transactionDetailsOriginX = textOriginX;
    CGFloat transactionDetailsLabelOriginY = CGRectGetMaxY(self.contentView.bounds) - kVerticalPadding - transactionLabelPreferredSize.height;
    CGFloat transactionDetailsLabelWidth = self.contentView.bounds.size.width - transactionDetailsOriginX;
    self.transactionDetailsLabel.frame = CGRectMake(transactionDetailsOriginX, transactionDetailsLabelOriginY, transactionDetailsLabelWidth, transactionLabelPreferredSize.height);
}
- (NSString *)nameLabelText
{
    NSURL *url = self.model.ne_request.URL;
    NSString *name = [url lastPathComponent];
    if ([name length] == 0) {
        name = @"/";
    }
    NSString *query = [url query];
    if (query) {
        name = [name stringByAppendingFormat:@"?%@", query];
    }
    return name;
}

- (NSString *)pathLabelText
{
    NSURL *url = self.model.ne_request.URL;
    NSMutableArray *mutablePathComponents = [[url pathComponents] mutableCopy];
    if ([mutablePathComponents count] > 0) {
        [mutablePathComponents removeLastObject];
    }
    NSString *path = [url host];
    for (NSString *pathComponent in mutablePathComponents) {
        path = [path stringByAppendingPathComponent:pathComponent];
    }
    return path;
}
- (NSString *)transactionDetailsLabelText
{
    NSMutableArray *detailComponents = [NSMutableArray array];
    
    NSString *timestamp = self.model.startDateString;
    if ([timestamp length] > 0) {
        [detailComponents addObject:timestamp];
    }
    
    // Omit method for GET (assumed as default)
    NSString *httpMethod = self.model.ne_request.HTTPMethod;
    if ([httpMethod length] > 0) {
        [detailComponents addObject:httpMethod];
    }
    
    NSString *statusCodeString = self.model.statusCodeString;
    if ([statusCodeString length] > 0) {
        [detailComponents addObject:statusCodeString];
    }
    if (self.model.responseFlow > 0) {
        NSString *responseSize = [NSByteCountFormatter stringFromByteCount:self.model.responseFlow countStyle:NSByteCountFormatterCountStyleBinary];
        [detailComponents addObject:responseSize];
    }
    NSString *duration = self.model.formateDuation;
    if (duration) {
        [detailComponents addObject:duration];
    }
    
    return [detailComponents componentsJoinedByString:@" ・ "];
}


+ (CGFloat)preferredCellHeight {
    return 65;
}

@end
