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
#import <FontAwesome+iOS/NSString+FontAwesome.h>
#import "PrefsTableViewController.h"
#import "NSString+Additions.h"
#import "Constants.h"
#import "UIImage+Additions.h"
#import "AppDelegate.h"
#import "LoginViewController.h"


@interface MasterViewController ()

@property NSMutableArray *objects;
// ---------------------------------------------------------------------------------------------------------------------
@property UILabel *label;
// ---------------------------------------------------------------------------------------------------------------------
@end

@implementation MasterViewController


// ---------------------------------------------------------------------------------------------------------------------
#pragma mark - Init & lifecycle
// ---------------------------------------------------------------------------------------------------------------------
- (void)awakeFromNib
{
    [super awakeFromNib];
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        self.clearsSelectionOnViewWillAppear = NO;
        self.preferredContentSize = CGSizeMake(320.0, 600.0);
    }

    NSLog(@">>>>>> %@", [[LovelyDataProvider sharedInstance]theCredentialsDict]);
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(checkForLocalCredentials)
                                                 name:@"DidLogoutNotification" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(updateFeed:)
                                                 name:@"AppDidNoticeOldFeed" object:nil];
}

// ---------------------------------------------------------------------------------------------------------------------
- (void)viewDidLoad
{
    [super viewDidLoad];
    self.detailViewController =
    (DetailViewController *)[[self.splitViewController.viewControllers lastObject] topViewController];
    [self.navigationController setToolbarHidden:NO animated:YES];
    [self setupToolbar];

}

// ---------------------------------------------------------------------------------------------------------------------
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

// ---------------------------------------------------------------------------------------------------------------------
- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self checkForLocalCredentials];
}

// ---------------------------------------------------------------------------------------------------------------------
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


// ---------------------------------------------------------------------------------------------------------------------
#pragma mark - Visual setup
// ---------------------------------------------------------------------------------------------------------------------
- (void)setupToolbar
{
    self.label = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 200, 30)];
    self.label.text = @"Initializing...";
    self.label.textColor = WHITE;
    self.label.textAlignment = NSTextAlignmentLeft;
    self.label.font = [UIFont fontWithName:@"helveticaNeue-Light" size:14.0f];

    NSDictionary *textAttributes = @{ NSFontAttributeName : [UIFont fontWithName:kFontAwesomeFamilyName size:22.0f],
                                      NSForegroundColorAttributeName : WHITE
                                      };

    UIBarButtonItem *labelItem = [[UIBarButtonItem alloc]initWithCustomView:self.label];
    UIBarButtonItem *logoutItem = [[UIBarButtonItem alloc]initWithTitle:@"\uf085"
                                                                  style:UIBarButtonItemStyleDone
                                                                 target:self
                                                                 action:@selector(showSettingsPanel:)];

    [logoutItem setTitleTextAttributes:textAttributes forState:UIControlStateNormal];

    [self setToolbarItems:@[

                            labelItem,
                            [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
                                                                          target:nil
                                                                          action:nil],
                            logoutItem,
                            [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace
                                                                          target:nil
                                                                          action:nil],

                            ] animated:YES];
}


// ---------------------------------------------------------------------------------------------------------------------
#pragma mark - Visual setup
// ---------------------------------------------------------------------------------------------------------------------
- (void)checkForLocalCredentials
{
    NSLog(@"check for local credentials");
    if ([[LovelyDataProvider sharedInstance]hasCredentials]) {
        self.label.text = [[LovelyDataProvider sharedInstance]theCredentialsDict][@"userName"];
        [self checkForLocalFeed];
    }
    else {
        [self launchCredentialsDialogPanel];
    }
}


// ---------------------------------------------------------------------------------------------------------------------
#pragma mark - UITableViewDataSource protocol methods
// ---------------------------------------------------------------------------------------------------------------------
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

// ---------------------------------------------------------------------------------------------------------------------
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.objects.count;
}

// ---------------------------------------------------------------------------------------------------------------------
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];

    NSDate *object = self.objects[indexPath.row];
    cell.textLabel.text = [object description];
    return cell;
}

// ---------------------------------------------------------------------------------------------------------------------
#pragma mark - Brings up the login panel
// ---------------------------------------------------------------------------------------------------------------------
- (void)launchCredentialsDialogPanel
{
    /*

    UIAlertController *loginController = [UIAlertController alertControllerWithTitle:@"Who are you?"
                                                                             message:@"Please enter your credentials."
                                                                      preferredStyle:UIAlertControllerStyleAlert];

    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK"
                                                       style:UIAlertActionStyleDefault
                                                     handler:^(UIAlertAction *action) {
                                                         UITextField *userNameField =
                                                         loginController.textFields.firstObject;
                                                         UITextField *passwordField =
                                                         loginController.textFields.lastObject;
                                                         [self validateUsername:userNameField.text
                                                                    andPassword:passwordField.text];
                                                     }];
    okAction.enabled = NO;
    [loginController addAction:okAction];

    UIAlertAction *forgotPasswordAction = [UIAlertAction actionWithTitle:@"Forgot password"
                                                           style:UIAlertActionStyleCancel
                                                         handler:^(UIAlertAction *action) {
                                                             NSLog(@"ForgotPassword");
                                                             [self launchForgotPasswordDialogPanel:nil];
                                                         }];
    [loginController addAction:forgotPasswordAction];

    [loginController addTextFieldWithConfigurationHandler:^(UITextField *textField) {
        textField.placeholder = @"eMail address";
        textField.text = kDefaultUser;
        textField.borderStyle = UITextBorderStyleRoundedRect;
        textField.keyboardType = UIKeyboardTypeEmailAddress;

        [[NSNotificationCenter defaultCenter]addObserverForName:@"UITextFieldTextDidChangeNotification"
                                                         object:textField
                                                          queue:[NSOperationQueue mainQueue]
                                                     usingBlock:^(NSNotification *note) {
                                                         okAction.enabled = textField.text.length > 0;
                                                     }];
    }];

    [loginController addTextFieldWithConfigurationHandler:^(UITextField *textField) {
        textField.placeholder = @"Password";
        textField.text = kDefaultPassword;
        textField.secureTextEntry = YES;
    }];

    loginController.view.tintColor = [UIColor blackColor];

    [self presentViewController:loginController animated:YES completion:^{
        NSLog(@"loginController: %@", loginController);
    }];
     
     */

    UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    LoginViewController *vc = [sb instantiateViewControllerWithIdentifier:@"LoginViewController"];
    UINavigationController *loginNavigationController = [[UINavigationController alloc]initWithRootViewController:vc];
    loginNavigationController.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    loginNavigationController.modalPresentationStyle = UIModalPresentationFormSheet ;
    [self presentViewController:loginNavigationController animated:YES completion:^{
        //
    }];

}


// ---------------------------------------------------------------------------------------------------------------------
#pragma mark - Validate credentials by storing them and try to get the feed with
// ---------------------------------------------------------------------------------------------------------------------
- (void)validateUsername:(NSString *)userName andPassword:(NSString *)password
{
    self.label.text = userName;
    [[LovelyDataProvider sharedInstance]setUserName:userName andPassword:password];
    [self checkForLocalFeed];
}


// ---------------------------------------------------------------------------------------------------------------------
#pragma mark - Check for local feed an get one if needed
// ---------------------------------------------------------------------------------------------------------------------
- (void)checkForLocalFeed
{
    
    if ([[LovelyDataProvider sharedInstance]hasLocalFeed]) {
        NSLog(@"Got locally stored feed!");
    }
    else {
        [self fetchFeed];
    }
}

// ---------------------------------------------------------------------------------------------------------------------
#pragma mark - Actual fetch
// ---------------------------------------------------------------------------------------------------------------------
- (void)fetchFeed
{
    NSString *SHA1 = [[LovelyDataProvider sharedInstance]SHA1];
    NSDictionary *params = @{
                             @"uid" : SHA1,
                             @"foo" : [[[NSDate date]description]SHA1],
                             };

    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication]delegate];

    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:appDelegate.window animated:YES];
    hud.mode = MBProgressHUDModeIndeterminate;
    hud.labelText = @"Loading";

    [appDelegate setNetworkActivityIndicatorVisible:YES];



    NSString *sUrl = kEndpointURL;
    MKNetworkOperation *op = [[MKNetworkOperation alloc]initWithURLString:sUrl params:params
                                                               httpMethod:@"GET"];
    NSLog(@"op: %@", op);

    [op onDownloadProgressChanged:^(double progress) {
        NSLog(@"%.2f", progress);
    }];

    [op addCompletionHandler:^(MKNetworkOperation *completedOperation) {
        NSLog(@"GOT FEED");

        NSError *parsingError;

        NSDictionary *json = [NSJSONSerialization JSONObjectWithData:completedOperation.responseData
                                                             options:kNilOptions
                                                               error:&parsingError];
        
        if ([[LovelyDataProvider sharedInstance]storeFeed:json]) {

            NSLog(@"FEED WRITTEN");
            NSDate *lastSuccessfulUpdate = [NSDate date];
            [[NSUserDefaults standardUserDefaults]setObject:lastSuccessfulUpdate forKey:@"lastSuccessfulUpdate"];
            [[NSUserDefaults standardUserDefaults]synchronize];
            [appDelegate setNetworkActivityIndicatorVisible:NO];

        }
        else {
            NSLog(@"WRITING FEED FAILED!");
        }
        [hud hide:YES];


    } errorHandler:^(MKNetworkOperation *completedOperation, NSError *error) {
        switch (error.code) {
            case 404:
                NSLog(@"404 - Not found!");
                break;
            case 403:
                NSLog(@"403 - Forbidden!");
                [[LovelyDataProvider sharedInstance]removeCredentials];
                [self launchCredentialsDialogPanel];
                break;
                
            default:
                break;
        }
        [hud hide:YES];

    }];

    [op setCacheHandler:^(MKNetworkOperation *completedOperation) {
    }];
    
    [op start];
}

- (IBAction)showSettingsPanel:(id)sender
{
    UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    PrefsTableViewController *vc = [sb instantiateViewControllerWithIdentifier:@"PrefsTableViewController"];
    UINavigationController *prefNavigationController = [[UINavigationController alloc]initWithRootViewController:vc];
    prefNavigationController.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    prefNavigationController.modalPresentationStyle = UIModalPresentationFormSheet ;
    [self presentViewController:prefNavigationController animated:YES completion:^{
        //
    }];
}

- (IBAction)launchForgotPasswordDialogPanel:(id)sender
{

}

- (void)updateFeed:(NSNotification *)notification
{

    NSLog(@"Got notification!");
    NSString *hashedUUID = [[LovelyDataProvider sharedInstance]SHA1];
    NSDictionary *params = @{
                             @"uid" : hashedUUID,
                             @"foo" : [[[NSDate date] description] SHA1],
                             };

    NSString *sUrl = kEndpointURL;
    MKNetworkOperation *op = [[MKNetworkOperation alloc]initWithURLString:sUrl params:params
                                                               httpMethod:@"GET"];
    [op onDownloadProgressChanged:^(double progress) {
        NSLog(@"%.2f", progress);
    }];

    [op addCompletionHandler:^(MKNetworkOperation *completedOperation) {
        NSLog(@"Beep!");
        NSError *parsingError;
        NSDictionary *json = [NSJSONSerialization JSONObjectWithData:completedOperation.responseData
                                                             options:kNilOptions
                                                               error:&parsingError];

        if ([[LovelyDataProvider sharedInstance]storeFeed:json]) {
            NSLog(@"Wrote feeed!");
            NSDate *lastSuccessfulUpdate = [NSDate date];
            [[NSUserDefaults standardUserDefaults]setObject:lastSuccessfulUpdate forKey:@"lastSuccessfulUpdate"];
        }
        else {
            NSLog(@"WRITING FEED FAILED!");
        }
    } errorHandler:^(MKNetworkOperation *completedOperation, NSError *error) {
        switch (error.code) {
            case 404:
                NSLog(@"404 - Not found!");
                break;
            case 403:
                NSLog(@"403 - Forbidden!");
                break;
            default:
                break;
        }
    }];

    [op setCacheHandler:^(MKNetworkOperation *completedOperation) {
    }];

    [op start];
}


@end
