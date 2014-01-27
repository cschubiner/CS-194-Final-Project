//
//  ProfileUserNetworkRequest.m
//  flat
//
//  Created by Clay Schubiner on 1/26/14.
//  Copyright (c) 2014 cs194. All rights reserved.
//

#import "ProfileUserNetworkRequest.h"
#import "ProfileUser+Json.h"

@implementation ProfileUserNetworkRequest

+ (void) getUserFromGroupID:(NSInteger*)groupID
             withCompletionBlock:(RequestProfileUsersCompletionHandler)completionBlock
{
    [[FlatAPIClientManager sharedClient]GET:@"users/all"
                                 parameters:Nil
                                    success:^(NSURLSessionDataTask * task, id JSON) {
                                        NSError *error = [ErrorHelper apiErrorFromDictionary:JSON];
                                        if (!error) {
                                            NSMutableArray *usersArray = [JSON objectForKey:@"users"];
                                            NSMutableArray *usersArrayReturn = [[NSMutableArray alloc] init];
                                            for (NSMutableDictionary* userJSON in usersArray) {
                                                ProfileUser *profileUser = [ProfileUser getProfileUserObjectFromDictionary:userJSON
                                                                                      AndManagedObjectContext:[NSManagedObjectContext MR_defaultContext]];
                                                [usersArrayReturn addObject:profileUser];
                                            }
                                                completionBlock(error, usersArrayReturn);
                                        } else {
                                            completionBlock(error, nil);
                                        }
                                    }
                                    failure: ^(NSURLSessionDataTask *__unused task, NSError *error) {
                                        NSLog(@"error");
                                        completionBlock(error, nil);
                                    }];
    
}

@end
