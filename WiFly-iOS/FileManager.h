//
//  FileManager.h
//  WiFly-iOS
//
//  Created by Sherlock Zhong on 5/5/15.
//  Copyright (c) 2015 SherlockZhong. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FileManager : NSObject

+ (FileManager *)sharedInstance;

- (NSMutableArray *)listFiles;

- (void)deleteFile:(NSString *)path;

- (NSString *)getFilePath:(NSString *)name;

- (NSString *)getMime:(NSString *)name;

@end
