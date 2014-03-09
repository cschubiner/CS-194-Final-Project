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

+(void)deleteCurrentGroupFromStore {
    NSManagedObjectContext *localContext = [NSManagedObjectContext MR_defaultContext];
    Group *group = [Group MR_findFirst];
    if (group) {
        // Delete the group found
        [group MR_deleteInContext:localContext];
        [localContext MR_saveToPersistentStoreWithCompletion:^(BOOL success, NSError *error) {}];
    }
    [Group MR_truncateAll];
}

@end
