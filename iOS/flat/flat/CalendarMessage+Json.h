//
//  CalendarMessage+Json.h
//  flat
//
//  Created by Zachary Palacios on 2/25/14.
//  Copyright (c) 2014 cs194. All rights reserved.
//

#import "CalendarMessage.h"

@interface CalendarMessage (Json)

+ (CalendarMessage *)getMessageObjectFromDictionary:(NSDictionary *)dictionary;

@end
