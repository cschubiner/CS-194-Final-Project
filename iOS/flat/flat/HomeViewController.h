//
//  HomeViewController.h
//  flat
//
//  Created by Zachary Palacios on 1/19/14.
//  Copyright (c) 2014 cs194. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JSMessagesViewController.h"

@interface HomeViewController : JSMessagesViewController <JSMessagesViewDelegate, JSMessagesViewDataSource>

@property (strong, nonatomic) NSMutableArray *messages;
@property (strong, nonatomic) UIRefreshControl *refresh;
@property (strong, nonatomic) UITableViewController *tableViewController;

+ (UIImage *) imageWithView:(UIView *)view;
-(void) resetTable;

@end
