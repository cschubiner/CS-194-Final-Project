//
//  EventModel.h
//  flat
//
//  Created by Clay Schubiner on 2/16/14.
//  Copyright (c) 2014 cs194. All rights reserved.
//

#import "JSONModel.h"

@interface EventModel : JSONModel


//@property (assign, nonatomic) int id;
@property (strong, nonatomic) NSNumber* userID;
@property (strong, nonatomic) NSString* title;
@property (strong, nonatomic) NSDate* startDate;
@property (strong, nonatomic) NSDate* endDate;

@end
