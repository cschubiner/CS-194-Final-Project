//
//  Message+Json.h
//  flat
//
//  Created by Zachary Palacios on 2/9/14.
//  Copyright (c) 2014 cs194. All rights reserved.
//

#import "Message.h"

@interface Message (Json)

+ (Message *)getMessageObjectFromDictionary:(NSDictionary *)dictionary;

@end
