//
//  TasksViewController.h
//  flat
//
//  Created by Zachary Palacios on 3/2/14.
//  Copyright (c) 2014 cs194. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TasksViewController : UIViewController <UITableViewDelegate, UITableViewDataSource>

@property UITableView *tasksTable;

@end
