//
//  Message+Json.m
//  flat
//
//  Created by Zachary Palacios on 2/9/14.
//  Copyright (c) 2014 cs194. All rights reserved.
//

#import "Message+Json.h"

@implementation Message (Json)

+ (Message *)getMessageObjectFromDictionary:(NSDictionary *)dictionary
{
    Message *message = [[Message alloc] initWithText:[dictionary objectForKey:@"body"]
                                                  sender:[dictionary objectForKey:@"name"]
                                            senderUserId:[dictionary objectForKey:@"user_id"]
                                                    date:[dictionary objectForKey:@"time_stamp"]];
    return message;
}

@end
