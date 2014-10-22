//
//  MasterViewController.m
//  NuFileCloud
//
//  Created by Martin Kautz on 22.10.14.
//  Copyright (c) 2014 JAKOTA Design Group. All rights reserved.
//

#import "MasterViewController.h"
#import "DetailViewController.h"
#import "LovelyDataProvider.h"
#import <MKNetworkKit/MKNetworkKit.h>
#import <MBProgressHUD/MBProgressHUD.h>


@interface MasterViewController ()

@property NSMutableArray *objects;
@property UILabel *label;
@end

@implementation MasterViewController

- (void)awakeFromNib
{
    [super awakeFromNib];
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        self.clearsSelectionOnViewWillAppear = NO;
        self.preferredContentSize = CGSizeMake(320.0, 600.0);
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.detailViewController =
    (DetailViewController *)[[self.splitViewController.viewControllers lastObject] topViewController];

    [self.navigationController setToolbarHidden:NO animated:YES];
    [self setupToolbar];
}

- (void)setupToolbar
{
    self.label = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 200, 30)];
    self.label.text = @"Initializing...";
    self.label.textColor = [UIColor whiteColor];
    self.label.textAlignment = NSTextAlignmentLeft;
    UIBarButtonItem *labelItem = [[UIBarButtonItem alloc]initWithCustomView:self.label];
    UIBarButtonItem *logoutItem = [[UIBarButtonItem alloc]initWithTitle:@"Logout"
                                                                  style:UIBarButtonItemStyleDone
                                                                 target:self
                                                                 action:@selector(requestLogout:)];
    [self setToolbarItems:@[
                            [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil],
                            labelItem,
                            logoutItem,
                            [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil]
                            ] animated:YES];

}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self checkForLocalCredentials];

}

- (IBAction)requestLogout:(id)sender
{
    [[LovelyDataProvider sharedInstance]removeCredentials];
    self.label.text = @"Anonymous";
    [self launchCredentialsDialogPanel];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)checkForLocalCredentials
{
    if ([[LovelyDataProvider sharedInstance]hasCredentials]) {
        self.label.text = [[LovelyDataProvider sharedInstance]theCredentialsDict][@"userName"];
    }
    else {
        [self launchCredentialsDialogPanel];
    }
}


#pragma mark - Table View

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.objects.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];

    NSDate *object = self.objects[indexPath.row];
    cell.textLabel.text = [object description];
    return cell;
}


- (void)launchCredentialsDialogPanel
{
    UIAlertController *loginController = [UIAlertController alertControllerWithTitle:@"Who are you?"
                                                                             message:@"Please enter your credentials."
                                                                      preferredStyle:UIAlertControllerStyleAlert];

    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK"
                                                       style:UIAlertActionStyleDefault
                                                     handler:^(UIAlertAction *action) {
                                                         UITextField *userNameField = loginController.textFields.firstObject;
                                                         UITextField *passwordField = loginController.textFields.lastObject;
                                                         [self validateUsername:userNameField.text andPassword:passwordField.text];
                                                     }];
    okAction.enabled = NO;
    [loginController addAction:okAction];

    UIAlertAction *forgotPasswordAction = [UIAlertAction actionWithTitle:@"Forgot password"
                                                           style:UIAlertActionStyleCancel
                                                         handler:^(UIAlertAction *action) {
                                                             NSLog(@"ForgotPassword");
                                                             [self launchForgotPasswordDialogPanel];
                                                         }];
    [loginController addAction:forgotPasswordAction];


    [loginController addTextFieldWithConfigurationHandler:^(UITextField *textField) {
        textField.placeholder = @"eMail address";
        textField.keyboardType = UIKeyboardTypeEmailAddress;
        textField.borderStyle = UITextBorderStyleNone;

        [[NSNotificationCenter defaultCenter]addObserverForName:@"UITextFieldTextDidChangeNotification"
                                                         object:textField
                                                          queue:[NSOperationQueue mainQueue]
                                                     usingBlock:^(NSNotification *note) {
                                                         okAction.enabled = textField.text.length > 0;
                                                     }];
    }];

    [loginController addTextFieldWithConfigurationHandler:^(UITextField *textField) {
        textField.placeholder = @"Password";
        textField.secureTextEntry = YES;
    }];

    loginController.view.tintColor = [UIColor blackColor];

    [self presentViewController:loginController animated:YES completion:^{
        //
    }];
}

- (void)launchForgotPasswordDialogPanel
{

}

- (void)validateUsername:(NSString *)userName andPassword:(NSString *)password
{
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.mode = MBProgressHUDModeIndeterminate;
    hud.labelText = @"Loading";


        NSString *sUrl = @"http://www.teambender.de/scrape.php";
        MKNetworkOperation *op = [[MKNetworkOperation alloc]initWithURLString:sUrl params:nil
                                                                   httpMethod:@"GET"];

        [op addCompletionHandler:^(MKNetworkOperation *completedOperation) {
            NSLog(@"GOT STUFF");
            self.label.text = userName;
            [[LovelyDataProvider sharedInstance]setUserName:userName andPassword:password];
            [hud hide:YES];

        } errorHandler:^(MKNetworkOperation *completedOperation, NSError *error) {
            NSLog(@"error: %@", error);
            [hud hide:YES];

        }];

        [op setCacheHandler:^(MKNetworkOperation *completedOperation) {
        }];
        
        [op start];
        









    //NSLog(@"validating got started!");
    //[[LovelyDataProvider sharedInstance]checkCredentials];
    //if([userName isEqualToString:@"a"] && [password isEqualToString:@"a"]) {
    //    NSLog(@"Niiiice!");
    //}
    //else {
    //    [self launchCredentialsDialogPanel];
    //}
}

@end
