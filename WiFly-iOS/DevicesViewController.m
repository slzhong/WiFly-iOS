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
        [self startTransmitter];
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
    
    self.tv_devices.delegate = self;
    self.tv_devices.dataSource = self;
}

- (void) initData {
    self.devices = [NSMutableArray array];
    self.current = 1;
    self.scanned = 0;
    self.addedIps = @"";
    self.ip = @"";
    self.ipPrefix = @"";
    self.progressDisplayed = NO;
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

- (NSString *)getSsid {
    NSString *result = @"";
    CFArrayRef interfaces = CNCopySupportedInterfaces();
    if (interfaces != nil) {
        CFDictionaryRef info = CNCopyCurrentNetworkInfo(CFArrayGetValueAtIndex(interfaces, 0));
        if (info != nil) {
            NSDictionary *dict = (NSDictionary *)CFBridgingRelease(info);
            result = [dict valueForKey:@"SSID"];
        }
    }
    return result;
}

- (void)startServer {
    ServerManager *sm = [ServerManager sharedInstance];
    [sm start];
    NSString *name = [[NSUserDefaults standardUserDefaults] valueForKey:@"name"];
    NSString *url = sm.server.serverURL.absoluteString;
    [sm setInfo:name url:url];
    self.ip = [url substringWithRange:NSMakeRange(7, [url rangeOfString:@":12580"].location - 7)];
    NSArray *components = [self.ip componentsSeparatedByString:@"."];
    for (int i = 0; i < components.count - 1; i++) {
        self.ipPrefix = [NSString stringWithFormat:@"%@%@.", self.ipPrefix,components[i]];
    }
    [self searchDevice];
}

- (void)startTransmitter {
    ServerManager *sm = [ServerManager sharedInstance];
    [sm startTransmitter];
}

- (void)searchDevice {
    if (self.devices.count <= 0) {
        NSString *hint = @"Searching For Devices...";
        NSString *ssid = [self getSsid];
        if (ssid.length > 0) {
            hint = [NSString stringWithFormat:@"%@\n\nCurrent WiFi:\n %@", hint, ssid];
        }
        [self showProgressWithText:hint];
    }
    for (int i = 0; i < 10; i++) {
        [self searchIp:[NSString stringWithFormat:@"%@%d", self.ipPrefix, self.current + i]];
    }
}

- (void)searchIp:(NSString *)ip {
    if (![ip isEqualToString:self.ip]) {
        NSString *url = [NSString stringWithFormat:@"http://%@:12580/id", ip];
        AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
        manager.responseSerializer = [AFJSONResponseSerializer serializer];
        manager.requestSerializer=[AFJSONRequestSerializer serializer];
        manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"application/json"];
        [manager.requestSerializer willChangeValueForKey:@"timeoutInterval"];
        manager.requestSerializer.timeoutInterval = 1.f;
        [manager.requestSerializer didChangeValueForKey:@"timeoutInterval"];
        [manager GET:url parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
            [self checkDevice:responseObject];
            [self searchNext];
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            [self removeDevice:ip];
            [self searchNext];
        }];
    } else {
        [self searchNext];
    }
}

- (void)searchNext {
    if (++self.scanned < 10) {
        return;
    } else {
        self.scanned = 0;
        self.current = (self.current > 250) ? 1 : self.current + 10;
        [self searchDevice];
    }
}

- (void)checkDevice:(NSDictionary *)device {
    if (![self.addedIps containsString:[device valueForKey:@"url"]]) {
        self.addedIps = [NSString stringWithFormat:@"%@,%@", self.addedIps, [device valueForKey:@"url"]];
        [self addDevice:device];
    }
}

- (void)addDevice:(NSDictionary *)device {
    if (self.devices.count == 0) {
        [self dismissProgress];
    }
    [self.devices addObject:device];
    [self.tv_devices reloadData];
}

- (void)removeDevice:(NSString *)ip {
    NSString *url = [NSString stringWithFormat:@"http://%@:12580/", ip];
    if ([self.addedIps containsString:url]) {
        NSMutableString *tmp = [[NSMutableString alloc] initWithString:self.addedIps];
        [tmp deleteCharactersInRange:[tmp rangeOfString:url]];
        self.addedIps = tmp;
        for (NSUInteger i = 0; i < self.devices.count; i++) {
            if ([[self.devices[i] valueForKey:@"url"] isEqualToString:url]) {
                [self.devices removeObjectAtIndex:i];
                [self.tv_devices reloadData];
                break;
            }
        }
    }
    if (self.devices.count <= 0) {
        NSString *hint = @"Searching For Devices...";
        NSString *ssid = [self getSsid];
        if (ssid.length > 0) {
            hint = [NSString stringWithFormat:@"%@\n\nCurrent WiFi:\n %@", hint, ssid];
        }
        [self showProgressWithText:hint];
    }
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
    if (!self.progressDisplayed) {
        [SVProgressHUD showWithStatus:text maskType:SVProgressHUDMaskTypeClear];
        self.progressDisplayed = YES;
    }
}

- (void)dismissProgress {
    if (self.progressDisplayed) {
        [SVProgressHUD dismiss];
        self.progressDisplayed = NO;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.devices.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    DeviceTableViewCell *cell = [self.tv_devices dequeueReusableCellWithIdentifier:@"DeviceTableViewCell"];
    if (cell == nil) {
        cell = [[[NSBundle mainBundle] loadNibNamed:@"DeviceTableViewCell" owner:self options:nil] lastObject];
    }
    NSMutableDictionary *device = [self.devices objectAtIndex:indexPath.row];
    NSString *ip = [[device valueForKey:@"url"] substringWithRange:NSMakeRange(7, [[device valueForKey:@"url"] rangeOfString:@":12580"].location - 7)];
    [cell setViews:[NSString stringWithFormat:@"%@.png", [device valueForKey:@"type"]] name:[device valueForKey:@"name"] ip:ip];
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
