//
//  MessageNetworkRequest.h
//  flat
//
//  Created by Zachary Palacios on 2/9/14.
//  Copyright (c) 2014 cs194. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^MessageNetworkCompletionHandler)(NSError *, NSArray *messages);

@interface MessageNetworkRequest : NSObject

+ (void)sendMessageWithText:(NSString *)text
         fromUserWithUserID:(NSNumber*)userID
                    postURL:(NSString*)postURL
         andCompletionBlock:(MessageNetworkCompletionHandler)completionBlock;

+ (void)sendMessageWithText:(NSString *)text
         fromUserWithUserID:(NSNumber*)userID
         andCompletionBlock:(MessageNetworkCompletionHandler)completionBlock;

+ (void)getMessagesForUserWithUserID:(NSNumber*)userID
                  andCompletionBlock:(MessageNetworkCompletionHandler)completionBlock;

@end
