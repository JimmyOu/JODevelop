//
//  EmojiViewController.m
//  JODevelop
//
//  Created by JimmyOu on 2018/2/7.
//  Copyright © 2018年 JimmyOu. All rights reserved.
//

#import "EmojiViewController.h"
#import "Masonry.h"
//#import "SREmojiContainer.h"
#import "SRInputView.h"
#import "Emoji2ViewController.h"
#import "UIView+Extension.h"
#import "UIColor+Extension.h"

//static const CGFloat kHeightOfEmojiView = 200;

@interface EmojiViewController ()

@property (strong, nonatomic) SRInputView *inputV;

@property (strong, nonatomic) UITextField *textField;

@end

@implementation EmojiViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self.view addSubview:self.inputV];
    [self.inputV mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.view);
        make.right.mas_equalTo(self.view);
        make.bottom.mas_equalTo(self.view);
        make.height.mas_equalTo(50);
    }];
    
    [self.view addSubview:self.textField];
    self.textField.backgroundColor = [UIColor redColor];
    [self.textField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(150);
        make.height.mas_equalTo(50);
        make.center.mas_equalTo(self.view);
    }];
    
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeContactAdd];
    [self.view addSubview:btn];
    [btn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.mas_equalTo(self.textField.mas_top);
        make.centerX.mas_equalTo(self.view);
    }];
    
    [btn clicked:^{
        Emoji2ViewController *vc2 = [[Emoji2ViewController alloc] init];
        [self.navigationController pushViewController:vc2 animated:YES];
    }];
    

    
}
- (UITextField *)textField {
    if (!_textField) {
        _textField = [[UITextField alloc] init];
    }
    return _textField;
}

- (SRInputView *)inputV {
    if(!_inputV) {
        _inputV = [[SRInputView alloc] initWithTextInput:self.textField];
    }
    return _inputV;
}

@end
