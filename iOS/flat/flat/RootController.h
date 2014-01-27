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
#import "HomeViewController.h"

@interface RootController : JASidePanelController <SidebarViewDelegate>

-(IBAction)toggleSidebarMenu:(id)sender;

@property (nonatomic, strong) SidebarViewController *leftPanel;
@property (nonatomic, strong) HomeViewController *centerPanel;

@end