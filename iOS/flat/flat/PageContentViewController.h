//
//  PageContentViewController.h
//  flat
//
//  Created by Kyle Archie on 2/23/14.
//  Copyright (c) 2014 cs194. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PageContentViewController : UIViewController
@property (weak, nonatomic) IBOutlet UIImageView *backgroundImageView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property NSUInteger pageIndex;
@property NSString *titleText;
@property NSString *imageFile;
@end
