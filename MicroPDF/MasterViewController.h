//
//  MasterViewController.h
//  MicroPDF
//
//  Created by Varun Mulloli on 10/11/12.
//  Copyright (c) 2012 Varun Mulloli. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "PDFViewController.h"
#import "NetworkManager.h"

@interface MasterViewController : UITableViewController
<UISearchDisplayDelegate, UISearchBarDelegate, UITextFieldDelegate>
{
    NSMutableArray *listContent;
    NSMutableArray *filteredListContent;
    
    UIProgressView *progressBar;
    UIBarButtonItem *cancelButton;
    NSArray *toolbarItems;
    
    NSURL *url;
    
    long long currentDownloadSize;
    long long totalDownloadSize;
    
    BOOL isDownloading;
}

@property (nonatomic, strong, readwrite) NSURLConnection *connection;
@property (nonatomic, copy, readwrite) NSString *filePath;
@property (nonatomic, strong, readwrite) NSOutputStream *fileStream;

@end
