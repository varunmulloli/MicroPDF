//
//  AppDelegate.h
//  MicroPDF
//
//  Created by Varun Mulloli on 22/11/12.
//  Copyright (c) 2012 Varun Mulloli. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NetworkManager.h"
#import "MasterViewController.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) MasterViewController *viewController;

@end
