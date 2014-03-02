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

static const int NAV_BAR_HEIGHT = 56;//64;

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
    
    int startingWidth = 60;
    self.sideBarMenuTable = [[UITableView alloc] initWithFrame:CGRectMake(startingWidth, NAV_BAR_HEIGHT, self.view.frame.size.width-startingWidth, self.view.frame.size.height)];
    self.sideBarMenuTable.delegate = self;
    self.sideBarMenuTable.dataSource = self;
    [self.view addSubview:self.sideBarMenuTable];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    [tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    tableView.backgroundColor = [UIColor whiteColor];
    return 1;
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
    return 50;
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *MyIdentifier = @"MyReuseIdentifier";
    UITableViewCell*  cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault  reuseIdentifier:MyIdentifier];
    NSArray * events = [FlatAPIClientManager sharedClient].allEvents;
    
    if (events.count == 0) {
        [cell.textLabel setText:@"Loading..."];
        return cell;
    }
    EventModel* event = [events objectAtIndex:indexPath.row];
    
    
    UIColor * color = [ProfileUser getColorFromUserID:event.userID];
    
    
    cell.backgroundColor = color;
    
    NSString * text = [NSString stringWithFormat:@"%@ has an event from %@ to %@.\n%@",
                              [FlatAPIClientManager sharedClient].profileUser.firstName,
                              event.startDate, event.endDate,
                              event.title];
    [cell.textLabel setText:text];
    return cell;
}

@end
