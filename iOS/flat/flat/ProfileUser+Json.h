//
//  ProfileUser+Json.h
//  flat
//
//  Created by Zachary Palacios on 1/19/14.
//  Copyright (c) 2014 cs194. All rights reserved.
//

#import "ProfileUser.h"

@interface ProfileUser (Json)

+ (ProfileUser *)getProfileUserObjectFromDictionary:(NSDictionary *)dictionary
                            AndManagedObjectContext:(NSManagedObjectContext *)context;

+ (UIColor *) getColorFromUser:(ProfileUser*)user;
+ (UIColor *) getColorFromUserID:(NSNumber*)userID;
+ (NSString *) getInitialsFromUserID:(NSNumber*)userID;
+ (NSString *) getFirstNameFromUserID:(NSNumber*)userID;
@end
