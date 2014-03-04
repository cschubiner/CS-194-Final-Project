//
//  NSValue+NSValueEqualTo.m
//  Flat
//
//  Created by Clay Schubiner on 3/2/14.
//  Copyright (c) 2014 cs194. All rights reserved.
//

#import "NSValue+NSValueEqualTo.h"

@implementation NSValue (NSValueEqualTo)


- (BOOL)isEqualToNumber2:(NSNumber *)number {
    if (number == nil || (NSNull*)number == [NSNull null]) {
        NSLog(@"inputted number is null. Returning false");
        return false;
    }
    return [(NSNumber*)self isEqualToNumber:number];
}

@end
