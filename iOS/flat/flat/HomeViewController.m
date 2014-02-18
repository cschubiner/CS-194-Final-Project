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
        //        NSLog(@"MESSAGES ARE %@", messages);
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
    [ProfileUserHelper getUsersFromGroupID:[[FlatAPIClientManager sharedClient]profileUser].groupID withCompletionBlock:^(NSError * error, NSMutableArray * users) {
        [[FlatAPIClientManager sharedClient] setUsers:users];
        [MessageHelper getMessagesWithCompletionBlock:^(NSError *error, NSArray *messages) {
            self.messages = [messages mutableCopy];
            [self.tableView reloadData];
            [self scrollToBottomAnimated:NO];
        }];
    }];
}

- (void)didSendText:(NSString *)text
{
    [self.messageInputView.textView setText:nil];
    [self textViewDidChange:self.messageInputView.textView];
    if (text.length == 0)
        return;
    [MessageHelper sendMessageWithText:text
                    andCompletionBlock:^(NSError *error, NSArray *messages) {
                        if (error) {
                            //Diplay message did not send error
                            self.messageInputView.textView.text = text;
                        } else {
                            //    NSLog(@"MESSAGES: %@", messages);
                            self.messages = [messages mutableCopy];
                            [JSMessageSoundEffect playMessageSentSound];
                            NSLog(@"About to reload data");
                            [self.tableView reloadData];
                            NSLog(@"Just reloaded data");
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
    UIColor * bubbleColor = [ProfileUser getColorFromUserID:[NSNumber numberWithInt:currMessage.senderID]];
    if (currMessage.senderID == [user.userID intValue]) {
        return [JSBubbleImageViewFactory bubbleImageViewForType:type
                                                          color:bubbleColor];
    }
    return [JSBubbleImageViewFactory bubbleImageViewForType:type
                                                      color:bubbleColor];
}


- (void)configureCell:(JSBubbleMessageCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
//    if ([cell messageType] == JSBubbleMessageTypeOutgoing) {
//        cell.bubbleView.textView.textColor = [UIColor whiteColor];
//        
//        if ([cell.bubbleView.textView respondsToSelector:@selector(linkTextAttributes)]) {
//            NSMutableDictionary *attrs = [cell.bubbleView.textView.linkTextAttributes mutableCopy];
//            [attrs setValue:[UIColor blueColor] forKey:UITextAttributeTextColor];
//            
//            cell.bubbleView.textView.linkTextAttributes = attrs;
//        }
//    }
//    
//    //    [[JSBubbleView appearance] setFont:[UIFont systemFontOfSize:16.0f]];
//    
//    if (cell.timestampLabel) {
//        cell.timestampLabel.textColor = [UIColor lightGrayColor];
//        cell.timestampLabel.shadowOffset = CGSizeZero;
//    }
//    
//    
//    
//    if (cell.subtitleLabel) {
//        cell.subtitleLabel.textColor = [UIColor lightGrayColor];
//    }
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
    return JSMessagesViewSubtitlePolicyIncomingOnly;
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

-(NSString *)subtitleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    JSMessage *currMessage = [self.messages objectAtIndex:indexPath.row];
    return currMessage.sender;
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