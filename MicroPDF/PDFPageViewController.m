//
//  DetailViewController.m
//  MicroPDF
//
//  Created by Varun Mulloli on 10/11/12.
//  Copyright (c) 2012 Varun Mulloli. All rights reserved.
//

#import "PDFPageViewController.h"

@implementation PDFPageViewController

@synthesize pageNumber;
@synthesize bookName;

- (void)configureView
{
    // Update the user interface for the detail item.
        
        self.title = bookName;

        NSArray *pathArray = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);

        NSString *filePath= [[NSBundle bundleWithPath:[pathArray objectAtIndex:0]] pathForResource:bookName ofType:@"pdf"];
        
        pdfURL = [[NSURL alloc] initFileURLWithPath:filePath];
        CGPDFDocumentRef PDFDocument = CGPDFDocumentCreateWithURL((__bridge CFURLRef)pdfURL);
        totalPages = CGPDFDocumentGetNumberOfPages(PDFDocument);
        CGPDFDocumentRelease(PDFDocument);
        
        currentPage = 1;
        
        pageNumber.title = [[NSString alloc] initWithFormat:@"%ld/%ld",currentPage,totalPages];

        self.pageViewController = [[UIPageViewController alloc] initWithTransitionStyle:UIPageViewControllerTransitionStylePageCurl navigationOrientation:UIPageViewControllerNavigationOrientationHorizontal options:nil];
        self.pageViewController.delegate = self;
        self.pageViewController.dataSource = self;
        
        PDFViewController *startingPage = [self.storyboard instantiateViewControllerWithIdentifier:@"PDF"];
        startingPage.pdfURL = pdfURL;
        startingPage.pageNo = currentPage;

        [self.pageViewController setViewControllers:@[startingPage] direction:UIPageViewControllerNavigationDirectionForward animated:NO completion:NULL];
        
        [self addChildViewController:self.pageViewController];
        [self.view addSubview:self.pageViewController.view];
        
        CGRect pageViewRect = self.view.bounds;
        self.pageViewController.view.frame = pageViewRect;
}

- (IBAction) prevPageButton
{
    if(currentPage > 1)
    {
        currentPage -= 1;
        pageNumber.title = [[NSString alloc] initWithFormat:@"%ld/%ld",currentPage,totalPages];
        
        PDFViewController *startingPage = [self.storyboard instantiateViewControllerWithIdentifier:@"PDF"];
        startingPage.pdfURL = pdfURL;
        startingPage.pageNo = currentPage;
        
        [self.pageViewController setViewControllers:@[startingPage] direction:UIPageViewControllerNavigationDirectionReverse animated:YES completion:NULL];
    }
}

- (IBAction) nextPageButton
{
    if(currentPage != totalPages)
    {
        currentPage += 1;
        pageNumber.title = [[NSString alloc] initWithFormat:@"%ld/%ld",currentPage,totalPages];
        
        PDFViewController *startingPage = [self.storyboard instantiateViewControllerWithIdentifier:@"PDF"];
        startingPage.pdfURL = pdfURL;
        startingPage.pageNo = currentPage;
        
        [self.pageViewController setViewControllers:@[startingPage] direction:UIPageViewControllerNavigationDirectionForward animated:YES completion:NULL];
    }
}

#pragma mark - Page View Controller Data Source

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController
{
    if (currentPage == 1)
        return nil;
    else
        currentPage -= 1;
    
    pageNumber.title = [[NSString alloc] initWithFormat:@"%ld/%ld",currentPage,totalPages];
    
    PDFViewController *previuosPage = [self.storyboard instantiateViewControllerWithIdentifier:@"PDF"];
    previuosPage.pdfURL = pdfURL;
    previuosPage.pageNo = currentPage;
    
    return previuosPage;
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController
{
    if (currentPage == totalPages)
        return nil;
    else
        currentPage += 1;
    
    pageNumber.title = [[NSString alloc] initWithFormat:@"%ld/%ld",currentPage,totalPages];
    
    PDFViewController *nextPage = [self.storyboard instantiateViewControllerWithIdentifier:@"PDF"];
    nextPage.pdfURL = pdfURL;
    nextPage.pageNo = currentPage;
    
    return nextPage;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    [self configureView];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    [self.pageViewController.view removeFromSuperview];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

@end
