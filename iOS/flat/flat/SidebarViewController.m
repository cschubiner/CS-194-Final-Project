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

const static int AWAY_DORM_STATUS = 0;
const static int IN_DORM_STATUS = 1;
const static int NOT_BROADCASTING_DORM_STATUS = 2;


@implementation SidebarViewController
{
    NSArray *colorArray;
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

-(void)refreshUsers {
    ProfileUser * currUser = [FlatAPIClientManager sharedClient].profileUser;
    [ProfileUserHelper getUsersFromGroupID:currUser.groupID withCompletionBlock:^(NSError * error, NSMutableArray * users) {
        self.users = users;
        [self.sideBarMenuTable reloadData];
    }];
}

-(void)viewWillAppear:(BOOL)animated {
    
    [self refreshUsers];
    [NSTimer scheduledTimerWithTimeInterval:8.0
                                     target:self
                                   selector:@selector(refreshUsers)
                                   userInfo:nil
                                    repeats:YES];
}

-(UIColor*)colorWithHexString:(NSString*)hex
{
    NSString *cString = [[hex stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] uppercaseString];
    
    // String should be 6 or 8 characters
    if ([cString length] < 6) return [UIColor grayColor];
    
    // strip 0X if it appears
    if ([cString hasPrefix:@"0X"]) cString = [cString substringFromIndex:2];
    
    if ([cString length] != 6) return  [UIColor grayColor];
    
    // Separate into r, g, b substrings
    NSRange range;
    range.location = 0;
    range.length = 2;
    NSString *rString = [cString substringWithRange:range];
    
    range.location = 2;
    NSString *gString = [cString substringWithRange:range];
    
    range.location = 4;
    NSString *bString = [cString substringWithRange:range];
    
    // Scan values
    unsigned int r, g, b;
    [[NSScanner scannerWithString:rString] scanHexInt:&r];
    [[NSScanner scannerWithString:gString] scanHexInt:&g];
    [[NSScanner scannerWithString:bString] scanHexInt:&b];
    
    return [UIColor colorWithRed:((float) r / 255.0f)
                           green:((float) g / 255.0f)
                            blue:((float) b / 255.0f)
                           alpha:1.0f];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    NSString *hex1 = @"FF1300";
    NSString *hex2 = @"FF7A00";
    NSString *hex3 = @"03899C";
    NSString *hex4 = @"00C322";
    UIColor *color1 = [self colorWithHexString:hex1];
    UIColor *color2 = [self colorWithHexString:hex2];
    UIColor *color3 = [self colorWithHexString:hex3];
    UIColor *color4 = [self colorWithHexString:hex4];
    
    colorArray = [NSArray arrayWithObjects: color1, color2, color3, color4, nil];
    locationArray = [NSArray arrayWithObjects: [NSNumber numberWithInt:1], [NSNumber numberWithInt:0], [NSNumber numberWithInt:1], [NSNumber numberWithInt:2], nil];
    
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
    return self.users.count;
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

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
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
    
    [tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    tableView.backgroundColor = [UIColor whiteColor];
    
    ProfileUser * user = [self.users objectAtIndex: indexPath.row];
    
    UIView *circleView = [[UIView alloc] initWithFrame:CGRectMake(40,15,70,70)];
    circleView.alpha = 0.5;
    circleView.layer.cornerRadius = 35;
    circleView.backgroundColor = colorArray[user.colorID.intValue];
    
    NSArray *geoImages = [NSArray arrayWithObjects:@"arrow-hollow-black.png", @"arrow-black.png", @"arrow-empty-small.png", nil];
    UIImageView *locationImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:
                                                                     geoImages[user.isNearDorm.intValue]]];
    locationImage.frame = CGRectMake(4,40,20,20);
    
    UILabel *name = [[UILabel alloc]initWithFrame:CGRectMake(60, 16, 70, 70)];
    name.textColor = [UIColor whiteColor];
    name.font = [UIFont fontWithName:@"courier" size:25];
    
    cell.backgroundColor = [UIColor whiteColor];
    [cell.contentView addSubview:circleView];
    [cell.contentView addSubview:name];
    [cell.contentView addSubview:locationImage];

    NSString *initials  = [NSString stringWithFormat:@"%@%@",
                           [user.firstName substringWithRange:NSMakeRange(0, 1)],
                           [user.lastName substringWithRange:NSMakeRange(0, 1)]];
    
    name.text = initials;
    
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
