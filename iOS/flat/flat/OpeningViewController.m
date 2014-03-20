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
#import "PageContentViewController.h"

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
    DLog(@"Opening View Controller");
    [super viewDidLoad];
    [self setNeedsStatusBarAppearanceUpdate];
    
    //start
    [super viewDidLoad];
    // Create the data model
    _pageTitles = @[@"Welcome to your Flat", @"A place to interact with your Flatmates", @"You can see if they are home...", @"and always know who is busy."];
    _pageImages = @[@"1-final.png", @"1-final.png", @"2-final.png", @"3-final.png"];
    
    // Create page view controller
    self.pageViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"PageViewController"];
    self.pageViewController.dataSource = self;
    
    PageContentViewController *startingViewController = [self viewControllerAtIndex:0];
    NSArray *viewControllers = @[startingViewController];
    [self.pageViewController setViewControllers:viewControllers direction:UIPageViewControllerNavigationDirectionForward animated:NO completion:nil];
    
    // Change the size of page view controller
    self.pageViewController.view.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
    
    [self addChildViewController:_pageViewController];
    [self.view addSubview:_pageViewController.view];
    [self.pageViewController didMoveToParentViewController:self];
    //end
    
    
    
    [self.view addSubview:[[OpeningButton alloc] initWithType:@"facebookSignIn"
                                                       parent:self
                                                       action:@selector(openFacebookSession)]];
    [self setBackground];
}

- (PageContentViewController *)viewControllerAtIndex:(NSUInteger)index
{
    if (([self.pageTitles count] == 0) || (index >= [self.pageTitles count])) {
        return nil;
    }
    
    // Create a new view controller and pass suitable data.
    PageContentViewController *pageContentViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"PageContentViewController"];
    pageContentViewController.imageFile = self.pageImages[index];
    pageContentViewController.titleText = self.pageTitles[index];
    pageContentViewController.pageIndex = index;
    
    return pageContentViewController;
}

#pragma mark - Page View Controller Data Source

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController
{
    NSUInteger index = ((PageContentViewController*) viewController).pageIndex;
    
    if ((index == 0) || (index == NSNotFound)) {
        return nil;
    }
    
    index--;
    return [self viewControllerAtIndex:index];
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController
{
    NSUInteger index = ((PageContentViewController*) viewController).pageIndex;
    
    if (index == NSNotFound) {
        return nil;
    }
    
    index++;
    if (index == [self.pageTitles count]) {
        return nil;
    }
    return [self viewControllerAtIndex:index];
}

- (NSInteger)presentationCountForPageViewController:(UIPageViewController *)pageViewController
{
    return [self.pageTitles count];
}

- (NSInteger)presentationIndexForPageViewController:(UIPageViewController *)pageViewController
{
    return 0;
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
    [background setBackgroundColor:[UIColor whiteColor]];
    background.contentMode = UIViewContentModeScaleAspectFill;
    [self.view insertSubview:background atIndex:0];
    self.view.backgroundColor = [UIColor whiteColor];
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
         DLog(@"signing up with facebook");
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
