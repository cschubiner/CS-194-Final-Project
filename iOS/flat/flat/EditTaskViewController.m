//
//  EditTaskViewController.m
//  flat
//
//  Created by Zachary Palacios on 3/4/14.
//  Copyright (c) 2014 cs194. All rights reserved.
//

#import "EditTaskViewController.h"
#import "TasksHelper.h"
#import "TaskDetailViewController.h"

@interface EditTaskViewController ()
@property UITextField *textField;
@property UITextView *textView;
@property NSDate *date;
@end

@implementation EditTaskViewController

static const int SUBMIT_BUTTON_HEIGHT = 60;
static const int SUBMIT_BUTTON_WIDTH = 200;
static const int NAV_BAR_HEIGHT = 64;
static const int DESCRIPTION_LABEL_HEIGHT = 20;
static const int SIDE_SPACING = 5;

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
    self.navigationItem.title = @"Edit Task";
    
    UILabel *descriptionLabel = [[UILabel alloc] initWithFrame:CGRectMake(SIDE_SPACING, NAV_BAR_HEIGHT, width - (2 * SIDE_SPACING), DESCRIPTION_LABEL_HEIGHT)];
    descriptionLabel.text = @"Description:";
    [self.view addSubview:descriptionLabel];
    
    //TextField
    self.textField = [[UITextField alloc] initWithFrame:CGRectMake(SIDE_SPACING, NAV_BAR_HEIGHT + DESCRIPTION_LABEL_HEIGHT + 5, width - (SIDE_SPACING * 2), 40)];
    CGRect frameRect = self.textField.frame;
    frameRect.size.height = 53;
    self.textField.frame = frameRect;
    self.textField.borderStyle = UITextBorderStyleLine;
    self.textField.font = [UIFont systemFontOfSize:16];
    [self.view addSubview:self.textField];
    
    //TextView
    self.textView = [[UITextView alloc] initWithFrame:CGRectMake(SIDE_SPACING, NAV_BAR_HEIGHT + DESCRIPTION_LABEL_HEIGHT + 5, width - (2 * SIDE_SPACING), 53)];
    self.textView.backgroundColor = nil;
    self.textView.font = [UIFont systemFontOfSize:16];
    self.textView.text = self.task.body;
    [self.view addSubview:self.textView];
    
    //Date picker
    UIDatePicker *myPicker = [[UIDatePicker alloc] initWithFrame:CGRectMake(0, 0, 320, 216)];
    [myPicker addTarget:self
                 action:@selector(pickerChanged:)
       forControlEvents:UIControlEventValueChanged];
    [myPicker setCenter:CGPointMake(width / 2, NAV_BAR_HEIGHT + height - (height / 4) - 130)];
    [myPicker setDate:self.task.dueDate];
    [self.view addSubview:myPicker];
    
    
    //submit button
    UIButton *submitButton = [[UIButton alloc] initWithFrame:CGRectMake(width / 2 - SUBMIT_BUTTON_WIDTH / 2, height - SUBMIT_BUTTON_HEIGHT, SUBMIT_BUTTON_WIDTH, SUBMIT_BUTTON_HEIGHT)];
    [submitButton setTitle:@"Update"
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

- (void) touchesBegan:(NSSet *)touches
            withEvent:(UIEvent *)event
{
    [self.view endEditing:YES];
}

- (void)submitButtonPressed
{
    NSString *text = self.textView.text;
    if (self.date == NULL || self.date == nil) {
        self.date = self.task.dueDate;
    }
    NSLog(@"submit button pressed %@ %@", text, self.date);
    [TasksHelper editTaskWithTaskId:self.task.taskId
                            andBody:text
                            andDate:self.date
               andCompletionHandler:^(NSError *error, NSArray *tasks)
     {
         if (error) {
             NSLog(@"Error creating a task: %@", error);
         } else {
             DLog(@"Created Task");
             TaskDetailViewController *prev = [self.navigationController.viewControllers objectAtIndex:self.navigationController.viewControllers.count - 2];
             prev.tasks = [tasks mutableCopy];
             for (int i = 0; i < [tasks count]; i++) {
                 Task *currTask = [tasks objectAtIndex:i];
                 if([currTask.taskId isEqualToNumber2:prev.task.taskId]) {
                     prev.task = currTask;
                     break;
                 }
             }
             [self.navigationController popViewControllerAnimated:YES];
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
