//
//  SREmojiContainer.h
//  JODevelop
//
//  Created by JimmyOu on 2018/2/5.
//  Copyright © 2018年 JimmyOu. All rights reserved.
//

#import "NEPageControl.h"

@implementation NEPageControl

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
		self.backgroundColor = [UIColor clearColor];
		_numberOfPages = 0;
		_currentPage = 0;
        _offset = 10.f;
        self.onImage = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"guide_dot_actived" ofType:@"png"]];
        self.offImage = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"guide_dot" ofType:@"png"]];
    }
    return self;
}

-(id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
		_numberOfPages = 0;
		_currentPage = 0;
        _offset = 10.f;
        self.onImage = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"guide_dot_actived" ofType:@"png"]];
        self.offImage = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"guide_dot" ofType:@"png"]];
		self.backgroundColor = [UIColor clearColor];
    }
    return self;
}

- (void)setNumberOfPages:(NSInteger) number {
	_numberOfPages = number;
	UIImageView *item;
    
	self.bounds = CGRectMake(0, 0, _onImage.size.width*number + _offset*(number-1), _onImage.size.height);
	for (int i = 0; i < _numberOfPages; ++i) {
		item = [[UIImageView alloc] initWithFrame:CGRectMake((_offset+_onImage.size.width)*i, 0, _onImage.size.width, _onImage.size.height)];
		item.tag = i;
        
        UIImage *image = nil;
		if (i == _currentPage) {
            image = _onImage;
		}
        else {
            image = _offImage;
		}
        
        [item setContentMode:UIViewContentModeCenter];
        [item setImage:image];
		[self addSubview:item];
	}
}

- (void)setCurrentPage:(NSInteger)page {
	_currentPage = page;
	
	for (UIView *subView in self.subviews) {
        if ([subView isMemberOfClass:[UIImageView class]]) {
            UIImageView *imageView = (UIImageView *)subView;
            UIImage *image = nil;
            if (imageView.tag == _currentPage) {
                image = _onImage;
            }
            else {
                image = _offImage;
            }
            [imageView setImage:image];
        }
	}
}
@end
