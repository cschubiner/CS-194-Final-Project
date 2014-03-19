//
//  HomeViewController.m
//  flat
//
//  Created by Zachary Palacios on 1/19/14.
//  Copyright (c) 2014 cs194. All rights reserved.
//

#import "HomeViewController.h"
#import "Message.h"
#import "MessageHelper.h"
#import <QuartzCore/QuartzCore.h>
#import "SAMLoadingView.h"
#import "ISO8601DateFormatter.h"


@interface HomeViewController ()
@property BOOL justLoggedIn;
@end

@implementation HomeViewController


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}


- (void)toggleSidebarMenu:(id)sender
{
    DLog(@"left menu toggled");
    [self.messageInputView resignFirstResponder];
    [[FlatAPIClientManager sharedClient].rootController toggleLeftPanel:sender];
    [self setNavBarButtons];
}

- (void)rightButtonPressed:(id)sender
{
    DLog(@"right menu toggled");
    [self.messageInputView resignFirstResponder];
    [[FlatAPIClientManager sharedClient].rootController toggleRightPanel:sender];
    [self setNavBarButtons];
}

- (BOOL)shouldDisplayTimestampForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row % 3 == 0) {
        return YES;
    }
    return NO;
}

-(void)setNavBarButtons
{
    int numUsersHome = [[FlatAPIClientManager sharedClient] getNumUsersHome];
    int numUsersBusy = [[[FlatAPIClientManager sharedClient] rootController].rightPanel numberOfEventsOccurringNow];
    
    UIImage* image = [UIImage imageNamed:@"circle-icon.png"];
    CGRect frame = CGRectMake(0, 0, image.size.width, image.size.height);
    UIButton* someButton = [[UIButton alloc] initWithFrame:frame];
    NSString *numHomeText = [NSString stringWithFormat:@"%d", numUsersHome];
    [someButton setTitle:numHomeText forState:UIControlStateNormal];
    [someButton.titleLabel setFont:[UIFont fontWithName:@"Courier" size:18.0f]];
    [someButton setBackgroundImage:image forState:UIControlStateNormal];
    [someButton setShowsTouchWhenHighlighted:YES];
    [someButton addTarget:self
                   action:@selector(toggleSidebarMenu:)
         forControlEvents:UIControlEventTouchUpInside];
    CGRect fr = [someButton.titleLabel frame];
	fr.origin.x = 7;
	fr.origin.y = 4;
	[[someButton titleLabel] setFrame:fr];
    UIBarButtonItem* someBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:someButton];
    
    UIImage* image2 = [UIImage imageNamed:@"calendar-icon.png"];
    CGRect frame2 = CGRectMake(0, 0, image2.size.width, image2.size.height);
    NSString *numBusyText = [NSString stringWithFormat:@"%d", numUsersBusy];
    UIButton* someButton2 = [[UIButton alloc] initWithFrame:frame2];
    [someButton2 setTitle:numBusyText forState:UIControlStateNormal];
    [someButton2.titleLabel setFont:[UIFont fontWithName:@"Courier" size:18.0f]];
    [someButton2 setBackgroundImage:image2 forState:UIControlStateNormal];
    [someButton2 setShowsTouchWhenHighlighted:YES];
    [someButton2 addTarget:self
                    action:@selector(rightButtonPressed:)
          forControlEvents:UIControlEventTouchUpInside];
    CGRect fr2 = [someButton2.titleLabel frame];
	fr2.origin.x = 7;
	fr2.origin.y = 7;
	[[someButton2 titleLabel] setFrame:fr2];
    UIBarButtonItem* someBarButtonItem2 = [[UIBarButtonItem alloc] initWithCustomView:someButton2];
    
    self.navigationItem.leftBarButtonItem = someBarButtonItem;
    self.navigationItem.rightBarButtonItem = someBarButtonItem2;
}

-(void)setupNavBar {
    
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor whiteColor]}];
    UIImage *myGradient = [UIImage imageNamed:@"grad-small.png"];
    [[self navigationItem] setTitle:@"Flat"];
    [self.navigationController.navigationBar setTitleTextAttributes:
     @{ NSFontAttributeName: [UIFont fontWithName:@"HelveticaNeue-Light" size:22.0f], NSForegroundColorAttributeName: [UIColor colorWithPatternImage:myGradient]}];
    
    [self setNavBarButtons];
    
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor]; //sets text color
    self.navigationController.navigationBar.barTintColor =  [ProfileUser getColorFromUser:[[FlatAPIClientManager sharedClient]profileUser]];
    
    self.navigationController.navigationBar.translucent = YES;
    self.navigationController.navigationBar.alpha = .2;
}


- (void)getMessages
{
    [[FlatAPIClientManager sharedClient].rootController refreshMessagesWithAnimation:YES scrollToBottom:YES];
}

- (void)viewDidAppear:(BOOL)animated
{
    if ([[FlatAPIClientManager sharedClient].users count] == 1 && self.justLoggedIn) {
        //show groups
        UIAlertView *alertView = [[UIAlertView alloc]
                                  initWithTitle:@"Join a Flat"
                                  message:@"Let's get you in a Flat. Join a group with your friends!"
                                  delegate:nil
                                  cancelButtonTitle:@"OK"
                                  otherButtonTitles:nil];
        [alertView show];
        
        [self performSegueWithIdentifier:@"HomeViewControllerToGroupTableViewController" sender:self];
    }
    self.justLoggedIn = NO;
}

-(void) resetTable {
    self.title = @"Flat";
    [self.tableView setBackgroundColor:[UIColor whiteColor]];
    [self.tableView setSeparatorColor:[UIColor whiteColor]];
    
    self.messageInputView.textView.placeHolder = @"";
    
    self.tableView.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height - self.messageInputView.frame.size.height);
    
    //Pull to refresh
    self.tableViewController = [[UITableViewController alloc] init];
    self.tableViewController.tableView = self.tableView;
    
    self.refresh = [[UIRefreshControl alloc] init];
    [self.refresh addTarget:self action:@selector(getMessages) forControlEvents:UIControlEventValueChanged];
    self.refresh.tintColor = [UIColor grayColor];
    self.refresh.attributedTitle = [[NSAttributedString alloc] initWithString:@"Pull to Refresh"];
    self.tableViewController.refreshControl = self.refresh;
}

- (void)viewDidLoad
{
    
    self.delegate = self;
    self.dataSource = self;
    self.justLoggedIn = YES;
    [super viewDidLoad];
    [[JSBubbleView appearance] setFont:[UIFont systemFontOfSize:16.0f]];
    
    [self resetTable];
    [self setupNavBar];
    
    [self loadInitialMessages];
}

- (void)loadInitialMessages
{
    //
    [[FlatAPIClientManager sharedClient]turnOnLoadingView:self.view];
    [ProfileUserHelper getUsersFromGroupID:[[FlatAPIClientManager sharedClient]profileUser].groupID withCompletionBlock:^(NSError * error, NSMutableArray * users) {
        [[FlatAPIClientManager sharedClient] setUsers:users];
        [[FlatAPIClientManager sharedClient].rootController refreshMessagesWithAnimation:NO scrollToBottom:YES];
    }];
}

-(void)didSendText:(NSString *)text fromSender:(NSString *)sender onDate:(NSDate *)date {
    if (text.length == 0)
        return;
    
    self.messageInputView.textView.dataDetectorTypes = UIDataDetectorTypeNone;
    [self.messageInputView.textView setText:nil];
    [self textViewDidChange:self.messageInputView.textView];
    [MessageHelper sendMessageWithText:text
                    andCompletionBlock:^(NSError *error, NSMutableArray *messages) {
                        if (error) {
                            //Diplay message did not send error
                            self.messageInputView.textView.text = text;
                        } else {
                            //    NSLog(@"MESSAGES: %@", messages);
                            self.messages = messages;
                            [JSMessageSoundEffect playMessageSentSound];
                            DLog(@"About to reload data");
                            [self.tableView reloadData];
                            DLog(@"Just reloaded data");
                        }
                        [self finishSend];
                    }];
}


- (JSBubbleMessageType)messageTypeForRowAtIndexPath:(NSIndexPath *)indexPath
{
    Message *currMessage = [self.messages objectAtIndex:indexPath.row];
    ProfileUser *user = [FlatAPIClientManager sharedClient].profileUser;
    
    if ([currMessage.senderID isEqualToNumberWithNullCheck: user.userID]) {
        return JSBubbleMessageTypeOutgoing;
    }
    return JSBubbleMessageTypeIncoming;
}

- (UIImageView *)bubbleImageViewWithType:(JSBubbleMessageType)type
                       forRowAtIndexPath:(NSIndexPath *)indexPath
{
    Message *currMessage = [self.messages objectAtIndex:indexPath.row];
    ProfileUser *user = [FlatAPIClientManager sharedClient].profileUser;
    
    if ([currMessage.senderID isEqualToNumberWithNullCheck:user.userID] ) {
        return [JSBubbleImageViewFactory bubbleImageViewForType:type
                                                          color:[UIColor js_bubbleBlueColor]];
    }
    return [JSBubbleImageViewFactory bubbleImageViewForType:type
                                                      color:[UIColor js_bubbleLightGrayColor]];
    
}


- (void)configureCell:(JSBubbleMessageCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    if (cell.timestampLabel) {
        cell.timestampLabel.textColor = [UIColor grayColor];
        cell.timestampLabel.shadowOffset = CGSizeZero;
    }
    
    //    cell.bubbleView.textView.dataDetectorTypes = UIDataDetectorTypeNone;
    if ([cell messageType] == JSBubbleMessageTypeOutgoing)
        cell.bubbleView.textView.textColor = [UIColor whiteColor];
}


- (JSMessageInputViewStyle)inputViewStyle
{
    return JSMessageInputViewStyleFlat;
}

- (NSInteger)tableView:(UITableView *)tableView
 numberOfRowsInSection:(NSInteger)section
{
    return [self.messages count];
}

- (BOOL)allowsPanToDismissKeyboard
{
    return YES;
}


+ (UIImage *) imageWithView:(UIView *)view
{
    UIGraphicsBeginImageContextWithOptions(view.bounds.size, view.opaque, 0.0);
    [view.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage * img = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return img;
}


-(UIImageView *)avatarImageViewForRowAtIndexPath:(NSIndexPath *)indexPath sender:(NSString *)sender {
    Message *currMessage = [self.messages objectAtIndex:indexPath.row];
    UIImage * image;
    if ([currMessage.senderID isEqualToNumberWithNullCheck:[NSNumber numberWithInt:1]]) {
        //if it's the initial greeting message
        image = [JSAvatarImageFactory avatarImageNamed:@"infoicon3" croppedToCircle:YES];
    }
    else if (![currMessage.senderID isEqualToNumberWithNullCheck:[NSNumber numberWithInt:0]]) {
        static NSMutableDictionary * avatarDict = nil;
        static NSNumber * oldGroupID = nil;
        NSNumber * currGroupID = [FlatAPIClientManager sharedClient].profileUser.groupID;
        if (![currGroupID isEqualToNumberWithNullCheck:oldGroupID]) {
            avatarDict = nil;
            oldGroupID = currGroupID;
        }
        
        if (!avatarDict) avatarDict = [[NSMutableDictionary alloc]init];
        UIView* ret = [avatarDict objectForKey:currMessage.senderID];
        if (ret)
            return [[UIImageView alloc]initWithImage: [HomeViewController imageWithView:ret]];
        
        UIColor * bubbleColor = [ProfileUser getColorFromUserID:currMessage.senderID];
        UIView * backView = [[UIView alloc] initWithFrame:CGRectMake(40,15,70,70)];
        backView.backgroundColor = [UIColor whiteColor];
        UIView * circleView = [[UIView alloc] initWithFrame:CGRectMake(5,6,60,60)];
        circleView.alpha = 1.0;
        circleView.layer.cornerRadius = 30;
        circleView.backgroundColor = bubbleColor;
        
        UILabel *name = [[UILabel alloc]initWithFrame:CGRectMake(20, 1, 70, 70)];
        name.textColor = [UIColor whiteColor];
        name.font = [UIFont fontWithName:@"courier" size:25];
        
        [backView addSubview:circleView];
        [backView addSubview:name];
        name.text = [ProfileUser getInitialsFromUserID:currMessage.senderID];
        if (![name.text isEqualToString:@"--"])
            [avatarDict setObject:backView forKey:currMessage.senderID];
        
        return [[UIImageView alloc]initWithImage: [HomeViewController imageWithView:backView]];
    }
    else {
        //it's a calendar event message
        image = [JSAvatarImageFactory avatarImageNamed:@"calendar+icon" croppedToCircle:NO];
    }
    return [[UIImageView alloc] initWithImage:image];
}


-(BOOL)shouldPreventScrollToBottomWhileUserScrolling {
    return YES;
}

#pragma mark - Messages view data source: REQUIRED
- (Message *)messageForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [self.messages objectAtIndex:indexPath.row];
}



@end