//
//  JOShimmering.h
//  模块化Demo
//
//  Created by JimmyOu on 17/3/30.
//  Copyright © 2017年 JimmyOu. All rights reserved.
//

#import <CoreGraphics/CoreGraphics.h>
#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, JOShimmerDirection) {
    JOShimmerDirectionRight,//left -> right
    JOShimmerDirectionLeft, //right -> left
    JOShimmerDirectionUp,   //below -> above
    JOShimmerDirectionDown, //above -> below
};

static const float JOShimmerDefaultBeginTime = CGFLOAT_MAX;

@protocol JOShimmering <NSObject>

//set Yes to start shimmering and No to stop ,default No
@property (nonatomic, assign, readwrite, getter = isShimmering) BOOL shimmering;

// time between shimmerings in seconds, default 0.4
@property (nonatomic, assign, readwrite) CFTimeInterval shimmeringPauseDuration;

// the opacity of content while shimmering ,default 0.5
@property (nonatomic, assign, readwrite) CGFloat shimmeringAnimationOpacity;

// the opacity of content before shimmering, default 1
@property (assign, nonatomic, readwrite) CGFloat shimmeringOpacity;

// the speed of shimmering, in points per second, default 230
@property (assign, nonatomic, readwrite) CGFloat shimmeringSpeed;

// highlighted length of shimmering, range of [0,1], default 1.0
@property (assign, nonatomic, readwrite) CGFloat shimmeringHighlightLength;

// direction of shimmering animation, default JOShimmerDirectionRight
@property (assign, nonatomic, readwrite) JOShimmerDirection shimmeringDirection;

//duration of  fade time when shimmering begins, default 0.1
@property (assign, nonatomic, readwrite) CFTimeInterval shimmeringBeginFadeDuration;

//duration of  fade time when shimmering ends, default 0.3
@property (assign, nonatomic, readwrite) CFTimeInterval shimmeringEndFadeDuration;


/**
 The absolute CoreAnimation media time when the shimmer will fade in
 only valid after setting shimmering to No
 */
@property (assign, nonatomic, readonly) CFTimeInterval shimmeringFadeTime;


/**
 The absolute CoreAnimation media time when the shimmer will begin.
 only valid after setting shimmering to Yes
 */
@property (assign, nonatomic) CFTimeInterval shimmeringBeginTime;
@end
