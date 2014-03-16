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
         fromUserWithUserID:(NSNumber*)userID
                    postURL: (NSString*)postURL
         andCompletionBlock:(MessageNetworkCompletionHandler)completionBlock
{
    NSDictionary *params = @{@"message":text,
                             @"userID":userID};
    NSLog(@"TEXT: %@ \n USERID %@", text, userID);
    [[FlatAPIClientManager sharedClient] POST:postURL
                                   parameters:params
                                      success:^(NSURLSessionDataTask *__unused task, id JSON) {
                                          NSError *error = [ErrorHelper apiErrorFromDictionary:JSON];
                                          if (!error) {
//                                              NSLog(@"JSON: %@", JSON);
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

+ (void)sendMessageWithText:(NSString *)text
         fromUserWithUserID:(NSNumber*)userID
         andCompletionBlock:(MessageNetworkCompletionHandler)completionBlock
{
    [self sendMessageWithText:text fromUserWithUserID:userID postURL:@"/message/new" andCompletionBlock:completionBlock];
}

+ (void)getMessagesForUserWithUserID:(NSNumber*)userID
                  andCompletionBlock:(MessageNetworkCompletionHandler)completionBlock
{
//    DLog(@"Getting messages c");
    NSDictionary *params = nil; //@{@"userID":[NSNumber numberWithInt:userID]};
    
    NSString * url = [NSString stringWithFormat:@"/messages/all/%@", userID];
    [[FlatAPIClientManager sharedClient] GET:url
                                  parameters:params
                                     success:^(NSURLSessionDataTask *__unused task, id JSON) {
//    DLog(@"Getting messages d");
                                         NSError *error = [ErrorHelper apiErrorFromDictionary:JSON];
                                         if (!error) {
                                             NSMutableArray *messageArray = [JSON objectForKey:@"messages"];
                                             NSMutableArray *messageArrayReturn = [[NSMutableArray alloc] init];
                                             for (NSMutableDictionary* messageJSON in messageArray) {
                                                 //if ([[messageJSON objectForKey:@"type"] isEqualToString:@"text"]) {
                                                     JSMessage *message = [JSMessage getMessageObjectFromDictionary:messageJSON];
                                                     [messageArrayReturn addObject:message];
                                                 /*} else if ([[messageJSON objectForKey:@"type"] isEqualToString:@"calendar"]) {
                                                     CalendarMessage *message = [CalendarMessage getMessageObjectFromDictionary:messageJSON];
                                                     [messageArrayReturn addObject:message];
                                                 }*/
                                             }
                                             completionBlock(error, messageArrayReturn);
                                         } else {
                                             completionBlock(error, nil);
                                         }
                                     }
                                     failure:^(NSURLSessionDataTask *task, NSError *error) {
//    DLog(@"Getting messages f");
                                         NSLog(@"Error in MessageNetworkRequest: %@", error);
                                         completionBlock(error, nil);
//    DLog(@"Getting messages e");
                                     }];
}

@end
