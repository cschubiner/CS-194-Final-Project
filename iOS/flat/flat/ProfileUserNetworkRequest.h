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

+ (void) getUsersFromGroupID:(NSInteger*)groupID
        withCompletionBlock:(RequestProfileUsersCompletionHandler)completionBlock;

@end
