//
//  GroupLocalRequest.m
//  flat
//
//  Created by Clay Schubiner on 2/10/14.
//  Copyright (c) 2014 cs194. All rights reserved.
//

#import "GroupLocalRequest.h"

@implementation GroupLocalRequest

+ (Group *)getGroup
{
    NSManagedObjectContext *localContext = [NSManagedObjectContext MR_defaultContext];
    NSEntityDescription *entityDescription = [NSEntityDescription entityForName:@"Group"
                                                         inManagedObjectContext:localContext];
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:entityDescription];
    [request setReturnsObjectsAsFaults:NO];
    NSError *error = nil;
    NSArray *array = [localContext executeFetchRequest:request error:&error];
    if ([array count] > 0)
    {
        return [array firstObject];
    } else {
        return nil;
    }
}

+ (void)deleteCurrentGroupFromStore
{
    NSManagedObjectContext *localContext = [NSManagedObjectContext MR_defaultContext];
    Group *group = [Group MR_findFirst];
    if (group) {
        // Delete the group found
        [group MR_deleteInContext:localContext];
        [localContext MR_saveToPersistentStoreWithCompletion:^(BOOL success, NSError *error) {}];
    }
}
@end
