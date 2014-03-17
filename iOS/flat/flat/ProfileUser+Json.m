//
//  ProfileUser+Json.m
//  flat
//
//  Created by Zachary Palacios on 1/19/14.
//  Copyright (c) 2014 cs194. All rights reserved.
//

#import "ProfileUser+Json.h"
#import "cs194AppDelegate.h"
#import "ProfileUser.h"
@implementation ProfileUser (Json)


+ (ProfileUser *)getProfileUserObjectFromDictionary:(NSDictionary *)dictionary
                            AndManagedObjectContext:(NSManagedObjectContext *)context
{
 
    ProfileUser *profileUser = [ProfileUser MR_createInContext:context];
    profileUser.userID = [dictionary objectForKey:@"fb_id"];
    profileUser.groupID = [dictionary objectForKey:@"group_id"];
    profileUser.colorID = [dictionary objectForKey:@"color_id"];
    profileUser.firstName = [dictionary objectForKey:@"first_name"];
    profileUser.lastName = [dictionary objectForKey:@"last_name"];
    profileUser.email = [dictionary objectForKey:@"email"];
    profileUser.isNearDorm = [dictionary objectForKey:@"is_near_dorm"];
    
    [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreWithCompletion:nil];

    return profileUser;
}

+ (NSString *) getInitialsFromUserID:(NSNumber*)userID {
    static NSMutableDictionary * colorDict = nil;
    if (!colorDict) colorDict = [[NSMutableDictionary alloc]init];
    NSString * ret = [colorDict objectForKey:userID];
    if (ret) return ret;
    
    for (ProfileUser * user in [[FlatAPIClientManager sharedClient]users]){
        

        if ([user.userID isEqualToNumberWithNullCheck:userID]) {
 
            NSString *initials  = [NSString stringWithFormat:@"%@%@",
                                                                 [user.firstName substringWithRange:NSMakeRange(0, 1)],
                                                                 [user.lastName substringWithRange:NSMakeRange(0, 1)]];
            [colorDict setObject:initials forKey:userID];

            return initials;
        }
    }
    return @"--";
}

+ (NSString *) getFirstNameFromUserID:(NSNumber*)userID {
    static NSMutableDictionary * colorDict = nil;
    if (!colorDict) colorDict = [[NSMutableDictionary alloc]init];
    NSString * ret = [colorDict objectForKey:userID];
    if (ret) return ret;
    
    for (ProfileUser * user in [[FlatAPIClientManager sharedClient]users]){
        if ([user.userID isEqualToNumberWithNullCheck:userID]) {
            NSString *initials  = user.firstName;
            [colorDict setObject:initials forKey:userID];
            return initials;
        }
    }
    return @"DB Error";
}

+ (UIColor *) getColorFromUserID:(NSNumber*)userID {
    static NSMutableDictionary * colorDict = nil;
    if (!colorDict) colorDict = [[NSMutableDictionary alloc]init];
    UIColor * ret = [colorDict objectForKey:userID];
    if (ret) return ret;
    
    for (ProfileUser * user in [[FlatAPIClientManager sharedClient]users]){
        if ([user.userID isEqualToNumberWithNullCheck:userID]) {
            ret = [self getColorFromUser:user];
            [colorDict setObject:ret forKey:userID];
            return ret;
        }
        

    }
    return [UIColor grayColor];
    //    return nil;
}

+ (UIColor *) getColorFromUser:(ProfileUser*)user
{
    NSString * colorStr = @"FF2A68";
    if ([user.colorID isEqualToNumberWithNullCheck:[NSNumber numberWithInt:0]])
        colorStr = @"FF1300";
    else if ([user.colorID isEqualToNumberWithNullCheck:[NSNumber numberWithInt:1]])
        colorStr = @"FF5E3A";
    else if ([user.colorID isEqualToNumberWithNullCheck:[NSNumber numberWithInt:2]])
        colorStr = @"FFCD02";
    else if ([user.colorID isEqualToNumberWithNullCheck:[NSNumber numberWithInt:3]])
        colorStr = @"A4E786";
    else if ([user.colorID isEqualToNumberWithNullCheck:[NSNumber numberWithInt:4]])
        colorStr = @"0BD318";
    else if ([user.colorID isEqualToNumberWithNullCheck:[NSNumber numberWithInt:5]])
        colorStr = @"5AC8FB";
    else if ([user.colorID isEqualToNumberWithNullCheck:[NSNumber numberWithInt:6]])
        colorStr = @"007AFF";
    else if ([user.colorID isEqualToNumberWithNullCheck:[NSNumber numberWithInt:7]])
        colorStr = @"5856D6";
    else if ([user.colorID isEqualToNumberWithNullCheck:[NSNumber numberWithInt:8]])
        colorStr = @"E4B7F0";
    else if ([user.colorID isEqualToNumberWithNullCheck:[NSNumber numberWithInt:9]])
        colorStr = @"FF2A68";
    else if ([user.colorID isEqualToNumberWithNullCheck:[NSNumber numberWithInt:10]])
        colorStr = @"C643FC";
  
    return [self colorWithHexString:colorStr];
}

+(UIColor*)colorWithHexString:(NSString*)hex
{
    NSString *cString = [[hex stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] uppercaseString];
    
    // String should be 6 or 8 characters
    if ([cString length] < 6) return [UIColor grayColor];
    
    // strip 0X if it appears
    if ([cString hasPrefix:@"0X"]) cString = [cString substringFromIndex:2];
    
    if ([cString length] != 6) return  [UIColor grayColor];
    
    // Separate into r, g, b substrings
    NSRange range;
    range.location = 0;
    range.length = 2;
    NSString *rString = [cString substringWithRange:range];
    
    range.location = 2;
    NSString *gString = [cString substringWithRange:range];
    
    range.location = 4;
    NSString *bString = [cString substringWithRange:range];
    
    // Scan values
    unsigned int r, g, b;
    [[NSScanner scannerWithString:rString] scanHexInt:&r];
    [[NSScanner scannerWithString:gString] scanHexInt:&g];
    [[NSScanner scannerWithString:bString] scanHexInt:&b];
    
    return [UIColor colorWithRed:((float) r / 255.0f)
                           green:((float) g / 255.0f)
                            blue:((float) b / 255.0f)
                           alpha:1.0f];
}

@end
