//
//  AuthenticationNetworkRequest.h
//  flat
//
//  Created by Zachary Palacios on 1/19/14.
//  Copyright (c) 2014 cs194. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AuthenticationNetworkRequest : NSObject

typedef void (^RequestProfileUserCompletionHandler)(NSError *, ProfileUser *);

+ (void)signinWithFacebook:(NSString *)fbAccessToken
        andCompletionBlock:(RequestProfileUserCompletionHandler)completionBlock;

+ (void)signUpWithFacebook:(NSString *)fbAccessToken
                  andEmail:(NSString *)email
              andFirstName:(NSString *)firstName
               andLastName:(NSString *)lastName
        andCompletionBlock:(RequestProfileUserCompletionHandler)completionBlock;

@end
