//
//  FlatAPIClientManager.m
//  flat
//
//  Created by Zachary Palacios on 1/19/14.
//  Copyright (c) 2014 cs194. All rights reserved.
//

#import "FlatAPIClientManager.h"

static NSString * const FLATAPIBASEURLSTRING = @"";
static NSString * const KEY = @"";
static NSString * const SIGNATURE = @"";

@implementation FlatAPIClientManager

+ (instancetype)sharedClient {
    static FlatAPIClientManager *_sharedClient = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedClient = [[self alloc] initWithBaseURL:[NSURL URLWithString:FLATAPIBASEURLSTRING]];
        [_sharedClient setSecurityPolicy:[AFSecurityPolicy policyWithPinningMode:AFSSLPinningModePublicKey]];
    });
    return _sharedClient;
}

- (NSURLSessionDataTask *)GET:(NSString *)URLString
                   parameters:(NSDictionary *)parameters
                      success:(void ( ^ ) ( NSURLSessionDataTask *task , id responseObject ))success
                      failure:(void ( ^ ) ( NSURLSessionDataTask *task , NSError *error ))failure
{
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    NSMutableDictionary *authentication = [NSMutableDictionary dictionaryWithDictionary:@{@"key":KEY,@"signature":SIGNATURE}];
    if  (self.profileUser != nil)
    {
        [authentication setValue:self.profileUser.userID forKey:@"user_id"];
        [authentication setValue:self.profileUser.apiToken forKey:@"api_token"];
    }
    [params setDictionary:authentication];
    for(NSString *key in [parameters allKeys]) {
        [params setObject:[parameters objectForKey:key] forKey:key];
    }
    return [super GET:(NSString *)URLString parameters:(NSDictionary *)params
              success:(void ( ^ ) ( NSURLSessionDataTask *task , id responseObject ))success
              failure:(void ( ^ ) ( NSURLSessionDataTask *task , NSError *error ))failure];
}

//Override to include key and signature as parameters when making api calls.
- (NSURLSessionDataTask *)POST:(NSString *)URLString
                    parameters:(NSDictionary *)parameters
                       success:(void ( ^ ) ( NSURLSessionDataTask *task , id responseObject ))success
                       failure:(void ( ^ ) ( NSURLSessionDataTask *task , NSError *error ))failure
{
    NSLog(@"top of post request");
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    NSMutableDictionary *authentication = [NSMutableDictionary dictionaryWithDictionary:@{@"key":KEY,@"signature":SIGNATURE}];
    if  (self.profileUser != nil)
    {
        [authentication setValue:self.profileUser.userID forKey:@"user_id"];
        [authentication setValue:self.profileUser.apiToken forKey:@"api_token"];
    }
    [params setDictionary:authentication];
    for(NSString *key in [parameters allKeys]) {
        [params setObject:[parameters objectForKey:key] forKey:key];
    }
    NSLog(@"about to return post request");
    return [super POST:(NSString *)URLString parameters:(NSDictionary *)params
               success:(void ( ^ ) ( NSURLSessionDataTask *task , id responseObject ))success
               failure:(void ( ^ ) ( NSURLSessionDataTask *task , NSError *error ))failure];
}


@end
