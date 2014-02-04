//
//  HomeViewController.m
//  flat
//
//  Created by Zachary Palacios on 1/19/14.
//  Copyright (c) 2014 cs194. All rights reserved.
//

#import "HomeViewController.h"
#import "JSMessage.h"

@interface HomeViewController ()
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

- (void)viewDidLoad
{
    self.delegate = self;
    self.dataSource = self;
    [super viewDidLoad];
    
    [[JSBubbleView appearance] setFont:[UIFont systemFontOfSize:16.0f]];
    
    self.title = @"flat";
    
    self.messageInputView.textView.placeHolder = @"Message";
    
    self.tableView.frame = CGRectMake(0, 64, self.view.frame.size.width, self.view.frame.size.height);
    
    NSLog(@"before creating messages");
    self.messages = [[NSMutableArray alloc] initWithObjects:
                     [[JSMessage alloc] initWithText:@"Hey"
                                              sender:@"Zach"
                                                date:[NSDate distantPast]],
                     [[JSMessage alloc] initWithText:@"Sup"
                                              sender:@"Zach"
                                                date:[NSDate distantPast]],
                     [[JSMessage alloc] initWithText:@"When are you guys going to be back in the room?"
                                              sender:@"Zach"
                                                date:[NSDate distantPast]],
                     [[JSMessage alloc] initWithText:@"Uhhh idk why?"
                                              sender:@"Zach"
                                                date:[NSDate distantPast]],
                     [[JSMessage alloc] initWithText:@"I've got this skype interview. Gimme an hour"
                                              sender:@"Zach"
                                                date:[NSDate date]],
                     [[JSMessage alloc] initWithText:@"Aight np"
                                              sender:@"Zach"
                                                date:[NSDate date]],
                     nil];
}

- (void)didSendText:(NSString *)text
{
    ProfileUser *user = [FlatAPIClientManager sharedClient].profileUser;
    [JSMessageSoundEffect playMessageSentSound];
    [self.messages addObject:[[JSMessage alloc] initWithText:text
                                                      sender:user.firstName
                                                        date:[NSDate date]]];
    [self.tableView reloadData];
    self.messageInputView.textView.text = @"";
    [self scrollToBottomAnimated:YES];

}

- (JSBubbleMessageType)messageTypeForRowAtIndexPath:(NSIndexPath *)indexPath
{
    JSMessage *currMessage = [self.messages objectAtIndex:indexPath.row];
    NSString *userName = [FlatAPIClientManager sharedClient].profileUser.firstName;
    NSLog(@"%@ %@", currMessage.sender, userName);
    if ([currMessage.sender isEqualToString:userName]) {
        return JSBubbleMessageTypeOutgoing;
    }
    return JSBubbleMessageTypeIncoming;
}

- (UIImageView *)bubbleImageViewWithType:(JSBubbleMessageType)type
                       forRowAtIndexPath:(NSIndexPath *)indexPath
{
    JSMessage *currMessage = [self.messages objectAtIndex:indexPath.row];
    NSString *userName = [FlatAPIClientManager sharedClient].profileUser.firstName;
    if ([currMessage.sender isEqualToString:userName]) {
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