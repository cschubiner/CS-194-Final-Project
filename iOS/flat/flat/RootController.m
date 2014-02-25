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

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //edit for width of the sidebar
    self.leftFixedWidth = self.view.frame.size.width * .5;
    self.rightGapPercentage = 0.0f;
    self.allowRightSwipe = NO;
    self.allowRightOverpan= NO;
    self.rightFixedWidth = 0;
    
    self.navigationController.navigationBar.hidden = NO;
//    self.navigationController.navigationBar.barTintColor = [UIColor whiteColor];
    self.navigationController.navigationBar.tintColor = [UIColor blackColor]; //sets text color
    self.navigationController.navigationBar.translucent = YES;
    self.navigationController.navigationBar.alpha = .7;
    [[self navigationItem] setTitle:@"Flat"];
    
//    UIBarButtonItem *leftBarButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"menubar"]
//                                                                      style:UIBarButtonItemStylePlain
//                                                                     target:self
//                                                                     action:@selector(toggleSidebarMenu:)];
    UIBarButtonItem* lbb = [[UIBarButtonItem alloc]initWithTitle:@"Settings" style:UIBarButtonItemStyleBordered target:self action:@selector(openSettings)];
    [lbb setTintColor:[UIColor blackColor]];

    
//    self.navigationItem.leftBarButtonItem = leftBarButton;
    self.navigationItem.leftBarButtonItem = lbb;
//    UIBarButtonItem *rightBarButton = [[UIBarButtonItem alloc]
//                               initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh
//                                       target:self
//                                       action:@selector(refreshMessages:)];
//    self.navigationItem.rightBarButtonItem = rightBarButton;
    /*
    self.navigationItem.rightBarButtonItem.tintColor = [UIColor colorWithRed:109.0/255.0
                                                                       green:207.0/255.0
                                                                        blue:246.0/255.0
                                                                       alpha:1.0];
    */
    self.navigationController.toolbarHidden = TRUE;
    
    
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

- (IBAction)refreshMessages:(id)sender
{
    [MessageHelper getMessagesWithCompletionBlock:^(NSError *error, NSArray *messages) {
        NSLog(@"Messages: %@", messages);
        self.centerPanel.messages = [messages mutableCopy];
        [self.centerPanel.tableView reloadData];
    }];
}

- (void)getCalendarEvents {
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
    NSNumber * userID = [[FlatAPIClientManager sharedClient]profileUser].userID;
    
    NSString * eventJSON = @"{\"events\":[";
    if (events == nil || events.count == 0)
        eventJSON = @"{\"events\":[]}";
    for (EKEvent* event in events) {
        EventModel* ev = [[EventModel alloc]init];
        [ev setStartDate:[event startDate]];
        [ev setEndDate:[event endDate]];
        [ev setTitle:[event title]];
        [ev setUserID:userID];
        if (event == events.lastObject)
            eventJSON = [NSString stringWithFormat:@"%@%@]}", eventJSON, [ev toJSONString]]; //don't include comma
        else
            eventJSON = [NSString stringWithFormat:@"%@%@,", eventJSON, [ev toJSONString]];
        
    }
    [ProfileUserNetworkRequest sendCalendarEvents:eventJSON];
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

-(IBAction)toggleSidebarMenu:(id)sender
{
    [self toggleLeftPanel:sender];
}

-(void) awakeFromNib
{
    self.leftPanel = [self.storyboard instantiateViewControllerWithIdentifier:@"SidebarViewController"];
    self.centerPanel = [self.storyboard instantiateViewControllerWithIdentifier:@"HomeViewController"];
    self.leftPanel.delegate = self;
    
    [self setLeftPanel:self.leftPanel];
    [self setCenterPanel:self.centerPanel];
}

@end
