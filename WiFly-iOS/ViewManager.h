//
//  ViewManager.h
//  WiFly-iOS
//
//  Created by Sherlock Zhong on 5/6/15.
//  Copyright (c) 2015 SherlockZhong. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "DevicesViewController.h"
#import "FilesViewController.h"

@class DevicesViewController;
@class FilesViewController;

@interface ViewManager : NSObject

@property (strong, nonatomic) DevicesViewController *devicesViewController;
@property (strong, nonatomic) FilesViewController *filesViewController;

+(ViewManager *)sharedInstance;

@end
