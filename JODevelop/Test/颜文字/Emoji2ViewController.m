//
//  Emoji2ViewController.m
//  JODevelop
//
//  Created by JimmyOu on 2018/2/7.
//  Copyright © 2018年 JimmyOu. All rights reserved.
//

#import "Emoji2ViewController.h"
#import "Masonry.h"

@interface Emoji2ViewController ()

@property (strong, nonatomic) UITextField *textField;

@end

@implementation Emoji2ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self.view addSubview:self.textField];
    self.textField.backgroundColor = [UIColor redColor];
    [self.textField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(150);
        make.height.mas_equalTo(50);
        make.center.mas_equalTo(self.view);
    }];
}

- (UITextField *)textField {
    if (!_textField) {
        _textField = [[UITextField alloc] init];
    }
    return _textField;
}

@end
