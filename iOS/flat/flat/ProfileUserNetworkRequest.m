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

+(void)getUserForUserID:(NSNumber*)userID withCompletionBlock:(RequestProfileUserCompletionHandler)completionBlock{
    [[FlatAPIClientManager sharedClient] GET:[NSString stringWithFormat:@"/user/%@", userID]
                                  parameters:nil
                                     success:^(NSURLSessionDataTask *__unused task, id JSON)
     {
         NSError *error = [ErrorHelper apiErrorFromDictionary:JSON];
         if (!error) {
             NSMutableDictionary *userJSON = [JSON objectForKey:@"user"];
             ProfileUser *profileUser;
             profileUser = [ProfileUser getProfileUserObjectFromDictionary:userJSON
                                                   AndManagedObjectContext:[NSManagedObjectContext MR_defaultContext]];
             completionBlock(error, profileUser);
         } else {
             completionBlock(error, nil);
         }
     } failure:^(NSURLSessionDataTask *__unused task, NSError *error) {
         completionBlock(error,nil);
     }];
}


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
                                            NSArray *sortedArray;
                                            sortedArray = [usersArrayReturn sortedArrayUsingComparator:^NSComparisonResult(id a, id b) {
                                                NSNumber *first = [(ProfileUser*)a colorID];
                                                NSNumber *second = [(ProfileUser*)b colorID];
                                                return [first compare:second];
                                            }];
                                            completionBlock(error, [NSMutableArray arrayWithArray:sortedArray]);
                                        } else {
                                            completionBlock(error, nil);
                                        }
                                    }
                                    failure: ^(NSURLSessionDataTask *__unused task, NSError *error) {
                                        DLog(@"error");
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
                                            DLog(@"successfully set user location");
                                            [[[FlatAPIClientManager sharedClient]rootController]refreshUsers];
                                        } else {
                                            DLog(@"error when setting user location");
                                        }
                                    }
                                    failure: ^(NSURLSessionDataTask *__unused task, NSError *error) {
                                        DLog(@"error");
                                    }];
}

+(void)setGroupIDForUser:(NSNumber *)userID groupID:(NSNumber *)groupID withPassword:(NSString*)password withCompletionBlock:(ErrorCompletionHandler)completionBlock {
    NSString * url = [NSString stringWithFormat:@"user/%@/changegroupid/%@/token/%@", userID, groupID, password];
    [[FlatAPIClientManager sharedClient]GET:url
                                 parameters:Nil
                                    success:^(NSURLSessionDataTask * task, id JSON) {
                                        NSError *error = [ErrorHelper apiErrorFromDictionary:JSON];
                                        if (!error) {
                                            DLog(@"successfully set user group id");
                                            [[[FlatAPIClientManager sharedClient]profileUser] setGroupID:groupID];
                                            
                                            [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreWithCompletion:nil];
                                            [GroupNetworkRequest getGroupFromGroupID:groupID withCompletionBlock:^(NSError * error, Group* group) {
                                                [[FlatAPIClientManager sharedClient] setGroup:group];
                                                CLLocationManager * manager = [[LocationManager sharedClient] locationManager];
                                                [manager stopMonitoringForRegion:manager.monitoredRegions.anyObject];
                                                [manager startMonitoringForRegion:[[LocationManager sharedClient] getGroupLocationRegion]];
                                                [[LocationManager sharedClient] setShouldSetDormLocation:false];
                                                [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreWithCompletion:nil];
                                            }];
                                            
                                        } else {
                                            DLog(@"error when setting user group id");
                                        }
                                        if (completionBlock) completionBlock(error);
                                    }
                                    failure: ^(NSURLSessionDataTask *__unused task, NSError *error) {
                                        NSLog(@"error in setting group id %@", error);
                                        if (completionBlock) completionBlock(error);
                                    }];
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
                                                    if ([profileUser.userID isEqualToNumberWithNullCheck:userID] && [profileUser.groupID isEqualToNumberWithNullCheck:[[FlatAPIClientManager sharedClient]profileUser].groupID])
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
                                        NSLog(@"error in getting friend groups: %@", error);
                                        completionBlock(error, nil);
                                    }];
}

@end
