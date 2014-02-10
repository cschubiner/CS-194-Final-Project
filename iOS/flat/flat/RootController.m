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
    self.leftFixedWidth = self.view.frame.size.width * .8;
    self.rightGapPercentage = 0.0f;
    self.allowRightSwipe = NO;
    self.allowRightOverpan= NO;
    self.rightFixedWidth = 0;
    
    self.navigationController.navigationBar.hidden = NO;
    self.navigationController.navigationBar.barTintColor = [UIColor whiteColor];
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    self.navigationController.navigationBar.translucent = YES;
    self.navigationController.navigationBar.alpha = 0;
    [[self navigationItem] setTitle:@"Flat"];
    
    self.navigationController.toolbarHidden = TRUE;
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

-(void) awakeFromNib
{
    self.leftPanel = [self.storyboard instantiateViewControllerWithIdentifier:@"SidebarViewController"];
    self.centerPanel = [self.storyboard instantiateViewControllerWithIdentifier:@"HomeViewController"];
    self.leftPanel.delegate = self;
    
    [self setLeftPanel:self.leftPanel];
    [self setCenterPanel:self.centerPanel];
}

@end
