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

@implementation LocationManager

+ (instancetype)sharedClient {
    static LocationManager *_sharedClient = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedClient = [[self alloc] init];
        _sharedClient.locationManager = [[CLLocationManager alloc] init];
        _sharedClient.locationManager.delegate = _sharedClient;
        _sharedClient.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
        _sharedClient.locationManager.distanceFilter = 200; // meters
        [_sharedClient.locationManager startMonitoringForRegion:[_sharedClient getGroupLocationRegion]];
        [_sharedClient.locationManager startUpdatingLocation];
    });
    return _sharedClient;
}

const static int IN_DORM_STATUS = 1;
const static int AWAY_DORM_STATUS = 0;
const static int NOT_BROADCASTING_DORM_STATUS = 2;


#pragma mark - CLLocationManagerDelegate

- (void)locationManager:(CLLocationManager *)manager didEnterRegion:(CLRegion *)region
{
    NSLog(@"in region");
}

- (void)locationManager:(CLLocationManager *)manager didExitRegion:(CLRegion *)region
{
    NSLog(@"not in region");
}
- (void)locationManager:(CLLocationManager *)manager didStartMonitoringForRegion:(CLRegion *)region
{
    NSLog(@"monitoring region");
}

- (void)handleUserDormState:(NSNumber*)isInDormStatus {
    ProfileUser * currUser = [FlatAPIClientManager sharedClient].profileUser;
    currUser.isNearDorm = isInDormStatus;
    [ProfileUserNetworkRequest setUserLocationWithUserID:currUser.userID andIsInDorm:isInDormStatus];
    if (isInDormStatus) {
        UIAlertView *errorAlert = [[UIAlertView alloc]
                                   initWithTitle:@"Entered dorm location" message:@"In dorm location" delegate:nil cancelButtonTitle:@"Dismiss" otherButtonTitles:nil];
        [errorAlert show];
    }
}

- (void)locationManager:(CLLocationManager *)manager
      didDetermineState:(CLRegionState)state forRegion:(CLRegion *)region
{
    NSLog(@"state: %d", state);
    NSLog(@"determined initial state");
    int dormState = AWAY_DORM_STATUS;
    if (state == CLRegionStateInside)
        dormState = IN_DORM_STATUS;
    else if (state == CLRegionStateUnknown)
        dormState = NOT_BROADCASTING_DORM_STATUS;
    [self handleUserDormState: [NSNumber numberWithInt: dormState]];
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    NSLog(@"locationManager didFailWithError: %@", error);
//    UIAlertView *errorAlert = [[UIAlertView alloc]
//                               initWithTitle:@"Error" message:@"Failed to Get Your Location" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
//    [errorAlert show];
}

//- (void)locationManager:(CLLocationManager *)manager
//     didUpdateLocations:(NSArray *)locations {
//    // If it's a relatively recent event, turn off updates to save power.
//    CLLocation* location = [locations lastObject];
//    NSDate* eventDate = location.timestamp;
//    NSTimeInterval howRecent = [eventDate timeIntervalSinceNow];
//    if (abs(howRecent) < 15.0) {
//        // If the event is recent, do something with it.
//        self.currentLongitude = location.coordinate.longitude;
//        self.currentLatitude = location.coordinate.latitude;
//        NSLog(@"latitude %+.6f, longitude %+.6f\n",
//              location.coordinate.latitude,
//              location.coordinate.longitude);
//    }
//}


- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation
{
    [self locationManager:manager didUpdateLocations:@[oldLocation, newLocation]];
    
    static BOOL firstTime=TRUE;
    if(firstTime)
    {
        firstTime = FALSE;
        NSSet * monitoredRegions = self.locationManager.monitoredRegions;
        if(monitoredRegions)
        {
            [monitoredRegions enumerateObjectsUsingBlock:^(CLRegion *region,BOOL *stop)
             {
                 NSString *identifer = region.identifier;
                 CLLocationCoordinate2D centerCoords =region.center;
                 CLLocationCoordinate2D currentCoords= CLLocationCoordinate2DMake(newLocation.coordinate.latitude,newLocation.coordinate.longitude);
                 CLLocationDistance radius = region.radius;
                 
                 NSNumber * currentLocationDistance =[self calculateDistanceInMetersBetweenCoord:currentCoords coord:centerCoords];
                 
                 int dormState = AWAY_DORM_STATUS;
                 if ([currentLocationDistance floatValue] < radius)
                     dormState = IN_DORM_STATUS;
                 [self handleUserDormState: [NSNumber numberWithInt: dormState]];
             }];
        }
        //Stop Location Updation, we dont need it now.
        [self.locationManager stopUpdatingLocation];
    }
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
    CLLocationDegrees latitude = [[[[FlatAPIClientManager sharedClient]group] latLocation] doubleValue];
    CLLocationDegrees longitude = [[[[FlatAPIClientManager sharedClient]group] longLocation] doubleValue];
    CLLocationCoordinate2D centerCoordinate = CLLocationCoordinate2DMake(latitude, longitude);
    CLLocationDistance regionRadius = 50.0f; //geofence radius
    
    if(regionRadius > self.locationManager.maximumRegionMonitoringDistance)
    {
        regionRadius = self.locationManager.maximumRegionMonitoringDistance;
    }
    
    NSString *version = [[UIDevice currentDevice] systemVersion];
    CLRegion * region =nil;
    
    if([version floatValue] >= 7.0f) //for iOS7
    {
        region =  [[CLCircularRegion alloc] initWithCenter:centerCoordinate
                                                    radius:regionRadius
                                                identifier:identifier];
    }
    else // iOS 7 below
    {
        region = [[CLRegion alloc] initCircularRegionWithCenter:centerCoordinate
                                                         radius:regionRadius
                                                     identifier:identifier];
    }
    return  region;
}
static BOOL _started = NO;
static LocationManager *_sharedInstance = nil;
static CLLocationManager *_locationManager = nil;
static CLLocation *_location = nil;

- (CLLocationManager *)locationManager
{
    if (!_locationManager) {
    }
    return _locationManager;
}

+ (void)start
{
    @synchronized(self) {
        if (self.isStarted) {
            return;
        }
        _location = nil;
        if (!_locationManager) {
            _locationManager = [[CLLocationManager alloc] init];
            _locationManager.delegate = _sharedInstance = [[LocationManager alloc] init];
        }
        [_locationManager performSelectorOnMainThread:@selector(startUpdatingLocation) withObject:nil waitUntilDone:YES];
        _started = YES;
    }
}

+ (void)stop
{
    @synchronized(self) {
        if (!self.isStarted) {
            return;
        }
        [_locationManager performSelectorOnMainThread:@selector(stopUpdatingLocation) withObject:nil waitUntilDone:YES];
        _location = nil;
        _started = NO;
    }
}

+ (BOOL)isAuthorizationDecided
{
    return ([CLLocationManager authorizationStatus] != kCLAuthorizationStatusNotDetermined);
}

+ (BOOL)isAuthorized
{
    return ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusAuthorized);
}

+ (BOOL)isStarted
{
    @synchronized(self) {
        return _started;
    }
}

+ (CLLocation *)currentLocationByWaitingUpToMilliseconds:(NSUInteger)milliseconds
{
    // wait for an authorization decision first
    while (!self.isAuthorizationDecided) {
        [[NSRunLoop currentRunLoop] runUntilDate: [NSDate dateWithTimeIntervalSinceNow:0.001]];
    }
    
    if (!self.isAuthorized) {
        NSLog(@"LocationManager: ERROR not authorized to read location");
        return nil;
    }
    [self start]; // make sure we're started
    
    NSDate *end = (milliseconds) ? [NSDate dateWithTimeIntervalSinceNow:milliseconds / 1000.0] : nil;
    
    while (!milliseconds || [(NSDate *)NSDate.date compare:end] != NSOrderedDescending) {
        if (_location) {
            CLLocation * ret = _location;
            [self stop];
            return ret;
        }
        // sleep 1 ms, doesnt allow runloop [NSThread sleepForTimeInterval:0.001];
        [[NSRunLoop currentRunLoop] runUntilDate: [NSDate dateWithTimeIntervalSinceNow:0.001]];
    }
    NSLog(@"LocationManager: ERROR timeout after %d ms", milliseconds);
    return nil;
}

- (void)locationManager:(CLLocationManager *)manager
     didUpdateLocations:(NSArray *)locations
{
    CLLocation *location = locations.lastObject;
    
    NSTimeInterval age = [NSDate.date timeIntervalSinceDate:location.timestamp];
    // if the time interval returned from core location is more than two minutes we ignore it because it might be from an old session
    if (age >= 120.0) {
        return;
    }
    // negative horizontal accuracy means no location fix
    if (location.horizontalAccuracy < 0.0) {
        return;
    }
    
    // location should be good
    _location = location;
}

-       (void)locationManager:(CLLocationManager *)manager
 didChangeAuthorizationStatus:(CLAuthorizationStatus)status
{
    // if not authorized, clear the location
    if (status != kCLAuthorizationStatusAuthorized) {
        _location = nil;
    }
}

//// deprecated, present for backward compatibility
//- (void)locationManager:(CLLocationManager *)manager
//    didUpdateToLocation:(CLLocation *)newLocation
//           fromLocation:(CLLocation *)oldLocation {
//    [self locationManager:manager didUpdateLocations:@[oldLocation, newLocation]];
//}
//
//- (void)locationManager:(CLLocationManager *)manager
//       didFailWithError:(NSError *)error
//{
//    NSLog(@"LocationManager: DELEGATE FAIL didFailWithError error:%@", error);
//    _location = nil;
//}


@end
