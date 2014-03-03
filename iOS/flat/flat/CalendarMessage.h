//
//  CalendarMessage.h
//  flat
//
//  Created by Zachary Palacios on 2/25/14.
//  Copyright (c) 2014 cs194. All rights reserved.
//

#import "JSMessage.h"

@interface CalendarMessage : JSMessage

@property (strong, nonatomic) NSDate *startDate;

@property (strong, nonatomic) NSDate *endDate;

- (instancetype)initWithText:(NSString *)text
                      sender:(NSString *)sender
                senderUserId:(NSNumber*)senderID
                        date:(NSDate *)date
                andStartDate:(NSDate *)startDate
                  andEndDate:(NSDate *)endDate;

@end
