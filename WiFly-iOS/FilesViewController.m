//
//  FilesViewController.m
//  WiFly-iOS
//
//  Created by Sherlock Zhong on 5/4/15.
//  Copyright (c) 2015 SherlockZhong. All rights reserved.
//

#import "FilesViewController.h"

@interface FilesViewController ()

@end

@implementation FilesViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    ViewManager *vm = [ViewManager sharedInstance];
    [vm setFilesViewController:self];
    
    [self initViews];
    [self initData];
}

- (void)viewWillAppear:(BOOL)animated {
    [self updateFiles];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)initViews {
    
}

- (void)initData {
    self.documentPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
    self.fileManager = [NSFileManager defaultManager];
}

- (void)updateFiles {
    FileManager *fm = [FileManager sharedInstance];
    self.files = [fm listFiles];
    [self.tableView reloadData];
}

- (void)deleteFile:(NSIndexPath *)indexPath {
    NSString *name = [self.files[indexPath.row] valueForKey:@"name"];
    NSString *path = [self.documentPath stringByAppendingPathComponent:name];
    [self.fileManager removeItemAtPath:path error:nil];
    [self.files removeObjectAtIndex:indexPath.row];
    [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
}

- (void)showActionSheet:(NSInteger)index {
    NSString *name = [self.files[index] valueForKey:@"name"];
    self.currentFile = [self.documentPath stringByAppendingPathComponent:name];
    UIActionSheet *as = [[UIActionSheet alloc] initWithTitle:[NSString stringWithFormat:@"Select An Operation For\n%@", name] delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Send To Peer", @"Show Preview", @"Open In Other Apps", nil];
    [as showInView:self.view];
}

- (void)showCurrentFile {
    self.dic = [UIDocumentInteractionController interactionControllerWithURL:[NSURL fileURLWithPath:self.currentFile]];
    self.dic.delegate = self;
    [self.dic presentPreviewAnimated:YES];
}

- (void)openCurrentFile {
    self.dic = [UIDocumentInteractionController interactionControllerWithURL:[NSURL fileURLWithPath:self.currentFile]];
    self.dic.delegate = self;
    [self.dic presentOpenInMenuFromRect:CGRectZero inView:self.view animated:YES];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.files.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    FileTableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"FileTableViewCell"];
    if (cell == nil) {
        cell = [[[NSBundle mainBundle] loadNibNamed:@"FileTableViewCell" owner:self options:nil] lastObject];
    }
    NSMutableDictionary *file = [self.files objectAtIndex:indexPath.row];
    [cell setViews:[file valueForKey:@"name"] size:[file valueForKey:@"size"]];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self showActionSheet:indexPath.row];
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        [self deleteFile:indexPath];
    }
}

#pragma mark - Action Sheet Delegates
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 0) {
        
    } else if (buttonIndex == 1) {
        [self showCurrentFile];
    } else if (buttonIndex == 2) {
        [self openCurrentFile];
    }
}

#pragma mark - Document Interaction Controller Delegate
- (UIViewController *)documentInteractionControllerViewControllerForPreview:(UIDocumentInteractionController *)controller {
    return self;
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
