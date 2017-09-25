//
//  NSString+Extention.m
//  JOFoundation
//
//  Created by JimmyOu on 16/11/9.
//  Copyright © 2016年 JimmyOu. All rights reserved.
//

#import "NSString+Extention.h"
#import <CommonCrypto/CommonDigest.h>

@implementation NSString (Extention)
+ (BOOL)isEmpty:(NSString *)str {
    if (!str) {
        return YES;
    }
    return [str isEmpty];
}
- (BOOL)isEmpty {
    if (self) {
        if ([self isKindOfClass:[NSNull class]]) {
            return YES;
        }
        if ([self isEqual:[NSNull null]]) {
            return YES;
        }
        NSString *trimString = [self stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        return (trimString.length == 0);
    }
    return YES;
}
- (NSURL *)toUrl
{
    NSURL *result = [NSURL URLWithString:self];
    if (!result) {
        result = [NSURL URLWithString:[self stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    }
    
    if (!result) {
        result = [NSURL URLWithString:@""];
    }
    
    return result;
}
+ (BOOL)isUrl:(NSString *)str
{
    if (nil == str) {
        return NO;
    }
    
    return [str isUrl];
}

- (BOOL)isUrl
{
    // @"(https?|ftp|file)://[-A-Z0-9+&@#/%?=~_|!:,.;]*[-A-Z0-9+&@#/%=~_|]"
    NSRegularExpression *regular = [[NSRegularExpression alloc]
                                    initWithPattern:@"((http|ftp|https|file)://)(([a-zA-Z0-9\\._-]+\\.[a-zA-Z]{2,6})|([0-9]{1,3}\\.[0-9]{1,3}\\.[0-9]{1,3}\\.[0-9]{1,3}))(:[0-9]{1,4})*(/[a-zA-Z0-9\\&%_\\./-~-]*)?"
                                    options:NSRegularExpressionCaseInsensitive
                                    error:nil];
    
    NSUInteger numberOfMatches = [regular numberOfMatchesInString:self
                                                          options:NSMatchingAnchored
                                                            range:NSMakeRange(0, self.length)];
    
    return (numberOfMatches > 0);
}
- (NSString *)md5
{
    const char *cStr = [self UTF8String];
    unsigned char result[16];
    CC_MD5( cStr, (CC_LONG)strlen(cStr), result);
    
    return [NSString stringWithFormat:@"%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X",
            result[0], result[1], result[2], result[3],
            result[4], result[5], result[6], result[7],
            result[8], result[9], result[10], result[11],
            result[12], result[13], result[14], result[15]];
}

- (BOOL)isIdCard
{
    //判断位数
    if ([self length]!= 18 && [self length] != 15) {
        return NO;
    }
    
    //change x to X
    NSString *tmpID  = self.uppercaseString;
    NSString *cardID = tmpID;
    
    long lSumQT =0;
    //加权因子
    int R[] ={7, 9, 10, 5, 8, 4, 2, 1, 6, 3, 7, 9, 10, 5, 8, 4, 2 };
    //校验码
    unsigned char sChecker[11]={'1','0','X', '9', '8', '7', '6', '5', '4', '3', '2'};
    
    //将15位身份证号转换成18位
    NSMutableString *mString = [NSMutableString stringWithString:tmpID];
    if ([tmpID length] == 15) {
        [mString insertString:@"19" atIndex:6];
        
        long p = 0;
        const char *pid = [mString UTF8String];
        for (int i=0; i<=16; i++)
        {
            p += (pid[i]-48) * R[i];
        }
        
        int o = p%11;
        NSString *string_content = [NSString stringWithFormat:@"%c",sChecker[o]];
        [mString insertString:string_content atIndex:[mString length]];
        cardID = mString;
    }
    
    //判断地区码
    NSString * sProvince = [cardID substringToIndex:2];
    if (![self idAreaCode:sProvince]) {
        return NO;
    }
    
    //判断年月日是否有效
    
    //年份
    int strYear = [[cardID substring:6 to:10] intValue];
    //月份
    int strMonth = [[cardID substring:10 to:12] intValue];
    //日
    int strDay = [[cardID substring:12 to:14] intValue];
    
    NSTimeZone *localZone = [NSTimeZone localTimeZone];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init]  ;
    [dateFormatter setDateStyle:NSDateFormatterMediumStyle];
    [dateFormatter setTimeStyle:NSDateFormatterNoStyle];
    [dateFormatter setTimeZone:localZone];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSDate *date=[dateFormatter dateFromString:[NSString stringWithFormat:@"%d-%d-%d 12:01:01",strYear,strMonth,strDay]];
    if (date == nil) {
        return NO;
    }
    
    const char *charID  = [cardID UTF8String];
    
    //检验长度
    if( 18 != strlen(charID)) return -1;
    //校验数字
    for (int i=0; i<18; i++)
    {
        if ( !isdigit(charID[i]) && !(('X' == charID[i] || 'x' == charID[i]) && 17 == i) )
        {
            return NO;
        }
    }
    
    //验证最末的校验码
    for (int i=0; i<=16; i++)
    {
        lSumQT += (charID[i]-48) * R[i];
    }
    
    if (sChecker[lSumQT%11] != charID[17] )
    {
        return NO;
    }
    
    return YES;
}

- (BOOL)idAreaCode:(NSString *)code
{
    NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
    [dic setObject:@"北京" forKey:@"11"];
    [dic setObject:@"天津" forKey:@"12"];
    [dic setObject:@"河北" forKey:@"13"];
    [dic setObject:@"山西" forKey:@"14"];
    [dic setObject:@"内蒙古" forKey:@"15"];
    [dic setObject:@"辽宁" forKey:@"21"];
    [dic setObject:@"吉林" forKey:@"22"];
    [dic setObject:@"黑龙江" forKey:@"23"];
    [dic setObject:@"上海" forKey:@"31"];
    [dic setObject:@"江苏" forKey:@"32"];
    [dic setObject:@"浙江" forKey:@"33"];
    [dic setObject:@"安徽" forKey:@"34"];
    [dic setObject:@"福建" forKey:@"35"];
    [dic setObject:@"江西" forKey:@"36"];
    [dic setObject:@"山东" forKey:@"37"];
    [dic setObject:@"河南" forKey:@"41"];
    [dic setObject:@"湖北" forKey:@"42"];
    [dic setObject:@"湖南" forKey:@"43"];
    [dic setObject:@"广东" forKey:@"44"];
    [dic setObject:@"广西" forKey:@"45"];
    [dic setObject:@"海南" forKey:@"46"];
    [dic setObject:@"重庆" forKey:@"50"];
    [dic setObject:@"四川" forKey:@"51"];
    [dic setObject:@"贵州" forKey:@"52"];
    [dic setObject:@"云南" forKey:@"53"];
    [dic setObject:@"西藏" forKey:@"54"];
    [dic setObject:@"陕西" forKey:@"61"];
    [dic setObject:@"甘肃" forKey:@"62"];
    [dic setObject:@"青海" forKey:@"63"];
    [dic setObject:@"宁夏" forKey:@"64"];
    [dic setObject:@"新疆" forKey:@"65"];
    [dic setObject:@"台湾" forKey:@"71"];
    [dic setObject:@"香港" forKey:@"81"];
    [dic setObject:@"澳门" forKey:@"82"];
    [dic setObject:@"国外" forKey:@"91"];
    
    return ([dic objectForKey:code] != nil);
}

- (NSString *)substring:(NSUInteger)fromIndex to:(NSUInteger)toIndex
{
    if (toIndex <= fromIndex) {
        return @"";
    }
    
    NSRange range = NSMakeRange(fromIndex, toIndex - fromIndex);
    return [self substringWithRange:range];
}


@end
