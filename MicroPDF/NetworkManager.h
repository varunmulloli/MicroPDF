//
//  NetworkManager.h
//  MicroPDF
//
//  Created by Varun Mulloli on 16/11/12.
//  Copyright (c) 2012 Varun Mulloli. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NetworkManager : NSObject

+ (NetworkManager *)sharedInstance;

- (NSURL *)smartURLForString:(NSString *)str;

@property (nonatomic, assign, readonly) NSUInteger networkOperationCount;  // observable

- (void)didStartNetworkOperation;
- (void)didStopNetworkOperation;

@end
