//
//  ProfileUser+Json.m
//  flat
//
//  Created by Zachary Palacios on 1/19/14.
//  Copyright (c) 2014 cs194. All rights reserved.
//

#import "ProfileUser+Json.h"
#import "cs194AppDelegate.h"

@implementation ProfileUser (Json)

+ (ProfileUser *)getProfileUserObjectFromDictionary:(NSDictionary *)dictionary
                            AndManagedObjectContext:(NSManagedObjectContext *)context
{
    ProfileUser *profileUser = [ProfileUser MR_createInContext:context];
    NSNumberFormatter *f = [[NSNumberFormatter alloc] init];
    profileUser.userID = [f numberFromString:[dictionary objectForKey:@"id"]];
    profileUser.firstName = [dictionary objectForKey:@"firstname"];
    profileUser.lastName = [dictionary objectForKey:@"lastname"];
    profileUser.email = [dictionary objectForKey:@"email"];
    profileUser.imageUrl = [dictionary objectForKey:@"imageUrl"];
    profileUser.apiToken = [dictionary objectForKey:@"api_token"];
    
    [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreAndWait];
    return profileUser;
}

@end
