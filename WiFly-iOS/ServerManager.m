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
//    NSString *path = [[NSBundle mainBundle] pathForResource:@"index" ofType:@"html"];
//    [self.server addGETHandlerForBasePath:@"/" directoryPath:[path substringToIndex:[path rangeOfString:@"index.html"].location] indexFilename:@"index.html" cacheAge:3600 allowRangeRequests:NO];
    
    [self.server addHandlerForMethod:@"GET" path:@"/id" requestClass:[GCDWebServerRequest class] processBlock:^GCDWebServerResponse *(GCDWebServerRequest* request) {
        ServerManager *sm = [ServerManager sharedInstance];
        NSMutableDictionary *info = [NSMutableDictionary dictionary];
        [info setValue:sm.name forKey:@"name"];
        [info setValue:sm.url forKey:@"url"];
        [info setValue:@"ios" forKey:@"type"];
        return [GCDWebServerDataResponse responseWithJSONObject:info];
    }];
}

- (void)setInfo:(NSString *)n url:(NSString *)u {
    self.name = n;
    self.url = u;
}

- (void)startTransmitter {
    NSString* documentsPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
    self.transmitter = [[GCDWebUploader alloc] initWithUploadDirectory:documentsPath];
    [self.transmitter start];
    NSLog(@"%@", self.transmitter.serverURL);
}

@end
