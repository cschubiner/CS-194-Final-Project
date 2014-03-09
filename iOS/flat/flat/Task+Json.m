//
//  Task+Json.m
//  flat
//
//  Created by Zachary Palacios on 3/8/14.
//  Copyright (c) 2014 cs194. All rights reserved.
//

#import "Task+Json.h"

@implementation Task (Json)

+ (Task *)getTaskObjectFromDictionary:(NSDictionary *)dictionary
              AndManagedObjectContext:(NSManagedObjectContext *)context
{
    Task *task = [Task MR_createInContext:context];
    task.taskId = [dictionary objectForKey:@"id"];
    task.body = [dictionary objectForKey:@"body"];
    task.dueDate = [Utils dateFromString:[dictionary objectForKey:@"due_date"]];
    [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreAndWait];
    return task;
}

@end
