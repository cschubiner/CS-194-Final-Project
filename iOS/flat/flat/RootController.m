//
//  RootController.m
//  flat
//
//  Created by Zachary Palacios on 1/19/14.
//  Copyright (c) 2014 cs194. All rights reserved.
//

#import "RootController.h"
#import <EventKit/EventKit.h>
#import "EventModel.h"
#import "ProfileUserNetworkRequest.h"
#import "HomeViewController.h"
#import "MessageHelper.h"
#import <Firebase/Firebase.h>


@interface RootController ()

@end

@implementation RootController

- (void)toggleSidebarMenu:(id)sender
{
    DLog(@"left menu toggled");
    [self.centerPanel.messageInputView resignFirstResponder];
    [self toggleLeftPanel:sender];
}

- (void)rightButtonPressed:(id)sender
{
    DLog(@"right menu toggled");
    [self.centerPanel.messageInputView resignFirstResponder];
    [self toggleRightPanel:sender];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}


-(void)setNavBarButtons {
    int numUsersHome = [[FlatAPIClientManager sharedClient] getNumUsersHome];
    UIImage* image = [UIImage imageNamed:@"circle-icon.png"];
    CGRect frame = CGRectMake(0, -2, image.size.width + 3 , image.size.height + 3);
    UIButton* someButton = [[UIButton alloc] initWithFrame:frame];
    NSString *numHomeText = [NSString stringWithFormat:@"%d", numUsersHome];
    CGRect labelFrame = CGRectMake(2, 3, image.size.width, image.size.height);
    //UIImage *myGradient = [UIImage imageNamed:@"grad-small.png"];
    [someButton setTitle:numHomeText forState:UIControlStateNormal];
    [someButton.titleLabel setFont:[UIFont fontWithName:@"Courier" size:18.0f]];
    someButton.titleLabel.frame = labelFrame;
    [someButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [someButton setBackgroundImage:image forState:UIControlStateNormal];
    [someButton setShowsTouchWhenHighlighted:YES];
    [someButton addTarget:self
                   action:@selector(toggleSidebarMenu:)
         forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem* someBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:someButton];
    
    
    UIImage* image2 = [UIImage imageNamed:@"calendar-icon.png"];
    CGRect frame2 = CGRectMake(0, 0, image2.size.width, image2.size.height);
    UIButton* someButton2 = [[UIButton alloc] initWithFrame:frame2];
    [someButton2 setBackgroundImage:image2 forState:UIControlStateNormal];
    [someButton2 setShowsTouchWhenHighlighted:YES];
    [someButton2 addTarget:self
                    action:@selector(rightButtonPressed:)
          forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem* someBarButtonItem2 = [[UIBarButtonItem alloc] initWithCustomView:someButton2];
    
    self.navigationItem.leftBarButtonItem = someBarButtonItem;
    self.navigationItem.rightBarButtonItem = someBarButtonItem2;
}

-(void)willSwipeToSidePanel {
    [self.centerPanel.messageInputView resignFirstResponder];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setNeedsStatusBarAppearanceUpdate];
    
    //    [self.navigationController setNavigationBarHidden:YES animated:YES];
    
    //edit for width of the sidebar
    self.leftFixedWidth = self.view.frame.size.width * .5 * .9;
    self.rightGapPercentage = 0.0f;
    self.allowRightSwipe = YES;
    self.rightFixedWidth = self.view.frame.size.width * .85;
    
    //[self.navigationController setNavigationBarHidden:YES];
    
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor]; //sets text color
    self.navigationController.navigationBar.barTintColor = [UIColor blackColor];
    self.navigationController.navigationBar.translucent = YES;
    self.navigationController.navigationBar.alpha = .01;
 
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor whiteColor]}];
    UIImage *myGradient = [UIImage imageNamed:@"grad-small.png"];
    [[self navigationItem] setTitle:@"Flat"];
    [self.navigationController.navigationBar setTitleTextAttributes:
     @{ NSFontAttributeName: [UIFont fontWithName:@"HelveticaNeue-Light" size:22.0f], NSForegroundColorAttributeName: [UIColor colorWithPatternImage:myGradient]}];

    [self setNavBarButtons];
}

-(void)requestCalendarAccess {
    EKEventStore *store = [[EKEventStore alloc] init];
    [store requestAccessToEntityType:EKEntityTypeEvent completion:^(BOOL granted, NSError *error) {
        if (granted)
            [self getCalendarEvents];
        else {
            UIAlertView *alertView = [[UIAlertView alloc]
                                      initWithTitle:@"Error accessing calendar"
                                      message:@"We need to see your events so that we can share your schedule with your flatmates. Please enable calendar access for Flat in the Settings app."
                                      delegate:nil
                                      cancelButtonTitle:@"Dismiss"
                                      otherButtonTitles:nil];
            [alertView show];
        }
    }];
}

-(void)refreshUsers {
    ProfileUser * currUser = [FlatAPIClientManager sharedClient].profileUser;
    [ProfileUserHelper getUsersFromGroupID:currUser.groupID withCompletionBlock:^(NSError * error, NSMutableArray * users) {
        [[FlatAPIClientManager sharedClient] setUsers:users];
        [self.leftPanel.sideBarMenuTable reloadData];
        
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            [self requestCalendarAccess];
        });
        
    }];
}

-(void)refreshEvents {
    [[FlatAPIClientManager sharedClient]getAllCalendarEvents:^(){
        [self.rightPanel.sideBarMenuTable reloadData];
    }];
}

-(void)refreshStuff {
    [self refreshUsers];
    [self refreshEvents];
    [self setNavBarButtons];
}

-(void)viewWillAppear:(BOOL)animated {
    
    [NSTimer scheduledTimerWithTimeInterval:3.0 target:self selector:@selector(refreshStuff) userInfo:nil repeats:NO];
    [NSTimer scheduledTimerWithTimeInterval:15.0 target:self selector:@selector(refreshStuff) userInfo:nil repeats:NO];
    [NSTimer scheduledTimerWithTimeInterval:30.0 target:self selector:@selector(refreshStuff) userInfo:nil repeats:YES];
}

- (IBAction)refreshMessages:(id)sender
{
    [self refreshMessagesWithAnimation:YES scrollToBottom:YES];
}


-(void)getCalendarEventsForDays {
    EKEventStore *store = [[EKEventStore alloc] init];
    NSCalendar *calendar = [NSCalendar currentCalendar];
    
    // Create the start date components
    NSDateComponents *firstDateCom = [[NSDateComponents alloc] init];
    firstDateCom.hour = -1;
    NSDate *firstDate = [calendar dateByAddingComponents:firstDateCom
                                                  toDate:[NSDate date]
                                                 options:0];
    
    // Create the end date components
    NSDateComponents *secondDateCom = [[NSDateComponents alloc] init];
    secondDateCom.day = 5;  //get all events five days from now
    //    secondDateCom.hour = 24;
    NSDate *secondDate = [calendar dateByAddingComponents:secondDateCom
                                                   toDate:[NSDate date]
                                                  options:0];
    
    // Create the predicate from the event store's instance method
    NSArray * calSearchArray = [NSArray arrayWithObject:store.defaultCalendarForNewEvents]; //search only the default calendar (don't want birthdays appearing)
    NSPredicate *predicate = [store predicateForEventsWithStartDate:firstDate
                                                            endDate:secondDate
                                                          calendars:calSearchArray];
    
    // Fetch all events that match the predicate
    NSArray *events = [store eventsMatchingPredicate:predicate];
    [[FlatAPIClientManager sharedClient]setEvents:[NSMutableArray arrayWithArray:events]];
}


- (void)getCalendarEvents {
    [self getCalendarEventsForDays];
    NSArray *events = [FlatAPIClientManager sharedClient].events;
    NSNumber * userID = [[FlatAPIClientManager sharedClient]profileUser].userID;
    
    Firebase* fCal = [[Firebase alloc] initWithUrl:@"https://flatapp.firebaseio.com/calendars"];
    
    
    Firebase* fCalUser = [fCal childByAppendingPath:[NSString stringWithFormat:@"%@",userID]];
    [fCalUser setValue:nil]; //delete all calendar events for this user
    
    
    NSMutableArray * allEventArray = [[NSMutableArray alloc]init];
    for (EKEvent* event in events) {
        EventModel* ev = [[EventModel alloc]init];
        [ev setStartDate:[event startDate]];
        [ev setEndDate:[event endDate]];
        [ev setTitle:[event title]];
        [ev setUserID:userID];
        [ev setIsAllDay:[NSNumber numberWithBool:event.isAllDay]];
        [allEventArray addObject:ev];
        
        Firebase* fEvent = [fCalUser childByAppendingPath:[NSString stringWithFormat:@"%@", event.startDate]];
        [[fEvent childByAppendingPath:@"startDate"] setValue:[NSString stringWithFormat:@"%@", event.startDate]];
        [[fEvent childByAppendingPath:@"endDate"] setValue:[NSString stringWithFormat:@"%@", event.endDate]];
        [[fEvent childByAppendingPath:@"userID"] setValue:[NSString stringWithFormat:@"%@", userID]];
        [[fEvent childByAppendingPath:@"title"] setValue:event.title];
        [[fEvent childByAppendingPath:@"isAllDay"] setValue:ev.isAllDay];
    }
}

static bool justRefreshed = false;

-(void) allowMessageRefresh {
    justRefreshed = false;
}

-(void) refreshMessagesWithAnimation:(BOOL)animated scrollToBottom:(BOOL)scrollToBottom{
    if (justRefreshed) return;
    
    HomeViewController *homeViewController = self.centerPanel;
    //    homeViewController.messages = nil;
    //    [homeViewController.tableView reloadData];
    [MessageHelper getMessagesWithCompletionBlock:^(NSError *error, NSMutableArray *messages) {
        //        
        homeViewController.messages = messages;
//                [homeViewController viewDidLoad];
        [homeViewController resetTable];

        [homeViewController.tableView reloadData];
        [homeViewController reloadInputViews];
        if (scrollToBottom)
            [homeViewController scrollToBottomAnimated:animated];
        [[FlatAPIClientManager sharedClient]turnOffLoadingView];
        //        
    }];
    
    justRefreshed = true;
    [NSTimer scheduledTimerWithTimeInterval:5.0
                                     target:self
                                   selector:@selector(allowMessageRefresh)
                                   userInfo:nil
                                    repeats:NO];
}


-(void)openSettings {
    [self performSegueWithIdentifier:@"RootToSettingsViewController" sender:self];
}

- (void)viewDidAppear:(BOOL)animated
{
    
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    return YES;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)stylePanel:(UIView *)panel
{
    panel.layer.cornerRadius = 0.0f;
    panel.clipsToBounds = YES;
}

-(void)awakeFromNib
{
    self.leftPanel = [self.storyboard instantiateViewControllerWithIdentifier:@"SidebarViewController"];
    self.rightPanel = [self.storyboard instantiateViewControllerWithIdentifier:@"CalendarViewController"];
    self.centerPanel = [self.storyboard instantiateViewControllerWithIdentifier:@"HomeViewController"];
    self.leftPanel.delegate = self;
    self.rightPanel.delegate = self;
    
    [self setLeftPanel:self.leftPanel];
    [self setRightPanel:self.rightPanel];
    [self setCenterPanel:self.centerPanel];
    
}

@end
