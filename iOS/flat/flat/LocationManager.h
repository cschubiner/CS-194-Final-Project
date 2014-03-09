//
//  LocationManager.h
//  flat
//
//  Created by Clay Schubiner on 2/2/14.
//  Copyright (c) 2014 cs194. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@interface LocationManager : NSObject <CLLocationManagerDelegate>

+ (instancetype)sharedClient;

@property (nonatomic, strong) CLLocationManager *locationManager;
@property (nonatomic) double currentLatitude;
@property (nonatomic) double currentLongitude;

@property (nonatomic) BOOL shouldSetDormLocation;
- (CLRegion*)getGroupLocationRegion;

@end
