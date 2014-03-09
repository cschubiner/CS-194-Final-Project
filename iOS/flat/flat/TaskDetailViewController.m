//
//  TaskDetailViewController.m
//  flat
//
//  Created by Zachary Palacios on 3/4/14.
//  Copyright (c) 2014 cs194. All rights reserved.
//

#import "TaskDetailViewController.h"
#import "EditTaskViewController.h"
#import "TasksViewController.h"

@interface TaskDetailViewController ()
@property UITextView *textView;
@property UILabel *dueDateLabel;
@end

@implementation TaskDetailViewController

static const int NAV_BAR_HEIGHT = 64;
static const int TEXT_VIEW_HEIGHT = 200;
static const int TOP_SPACING = 5;
static const int TASK_LABEL_HEIGHT = 20;
static const int SIDE_SPACING = 5;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidAppear:(BOOL)animated
{
    self.textView.text = self.task.body;
    self.dueDateLabel.text = [NSString stringWithFormat:@"Due Date: %@", [Utils formatDate:self.task.dueDate
                                                                                withFormat:@"MM-dd-yyyy HH:mm"]];
    TasksViewController *prev = [self.navigationController.viewControllers objectAtIndex:self.navigationController.viewControllers.count - 2];
    prev.tasks = self.tasks;
    [prev.tasksTable reloadData];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    int width = self.view.frame.size.width;
    self.navigationItem.title = @"Task";
    
    UILabel *taskLabel = [[UILabel alloc] initWithFrame:CGRectMake(SIDE_SPACING, NAV_BAR_HEIGHT + TOP_SPACING, width, TASK_LABEL_HEIGHT)];
    taskLabel.text = @"Task: ";
    [self.view addSubview:taskLabel];
    
    self.textView = [[UITextView alloc] initWithFrame:CGRectMake(SIDE_SPACING, NAV_BAR_HEIGHT + TOP_SPACING + TASK_LABEL_HEIGHT + 5, width - (2 * SIDE_SPACING), TEXT_VIEW_HEIGHT)];
    self.textView.text = self.task.body;
    self.textView.font = [UIFont systemFontOfSize:24];
    [self.textView setEditable:NO];
    [self.view addSubview:self.textView];
    
    self.dueDateLabel = [[UILabel alloc] initWithFrame:CGRectMake(SIDE_SPACING, NAV_BAR_HEIGHT + TOP_SPACING + TASK_LABEL_HEIGHT + 5 + TEXT_VIEW_HEIGHT + 50, width, TASK_LABEL_HEIGHT)];
    self.dueDateLabel.text = [NSString stringWithFormat:@"Due Date: %@", [Utils formatDate:self.task.dueDate withFormat:@"MM-dd-yyyy HH:mm"]];
    [self.view addSubview:self.dueDateLabel];
    
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue
                 sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"DetailViewToEditTask"]) {
        EditTaskViewController *dest = (EditTaskViewController *)segue.destinationViewController;
        NSLog(@"preparing for segue, task: %@", self.task);
        dest.task = self.task;
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end