//
//  ErrorHelper.m
//  flat
//
//  Created by Zachary Palacios on 1/19/14.
//  Copyright (c) 2014 cs194. All rights reserved.
//

#import "ErrorHelper.h"

@implementation ErrorHelper

+ (NSError *)errorWithDomain:(NSString *)domain
                     andCode:(NSInteger)code
              andDescription:(NSString *)description
                  andMessage:(NSString *)message
{
    NSMutableDictionary *errorDetail = [NSMutableDictionary dictionary];
    if (description) {
        [errorDetail setObject:description forKey:@"description"];
    }
    
    if (message) {
        [errorDetail setObject:message forKey:@"message"];
    }
    
    NSError *error = [NSError errorWithDomain:domain
                                         code:code
                                     userInfo:errorDetail];
    return error;
}

+ (NSError *)authenticationFailedWithDescription:(NSString *)description
{
    return [self errorWithDomain:@"User" andCode:401
                  andDescription:description andMessage:@"AuthenticationFailed"];
}

+ (NSError *)parsingErrorWithDescription:(NSString *)description
{
    return [self errorWithDomain:@"Content" andCode:500
                  andDescription:description andMessage:@"Parsing Failed"];
}

+ (NSError *)apiErrorFromDictionary:(NSDictionary *)dictionary
{
    NSError *error;
    if ([[dictionary objectForKey:@"type"]  isEqual: @"error"] ||
        [dictionary objectForKey:@"error"])
    {
        NSString *domain = @"JSON";
        NSString *message = [dictionary objectForKey:@"message"];
        NSString *description = [dictionary objectForKey:@"full_message"];
        NSInteger code = 400;
        if ([message isEqualToString: @"AuthenticationError"])
        {
            domain = @"User";
            code = 401;
        } else if ([message isEqualToString:@"ObjectNotFoundError"]) {
            domain = @"Object";
            code = 404;
        } else if ([message isEqualToString:@"DuplicateUsernameError"]) {
            domain = @"User";
            code = 409;
        } else if ([message isEqualToString:@"UserCreateError"]) {
            domain = @"User";
            code = 406;
        }
        error = [self errorWithDomain:domain andCode:code
                       andDescription:description andMessage:message];
    }
    return error;
}

@end
