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
@property NSString *emailClicked;
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

- (IBAction)showEmail {
    // Email Subject
    NSString *emailTitle = @"";
    // Email Content
    NSString *messageBody = @"";
    // To address
    NSArray *toRecipients = [NSArray arrayWithObject:@""];
    if (self.emailClicked) {
        toRecipients = [NSArray arrayWithObject:self.emailClicked];
    }
    MFMailComposeViewController *mc = [[MFMailComposeViewController alloc] init];
    mc.mailComposeDelegate = self;
    [mc setSubject:emailTitle];
    [mc setMessageBody:messageBody
                isHTML:NO];
    [mc setToRecipients:toRecipients];
    
    // Present mail view controller on screen
    [self presentViewController:mc animated:YES
                     completion:nil];
    
}

- (void) mailComposeController:(MFMailComposeViewController *)controller
           didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
    switch (result)
    {
        case MFMailComposeResultCancelled:
            NSLog(@"Mail cancelled");
            break;
        case MFMailComposeResultSaved:
            NSLog(@"Mail saved");
            break;
        case MFMailComposeResultSent:
            NSLog(@"Mail sent");
            break;
        case MFMailComposeResultFailed:
            NSLog(@"Mail sent failure: %@", [error localizedDescription]);
            break;
        default:
            break;
    }
    // Close the Mail Interface
    [self dismissViewControllerAnimated:YES completion:NULL];
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


- (void)alertView:(UIAlertView *)alertView
clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSLog(@"BUTTON INDEX: %lu", (long)buttonIndex);
    if(buttonIndex == 1) {
        [self showEmail];
    }
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
        self.emailClicked = user.email;
        NSString * dormStatus = @"'s location has not been broadcasted recently";
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
                                  delegate:self
                                  cancelButtonTitle:@"Dismiss"
                                  otherButtonTitles:@"Send Email", nil];
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
    UITableViewCell*  cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault  reuseIdentifier:MyIdentifier];
    
    NSMutableArray * users = [[FlatAPIClientManager sharedClient]users];
    NSString *hex = @"394247";
    UIColor *backgroundColor = [ProfileUser colorWithHexString:hex];
    NSString *lighterText = @"f2f2f2";
    UIColor *lightTextColor = [ProfileUser colorWithHexString:lighterText];
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
