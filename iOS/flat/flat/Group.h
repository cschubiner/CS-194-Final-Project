//
//  Group.h
//  flat
//
//  Created by Clay Schubiner on 2/2/14.
//  Copyright (c) 2014 cs194. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Group : NSManagedObject

@property (nonatomic, retain) NSNumber * latLocation;
@property (nonatomic, retain) NSNumber * groupID;
@property (nonatomic, retain) NSNumber * longLocation;

@end