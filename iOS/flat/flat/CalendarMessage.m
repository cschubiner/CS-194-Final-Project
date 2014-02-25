//
//  CalendarMessage.m
//  flat
//
//  Created by Zachary Palacios on 2/25/14.
//  Copyright (c) 2014 cs194. All rights reserved.
//

#import "CalendarMessage.h"

@implementation CalendarMessage

- (instancetype)initWithText:(NSString *)text
                      sender:(NSString *)sender
                senderUserId:(int)senderID
                        date:(NSDate *)date
                andStartDate:(NSDate *)startDate
                  andEndDate:(NSDate *)endDate
{
    self = [super init];
    if (self) {
        self.text = text ? text : @" ";
        self.sender = sender;
        self.senderID = senderID;
        self.date = date;
        self.startDate = startDate;
        self.endDate = endDate;
    }
    return self;
}

- (void)dealloc
{
    self.text = nil;
    self.sender = nil;
    self.date = nil;
    self.startDate = nil;
    self.endDate = nil;
}

- (id)copyWithZone:(NSZone *)zone
{
    return [[[self class] allocWithZone:zone] initWithText:[self.text copy]
                                                    sender:[self.sender copy]
                                              senderUserId:self.senderID
                                                      date:[self.date copy]
                                              andStartDate:[self.startDate copy]
                                                andEndDate:[self.endDate copy]];
}

@end
