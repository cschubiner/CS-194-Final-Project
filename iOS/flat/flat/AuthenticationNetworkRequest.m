//
//  AuthenticationNetworkRequest.m
//  flat
//
//  Created by Zachary Palacios on 1/19/14.
//  Copyright (c) 2014 cs194. All rights reserved.
//

#import "AuthenticationNetworkRequest.h"
#import "FlatAPIClientManager.h"
#import "ErrorHelper.h"
#import "ProfileUser+Json.h"

@implementation AuthenticationNetworkRequest

+ (void)signinWithFacebook:(NSString *)fbAccessToken
        andCompletionBlock:(RequestProfileUserCompletionHandler)completionBlock
{
    NSDictionary *params = @{@"token":fbAccessToken};
    [[FlatAPIClientManager sharedClient] POST:@"/user/login/facebook"
                                  parameters:params
                                     success:^(NSURLSessionDataTask *__unused task, id JSON)
     {
         for (id key in JSON) {
             NSLog(@"key: %@, value: %@ \n", key, [JSON objectForKey:key]);
         }
         
         NSError *error = [ErrorHelper apiErrorFromDictionary:JSON];
         if (!error) {
             NSMutableDictionary *userJSON = [JSON objectForKey:@"user"];
             ProfileUser *profileUser;
             profileUser = [ProfileUser getProfileUserObjectFromDictionary:userJSON
                                                   AndManagedObjectContext:[NSManagedObjectContext MR_defaultContext]];
             completionBlock(error, profileUser);
         } else {
             completionBlock(error, nil);
         }
     } failure:^(NSURLSessionDataTask *__unused task, NSError *error) {
         completionBlock(error,nil);
     }];
}

+ (void)signUpWithFacebook:(NSString *)fbAccessToken
                  andEmail:(NSString *)email
              andFirstName:(NSString *)firstName
               andLastName:(NSString *)lastName
        andCompletionBlock:(RequestProfileUserCompletionHandler)completionBlock
{
    NSDictionary *params = @{@"token":fbAccessToken,
                             @"email":email,
                             @"firstname":firstName,
                             @"lastname":lastName};
    
    [[FlatAPIClientManager sharedClient] POST:@"/user/signup/facebook"
                                  parameters:params
                                     success:^(NSURLSessionDataTask *__unused task, id JSON)
     {
         NSLog(@"success in authentication network reqest");
         NSError *error = [ErrorHelper apiErrorFromDictionary:JSON];
         
         for (id key in JSON) {
             NSLog(@"key: %@, value: %@ \n", key, [JSON objectForKey:key]);
         }
         
         if (!error) {
             NSMutableDictionary *userJSON = [JSON objectForKey:@"user"];
             ProfileUser *profileUser;
             profileUser = [ProfileUser getProfileUserObjectFromDictionary:userJSON
                                                   AndManagedObjectContext:[NSManagedObjectContext MR_defaultContext]];
             completionBlock(error, profileUser);
         } else {
             completionBlock(error, nil);
         }
     } failure:^(NSURLSessionDataTask *__unused task, NSError *error) {
         NSLog(@"failure in AuthenticationNetworkRequest");
         completionBlock(error,nil);
     }];
}

@end