//
//  NECallTraceDetailVC.m
//  SnailReader
//
//  Created by JimmyOu on 2018/12/20.
//  Copyright © 2018 com.netease. All rights reserved.
//

#import "NECallTraceDetailVC.h"
#import "SMCallTraceTimeCostModel.h"
#import "NEMonitorToast.h"


@interface NECallTraceDetailVC ()

@property (strong, nonatomic) UITextView *textView;

@end

@implementation NECallTraceDetailVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.automaticallyAdjustsScrollViewInsets=NO;
    self.view.backgroundColor=[UIColor whiteColor];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Copy" style:UIBarButtonItemStyleDone target:self action:@selector(copyString:)];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(back)];
    self.title = self.model.className;
    
    [self.view addSubview:self.textView];
    [self setupAttributedString];
}

- (void)setupAttributedString {
    UIColor *titleColor=[UIColor colorWithRed:0.24f green:0.51f blue:0.78f alpha:1.00f];
    UIFont *titleFont=[UIFont systemFontOfSize:17];
    UIColor *detailColor=[UIColor blackColor];
    UIFont *detailFont=[UIFont systemFontOfSize:14.0];
    
    NSMutableAttributedString *callTrace = [[NSMutableAttributedString alloc] initWithString:@"call:\n"
                                                                                  attributes:@{
                                                                                               NSFontAttributeName : titleFont,
                                                                                               NSForegroundColorAttributeName: titleColor
                                                                                               }];
    NSMutableAttributedString *costTime = [[NSMutableAttributedString alloc] initWithString:@"cost:"
                                                                                  attributes:@{
                                                                                               NSFontAttributeName : titleFont,
                                                                                               NSForegroundColorAttributeName: titleColor
                                                                                               }];
    NSMutableAttributedString *callDepth = [[NSMutableAttributedString alloc] initWithString:@"callDepth:"
                                                                                  attributes:@{
                                                                                               NSFontAttributeName : titleFont,
                                                                                               NSForegroundColorAttributeName: titleColor
                                                                                               }];
    
    
    NSMutableAttributedString *path = [[NSMutableAttributedString alloc] initWithString:@"path:\n"
                                                                                  attributes:@{
                                                                                               NSFontAttributeName : titleFont,
                                                                                               NSForegroundColorAttributeName: titleColor
                                                                                               }];
    NSMutableAttributedString *frequency = [[NSMutableAttributedString alloc] initWithString:@"frequency:"
                                                                             attributes:@{
                                                                                          NSFontAttributeName : titleFont,
                                                                                          NSForegroundColorAttributeName: titleColor
                                                                                          }];
    
    NSMutableAttributedString *callTraceDetail = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@[%@ %@]\n",(_model.isClassMethod ? @"+":@"-"),_model.className, _model.methodName]
                                                                 attributes:@{
                                                                              NSFontAttributeName : detailFont,
                                                                              NSForegroundColorAttributeName: detailColor
                                                                              }];
    
    NSMutableAttributedString *costTimeDetail = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%.2f ms\n",_model.timeCost * 1000]
                                                                                        attributes:@{
                                                                                                     NSFontAttributeName : detailFont,
                                                                                                     NSForegroundColorAttributeName: detailColor
                                                                                                     }];
    
    NSMutableAttributedString *callDepthDetail = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%d\n",(int)self.model.callDepth]
                                                                                       attributes:@{
                                                                                                    NSFontAttributeName : detailFont,
                                                                                                    NSForegroundColorAttributeName: detailColor
                                                                                                    }];

    NSMutableAttributedString *pathDetail = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@\n\n",self.model.path]
                                                                                        attributes:@{
                                                                                                     NSFontAttributeName : detailFont,
                                                                                                     NSForegroundColorAttributeName: detailColor
                                                                                                     }];
    NSMutableAttributedString *frequencyDetail = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%d\n",(int)self.model.frequency]
                                                                                        attributes:@{
                                                                                                     NSFontAttributeName : detailFont,
                                                                                                     NSForegroundColorAttributeName: detailColor
                                                                                                     }];
    
    NSMutableAttributedString *attrText = [[NSMutableAttributedString alloc] init];
    [attrText appendAttributedString:callTrace];
    [attrText appendAttributedString:callTraceDetail];
    
    [attrText appendAttributedString:costTime];
    [attrText appendAttributedString:costTimeDetail];
    
    [attrText appendAttributedString:callDepth];
    [attrText appendAttributedString:callDepthDetail];
    
    [attrText appendAttributedString:path];
    [attrText appendAttributedString:pathDetail];
    
    [attrText appendAttributedString:frequency];
    [attrText appendAttributedString:frequencyDetail];

    self.textView.attributedText=attrText;
    
}
- (void)back {
    [self.navigationController popViewControllerAnimated:YES];
}
- (void)copyString:(id)sender {
    [NEMonitorToast showToast:@"复制到粘贴板"];
    [[UIPasteboard generalPasteboard] setString:self.textView.attributedText.string];
}
- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    self.textView.frame = self.view.bounds;
    
}
- (void)close
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (UITextView *)textView {
    if (!_textView) {
        _textView = [[UITextView alloc] init];
        _textView.editable = NO;
        
    }
    return _textView;
}
@end
