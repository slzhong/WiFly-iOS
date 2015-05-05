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
    
}

- (void)updateFiles {
    self.files = [NSMutableArray array];
    NSString *documentsPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
    NSFileManager *fm = [NSFileManager defaultManager];
    NSDirectoryEnumerator *em = [fm enumeratorAtPath:documentsPath];
    NSString *fileName;
    while (fileName = [em nextObject] ) {
        NSMutableDictionary *file = [NSMutableDictionary dictionary];
        NSDictionary *attributes = [fm attributesOfItemAtPath:[documentsPath stringByAppendingPathComponent:fileName] error:nil];
        [file setValue:fileName forKey:@"name"];
        [file setValue:[attributes valueForKey:NSFileSize] forKey:@"size"];
        [self.files addObject:file];
    }
    [self.tableView reloadData];
}

- (void)showActionSheet:(NSInteger)index {
    NSString *documentsPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
    NSString *name = [self.files[index] valueForKey:@"name"];
    self.currentFile = [documentsPath stringByAppendingPathComponent:name];
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
        // Delete the row from the data source
//        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
        NSLog(@"delete");
    }
}

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

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
