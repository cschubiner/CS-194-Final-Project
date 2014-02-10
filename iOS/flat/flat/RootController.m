//
//  RootController.m
//  flat
//
//  Created by Zachary Palacios on 1/19/14.
//  Copyright (c) 2014 cs194. All rights reserved.
//

#import "RootController.h"

@interface RootController ()

@end

@implementation RootController

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
    
    //edit for width of the sidebar
    self.leftFixedWidth = self.view.frame.size.width * .40;
    self.rightGapPercentage = 0.0f;
    self.allowRightSwipe = NO;
    self.allowRightOverpan= NO;
    self.rightFixedWidth = 0;
    
    self.navigationController.navigationBar.hidden = NO;
    self.navigationController.navigationBar.barTintColor = [UIColor blackColor];
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    self.navigationController.navigationBar.translucent = YES;
    self.navigationController.navigationBar.alpha = 0;
    self.navigationItem.titleView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"cs-logo"]];
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain
                                                                            target:nil
                                                                            action:nil];
    [self.navigationController.navigationBar setTitleTextAttributes:[NSDictionary dictionaryWithObject:[UIColor whiteColor]
                                                                                                forKey:NSForegroundColorAttributeName]];
    
//    UIBarButtonItem *leftBarButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"menubar"]
//                                                                      style:UIBarButtonItemStylePlain
//                                                                     target:self
//                                                                     action:@selector(toggleSidebarMenu:)];
    UIBarButtonItem* lbb = [[UIBarButtonItem alloc]initWithTitle:@"Settings" style:UIBarButtonItemStyleBordered target:self action:@selector(openSettings)];

    
//    self.navigationItem.leftBarButtonItem = leftBarButton;
    self.navigationItem.leftBarButtonItem = lbb;
    
    /*
    UIBarButtonItem *rightBarButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"notify_icon"]
                                                                       style:UIBarButtonItemStylePlain
                                                                      target:self
                                                                      action:@selector(showNotifications:)];
    self.navigationItem.rightBarButtonItem = rightBarButton;
    self.navigationItem.rightBarButtonItem.tintColor = [UIColor colorWithRed:109.0/255.0
                                                                       green:207.0/255.0
                                                                        blue:246.0/255.0
                                                                       alpha:1.0];
    */
    self.navigationController.toolbarHidden = TRUE;
}

-(void)openSettings {
    [self performSegueWithIdentifier:@"RootToSettingsViewController" sender:self];
}

- (void)viewDidAppear:(BOOL)animated
{
    
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    return YES;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)stylePanel:(UIView *)panel
{
    panel.layer.cornerRadius = 0.0f;
    panel.clipsToBounds = YES;
}

-(IBAction)toggleSidebarMenu:(id)sender
{
    [self toggleLeftPanel:sender];
}

/*
-(IBAction)showNotifications:(id)sender
{
    [self.navigationController pushViewController:[[NotificationViewController alloc] init] animated:YES];
}
*/

-(void) awakeFromNib
{
    self.leftPanel = [self.storyboard instantiateViewControllerWithIdentifier:@"SidebarViewController"];
    self.centerPanel = [self.storyboard instantiateViewControllerWithIdentifier:@"HomeViewController"];
    self.leftPanel.delegate = self;
    
    [self setLeftPanel:self.leftPanel];
    [self setCenterPanel:self.centerPanel];
}

@end
