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
    NSLog(@"Getting messages 9");
                                         if (error) {
                                             NSLog(@"Error in MessageHelper %@", error);
                                             completionBlock(error, nil);
                                         } else {
                                             completionBlock(nil, messages);
                                         }
    NSLog(@"Getting messages a");
                                     }];
}


+(void)sendCalendarMessageForEvent:(EKEvent*)event {
    NSNumber * userID = [FlatAPIClientManager sharedClient].profileUser.userID;
    NSString * messageText = [NSString stringWithFormat:@"%@'s event, %@, starts at %@.",
                              [FlatAPIClientManager sharedClient].profileUser.firstName,
                              event.title,
                       [Utils formatDate:event.startDate]
//                              , [Utils formatDate:event.endDate]
                              ];
    [MessageNetworkRequest sendMessageWithText:messageText
                            fromUserWithUserID:userID
                            postURL:@"calendar/message/new"
                            andCompletionBlock:^(NSError *error, NSArray *messages) {
                                if (error) {
                                    NSLog(@"Error in sending calendar message %@", error);
                                } else {
                                    NSLog(@"calendar message sent successfully");
                                }
                            }];
}
@end
