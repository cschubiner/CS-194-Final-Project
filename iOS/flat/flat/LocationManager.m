//
//  LocationManager.m
//  flat
//
//  Created by Clay Schubiner on 2/2/14.
//  Copyright (c) 2014 cs194. All rights reserved.
//

#import "LocationManager.h"
#import "FlatAPIClientManager.h"
#import "Group.h"
#import "ProfileUserNetworkRequest.h"
#import "GroupNetworkRequest.h"

@implementation LocationManager



+ (instancetype)sharedClient {
    static LocationManager *_sharedClient = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedClient = [[self alloc] init];
        _sharedClient.locationManager = [[CLLocationManager alloc] init];
        _sharedClient.locationManager.delegate = _sharedClient;
        _sharedClient.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
        _sharedClient.locationManager.distanceFilter = 20; // meters
        [_sharedClient.locationManager startMonitoringForRegion:[_sharedClient getGroupLocationRegion]];
        [_sharedClient.locationManager startUpdatingLocation];
    });
    return _sharedClient;
}


#pragma mark - CLLocationManagerDelegate

- (void)locationManager:(CLLocationManager *)manager didEnterRegion:(CLRegion *)region
{
    DLog(@"in region");
    int dormState = IN_DORM_STATUS;
    if ([self regionIsEmpty:region])
        dormState = NOT_BROADCASTING_DORM_STATUS;
    [self handleUserDormState:[NSNumber numberWithInt:dormState]];
}

- (void)locationManager:(CLLocationManager *)manager didExitRegion:(CLRegion *)region
{
    DLog(@"not in region");
    int dormState = AWAY_DORM_STATUS;
    if ([self regionIsEmpty:region])
        dormState = NOT_BROADCASTING_DORM_STATUS;
    [self handleUserDormState:[NSNumber numberWithInt:dormState]];
}
- (void)locationManager:(CLLocationManager *)manager didStartMonitoringForRegion:(CLRegion *)region
{
    DLog(@"monitoring region");
    if ([self regionIsEmpty:region]) {
        [manager stopMonitoringForRegion:region];
        [self stopMonitoringAllRegions];
        [manager stopUpdatingLocation];
        [self handleUserDormState:[NSNumber numberWithInt:NOT_BROADCASTING_DORM_STATUS]];
    }
}


-(bool)regionIsEmpty:(CLRegion*)region {
    return region.center.latitude <= .001 && region.center.latitude >= -.001
    && region.center.longitude <= .001 && region.center.longitude >= -.001;
}

- (void)handleUserDormState:(NSNumber*)isInDormStatus {
    if (canUpdateDormState == false) return;
    canUpdateDormState = false;
    
    ProfileUser * currUser = [FlatAPIClientManager sharedClient].profileUser;
    currUser.isNearDorm = isInDormStatus;
    [ProfileUserNetworkRequest setUserLocationWithUserID:currUser.userID andIsInDorm:isInDormStatus];
    [NSTimer scheduledTimerWithTimeInterval:5.0 target:self selector:@selector(allowDormStateUpdate) userInfo:nil repeats:NO];
}
bool canUpdateDormState = true;
-(void)allowDormStateUpdate {
    canUpdateDormState = true;
}

- (void)locationManager:(CLLocationManager *)manager
      didDetermineState:(CLRegionState)state forRegion:(CLRegion *)region
{
    static BOOL firstTime = true;
    if (firstTime) {
        firstTime = false;
        NSLog(@"state: %d", state);
        DLog(@"determined initial state");
        int dormState = AWAY_DORM_STATUS;
        if ([self regionIsEmpty:region])
            dormState = NOT_BROADCASTING_DORM_STATUS;
        else if (state == CLRegionStateInside)
            dormState = IN_DORM_STATUS;
        else if (state == CLRegionStateUnknown)
            dormState = NOT_BROADCASTING_DORM_STATUS;
        [self handleUserDormState: [NSNumber numberWithInt: dormState]];
    }
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    NSLog(@"locationManager didFailWithError: %@", error);
}

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation
{
    if (self.shouldSetDormLocation) {
        [self setShouldSetDormLocation:false];
        
        DLog(@"setting dorm location to: ");
        NSLog(@"latitude %+.6f, longitude %+.6f\n",
              newLocation.coordinate.latitude,
              newLocation.coordinate.longitude);
        //        Group * group = [[FlatAPIClientManager sharedClient] group];
        
        [GroupNetworkRequest setGroupLocation:[[FlatAPIClientManager sharedClient]profileUser].groupID withLocation:newLocation withCompletionBlock:^(NSError * error, Group * group) {
            if (error == nil) {
                [[[FlatAPIClientManager sharedClient] group] setLatLocation:[NSNumber numberWithDouble:newLocation.coordinate.latitude]];
                [[[FlatAPIClientManager sharedClient] group] setLongLocation:[NSNumber numberWithDouble:newLocation.coordinate.longitude]];
                [self handleUserDormState:[NSNumber numberWithInt:IN_DORM_STATUS]];
                [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreWithCompletion:nil];
                CLLocationManager * manager = [[LocationManager sharedClient] locationManager];
                [manager stopMonitoringForRegion:manager.monitoredRegions.anyObject];
                [manager startMonitoringForRegion:[[LocationManager sharedClient] getGroupLocationRegion]];
            }
        }];
        
    }
    
    NSSet * monitoredRegions = self.locationManager.monitoredRegions;
    if(monitoredRegions)
    {
        [monitoredRegions enumerateObjectsUsingBlock:^(CLRegion *region,BOOL *stop)
         {
             CLLocationCoordinate2D centerCoords =region.center;
             CLLocationCoordinate2D currentCoords= CLLocationCoordinate2DMake(newLocation.coordinate.latitude,newLocation.coordinate.longitude);
             CLLocationDistance radius = region.radius;
             
             NSNumber * currentLocationDistance =[self calculateDistanceInMetersBetweenCoord:currentCoords coord:centerCoords];
             
             int dormState = AWAY_DORM_STATUS;
             if ([self regionIsEmpty:region])
                 dormState = NOT_BROADCASTING_DORM_STATUS;
             else if ([currentLocationDistance floatValue] < radius)
                 dormState = IN_DORM_STATUS;
             [self handleUserDormState: [NSNumber numberWithInt: dormState]];
         }];
    }
    //Stop Location Updation, we dont need it now.
    [self.locationManager stopUpdatingLocation];
}

- (NSNumber*)calculateDistanceInMetersBetweenCoord:(CLLocationCoordinate2D)coord1 coord:(CLLocationCoordinate2D)coord2 {
    NSInteger nRadius = 6371; // Earth's radius in Kilometers
    double latDiff = (coord2.latitude - coord1.latitude) * (M_PI/180);
    double lonDiff = (coord2.longitude - coord1.longitude) * (M_PI/180);
    double lat1InRadians = coord1.latitude * (M_PI/180);
    double lat2InRadians = coord2.latitude * (M_PI/180);
    double nA = pow ( sin(latDiff/2), 2 ) + cos(lat1InRadians) * cos(lat2InRadians) * pow ( sin(lonDiff/2), 2 );
    double nC = 2 * atan2( sqrt(nA), sqrt( 1 - nA ));
    double nD = nRadius * nC;
    // convert to meters
    return @(nD*1000);
}

- (CLRegion*)getGroupLocationRegion
{
    NSString *identifier = @"dormLocation";
    CLLocationDegrees latitude = [[[[FlatAPIClientManager sharedClient] group] latLocation] doubleValue];
    CLLocationDegrees longitude = [[[[FlatAPIClientManager sharedClient] group] longLocation] doubleValue];
    CLLocationCoordinate2D centerCoordinate = CLLocationCoordinate2DMake(latitude, longitude);
    CLLocationDistance regionRadius = 60.0f; //geofence radius
    
    if(regionRadius > self.locationManager.maximumRegionMonitoringDistance)
    {
        regionRadius = self.locationManager.maximumRegionMonitoringDistance;
    }
    
    return [[CLCircularRegion alloc] initWithCenter:centerCoordinate
                                             radius:regionRadius
                                         identifier:identifier];
}

- (void)stopMonitoringAllRegions {
    for (CLRegion *region in [[[LocationManager sharedClient].locationManager monitoredRegions] allObjects]) {
        [[LocationManager sharedClient].locationManager stopMonitoringForRegion:region];
    }
}
@end
