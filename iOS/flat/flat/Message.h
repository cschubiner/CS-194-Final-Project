//
//  Message.h
//  Pods
//
//  Created by Zachary Palacios on 1/26/14.
//
//

#import <Foundation/Foundation.h>
#import "MessageData.h"
#import "ISO8601DateFormatter.h"

/**
 *  A `Message` object represents a single user message. This is a concrete class that implements the `MessageData` protocol. It contains the message text, its sender, and the date that the message was sent.
 */
@interface Message : NSObject <JSMessageData, NSCoding, NSCopying>

/**
 *  The body text of the message. The default value is the empty string `@" "`. This value must not be `nil`.
 */
@property (copy, nonatomic) NSString *text;

/**
 *  The name of user who sent the message. The default value is `nil`.
 */
@property (copy, nonatomic) NSString *sender;

@property (copy, nonatomic) NSNumber *senderID;

/**
 *  The date that the message was sent. The default value is `nil`.
 */
@property (strong, nonatomic) NSDate *date;

#pragma mark - Initialization

/**
 *  Initializes and returns a message object having the given text, sender, and date.
 *
 *  @param text   The body text of the message.
 *  @param sender The name of the user who sent the message.
 *  @param date   The date that the message was sent.
 *
 *  @return An initialized `JSMessage` object or `nil` if the object could not be successfully initialized.
 */
- (instancetype)initWithText:(NSString *)text
                      sender:(NSString *)sender
                senderUserId:(NSNumber*)senderID
                        date:(NSDate *)date;

@end