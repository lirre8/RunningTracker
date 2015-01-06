//
//  RTRDataSelector.m
//  RunningTracker
//
//  Created by u on 11/18/14.
//  Copyright (c) 2014 lirre8. All rights reserved.
//

#import "RTRDataSelector.h"

@interface RTRDataSelector ()

@end

@implementation RTRDataSelector

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        NSFileManager *filemgr = [NSFileManager defaultManager];
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentsDirectory = [paths objectAtIndex:0];
        NSString* inboxPath = [documentsDirectory stringByAppendingPathComponent:@"Inbox"];
        self.dataFiles = [filemgr contentsOfDirectoryAtPath:inboxPath error:nil];
        self.stage = [NSNumber numberWithInt:0];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"Load data";

    // Setup the done button on the right side of navigation bar
    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc]initWithTitle:@"Done" style:UIBarButtonItemStylePlain target:self action:@selector(done:)];
    self.navigationItem.rightBarButtonItem = doneButton;

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return self.dataFiles.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:[NSString stringWithFormat:@"%ld_Cell",(long)indexPath.row]];
    cell.textLabel.text = [self.dataFiles objectAtIndex:indexPath.row];
    
    if ([cell.textLabel.text isEqual:self.lowerLegData] || [cell.textLabel.text isEqual:self.upperLegData]) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    }
    else
        cell.accessoryType = UITableViewCellAccessoryNone;
    
    return cell;
}

-(NSString *) tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    NSString *header = @"";
    if (section == 0) {
        if (self.dataFiles.count == 0) {
            header = @"No Data Files Found";
        }
        switch ([self.stage intValue]) {
            case 0:
                header = @"Choose your lower leg data";
                break;
            case 1:
                header = @"Choose your upper leg data";
                break;
            case 2:
                header = @"Press done to continue";
                break;
            default:
                break;
        }

    }
    return header;
}

-(void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *file = [self.dataFiles objectAtIndex:indexPath.row];
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if ([self.stage intValue] == 0) {
        self.stage = [NSNumber numberWithInt:[self.stage intValue]+1];
        self.lowerLegData = file;
    }
    else if ([self.stage intValue] == 1 && ![file isEqual:self.lowerLegData]) {
        self.stage = [NSNumber numberWithInt:[self.stage intValue]+1];
        self.upperLegData = file;
    }
    
    [self.tableView reloadData];
}

-(IBAction)done:(id)sender {
    if ([self.stage intValue] < 2) {
        UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"Select data" message:@"Please select 2 datafiles before continuing" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alertView show];
    }
    else {
        [self.delegate dataWasSelectedLowerLeg:self.lowerLegData upperLeg:self.upperLegData];
        [[self navigationController] popViewControllerAnimated:YES];
    }
}

@end
