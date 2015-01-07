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
// ---------------------------------------------------------------------------------------------------------------------
@property NSMutableArray *objects;
@property NSMutableArray *bookmarkLists;
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

    DLog(@">>>>>> %@", [[LovelyDataProvider sharedInstance]theCredentialsDict]);
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(checkForLocalCredentials)
                                                 name:@"DidLogoutNotification" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(updateLabel:)
                                                 name:@"DidLoginNotification" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(updateFeed:)
                                                 name:@"AppDidNoticeOldFeed" object:nil];

    self.title = @"NuFileCloud";
}

// ---------------------------------------------------------------------------------------------------------------------
- (void)viewDidLoad
{
    [super viewDidLoad];
    self.detailViewController = (DetailViewController *)[[self.splitViewController.viewControllers lastObject] topViewController];
    //[self.navigationController setToolbarHidden:NO animated:NO];
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
    DLog(@"check for local credentials");
    if ([[LovelyDataProvider sharedInstance]hasCredentials]) {
        self.label.text = [[LovelyDataProvider sharedInstance]theCredentialsDict][@"userName"];
        [self checkForLocalFeed];
    }
    else {
        self.label.text = @"";
        [self killMe];
        [self launchCredentialsDialogPanel];
    }
}

- (void)updateLabel:(NSNotification *)notification
{
    self.label.text = [[LovelyDataProvider sharedInstance]theCredentialsDict][@"userName"];
    [self loadData];
}

// ---------------------------------------------------------------------------------------------------------------------
#pragma mark - UITableViewDataSource protocol methods
// ---------------------------------------------------------------------------------------------------------------------
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return self.bookmarkLists ? 2 : 1;
}

// ---------------------------------------------------------------------------------------------------------------------
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    switch (section) {
        case 0:
            return self.objects.count;
            break;

        default:
            return 1;
            break;
    }
}

// ---------------------------------------------------------------------------------------------------------------------
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];

    switch (indexPath.section) {
        case 0: {
            NSString *categoryName = _objects[indexPath.row][@"title"];
            if ([categoryName isEqualToString:@"None"]) {
                categoryName = @"Other";
            }
            cell.textLabel.text = [NSString stringWithFormat:@"%@ (%d)",
                                   categoryName,
                                   [_objects[indexPath.row][@"num"]intValue]];
        }
            break;

        default:
            cell.textLabel.text = @"Lis #1";
            break;
    }
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
        DLog(@"Got locally stored feed!");
        [self loadData];
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
    DLog(@"op: %@", op);

    [op onDownloadProgressChanged:^(double progress) {
        DLog(@"%.2f", progress);
    }];

    [op addCompletionHandler:^(MKNetworkOperation *completedOperation) {
        DLog(@"GOT FEED");

        NSError *parsingError;

        NSDictionary *json = [NSJSONSerialization JSONObjectWithData:completedOperation.responseData
                                                             options:kNilOptions
                                                               error:&parsingError];
        
        if ([[LovelyDataProvider sharedInstance]storeFeed:json]) {

            DLog(@"FEED WRITTEN");
            NSDate *lastSuccessfulUpdate = [NSDate date];
            [[NSUserDefaults standardUserDefaults]setObject:lastSuccessfulUpdate forKey:@"lastSuccessfulUpdate"];
            [[NSUserDefaults standardUserDefaults]synchronize];
            [appDelegate setNetworkActivityIndicatorVisible:NO];
            
            [self loadData];

        }
        else {
            DLog(@"WRITING FEED FAILED!");
        }
        [hud hide:YES];


    } errorHandler:^(MKNetworkOperation *completedOperation, NSError *error) {
        switch (error.code) {
            case 404:
                DLog(@"404 - Not found!");
                break;
            case 403:
                DLog(@"403 - Forbidden!");
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
    DLog(@"Got notification!");
    NSString *hashedUUID = [[LovelyDataProvider sharedInstance]SHA1];
    NSDictionary *params = @{
                             @"uid" : hashedUUID,
                             @"foo" : [[[NSDate date] description] SHA1],
                             };

    NSString *sUrl = kEndpointURL;
    MKNetworkOperation *op = [[MKNetworkOperation alloc]initWithURLString:sUrl params:params
                                                               httpMethod:@"GET"];
    [op onDownloadProgressChanged:^(double progress) {
        DLog(@"%.2f", progress);
    }];

    [op addCompletionHandler:^(MKNetworkOperation *completedOperation) {
        DLog(@"Beep!");
        NSError *parsingError;
        NSDictionary *json = [NSJSONSerialization JSONObjectWithData:completedOperation.responseData
                                                             options:kNilOptions
                                                               error:&parsingError];

        if ([[LovelyDataProvider sharedInstance]storeFeed:json]) {
            DLog(@"Wrote feeed!");
            NSDate *lastSuccessfulUpdate = [NSDate date];
            [[NSUserDefaults standardUserDefaults]setObject:lastSuccessfulUpdate forKey:@"lastSuccessfulUpdate"];
            [self loadData];
        }
        else {
            DLog(@"WRITING FEED FAILED!");
        }
    } errorHandler:^(MKNetworkOperation *completedOperation, NSError *error) {
        switch (error.code) {
            case 404:
                DLog(@"404 - Not found!");
                break;
            case 403:
                DLog(@"403 - Forbidden!");
                break;
            default:
                break;
        }
    }];

    [op setCacheHandler:^(MKNetworkOperation *completedOperation) {
    }];

    [op start];
}

//----------------------------------------------------------------------------------------------------------------------
- (void)loadData
{
    _objects = [[NSMutableArray alloc]initWithCapacity:6];

    NSDictionary    *jsonDict       = [[LovelyDataProvider sharedInstance]theFeedDict];


    NSArray         *categoryArray  = jsonDict[@"payload"][@"category"];
    NSDictionary    *categoryDict   = nil;
    NSDictionary    *category       = nil;
    unsigned long   numOfAssets     = 0;

    for (category in categoryArray) {

        NSArray *assetArray = category[@"assets"];
        NSArray *byAllowedRegionsFilteredArray = [self filterArrayForAllowedRegions:assetArray];

        NSArray *filteredArray = [self filterArrayForSelectedProperties:byAllowedRegionsFilteredArray];

        NSArray *descriptorArray = [NSArray arrayWithObject:[[NSSortDescriptor alloc] initWithKey:@"webText"
                                                                                        ascending:YES]];
        NSArray *sortedAssetArray = [filteredArray sortedArrayUsingDescriptors:descriptorArray];

        categoryDict = @{@"title"   : category[@"categoryName"],
                         @"num"     : [NSNumber numberWithLong:sortedAssetArray.count],
                         @"assets"  : sortedAssetArray};

        numOfAssets += sortedAssetArray.count;

        if (sortedAssetArray.count > 0) {
            [_objects addObject:categoryDict];
        }
    }

    [_objects sortUsingDescriptors:[NSArray arrayWithObject:[[NSSortDescriptor alloc] initWithKey:@"title"
                                                                                        ascending:YES]]];
    DLog(@"number of categories: %lu", (unsigned long)_objects.count);
    //////self.numOfAssets = numOfAssets;
    [self.tableView reloadData];
}

//----------------------------------------------------------------------------------------------------------------------
#pragma mark - Haystack filter (allowedRegions)
//----------------------------------------------------------------------------------------------------------------------
- (NSArray *)filterArrayForAllowedRegions:(NSArray *)anAssetArray
{
    NSString *sAllowedRegions = [[NSUserDefaults standardUserDefaults]objectForKey:ALLOWEDREGIONS];
    NSArray *aAllowedRegions = [sAllowedRegions componentsSeparatedByString:@","];

    NSDictionary *asset = nil;
    NSMutableArray *filteredArray   = [[NSMutableArray alloc]initWithCapacity:1];

    for (asset in anAssetArray) {
        BOOL        shouldAddRegion         = NO;
        NSString    *region;

        for (region in aAllowedRegions) {
            if ([asset[@"salesRegions"]containsString:region] ||
                [asset[@"salesRegions"]isEqualToString:region]) {
                shouldAddRegion = YES;
            }
        }

        if (shouldAddRegion) {
            [filteredArray addObject:asset];
        } else {
            // fix special case for ALL
            if (!aAllowedRegions || [aAllowedRegions[0]isEqualToString:@""]) {
                [filteredArray addObject:asset];
            }
        }
    }

    return filteredArray;
}

//----------------------------------------------------------------------------------------------------------------------
#pragma mark - Haystack filter (chosen properties)
//----------------------------------------------------------------------------------------------------------------------
- (NSArray *)filterArrayForSelectedProperties:(NSArray *)anAssetArray
{
    NSDictionary *selectedProperties    = [[NSUserDefaults standardUserDefaults]objectForKey:@"selectedProperties"];

    //DLog(@">>> /// >>> : \n\n\n%@", selectedProperties);

    NSArray *aSelectedBrands            = selectedProperties[@"brands"];
    NSArray *aSelectedLanguages         = selectedProperties[@"language"];
    NSArray *aSelectedTypes             = selectedProperties[@"assetType"];


    NSDictionary *asset                 = nil;
    NSMutableArray *filteredArray       = [[NSMutableArray alloc]initWithCapacity:1];

    for (asset in anAssetArray) {

        BOOL        shouldAddBrand      = NO;
        BOOL        shouldAddLanguage   = NO;
        BOOL        shouldAddType       = NO;

        NSString    *brand              = nil;
        NSString    *language           = nil;
        NSString    *type               = nil;

        for (brand in aSelectedBrands) {
            if ([asset[@"brands"]containsString:brand] || [asset[@"brands"]isEqualToString:brand]) {
                shouldAddBrand = YES;
            }
        }

        for (language in aSelectedLanguages) {
            if ([asset[@"language"]containsString:language] || [asset[@"language"]isEqualToString:language]) {
                shouldAddLanguage = YES;
            }
        }

        for (type in aSelectedTypes) {
            if ([asset[@"assetType"]containsString:type] || [asset[@"assetType"]isEqualToString:type]) {
                shouldAddType = YES;
            }
        }

        if (shouldAddBrand && shouldAddLanguage && shouldAddType) {
            [filteredArray addObject:asset];
        } else {
            if (!selectedProperties) {
                [filteredArray addObject:asset];
            }
        }
    }
    return filteredArray;
}

//----------------------------------------------------------------------------------------------------------------------
-(void)killMe
{
    _objects = nil;
    [self.tableView reloadData];
}

- (void)storeAllowedRegions:(NSString *)regions
{

#pragma mark TODO add special case for ALL

    NSString *storedRegions = [[NSUserDefaults standardUserDefaults]objectForKey:ALLOWEDREGIONS];

    if (!storedRegions)
    {
        // nor regions yet, so store unconditional
        [[NSUserDefaults standardUserDefaults]setObject:regions forKey:ALLOWEDREGIONS];
    }
    else
    {
        // we do have some, so compare
        if ([storedRegions isEqualToString:regions])
        {
            // do nothing
        }
        else
        {
            [[NSUserDefaults standardUserDefaults]setObject:regions forKey:ALLOWEDREGIONS];
            DLog(@"Regions for user changed from %@ to %@", storedRegions, regions);
            //////[self triggerReload:[NSNotification notificationWithName:@"AllowedRegionsHasChangedNotification" object:nil]];

        }
    }
    // we send out a notification to inform the viewcontroller to reload the data
}


@end
