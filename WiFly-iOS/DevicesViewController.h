//
//  DevicesViewController.h
//  WiFly-iOS
//
//  Created by Sherlock Zhong on 4/20/15.
//  Copyright (c) 2015 SherlockZhong. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <SystemConfiguration/CaptiveNetwork.h>

#import "SVProgressHUD.h"
#import "AFURLSessionManager.h"
#import "AFHTTPRequestOperationManager.h"

#import "ServerManager.h"
#import "FileManager.h"
#import "ViewManager.h"
#import "DeviceTableViewCell.h"

@interface DevicesViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, UIActionSheetDelegate, UIPickerViewDelegate, UIPickerViewDataSource, UIImagePickerControllerDelegate, UINavigationControllerDelegate>

@property (strong, nonatomic) IBOutlet UITableView *tv_devices;
@property (strong, nonatomic) IBOutlet UIView *v_container;
@property (strong, nonatomic) IBOutlet UIPickerView *pv_files;

@property (strong, nonatomic) NSIndexPath *currentIndex;
@property (strong, nonatomic) NSDictionary *currentTarget;
@property (strong, nonatomic) NSDictionary *currentFile;
@property (strong, nonatomic) NSMutableArray *devices;
@property (strong, nonatomic) NSMutableArray *files;
@property (strong, nonatomic) NSMutableArray *cells;
@property (strong, nonatomic) NSString *addedIps;
@property (strong, nonatomic) NSString *ip;
@property (strong, nonatomic) NSString *ipPrefix;
@property (strong, nonatomic) NSData *imageData;

@property int scanned;
@property int current;

@property BOOL progressDisplayed;
@property BOOL progressShouldDisplay;
@property BOOL pickerDisplayed;

@end
