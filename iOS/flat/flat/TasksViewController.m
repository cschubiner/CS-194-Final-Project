//
//  TasksViewController.m
//  flat
//
//  Created by Zachary Palacios on 3/2/14.
//  Copyright (c) 2014 cs194. All rights reserved.
//

#import "TasksViewController.h"
#import "TasksHelper.h"
#import "Task+Json.h"

@interface TasksViewController ()
@property NSMutableArray *tasks;
@property Task *taskSelected;
@end

@implementation TasksViewController

static const int NAV_BAR_HEIGHT = 64;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    
    return self;
}

-(void)tableView:(UITableView *)tableView
didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
}

-(BOOL)tableView:(UITableView *)tableView
shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath
{
    return NO;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 90;
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return nil;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [self.tasks count];
}

- (NSInteger)tableView:(UITableView *)tableView
 numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

- (NSString *)tableView:(UITableView *)tableView
titleForHeaderInSection:(NSInteger)section
{
    return nil;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (void)actionSheet:(UIActionSheet *)actionSheet
clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == [actionSheet destructiveButtonIndex]) {
        [TasksHelper deleteTaskWithTaskId:self.taskSelected.taskId
                     andCompletionHandler:^(NSError *error, NSArray *tasks) {
                         self.tasks = [tasks mutableCopy];
                     }];
    }
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        //remove the deleted object from your data source.
        UIActionSheet *logoutActionSheet = [[UIActionSheet alloc]
                                            initWithTitle:@"Are you sure you want to delete task?"
                                            delegate:self
                                            cancelButtonTitle:@"Cancel"
                                            destructiveButtonTitle:@"Delete"
                                            otherButtonTitles:nil];
        self.taskSelected = [self.tasks objectAtIndex:indexPath.row];
        [logoutActionSheet showInView:self.view];
    }
}

/*
 [TasksHelper deleteTaskWith
 [self.tasks removeObjectAtIndex:indexPath.row];
 */

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    self.navigationItem.title = @"Tasks";
    int width = self.view.frame.size.width;
    int height = self.view.frame.size.height;
    [TasksHelper getTasksWithCompletionBlock:^(NSError *error, NSArray *tasks)
    {
        self.tasks = [tasks mutableCopy];
        NSLog(@"Num taskssss: %lu", [self.tasks count]);
        if ([self.tasks count] > 0) {
            NSLog(@"task: %@", [self.tasks objectAtIndex:0]);
        }
        self.tasksTable = [[UITableView alloc] initWithFrame:CGRectMake(0, NAV_BAR_HEIGHT
, width, height - NAV_BAR_HEIGHT)];
        self.tasksTable.delegate = self;
        self.tasksTable.dataSource = self;
        [self.view addSubview:self.tasksTable];
    }];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
