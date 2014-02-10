//
//  JSMessage+Json.h
//  flat
//
//  Created by Zachary Palacios on 2/9/14.
//  Copyright (c) 2014 cs194. All rights reserved.
//

#import "JSMessage.h"

@interface JSMessage (Json)

+ (JSMessage *)getMessageObjectFromDictionary:(NSDictionary *)dictionary;

@end
