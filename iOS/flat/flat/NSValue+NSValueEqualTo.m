//
//  NSValue+NSValueEqualTo.m
//  Flat
//
//  Created by Clay Schubiner on 3/2/14.
//  Copyright (c) 2014 cs194. All rights reserved.
//

#import "NSValue+NSValueEqualTo.h"

@implementation NSValue (NSValueEqualTo)


- (BOOL)isEqualToNumber2:(NSNumber *)number {
    if (number == nil || (NSNull*)number == [NSNull null]) {
        NSLog(@"inputted number is null. Returning false");
        return false;
    }
    return [(NSNumber*)self isEqualToNumber:number];
}

- (BOOL)isSameDay:(NSDate*)date2 {
    if (!date2) return false;
    NSCalendar* calendar = [NSCalendar currentCalendar];
    
    unsigned unitFlags = NSYearCalendarUnit | NSMonthCalendarUnit |  NSDayCalendarUnit;
    NSDateComponents* comp1 = [calendar components:unitFlags fromDate:(NSDate*)self];
    NSDateComponents* comp2 = [calendar components:unitFlags fromDate:date2];
    
    return [comp1 day]   == [comp2 day] &&
    [comp1 month] == [comp2 month] &&
    [comp1 year]  == [comp2 year];
}

@end
