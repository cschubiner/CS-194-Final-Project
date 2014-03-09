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

-(void)refreshMessages {
    HomeViewController *homeViewController = [self getHomeViewController];
    homeViewController.messages = nil;
    [homeViewController.tableView reloadData];
    [MessageHelper getMessagesWithCompletionBlock:^(NSError *error, NSArray *messages) {
    NSLog(@"Getting messages 7");
        if ([messages count] != [homeViewController.messages count] && [messages count] != 0) {
            [JSMessageSoundEffect playMessageReceivedAlert];
        }
        homeViewController.messages = [messages mutableCopy];
        [homeViewController.tableView reloadData];
        [homeViewController reloadInputViews];
        [homeViewController viewDidLoad];
        [homeViewController scrollToBottomAnimated:YES];
    NSLog(@"Getting messages 8");
    }];
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    //    [self dismissViewControllerAnimated:YES completion:nil];
    NSNumber * newGroupID;
    ProfileUser * user = [[FlatAPIClientManager sharedClient]profileUser];
    if (indexPath.row == [self.groups count]) {
        NSTimeInterval secondsElapsed = [[NSDate date] timeIntervalSinceDate:[NSDate dateWithTimeIntervalSince1970:1000000]];
        newGroupID = [NSNumber numberWithInt:(int)secondsElapsed];
        NSLog(@"new group ID: %@", newGroupID);
    }
    else {
        NSMutableArray* users = [self.groups objectAtIndex:indexPath.row];
        ProfileUser * firstUser = [users objectAtIndex:0];
        newGroupID = firstUser.groupID;
    }
    [ProfileUserNetworkRequest setGroupIDForUser:user.userID groupID:newGroupID withCompletionBlock:^(NSError* error) {
        [self refreshMessages];
        [self.navigationController popToViewController:[self getRootViewController] animated:YES]; // what a convenient method
    }];
}



/*
 #pragma mark - Navigation
 
 // In a story board-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
 {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 
 */

@end
