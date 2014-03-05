//
//  TasksHelper.h
//  flat
//
//  Created by Zachary Palacios on 3/2/14.
//  Copyright (c) 2014 cs194. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^TaskHelperCompletionHandler)(NSError *, NSArray *tasks);

@interface TasksHelper : NSObject

+ (void)getTasksWithCompletionBlock:(TaskHelperCompletionHandler)completionBlock;

+ (void)createTaskWithText:(NSString *)text
                   andDate:(NSDate *)date
        andCompletionBlock:(TaskHelperCompletionHandler)completion;

+ (void)deleteTaskWithTaskId:(NSNumber *)taskId
        andCompletionHandler:(TaskHelperCompletionHandler)completion;

+ (void)editTaskWithTaskId:(NSNumber *)taskId
                   andBody:(NSString *)body
                   andDate:(NSDate *)date
      andCompletionHandler:(TaskHelperCompletionHandler)completion;

@end
