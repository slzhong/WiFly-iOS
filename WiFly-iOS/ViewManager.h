//
//  ViewManager.h
//  WiFly-iOS
//
//  Created by Sherlock Zhong on 5/6/15.
//  Copyright (c) 2015 SherlockZhong. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "AFHTTPRequestOperationManager.h"

#import "ServerManager.h"
#import "DevicesViewController.h"
#import "FilesViewController.h"

@class DevicesViewController;
@class FilesViewController;

@interface ViewManager : NSObject <UIAlertViewDelegate>

@property (strong, nonatomic) DevicesViewController *devicesViewController;
@property (strong, nonatomic) FilesViewController *filesViewController;
@property (strong, nonatomic) NSString *currentViewController;
@property (strong, nonatomic) NSString *extra;

+(ViewManager *)sharedInstance;

- (void) globalAlert:(NSInteger)style title:(NSString *)title content:(NSString *)content cancel:(NSString *)cancel confirm:(NSString *)confirm extra:(NSString *)extra;

@end
