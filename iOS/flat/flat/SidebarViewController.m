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

@interface SidebarViewController ()


@end


@implementation SidebarViewController
{
    NSArray *locationArray;
}

static const int STATUS_BAR_HEIGHT = 18;

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
    
    locationArray = [NSArray arrayWithObjects: [NSNumber numberWithInt:1], [NSNumber numberWithInt:0], [NSNumber numberWithInt:1], [NSNumber numberWithInt:2], nil];
    
    self.sideBarMenuTable = [[UITableView alloc] initWithFrame:CGRectMake(0, STATUS_BAR_HEIGHT, self.view.frame.size.width, self.view.frame.size.height - STATUS_BAR_HEIGHT)];
    self.sideBarMenuTable.delegate = self;
    self.sideBarMenuTable.dataSource = self;
    UIColor *backgroundColor = [ProfileUser colorWithHexString: @"394247"];
    [self.view setBackgroundColor:backgroundColor];
    [self.view addSubview:self.sideBarMenuTable];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView
 numberOfRowsInSection:(NSInteger)section
{
    NSMutableArray *users = [[FlatAPIClientManager sharedClient]users];
    return MAX(1, users.count) + 2;
}

- (NSString *)tableView:(UITableView *)tableView
titleForHeaderInSection:(NSInteger)section
{
    if (section == 0) {
        return nil;
    }
    else
    {
        return @"hello";
    }
}

- (BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    HomeViewController * hvc = [[FlatAPIClientManager sharedClient]rootController].centerPanelHome;
    if (indexPath.row == 0) {   //settings
        [self.sideBarMenuTable deselectRowAtIndexPath:indexPath
                                             animated:YES];
        [hvc toggleSidebarMenu:nil];
        [hvc performSegueWithIdentifier:@"HomeToSettings"
                                 sender:self];
    } else if (indexPath.row == 1) {    //tasks
        [self.sideBarMenuTable deselectRowAtIndexPath:indexPath
                                             animated:YES];
        [hvc toggleSidebarMenu:nil];
        [hvc performSegueWithIdentifier:@"HomeToTasks"
                                 sender:self];
    }
    
    else if (indexPath.row - 2 < [[FlatAPIClientManager sharedClient]users].count){
        // show a popup for the selected user
        ProfileUser * user = [[[FlatAPIClientManager sharedClient]users] objectAtIndex:indexPath.row -2];
        NSString * dormStatus = @"has not broadcasted his location recently";
        if ([user.isNearDorm isEqualToNumber2:[NSNumber numberWithInt:IN_DORM_STATUS]]) {
            dormStatus = @"is currently in the dorm";
        }
        else if ([user.isNearDorm isEqualToNumber2:[NSNumber numberWithInt:AWAY_DORM_STATUS]]) {
            dormStatus = @"is away from the dorm right now";
        }
        NSString * text = [NSString stringWithFormat:@"%@ %@.\nEmail: %@", user.firstName, dormStatus, user.email];
        NSString * title = [NSString stringWithFormat:@"%@ %@", user.firstName, user.lastName];
        UIAlertView *alertView = [[UIAlertView alloc]
                                  initWithTitle:title
                                  message:text
                                  delegate:nil
                                  cancelButtonTitle:@"Dismiss"
                                  otherButtonTitles:nil];
        [alertView show];
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
    }
    else {
        NSLog(@"Accessed invalid indexpath. indexpath.row: %ld", (long)indexPath.row);
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSMutableArray * users = [[FlatAPIClientManager sharedClient]users];
    if (indexPath.row == 0 || indexPath.row == 1) {
        return 70;
    }
    if (users.count == 0) return 520;
    return 90;
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *MyIdentifier = @"MyReuseIdentifier";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:MyIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault  reuseIdentifier:MyIdentifier];
    }
    
    NSMutableArray * users = [[FlatAPIClientManager sharedClient]users];
    NSString *hex = @"394247";
    UIColor *backgroundColor = [ProfileUser colorWithHexString:hex];
    NSString *lighterText = @"f2f2f2";
    UIColor *lightTextColor = [ProfileUser colorWithHexString:lighterText];
    NSString *darkerText = @"9a9fa1";
    //UIColor *darkTextColor = [ProfileUser colorWithHexString:darkerText];
    cell.backgroundColor = backgroundColor;
    cell.textLabel.textColor = lightTextColor;
    
    if (indexPath.row == 0)
    {
        cell.textLabel.text = @"Settings";
    }
    else if (indexPath.row == 1)
    {
        cell.textLabel.text = @"Tasks";
    }
    else
    {
        if (users.count == 0)
        {
            [cell.textLabel setText:@"Loading..."];
            return cell;
        }
        [tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
        tableView.backgroundColor = backgroundColor;
        
        ProfileUser * user = [users objectAtIndex: indexPath.row - 2];
        
        UIView *circleView = [[UIView alloc] initWithFrame:CGRectMake(40,15,70,70)];
        circleView.alpha = 1.0;
        circleView.layer.cornerRadius = 35;
        circleView.backgroundColor = [ProfileUser getColorFromUser:user];
        
        NSArray *geoImages = [NSArray arrayWithObjects:@"arrow-hollow-black.png", @"arrow-black.png", @"arrow-empty-small.png", nil];
        UIImageView *locationImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:
                                                                         geoImages[user.isNearDorm.intValue]]];
        locationImage.frame = CGRectMake(4,40,20,20);
        
        UILabel *name = [[UILabel alloc]initWithFrame:CGRectMake(60, 16, 70, 70)];
        name.textColor = [UIColor whiteColor];
        name.font = [UIFont fontWithName:@"courier" size:25];
        
        [cell.contentView addSubview:circleView];
        [cell.contentView addSubview:name];
        [cell.contentView addSubview:locationImage];
        
        NSString *initials  = [NSString stringWithFormat:@"%@%@",
                               [user.firstName substringWithRange:NSMakeRange(0, 1)],
                               [user.lastName substringWithRange:NSMakeRange(0, 1)]];
        name.text = initials;
        
    }
    return cell;
}

- (void)handleLogin
{
    [self.sideBarMenuTable reloadData];
}



- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
