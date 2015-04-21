//
//  DevicesViewController.h
//  WiFly-iOS
//
//  Created by Sherlock Zhong on 4/20/15.
//  Copyright (c) 2015 SherlockZhong. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "SVProgressHUD.h"
#import "AFHTTPRequestOperationManager.h"

#import "ServerManager.h"
#import "DeviceTableViewCell.h"

@interface DevicesViewController : UIViewController<UITableViewDelegate, UITableViewDataSource>

@property (strong, nonatomic) IBOutlet UITableView *tv_devices;

@property (strong, nonatomic) NSMutableArray *devices;
@property (strong, nonatomic) NSString *ip;
@property (strong, nonatomic) NSString *ipPrefix;

@property int scanned;
@property int current;

@property BOOL progressDisplayed;

@end
