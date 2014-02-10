//
//  MessageHelper.h
//  flat
//
//  Created by Zachary Palacios on 2/9/14.
//  Copyright (c) 2014 cs194. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^MessageHelperCompletionHandler)(NSError *, NSArray *messages);

@interface MessageHelper : NSObject

+(void)sendMessageWithText:(NSString *)text
        andCompletionBlock:(MessageHelperCompletionHandler)completionBlock;

+(void)getMessagesWithCompletionBlock:(MessageHelperCompletionHandler)completionBlock;

@end
