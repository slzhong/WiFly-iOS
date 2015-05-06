//
//  FileTableViewCell.m
//  WiFly-iOS
//
//  Created by Sherlock Zhong on 5/4/15.
//  Copyright (c) 2015 SherlockZhong. All rights reserved.
//

#import "FileTableViewCell.h"

@implementation FileTableViewCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setViews:(NSString *)name size:(NSString *)size {
    [self setIcon:name];
    [self setName:name];
    [self setSize:size];
}

- (void)setIcon:(NSString *)name {
    if ([name hasSuffix:@".jpg"] ||
        [name hasSuffix:@".jpeg"] ||
        [name hasSuffix:@".png"] ||
        [name hasSuffix:@".bmp"] ||
        [name hasSuffix:@".gif"]) {
        self.iv_type.image = [UIImage imageNamed:@"file_image.png"];
    } else if ([name hasSuffix:@".mp3"] ||
               [name hasSuffix:@".wav"] ||
               [name hasSuffix:@".ogg"] ||
               [name hasSuffix:@".wav"] ||
               [name hasSuffix:@".acc"] ||
               [name hasSuffix:@".m4a"] ||
               [name hasSuffix:@".ape"] ||
               [name hasSuffix:@".flac"]) {
        self.iv_type.image = [UIImage imageNamed:@"file_audio.png"];
    } else if ([name hasSuffix:@".avi"] ||
               [name hasSuffix:@".mp4"] ||
               [name hasSuffix:@".wmv"] ||
               [name hasSuffix:@".mkv"] ||
               [name hasSuffix:@".rmvb"]) {
        self.iv_type.image = [UIImage imageNamed:@"file_video.png"];
    } else if ([name hasSuffix:@".doc"] ||
               [name hasSuffix:@".xls"] ||
               [name hasSuffix:@".ppt"] ||
               [name hasSuffix:@".docx"] ||
               [name hasSuffix:@".xlsx"] ||
               [name hasSuffix:@".pptx"] ||
               [name hasSuffix:@".key"] ||
               [name hasSuffix:@".pages"] ||
               [name hasSuffix:@".numbers"]) {
        self.iv_type.image = [UIImage imageNamed:@"file_document.png"];
    } else if ([name hasSuffix:@".zip"] ||
               [name hasSuffix:@".rar"] ||
               [name hasSuffix:@".tar"] ||
               
               [name hasSuffix:@".gz"] ||
               [name hasSuffix:@".7z"]) {
        self.iv_type.image = [UIImage imageNamed:@"file_archieve.png"];
    } else {
        self.iv_type.image = [UIImage imageNamed:@"file.png"];
    }
}

- (void)setName:(NSString *)name {
    self.lb_name.text = name;
}

- (void)setSize:(NSString *)size {
    NSInteger num = [size integerValue];
    NSString *unit;
    if (num < 1000000) {
        num = num / 10;
        unit = @"KB";
    } else if (num < 1000000000) {
        num = num / 10000;
        unit = @"MB";
    } else {
        num = num / 10000000;
        unit = @"GB";
    }
    NSInteger r = num % 100;
    NSString *remain = r < 10 ? [NSString stringWithFormat:@"0%ld", (long)r] : [NSString stringWithFormat:@"%ld", (long)r];
    self.lb_size.text = [NSString stringWithFormat:@"%ld.%@ %@", num / 100, remain, unit];
}

@end
