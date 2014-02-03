//
//  Group+Json.m
//  flat
//
//  Created by Clay Schubiner on 2/2/14.
//  Copyright (c) 2014 cs194. All rights reserved.
//

#import "Group+Json.h"

@implementation Group (Json)

+ (Group *)getGroupObjectFromDictionary:(NSDictionary *)dictionary
                            AndManagedObjectContext:(NSManagedObjectContext *)context
{
    Group *group = [Group MR_createInContext:context];
    group.groupID = [dictionary objectForKey:@"groupID"];
    group.latLocation = [dictionary objectForKey:@"latLocation"];
    group.longLocation = [dictionary objectForKey:@"longLocation"];
    
    [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreAndWait];
    return group;
}

@end
