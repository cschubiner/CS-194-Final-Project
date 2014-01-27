//
//  ProfileUserHelper.m
//  flat
//
//  Created by Zachary Palacios on 1/19/14.
//  Copyright (c) 2014 cs194. All rights reserved.
//

#import "ProfileUserHelper.h"
#import "ProfileUserLocalRequest.h"

@implementation ProfileUserHelper

+(ProfileUser *)getProfileUser
{
    ProfileUser *currUser = [ProfileUserLocalRequest getProfileUser];
    return currUser;
}

+(void)deleteCurrentProfileFromStore
{
    [ProfileUserLocalRequest deleteCurrentProfileFromStore];
}

+ (void) getUserFromGroupID:(NSInteger*)groupID
        withCompletionBlock:(RequestProfileUsersCompletionHandler)completionBlock {
    [ProfileUserNetworkRequest getUserFromGroupID:groupID withCompletionBlock:completionBlock];
}

@end
