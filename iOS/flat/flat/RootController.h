//
//  RootController.h
//  flat
//
//  Created by Zachary Palacios on 1/19/14.
//  Copyright (c) 2014 cs194. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JASidePanelController.h"
#import "SidebarViewController.h"
#import "CalendarViewController.h"
#import "HomeViewController.h"

@interface RootController : JASidePanelController <SidebarViewDelegate, UINavigationControllerDelegate>

- (void)toggleSidebarMenu:(id)sender;
- (void)rightButtonPressed:(id)sender;

@property (nonatomic, strong) SidebarViewController *leftPanel;
@property (nonatomic, strong) CalendarViewController *rightPanel;
@property (nonatomic, strong) UINavigationController *centerPanel;
@property (nonatomic, strong) HomeViewController *centerPanelHome;

-(void)requestCalendarAccess;
-(void) refreshMessagesWithAnimation:(BOOL)animated scrollToBottom:(BOOL)scrollToBottom;
-(void)refreshUsers;
-(void)getCalendarEventsForDays;

@end
