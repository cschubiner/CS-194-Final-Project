//
//  Group+Json.m
//  flat
//
//  Created by Clay Schubiner on 2/2/14.
//  Copyright (c) 2014 cs194. All rights reserved.
//

#import "Group+Json.h"

@implementation Group (Json)

+ (Group *)getGroupObjectFromDictionary:(NSDictionary *)dictionary {
    Group *group = [[Group alloc]init];
    group.groupID = [dictionary objectForKey:@"groupID"];
    group.latLocation = [dictionary objectForKey:@"latLocation"];
    group.longLocation = [dictionary objectForKey:@"longLocation"];
    
    return group;
}

@end
