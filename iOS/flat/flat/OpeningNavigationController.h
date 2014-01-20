//
//  OpeningNavigationController.h
//  flat
//
//  Created by Zachary Palacios on 1/19/14.
//  Copyright (c) 2014 cs194. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface OpeningNavigationController : UINavigationController

- (void)handleFacebookSignupWithToken:(NSString *)fbToken
                             andEmail:(NSString *)email
                            firstName:(NSString *)firstName
                          andLastName:(NSString *)lastName;

@end
