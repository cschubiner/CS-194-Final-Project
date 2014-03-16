//
//  AuthenticationHelper.m
//  flat
//
//  Created by Zachary Palacios on 1/19/14.
//  Copyright (c) 2014 cs194. All rights reserved.
//

#import "AuthenticationHelper.h"
#import "AuthenticationNetworkRequest.h"

@implementation AuthenticationHelper

+ (void)signUpWithFacebook:(NSString *)fbToken
                  andEmail:(NSString *)email
              andFirstName:(NSString *)firstName
               andLastName:(NSString *)lastName
       withCompletionBlock:(HelperProfileUserCompletionHandler)completionBlock
{
    DLog(@"in Authentication helper before signing up user");
    [AuthenticationNetworkRequest signUpWithFacebook:fbToken
                                            andEmail:email
                                        andFirstName:firstName
                                         andLastName:lastName
                                  andCompletionBlock:^(NSError *error, ProfileUser *user)
     {
         DLog(@"in completion block in Authentication Helper");
         completionBlock(error, user);
     }];
    
}

@end
