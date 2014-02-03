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
    profileUser.userID = [dictionary objectForKey:@"fb_id"];
    profileUser.groupID = [dictionary objectForKey:@"group_id"];
    profileUser.colorID = [dictionary objectForKey:@"color_id"];
    profileUser.firstName = [dictionary objectForKey:@"first_name"];
    profileUser.lastName = [dictionary objectForKey:@"last_name"];
    profileUser.email = [dictionary objectForKey:@"email"];
//    profileUser.imageUrl = [dictionary objectForKey:@"image_url"];
    profileUser.isNearDorm = [dictionary objectForKey:@"is_near_dorm"];
//    profileUser.apiToken = [dictionary objectForKey:@"api_token"];
    
    [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreAndWait];
    return profileUser;
}



@end
