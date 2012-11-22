//
//  NetworkManager.m
//  MicroPDF
//
//  Created by Varun Mulloli on 16/11/12.
//  Copyright (c) 2012 Varun Mulloli. All rights reserved.
//

#import "NetworkManager.h"

@implementation NetworkManager

@synthesize networkOperationCount;

+ (NetworkManager *)sharedInstance
{
    static dispatch_once_t  onceToken;
    static NetworkManager * sSharedInstance;
    
    dispatch_once(&onceToken, ^{ sSharedInstance = [[NetworkManager alloc] init]; });
    return sSharedInstance;
}

- (NSURL *)smartURLForString:(NSString *)str
{
    NSURL *     result;
    NSString *  trimmedStr;
    NSRange     schemeMarkerRange;
    NSString *  scheme;
    
    assert(str != nil);
    
    result = nil;
    
    trimmedStr = [str stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    
    if ( (trimmedStr != nil) && (trimmedStr.length != 0) )
    {
        schemeMarkerRange = [trimmedStr rangeOfString:@"://"];
        
        if (schemeMarkerRange.location == NSNotFound)
        {
            result = [NSURL URLWithString:[NSString stringWithFormat:@"http://%@", trimmedStr]];
        }
        else
        {
            scheme = [trimmedStr substringWithRange:NSMakeRange(0, schemeMarkerRange.location)];
            assert(scheme != nil);
            
            if ( ([scheme compare:@"http"  options:NSCaseInsensitiveSearch] == NSOrderedSame)
                || ([scheme compare:@"https" options:NSCaseInsensitiveSearch] == NSOrderedSame) )
            {
                result = [NSURL URLWithString:trimmedStr];
            }
        }
    }
    
    return result;
}

- (void)didStartNetworkOperation
{
    // If you start a network operation off the main thread, you'll have to update this code
    // to ensure that any observers of this property are thread safe.
    assert([NSThread isMainThread]);
    networkOperationCount += 1;
}

- (void)didStopNetworkOperation
{
    // If you stop a network operation off the main thread, you'll have to update this code
    // to ensure that any observers of this property are thread safe.
    assert([NSThread isMainThread]);
    assert(networkOperationCount > 0);
    networkOperationCount -= 1;
}

@end
