//
//  DeviceTableViewCell.h
//  WiFly-iOS
//
//  Created by Sherlock Zhong on 4/20/15.
//  Copyright (c) 2015 SherlockZhong. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DeviceTableViewCell : UITableViewCell

@property (strong, nonatomic) IBOutlet UIImageView *iv_icon;
@property (strong, nonatomic) IBOutlet UILabel *lb_name;
@property (strong, nonatomic) IBOutlet UILabel *lb_ip;

- (void)setViews:(NSString *)icon name:(NSString *)name ip:(NSString *)ip;
- (void)setIcon:(NSString *)icon;
- (void)setName:(NSString *)name;
- (void)setIp:(NSString *)ip;

@end
