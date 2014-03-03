//
//  CreateTasksViewController.m
//  flat
//
//  Created by Zachary Palacios on 3/2/14.
//  Copyright (c) 2014 cs194. All rights reserved.
//

#import "CreateTasksViewController.h"
#import "TasksHelper.h"

@interface CreateTasksViewController ()
@property NSDate *date;
@property NSString *text;
@end

@implementation CreateTasksViewController

static const int SUBMIT_BUTTON_HEIGHT = 60;
static const int SUBMIT_BUTTON_WIDTH = 200;
static const int NAV_BAR_HEIGHT = 64;
static const int DESCRIPTION_LABEL_HEIGHT = 20;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    int width = self.view.frame.size.width;
    int height = self.view.frame.size.height - NAV_BAR_HEIGHT;
    self.navigationItem.title = @"Create Task";
    
    UILabel *descriptionLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, NAV_BAR_HEIGHT, width, DESCRIPTION_LABEL_HEIGHT)];
    descriptionLabel.text = @"Description:";
    [self.view addSubview:descriptionLabel];
    
    //TextField
    UITextField *textField = [[UITextField alloc] initWithFrame:CGRectMake(0, NAV_BAR_HEIGHT + DESCRIPTION_LABEL_HEIGHT, width, 40)];
    CGRect frameRect = textField.frame;
    frameRect.size.height = 53;
    textField.frame = frameRect;
    textField.borderStyle = UITextBorderStyleLine;
    [self.view addSubview:textField];
    
    UITextView *textView = [[UITextView alloc] initWithFrame:CGRectMake(0, NAV_BAR_HEIGHT + DESCRIPTION_LABEL_HEIGHT, width, 53)];
    textView.backgroundColor = nil;
    [self.view addSubview:textView];
    
    //Date picker
    UIDatePicker *myPicker = [[UIDatePicker alloc] initWithFrame:CGRectMake(0, 0, 320, 216)];
    [myPicker addTarget:self
                 action:@selector(pickerChanged:)
        forControlEvents:UIControlEventValueChanged];
    [myPicker setCenter:CGPointMake(width / 2, NAV_BAR_HEIGHT + height - (height / 4) - 130)];
    [self.view addSubview:myPicker];
    
    
    //submit button
    UIButton *submitButton = [[UIButton alloc] initWithFrame:CGRectMake(width / 2 - SUBMIT_BUTTON_WIDTH / 2, height - SUBMIT_BUTTON_HEIGHT, SUBMIT_BUTTON_WIDTH, SUBMIT_BUTTON_HEIGHT)];
    [submitButton setTitle:@"Submit"
                  forState:UIControlStateNormal];
    [submitButton setTitleColor:[UIColor whiteColor]
                       forState:UIControlStateNormal];
    [submitButton.titleLabel setFont:[UIFont systemFontOfSize:16]];
    [submitButton addTarget:self
                     action:@selector(submitButtonPressed)
           forControlEvents:UIControlEventTouchUpInside];
    [submitButton setBackgroundColor:[UIColor greenColor]];
    [self.view addSubview:submitButton];
}

- (void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [self.view endEditing:YES];
}

- (void)submitButtonPressed
{
    NSLog(@"submit button pressed");
    [TasksHelper createTaskWithText:self.text
                            andDate:self.date
                 andCompletionBlock:^(NSError *error, NSArray *tasks)
     {
         if (error) {
             NSLog(@"Error creating a task: %@", error);
         } else {
             NSLog(@"Created Task");
         }
     }];
}

- (void)pickerChanged:(id)sender
{
    self.date = [sender date];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
