//
//  AuthenticationHelper.h
//  flat
//
//  Created by Zachary Palacios on 1/19/14.
//  Copyright (c) 2014 cs194. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^HelperProfileUserCompletionHandler)(NSError *, ProfileUser *);

@interface AuthenticationHelper : NSObject

+ (void)signUpWithFacebook:(NSString *)fbToken
                  andEmail:(NSString *)email
              andFirstName:(NSString *)firstName
               andLastName:(NSString *)lastName
       withCompletionBlock:(HelperProfileUserCompletionHandler)completionBlock;

@end
