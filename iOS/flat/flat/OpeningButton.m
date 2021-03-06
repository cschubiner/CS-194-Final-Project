//
//  OpeningButton.m
//  flat
//
//  Created by Zachary Palacios on 1/19/14.
//  Copyright (c) 2014 cs194. All rights reserved.
//

#import "OpeningButton.h"

@implementation OpeningButton

- (id)initWithType:(NSString *)type
           parent:(UIViewController *)parent
           action:(SEL)action
{
    self = [super init];
    if (self) {
        self = [UIButton buttonWithType:UIButtonTypeSystem];
        [self setTitleColor: [UIColor colorWithRed:57.0/255.0 green:90.0/255.0 blue:161.0/255.0 alpha:1.0] forState:UIControlStateNormal];
        self.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
        self.titleLabel.font = [UIFont fontWithName:@"ProximaNova-Bold" size:18.0f];
        [self addTarget:parent action:action forControlEvents:UIControlEventTouchUpInside];
        
        int height = [[UIScreen mainScreen] bounds].size.height;
        int width = [[UIScreen mainScreen] bounds].size.width;
        if ([type isEqualToString:@"facebookSignIn"]) {
            self.frame = CGRectMake(0, height-75, width, 50);
            self.backgroundColor = [UIColor whiteColor];
            [self setTitle:@"Sign up with Facebook" forState:UIControlStateNormal];
            
            CAGradientLayer *gradient = [CAGradientLayer layer];
            gradient.frame = self.bounds;
            gradient.colors = [NSArray arrayWithObjects:(id)[[UIColor colorWithRed:88.0/255.0
                                                                             green:127.0/255.0
                                                                              blue:192.0/255.0
                                                                             alpha:1.0] CGColor],
                               (id)[[UIColor colorWithRed:45.0/255.0
                                                    green:75.0/255.0
                                                     blue:125.0/255.0
                                                    alpha:1.0] CGColor], nil];
        }
    }
    return self;
}

-(void)setEnabledColor {
        [self setTitleColor: [UIColor colorWithRed:57.0/255.0 green:90.0/255.0 blue:161.0/255.0 alpha:1.0] forState:UIControlStateNormal];
}
-(void)setDisabledColor {
        [self setTitleColor: [UIColor grayColor] forState:UIControlStateDisabled];
}

@end
