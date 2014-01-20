//
//  ProfileUserLocalRequest.h
//  flat
//
//  Created by Zachary Palacios on 1/19/14.
//  Copyright (c) 2014 cs194. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ProfileUser+Json.h"

@interface ProfileUserLocalRequest : NSObject

+ (ProfileUser *)getProfileUser;

+ (void)deleteCurrentProfileFromStore;

@end
