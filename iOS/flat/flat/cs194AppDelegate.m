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
#import <EventKit/EventKit.h>
#import "MessageHelper.h"
#import "Reachability.h"

@implementation cs194AppDelegate

Reachability * internetReachable;


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    //Magical Record
    [MagicalRecord setupCoreDataStack];
    UIPageControl *pageControl = [UIPageControl appearance];
    pageControl.pageIndicatorTintColor = [UIColor lightGrayColor];
    pageControl.currentPageIndicatorTintColor = [UIColor blackColor];
    pageControl.backgroundColor = [UIColor whiteColor];
    
    
    
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
        DLog(@"Not Logged in, show Login screen");
        [self showInitialView];
        DLog(@"Show initial view already called");
        [self showLoginView];
    }
    
    [[UIApplication sharedApplication] registerForRemoteNotificationTypes:
     (UIRemoteNotificationTypeSound | UIRemoteNotificationTypeAlert)];
    
    //    [NSTimer scheduledTimerWithTimeInterval:280.0 target:self selector:@selector(checkForCalendarEvent) userInfo:nil repeats:YES];
    
    [self testInternetConnection];
    
    return YES;
}

- (void)testInternetConnection
{
    internetReachable = [Reachability reachabilityWithHostname:@"www.google.com"];
    // Internet is reachable
    internetReachable.reachableBlock = ^(Reachability*reach)
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            DLog(@"We are connected to the internet.");
        });
    };
    // Internet is not reachable
    internetReachable.unreachableBlock = ^(Reachability*reach)
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            DLog(@"Uh oh, we are not connected to the internet.");
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"No internet access" message:@"You need internet access to enjoy Flat. Please check your internet connection." delegate:self cancelButtonTitle:@"Dismiss" otherButtonTitles:nil];
            [alertView show];
        });
    };
    [ internetReachable startNotifier];
}



- (void)showInitialView
{
    UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"Main_iPhone"
                                                         bundle:nil];
    DLog(@"before instantiating root controller");
    self.mainViewController = [storyBoard instantiateViewControllerWithIdentifier:@"RootController"];
    [[FlatAPIClientManager sharedClient] setRootController:self.mainViewController];
    DLog(@"after instantiating root controller");
    //    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.rootViewController = self.mainViewController;
    [self.window makeKeyAndVisible];
}

- (void)showLoginView
{
    DLog(@"showLoginView");
    UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Main_iPhone"
                                                 bundle:nil];
    self.loginViewController = [sb instantiateViewControllerWithIdentifier:@"OpeningNavigationController"];
    [self.mainViewController.centerPanel presentViewController:self.loginViewController
                                                      animated:NO
                                                    completion:nil];
}

- (void)refreshInitialView
{
    [self.mainViewController.centerPanelHome viewDidLoad];
}

- (void)handleLogout
{
    // Delete the Profile User from CoreData
    [ProfileUserHelper deleteCurrentProfileFromStore];
    [ProfileUser MR_truncateAll];
    [[FlatAPIClientManager sharedClient] setProfileUser:nil];
    
    [Group deleteCurrentGroupFromStore];
    [Group MR_truncateAll];
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
                DLog(@"FBSessionStateOpen, No Error");
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
                DLog(@"Error: FBSessionStateOpen");
            }
            
            break;
        }
        case FBSessionStateClosed:
            DLog(@"FBSessionStateClosed");
            
            break;
        case FBSessionStateClosedLoginFailed:
        {
            DLog(@"FBSessionStateClosedLoginFailed");
            
            // Once the user has logged in, we want them to
            // be looking at the root view.
            
            /*
             ///////[self.mainNavigationViewController popToRootViewControllerAnimated:NO];
             
             [FBSession.activeSession closeAndClearTokenInformation];
             
             [self showLoginView];*/
            
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

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    UIApplication *app = [UIApplication sharedApplication];
    
    //create new uiBackgroundTask
    __block UIBackgroundTaskIdentifier bgTask = [app beginBackgroundTaskWithExpirationHandler:^{
        [app endBackgroundTask:bgTask];
        bgTask = UIBackgroundTaskInvalid;
    }];
    
    //and create new timer with async call:
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        int checkEvery = 290; //almost every 5 minutes
        NSTimer* t = [NSTimer scheduledTimerWithTimeInterval:checkEvery target:self selector:@selector(backgroundTask) userInfo:nil repeats:YES];
        [[NSRunLoop currentRunLoop] addTimer:t forMode:NSDefaultRunLoopMode];
        [[NSRunLoop currentRunLoop] run];
    });
}

-(void)backgroundTask {
    [self checkForCalendarEvent];
    [self refreshGroupAndLocation];
}

-(void)checkForCalendarEvent {
    DLog(@"start of calendar event checking");
    NSCalendar* calendar = [[NSCalendar alloc] initWithCalendarIdentifier: NSGregorianCalendar];
    NSDateComponents* components = [[NSDateComponents alloc] init];
    components.minute = 5;
    NSDate* fiveMinutesFromNow = [calendar dateByAddingComponents: components toDate: [NSDate date] options: 0];
    
    NSMutableIndexSet *discardedItems = [NSMutableIndexSet indexSet];
    NSUInteger index = 0;
    [[[FlatAPIClientManager sharedClient]rootController]getCalendarEventsForDays];
    NSMutableArray * events = [FlatAPIClientManager sharedClient].events;
    if (events == nil) return;
    for (EKEvent* event in events) {
        NSComparisonResult result = [fiveMinutesFromNow compare:event.startDate];
        NSComparisonResult resultNow = [[NSDate date] compare:event.startDate];
        if ((result == NSOrderedSame || result == NSOrderedDescending) &&
            (resultNow == NSOrderedSame || resultNow == NSOrderedAscending)) { //if event occurs within next five minutes
            [MessageHelper sendCalendarMessageForEvent:event];
            [discardedItems addIndex:index];
        }
        index++;
    }
    
    [events removeObjectsAtIndexes:discardedItems];
    DLog(@"end calendar event checking");
    
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

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

-(void) refreshGroupAndLocation {
    [GroupNetworkRequest getGroupFromGroupID:[FlatAPIClientManager sharedClient].profileUser.groupID withCompletionBlock:^(NSError * error, Group * group1) {
        if (group1 == nil)
            group1 = [GroupLocalRequest getGroup];
        [FlatAPIClientManager sharedClient].group = group1;
        [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreAndWait];
        //kickstart location
        CLLocationManager * manager = [[LocationManager sharedClient] locationManager];
        [manager stopMonitoringForRegion:manager.monitoredRegions.anyObject];
        [manager startMonitoringForRegion:[[LocationManager sharedClient] getGroupLocationRegion]];
        [[LocationManager sharedClient] setShouldSetDormLocation:false];
    }];
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    static bool firstTime = true;
    [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
    if (firstTime) {
        firstTime = false;
        return;
    }
    if (self.mainViewController != nil && [[FlatAPIClientManager sharedClient]profileUser] != nil) {
        [self refreshGroupAndLocation];
        [self.mainViewController refreshMessagesWithAnimation:NO scrollToBottom:YES];
        [self.mainViewController getPersonalCalendarEvents];
        [[FlatAPIClientManager sharedClient]getEveryonesCalendarEvents];
    }
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

- (void)application:(UIApplication*)application didReceiveRemoteNotification:(NSDictionary*)userInfo
{
    [self.mainViewController refreshMessagesWithAnimation:NO scrollToBottom:NO];
    [UIApplication sharedApplication].applicationIconBadgeNumber++;
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
