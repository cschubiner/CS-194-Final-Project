//
//  SidebarViewController.m
//  flat
//
//  Created by Zachary Palacios on 1/19/14.
//  Copyright (c) 2014 cs194. All rights reserved.
//

#import "SidebarViewController.h"


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

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.sideBarMenuTable = [[UITableView alloc] initWithFrame:CGRectMake(0, NAV_BAR_HEIGHT, self.view.frame.size.width, self.view.frame.size.height)];
    self.sideBarMenuTable.delegate = self;
    self.sideBarMenuTable.dataSource = self;

    
    [ProfileUserHelper getUsersFromGroupID:0 withCompletionBlock:^(NSError * error, NSMutableArray * users) {
        self.users = users;
        [self.sideBarMenuTable reloadData];
    }];
    
    
//    ProfileUser * currUser = [FlatAPIClientManager sharedClient].profileUser;
    
    [self.view addSubview:self.sideBarMenuTable];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.users.count;
}


- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return @"Roommates";
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *MyIdentifier = @"MyReuseIdentifier";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:MyIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault  reuseIdentifier:MyIdentifier];
    }
    ProfileUser * user = [self.users objectAtIndex: indexPath.row];
    cell.textLabel.text = [user firstName];
    return cell;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
