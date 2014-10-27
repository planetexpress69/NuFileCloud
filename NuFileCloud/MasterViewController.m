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
- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self checkForLocalCredentials];
}

// ---------------------------------------------------------------------------------------------------------------------
#pragma mark - Visual setup
// ---------------------------------------------------------------------------------------------------------------------
- (void)setupToolbar
{
    self.label = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 200, 30)];
    self.label.text = @"Initializing...";
    self.label.textColor = [UIColor whiteColor];
    self.label.textAlignment = NSTextAlignmentLeft;

    NSDictionary *textAttributes = @{ NSFontAttributeName : [UIFont fontWithName: kFontAwesomeFamilyName size: 22.0f],
                                      NSForegroundColorAttributeName : [UIColor whiteColor]
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
        [self checkForLocalFeed];
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
        textField.text = @"kautz@jakota.de";
        textField.borderStyle = UITextBorderStyleRoundedRect;
        textField.keyboardType = UIKeyboardTypeEmailAddress;
        //textField.borderStyle = UITextBorderStyleNone;

        [[NSNotificationCenter defaultCenter]addObserverForName:@"UITextFieldTextDidChangeNotification"
                                                         object:textField
                                                          queue:[NSOperationQueue mainQueue]
                                                     usingBlock:^(NSNotification *note) {
                                                         okAction.enabled = textField.text.length > 0;
                                                     }];
    }];

    [loginController addTextFieldWithConfigurationHandler:^(UITextField *textField) {
        textField.placeholder = @"Password";
        textField.text = @"Iwork4Honeywell";
        textField.secureTextEntry = YES;
    }];

    loginController.view.tintColor = [UIColor blackColor];



    [self presentViewController:loginController animated:YES completion:^{
        NSLog(@"loginContrioller: %@", loginController);

    }];
}

- (void)launchForgotPasswordDialogPanel
{

}

- (void)validateUsername:(NSString *)userName andPassword:(NSString *)password
{
    self.label.text = userName;
    [[LovelyDataProvider sharedInstance]setUserName:userName andPassword:password];
    [self checkForLocalFeed];
}

- (void)checkForLocalFeed
{
    
    if ([[LovelyDataProvider sharedInstance]hasLocalFeed]) {
        NSLog(@"Application is ready to rumble...");
    }
    else {
        [self fetchFeed];
    }
}

- (void)fetchFeed
{
    NSString *SHA1 = [[LovelyDataProvider sharedInstance]SHA1];
    NSDictionary *params = @{
                             @"uid" : SHA1,
                             @"foo" : [[[NSDate date]description]SHA1],
                             };
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.mode = MBProgressHUDModeIndeterminate;
    hud.labelText = @"Loading";

    NSString *sUrl = kEndpointURL;
    MKNetworkOperation *op = [[MKNetworkOperation alloc]initWithURLString:sUrl params:params
                                                               httpMethod:@"GET"];

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
        NSLog(@"Cache handler...");
    }];
    
    [op start];
}

- (IBAction)showSettingsPanel:(id)sender
{
    UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    PrefsTableViewController *vc = [sb instantiateViewControllerWithIdentifier:@"PrefsTableViewController"];

    UINavigationController *prefNavigationController = [[UINavigationController alloc]initWithRootViewController:vc];
    prefNavigationController.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    prefNavigationController.modalPresentationStyle = UIModalPresentationFormSheet;
    [self presentViewController:prefNavigationController animated:YES completion:^{
        //
    }];
}

@end
