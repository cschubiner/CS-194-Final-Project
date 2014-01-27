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
    profileUser.userID = [dictionary objectForKey:@"userID"];
    profileUser.groupID = [dictionary objectForKey:@"groupID"];
    profileUser.colorID = [dictionary objectForKey:@"colorID"];
    profileUser.firstName = [dictionary objectForKey:@"firstName"];
    profileUser.lastName = [dictionary objectForKey:@"lastName"];
    profileUser.email = [dictionary objectForKey:@"email"];
    profileUser.imageUrl = [dictionary objectForKey:@"imageURL"];
  //  profileUser.apiToken = [dictionary objectForKey:@"api_token"];
    
    [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreAndWait];
    return profileUser;
}

@end
