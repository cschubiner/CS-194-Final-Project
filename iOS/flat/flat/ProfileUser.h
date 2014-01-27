//
//  ProfileUser.h
//  flat
//
//  Created by Clay Schubiner on 1/26/14.
//  Copyright (c) 2014 cs194. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface ProfileUser : NSManagedObject

@property (nonatomic, retain) NSString * apiToken;
@property (nonatomic, retain) NSString * email;
@property (nonatomic, retain) NSString * firstName;
@property (nonatomic, retain) NSString * imageUrl;
@property (nonatomic, retain) NSString * lastName;
@property (nonatomic, retain) NSNumber * userID;
@property (nonatomic, retain) NSNumber * groupID;

@end
