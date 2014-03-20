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
    if (!(str.length > 0)) return nil;
//    [NSDateFormatter setDefaultFormatterBehavior:NSDateFormatterBehavior10_4];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setTimeZone:[NSTimeZone systemTimeZone]];
    //[NSDateFormatter setDefaultFormatterBehavior:NSDateFormatterBehaviorDefault];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ssZZZZZZ"];
    NSDate* ret= [dateFormatter dateFromString:str];
    //    NSLog(@"ret: %@", ret);

    return ret;
}

+(CGRect)getSizeOfFont:(UIFont*)font withText:(NSString*)text withLabel:(UILabel*)label{
        return [text boundingRectWithSize:label.frame.size
                                      options:NSStringDrawingUsesLineFragmentOrigin
                                   attributes:@{NSFontAttributeName:font}
                                      context:nil];
}

+(NSString*)formatDate:(NSDate*) date {
    return [Utils formatDate:date withFormat:@"h:mm a"];
}

//+(NSDate*)correctTimeZone:(NSDate*) date {
//    NSCalendar *gregorian=[[NSCalendar alloc] initWithCalendarIdentifier: NSGregorianCalendar];
//    [gregorian setTimeZone:[NSTimeZone timeZoneWithName:@"GMT"]];
//    NSDateComponents* components = [gregorian components:NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit|NSHourCalendarUnit|NSMinuteCalendarUnit
//                                                 fromDate:date];
//    return [gregorian dateFromComponents:components];
//}


+(NSString *)formatDate:(NSDate *)date withFormat:(NSString *)formatStr {
    if (date == nil) return nil;
    NSDateFormatter* secondDateFormatter = [[NSDateFormatter alloc] init];
    [secondDateFormatter setDateFormat:formatStr];
//    [secondDateFormatter setTimeZone:defa];
    NSString* secondDateString = [NSString stringWithFormat:@"%@",[secondDateFormatter stringFromDate:date]];
    return secondDateString;
}

+(NSString*)formatDateDayOfWeek:(NSDate*) date  {
    NSCalendar *cal = [NSCalendar currentCalendar];
    static NSTimeInterval secondsPerDay = 24 * 60 * 60;
    NSDateComponents *components = [cal components:(NSEraCalendarUnit|NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit) fromDate:[NSDate date]];
    NSDate *today = [cal dateFromComponents:components];
    NSDate *tomorrow = [cal dateFromComponents:[cal components:(NSEraCalendarUnit|NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit) fromDate:[[NSDate date]dateByAddingTimeInterval:secondsPerDay]]];
    components = [cal components:(NSEraCalendarUnit|NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit) fromDate:date];
    NSDate *otherDate = [cal dateFromComponents:components];
    
    if([today isEqualToDate:otherDate])
        return @"Today";
    
    if([tomorrow isEqualToDate:otherDate])
        return @"Tomorrow";
    
    return [Utils formatDate:date withFormat:@"EEEE"];
}


@end
