//
//  GroupNetworkRequest.m
//  flat
//
//  Created by Clay Schubiner on 2/2/14.
//  Copyright (c) 2014 cs194. All rights reserved.
//

#import "GroupNetworkRequest.h"
#import "Group+Json.h"

@implementation GroupNetworkRequest

+ (void) getGroupFromGroupID:(NSNumber*)groupID
         withCompletionBlock:(RequestGroupCompletionHandler)completionBlock;
{
    if (groupID == nil) return;
    NSString * url = [NSString stringWithFormat:@"group/%@", groupID];
    [[FlatAPIClientManager sharedClient]GET: url
                                 parameters:Nil
                                    success:^(NSURLSessionDataTask * task, id JSON) {
                                        NSError *error = [ErrorHelper apiErrorFromDictionary:JSON];
                                        if (!error) {
                                            NSMutableDictionary *groupJSON = [JSON objectForKey:@"group"];
                                                Group *group = [Group getGroupObjectFromDictionary:groupJSON];
                                            completionBlock(error, group);
                                        } else {
                                            completionBlock(error, nil);
                                        }
                                    }
                                    failure: ^(NSURLSessionDataTask *__unused task, NSError *error) {
                                        DLog(@"error");
                                        completionBlock(error, nil);
                                    }];
}

+ (void) setGroupLocation:(NSNumber*)groupID
             withLocation: (CLLocation *) location
      withCompletionBlock:(RequestGroupCompletionHandler)completionBlock {
    
    NSDictionary * params = [NSDictionary dictionaryWithObjectsAndKeys:
                             groupID, @"groupID",
                             [NSNumber numberWithDouble:location.coordinate.latitude], @"lat",
                             [NSNumber numberWithDouble:location.coordinate.longitude], @"long",
                             nil];
    NSString * url = @"group/update_location/";
    [[FlatAPIClientManager sharedClient]POST: url
                                 parameters:params
                                    success:^(NSURLSessionDataTask * task, id JSON) {
                                        NSError *error = [ErrorHelper apiErrorFromDictionary:JSON];
                                        if (!error) {
                                            NSMutableDictionary *groupJSON = [JSON objectForKey:@"group"];
                                            Group *group = [Group getGroupObjectFromDictionary:groupJSON];
                                            completionBlock(error, group);
                                        } else {
                                            completionBlock(error, nil);
                                        }
                                    }
                                    failure: ^(NSURLSessionDataTask *__unused task, NSError *error) {
                                        NSLog(@"error: %@", error);
                                        completionBlock(error, nil);
                                    }];
}

@end