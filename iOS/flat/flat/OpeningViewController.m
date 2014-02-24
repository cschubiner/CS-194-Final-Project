//
//  OpeningViewController.m
//  flat
//
//  Created by Zachary Palacios on 1/19/14.
//  Copyright (c) 2014 cs194. All rights reserved.
//

#import "OpeningViewController.h"
#import "MBProgressHUD.h"
#import "cs194AppDelegate.h"
#import "AuthenticationHelper.h"
#import "OpeningButton.h"
#import "GroupTableViewController.h"

@interface OpeningViewController ()
@property NSArray *readPermissions;
@end

@implementation OpeningViewController


- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:NO];
    [self.view setHidden:NO];
    
    [MBProgressHUD hideHUDForView:self.view animated:NO];
}

- (void)openFacebookSession
{
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.labelText = @"Connecting";
    cs194AppDelegate* appDelegate = [UIApplication sharedApplication].delegate;
    [appDelegate openFacebookSession];
}

- (void)viewDidLoad
{
    NSLog(@"Opening View Controller");
    [super viewDidLoad];
    [self setNeedsStatusBarAppearanceUpdate];
    
    //self.screenName = @"Opening View Screen";
    [self.view addSubview:[[OpeningButton alloc] initWithType:@"facebookSignIn"
                                                             parent:self
                                                             action:@selector(openFacebookSession)]];
    [self setBackground];
}

- (UIStatusBarStyle) preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"OpeningToGroup"]) {
        //Do something here if necessary
    }
}

-(void)setBackground {
    UIImageView *background = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height-60)];
    //[background setImage:[UIImage imageNamed:@"opening_background.png"]];
    [background setBackgroundColor:[UIColor greenColor]];
    background.contentMode = UIViewContentModeScaleAspectFill;
    [self.view insertSubview:background atIndex:0];
    self.view.backgroundColor = [UIColor clearColor];
    self.view.alpha = 1.0;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)signUpUserWithFacebook:(NSString *)fbToken
                      andEmail:(NSString *)email
                  andFirstName:(NSString *)firstName
                   andLastName:(NSString *)lastName
{
    NSLog(@"signing up user with email %@", email);
    [AuthenticationHelper signUpWithFacebook:fbToken
                                    andEmail:email
                                andFirstName:firstName
                                 andLastName:lastName
                         withCompletionBlock:^(NSError *error, ProfileUser *profileUser)
     {
         NSLog(@"signing up with facebook");
         if (!error) {
             NSLog(@"openingViewController completion block %@", profileUser);
             [FlatAPIClientManager sharedClient].profileUser = profileUser;
             [self performSegueWithIdentifier:@"OpeningToGroup"
                                       sender:self];
             //[self dismissViewControllerAnimated:YES completion:nil];
         }
     }];
}

@end
