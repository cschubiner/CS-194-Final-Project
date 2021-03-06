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
#import <MessageUI/MessageUI.h>

@protocol SidebarViewDelegate <NSObject>

@end

@interface SidebarViewController : UIViewController <UISearchBarDelegate, UISearchDisplayDelegate, UITableViewDataSource, UITableViewDelegate, UIAlertViewDelegate, MFMailComposeViewControllerDelegate>
{
    
    BOOL isVisible;
    BOOL newNotification;
    BOOL inDetailed;
    int divider;
    
    
}

@property (nonatomic, strong) UITableView *sideBarMenuTable;

@property (nonatomic, retain) UIButton *listener;
@property (nonatomic, retain) UIButton *notificationCount;

@property (nonatomic, strong) NSArray *teams;

@property (nonatomic, strong) NSMutableIndexSet *expandedSections;

@property (nonatomic, assign) id delegate;

-(void)reloadTable;

@end
