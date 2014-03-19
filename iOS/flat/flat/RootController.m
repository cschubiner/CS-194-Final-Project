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


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}


-(void)willSwipeToSidePanel {
    [self.centerPanelHome.messageInputView resignFirstResponder];
}



- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setNeedsStatusBarAppearanceUpdate];
    
    //edit for width of the sidebar
    self.leftFixedWidth = self.view.frame.size.width * .43;
    self.rightGapPercentage = 0.0f;
    self.allowRightSwipe = YES;
    self.rightFixedWidth = self.view.frame.size.width * .851;
    
    [self getPersonalCalendarEvents];
    [[FlatAPIClientManager sharedClient]getEveryonesCalendarEvents];
}

bool allowCalendarAccess = false;
-(void)requestCalendarAccess {
    EKEventStore *store = [[EKEventStore alloc] init];
    [store requestAccessToEntityType:EKEntityTypeEvent completion:^(BOOL granted, NSError *error) {
        if (granted) {
            allowCalendarAccess = true;
            [self getCalendarEvents];
        }
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

-(void)getPersonalCalendarEvents {
    if (allowCalendarAccess)
        [self getCalendarEvents];
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [self requestCalendarAccess];
    });
}

-(void)allowUserRefresh{
    allowUserRefresh = true;
}
bool allowUserRefresh = true;
-(void)refreshUsers {
    if (allowUserRefresh == false) return;
    allowUserRefresh = false;
    ProfileUser * currUser = [FlatAPIClientManager sharedClient].profileUser;
    [ProfileUserHelper getUsersFromGroupID:currUser.groupID withCompletionBlock:^(NSError * error, NSMutableArray * users) {
        [[FlatAPIClientManager sharedClient] setUsers:users];
        [self.leftPanel.sideBarMenuTable reloadData];
        [[FlatAPIClientManager sharedClient]getEveryonesCalendarEvents];
        [self.centerPanelHome setNavBarButtons];
    }];
    [NSTimer scheduledTimerWithTimeInterval:5.0 target:self selector:@selector(allowUserRefresh) userInfo:nil repeats:NO];
}

-(void)viewWillAppear:(BOOL)animated {
    
    [NSTimer scheduledTimerWithTimeInterval:3.0 target:self selector:@selector(refreshUsers) userInfo:nil repeats:NO];
    [NSTimer scheduledTimerWithTimeInterval:15.0 target:self selector:@selector(refreshUsers) userInfo:nil repeats:NO];
    [NSTimer scheduledTimerWithTimeInterval:30.0 target:self selector:@selector(refreshUsers) userInfo:nil repeats:YES];
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
    firstDateCom.hour = -24;
    NSDate *firstDate = [calendar dateByAddingComponents:firstDateCom
                                                  toDate:[NSDate date]
                                                 options:0];
    
    // Create the end date components
    NSDateComponents *secondDateCom = [[NSDateComponents alloc] init];
    secondDateCom.day = 5;  //get all events five days from now
    NSDate *secondDate = [calendar dateByAddingComponents:secondDateCom
                                                   toDate:[NSDate date]
                                                  options:0];
    
    // Create the predicate from the event store's instance method
    NSArray * calSearchArray = [NSArray arrayWithObject:store.defaultCalendarForNewEvents]; //search only the default calendar (don't want birthdays appearing)
    NSPredicate *predicate = [store predicateForEventsWithStartDate:firstDate endDate:secondDate calendars:calSearchArray];
    
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
    [fCalUser removeValue]; //delete all calendar events for this user
    
    for (EKEvent* event in events) {
        EventModel* ev = [[EventModel alloc]init];
        [ev setStartDate:[event startDate]];
        [ev setEndDate:[event endDate]];
        [ev setTitle:[event title]];
        [ev setUserID:userID];
        [ev setIsAllDay:[NSNumber numberWithBool:event.isAllDay]];
        
        Firebase* fEvent = [fCalUser childByAutoId];
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

-(void)resetRefreshController {
    HomeViewController *homeViewController = self.centerPanelHome;
    if ([homeViewController.tableViewController.refreshControl isRefreshing]) {
        [homeViewController.tableViewController.refreshControl endRefreshing];
        [homeViewController.tableView setContentInset:UIEdgeInsetsMake(0, 0, 0, 0)];
    }
}

-(void) refreshMessagesWithAnimation:(BOOL)animated scrollToBottom:(BOOL)scrollToBottom{
    if (justRefreshed) {
        [self resetRefreshController];
        return;
    }
    
    HomeViewController *homeViewController = self.centerPanelHome;
    [MessageHelper getMessagesWithCompletionBlock:^(NSError *error, NSMutableArray *messages) {
        NSLog(@"Messages received");
        homeViewController.messages = messages;
        [homeViewController resetTable];
        [self resetRefreshController];
        [homeViewController.tableView reloadData];
        [homeViewController reloadInputViews];
        if (scrollToBottom) {
            [homeViewController scrollToBottomAnimated:animated];
        }
        [[FlatAPIClientManager sharedClient] turnOffLoadingView];
    }];
    
    justRefreshed = true;
    [NSTimer scheduledTimerWithTimeInterval:5.0 target:self selector:@selector(allowMessageRefresh) userInfo:nil repeats:NO];
}


-(void)openSettings {
    [self performSegueWithIdentifier:@"RootToSettingsViewController" sender:self];
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
    self.centerPanelHome = [self.storyboard instantiateViewControllerWithIdentifier:@"HomeViewController"];
	UINavigationController *nc = [[UINavigationController alloc] initWithRootViewController:self.centerPanelHome];
    self.leftPanel.delegate = self;
    self.rightPanel.delegate = self;
    [self setCenterPanel:nc];
    self.centerPanel.delegate = self;
}

@end
