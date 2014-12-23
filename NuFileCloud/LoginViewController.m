//
//  LoginViewController.m
//  NuFileCloud
//
//  Created by Martin Kautz on 19.12.14.
//  Copyright (c) 2014 JAKOTA Design Group. All rights reserved.
//

#import "LoginViewController.h"
#import "TBButton.h"
#import "LovelyDataProvider.h"
#import "NSString+Additions.h"
#import "AppDelegate.h"
#import "MBProgressHUD.h"
#import <MKNetworkKit/MKNetworkEngine.h>
#import "Constants.h"

@interface LoginViewController () <UITextFieldDelegate>
@property (nonatomic, weak) IBOutlet UITextField    *usernameTextField;
@property (nonatomic, weak) IBOutlet UITextField    *passwordTextField;
@property (nonatomic, weak) IBOutlet TBButton       *loginButton;
@end

@implementation LoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.loginButton.normalBackgroundColor = [UIColor clearColor];
    self.loginButton.highlightedBackgroundColor = [UIColor blackColor];
    self.loginButton.normalForegroundColor = [UIColor blackColor];
    self.loginButton.highlightedForegroundColor = [UIColor whiteColor];
    self.loginButton.cornerRadius = 6.0f;
    self.loginButton.borderWidth = 2.0f;
    self.loginButton.normalBorderColor = [UIColor blackColor];
    self.loginButton.highlightedBorderColor = [UIColor blackColor];
    [self.loginButton setFlatTitle:@"Login"];
    [self.loginButton addTarget:self action:@selector(checkCredentials) forControlEvents:UIControlEventTouchUpInside];

    self.usernameTextField.delegate         = self;
    self.usernameTextField.keyboardType     = UIKeyboardTypeEmailAddress;
    self.passwordTextField.delegate         = self;
    self.passwordTextField.keyboardType     = UIKeyboardTypeDefault;
    self.passwordTextField.secureTextEntry  = YES;

#if DEBUG
    if (![[LovelyDataProvider sharedInstance]hasCredentials]) {
        self.usernameTextField.text = @"kautz@jakota.de";
        self.passwordTextField.text = @"Iwork4Honeywell";
    }
#endif


    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark - UITextFieldDelegate protocol methods
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    if (textField == self.usernameTextField) {
        textField.returnKeyType = UIReturnKeyNext;
    } else {
        textField.returnKeyType = UIReturnKeyJoin;
    }
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField
{
    return YES; // return YES to allow editing to stop and to resign first responder status. NO to disallow the editing session to end
}
- (void)textFieldDidEndEditing:(UITextField *)textField
{
    // may be called if forced even if shouldEndEditing returns NO (e.g. view removed from window) or endEditing:YES called
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    return YES;
    /// return NO to not change text
}

- (BOOL)textFieldShouldClear:(UITextField *)textField
{
    return YES;// called when clear button pressed. return NO to ignore (no notifications)
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (textField == self.usernameTextField) {
        [textField resignFirstResponder];
        [self.passwordTextField becomeFirstResponder];
    } else if (textField == self.passwordTextField) {
        // here you can define what happens
        // when user presses return on the email field


        [self checkCredentials];
    }
    return YES;
}

// ---------------------------------------------------------------------------------------------------------------------
#pragma mark - Actual fetch
// ---------------------------------------------------------------------------------------------------------------------
-(void)checkCredentials
{
    [[LovelyDataProvider sharedInstance]setUserName:[self.usernameTextField.text lowercaseString] andPassword:self.passwordTextField.text];
    [self.usernameTextField resignFirstResponder];
    [self.passwordTextField resignFirstResponder];
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
                [self.presentingViewController dismissViewControllerAnimated:YES completion:^{
                    //
                }];

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
                    //[self launchCredentialsDialogPanel];
                    [appDelegate setNetworkActivityIndicatorVisible:NO];
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



@end
