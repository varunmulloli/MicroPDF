//
//  DetailViewController.h
//  MicroPDF
//
//  Created by Varun Mulloli on 10/11/12.
//  Copyright (c) 2012 Varun Mulloli. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "PDFViewController.h"

@interface PDFPageViewController : UIViewController
<UIPageViewControllerDelegate, UIPageViewControllerDataSource>
{
    NSURL *pdfURL;
    long totalPages, currentPage;
    
    PDFViewController *page;
}

@property (strong, nonatomic) NSString *bookName;

@property (strong, nonatomic) UIPageViewController *pageViewController;

@property (strong, nonatomic) IBOutlet UIBarButtonItem *pageNumber;

- (IBAction) prevPageButton;
- (IBAction) nextPageButton;

- (void)configureView;

@end
