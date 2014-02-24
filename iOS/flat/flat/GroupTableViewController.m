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
    return MAX([self.groups count], 1);
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
    if ([self.groups count] > 0) {
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
    else
        cell.textLabel.text = @"There are no groups for you to join.";
    cell.textLabel.numberOfLines = 0;
    [cell sizeToFit];
    
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 100.0;
}


-(void)refreshMessages {
    UINavigationController *navigationController = (UINavigationController*)self.view.window.rootViewController;
     HomeViewController *homeViewController = (HomeViewController *)[navigationController.viewControllers objectAtIndex:0];
    [MessageHelper getMessagesWithCompletionBlock:^(NSError *error, NSArray *messages){
        homeViewController.messages = [messages mutableCopy];
        [homeViewController.tableView reloadData];
    }];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    //    [self dismissViewControllerAnimated:YES completion:nil];
    if ([self.groups count] > 0) {
        NSMutableArray* users = [self.groups objectAtIndex:indexPath.row];
        ProfileUser * firstUser = [users objectAtIndex:0];
        
        ProfileUser * user = [[FlatAPIClientManager sharedClient]profileUser];
        [ProfileUserNetworkRequest setGroupIDForUser:user.userID groupID:firstUser.groupID];
        
        [self.navigationController popViewControllerAnimated:YES];
    }
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
