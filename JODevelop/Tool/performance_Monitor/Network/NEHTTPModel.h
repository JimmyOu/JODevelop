//
//  NEHTTPModel.h
//  SnailReader
//
//  Created by JimmyOu on 2018/8/17.
//  Copyright © 2018年 com.netease. All rights reserved.
//

#import <Foundation/Foundation.h>
NS_ASSUME_NONNULL_BEGIN
@interface NEHTTPModel : NSObject

@property (nonatomic,strong) NSURLRequest *ne_request;
@property (nonatomic,strong) NSHTTPURLResponse *ne_response;
@property (nonatomic,copy) NSString *myID;
@property (nonatomic,strong) NSString *startDateString;
@property (nonatomic,strong) NSString *endDateString;
@property (nonatomic, copy) NSString *formateDuation;

//request
@property (nonatomic,strong) NSString *requestURLString;
@property (nonatomic,strong) NSString *requestCachePolicy; 
@property (nonatomic,assign) double requestTimeoutInterval;
@property (nonatomic,nullable, strong) NSString *requestHTTPMethod;
@property (nonatomic,nullable,strong) NSString *requestAllHTTPHeaderFields;
@property (nonatomic,nullable,strong) NSString *requestHTTPBody;

//response
@property (nonatomic,nullable,strong) NSString *responseMIMEType;
@property (nonatomic,strong) NSString * responseExpectedContentLength;
@property (nonatomic,nullable,strong) NSString *responseTextEncodingName;
@property (nullable, nonatomic, strong) NSString *responseSuggestedFilename;
@property (nonatomic,assign) int responseStatusCode;
@property (nonatomic, copy) NSString *statusCodeString;
@property (nonatomic,nullable,strong) NSString *responseAllHeaderFields;
@property (strong, nonatomic) NSData *data;
@property (strong, nonatomic) NSError *error;

//JSONData
@property (nonatomic,strong) NSString *receiveJSONData;

//流量
@property (assign, nonatomic) NSUInteger requestFlow;
@property (assign, nonatomic) NSUInteger responseFlow;
@property (assign, nonatomic) NSUInteger totalFlow;


- (void)synchronize;

@end
NS_ASSUME_NONNULL_END
