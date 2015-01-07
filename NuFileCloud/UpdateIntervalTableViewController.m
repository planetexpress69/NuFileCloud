//
//  UpdateIntervalTableViewController.m
//  NuFileCloud
//
//  Created by Martin Kautz on 03.11.14.
//  Copyright (c) 2014 JAKOTA Design Group. All rights reserved.
//

#import "UpdateIntervalTableViewController.h"
#import "Constants.h"

@interface UpdateIntervalTableViewController ()

@end

@implementation UpdateIntervalTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    self.title = @"Update interval";

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
#warning Potentially incomplete method implementation.
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
#warning Incomplete method implementation.
    // Return the number of rows in the section.
    return 4;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"UpdateIntervalCell" forIndexPath:indexPath];

    int storedUpdateInterval = ((NSNumber *)[[NSUserDefaults standardUserDefaults]objectForKey:@"updateInterval"]).intValue;
    
    switch (indexPath.row) {
        case 0:
            if (storedUpdateInterval == 60) { cell.accessoryType = UITableViewCellAccessoryCheckmark; } else { cell.accessoryType = UITableViewCellAccessoryNone; }
            cell.textLabel.text = @"Minutely";  // 60
            break;
        case 1:
            if (storedUpdateInterval == 3600) { cell.accessoryType = UITableViewCellAccessoryCheckmark; } else { cell.accessoryType = UITableViewCellAccessoryNone; }
            cell.textLabel.text = @"Hourly";    // 3600
            break;
        case 2:
            if (storedUpdateInterval == 86400) { cell.accessoryType = UITableViewCellAccessoryCheckmark; } else { cell.accessoryType = UITableViewCellAccessoryNone; }
            cell.textLabel.text = @"Daily";     // 86400
            break;
        case 3:
            if (storedUpdateInterval == 604800) { cell.accessoryType = UITableViewCellAccessoryCheckmark; } else { cell.accessoryType = UITableViewCellAccessoryNone; }
            cell.textLabel.text = @"Weekly";     // 604800
            break;

        default:
            break;
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    /*
    NSArray *visibleCells = [tableView visibleCells];

    for (UITableViewCell *cell in visibleCells) {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
     */

    for (int i = 0; i < 4; i ++) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:i inSection:0];
        UITableViewCell *currentCell = [self.tableView cellForRowAtIndexPath:indexPath];
        currentCell.accessoryType = UITableViewCellAccessoryNone;
    }

    UITableViewCell *currentCell = [self.tableView cellForRowAtIndexPath:indexPath];
    currentCell.accessoryType = UITableViewCellAccessoryCheckmark;

    switch (indexPath.row) {
        case 0:
            [[NSUserDefaults standardUserDefaults]setObject:@60 forKey:@"updateInterval"];
            break;
        case 1:
            [[NSUserDefaults standardUserDefaults]setObject:@3600 forKey:@"updateInterval"];
            break;
        case 2:
            [[NSUserDefaults standardUserDefaults]setObject:@86400 forKey:@"updateInterval"];
            break;
        case 3:
            [[NSUserDefaults standardUserDefaults]setObject:@604800 forKey:@"updateInterval"];
            break;

        default:
            break;
    }

}


/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 100.0f;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    UITextView *footerView = [[UITextView alloc]initWithFrame:CGRectMake(0.0f, 0.0f, self.tableView.frame.size.width, 100.0f)];
    footerView.backgroundColor = CLEAR;
    footerView.text = @"The update interval determines how often the app is trying to check the server for new assets.";
    footerView.textAlignment = NSTextAlignmentCenter;
    footerView.textColor = [UIColor grayColor];
    footerView.font = [UIFont systemFontOfSize:[UIFont smallSystemFontSize]];
    return footerView;
}

@end
