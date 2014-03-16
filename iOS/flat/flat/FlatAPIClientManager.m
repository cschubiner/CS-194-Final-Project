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

-(void)turnOnLoadingView:(UIView*)view {
    if (self.loadingView != nil) return;
    self.loadingView = [[SAMLoadingView alloc] initWithFrame:view.bounds];
    self.loadingView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [view addSubview:self.loadingView];
}

-(void)turnOffLoadingView {
    if (self.loadingView)
        [self.loadingView removeFromSuperview];
    self.loadingView = nil;
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

-(BOOL)userIDIsInMyGroup:(NSNumber*)userID {
    for (ProfileUser* user in [[FlatAPIClientManager sharedClient]users]) {
        if ([userID isEqualToNumber2:user.userID])
            return true;
    }
    return false;
}

-(void)getAllCalendarEvents:(void(^)())callback{
    NSMutableArray*events = [[NSMutableArray alloc]init];
    
    Firebase* fCal = [[Firebase alloc] initWithUrl:@"https://flatapp.firebaseio.com/calendars"];
    [fCal observeEventType:FEventTypeValue withBlock:^(FDataSnapshot *snapshot) {
        for (FDataSnapshot * fCalUser in snapshot.children) {
            for (FDataSnapshot * fCalEvent in fCalUser.children) {
                EventModel * event = [[EventModel alloc]init];
                [event setTitle:[fCalEvent childSnapshotForPath:@"title"].value];
                [event setStartDate:[Utils dateFromString:[fCalEvent childSnapshotForPath:@"startDate"].value]];
                [event setEndDate:[Utils dateFromString:[fCalEvent childSnapshotForPath:@"endDate"].value]];
                [event setIsAllDay:[fCalEvent childSnapshotForPath:@"isAllDay"].value];
                NSNumber* userID = [Utils numberFromString:[fCalEvent childSnapshotForPath:@"userID"].value];
                [event setUserID:userID];
                
                if ([self userIDIsInMyGroup:userID] && [event.startDate isInPast] == false)
                    [events addObject:event];
            }
        }
        
        NSArray *sortedArray;
        sortedArray = [events sortedArrayUsingComparator:^NSComparisonResult(id a, id b) {
            NSDate *first = [(EventModel*)a startDate];
            NSDate *second = [(EventModel*)b startDate];
            return [first compare:second];
        }];
        [[FlatAPIClientManager sharedClient]setAllEvents:sortedArray];
        callback();
    }];
}

-(int)getNumUsersHome {
    [[[FlatAPIClientManager sharedClient]rootController]refreshUsers];
    int numUsersHome = 0;
    for (ProfileUser * user in [[FlatAPIClientManager sharedClient]users]) {
        if ([user.isNearDorm isEqualToNumber2:[NSNumber numberWithInt:IN_DORM_STATUS]])
            numUsersHome++;
    }
    [UIApplication sharedApplication].applicationIconBadgeNumber = numUsersHome;
    NSLog(@"there are currently %d users home.", numUsersHome);
    return numUsersHome;
}



@end
