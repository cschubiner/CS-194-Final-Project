//
//  TaskDetailViewController.h
//  flat
//
//  Created by Zachary Palacios on 3/4/14.
//  Copyright (c) 2014 cs194. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Task+Json.h"

@interface TaskDetailViewController : UIViewController
@property Task *task;
@property NSMutableArray *tasks;
@end
