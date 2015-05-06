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
    
    ViewManager *vm = [ViewManager sharedInstance];
    [vm setDevicesViewController:self];
    
    [self initData];
    [self initViews];
    
    if ([self getSsid].length <= 0) {
        [self showErrorWithText:@"WiFi Not In Range\nMake Sure WiFi Is Turned On"];
    } else if ([self checkId]) {
        [self startServer];
        [self startTransmitter];
    } else {
        [self showPrompt];
    }
}

- (void)viewDidAppear:(BOOL)animated {
    if ([self getSsid].length > 0 && [self checkId]) {
        self.progressShouldDisplay = YES;
        [self detectDevice];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) initViews {
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
    self.navigationItem.backBarButtonItem = item;
    
    [SVProgressHUD setBackgroundColor:[UIColor colorWithRed:78/255.0f green:208/255.0f blue:253/255.0f alpha:0.9f]];
    [SVProgressHUD setForegroundColor:[UIColor whiteColor]];
    
    self.pv_files.delegate = self;
    self.pv_files.dataSource = self;
    
    self.tv_devices.delegate = self;
    self.tv_devices.dataSource = self;
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideFiles)];
    tapGestureRecognizer.cancelsTouchesInView = NO;
    [self.tv_devices addGestureRecognizer:tapGestureRecognizer];
}

- (void) initData {
    self.files = [NSMutableArray array];
    self.devices = [NSMutableArray array];
    self.cells = [NSMutableArray array];
    self.current = 1;
    self.scanned = 0;
    self.addedIps = @"";
    self.ip = @"";
    self.ipPrefix = @"";
    self.progressDisplayed = NO;
    self.pickerDisplayed = NO;
}

- (BOOL)checkId {
    return [[NSUserDefaults standardUserDefaults] valueForKey:@"name"] != nil;
}

- (IBAction)showFiles:(id)sender {
    self.progressShouldDisplay = NO;
    [self dismissProgress];
    [self performSegueWithIdentifier:@"showFiles" sender:sender];
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
    [self detectDevice];
    for (int i = 0; i < 10; i++) {
        [self searchIp:[NSString stringWithFormat:@"%@%d", self.ipPrefix, self.current + i]];
    }
}

- (void)detectDevice {
    if (self.progressShouldDisplay && self.devices.count <= 0) {
        NSString *hint = @"Searching For Devices...";
        NSString *ssid = [self getSsid];
        if (ssid.length > 0) {
            hint = [NSString stringWithFormat:@"%@\n\nCurrent WiFi:\n %@", hint, ssid];
        }
        [self showProgressWithText:hint];
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
    if ([self.addedIps rangeOfString:[device valueForKey:@"url"]].location > self.addedIps.length) {
        self.addedIps = [NSString stringWithFormat:@"%@,%@", self.addedIps, [device valueForKey:@"url"]];
        [self addDevice:device];
    }
}

- (void)addDevice:(NSDictionary *)device {
    if (self.devices.count == 0) {
        [self dismissProgress];
    }
    [self.devices addObject:device];
    self.cells = [NSMutableArray array];
    [self.tv_devices reloadData];
}

- (void)removeDevice:(NSString *)ip {
    NSString *url = [NSString stringWithFormat:@"http://%@:12580/", ip];
    if ([self.addedIps rangeOfString:url].location < self.addedIps.length) {
        NSMutableString *tmp = [[NSMutableString alloc] initWithString:self.addedIps];
        [tmp deleteCharactersInRange:[tmp rangeOfString:url]];
        self.addedIps = tmp;
        for (NSUInteger i = 0; i < self.devices.count; i++) {
            if ([[self.devices[i] valueForKey:@"url"] isEqualToString:url]) {
                [self.devices removeObjectAtIndex:i];
                self.cells = [NSMutableArray array];
                [self.tv_devices reloadData];
                break;
            }
        }
    }
    [self detectDevice];
}

#pragma mark - Upload Functions
- (void)showActionSheet {
    UIActionSheet *as = [[UIActionSheet alloc] initWithTitle:@"Select A Type You Want To Send" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Choose From Album", @"Choose From Received Files", nil];
    [as showInView:self.view];
}

- (void)showImagePicker {
    UIImagePickerController *ipc = [[UIImagePickerController alloc] init];
    ipc.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    ipc.mediaTypes = [[NSArray alloc] initWithObjects:(NSString*)kUTTypeImage,nil];
    ipc.delegate = self;
    ipc.allowsEditing = NO;
    [self presentViewController:ipc animated:YES completion:^{}];
}

- (void)showFiles {
    if (!self.pickerDisplayed) {
        self.pickerDisplayed = YES;
        FileManager *fm = [FileManager sharedInstance];
        self.files = [fm listFiles];
        [self.pv_files reloadAllComponents];
        [UIView beginAnimations:@"PickerViewFlyIn" context:nil];
        [UIView setAnimationDuration:0.3];
        self.v_container.frame = CGRectMake(0, [[UIScreen mainScreen] bounds].size.height - 200, [[UIScreen mainScreen] bounds].size.width, 200);
        [UIView commitAnimations];
        if (self.currentFile == nil) {
            self.currentFile = self.files[0];
        }
    }
}

- (void)hideFiles {
    if (self.pickerDisplayed) {
        self.pickerDisplayed = NO;
        [UIView beginAnimations:@"PickerViewFlyIn" context:nil];
        [UIView setAnimationDuration:0.3];
        self.v_container.frame = CGRectMake(0, [[UIScreen mainScreen] bounds].size.height, [[UIScreen mainScreen] bounds].size.width, 200);
        [UIView commitAnimations];
    }
}

- (IBAction)confirmFile:(id)sender {
    [self hideFiles];
    [self startUpload];
}

- (IBAction)cancelFile:(id)sender {
    [self hideFiles];
}

- (void)startUpload {
    DeviceTableViewCell *cell = self.cells[self.currentIndex.row];
    [cell setStatus:@"sending..." type:nil];
    FileManager *fm = [FileManager sharedInstance];
    NSString *url = [NSString stringWithFormat:@"%@upload", [self.currentTarget valueForKey:@"url"]];
    NSString *formName = @"file";
    if ([[self.currentTarget valueForKey:@"type"] isEqualToString:@"ios"]) {
        url = [NSString stringWithFormat:@"%@/upload", [url substringToIndex:url.length - 13]];
        formName = @"files[]";
    }
    NSMutableURLRequest *request = [[AFHTTPRequestSerializer serializer] multipartFormRequestWithMethod:@"POST" URLString:url parameters:nil constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
        if (self.imageData != nil) {
            NSString *name = [NSString stringWithFormat:@"IMG_%ld.jpg", (long)[[NSDate date] timeIntervalSince1970]];
            NSString *type = @"image/jpg";
            [formData appendPartWithFileData:self.imageData name:formName fileName:name mimeType:type];
            [formData appendPartWithFormData:[name dataUsingEncoding:NSUTF8StringEncoding] name:@"name"];
            [formData appendPartWithFormData:[type dataUsingEncoding:NSUTF8StringEncoding] name:@"type"];
            [formData appendPartWithFormData:[[NSString stringWithFormat:@"%lu", (unsigned long)self.imageData.length] dataUsingEncoding:NSUTF8StringEncoding] name:@"size"];
            self.imageData = nil;
        } else {
            NSString *name = [self.currentFile valueForKey:@"name"];
            NSString *path = [fm getFilePath:name];
            [formData appendPartWithFileURL:[NSURL fileURLWithPath:path] name:formName fileName:name mimeType:[fm getMime:name] error:nil];
            [formData appendPartWithFormData:[name dataUsingEncoding:NSUTF8StringEncoding] name:@"name"];
            [formData appendPartWithFormData:[[NSString stringWithFormat:@"%@", [self.currentFile valueForKey:@"size"]] dataUsingEncoding:NSUTF8StringEncoding] name:@"size"];
            [formData appendPartWithFormData:[[fm getMime:name] dataUsingEncoding:NSUTF8StringEncoding] name:@"type"];
        }
        [formData appendPartWithFormData:[[NSString stringWithFormat:@"/"] dataUsingEncoding:NSUTF8StringEncoding] name:@"path"];
        [formData appendPartWithFormData:[[[NSUserDefaults standardUserDefaults] valueForKey:@"name"] dataUsingEncoding:NSUTF8StringEncoding] name:@"from"];
    } error:nil];
    
    AFURLSessionManager *manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    NSProgress *progress = nil;
    
    NSURLSessionUploadTask *uploadTask = [manager uploadTaskWithStreamedRequest:request progress:&progress completionHandler:^(NSURLResponse *response, id responseObject, NSError *error) {
        if (error && ![[error localizedDescription] isEqualToString:@"Request failed: unacceptable content-type: text/plain"]) {
            [self showErrorWithText:@"Failed To Send"];
            [cell setStatus:@"error" type:@"error"];
        } else {
            [self showSuccessWithText:@"Transfer Succeeded"];
            [cell setStatus:@"√" type:@"success"];
        }
    }];
    
    [uploadTask resume];
}

#pragma mark - SVProgressHUD
- (void)showSuccessWithText:(NSString *)text {
    [SVProgressHUD showSuccessWithStatus:text maskType:SVProgressHUDMaskTypeNone];
}

- (void)showErrorWithText:(NSString *)text {
    [SVProgressHUD showErrorWithStatus:text maskType:SVProgressHUDMaskTypeNone];
}

- (void)showInfoWithText:(NSString *)text {
    [SVProgressHUD showInfoWithStatus:text maskType:SVProgressHUDMaskTypeNone];
}

- (void)showProgressWithText:(NSString *)text {
    if (!self.progressDisplayed) {
        [SVProgressHUD showWithStatus:text maskType:SVProgressHUDMaskTypeNone];
        self.progressDisplayed = YES;
    }
}

- (void)dismissProgress {
    if (self.progressDisplayed) {
        [SVProgressHUD dismiss];
        self.progressDisplayed = NO;
    }
}

#pragma mark - Action Sheet Delegates
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 0) {
        [self showImagePicker];
    } else if (buttonIndex == 1) {
        [self showFiles];
    }
}

#pragma mark - Picker View Delegates
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    return self.files.count;
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    return [self.files[row] valueForKey:@"name"];
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    self.currentFile = self.files[row];
}

#pragma mark - Image Picker Delegates
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    [picker dismissViewControllerAnimated:YES completion:^{}];
    UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];
    self.imageData = UIImageJPEGRepresentation(image, 1);
    [self startUpload];
}

#pragma mark - Table View Delegates
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
    [self.cells addObject:cell];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    self.currentIndex = indexPath;
    self.currentTarget = self.devices[indexPath.row];
    [self.tv_devices deselectRowAtIndexPath:indexPath animated:YES];
    [self hideFiles];
    [self showActionSheet];
}

@end
