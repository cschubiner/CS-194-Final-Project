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
#import "GroupLocalRequest.h"
#import "HomeViewController.h"
#import "MessageHelper.h"

@implementation cs194AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    //Magical Record
    [MagicalRecord setupCoreDataStack];
    UIPageControl *pageControl = [UIPageControl appearance];
    pageControl.pageIndicatorTintColor = [UIColor lightGrayColor];
    pageControl.currentPageIndicatorTintColor = [UIColor blackColor];
    pageControl.backgroundColor = [UIColor whiteColor];
    
    // code to let kyle log in cuz of his messed up privacy settings. don't delete or uncomment.
    //        ProfileUser *kyleUser = [ProfileUser MR_createInContext:[NSManagedObjectContext MR_defaultContext]];
    //        kyleUser.userID =  [NSNumber numberWithLong:100002378870303];
    //        kyleUser.groupID = [NSNumber numberWithInt:1];
    //       kyleUser.colorID =  [NSNumber numberWithInt:1];
    //        kyleUser.firstName = @"Kyle";
    //        kyleUser.lastName = @"Archie";
    //        kyleUser.email = @"kyleaarchie@gmail.com";
    //        kyleUser.isNearDorm = [NSNumber numberWithInt:1];
    //        [[FlatAPIClientManager sharedClient] setProfileUser:kyleUser];
    
    // Check if user is logged in
    ProfileUser *profileUser = [ProfileUserHelper getProfileUser];
    
    [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreAndWait];
    
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
    
    [GroupNetworkRequest getGroupFromGroupID:[FlatAPIClientManager sharedClient].profileUser.groupID withCompletionBlock:^(NSError * error, Group * group1) {
        if (group1 == nil)
            group1 = [GroupLocalRequest getGroup];
        [FlatAPIClientManager sharedClient].group = group1;
        [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreAndWait];
        //kickstart location
        [[LocationManager sharedClient] setShouldSetDormLocation:false];
    }];
    
    
    [[UIApplication sharedApplication] registerForRemoteNotificationTypes:
     (UIRemoteNotificationTypeSound | UIRemoteNotificationTypeAlert)];
    
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
                             [ProfileUserHelper getUsersFromGroupID:profileUser.groupID
                                                withCompletionBlock:^(NSError * error, NSMutableArray * users) {
                                                    [FlatAPIClientManager sharedClient].profileUser = profileUser;
                                                    [FlatAPIClientManager sharedClient].users = users;
                                                    [self showInitialView];
                                                }];
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
        {
            NSLog(@"FBSessionStateClosedLoginFailed");
            
            // Once the user has logged in, we want them to
            // be looking at the root view.
            
            /*
             [self.mainNavigationViewController popToRootViewControllerAnimated:NO];
             
             [FBSession.activeSession closeAndClearTokenInformation];
             
             [self showLoginView];*/
            
            // Hacky code to let kyle log in -----------------------------------------
            /* ProfileUser * kyle = [[ProfileUser alloc]init];
             ProfileUser *profileUser;
             profileUser = [ProfileUser getProfileUserObjectFromDictionary:userJSON
             AndManagedObjectContext:[NSManagedObjectContext MR_defaultContext]];
             
             [kyle setFirstName:@"Kyle"];
             kyle.lastName = @"Archie";
             kyle.userID = [NSNumber numberWithInt:100002378870303];
             kyle.groupID = [NSNumber numberWithInt:19];
             kyle.isNearDorm = [NSNumber numberWithBool:true];*/
            //  [FlatAPIClientManager sharedClient].profileUser = kyle;
            [self showInitialView];
            
            // delete the above section at some point --------------------------------
        }
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

-(void)showFBLogin
{
    [FBSession openActiveSessionWithPublishPermissions:@[@"basic_info", @"email"] defaultAudience:FBSessionDefaultAudienceFriends allowLoginUI:YES
                                     completionHandler:^(FBSession *session, FBSessionState state, NSError *error) {
                                         if (error) {
                                             [FBSession.activeSession closeAndClearTokenInformation];
                                             [self openFacebookSession];
                                         }
                                         [self sessionStateChanged:session
                                                             state:state
                                                             error:error];
                                     }];
}

- (void)openFacebookSession
{
//    [self showFBLogin];
//    return;
    [FBSession openActiveSessionWithReadPermissions:@[@"basic_info", @"email"]
                                       allowLoginUI:YES
                                  completionHandler:^(FBSession *session, FBSessionState state, NSError *error) {
                                      if (error) {
                                          [FBSession.activeSession closeAndClearTokenInformation];
//                                          [self openFacebookSession];
                                      }
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

- (void)application:(UIApplication*)application didReceiveRemoteNotification:(NSDictionary*)userInfo
{
    RootController *mainViewController = self.mainViewController;
    HomeViewController *homeViewController = mainViewController.centerPanel;
    [MessageHelper getMessagesWithCompletionBlock:^(NSError *error, NSArray *messages) {
        if ([messages count] != [homeViewController.messages count]) {
            [JSMessageSoundEffect playMessageReceivedAlert];
        }
        homeViewController.messages = [messages mutableCopy];
        [homeViewController.tableView reloadData];
        [homeViewController scrollToBottomAnimated:YES];
    }];
}

- (void)application:(UIApplication*)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData*)deviceToken
{
    const unsigned *tokenBytes = [deviceToken bytes];
    NSString *hexToken = [NSString stringWithFormat:@"%08x%08x%08x%08x%08x%08x%08x%08x",
                          ntohl(tokenBytes[0]), ntohl(tokenBytes[1]), ntohl(tokenBytes[2]),
                          ntohl(tokenBytes[3]), ntohl(tokenBytes[4]), ntohl(tokenBytes[5]),
                          ntohl(tokenBytes[6]), ntohl(tokenBytes[7])];
    [FlatAPIClientManager sharedClient].deviceToken = hexToken;
}

- (void)application:(UIApplication*)application didFailToRegisterForRemoteNotificationsWithError:(NSError*)error
{
	NSLog(@"Failed to get token, error: %@", error);
}

@end
