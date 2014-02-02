//
//  ProfileUserHelper.h
//  flat
//
//  Created by Zachary Palacios on 1/19/14.
//  Copyright (c) 2014 cs194. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ProfileUser+Json.h"
#import "ProfileUserNetworkRequest.h"


@interface ProfileUserHelper : NSObject

+(ProfileUser *)getProfileUser;

+(void)deleteCurrentProfileFromStore;

+ (void) getUsersFromGroupID:(NSInteger*)groupID
        withCompletionBlock:(RequestProfileUsersCompletionHandler)completionBlock;


@end
