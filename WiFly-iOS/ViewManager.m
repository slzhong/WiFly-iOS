//
//  ViewManager.m
//  WiFly-iOS
//
//  Created by Sherlock Zhong on 5/6/15.
//  Copyright (c) 2015 SherlockZhong. All rights reserved.
//

#import "ViewManager.h"

static ViewManager *viewManager;

@implementation ViewManager

+(ViewManager *)sharedInstance {
    if (viewManager == nil) {
        viewManager = [[ViewManager alloc] init];
    }
    return viewManager;
}

@end
