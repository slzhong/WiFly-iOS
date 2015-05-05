//
//  FileManager.m
//  WiFly-iOS
//
//  Created by Sherlock Zhong on 5/5/15.
//  Copyright (c) 2015 SherlockZhong. All rights reserved.
//

#import "FileManager.h"

static FileManager *fileManager;

@implementation FileManager

+(FileManager *)sharedInstance {
    if (fileManager == nil) {
        fileManager = [[FileManager alloc] init];
    }
    return fileManager;
}

- (NSMutableArray *)listFiles {
    NSFileManager *fm = [NSFileManager defaultManager];
    NSString *dp = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
    NSMutableArray *result = [NSMutableArray array];
    NSDirectoryEnumerator *em = [fm enumeratorAtPath:dp];
    NSString *fileName;
    while (fileName = [em nextObject] ) {
        NSMutableDictionary *file = [NSMutableDictionary dictionary];
        NSDictionary *attributes = [fm attributesOfItemAtPath:[dp stringByAppendingPathComponent:fileName] error:nil];
        [file setValue:fileName forKey:@"name"];
        [file setValue:[attributes valueForKey:NSFileSize] forKey:@"size"];
        [result addObject:file];
    }
    return result;
}

- (void)deleteFile:(NSString *)path {
    [[NSFileManager defaultManager] removeItemAtPath:path error:nil];
}

- (NSString *)getFilePath:(NSString *)name {
    return [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject] stringByAppendingPathComponent:name];
}

- (NSString *)getMime:(NSString *)name {
    NSArray *parts = [name componentsSeparatedByString:@"."];
    NSString *suffix = parts[parts.count - 1];
    if ([suffix isEqualToString:@"jpg"] ||
        [suffix isEqualToString:@"png"] ||
        [suffix isEqualToString:@"gif"] ||
        [suffix isEqualToString:@"jpeg"]) {
        return [NSString stringWithFormat:@"image/%@", suffix];
    } else if ([suffix isEqualToString:@"mp3"] ||
               [suffix isEqualToString:@"wmv"] ||
               [suffix isEqualToString:@"acc"] ||
               [suffix isEqualToString:@"m4a"]) {
        return [NSString stringWithFormat:@"audio/%@", suffix];
    } else {
        return @"text/plain";
    }
}

@end
