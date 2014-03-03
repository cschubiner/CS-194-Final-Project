//
//  TasksNetworkRequest.m
//  flat
//
//  Created by Zachary Palacios on 3/2/14.
//  Copyright (c) 2014 cs194. All rights reserved.
//

#import "TasksNetworkRequest.h"
#import "Task+Json.h"

@implementation TasksNetworkRequest

+(void)getTasksForGroupWithGroupId:(NSNumber *)groupId
                andCompletionBlock:(TaskNetworkCompletionHandler)completion
{
    NSString *url = [NSString stringWithFormat:@"tasks/%@", groupId];
    [[FlatAPIClientManager sharedClient] GET:url
                                  parameters:nil
                                     success:^(NSURLSessionDataTask *task, id JSON) {
                                         NSError *error = [ErrorHelper apiErrorFromDictionary:JSON];
                                         if (!error) {
                                             NSMutableArray *tasksArray = [JSON objectForKey:@"tasks"];
                                             NSMutableArray *tasksArrayReturn = [[NSMutableArray alloc] init];
                                             for (NSMutableDictionary* userJSON in tasksArray) {
                                                 Task *task = [Task getTaskObjectFromDictionary:userJSON
                                                                        AndManagedObjectContext:[NSManagedObjectContext MR_defaultContext]];
                                                 [tasksArrayReturn addObject:task];
                                             }
                                             completion(error, tasksArrayReturn);
                                         } else {
                                             completion(error, nil);
                                         }

                                     }
                                     failure:^(NSURLSessionDataTask *task, NSError *error) {
                                         NSLog(@"Error in TasksNetworkFile: %@", error);
                                         completion(error, nil);
                                     }];
}

+ (void)createTaskForGroupWithGroupId:(NSNumber *)groupId
                              andText:(NSString *)text
                              andDate:(NSDate *)date
                   andCompletionBlock:(TaskNetworkCompletionHandler)completion
{
    NSDictionary *params = @{@"group_id":groupId,
                             @"due_date":date,
                             @"body":text};
    [[FlatAPIClientManager sharedClient] POST:@"/tasks/add"
                                  parameters:params
                                     success:^(NSURLSessionDataTask *task, id JSON) {
                                         NSError *error = [ErrorHelper apiErrorFromDictionary:JSON];
                                         if (!error) {
                                             NSMutableArray *tasksArray = [JSON objectForKey:@"tasks"];
                                             NSMutableArray *tasksArrayReturn = [[NSMutableArray alloc] init];
                                             for (NSMutableDictionary* userJSON in tasksArray) {
                                                 Task *task = [Task getTaskObjectFromDictionary:userJSON
                                                                        AndManagedObjectContext:[NSManagedObjectContext MR_defaultContext]];
                                                 [tasksArrayReturn addObject:task];
                                             }
                                             completion(error, tasksArrayReturn);
                                         } else {
                                             completion(error, nil);
                                         }
                                         
                                     }
                                     failure:^(NSURLSessionDataTask *task, NSError *error) {
                                         NSLog(@"Error in TasksNetworkFile: %@", error);
                                         completion(error, nil);
                                     }];
}

+ (void)deleteTaskWithTaskId:taskId
          andCompletionBlock:(TaskNetworkCompletionHandler)completion
{
    NSDictionary *params = @{@"task_id":taskId};
    [[FlatAPIClientManager sharedClient] POST:@""
                                   parameters:params
                                      success:^(NSURLSessionDataTask *task, id JSON) {
                                          NSError *error = [ErrorHelper apiErrorFromDictionary:JSON];
                                          if (!error) {
                                              NSMutableArray *tasksArray = [JSON objectForKey:@"tasks"];
                                              NSMutableArray *tasksArrayReturn = [[NSMutableArray alloc] init];
                                              for (NSMutableDictionary* userJSON in tasksArray) {
                                                  Task *task = [Task getTaskObjectFromDictionary:userJSON
                                                                         AndManagedObjectContext:[NSManagedObjectContext MR_defaultContext]];
                                                  [tasksArrayReturn addObject:task];
                                              }
                                              completion(error, tasksArrayReturn);
                                          } else {
                                              completion(error, nil);
                                          }
                                          
                                      }
                                      failure:^(NSURLSessionDataTask *task, NSError *error) {
                                          NSLog(@"Error in TasksNetworkFile: %@", error);
                                          completion(error, nil);
                                      }];

}

@end
