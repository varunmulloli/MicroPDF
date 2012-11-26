//
//  ViewController.m
//  PDFScroll
//
//  Created by Varun Mulloli on 23/11/12.
//  Copyright (c) 2012 Varun Mulloli. All rights reserved.
//

#import "PDFPageViewController.h"
#import "PDFViewController.h"
#import "PDFScrollView.h"

@implementation PDFPageViewController
@synthesize bookName;

@synthesize scrollView;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.navigationController.navigationBar setTranslucent:YES];
    [self.navigationController.toolbar setTranslucent:YES];
    
    UITapGestureRecognizer* tap =[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showHideToolBars:)];
    tap.numberOfTapsRequired = 1;
    [scrollView addGestureRecognizer:tap];
    
    loadedViewControllers = [[NSMutableArray alloc] init];
    loadedPages = [[NSMutableArray alloc] init];
    scrollView.delegate = self;
    
    NSArray *pathArray = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,
                                                             NSUserDomainMask, YES);
    NSString *path = [[NSBundle bundleWithPath:[pathArray objectAtIndex:0]] pathForResource:[bookName stringByDeletingPathExtension] ofType:@"pdf"];
    CGPDFDocumentRef PDFDocument = CGPDFDocumentCreateWithURL((__bridge CFURLRef)[NSURL fileURLWithPath:path]);
    numberOfPages = CGPDFDocumentGetNumberOfPages(PDFDocument);
    CGPDFDocumentRelease(PDFDocument);
	
    self.title = bookName;
    
    currentPage = 0;
	[self alignSubviews];
    
    scrollViewFrame = scrollView.frame;
    
    [self loadViewWithPage:0];
    [self loadViewWithPage:1];
}

- (void) showHideToolBars:(id)sender
{
    if ([self.navigationController isNavigationBarHidden])
    {
        [self.navigationController setNavigationBarHidden:NO animated:YES];
        [self.navigationController setToolbarHidden:NO animated:YES];
    }
    else
    {
        [self.navigationController setNavigationBarHidden:YES animated:YES];
        [self.navigationController setToolbarHidden:YES animated:YES];
    }
}

- (void)alignSubviews
{
	scrollView.contentSize = CGSizeMake(numberOfPages*scrollView.bounds.size.width,
										scrollView.bounds.size.height);
	NSUInteger i = currentPage == 0 ? currentPage : currentPage - 1;
	for (PDFViewController *viewController in loadedViewControllers)
    {
		viewController.view.frame = CGRectMake(i * scrollView.bounds.size.width, 0,
							 scrollView.bounds.size.width, scrollView.bounds.size.height);
		i++;
	}
}

- (void) loadViewWithPage:(int)page
{    
    if (page < 0 || page >= numberOfPages)
        return;
    
    if (![loadedPages containsObject:[NSNumber numberWithInt:page]])
    {
        PDFViewController *viewController = [self.storyboard instantiateViewControllerWithIdentifier:@"PDF"];
        viewController.pageNo = page+1;
        viewController.bookName = [bookName stringByDeletingPathExtension];
        CGRect frame = scrollViewFrame;
        frame.size.width -= 20;
        frame.size.height -= 20;
        viewController.pageRect = frame;
        
        [scrollView addSubview:viewController.view];
        
        if ((loadedPages.count != 0) && (page < [[loadedPages objectAtIndex:0] integerValue]))
        {
            [loadedPages insertObject:[NSNumber numberWithInt:page] atIndex:0];
            [loadedViewControllers insertObject:viewController atIndex:0];
        }
        else
        {
            [loadedPages addObject:[NSNumber numberWithInt:page]];
            [loadedViewControllers addObject:viewController];
        }
        viewController = nil;
    }
    
    NSInteger location = [loadedPages indexOfObject:[NSNumber numberWithInt:page]];
    PDFViewController *viewController = [loadedViewControllers objectAtIndex:location];
    CGRect frame = scrollView.bounds;
    frame.origin.x = scrollView.bounds.size.width*page;
    viewController.view.frame = frame;
    [(PDFScrollView *)viewController.view setZoomScale:1.0];
    [loadedViewControllers replaceObjectAtIndex:location withObject:viewController];
    viewController = nil;
}

- (void) releaseViewWithPage:(int)page
{
    if (page < 0 || page >= numberOfPages)
        return;
    if ([loadedPages containsObject:[NSNumber numberWithInt:page]])
    {
        NSInteger location = [loadedPages indexOfObject:[NSNumber numberWithInt:page]];
        PDFViewController *viewController = [loadedViewControllers objectAtIndex:location];
        [viewController.view removeFromSuperview];
        [loadedViewControllers removeObjectAtIndex:location];
        [loadedPages removeObjectAtIndex:location];
        viewController = nil;
    }
}

- (void) scrollViewDidEndDecelerating:(UIScrollView *)scroll
{
    int page = scrollView.contentOffset.x / scrollView.bounds.size.width;
    
    [self loadViewWithPage:page];
    [self loadViewWithPage:page+1];
    [self loadViewWithPage:page-1];
    
    [self releaseViewWithPage:page-2];
    [self releaseViewWithPage:page+2];
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
								duration:(NSTimeInterval)duration
{
	currentPage = scrollView.contentOffset.x / scrollView.bounds.size.width;
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
										 duration:(NSTimeInterval)duration
{
	[self alignSubviews];
	scrollView.contentOffset = CGPointMake(currentPage * scrollView.bounds.size.width, 0);
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

@end
