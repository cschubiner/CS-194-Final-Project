//
//  Task+Json.h
//  flat
//
//  Created by Zachary Palacios on 3/8/14.
//  Copyright (c) 2014 cs194. All rights reserved.
//

#import "Task.h"

@interface Task (Json)

+ (Task *)getTaskObjectFromDictionary:(NSDictionary *)dictionary
              AndManagedObjectContext:(NSManagedObjectContext *)context;

@end
