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

@property NSMutableArray * users;

@end

@implementation SidebarViewController

static const int NAV_BAR_HEIGHT = 64;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}


-(void)viewWillAppear:(BOOL)animated {
    ProfileUser * currUser = [FlatAPIClientManager sharedClient].profileUser;
    [ProfileUserHelper getUsersFromGroupID:currUser.groupID withCompletionBlock:^(NSError * error, NSMutableArray * users) {
        self.users = users;
        [self.sideBarMenuTable reloadData];
    }];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.sideBarMenuTable = [[UITableView alloc] initWithFrame:CGRectMake(0, NAV_BAR_HEIGHT, self.view.frame.size.width, self.view.frame.size.height)];
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
    return self.users.count + 3;
}


- (NSString *)tableView:(UITableView *)tableView
titleForHeaderInSection:(NSInteger)section
{
    return @"Roommates";
}

- (void)handleLogout
{
    NSLog(@"handleLogout");
    
    [self.delegate toggleSidebarMenu:nil];
    
    cs194AppDelegate *delegate = [UIApplication sharedApplication].delegate;
    [delegate handleLogout];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == [self.users count] + 1) {
        NSString *logoutTitle = @"Do you really want to logout?";
        UIActionSheet *logoutActionSheet = [[UIActionSheet alloc]
                                            initWithTitle:logoutTitle
                                            delegate:self
                                            cancelButtonTitle:@"Cancel"
                                            destructiveButtonTitle:@"Log Out"
                                            otherButtonTitles:nil];
        [logoutActionSheet showInView:self.view];
        [tableView deselectRowAtIndexPath:indexPath
                                 animated:YES];
    } else if (indexPath.row == [self.users count]) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle: @"Set dorm location"
                                                        message: @"Do you want to set your current location as your group's dorm location?"
                                                       delegate: self
                                              cancelButtonTitle:@"Cancel"
                                              otherButtonTitles:@"Set Location", nil];
        [alert setTag:0];
        [alert show];
    }
    else if (indexPath.row == [self.users count] + 2) {
        [self performSegueWithIdentifier:@"SidebarToGroupTableView"
                                  sender:self];
//        GroupTableViewController * groupTableVC = [[GroupTableViewController alloc] init];
//        [self presentViewController:groupTableVC animated:YES completion:nil];
        
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue
                 sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"SidebarToGroupTableView"]) {
        
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (alertView.tag == 0) { //set dorm location as current location
        if (buttonIndex == 1) {
            NSLog(@"user pressed OK");
            CLLocation *location = [LocationManager currentLocationByWaitingUpToMilliseconds:4000];
            
            NSLog(@"current location: %f", location.coordinate.latitude);
            NSLog(@"curr lat: %f", [[LocationManager sharedClient] currentLatitude]); //doesn't work. good.
        }
        else {
            NSLog(@"user pressed Cancel");
        }
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *MyIdentifier = @"MyReuseIdentifier";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:MyIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault  reuseIdentifier:MyIdentifier];
    }
    if (indexPath.row == [self.users count] + 2) {
        cell.textLabel.text = @"Switch groups";
        return cell;
    }
    if (indexPath.row == [self.users count] + 1) {
        cell.textLabel.text = @"Logout";
        return cell;
    }
    if (indexPath.row == [self.users count]) {
        cell.textLabel.text = @"Set dorm location";
        return cell;
    }
    
    ProfileUser * user = [self.users objectAtIndex: indexPath.row];
    bool userIsNearDorm = [user.isNearDorm intValue] == 1; // cannot simply check user.isNearDorm
    cell.textLabel.text = [NSString stringWithFormat:@"%@ - %@", [user firstName], (userIsNearDorm) ? @"in dorm" : @"away from dorm"];
    return cell;
}

- (void)handleLogin
{
    [self.sideBarMenuTable reloadData];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0) {
        [self handleLogout];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
