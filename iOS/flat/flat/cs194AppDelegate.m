//
//  cs194AppDelegate.m
//  flat
//
//  Created by Zachary Palacios on 1/19/14.
//  Copyright (c) 2014 cs194. All rights reserved.
//

#import "cs194AppDelegate.h"
#import <FacebookSDK/FacebookSDK.h>
#import "AuthenticationNetworkRequest.h"
#import "ProfileUserHelper.h"
#import "AuthenticationHelper.h"
#import "GroupNetworkRequest.h"


@implementation cs194AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    //Magical Record
    [MagicalRecord setupCoreDataStack];
    
    // Check if user is logged in
    ProfileUser *profileUser = [ProfileUserHelper getProfileUser];
    if (profileUser != nil) {
        self.loggedIn = YES;
        
        //User is logged in
        if (FBSession.activeSession.state == FBSessionStateCreatedTokenLoaded) {
            // Open Facebook Session
            [self openFacebookSession];
        }
        
        // Set Profile User
        [FlatAPIClientManager sharedClient].profileUser = profileUser;
        [self showInitialView];
    } else {
        // Not Logged In, show Login
        NSLog(@"Not Logged in, show Login screen");
        [self showInitialView];
        NSLog(@"Show initial view already called");
        [self showLoginView];
    }
    
    [GroupNetworkRequest getGroupFromGroupID:[FlatAPIClientManager sharedClient].profileUser.groupID withCompletionBlock:^(NSError * error, Group * group) {
        [FlatAPIClientManager sharedClient].group = group;
        NSLog(@"curr lat: %f", [[LocationManager sharedClient] currentLatitude]);
    }];

    return YES;
}

- (void)showInitialView
{
    UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"Main_iPhone"
                                                         bundle:nil];
    NSLog(@"before instantiating root controller");
    self.mainViewController = [storyBoard instantiateViewControllerWithIdentifier:@"RootController"];
    NSLog(@"after instantiating root controller");
    self.mainNavigationViewController = [[MainNavigationViewController alloc] initWithRootViewController:self.mainViewController];
    self.window.rootViewController = self.mainNavigationViewController;
    [self.window makeKeyAndVisible];
}

- (void)showLoginView
{
    NSLog(@"showLoginView");
    UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Main_iPhone"
                                                 bundle:nil];
    self.loginViewController = [sb instantiateViewControllerWithIdentifier:@"OpeningNavigationController"];
    [self.mainViewController.centerPanel presentViewController:self.loginViewController
                                                      animated:NO
                                                    completion:nil];
}

- (void)refreshInitialView
{
    [self.mainViewController.centerPanel viewDidLoad];
}

- (void)handleLogout
{
    // Delete the Profile User from CoreData
    [ProfileUserHelper deleteCurrentProfileFromStore];
    [ProfileUser MR_truncateAll];
    [[FlatAPIClientManager sharedClient] setProfileUser:nil];
    [[FlatAPIClientManager sharedClient] setGroup:nil];
    
    // Clear Facebook Tokens
    [FBSession.activeSession closeAndClearTokenInformation];
    
    // Set loggedIn to NO
    self.loggedIn = NO;
    
    // Show Login View
    [self showLoginView];
}

- (BOOL)application:(UIApplication *)application
            openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication
         annotation:(id)annotation
{
    return [FBSession.activeSession handleOpenURL:url];
}

- (void)sessionStateChanged:(FBSession *)session
                      state:(FBSessionState) state
                      error:(NSError *)error
{
    switch (state) {
        case FBSessionStateOpen: {
            if (!error) {
                NSLog(@"FBSessionStateOpen, No Error");
                self.fbToken = session.accessTokenData.accessToken;
                
                if (self.loggedIn == NO) {
                    [AuthenticationNetworkRequest signinWithFacebook:self.fbToken
                                                  andCompletionBlock:^(NSError *error, ProfileUser *profileUser)
                     {
                         if (!profileUser) {
                             // Create Account via Facebook if user doesnt exist in our db
                             [[FBRequest requestForMe] startWithCompletionHandler:
                              ^(FBRequestConnection *connection,
                                NSDictionary<FBGraphUser> *user,
                                NSError *error) {
                                  
                                  if (!error) {
                                      if (self.fbToken)
                                      {
                                          NSString *firstName = [user objectForKey:@"first_name"];
                                          NSString *lastName = [user objectForKey:@"last_name"];
                                          NSString *emailAddress = [user objectForKey:@"email"];
                                          // Facebook Sign Up
                                          [self.loginViewController handleFacebookSignupWithToken:self.fbToken
                                                                                         andEmail:emailAddress
                                                                                        firstName:firstName
                                                                                      andLastName:lastName];
                                      }
                                  }
                              }];
                         } else {
                             // User already exists. Sign up user
                             [FlatAPIClientManager sharedClient].profileUser = profileUser;
//                             [self.mainViewController.leftPanel handleLogin];
                             [self showInitialView];
                         }
                     }];
                }
                
            } else {
                NSLog(@"Error: FBSessionStateOpen");
            }
            
            break;
        }
        case FBSessionStateClosed:
            NSLog(@"FBSessionStateClosed");
            
            break;
        case FBSessionStateClosedLoginFailed:
            NSLog(@"FBSessionStateClosedLoginFailed");
            
            // Once the user has logged in, we want them to
            // be looking at the root view.
            [self.mainNavigationViewController popToRootViewControllerAnimated:NO];
            
            [FBSession.activeSession closeAndClearTokenInformation];
            
            [self showLoginView];
            break;
        default:
            break;
    }
    
    if (error) {
        UIAlertView *alertView = [[UIAlertView alloc]
                                  initWithTitle:@"Error"
                                  message:error.localizedDescription
                                  delegate:nil
                                  cancelButtonTitle:@"OK"
                                  otherButtonTitles:nil];
        [alertView show];
    }
}

- (void)openFacebookSession
{
    [FBSession openActiveSessionWithReadPermissions:@[@"basic_info", @"email"]
                                       allowLoginUI:YES
                                  completionHandler:^(FBSession *session, FBSessionState state, NSError *error) {
                                      [self sessionStateChanged:session
                                                          state:state
                                                          error:error];
                                  }];
}
							
- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
