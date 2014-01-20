//
//  FlatAPIClientManager.h
//  flat
//
//  Created by Zachary Palacios on 1/19/14.
//  Copyright (c) 2014 cs194. All rights reserved.
//

#import "AFHTTPSessionManager.h"
#import "ProfileUser.h"

@interface FlatAPIClientManager : AFHTTPSessionManager

+ (instancetype)sharedClient;

@property (nonatomic, strong) ProfileUser *profileUser;

@end