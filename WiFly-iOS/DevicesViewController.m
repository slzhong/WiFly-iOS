//
//  DevicesViewController.m
//  WiFly-iOS
//
//  Created by Sherlock Zhong on 4/20/15.
//  Copyright (c) 2015 SherlockZhong. All rights reserved.
//

#import "DevicesViewController.h"

@interface DevicesViewController ()

@end

@implementation DevicesViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self initViews];
    
    if ([self checkId]) {
        [self startServer];
    } else {
        [self showPrompt];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) initViews {
    [SVProgressHUD setBackgroundColor:[UIColor colorWithRed:78/255.0f green:208/255.0f blue:253/255.0f alpha:0.9f]];
    [SVProgressHUD setForegroundColor:[UIColor whiteColor]];
}

- (BOOL)checkId {
    return [[NSUserDefaults standardUserDefaults] valueForKey:@"name"] != nil;
}

- (void)showPrompt {
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"WELCOME" message:@"Enter A Name For Your Device" delegate:self cancelButtonTitle:@"DONE" otherButtonTitles:nil, nil];
    alertView.alertViewStyle = UIAlertViewStylePlainTextInput;
    [alertView show];
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    UITextField *tf = [alertView textFieldAtIndex:0];
    [[NSUserDefaults standardUserDefaults] setValue:tf.text forKey:@"name"];
    [self startServer];
}

- (void)startServer {
    ServerManager *sm = [ServerManager sharedInstance];
    [sm start];
    
    NSString *name = [[NSUserDefaults standardUserDefaults] valueForKey:@"name"];
    NSString *url = sm.server.serverURL.absoluteString;
    [sm setInfo:name url:url];
    
    [self searchDevice];
}

- (void)searchDevice {
    [self showProgressWithText:@"Searching For Devices..."];
}

- (void)showSuccessWithText:(NSString *)text {
    [SVProgressHUD showSuccessWithStatus:text maskType:SVProgressHUDMaskTypeGradient];
}

- (void)showErrorWithText:(NSString *)text {
    [SVProgressHUD showErrorWithStatus:text maskType:SVProgressHUDMaskTypeClear];
}

- (void)showInfoWithText:(NSString *)text {
    [SVProgressHUD showInfoWithStatus:text maskType:SVProgressHUDMaskTypeClear];
}

- (void)showProgressWithText:(NSString *)text {
    [SVProgressHUD showWithStatus:text maskType:SVProgressHUDMaskTypeClear];
}

- (void)dismissProgress {
    [SVProgressHUD dismiss];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
