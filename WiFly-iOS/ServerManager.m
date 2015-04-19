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
    [self.server addDefaultHandlerForMethod:@"GET" requestClass:[GCDWebServerRequest class] processBlock:^GCDWebServerResponse *(GCDWebServerRequest* request) {
        return [GCDWebServerDataResponse responseWithHTML:@"<html><body><p>Hello World</p></body></html>"];
    }];
    
    [self.server addHandlerForMethod:@"GET" path:@"/id" requestClass:[GCDWebServerRequest class] processBlock:^GCDWebServerResponse *(GCDWebServerRequest* request) {
        ServerManager *sm = [ServerManager sharedInstance];
        NSMutableDictionary *info = [NSMutableDictionary dictionary];
        [info setValue:sm.name forKey:@"name"];
        [info setValue:sm.url forKey:@"url"];
        return [GCDWebServerDataResponse responseWithJSONObject:info];
    }];
}

- (void)setInfo:(NSString *)n url:(NSString *)u {
    self.name = n;
    self.url = u;
}

@end
