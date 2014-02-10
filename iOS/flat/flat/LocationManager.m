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

- (void)handleUserDormState:(bool)isInDorm {
    ProfileUser * currUser = [FlatAPIClientManager sharedClient].profileUser;
    currUser.isNearDorm = [NSNumber numberWithInt:isInDorm ? 1 : 0];
    [ProfileUserNetworkRequest setUserLocationWithUserID:currUser.userID andIsInDorm:isInDorm];
    if (isInDorm) {
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
    [self handleUserDormState:state == CLRegionStateInside];
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    NSLog(@"didFailWithError: %@", error);
    UIAlertView *errorAlert = [[UIAlertView alloc]
                               initWithTitle:@"Error" message:@"Failed to Get Your Location" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [errorAlert show];
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
                 [self handleUserDormState:[currentLocationDistance floatValue] < radius];
//                 if([currentLocationDistance floatValue] < radius)
//                 {
//                     NSLog(@"Invoking didEnterRegion Manually for region: %@",identifer);
//                     
//                     //stop Monitoring Region temporarily
//                     [self.locationManager stopMonitoringForRegion:region];
//                     
//                     [self locationManager:self.locationManager didEnterRegion:region];
//                     //start Monitoing Region again.
//                     [self.locationManager startMonitoringForRegion:region];
//                 }
//                 else {
//                     //stop Monitoring Region temporarily
//                     [self.locationManager stopMonitoringForRegion:region];
//                     
//                     [self locationManager:self.locationManager didExitRegion:region];
//                     //start Monitoing Region again.
//                     [self.locationManager startMonitoringForRegion:region];
//                 }
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
@end
