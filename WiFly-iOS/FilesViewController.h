//
//  FilesViewController.h
//  WiFly-iOS
//
//  Created by Sherlock Zhong on 5/4/15.
//  Copyright (c) 2015 SherlockZhong. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "FileTableViewCell.h"

@interface FilesViewController : UITableViewController <UIActionSheetDelegate, UIDocumentInteractionControllerDelegate>

@property (strong, nonatomic) NSMutableArray *files;

@property (strong, nonatomic) NSString *currentFile;

@property (strong, nonatomic) UIDocumentInteractionController *dic;

@end
