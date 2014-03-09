//
//  ProfileUserNetworkRequest.m
//  flat
//
//  Created by Clay Schubiner on 1/26/14.
//  Copyright (c) 2014 cs194. All rights reserved.
//

#import "ProfileUserNetworkRequest.h"
#import "ProfileUser+Json.h"
#import "GroupNetworkRequest.h"

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
                                                ProfileUser *profileUser = [ProfileUser getProfileUserObjectFromDictionary:userJSON AndManagedObjectContext:[NSManagedObjectContext MR_defaultContext]];
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

+(void)setGroupIDForUser:(NSNumber *)userID groupID:(NSNumber *)groupID withCompletionBlock:(ErrorCompletionHandler)completionBlock {
    NSString * url = [NSString stringWithFormat:@"user/%@/changegroupid/%@", userID, groupID];
    [[FlatAPIClientManager sharedClient]GET:url
                                 parameters:Nil
                                    success:^(NSURLSessionDataTask * task, id JSON) {
                                        NSError *error = [ErrorHelper apiErrorFromDictionary:JSON];
                                        if (!error) {
                                            NSLog(@"successfully set user group id");
                                            [[[FlatAPIClientManager sharedClient]profileUser] setGroupID:groupID];
                                            
                                            [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreAndWait];
                                            [GroupNetworkRequest getGroupFromGroupID:groupID withCompletionBlock:^(NSError * error, Group* group) {
                                                [[FlatAPIClientManager sharedClient] setGroup:group];
                                                [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreAndWait];
                                            }];
                                            
                                        } else {
                                            NSLog(@"error when setting user group id");
                                        }
                                        if (completionBlock) completionBlock(error);
                                    }
                                    failure: ^(NSURLSessionDataTask *__unused task, NSError *error) {
                                        NSLog(@"error in setting group id");
                                        if (completionBlock) completionBlock(error);
                                    }];
}

+ (void) setGroupIDForUser:(NSNumber*)userID
                   groupID:(NSNumber*)groupID {
    [ProfileUserNetworkRequest setGroupIDForUser:userID groupID:groupID withCompletionBlock:nil];
}


+ (void) getFriendsGroupsFromUserID:(NSNumber*)userID
         withCompletionBlock:(RequestProfileUsersCompletionHandler)completionBlock
{
    NSString * url = [NSString stringWithFormat:@"http://flatappapi.appspot.com/facebook/user/%@/friendgroups", userID];
    [[FlatAPIClientManager sharedClient]GET:url
                                 parameters:Nil
                                    success:^(NSURLSessionDataTask * task, id JSON) {
                                        NSError *error = [ErrorHelper apiErrorFromDictionary:JSON];
                                        if (!error) {
                                            NSMutableArray *groupsArrayReturn = [[NSMutableArray alloc] init];
                                            NSMutableArray *groupsArray = [JSON objectForKey:@"groups"];
                                            for (NSMutableDictionary * group in groupsArray) {
                                                NSMutableArray *usersArray = [group objectForKey:@"users"];
                                                NSMutableArray *usersArrayReturn = [[NSMutableArray alloc] init];
                                                
                                                bool shouldAddThisUsersGroup = true;
                                                for (NSMutableDictionary* userJSON in usersArray) {
                                                    ProfileUser *profileUser = [ProfileUser getProfileUserObjectFromDictionary:userJSON
                                                                                                       AndManagedObjectContext:[NSManagedObjectContext MR_defaultContext]];
                                                    

                                                    if ([profileUser.userID isEqualToNumber2:userID] && [profileUser.groupID isEqualToNumber2:[[FlatAPIClientManager sharedClient]profileUser].groupID])
                                                        shouldAddThisUsersGroup = false; //do not add the group that belongs to current user
                                                    [usersArrayReturn addObject:profileUser];
                                                }
                                                if (shouldAddThisUsersGroup)
                                                    [groupsArrayReturn addObject:usersArrayReturn];
                                            }
                                            completionBlock(error, groupsArrayReturn);
                                        } else {
                                            completionBlock(error, nil);
                                        }
                                    }
                                    failure: ^(NSURLSessionDataTask *__unused task, NSError *error) {
                                        NSLog(@"error in getting friend groups");
                                        completionBlock(error, nil);
                                    }];
    
}

@end
