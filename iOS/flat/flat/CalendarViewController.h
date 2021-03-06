//
//  SidebarViewController.h
//  flat
//
//  Created by Zachary Palacios on 1/19/14.
//  Copyright (c) 2014 cs194. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LocationManager.h"
#import "ProfileUserHelper.h"


@protocol CalendarViewDelegate <NSObject>

@end

@interface CalendarViewController : UIViewController <UISearchBarDelegate, UISearchDisplayDelegate, UITableViewDataSource, UITableViewDelegate, UIAlertViewDelegate>
{
    BOOL isVisible;
    BOOL newNotification;
    BOOL inDetailed;
    int divider;
}

@property (nonatomic, strong) UITableView *sideBarMenuTable;


-(int)numberOfEventsOccurringNow;

@property (nonatomic, strong) NSMutableIndexSet *expandedSections;

@property (nonatomic, assign) id delegate;


@end
