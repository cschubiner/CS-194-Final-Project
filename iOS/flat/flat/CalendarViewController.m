//
//  SidebarViewController.m
//  flat
//
//  Created by Zachary Palacios on 1/19/14.
//  Copyright (c) 2014 cs194. All rights reserved.
//

#import "SidebarViewController.h"
#import "cs194AppDelegate.h"
#import "GroupTableViewController.h"
#import "CalendarViewController.h"
#import "EventModel.h"

@interface CalendarViewController ()


@end


@implementation CalendarViewController
{
}

static const int NAV_BAR_HEIGHT = 64;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    
    return self;
}

-(void)refreshEvents {
    [[FlatAPIClientManager sharedClient]getAllCalendarEvents:^(){
        [self.sideBarMenuTable reloadData];
    }];
}

-(void)viewWillAppear:(BOOL)animated {
    [NSTimer scheduledTimerWithTimeInterval:4.0 target:self selector:@selector(refreshEvents) userInfo:nil repeats:NO];
    [NSTimer scheduledTimerWithTimeInterval:15.0 target:self selector:@selector(refreshEvents) userInfo:nil repeats:NO];
    [NSTimer scheduledTimerWithTimeInterval:30.0 target:self selector:@selector(refreshEvents) userInfo:nil repeats:YES];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    int startingWidth = 47;
    self.sideBarMenuTable = [[UITableView alloc] initWithFrame:CGRectMake(startingWidth, NAV_BAR_HEIGHT, self.view.frame.size.width-startingWidth, self.view.frame.size.height - NAV_BAR_HEIGHT)];
    self.sideBarMenuTable.delegate = self;
    self.sideBarMenuTable.dataSource = self;
    [self.view addSubview:self.sideBarMenuTable];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
//    [tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    tableView.backgroundColor = [UIColor whiteColor];
    return 1;
}

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return @"Upcoming Events";
}

- (NSInteger)tableView:(UITableView *)tableView
 numberOfRowsInSection:(NSInteger)section
{
    NSArray * events = [FlatAPIClientManager sharedClient].allEvents;
    return MAX(1, events.count);
}

-(BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath {
    return NO;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSArray * events = [FlatAPIClientManager sharedClient].allEvents;
    if (events.count == 0) return 520;
    return 70;
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *MyIdentifier = @"MyReuseIdentifier5";
    UITableViewCell*  cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault  reuseIdentifier:MyIdentifier];
    NSArray * events = [FlatAPIClientManager sharedClient].allEvents;
    
    if (events.count == 0) {
        [cell.textLabel setText:@"Loading..."];
        return cell;
    }
    EventModel* event = [events objectAtIndex:indexPath.row];
    
    
    UIColor * color = [ProfileUser getColorFromUserID:event.userID];
    cell.backgroundColor = color;
    
    NSString * text = [NSString stringWithFormat:@"%@: %@\n%@ from %@ to %@",
                              [ProfileUser getFirstNameFromUserID:event.userID],
                              event.title,
                              [Utils formatDateDayOfWeek:event.startDate],
                              [Utils formatDate:event.startDate], [Utils formatDate:event.endDate]
                              ];
    [cell.textLabel setText:text];
    cell.textLabel.numberOfLines = 0;
    [cell sizeToFit];
    return cell;
}

@end
