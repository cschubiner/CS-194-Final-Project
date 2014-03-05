//
//  TasksHelper.m
//  flat
//
//  Created by Zachary Palacios on 3/2/14.
//  Copyright (c) 2014 cs194. All rights reserved.
//

#import "TasksHelper.h"
#import "TasksNetworkRequest.h"

@implementation TasksHelper

+ (void)getTasksWithCompletionBlock:(TaskHelperCompletionHandler)completion
{
    NSNumber *groupId = [FlatAPIClientManager sharedClient].group.groupID;
    [TasksNetworkRequest getTasksForGroupWithGroupId:groupId
                                  andCompletionBlock:^(NSError *error, NSArray *tasks)
    {
        if (error) {
            NSLog(@"Error in TasksHelper: %@", error);
            completion(error, nil);
        } else {
            completion(error, tasks);
        }
    }];
}

+ (void)createTaskWithText:(NSString *)text
                   andDate:(NSDate *)date
        andCompletionBlock:(TaskHelperCompletionHandler)completion
{
    NSNumber *groupId = [FlatAPIClientManager sharedClient].group.groupID;
<<<<<<< HEAD
    NSLog(@"about to make network request in task helper");
=======
>>>>>>> my-temporary-work
    [TasksNetworkRequest createTaskForGroupWithGroupId:groupId
                                               andText:(NSString *)text
                                               andDate:date
                                    andCompletionBlock:^(NSError *error, NSArray *tasks)
    {
        if (error) {
            NSLog(@"Error in TasksHelper: %@", error);
            completion(error, nil);
        } else {
            completion(error, tasks);
        }
    }];
}

+ (void)deleteTaskWithTaskId:(NSNumber *)taskId
        andCompletionHandler:(TaskHelperCompletionHandler)completion
{
<<<<<<< HEAD
    Group *group = [FlatAPIClientManager sharedClient].group;
    [TasksNetworkRequest deleteTaskWithTaskId:taskId
                                   andGroupId:group.groupID
=======
    [TasksNetworkRequest deleteTaskWithTaskId:taskId
>>>>>>> my-temporary-work
                           andCompletionBlock:^(NSError *error, NSArray *tasks)
    {
        if (error) {
            NSLog(@"Error in TaskHelper: %@", error);
            completion(error, nil);
        } else {
            completion(error, tasks);
        }
    }];
}

<<<<<<< HEAD
+ (void)editTaskWithTaskId:(NSNumber *)taskId
                   andBody:(NSString *)body
                   andDate:(NSDate *)date
      andCompletionHandler:(TaskHelperCompletionHandler)completion
{
    Group *group = [FlatAPIClientManager sharedClient].group;
    [TasksNetworkRequest editTaskWithTaskId:taskId
                                    andBody:body
                                    andDate:date
                                 andGroupId:group.groupID
                         andCompletionBlock:^(NSError *error, NSArray *tasks)
    {
        if (error) {
            NSLog(@"Error in TaskHelper: %@", error);
            completion(error, nil);
        } else {
            completion(error, tasks);
        }
    }];
}

=======
>>>>>>> my-temporary-work
@end
