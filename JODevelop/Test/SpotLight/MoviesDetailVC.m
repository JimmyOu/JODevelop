//
//  MoviesDetailVC.m
//  JODevelop
//
//  Created by JimmyOu on 2017/8/8.
//  Copyright © 2017年 JimmyOu. All rights reserved.
//

#import "MoviesDetailVC.h"

@interface MoviesDetailVC ()

@property (nonatomic, strong) UILabel *lblTitle;
@property (nonatomic, strong) UILabel *lblCategory;
@property (nonatomic, strong) UILabel *lblDescription;
@property (nonatomic, strong) UILabel *lblDirector;
@property (nonatomic, strong) UILabel *lblStars;
@property (nonatomic, strong) UILabel *lblRating;
@property (nonatomic, strong) UIImageView *imgMovieImage;

@end

@implementation MoviesDetailVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor whiteColor];
    [self setupUI];
}
- (void)setupUI {
    [self.view addSubview:self.imgMovieImage];
    [self.imgMovieImage mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(120, 160));
        make.right.mas_equalTo(self.view);
        make.top.mas_equalTo(self.view).offset(68);
    }];
    [self.view addSubview:self.lblTitle];
    [self.lblTitle mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.view);
        make.top.mas_equalTo(self.view).offset(37 + 60);
        make.right.mas_equalTo(self.imgMovieImage.mas_left).offset(-8);
    }];
    
    [self.view addSubview:self.lblCategory];
    [self.lblCategory mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.view);
        make.right.mas_equalTo(self.imgMovieImage.mas_left).offset(-8);
        make.top.mas_equalTo(self.lblTitle.mas_bottom).offset(70);
    }];
    
    [self.view addSubview:self.lblRating];
    [self.lblRating mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(40, 40));
        make.top.mas_equalTo(self.imgMovieImage.mas_bottom).offset(8);
        make.centerX.mas_equalTo(self.imgMovieImage);
    }];
    
    [self.view addSubview:self.lblDescription];
    [self.lblDescription mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.lblCategory.mas_bottom).offset(8);
        make.left.mas_equalTo(self.view);
        make.right.mas_equalTo(self.imgMovieImage.mas_left).offset(-8);
    }];
    [self.view addSubview:self.lblDirector];
    [self.lblDirector mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.view);
        make.right.mas_equalTo(self.view);
        make.top.mas_equalTo(self.lblDescription.mas_bottom).offset(10);
    }];
    
    [self.view addSubview:self.lblStars];
    [self.lblStars mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.view);
        make.right.mas_equalTo(self.view);
        make.top.mas_equalTo(self.lblDirector.mas_bottom).offset(2);
    }];
}
- (UIImageView *)imgMovieImage {
    if (!_imgMovieImage) {
        _imgMovieImage = [UIImageView new];
    }
    return _imgMovieImage;
}
- (UILabel *)lblTitle {
    if (!_lblTitle) {
        _lblTitle = [UILabel new];
        _lblTitle.font = [UIFont fontWithName:@"Avenir-Black" size:17];
        _lblTitle.numberOfLines = 0;
        _lblTitle.textAlignment = NSTextAlignmentLeft;
        _lblTitle.textColor = [UIColor blackColor];
        
    }
    return _lblTitle;
}
- (UILabel *)lblCategory {
    if (!_lblCategory) {
        _lblCategory = [UILabel new];
        _lblCategory.font = [UIFont fontWithName:@"Avenir-Light" size:15];
        _lblCategory.numberOfLines = 0;
        _lblCategory.textAlignment = NSTextAlignmentLeft;
        _lblCategory.textColor = [UIColor orangeColor];
        
    }
    return _lblCategory;
}

- (UILabel *)lblRating {
    if (!_lblRating) {
        _lblRating = [UILabel new];
        _lblRating.backgroundColor = [UIColor yellowColor];
        _lblRating.font = [UIFont fontWithName:@"Avenir-Medium Oblique" size:17];
        _lblRating.numberOfLines = 0;
        _lblRating.textAlignment = NSTextAlignmentCenter;
        _lblRating.textColor = [UIColor blackColor];
        
    }
    return _lblRating;
}
- (UILabel *)lblDescription {
    if (!_lblDescription) {
        _lblDescription = [UILabel new];
        
        _lblDescription.font = [UIFont fontWithName:@"Avenir-Oblique" size:14];
        _lblDescription.numberOfLines = 0;
        _lblDescription.textAlignment = NSTextAlignmentLeft;
        _lblDescription.textColor = [UIColor blackColor];
        
    }
    return _lblDescription;
}

- (UILabel *)lblDirector {
    if (!_lblDirector) {
        _lblDirector = [UILabel new];
        
        _lblDirector.font = [UIFont fontWithName:@"Avenir-Light" size:15];
        _lblDirector.numberOfLines = 1;
        _lblDirector.textAlignment = NSTextAlignmentLeft;
        _lblDirector.textColor = [UIColor lightGrayColor];
        
    }
    return _lblDirector;
}

- (UILabel *)lblStars {
    if (!_lblStars) {
        _lblStars = [UILabel new];
        
        _lblStars.font = [UIFont fontWithName:@"Avenir-Light" size:15];
        _lblStars.numberOfLines = 1;
        _lblStars.textAlignment = NSTextAlignmentLeft;
        _lblStars.textColor = [UIColor lightGrayColor];
        
    }
    return _lblStars;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.lblTitle.text = self.movieInfo[@"Title"];
    self.lblCategory.text = self.movieInfo[@"Category"];
    self.lblDescription.text = self.movieInfo[@"Description"];
    self.lblDirector.text = self.movieInfo[@"Director"];
    self.lblStars.text = self.movieInfo[@"Stars"];
    self.lblRating.text = self.movieInfo[@"Rating"];
    self.imgMovieImage.image = [UIImage imageNamed:self.movieInfo[@"Image"]];
}

@end
