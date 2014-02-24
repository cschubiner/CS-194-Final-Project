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
    //    profileUser.imageUrl = [dictionary objectForKey:@"image_url"];
    profileUser.isNearDorm = [dictionary objectForKey:@"is_near_dorm"];
    //    profileUser.apiToken = [dictionary objectForKey:@"api_token"];
    
    [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreAndWait];
    return profileUser;
}

+ (NSString *) getInitialsFromUserID:(NSNumber*)userID {
    static NSMutableDictionary * colorDict = nil;
    if (!colorDict) colorDict = [[NSMutableDictionary alloc]init];
    NSString * ret = [colorDict objectForKey:userID];
    if (ret) return ret;
    
    for (ProfileUser * user in [[FlatAPIClientManager sharedClient]users]){
        if ([user.userID isEqualToNumber:userID]) {
            NSString *initials  = [NSString stringWithFormat:@"%@%@",
                                                                 [user.firstName substringWithRange:NSMakeRange(0, 1)],
                                                                 [user.lastName substringWithRange:NSMakeRange(0, 1)]];
            [colorDict setObject:initials forKey:userID];
            return initials;
        }
    }
    return @"NA";
    //    return nil;
}

+ (UIColor *) getColorFromUserID:(NSNumber*)userID {
    static NSMutableDictionary * colorDict = nil;
    if (!colorDict) colorDict = [[NSMutableDictionary alloc]init];
    UIColor * ret = [colorDict objectForKey:userID];
    if (ret) return ret;
    
    for (ProfileUser * user in [[FlatAPIClientManager sharedClient]users]){
        if ([user.userID isEqualToNumber:userID]) {
            ret = [self getColorFromUser:user];
            [colorDict setObject:ret forKey:userID];
            return ret;
        }
    }
    return [UIColor grayColor];
    //    return nil;
}

+ (UIColor *) getColorFromUser:(ProfileUser*)user {
//    if ([user.firstName isEqualToString:@"Zach"])
//        NSLog(@"zach");
    NSString * colorStr = @"FFFFFF";
    if ([user.colorID isEqualToNumber:[NSNumber numberWithInt:0]])
        colorStr = @"fb605e";
    else if ([user.colorID isEqualToNumber:[NSNumber numberWithInt:1]])
        colorStr = @"FF7A00";
    else if ([user.colorID isEqualToNumber:[NSNumber numberWithInt:2]])
        colorStr = @"03899C";
    else if ([user.colorID isEqualToNumber:[NSNumber numberWithInt:3]])
        colorStr = @"00C322";
    
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
