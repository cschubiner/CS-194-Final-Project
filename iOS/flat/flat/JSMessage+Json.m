//
//  JSMessage+Json.m
//  flat
//
//  Created by Zachary Palacios on 2/9/14.
//  Copyright (c) 2014 cs194. All rights reserved.
//

#import "JSMessage+Json.h"

@implementation JSMessage (Json)

+ (JSMessage *)getMessageObjectFromDictionary:(NSDictionary *)dictionary
{
    JSMessage *message = [[JSMessage alloc] initWithText:[dictionary objectForKey:@"body"]
                                                  sender:[dictionary objectForKey:@"name"]
                                            senderUserId:[[dictionary objectForKey:@"user_id"] intValue]
                                                    date:[dictionary objectForKey:@"time_stamp"]];
    return message;
}

@end
