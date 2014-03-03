//
//  JSMessage.m
//  Pods
//
//  Created by Zachary Palacios on 1/26/14.
//
//

#import "JSMessage.h"

@implementation JSMessage

#pragma mark - Initialization

- (instancetype)initWithText:(NSString *)text
                      sender:(NSString *)sender
                senderUserId:(NSString *)senderID
                        date:(NSDate *)date
{
    self = [super init];
    if (self) {
        _text = text ? text : @" ";
        _sender = sender;
        _senderID = [Utils numberFromString:senderID]; //ignoring this warning. Xcode is broken
        _date = date;
    }
    return self;
}

- (void)dealloc
{
    _text = nil;
    _sender = nil;
    _date = nil;
}

#pragma mark - NSCoding

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    if (self) {
        _text = [aDecoder decodeObjectForKey:@"text"];
        _sender = [aDecoder decodeObjectForKey:@"sender"];
        _senderID = [aDecoder decodeObjectForKey:@"senderID"];
        _date = [aDecoder decodeObjectForKey:@"date"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:self.text forKey:@"text"];
    [aCoder encodeObject:self.sender forKey:@"sender"];
    [aCoder encodeObject:self.senderID forKey:@"senderID"];
    [aCoder encodeObject:self.date forKey:@"date"];
}

#pragma mark - NSCopying

- (id)copyWithZone:(NSZone *)zone
{
    return [[[self class] allocWithZone:zone] initWithText:[self.text copy]
                                                    sender:[self.sender copy]
                                              senderUserId:[self.senderID copy]
                                                      date:[self.date copy]];
}

@end
