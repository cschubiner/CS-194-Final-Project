//
//  Utils.m
//  Flat
//
//  Created by Clay Schubiner on 3/2/14.
//  Copyright (c) 2014 cs194. All rights reserved.
//

#import "Utils.h"

@implementation Utils

+(NSNumber*)numberFromString:(NSString*)str {
    if ((NSNull*)str == [NSNull null] || str == nil) return nil;
    NSNumberFormatter * f = [[NSNumberFormatter alloc] init];
    [f setNumberStyle:NSNumberFormatterNoStyle];
   return [f numberFromString:str];
}

+(NSDate*)dateFromString:(NSString*)str {
    if ((NSNull*)str == nil || [[NSNull null] isEqual:str]) return nil;
    [NSDateFormatter setDefaultFormatterBehavior:NSDateFormatterBehavior10_4];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setTimeZone:[NSTimeZone localTimeZone]];
    //[NSDateFormatter setDefaultFormatterBehavior:NSDateFormatterBehaviorDefault];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss +0000"];
    NSDate* ret= [dateFormatter dateFromString:str];
    //    NSLog(@"ret: %@", ret);
    return ret;
}


+(NSString*)formatDate:(NSDate*) date {
    return [Utils formatDate:date withFormat:@"h:mm a"];
}


+(NSString *)formatDate:(NSDate *)date withFormat:(NSString *)formatStr {
    if (date == nil) return nil;
    NSDateFormatter* secondDateFormatter = [[NSDateFormatter alloc] init];
    [secondDateFormatter setDateFormat:formatStr];
    [secondDateFormatter setTimeZone:[NSTimeZone localTimeZone]];
    NSString* secondDateString = [NSString stringWithFormat:@"%@",[secondDateFormatter stringFromDate:date]];
    return secondDateString;
}



@end
