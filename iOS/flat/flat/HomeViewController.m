//
//  HomeViewController.m
//  flat
//
//  Created by Zachary Palacios on 1/19/14.
//  Copyright (c) 2014 cs194. All rights reserved.
//

#import "HomeViewController.h"
#import "JSMessage.h"
#import "MessageHelper.h"
#import <QuartzCore/QuartzCore.h>
#import "SAMLoadingView.h"


@interface HomeViewController ()
@property UIRefreshControl *refresh;
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
        [self performSegueWithIdentifier:@"HomeViewControllerToGroupTableViewController"
                                  sender:self];
    }
    self.justLoggedIn = NO;
}

-(void) resetTable {
    self.title = @"Flat";
    [self.tableView setBackgroundColor:[UIColor whiteColor]];
    [self.tableView setSeparatorColor:[UIColor whiteColor]];
    
    self.messageInputView.textView.placeHolder = @"Message";
    
    self.tableView.frame = CGRectMake(0, 64, self.view.frame.size.width, self.view.frame.size.height - self.messageInputView.frame.size.height - 64);
    //    self.tableView.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height - self.messageInputView.frame.size.height);
    
    //Pull to refresh
    self.refresh = [[UIRefreshControl alloc] init];
    self.refresh.tintColor = [UIColor grayColor]; //THIS THING
    self.refresh.attributedTitle = [[NSAttributedString alloc] initWithString:@"Pull to Refresh"];
    [self.refresh addTarget:self
                     action:@selector(getMessages)
           forControlEvents:UIControlEventValueChanged];
    [self.tableView addSubview:self.refresh];
}

- (void)viewDidLoad
{
    
    self.delegate = self;
    self.dataSource = self;
    self.justLoggedIn = YES;
    [super viewDidLoad];
    
    [[JSBubbleView appearance] setFont:[UIFont systemFontOfSize:16.0f]];
    
    [self resetTable];
    
    
    [self loadInitialMessages];
}

- (void)loadInitialMessages
{
    //    NSLog(@"Getting messages y");
    [[FlatAPIClientManager sharedClient]turnOnLoadingView:self.view];
    [ProfileUserHelper getUsersFromGroupID:[[FlatAPIClientManager sharedClient]profileUser].groupID withCompletionBlock:^(NSError * error, NSMutableArray * users) {
        [[FlatAPIClientManager sharedClient] setUsers:users];
        [[FlatAPIClientManager sharedClient].rootController refreshMessagesWithAnimation:NO scrollToBottom:YES];
    }];
}

- (void)didSendText:(NSString *)text
{
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
                            NSLog(@"About to reload data");
                            [self.tableView reloadData];
                            NSLog(@"Just reloaded data");
                        }
                        [self finishSend];
                    }];
}

- (JSBubbleMessageType)messageTypeForRowAtIndexPath:(NSIndexPath *)indexPath
{
    //    NSLog(@"Getting messages znz");
    JSMessage *currMessage = [self.messages objectAtIndex:indexPath.row];
    ProfileUser *user = [FlatAPIClientManager sharedClient].profileUser;
    
    if ([currMessage.senderID isEqualToNumber2: user.userID]) {
        return JSBubbleMessageTypeOutgoing;
    }
    return JSBubbleMessageTypeIncoming;
}


- (UIImageView *)bubbleImageViewWithType:(JSBubbleMessageType)type
                       forRowAtIndexPath:(NSIndexPath *)indexPath
{
    //    NSLog(@"Getting messages zzk");
    JSMessage *currMessage = [self.messages objectAtIndex:indexPath.row];
    ProfileUser *user = [FlatAPIClientManager sharedClient].profileUser;
    if ([currMessage.senderID isEqualToNumber2:user.userID] ) {
        return [JSBubbleImageViewFactory bubbleImageViewForType:type
                                                          color:[UIColor js_bubbleBlueColor]];
    }
    return [JSBubbleImageViewFactory bubbleImageViewForType:type
                                                      color:[UIColor js_bubbleLightGrayColor]];
    
}


- (void)configureCell:(JSBubbleMessageCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    //    NSLog(@"Getting messages zzz");
    //    if (cell.timestampLabel) {
    //        cell.timestampLabel.textColor = [UIColor lightGrayColor];
    //        cell.timestampLabel.shadowOffset = CGSizeZero;
    //    }
    
    cell.bubbleView.textView.dataDetectorTypes = UIDataDetectorTypeNone;
    if ([cell messageType] == JSBubbleMessageTypeOutgoing) {
        cell.bubbleView.textView.textColor = [UIColor whiteColor];
    }
    //    NSLog(@"Getting messages zzu");
}

- (JSMessagesViewTimestampPolicy)timestampPolicy
{
    return JSMessagesViewTimestampPolicyCustom;
}

- (JSMessagesViewAvatarPolicy)avatarPolicy
{
    return JSMessagesViewAvatarPolicyIncomingOnly;
}

- (JSMessagesViewSubtitlePolicy)subtitlePolicy
{
    return JSMessagesViewSubtitlePolicyIncomingOnly;
}

- (JSMessageInputViewStyle)inputViewStyle
{
    return JSMessageInputViewStyleFlat;
}

- (NSString *)textForRowAtIndexPath:(NSIndexPath *)indexPath
{
    //    NSLog(@"Getting messages e");
    return [[self.messages objectAtIndex:indexPath.row] text];
}

- (NSDate *)timestampForRowAtIndexPath:(NSIndexPath *)indexPath
{
    //    NSLog(@"Getting messages r");
    return [[self.messages objectAtIndex:indexPath.row] date];
}


-(NSString *)subtitleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    //    NSLog(@"Getting messages t");
    JSMessage *currMessage = [self.messages objectAtIndex:indexPath.row];
    return currMessage.sender;
}

- (NSInteger)tableView:(UITableView *)tableView
 numberOfRowsInSection:(NSInteger)section
{
    
    //    NSLog(@"Getting messages o");
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


-(UIImageView *)avatarImageViewForRowAtIndexPath:(NSIndexPath *)indexPath {
    JSMessage *currMessage = [self.messages objectAtIndex:indexPath.row];
    UIImage * image;
    if ([currMessage.senderID isEqualToNumber2:[NSNumber numberWithInt:1]]) {
        //if it's the initial greeting message
        image = [JSAvatarImageFactory avatarImageNamed:@"infoicon3" croppedToCircle:YES];
    }
    else if (![currMessage.senderID isEqualToNumber2:[NSNumber numberWithInt:0]]) {
        static NSMutableDictionary * avatarDict = nil;
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
        [avatarDict setObject:backView forKey:currMessage.senderID];
        
        return [[UIImageView alloc]initWithImage: [HomeViewController imageWithView:backView]];
        
    }
    else {
        //if it's a calendar event message
        image = [JSAvatarImageFactory avatarImageNamed:@"calendar+icon" croppedToCircle:NO];
    }
    return [[UIImageView alloc] initWithImage:image];
}


#pragma mark - Messages view data source: REQUIRED
- (JSMessage *)messageForRowAtIndexPath:(NSIndexPath *)indexPath
{
    //    NSLog(@"Getting messages h");
    return [self.messages objectAtIndex:indexPath.row];
}

@end