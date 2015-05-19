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

- (void) globalAlert:(NSInteger)style title:(NSString *)title content:(NSString *)content cancel:(NSString *)cancel confirm:(NSString *)confirm extra:(NSString *)extra {
    self.extra = extra;
    dispatch_async(dispatch_get_main_queue(), ^{
        UIAlertView *av = [[UIAlertView alloc] initWithTitle:title message:content delegate:self cancelButtonTitle:cancel otherButtonTitles:confirm, nil];
        av.alertViewStyle = style;
        [av show];
    });
}

-(void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 1) {
        UITextField *tf = [alertView textFieldAtIndex:0];
        ServerManager *sm = [ServerManager sharedInstance];
        [sm sendChat:self.extra content:tf.text];
    }
}

@end
