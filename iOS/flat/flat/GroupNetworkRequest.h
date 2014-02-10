//
//  GroupNetworkRequest.h
//  flat
//
//  Created by Clay Schubiner on 2/2/14.
//  Copyright (c) 2014 cs194. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Group.h"

@interface GroupNetworkRequest : NSObject

typedef void (^RequestGroupCompletionHandler)(NSError *, Group *);

+ (void) getGroupFromGroupID:(NSNumber*)groupID
         withCompletionBlock:(RequestGroupCompletionHandler)completionBlock;
@end
