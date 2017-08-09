//
//  MoviesService.h
//  JODevelop
//
//  Created by JimmyOu on 2017/8/8.
//  Copyright © 2017年 JimmyOu. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MoviesService : NSObject

+ (NSArray *)loadMoviesInfo;
+ (void)setupSearchableContent;
+ (void)restoreUserActivityState:(NSUserActivity *)activity;

@end
