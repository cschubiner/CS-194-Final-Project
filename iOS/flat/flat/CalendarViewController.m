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


@implementation CalendarViewController {}


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
    self.sideBarMenuTable = [[UITableView alloc] initWithFrame:CGRectMake(startingWidth, STATUS_BAR_HEIGHT, self.view.frame.size.width-startingWidth, self.view.frame.size.height - STATUS_BAR_HEIGHT)];
    UIColor *backgroundColor = [ProfileUser colorWithHexString: @"394247"];
    [self.view setBackgroundColor:backgroundColor];
    self.sideBarMenuTable.backgroundColor = backgroundColor;
    [self.view addSubview:self.sideBarMenuTable];
    self.sideBarMenuTable.delegate = self;
    self.sideBarMenuTable.dataSource = self;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
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
            if ([ev.startDate isToday]) return @"Today's events";
            if ([ev.startDate isTomorrow]) return @"Tomorrow's events";
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
    return 75;
}


-(bool)eventIsOccuringNow:(EventModel*)event {
    if (event == nil || [[NSNull null]isEqual:event]) return false;
    return [event.startDate isInPast] && [event.endDate isInFuture];
}

-(int)numberOfEventsOccurringNow {
    NSArray * events = [FlatAPIClientManager sharedClient].allEvents;
    int count = 0;
    for (EventModel * ev in events) {
        if ([[NSNull null]isEqual:ev]) continue;
        if ([self eventIsOccuringNow:ev] && [ev.isAllDay isEqualToNumberWithNullCheck:[NSNumber numberWithBool:false]])
            count++;
    }
    NSLog(@"there are currently %d user(s) busy.", count);
    return count;
}

-(UILabel*)getTitleTextLabel:(UITableViewCell*)cell color:(UIColor*)color titleText:(NSString*)titleString {
    UILabel *titleText = [[UILabel alloc]initWithFrame:CGRectMake(20, -5, cell.frame.size.width, cell.frame.size.height)];
    titleText.textColor = color;
    NSString * fontName = @"HelveticaNeue-Light";
    CGFloat fontSize = 17;
    titleText.font = [UIFont fontWithName:fontName size:fontSize];
    titleText.text = titleString;
    CGFloat width = [Utils getSizeOfFont:titleText.font withText:titleString withLabel:titleText].size.width;
    
    if (width > 249) fontSize = 15.0f;
    if (width > 286) fontSize = 14.0f;
    titleText.font = [UIFont fontWithName:fontName size:fontSize];
    width = [Utils getSizeOfFont:titleText.font withText:titleString withLabel:titleText].size.width;
    while (width > 249) {
        titleText.text = [titleText.text substringToIndex:titleText.text.length-2];
        titleString = [NSString stringWithFormat:@"%@...", titleText.text];
        width = [Utils getSizeOfFont:titleText.font withText:titleString withLabel:titleText].size.width;
    }
    titleText.text = titleString;
    return titleText;
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
    
    NSString *lighterText = @"f2f2f2";
    UIColor *lightTextColor = [ProfileUser colorWithHexString:lighterText];
    NSString *darkerText = @"9a9fa1";
    UIColor *darkTextColor = [ProfileUser colorWithHexString:darkerText];
    
    tableView.separatorColor = darkTextColor;
    
    if (events.count == 0) {
        [cell.textLabel setText:@"Loading..."];
        return cell;
    }
    event = [events objectAtIndex:allCount];
    if ([[NSNull null]isEqual:event]) {
        DLog(@"event is null :(");
    }
    BOOL eventIsOccurringNow = [self eventIsOccuringNow:event];
    
    NSString *hex = @"394247";
    UIColor *backgroundColor = [ProfileUser colorWithHexString:hex];
    NSString *otherHex = @"272e31";
    UIColor *highlightColor = [ProfileUser colorWithHexString:otherHex];
    
    cell.textLabel.textColor = lightTextColor;
    
    [tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    tableView.backgroundColor = backgroundColor;
    cell.backgroundColor = backgroundColor;
    
    UIColor * color = [ProfileUser getColorFromUserID:event.userID];
    
    UILabel * titleText = [self getTitleTextLabel:cell color:lightTextColor titleText:event.title];
    
    UILabel *timeText = [[UILabel alloc]initWithFrame:CGRectMake(20, 15, cell.frame.size.width, cell.frame.size.height)];
    timeText.textColor = darkTextColor;
    timeText.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:14];
    timeText.text = [NSString stringWithFormat:@"%@ - %@", [Utils formatDate:event.startDate], [Utils formatDate:event.endDate]];
    
    if ([[NSNumber numberWithBool:true] isEqualToNumberWithNullCheck:event.isAllDay]) {
        timeText.text = @"All day";
    }
    
    UILabel *userText = [[UILabel alloc]initWithFrame:CGRectMake(20, 35, cell.frame.size.width, cell.frame.size.height)];
    userText.textColor = color;
    userText.alpha = .8;
    userText.font = [UIFont fontWithName:@"HelveticaNeue" size:14];
    userText.text = [NSString stringWithFormat:@"%@ %@", [ProfileUser getFirstNameFromUserID:event.userID], [ProfileUser getLastNameFromUserID:event.userID]];
    
    
    UIView *barView = [[UIView alloc] initWithFrame:CGRectMake(0, 10, 6, cell.frame.size.height + 15)];
    barView.alpha = 1.0;
    barView.backgroundColor = color;
    
    if (eventIsOccurringNow)
    {
        cell.backgroundColor = highlightColor;
    }
    
    [cell.contentView addSubview:titleText];
    [cell.contentView addSubview:timeText];
    [cell.contentView addSubview:userText];
    [cell.contentView addSubview:barView];
    cell.textLabel.numberOfLines = 0;
    [cell sizeToFit];
    return cell;
}

@end
