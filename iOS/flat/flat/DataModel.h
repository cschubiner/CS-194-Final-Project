//
//  DataModel.h
//  flat
//
//  Created by Zachary Palacios on 2/18/14.
//  Copyright (c) 2014 cs194. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DataModel : NSObject

- (NSString*)userId;
- (NSString*)deviceToken;
- (void)setDeviceToken:(NSString*)token;

@end
