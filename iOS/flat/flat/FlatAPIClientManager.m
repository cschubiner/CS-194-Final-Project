//
//  FlatAPIClientManager.m
//  flat
//
//  Created by Zachary Palacios on 1/19/14.
//  Copyright (c) 2014 cs194. All rights reserved.
//

#import "FlatAPIClientManager.h"
#import <EventKit/EventKit.h>
#import "EventModel.h"
#import <Firebase/Firebase.h>

static NSString * const FLATAPIBASEURLSTRING = @"http://flatappapi.appspot.com";
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



-(void)getAllCalendarEvents:(void(^)())callback{
    NSMutableArray*events = [[NSMutableArray alloc]init];
    
    Firebase* fCal = [[Firebase alloc] initWithUrl:@"https://flatapp.firebaseio.com/calendars"];
    [fCal observeEventType:FEventTypeValue withBlock:^(FDataSnapshot *snapshot) {
        for (FDataSnapshot * fCalUser in snapshot.children) {
            for (FDataSnapshot * fCalEvent in fCalUser.children) {
//                NSLog(@"child%@", fCalEvent.value);
                EventModel * event = [[EventModel alloc]init];
//                NSLog(@"title: %@", [fCalEvent childSnapshotForPath:@"title"].value);
//                NSLog(@"endDate: %@",[fCalEvent childSnapshotForPath:@"endDate"].value);
                [event setTitle:[fCalEvent childSnapshotForPath:@"title"].value];
                [event setStartDate:[Utils dateFromString:[fCalEvent childSnapshotForPath:@"startDate"].value]];
                [event setEndDate:[Utils dateFromString:[fCalEvent childSnapshotForPath:@"endDate"].value]];
                [event setUserID:[Utils numberFromString:[fCalEvent childSnapshotForPath:@"userID"].value]];
                
//                [event setStartDate:[Utils correctTimeZone:event.startDate]];
//                [event setEndDate:[Utils correctTimeZone:event.endDate]];
                [events addObject:event];
            }
        }
        
//        NSLog(@"events: %@",events);
        [[FlatAPIClientManager sharedClient]setAllEvents:events];
        callback();
    }];
}

@end
