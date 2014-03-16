//
//  GroupTableViewController.m
//  flat
//
//  Created by Clay Schubiner on 2/9/14.
//  Copyright (c) 2014 cs194. All rights reserved.
//

#import "GroupTableViewController.h"
#import "ProfileUserNetworkRequest.h"
#import "FlatAPIClientManager.h"
#import "MessageHelper.h"

@interface GroupTableViewController ()
@property (nonatomic, strong) NSArray * groups;
@property (nonatomic) NSUInteger joiningGroup;
@end

@implementation GroupTableViewController

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
    //    [self.navigationItem.leftBarButtonItem setTintColor:[UIColor blackColor]];
    //    [[UIBarButtonItem appearance] setTintColor: [UIColor colorWithRed:102.0/255.0 green:153.0/255.0 blue:153.0/255.0 alpha:1.0]];
    //    [self.navigationItem.leftBarButtonItem setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
    //                                              [UIColor redColor], UITextAttributeTextColor,
    //                                              nil] forState:UIControlStateNormal];
    
    [[self navigationItem] setTitle:@"Join a Group"];
    
    // Uncomment the following line to preserve selection between presentations.
    self.clearsSelectionOnViewWillAppear = NO;
}

-(void)viewWillAppear:(BOOL)animated {
    ProfileUser* user = [[FlatAPIClientManager sharedClient] profileUser];
    [ProfileUserNetworkRequest getFriendsGroupsFromUserID:user.userID
                                      withCompletionBlock:^(NSError *error, NSArray *groups){
                                          NSLog(@"groups: %@", groups);
                                          self.groups = groups;
                                          [self.tableView reloadData];
                                      }];
    
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
    return [self.groups count] + 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell2";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
    }
    // Configure the cell...
    if (indexPath.row == [self.groups count]) {
        cell.textLabel.text = @"Create a new group";
    }
    else{
        NSMutableArray* users = [self.groups objectAtIndex:indexPath.row];
        NSMutableString * cellStr = [[NSMutableString alloc] init];
        for (ProfileUser * user in users) {
            NSLog(@"user name: %@", user.firstName);
            if (users.count >= 3) {
                if (user != users.lastObject)
                    [cellStr appendString:[NSString stringWithFormat:@"%@ %@, ", user.firstName, user.lastName]];
                else
                    [cellStr appendString:[NSString stringWithFormat:@"and %@ %@", user.firstName, user.lastName]];
            }
            else if (users.count == 2) {
                if (user != users.lastObject)
                    [cellStr appendString:[NSString stringWithFormat:@"%@ %@ ", user.firstName, user.lastName]];
                else
                    [cellStr appendString:[NSString stringWithFormat:@"and %@ %@", user.firstName, user.lastName]];
            }
            else if (users.count == 1) {
                [cellStr appendString:[NSString stringWithFormat:@"%@ %@", user.firstName, user.lastName]];
            }
        }
        cell.textLabel.text = [NSString stringWithFormat:@"Group with: %@", cellStr];
    }
    
    cell.textLabel.numberOfLines = 0;
    [cell sizeToFit];
    
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 95.0;
}

-(RootController*)getRootViewController {
    return ((RootController*)((NSArray*)((UINavigationController*)self.navigationController).childViewControllers)[0]); //madness!!
}

-(HomeViewController*) getHomeViewController {
    return [self getRootViewController].centerPanel;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    //    [self dismissViewControllerAnimated:YES completion:nil];
    self.joiningGroup = indexPath.row;
    if (self.joiningGroup != [self.groups count]) {
        [self askForGroupPassword];
        return;
    }
    //else, the user is creating a new group
    ProfileUser * user = [[FlatAPIClientManager sharedClient]profileUser];
    NSTimeInterval secondsElapsed = [[NSDate date] timeIntervalSinceDate:[NSDate dateWithTimeIntervalSince1970:1394929600]]; //this gets us a low group ID. This should work for the next 136 years or so :)
    NSNumber * newGroupID = [NSNumber numberWithInt:(int)secondsElapsed];
    NSLog(@"new group ID: %@", newGroupID);
    [ProfileUserNetworkRequest setGroupIDForUser:user.userID groupID:newGroupID withPassword:@"newgroup" withCompletionBlock:^(NSError* error) {
        if (error) {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Unable to create group" message:@"We were unable to create your group. Please try again later." delegate:self cancelButtonTitle:@"Dismiss" otherButtonTitles:nil];
            [alertView show];
        }
        else {
            RootController * rc = [self getRootViewController];
            [rc refreshMessagesWithAnimation:YES scrollToBottom:YES];
            [self.navigationController popToViewController:rc animated:YES];
        }
    }];
}

-(void)askForGroupPassword {
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Enter Access Code" message:@"Enter the access code of the group you wish to join" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Join Group", nil];
    alertView.alertViewStyle = UIAlertViewStylePlainTextInput;
    [alertView show];
    [[alertView textFieldAtIndex:0] resignFirstResponder];
    [[alertView textFieldAtIndex:0] setKeyboardType:UIKeyboardTypePhonePad];
    [[alertView textFieldAtIndex:0] becomeFirstResponder];
}

-(void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 0) return;
    UITextField *passwordTextField = [alertView textFieldAtIndex:0];
    NSLog(@"pw: %@",passwordTextField.text);
    
    ProfileUser * user = [[FlatAPIClientManager sharedClient]profileUser];
    NSMutableArray* users = [self.groups objectAtIndex:self.joiningGroup];
    ProfileUser * firstUser = [users objectAtIndex:0];
    [ProfileUserNetworkRequest setGroupIDForUser:user.userID groupID:firstUser.groupID withPassword:passwordTextField.text withCompletionBlock:^(NSError* error) {
        if (error) {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Incorrect password" message:@"The group's access code can be found at the top of the message feed of anyone in the group." delegate:self cancelButtonTitle:@"Dismiss" otherButtonTitles:nil];
            [alertView show];
        }
        else {
            RootController * rc = [self getRootViewController];
            [rc refreshMessagesWithAnimation:YES scrollToBottom:YES];
            [self.navigationController popToViewController:rc animated:YES];
        }
    }];
}

@end
