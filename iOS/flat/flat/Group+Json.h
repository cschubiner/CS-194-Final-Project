//
//  Group+Json.h
//  flat
//
//  Created by Clay Schubiner on 2/2/14.
//  Copyright (c) 2014 cs194. All rights reserved.
//

#import "Group.h"

@interface Group (Json)

+ (Group *)getGroupObjectFromDictionary:(NSDictionary *)dictionary;
@end
