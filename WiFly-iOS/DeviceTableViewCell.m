//
//  DeviceTableViewCell.m
//  WiFly-iOS
//
//  Created by Sherlock Zhong on 4/20/15.
//  Copyright (c) 2015 SherlockZhong. All rights reserved.
//

#import "DeviceTableViewCell.h"

@implementation DeviceTableViewCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setViews:(NSString *)icon name:(NSString *)name ip:(NSString *)ip {
    [self setIcon:icon];
    [self setName:name];
    [self setIp:ip];
}

- (void)setIcon:(NSString *)icon {
    self.iv_icon.image = [UIImage imageNamed:icon];
}

- (void)setName:(NSString *)name {
    self.lb_name.text = name;
}

- (void)setIp:(NSString *)ip {
    self.lb_ip.text = ip;
}

- (void)setStatus:(NSString *)text type:(NSString *)type {
    if (type == nil || [type isEqualToString:@"normal"]) {
        self.lb_status.textColor = [UIColor lightGrayColor];
    } else if ([type isEqualToString:@"error"]) {
        self.lb_status.textColor = [UIColor redColor];
    } else if ([type isEqualToString:@"success"]) {
        self.lb_status.textColor = [UIColor greenColor];
    }
    self.lb_status.text = text;
}

@end
