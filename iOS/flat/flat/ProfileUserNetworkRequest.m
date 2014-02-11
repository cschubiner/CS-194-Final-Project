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

+ (void) getUsersFromGroupID:(NSNumber*)groupID
         withCompletionBlock:(RequestProfileUsersCompletionHandler)completionBlock
{
    NSString * url = [NSString stringWithFormat:@"group/%@/users", groupID];
    [[FlatAPIClientManager sharedClient]GET:url
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


+ (void) setUserLocationWithUserID:(NSNumber*)userID
                       andIsInDorm:(NSNumber*) isInDormStatus {
    NSLog(@"telling colby our indorm status is: %@", isInDormStatus);
    NSString * url = [NSString stringWithFormat:@"user/%@/indorm/%@", userID, isInDormStatus];
    [[FlatAPIClientManager sharedClient]GET:url
                                 parameters:Nil
                                    success:^(NSURLSessionDataTask * task, id JSON) {
                                        NSError *error = [ErrorHelper apiErrorFromDictionary:JSON];
                                        if (!error) {
                                            NSLog(@"successfully set user location");
                                        } else {
                                            NSLog(@"error when setting user location");
                                        }
                                    }
                                    failure: ^(NSURLSessionDataTask *__unused task, NSError *error) {
                                        NSLog(@"error");
                                    }];
}


+ (void) setGroupIDForUser:(NSNumber*)userID
                   groupID:(NSNumber*)groupID {
    NSString * url = [NSString stringWithFormat:@"user/%@/changegroupid/%@", userID, groupID];
    [[FlatAPIClientManager sharedClient]GET:url
                                 parameters:Nil
                                    success:^(NSURLSessionDataTask * task, id JSON) {
                                        NSError *error = [ErrorHelper apiErrorFromDictionary:JSON];
                                        if (!error) {
                                            NSLog(@"successfully set user group id");
                                            [[[FlatAPIClientManager sharedClient]profileUser] setGroupID:groupID];
                                        } else {
                                            NSLog(@"error when setting user group id");
                                        }
                                    }
                                    failure: ^(NSURLSessionDataTask *__unused task, NSError *error) {
                                        NSLog(@"error in setting group id");
                                    }];
}

@end
