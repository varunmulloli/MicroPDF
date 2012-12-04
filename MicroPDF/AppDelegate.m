//
//  AppDelegate.m
//  MicroPDF
//
//  Created by Varun Mulloli on 22/11/12.
//  Copyright (c) 2012 Varun Mulloli. All rights reserved.
//

#import "AppDelegate.h"

@implementation AppDelegate
{
    char _networkOperationCountDummy;
}

-(BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
{
    if (url != nil && [url isFileURL])
    {
        self.viewController = [[MasterViewController alloc] init];
        [self.viewController handleDocumentOpenURL:url];
    }
    return YES;
}

// Override point for customization after application launch.
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [[NetworkManager sharedInstance] addObserver:self forKeyPath:@"networkOperationCount" options:NSKeyValueObservingOptionInitial context:&self->_networkOperationCountDummy];
    return YES;
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if (context == &self->_networkOperationCountDummy) {
        [UIApplication sharedApplication].networkActivityIndicatorVisible = ([NetworkManager sharedInstance].networkOperationCount != 0);
    } else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

@end
