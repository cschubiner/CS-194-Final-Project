//
//  MessageHelper.m
//  flat
//
//  Created by Zachary Palacios on 2/9/14.
//  Copyright (c) 2014 cs194. All rights reserved.
//

#import "MessageHelper.h"
#import "MessageNetworkRequest.h"

@implementation MessageHelper

+(void)sendMessageWithText:(NSString *)text
        andCompletionBlock:(MessageHelperCompletionHandler)completionBlock
{
    NSNumber * userID = [FlatAPIClientManager sharedClient].profileUser.userID;
    [MessageNetworkRequest sendMessageWithText:text
                            fromUserWithUserID:userID
                            andCompletionBlock:^(NSError *error, NSArray *messages) {
                                if (error) {
                                    NSLog(@"Error in MessageHelper %@", error);
                                    completionBlock(error, nil);
                                } else {
                                    completionBlock(nil, messages);
                                }
                            }];
}

+(void)getMessagesWithCompletionBlock:(MessageHelperCompletionHandler)completionBlock
{
    NSNumber* userID = [FlatAPIClientManager sharedClient].profileUser.userID;
    [MessageNetworkRequest getMessagesForUserWithUserID:userID
                                     andCompletionBlock:^(NSError *error, NSArray *messages) {
                                         if (error) {
                                             NSLog(@"Error in MessageHelper %@", error);
                                             completionBlock(error, nil);
                                         } else {
                                             completionBlock(nil, messages);
                                         }
                                     }];
}

@end
