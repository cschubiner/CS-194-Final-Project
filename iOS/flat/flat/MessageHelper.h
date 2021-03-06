//
//  MessageHelper.h
//  flat
//
//  Created by Zachary Palacios on 2/9/14.
//  Copyright (c) 2014 cs194. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <EventKit/EventKit.h>

typedef void (^MessageHelperCompletionHandler)(NSError *, NSMutableArray *messages);

@interface MessageHelper : NSObject

+(void)sendMessageWithText:(NSString *)text
        andCompletionBlock:(MessageHelperCompletionHandler)completionBlock;

+(void)getMessagesWithCompletionBlock:(MessageHelperCompletionHandler)completionBlock;

+(void)sendCalendarMessageForEvent:(EKEvent*)event;

@end
