//
//  OpeningNavigationController.m
//  flat
//
//  Created by Zachary Palacios on 1/19/14.
//  Copyright (c) 2014 cs194. All rights reserved.
//

#import "OpeningNavigationController.h"
#import "OpeningViewController.h"

@implementation OpeningNavigationController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.navigationController.navigationBar.translucent = YES;
}

- (void)handleFacebookSignupWithToken:(NSString *)fbToken
                             andEmail:(NSString *)email
                            firstName:(NSString *)firstName
                          andLastName:(NSString *)lastName
{
    NSLog(@"OpeningNavigationController %@", self.topViewController);
    [(OpeningViewController *)self.topViewController signUpUserWithFacebook:fbToken
                                                                   andEmail:email
                                                               andFirstName:firstName
                                                                andLastName:lastName];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end
