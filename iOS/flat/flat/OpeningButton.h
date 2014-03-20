//
//  OpeningButton.h
//  flat
//
//  Created by Zachary Palacios on 1/19/14.
//  Copyright (c) 2014 cs194. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface OpeningButton : UIButton

- (id)initWithType:(NSString *)type
            parent:(UIViewController *)parent
            action:(SEL)action;



-(void)setEnabledColor;
-(void)setDisabledColor;
    
@end
