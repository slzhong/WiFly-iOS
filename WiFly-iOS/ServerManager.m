//
//  ServerManager.m
//  WiFly-iOS
//
//  Created by Sherlock Zhong on 4/19/15.
//  Copyright (c) 2015 SherlockZhong. All rights reserved.
//

#import "ServerManager.h"

static ServerManager *serverManager = nil;

@implementation ServerManager

+ (ServerManager *)sharedInstance {
    if (serverManager == nil) {
        serverManager = [[ServerManager alloc] init];
    }
    return serverManager;
}

- (void)start {
    self.server = [[GCDWebServer alloc] init];
    [self initRoutes];
    [self.server startWithPort:12580 bonjourName:nil];
}

- (void)initRoutes {
    [self.server addHandlerForMethod:@"GET" path:@"/id" requestClass:[GCDWebServerRequest class] processBlock:^GCDWebServerResponse *(GCDWebServerRequest* request) {
        ServerManager *sm = [ServerManager sharedInstance];
        NSMutableDictionary *info = [NSMutableDictionary dictionary];
        [info setValue:sm.name forKey:@"name"];
        [info setValue:sm.url forKey:@"url"];
        [info setValue:@"ios" forKey:@"type"];
        return [GCDWebServerDataResponse responseWithJSONObject:info];
    }];
    
    [self.server addHandlerForMethod:@"GET" path:@"/chat" requestClass:[GCDWebServerRequest class] processBlock:^GCDWebServerResponse *(GCDWebServerRequest* request) {
        ViewManager *vm = [ViewManager sharedInstance];
        [vm globalAlert:UIAlertViewStylePlainTextInput title:[request.query valueForKey:@"from"] content:[request.query valueForKey:@"content"] cancel:@"Cancel" confirm:@"Reply" extra:[request.query valueForKey:@"url"]];
        
        NSMutableDictionary *info = [NSMutableDictionary dictionary];
        [info setValue:@"200" forKey:@"status"];
        [info setValue:@"ok" forKey:@"message"];
        return [GCDWebServerDataResponse responseWithJSONObject:info];
    }];
}

- (void)setInfo:(NSString *)n url:(NSString *)u {
    self.name = n;
    self.url = u;
}

- (void)startTransmitter {
    NSString *documentsPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
    self.transmitter = [[GCDWebUploader alloc] initWithUploadDirectory:documentsPath];
    self.transmitter.delegate = self;
    [self.transmitter start];
    NSLog(@"%@", self.transmitter.serverURL);
}

- (void)sendChat:(NSString *)url content:(NSString *)content {
    NSMutableDictionary *data = [NSMutableDictionary dictionary];
    [data setValue:self.name forKey:@"from"];
    [data setValue:content forKey:@"content"];
    [data setValue:[NSString stringWithFormat:@"%@chat", self.url] forKey:@"url"];
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    manager.requestSerializer=[AFJSONRequestSerializer serializer];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"application/json"];
    [manager GET:url parameters:data success:nil failure:nil];
}

#pragma mark - GCD Web Uploader Delegate
- (void)webUploader:(GCDWebUploader *)uploader didUploadFileAtPath:(NSString *)path {
    ViewManager *vm = [ViewManager sharedInstance];
    if (vm.filesViewController != nil) {
        [vm.filesViewController updateFiles];
    }
}

#pragma mark - Alert View Delegate
- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    
}

@end
