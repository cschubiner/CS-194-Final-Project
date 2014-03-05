//
//  Task.h
//  flat
//
//  Created by Zachary Palacios on 3/2/14.
//  Copyright (c) 2014 cs194. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Task : NSManagedObject

@property (nonatomic, retain) NSDate * dueDate;
<<<<<<< HEAD
@property (nonatomic, retain) NSNumber * taskId;
@property (nonatomic, retain) NSString * body;
=======
@property (nonatomic, retain) NSString * text;
@property (nonatomic, retain) NSNumber * taskId;
>>>>>>> my-temporary-work

@end
