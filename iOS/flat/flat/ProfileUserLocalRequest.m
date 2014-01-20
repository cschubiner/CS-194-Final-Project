//
//  ProfileUserLocalRequest.m
//  flat
//
//  Created by Zachary Palacios on 1/19/14.
//  Copyright (c) 2014 cs194. All rights reserved.
//

#import "ProfileUserLocalRequest.h"

@implementation ProfileUserLocalRequest

+ (ProfileUser *)getProfileUser
{
    NSManagedObjectContext *localContext = [NSManagedObjectContext MR_defaultContext];
    NSEntityDescription *entityDescription = [NSEntityDescription entityForName:@"ProfileUser"
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

+ (void)deleteCurrentProfileFromStore
{
    NSManagedObjectContext *localContext = [NSManagedObjectContext MR_defaultContext];
    ProfileUser *profileUser = [ProfileUser MR_findFirst];
    if (profileUser) {
        // Delete the person found
        [profileUser MR_deleteInContext:localContext];
        [localContext MR_saveToPersistentStoreWithCompletion:^(BOOL success, NSError *error) {}];
    }
}

@end
