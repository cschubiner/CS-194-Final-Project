//
//  cs194AppDelegate.h
//  flat
//
//  Created by Zachary Palacios on 1/19/14.
//  Copyright (c) 2014 cs194. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RootController.h"
#import "OpeningNavigationController.h"

@interface cs194AppDelegate : UIResponder <UIApplicationDelegate, UIAlertViewDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (strong, nonatomic) RootController *mainViewController;
@property (strong, nonatomic) OpeningNavigationController *loginViewController;
@property (nonatomic, assign) BOOL loggedIn;

@property (strong, nonatomic) NSString *fbToken;

- (void)openFacebookSession;
- (void)refreshInitialView;
- (void)handleLogout;

@end
