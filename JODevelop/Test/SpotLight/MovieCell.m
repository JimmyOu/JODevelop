//
//  MovieCell.m
//  JODevelop
//
//  Created by JimmyOu on 2017/8/8.
//  Copyright © 2017年 JimmyOu. All rights reserved.
//

#import "MovieCell.h"

@implementation MovieCell

- (void)awakeFromNib {
    [super awakeFromNib];
    self.lblRating.layer.cornerRadius = self.lblRating.frame.size.width/2;
    self.lblRating.layer.masksToBounds = true;
}



@end
