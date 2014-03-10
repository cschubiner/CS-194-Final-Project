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

    locationArray = [NSArray arrayWithObjects: [NSNumber numberWithInt:1], [NSNumber numberWithInt:0], [NSNumber numberWithInt:1], [NSNumber numberWithInt:2], nil];
    
    self.sideBarMenuTable = [[UITableView alloc] initWithFrame:CGRectMake(0, NAV_BAR_HEIGHT, self.view.frame.size.width, self.view.frame.size.height - NAV_BAR_HEIGHT)];
    self.sideBarMenuTable.delegate = self;
    self.sideBarMenuTable.dataSource = self;
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
    if (indexPath.row == 0 || indexPath.row == 1) {
        return YES;
    } else {
        return NO;
    }
}

- (void)tableView:(UITableView *)tableView
didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0) {   //settings
        [self.sideBarMenuTable deselectRowAtIndexPath:indexPath
                                             animated:YES];
        [self performSegueWithIdentifier:@"LeftSidebarToSettings"
                                  sender:self];
    } else if (indexPath.row == 1) {    //tasks
        [self.sideBarMenuTable deselectRowAtIndexPath:indexPath
                                             animated:YES];
        [self performSegueWithIdentifier:@"LeftSidebarToTasks"
                                  sender:self];
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
//    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:MyIdentifier];
//    if (cell == nil) {
//        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault  reuseIdentifier:MyIdentifier];
//    }
    UITableViewCell*  cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault  reuseIdentifier:MyIdentifier];
    
    NSMutableArray * users = [[FlatAPIClientManager sharedClient]users];
    cell.backgroundColor = [UIColor whiteColor];

    if (indexPath.row == 0) {
        cell.textLabel.text = @"Settings";
    } else if (indexPath.row == 1) {
        cell.textLabel.text = @"Tasks";
    } else {
        if (users.count == 0) {
            [cell.textLabel setText:@"Loading..."];
            return cell;
        }
        [tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
        tableView.backgroundColor = [UIColor whiteColor];
        
        ProfileUser * user = [users objectAtIndex: indexPath.row];
        
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
