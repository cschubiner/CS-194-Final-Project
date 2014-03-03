//
//  Task+Json.m
//  flat
//
//  Created by Zachary Palacios on 3/2/14.
//  Copyright (c) 2014 cs194. All rights reserved.
//

#import "Task+Json.h"

@implementation Task (Json)

+ (Task *)getTaskObjectFromDictionary:(NSDictionary *)dictionary
              AndManagedObjectContext:(NSManagedObjectContext *)context
{
    Task *task = [Task MR_createInContext:context];
    task.body = [dictionary objectForKey:@"body"];
    //task.dueDate = [NSDate dateWithTimeIntervalSince1970:(int)[dictionary objectForKey:@"due_date"]];
    task.taskId = [dictionary objectForKey:@"id"];
    [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreAndWait];
    return task;
}

@end
