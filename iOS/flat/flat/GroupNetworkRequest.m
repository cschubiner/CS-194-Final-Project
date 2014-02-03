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
    NSString * url = [NSString stringWithFormat:@"group/%@", groupID];
    [[FlatAPIClientManager sharedClient]GET: url
                                 parameters:Nil
                                    success:^(NSURLSessionDataTask * task, id JSON) {
                                        NSError *error = [ErrorHelper apiErrorFromDictionary:JSON];
                                        if (!error) {
                                            NSMutableDictionary *groupJSON = [JSON objectForKey:@"group"];
                                                Group *group = [Group getGroupObjectFromDictionary:groupJSON
                                                                                                   AndManagedObjectContext:[NSManagedObjectContext MR_defaultContext]];
                                            completionBlock(error, group);
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