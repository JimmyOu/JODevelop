//
//  MoviesService.m
//  JODevelop
//
//  Created by JimmyOu on 2017/8/8.
//  Copyright © 2017年 JimmyOu. All rights reserved.
//

#import "MoviesService.h"
#import <CoreSpotlight/CoreSpotlight.h>
#import <MobileCoreServices/MobileCoreServices.h>
#import "MoviesDetailVC.h"
#import "AppDelegate.h"

@implementation MoviesService

+ (NSArray *)loadMoviesInfo {
   NSString *path = [[NSBundle mainBundle] pathForResource:@"MoviesData" ofType:@"plist"];
    if (path) {
        return [[NSMutableArray alloc] initWithContentsOfFile:path];
    }
    return nil;
}

+ (void)setupSearchableContent {
    NSMutableArray *searchableItems = [NSMutableArray array];
    NSArray *moviesInfo = [self loadMoviesInfo];
    for (int i = 0; i < moviesInfo.count ; i++) {
        NSDictionary *movieInfo = moviesInfo[i];
        //inital CSSearchableItemAttributeSet
        CSSearchableItemAttributeSet *searchableItemAttributeSet = [[CSSearchableItemAttributeSet alloc] initWithItemContentType:(__bridge NSString*)kUTTypeText];
        
        //set attribute
        searchableItemAttributeSet.title = movieInfo[@"Title"];
        searchableItemAttributeSet.thumbnailURL = [[NSBundle mainBundle] URLForResource:movieInfo[@"Image"] withExtension:nil];
        searchableItemAttributeSet.contentDescription = movieInfo[@"Description"];
        
        //key words
        NSMutableArray *keywords = [NSMutableArray array];
        NSString *category = movieInfo[@"Category"];
        NSArray *categories = [category componentsSeparatedByString:@","];
        [keywords addObjectsFromArray:categories];
        
        NSString *star = movieInfo[@"Stars"];
        NSArray *stars = [star componentsSeparatedByString:@","];
        [keywords addObjectsFromArray:stars];
        
        //set keywords
        searchableItemAttributeSet.keywords = keywords;
        
        
        CSSearchableItem *item = [[CSSearchableItem alloc] initWithUniqueIdentifier:[NSString stringWithFormat:@"%@.%d",[self bundleID],i] domainIdentifier:@"movies" attributeSet:searchableItemAttributeSet];
        
        [searchableItems addObject:item];
    }
    
    [CSSearchableIndex.defaultSearchableIndex indexSearchableItems:searchableItems
                                                 completionHandler:^(NSError * _Nullable error) {
                                                     if (error) {
                                                         NSLog(@"%@",error.localizedDescription);
                                                     }
    }];
    
}

+ (void)restoreUserActivityState:(NSUserActivity *)activity{
    
    if ([activity.activityType isEqualToString:CSSearchableItemActionType]) {
        if (activity.userInfo) {
            NSString *selectedMovie = activity.userInfo[CSSearchableItemActivityIdentifier];
            NSLog(@"%@",selectedMovie);
            NSInteger seletedIndex = [[[selectedMovie componentsSeparatedByString:@"."] lastObject] integerValue];
            
           NSArray *infos =  [self loadMoviesInfo];
            MoviesDetailVC *detail = [MoviesDetailVC new];
            detail.movieInfo = infos[seletedIndex];
            
            AppDelegate *appDelegate = (AppDelegate *) [UIApplication sharedApplication].delegate;
           UINavigationController *navi = (UINavigationController *) appDelegate.window.rootViewController;
            [navi pushViewController:detail animated:YES];
            
        }
        
    }

}

+ (NSString *)bundleID {
  return  [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleIdentifier"];
    

}

@end
