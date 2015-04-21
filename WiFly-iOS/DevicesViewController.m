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
    
    [self initData];
    [self initViews];
    
    if ([self checkId]) {
        [self startServer];
    } else {
        [self showPrompt];
    }
    
    for (int i = 0; i < 10; i++) {
        NSMutableDictionary *device = [NSMutableDictionary dictionary];
        [device setValue:@"mac" forKey:@"type"];
        [device setValue:[NSString stringWithFormat:@"mac%d", i] forKey:@"name"];
        [device setValue:[NSString stringWithFormat:@"0.0.0.%d", i] forKey:@"ip"];
        [self.devices addObject:device];
    }
    [self.tv_devices reloadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) initViews {
    [SVProgressHUD setBackgroundColor:[UIColor colorWithRed:78/255.0f green:208/255.0f blue:253/255.0f alpha:0.9f]];
    [SVProgressHUD setForegroundColor:[UIColor whiteColor]];
    
    self.tv_devices.delegate = self;
    self.tv_devices.dataSource = self;
//    self.tv_devices.contentInset = UIEdgeInsetsMake(-64, 0, 0, 0);
}

- (void) initData {
    self.devices = [NSMutableArray array];
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
//    [self showProgressWithText:@"Searching For Devices..."];
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

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.devices.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
//    ContactParentTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ContactParentTableViewCell"];
//    if (cell == nil) {
//        cell = [[[NSBundle mainBundle] loadNibNamed:@"ContactParentTableViewCell" owner:self options:nil]lastObject];
//    }
//    cell.selectionStyle = UITableViewCellSelectionStyleNone;
//    ContactEntity *ce = self.sbResult[row];
//    NSString *subTitle;
//    if([ce.type isEqualToString:@"1"]) {
//        subTitle = [NSString stringWithFormat:@"%@的%@",ce.dsc,ce.role];
//    } else {
//        subTitle = [NSString stringWithFormat:@"%@老师",ce.dsc];
//    }
//    [cell setAvatar:ce.avatar_url name:ce.name dsc:subTitle];
//    return cell;

    DeviceTableViewCell *cell = [self.tv_devices dequeueReusableCellWithIdentifier:@"DeviceTableViewCell"];
    if (cell == nil) {
        cell = [[[NSBundle mainBundle] loadNibNamed:@"DeviceTableViewCell" owner:self options:nil] lastObject];
    }
//    [cell setViews:@"mac.png" name:@"mac" ip:@"0.0.0.0"];
    NSMutableDictionary *device = [self.devices objectAtIndex:indexPath.row];
    [cell setViews:[NSString stringWithFormat:@"%@.png", [device valueForKey:@"type"]] name:[device valueForKey:@"name"] ip:[device valueForKey:@"ip"]];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"%@", indexPath);
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
