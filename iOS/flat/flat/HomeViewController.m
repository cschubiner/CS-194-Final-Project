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

@interface HomeViewController ()
@property UIRefreshControl *refresh;
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
    NSLog(@"Getting messages");
    [MessageHelper getMessagesWithCompletionBlock:^(NSError *error, NSArray *messages) {
        NSLog(@"MESSAGES ARE %@", messages);
        self.messages = [messages mutableCopy];
        [self.tableView reloadData];
        [self.refresh endRefreshing];
        [self scrollToBottomAnimated:YES];
    }];
}

- (void)viewDidLoad
{
    self.delegate = self;
    self.dataSource = self;
    [super viewDidLoad];
    
    [[JSBubbleView appearance] setFont:[UIFont systemFontOfSize:16.0f]];
    
    self.title = @"flat";
    
    self.messageInputView.textView.placeHolder = @"Message";
    
    self.tableView.frame = CGRectMake(0, 64, self.view.frame.size.width, self.view.frame.size.height - 128);
    
    //Pull to refresh
    self.refresh = [[UIRefreshControl alloc] init];
    self.refresh.tintColor = [UIColor grayColor]; //THIS THING
    self.refresh.attributedTitle = [[NSAttributedString alloc] initWithString:@"Pull to Refresh"];
    [self.refresh addTarget:self
                action:@selector(getMessages)
      forControlEvents:UIControlEventValueChanged];
    [self.tableView addSubview:self.refresh];
    
    [self loadInitialMessages];
}

- (void)loadInitialMessages
{
    [MessageHelper getMessagesWithCompletionBlock:^(NSError *error, NSArray *messages) {
        self.messages = [messages mutableCopy];
        [self.tableView reloadData];
        [self scrollToBottomAnimated:NO];
    }];
}

- (void)didSendText:(NSString *)text
{
    [MessageHelper sendMessageWithText:text
                    andCompletionBlock:^(NSError *error, NSArray *messages) {
                        if (error) {
                            //Diplay message did not send error
                        } else {
                            NSLog(@"MESSAGES: %@", messages);
                            self.messages = [messages mutableCopy];
                            [JSMessageSoundEffect playMessageSentSound];
                            NSLog(@"About to reload data");
                            [self.tableView reloadData];
                            NSLog(@"Already loaded data");
                            self.messageInputView.textView.text = @"";
                            [self scrollToBottomAnimated:YES];
                            [self finishSend];
                        }
                    }];
}

- (JSBubbleMessageType)messageTypeForRowAtIndexPath:(NSIndexPath *)indexPath
{
    JSMessage *currMessage = [self.messages objectAtIndex:indexPath.row];
    ProfileUser *user = [FlatAPIClientManager sharedClient].profileUser;
    if (currMessage.senderID == [user.userID intValue]) {
        return JSBubbleMessageTypeOutgoing;
    }
    return JSBubbleMessageTypeIncoming;
}

- (UIImageView *)bubbleImageViewWithType:(JSBubbleMessageType)type
                       forRowAtIndexPath:(NSIndexPath *)indexPath
{
    JSMessage *currMessage = [self.messages objectAtIndex:indexPath.row];
    ProfileUser *user = [FlatAPIClientManager sharedClient].profileUser;
    if (currMessage.senderID == [user.userID intValue]) {
        return [JSBubbleImageViewFactory bubbleImageViewForType:type
                                                          color:[UIColor js_bubbleBlueColor]];
    }
    return [JSBubbleImageViewFactory bubbleImageViewForType:type
                                                      color:[UIColor js_bubbleLightGrayColor]];
}

- (JSMessagesViewTimestampPolicy)timestampPolicy
{
    return JSMessagesViewTimestampPolicyAll;
}

- (JSMessagesViewAvatarPolicy)avatarPolicy
{
    return JSMessagesViewAvatarPolicyNone;
}

- (JSMessagesViewSubtitlePolicy)subtitlePolicy
{
    return JSMessagesViewSubtitlePolicyNone;
}

- (JSMessageInputViewStyle)inputViewStyle
{
    return JSMessageInputViewStyleFlat;
}

- (NSString *)textForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [[self.messages objectAtIndex:indexPath.row] text];
}

- (NSDate *)timestampForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [[self.messages objectAtIndex:indexPath.row] date];
}

- (UIImageView *)avatarImageViewForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return nil;
}

- (NSString *)subtitleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return nil;
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

#pragma mark - Messages view data source: REQUIRED

- (JSMessage *)messageForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [self.messages objectAtIndex:indexPath.row];
}

@end