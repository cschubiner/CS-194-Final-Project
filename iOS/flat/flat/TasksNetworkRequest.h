//
//  TasksNetworkRequest.h
//  flat
//
//  Created by Zachary Palacios on 3/2/14.
//  Copyright (c) 2014 cs194. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^TaskNetworkCompletionHandler)(NSError *, NSArray *tasks);

@interface TasksNetworkRequest : NSObject

+(void)getTasksForGroupWithGroupId:(NSNumber *)groupId
                andCompletionBlock:(TaskNetworkCompletionHandler)completion;

+ (void)createTaskForGroupWithGroupId:(NSNumber *)groupId
                              andText:(NSString *)text
                              andDate:(NSDate *)date
                   andCompletionBlock:(TaskNetworkCompletionHandler)completion;

+ (void)deleteTaskWithTaskId:taskId
          andCompletionBlock:(TaskNetworkCompletionHandler)completion;

@end
