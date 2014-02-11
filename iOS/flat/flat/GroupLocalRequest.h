//
//  GroupLocalRequest.h
//  flat
//
//  Created by Clay Schubiner on 1/19/14.
//  Copyright (c) 2014 cs194. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Group+Json.h"

@interface GroupLocalRequest : NSObject

+ (Group *)getGroup;

+ (void)deleteCurrentGroupFromStore;

@end
