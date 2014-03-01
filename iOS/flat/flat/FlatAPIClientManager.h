//
//  FlatAPIClientManager.h
//  flat
//
//  Created by Zachary Palacios on 1/19/14.
//  Copyright (c) 2014 cs194. All rights reserved.
//

#import "AFHTTPSessionManager.h"
#import "ProfileUser.h"
#import "Group.h"

@interface FlatAPIClientManager : AFHTTPSessionManager

+ (instancetype)sharedClient;

@property (nonatomic, strong) ProfileUser *profileUser;
@property (nonatomic, strong) Group *group;
@property NSMutableArray *users;
@property (nonatomic, strong) NSMutableArray *events;
@property NSString *deviceToken;

@end