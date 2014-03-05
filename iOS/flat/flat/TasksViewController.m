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
<<<<<<< HEAD
#import "TaskDetailViewController.h"

@interface TasksViewController ()
=======

@interface TasksViewController ()
@property NSMutableArray *tasks;
>>>>>>> my-temporary-work
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

<<<<<<< HEAD
- (void)tableView:(UITableView *)tableView
didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.tasksTable deselectRowAtIndexPath:indexPath
                                   animated:YES];
    NSLog(@"Cell clicked at index: %lu", indexPath.row);
    [self performSegueWithIdentifier:@"TasksToDetailView"
                              sender:[tableView cellForRowAtIndexPath:indexPath]];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue
                 sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"TasksToDetailView"]) {
        TaskDetailViewController *dest = (TaskDetailViewController *)segue.destinationViewController;
        dest.task = [self.tasks objectAtIndex:((UITableViewCell *)sender).tag];
        dest.tasks = self.tasks;
    }
}

- (CGFloat)tableView:(UITableView *)tableView
heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 70;
=======
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
>>>>>>> my-temporary-work
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
<<<<<<< HEAD
    NSString *cellIdentifier = @"cell4";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle
                                      reuseIdentifier:cellIdentifier];
    }
    Task *currTask = [self.tasks objectAtIndex:indexPath.row];
    cell.textLabel.text = currTask.body;
    NSLog(@"TASK: %@", cell.textLabel.text);
    NSLog(@"DATE: %@", currTask.dueDate);
    cell.detailTextLabel.text = [NSString stringWithFormat:@"Due date: %@", [Utils formatDate:currTask.dueDate withFormat:@"MM-dd-yyyy HH:mm"]];
    cell.tag = indexPath.row;
    return cell;
=======
    return nil;
>>>>>>> my-temporary-work
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
<<<<<<< HEAD
    return 1;
=======
    return [self.tasks count];
>>>>>>> my-temporary-work
}

- (NSInteger)tableView:(UITableView *)tableView
 numberOfRowsInSection:(NSInteger)section
{
<<<<<<< HEAD
    return [self.tasks count];
=======
    return 1;
>>>>>>> my-temporary-work
}

- (NSString *)tableView:(UITableView *)tableView
titleForHeaderInSection:(NSInteger)section
{
    return nil;
}

<<<<<<< HEAD


- (BOOL)tableView:(UITableView *)tableView
canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
=======
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
>>>>>>> my-temporary-work
    return YES;
}

- (void)actionSheet:(UIActionSheet *)actionSheet
clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == [actionSheet destructiveButtonIndex]) {
        [TasksHelper deleteTaskWithTaskId:self.taskSelected.taskId
                     andCompletionHandler:^(NSError *error, NSArray *tasks) {
                         self.tasks = [tasks mutableCopy];
<<<<<<< HEAD
                         [self.tasksTable reloadData];
=======
>>>>>>> my-temporary-work
                     }];
    }
}

<<<<<<< HEAD
- (void)tableView:(UITableView *)tableView
commitEditingStyle:(UITableViewCellEditingStyle)editingStyle
forRowAtIndexPath:(NSIndexPath *)indexPath {
=======
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
>>>>>>> my-temporary-work
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

<<<<<<< HEAD
=======
/*
 [TasksHelper deleteTaskWith
 [self.tasks removeObjectAtIndex:indexPath.row];
 */

>>>>>>> my-temporary-work
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
<<<<<<< HEAD
=======
        NSLog(@"Num taskssss: %lu", [self.tasks count]);
        if ([self.tasks count] > 0) {
            NSLog(@"task: %@", [self.tasks objectAtIndex:0]);
        }
>>>>>>> my-temporary-work
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
