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

NSString* lastMessage;

+(void)sendMessageWithText:(NSString *)text
        andCompletionBlock:(MessageHelperCompletionHandler)completionBlock
{
    NSNumber * userID = [FlatAPIClientManager sharedClient].profileUser.userID;
    [MessageNetworkRequest sendMessageWithText:text
                            fromUserWithUserID:userID
                            andCompletionBlock:^(NSError *error, NSMutableArray *messages) {
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
                                     andCompletionBlock:^(NSError *error, NSMutableArray *messages) {
                                         //
                                         if (error) {
                                             NSLog(@"Error in MessageHelper %@", error);
                                             completionBlock(error, nil);
                                         } else {
                                             completionBlock(nil, messages);
                                         }
                                     }];
}


+(void)sendCalendarMessageForEvent:(EKEvent*)event {
    NSString * messageText = [NSString stringWithFormat:@"%@'s event, %@, starts at %@.",
                              [FlatAPIClientManager sharedClient].profileUser.firstName,
                              event.title,
                              [Utils formatDate:event.startDate]
                              ];
    if (lastMessage != nil && [messageText isEqualToString:lastMessage]) return;
    lastMessage = messageText;
    
    NSNumber * userID = [FlatAPIClientManager sharedClient].profileUser.userID;
    [MessageNetworkRequest sendMessageWithText:messageText
                            fromUserWithUserID:userID
                                       postURL:@"calendar/message/new"
                            andCompletionBlock:^(NSError *error, NSMutableArray *messages) {
                                if (((cs194AppDelegate*)[UIApplication sharedApplication].delegate).backgroundCallback != nil) {
                                    ((cs194AppDelegate*)[UIApplication sharedApplication].delegate).backgroundCallback(UIBackgroundFetchResultNewData);
                                    [((cs194AppDelegate*)[UIApplication sharedApplication].delegate) setBackgroundCallback:nil];
                                }
                                if (error) {
                                    NSLog(@"Error in sending calendar message %@", error);
                                } else {
                                    DLog(@"calendar message sent successfully");
                                }
                            }];
}
@end
