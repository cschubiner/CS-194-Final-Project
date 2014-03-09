//
//  SettingsViewController.m
//  flat
//
//  Created by Clay Schubiner on 2/9/14.
//  Copyright (c) 2014 cs194. All rights reserved.
//

#import "SettingsViewController.h"
#import "cs194AppDelegate.h"
#import "GroupTableViewController.h"

@interface SettingsViewController ()

@end

@implementation SettingsViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [[self navigationItem] setTitle:@"Settings"];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return 4;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell3";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault  reuseIdentifier:CellIdentifier];
    }
    
    // Configure the cell...
    if (indexPath.row ==  1) {
        cell.textLabel.text = @"Switch groups";
        return cell;
    }
    if (indexPath.row == 2) {
        cell.textLabel.text = @"Tasks";
        return cell;
    }
    if (indexPath.row == 3) {
        cell.textLabel.text = @"Logout";
        return cell;
    }
    if (indexPath.row == 0) {
        cell.textLabel.text = @"Set dorm location";
        return cell;
    }
    
    return cell;
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0) {
        [self handleLogout];
    }
}

- (void)handleLogout
{
    NSLog(@"handleLogout");
    
    [self.delegate toggleSidebarMenu:nil];
    
    cs194AppDelegate *delegate = [UIApplication sharedApplication].delegate;
    [delegate handleLogout];
}


- (void)prepareForSegue:(UIStoryboardSegue *)segue
                 sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"SidebarToGroupTableView"]) {
        
    }
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 3) {
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
    } else if (indexPath.row == 2) {
        [self performSegueWithIdentifier:@"SettingsToTasks"
                                  sender:self];
    } else if (indexPath.row == 0) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle: @"Set dorm location"
                                                        message: @"Do you want to set your current location as your group's dorm location?"
                                                       delegate: self
                                              cancelButtonTitle:@"Cancel"
                                              otherButtonTitles:@"Set Location", nil];
        [alert setTag:0];
        [alert show];
    }
    else if (indexPath.row == 1) {
        [self performSegueWithIdentifier:@"SidebarToGroupTableView"
                                  sender:self];
        //        GroupTableViewController * groupTableVC = [[GroupTableViewController alloc] init];
        //        [self presentViewController:groupTableVC animated:YES completion:nil];
        
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (alertView.tag == 0) { //set dorm location as current location
        if (buttonIndex == 1) {
            NSLog(@"user pressed OK");
//            CLLocation * location =
            
            [[LocationManager sharedClient] setShouldSetDormLocation:true];
            [[[LocationManager sharedClient] locationManager] startUpdatingLocation];
//            NSLog(@"curr lat: %f", [[LocationManager sharedClient] currentLatitude]); //doesn't work. good.
        }
        else {
            NSLog(@"user pressed Cancel");
        }
    }
}


@end
