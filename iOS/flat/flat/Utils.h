//
//  Utils.h
//  Flat
//
//  Created by Clay Schubiner on 3/2/14.
//  Copyright (c) 2014 cs194. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Utils : NSObject

+(NSNumber*)numberFromString:(NSString*)str;
+(NSDate*)dateFromString:(NSString*)str;
+(NSString*)formatDate:(NSDate*) date ;
+(NSString*)formatDate:(NSDate*) date withFormat:(NSString*) formatStr ;
@end
