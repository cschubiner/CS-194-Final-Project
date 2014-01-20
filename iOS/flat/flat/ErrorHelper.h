//
//  ErrorHelper.h
//  flat
//
//  Created by Zachary Palacios on 1/19/14.
//  Copyright (c) 2014 cs194. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ErrorHelper : NSObject

+ (NSError *)authenticationFailedWithDescription:(NSString *)description;

+ (NSError *)parsingErrorWithDescription:(NSString *)description;

+ (NSError *)apiErrorFromDictionary:(NSDictionary *)dictionary;

@end
