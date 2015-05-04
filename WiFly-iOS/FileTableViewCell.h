//
//  FileTableViewCell.h
//  WiFly-iOS
//
//  Created by Sherlock Zhong on 5/4/15.
//  Copyright (c) 2015 SherlockZhong. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FileTableViewCell : UITableViewCell

@property (strong, nonatomic) IBOutlet UIImageView *iv_type;
@property (strong, nonatomic) IBOutlet UILabel *lb_name;
@property (strong, nonatomic) IBOutlet UILabel *lb_size;

- (void)setViews:(NSString *)name size:(NSString *)size;
- (void)setIcon:(NSString *)name;
- (void)setName:(NSString *)name;
- (void)setSize:(NSString *)size;

@end
