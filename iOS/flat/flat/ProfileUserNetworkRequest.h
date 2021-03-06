//
//  ProfileUserNetworkRequest.h
//  flat
//
//  Created by Clay Schubiner on 1/26/14.
//  Copyright (c) 2014 cs194. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ProfileUserNetworkRequest : NSObject

typedef void (^RequestProfileUsersCompletionHandler)(NSError *, NSMutableArray *);
typedef void (^RequestProfileUserCompletionHandler)(NSError *, ProfileUser *);
typedef void (^ErrorCompletionHandler)(NSError *);

+ (void) getUsersFromGroupID:(NSNumber*)groupID
        withCompletionBlock:(RequestProfileUsersCompletionHandler)completionBlock;

+ (void) setUserLocationWithUserID:(NSNumber*)userID
                       andIsInDorm:(NSNumber*) isInDormStatus;

+(void)setGroupIDForUser:(NSNumber *)userID groupID:(NSNumber *)groupID withPassword:(NSString*)password withCompletionBlock:(ErrorCompletionHandler)completionBlock;

+ (void) getFriendsGroupsFromUserID:(NSNumber*)userID
                withCompletionBlock:(RequestProfileUsersCompletionHandler)completionBlock;

+(void)getUserForUserID:(NSNumber*)userID withCompletionBlock:(RequestProfileUserCompletionHandler)completionBlock;

@end
