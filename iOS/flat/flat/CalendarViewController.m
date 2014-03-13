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
    NSArray * events = [FlatAPIClientManager sharedClient].allEvents;
    int days = 0;
    NSDate* lastDate = nil;
    
    for (EventModel * ev in events) {
        if (![ev.startDate isEqualToDateIgnoringTime:lastDate])
            days++;
        lastDate = ev.startDate;
    }
    return days;
}

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    NSArray * events = [FlatAPIClientManager sharedClient].allEvents;
    int days = 0;
    NSDate* lastDate = nil;
    
    for (EventModel * ev in events) {
        if (![ev.startDate isEqualToDateIgnoringTime:lastDate])
            days++;
        
        if (days - 1 == section) {
            return [NSString stringWithFormat:@"%@'s Events",[ev.startDate nameOfDay]];
        }
        lastDate = ev.startDate;
    }
    
    return @"Other Events";
}

- (NSInteger)tableView:(UITableView *)tableView
 numberOfRowsInSection:(NSInteger)section
{
    NSArray * events = [FlatAPIClientManager sharedClient].allEvents;
    if (events.count == 0) return 1;
    
    int days = 0;
    NSDate* lastDate = nil;
    int count = 0;
    
    for (EventModel * ev in events) {
        if (![ev.startDate isEqualToDateIgnoringTime:lastDate])
            days++;
        
        if (days - 1 == section) {
            count++;
        }
        else if (days - 1 > section)
            return count;
        lastDate = ev.startDate;
    }
    return count;
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
    int days = 0;
    NSDate* lastDate = nil;
    int count = 0;
    int allCount = 0;
    EventModel* event = nil;
    
    for (EventModel * ev in events) {
        if (![ev.startDate isEqualToDateIgnoringTime:lastDate])
            days++;
        
        if (days - 1 == indexPath.section) {
            if (count == indexPath.row)
                break;
            count++;
        }
        else if (days - 1 > indexPath.section)
            break;
        lastDate = ev.startDate;
        allCount ++;
    }
    
    
    if (events.count == 0) {
        [cell.textLabel setText:@"Loading..."];
        return cell;
    }
     event = [events objectAtIndex:allCount];
    
    UIColor * color = [ProfileUser getColorFromUserID:event.userID];
    cell.backgroundColor = color;
    NSString * text;
    if ([[NSNumber numberWithBool:true] isEqualToNumber2:event.isAllDay]) {
        text = [NSString stringWithFormat:@"%@: %@\nAll day",
                [ProfileUser getFirstNameFromUserID:event.userID],
                event.title
                ];
    }
    else {
        text = [NSString stringWithFormat:@"%@: %@\n%@ to %@",
                [ProfileUser getFirstNameFromUserID:event.userID],
                event.title,
                [Utils formatDate:event.startDate], [Utils formatDate:event.endDate]
                ];
    }
    [cell.textLabel setText:text];
    cell.textLabel.numberOfLines = 0;
    [cell sizeToFit];
    return cell;
}

@end
