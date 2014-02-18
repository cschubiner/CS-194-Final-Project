//
//  DataModel.m
//  flat
//
//  Created by Zachary Palacios on 2/18/14.
//  Copyright (c) 2014 cs194. All rights reserved.
//

#import "DataModel.h"

static NSString * const UserId = @"UserId";
static NSString * const DeviceTokenKey = @"DeviceToken";

@implementation DataModel

- (NSString *)userId
{
    NSString *userId = [[NSUserDefaults standardUserDefaults] stringForKey:UserId];
    if (userId == nil || userId.length == 0) {
        userId = [[[NSUUID UUID] UUIDString] stringByReplacingOccurrencesOfString:@"-" withString:@""];
        [[NSUserDefaults standardUserDefaults] setObject:userId forKey:UserId];
    }
    return userId;
}

- (NSString*)deviceToken
{
	return [[NSUserDefaults standardUserDefaults] stringForKey:DeviceTokenKey];
}

- (void)setDeviceToken:(NSString *)token
{
	[[NSUserDefaults standardUserDefaults] setObject:token forKey:DeviceTokenKey];
}

@end
