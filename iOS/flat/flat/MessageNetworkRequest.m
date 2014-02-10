//
//  MessageNetworkRequest.m
//  flat
//
//  Created by Zachary Palacios on 2/9/14.
//  Copyright (c) 2014 cs194. All rights reserved.
//

#import "MessageNetworkRequest.h"
#import "JSMessage+Json.h"

@implementation MessageNetworkRequest

+ (void)sendMessageWithText:(NSString *)text
         fromUserWithUserID:(int)userID
         andCompletionBlock:(MessageNetworkCompletionHandler)completionBlock
{
    NSDictionary *params = @{@"message":text,
                             @"userID":[NSNumber numberWithInt:userID]};
    [[FlatAPIClientManager sharedClient] POST:@"/message/new"
                                   parameters:params
                                      success:^(NSURLSessionDataTask *__unused task, id JSON) {
                                          NSError *error = [ErrorHelper apiErrorFromDictionary:JSON];
                                          if (!error) {
                                              NSMutableArray *messageArray = [JSON objectForKey:@"messages"];
                                              NSMutableArray *messageArrayReturn = [[NSMutableArray alloc] init];
                                              for (NSMutableDictionary* messageJSON in messageArray) {
                                                  JSMessage *message = [JSMessage getMessageObjectFromDictionary:messageJSON];
                                                  [messageArrayReturn addObject:message];
                                              }
                                              completionBlock(error, messageArrayReturn);
                                          } else {
                                              completionBlock(error, nil);
                                          }
                                      }
                                      failure:^(NSURLSessionDataTask *task, NSError *error) {
                                          NSLog(@"Error in MessageNetworkRequest: %@", error);
                                          completionBlock(error, nil);
                                      }];
}

+ (void)getMessagesForUserWithUserID:(int)userID
                  andCompletionBlock:(MessageNetworkCompletionHandler)completionBlock
{
    NSDictionary *params = @{@"userID":[NSNumber numberWithInt:userID]};
    [[FlatAPIClientManager sharedClient] GET:@"/messages/all"
                                  parameters:params
                                     success:^(NSURLSessionDataTask *__unused task, id JSON) {
                                         NSError *error = [ErrorHelper apiErrorFromDictionary:JSON];
                                         if (!error) {
                                             NSMutableArray *messageArray = [JSON objectForKey:@"messages"];
                                             NSMutableArray *messageArrayReturn = [[NSMutableArray alloc] init];
                                             for (NSMutableDictionary* messageJSON in messageArray) {
                                                 JSMessage *message = [JSMessage getMessageObjectFromDictionary:messageJSON];
                                                 [messageArrayReturn addObject:message];
                                             }
                                             completionBlock(error, messageArrayReturn);
                                         } else {
                                             completionBlock(error, nil);
                                         }
                                     }
                                     failure:^(NSURLSessionDataTask *task, NSError *error) {
                                         NSLog(@"Error in MessageNetworkRequest: %@", error);
                                         completionBlock(error, nil);
                                     }];
}

@end
