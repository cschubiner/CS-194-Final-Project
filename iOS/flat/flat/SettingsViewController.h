//
//  SettingsViewController.h
//  flat
//
//  Created by Clay Schubiner on 2/9/14.
//  Copyright (c) 2014 cs194. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SettingsViewController : UITableViewController <UIAlertViewDelegate, UIActionSheetDelegate>

@property (nonatomic, assign) id delegate;

@end
