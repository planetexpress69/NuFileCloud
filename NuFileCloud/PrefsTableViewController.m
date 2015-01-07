//
//  PrefsTableViewController.m
//  NuFileCloud
//
//  Created by Martin Kautz on 23.10.14.
//  Copyright (c) 2014 JAKOTA Design Group. All rights reserved.
//

#import "PrefsTableViewController.h"
#import "LovelyDataProvider.h"
#import "UpdateIntervalTableViewController.h"

@interface PrefsTableViewController ()
@property (nonatomic, strong) NSDictionary *userDict;
@end

@implementation PrefsTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;

    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;

    self.title = @"Preferences";

    UIBarButtonItem *closeItem = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemDone
                                                                              target:self action:@selector(close:)];

    self.navigationItem.leftBarButtonItem = closeItem;

    UIBarButtonItem *logoutItem = [[UIBarButtonItem alloc]initWithTitle:@"Logout" style:UIBarButtonItemStyleDone
                                                                 target:self action:@selector(requestLogout:)];

    self.navigationItem.rightBarButtonItem = logoutItem;

    // get rid of the UpdateIntervalTableViewController's back button title
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@""
                                                                             style:UIBarButtonItemStylePlain
                                                                            target:nil
                                                                            action:nil];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.userDict = [[LovelyDataProvider sharedInstance]theFeedDict][@"user"];
    DLog(@"userDict: %@", self.userDict);
    [self.tableView reloadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    switch (section) {
        case 0:
            return 4;
            break;
        case 1:
            return 1;
            break;
        default:
            return 1;
            break;
    }
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

    if (indexPath.section == 0) {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"UserCell" forIndexPath:indexPath];

        switch (indexPath.row) {

            case 0:
                cell.textLabel.text = [NSString stringWithFormat:@"%@", self.userDict[@"name"]];
                cell.detailTextLabel.text = @"Name";
                break;

            case 1:
                cell.textLabel.text = [NSString stringWithFormat:@"%@", self.userDict[@"email"]];
                cell.detailTextLabel.text = @"email";
                break;

            case 2:
                cell.textLabel.text =
                [NSString stringWithFormat:@"%@", [self.userDict[@"brand"]isEqualToString:@""] ? @"ALL" : @"Value" ];
                cell.detailTextLabel.text = @"brand";
                break;

            case 3:
                cell.textLabel.text = [NSString stringWithFormat:@"%@", [self.userDict[@"regions"]isEqualToString:@""] ? @"ALL" : @"Value" ];
                cell.detailTextLabel.text = @"regions";
                break;

            case 4:
                cell.textLabel.text = [NSString stringWithFormat:@"%@", self.userDict[@"lastlogin"]];
                cell.detailTextLabel.text = @"lastlogin";
                break;

            default:
                break;
        }
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        return cell;
    }
    else if (indexPath.section == 1) {
        NSNumber *storedUpdateInterval = [[NSUserDefaults standardUserDefaults]objectForKey:@"updateInterval"];
        NSString *updateIntervalText = nil;
        switch (storedUpdateInterval.intValue) {
            case 60:
                updateIntervalText = @"Minutely";
                break;
            case 3600:
                updateIntervalText = @"Hourly";
                break;
            case 86400:
                updateIntervalText = @"Daily";
                break;
            case 604800:
                updateIntervalText = @"Weekly";
                break;
            default:
                updateIntervalText = @"Undefined";
                break;
        }

        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"UpdateCell" forIndexPath:indexPath];
        cell.textLabel.text = updateIntervalText;
        return cell;
    }
    else {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"UpdateCell" forIndexPath:indexPath];
        return cell;
    }


}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    switch (section) {
        case 0:
            return 0.0f;
            break;
        case 1:
            return 22.0f;
            break;
        default:
            return 0.0f;
            break;
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    switch (section) {
        case 0: {
            return nil;
        }
            break;

        case 1: {
            NSDate *lastSuccessfulUpdate = [[NSUserDefaults standardUserDefaults]objectForKey:@"lastSuccessfulUpdate"];

            UILabel *descLabel = [[UILabel alloc]initWithFrame:CGRectMake(0,0, self.tableView.frame.size.width, 12.0f)];
            descLabel.textAlignment = NSTextAlignmentCenter;
            descLabel.textColor = [UIColor grayColor];
            descLabel.font = [UIFont systemFontOfSize:[UIFont smallSystemFontSize]];
            descLabel.text = [NSString stringWithFormat:@"Last update: %@", lastSuccessfulUpdate != nil ? lastSuccessfulUpdate : @"-"];
            return descLabel;
        }
            break;

        default:
            return nil;
            break;
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    switch (section) {
        case 0:
            return @"User";
            break;

        case 1:
            return @"Update interval";
            break;

        default:
            return @"Other";
            break;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.section) {
        case 0:
            // do nothing
            break;
        case 1: {

            UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
            UpdateIntervalTableViewController *vc = [sb instantiateViewControllerWithIdentifier:@"UpdateIntervalTableViewController"];
            [self.navigationController pushViewController:vc animated:YES];
        }
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

- (IBAction)close:(id)sender
{
    [self.presentingViewController dismissViewControllerAnimated:YES
                                                      completion:^{
                                                          //
                                                      }];
}

// ---------------------------------------------------------------------------------------------------------------------
- (IBAction)requestLogout:(id)sender
{
    self.userDict = nil;
    [[LovelyDataProvider sharedInstance]removeCredentials];
    [[LovelyDataProvider sharedInstance]removeFeedWithFile:YES];
    [self.presentingViewController dismissViewControllerAnimated:YES completion:^{
        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad || 1 == 1) {
            [[NSNotificationCenter defaultCenter] postNotificationName:@"DidLogoutNotification" object:nil];
        }
    }];
}


@end
