//
//  CreateTasksViewController.m
//  flat
//
//  Created by Zachary Palacios on 3/2/14.
//  Copyright (c) 2014 cs194. All rights reserved.
//

#import "CreateTasksViewController.h"
#import "TasksHelper.h"
<<<<<<< HEAD
#import "TasksViewController.h"

@interface CreateTasksViewController ()
@property NSDate *date;
@property UITextField *textField;
@property UITextView *textView;
=======

@interface CreateTasksViewController ()
@property NSDate *date;
@property NSString *text;
>>>>>>> my-temporary-work
@end

@implementation CreateTasksViewController

static const int SUBMIT_BUTTON_HEIGHT = 60;
static const int SUBMIT_BUTTON_WIDTH = 200;
static const int NAV_BAR_HEIGHT = 64;
static const int DESCRIPTION_LABEL_HEIGHT = 20;
<<<<<<< HEAD
static const int SIDE_SPACING = 5;
=======
>>>>>>> my-temporary-work

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
    
<<<<<<< HEAD
    UILabel *descriptionLabel = [[UILabel alloc] initWithFrame:CGRectMake(SIDE_SPACING, NAV_BAR_HEIGHT, width - (2 * SIDE_SPACING), DESCRIPTION_LABEL_HEIGHT)];
=======
    UILabel *descriptionLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, NAV_BAR_HEIGHT, width, DESCRIPTION_LABEL_HEIGHT)];
>>>>>>> my-temporary-work
    descriptionLabel.text = @"Description:";
    [self.view addSubview:descriptionLabel];
    
    //TextField
<<<<<<< HEAD
    self.textField = [[UITextField alloc] initWithFrame:CGRectMake(SIDE_SPACING, NAV_BAR_HEIGHT + DESCRIPTION_LABEL_HEIGHT + 5, width - (SIDE_SPACING * 2), 40)];
    CGRect frameRect = self.textField.frame;
    frameRect.size.height = 53;
    self.textField.frame = frameRect;
    self.textField.borderStyle = UITextBorderStyleLine;
    self.textField.font = [UIFont systemFontOfSize:16];
    [self.view addSubview:self.textField];
    
    self.textView = [[UITextView alloc] initWithFrame:CGRectMake(SIDE_SPACING, NAV_BAR_HEIGHT + DESCRIPTION_LABEL_HEIGHT + 5, width - (2 * SIDE_SPACING), 53)];
    self.textView.backgroundColor = nil;
    self.textView.font = [UIFont systemFontOfSize:16];
    [self.view addSubview:self.textView];
=======
    UITextField *textField = [[UITextField alloc] initWithFrame:CGRectMake(0, NAV_BAR_HEIGHT + DESCRIPTION_LABEL_HEIGHT, width, 40)];
    CGRect frameRect = textField.frame;
    frameRect.size.height = 53;
    textField.frame = frameRect;
    textField.borderStyle = UITextBorderStyleLine;
    [self.view addSubview:textField];
    
    UITextView *textView = [[UITextView alloc] initWithFrame:CGRectMake(0, NAV_BAR_HEIGHT + DESCRIPTION_LABEL_HEIGHT, width, 53)];
    textView.backgroundColor = nil;
    [self.view addSubview:textView];
>>>>>>> my-temporary-work
    
    //Date picker
    UIDatePicker *myPicker = [[UIDatePicker alloc] initWithFrame:CGRectMake(0, 0, 320, 216)];
    [myPicker addTarget:self
                 action:@selector(pickerChanged:)
        forControlEvents:UIControlEventValueChanged];
    [myPicker setCenter:CGPointMake(width / 2, NAV_BAR_HEIGHT + height - (height / 4) - 130)];
<<<<<<< HEAD
    [myPicker setDate:[NSDate date]];
=======
>>>>>>> my-temporary-work
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

<<<<<<< HEAD
- (void) touchesBegan:(NSSet *)touches
            withEvent:(UIEvent *)event
{
=======
- (void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
>>>>>>> my-temporary-work
    [self.view endEditing:YES];
}

- (void)submitButtonPressed
{
<<<<<<< HEAD
    NSString *text = self.textView.text;
    if(self.date == NULL || self.date == nil) {
        self.date = [NSDate date];
    }
    NSLog(@"submit button pressed %@ %@", text, self.date);
    [TasksHelper createTaskWithText:text
=======
    NSLog(@"submit button pressed");
    [TasksHelper createTaskWithText:self.text
>>>>>>> my-temporary-work
                            andDate:self.date
                 andCompletionBlock:^(NSError *error, NSArray *tasks)
     {
         if (error) {
             NSLog(@"Error creating a task: %@", error);
         } else {
             NSLog(@"Created Task");
<<<<<<< HEAD
             TasksViewController *tasksVC = [self.navigationController.viewControllers objectAtIndex:self.navigationController.viewControllers.count - 2];
             tasksVC.tasks = [tasks mutableCopy];
             [tasksVC.tasksTable reloadData];
             [self.navigationController popViewControllerAnimated:YES];
=======
>>>>>>> my-temporary-work
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
