//
//  CalendarMessage+Json.m
//  flat
//
//  Created by Zachary Palacios on 2/25/14.
//  Copyright (c) 2014 cs194. All rights reserved.
//

#import "CalendarMessage+Json.h"

@implementation CalendarMessage (Json)

+ (CalendarMessage *)getMessageObjectFromDictionary:(NSDictionary *)dictionary
{
    CalendarMessage *calendarMessage = [[CalendarMessage alloc] initWithText:[dictionary objectForKey:@"body"]
                                                                      sender:[dictionary objectForKey:@"name"]
                                                                senderUserId:[dictionary objectForKey:@"user_id"] 
                                                                        date:[dictionary objectForKey:@"time_stamp"]
                                                                andStartDate:[dictionary objectForKey:@"start_time"]
                                                                  andEndDate:[dictionary objectForKey:@"end_time"]];
    return calendarMessage;
}

@end
