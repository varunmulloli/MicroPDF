//
//	ReaderViewController.m
//	Reader v2.6.0
//
//	Created by Julius Oklamcak on 2011-07-01.
//	Copyright © 2011-2012 Julius Oklamcak. All rights reserved.
//
//	Permission is hereby granted, free of charge, to any person obtaining a copy
//	of this software and associated documentation files (the "Software"), to deal
//	in the Software without restriction, including without limitation the rights to
//	use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies
//	of the Software, and to permit persons to whom the Software is furnished to
//	do so, subject to the following conditions:
//
//	The above copyright notice and this permission notice shall be included in all
//	copies or substantial portions of the Software.
//
//	THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
//	OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//	FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//	AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
//	WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
//	CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
//

#import "ReaderViewController.h"
#import "ThumbsViewController.h"
#import "ReaderContentView.h"
#import "ReaderThumbCache.h"
#import "ReaderThumbQueue.h"

@interface ReaderViewController () <UIScrollViewDelegate, UIGestureRecognizerDelegate,ThumbsViewControllerDelegate>
@end

@implementation ReaderViewController
{
	ReaderDocument *document;
    
	UIScrollView *theScrollView;
    
	NSMutableDictionary *contentViews;
    
	NSInteger currentPage;
    
	CGSize lastAppearSize;
    
	NSDate *lastHideTime;
    
	BOOL isVisible;
}

#pragma mark Constants

#define PAGING_VIEWS 3

#define TAP_AREA_SIZE 48.0f

#pragma mark Support methods

- (void)updateScrollViewContentSize
{
	NSInteger count = [document.pageCount integerValue];
    
	if (count > PAGING_VIEWS) count = PAGING_VIEWS; // Limit
    
	CGFloat contentHeight = theScrollView.bounds.size.height;
    
	CGFloat contentWidth = (theScrollView.bounds.size.width * count);
    
	theScrollView.contentSize = CGSizeMake(contentWidth, contentHeight);
}

- (void)updateScrollViewContentViews
{
	[self updateScrollViewContentSize]; // Update the content size
    
	NSMutableIndexSet *pageSet = [NSMutableIndexSet indexSet]; // Page set
    
	[contentViews enumerateKeysAndObjectsUsingBlock: // Enumerate content views
     ^(id key, id object, BOOL *stop)
     {
         ReaderContentView *contentView = object; [pageSet addIndex:contentView.tag];
     }
     ];
    
	__block CGRect viewRect = CGRectZero; viewRect.size = theScrollView.bounds.size;
    
	__block CGPoint contentOffset = CGPointZero; NSInteger page = [document.pageNumber integerValue];
    
	[pageSet enumerateIndexesUsingBlock: // Enumerate page number set
     ^(NSUInteger number, BOOL *stop)
     {
         NSNumber *key = [NSNumber numberWithInteger:number]; // # key
         
         ReaderContentView *contentView = [contentViews objectForKey:key];
         
         contentView.frame = viewRect; if (page == number) contentOffset = viewRect.origin;
         
         viewRect.origin.x += viewRect.size.width; // Next view frame position
     }
     ];
    
	if (CGPointEqualToPoint(theScrollView.contentOffset, contentOffset) == false)
	{
		theScrollView.contentOffset = contentOffset; // Update content offset
	}
}

- (void)showDocumentPage:(NSInteger)page
{
	if (page != currentPage) // Only if different
	{
		NSInteger minValue; NSInteger maxValue;
		NSInteger maxPage = [document.pageCount integerValue];
		NSInteger minPage = 1;
        
		if ((page < minPage) || (page > maxPage)) return;
        
		if (maxPage <= PAGING_VIEWS) // Few pages
		{
			minValue = minPage;
			maxValue = maxPage;
		}
		else // Handle more pages
		{
			minValue = (page - 1);
			maxValue = (page + 1);
            
			if (minValue < minPage)
            {minValue++; maxValue++;}
			else
				if (maxValue > maxPage)
                {minValue--; maxValue--;}
		}
        
		NSMutableIndexSet *newPageSet = [NSMutableIndexSet new];
        
		NSMutableDictionary *unusedViews = [contentViews mutableCopy];
        
		CGRect viewRect = CGRectZero; viewRect.size = theScrollView.bounds.size;
        
		for (NSInteger number = minValue; number <= maxValue; number++)
		{
			NSNumber *key = [NSNumber numberWithInteger:number]; // # key
            
			ReaderContentView *contentView = [contentViews objectForKey:key];
            
			if (contentView == nil) // Create a brand new document content view
			{
				NSURL *fileURL = document.fileURL; NSString *phrase = document.password; // Document properties
                
				contentView = [[ReaderContentView alloc] initWithFrame:viewRect fileURL:fileURL page:number password:phrase];
                
				[theScrollView addSubview:contentView]; [contentViews setObject:contentView forKey:key];
                
				[newPageSet addIndex:number];
			}
			else // Reposition the existing content view
			{
				contentView.frame = viewRect; [contentView zoomReset];
                
				[unusedViews removeObjectForKey:key];
			}
            
			viewRect.origin.x += viewRect.size.width;
		}
        
		[unusedViews enumerateKeysAndObjectsUsingBlock: // Remove unused views
         ^(id key, id object, BOOL *stop)
         {
             [contentViews removeObjectForKey:key];
             
             ReaderContentView *contentView = object;
             
             [contentView removeFromSuperview];
         }
         ];
        
		unusedViews = nil; // Release unused views
        
		CGFloat viewWidthX1 = viewRect.size.width;
		CGFloat viewWidthX2 = (viewWidthX1 * 2.0f);
        
		CGPoint contentOffset = CGPointZero;
        
		if (maxPage >= PAGING_VIEWS)
		{
			if (page == maxPage)
				contentOffset.x = viewWidthX2;
			else
				if (page != minPage)
					contentOffset.x = viewWidthX1;
		}
		else
			if (page == (PAGING_VIEWS - 1))
				contentOffset.x = viewWidthX1;
        
		if (CGPointEqualToPoint(theScrollView.contentOffset, contentOffset) == false)
		{
			theScrollView.contentOffset = contentOffset; // Update content offset
		}
        
		if ([document.pageNumber integerValue] != page) // Only if different
		{
			document.pageNumber = [NSNumber numberWithInteger:page]; // Update page number
		}
        
		NSURL *fileURL = document.fileURL; NSString *phrase = document.password; NSString *guid = document.guid;
        
		if ([newPageSet containsIndex:page] == YES) // Preview visible page first
		{
			NSNumber *key = [NSNumber numberWithInteger:page]; // # key
            
			ReaderContentView *targetView = [contentViews objectForKey:key];
            
			[targetView showPageThumb:fileURL page:page password:phrase guid:guid];
            
			[newPageSet removeIndex:page]; // Remove visible page from set
		}
        
		[newPageSet enumerateIndexesWithOptions:NSEnumerationReverse usingBlock: // Show previews
         ^(NSUInteger number, BOOL *stop)
         {
             NSNumber *key = [NSNumber numberWithInteger:number]; // # key
             
             ReaderContentView *targetView = [contentViews objectForKey:key];
             
             [targetView showPageThumb:fileURL page:number password:phrase guid:guid];
         }
         ];
        
		newPageSet = nil; // Release new page set
        
		currentPage = page; // Track current page number
	}
}

- (void)showDocument
{
	[self updateScrollViewContentSize]; // Set content size
    
	[self showDocumentPage:[document.pageNumber integerValue]];
    
	document.lastOpen = [NSDate date]; // Update last opened date
    
	isVisible = YES; // iOS present modal bodge
}

#pragma mark UIViewController methods

- (id)initWithReaderDocument:(ReaderDocument *)object
{
	id reader = nil; // ReaderViewController object
    
	if ((object != nil) && ([object isKindOfClass:[ReaderDocument class]]))
	{
		if ((self = [super initWithNibName:nil bundle:nil])) // Designated initializer
		{
			NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
            
			[notificationCenter addObserver:self selector:@selector(applicationWill:) name:UIApplicationWillTerminateNotification object:nil];
            
			[notificationCenter addObserver:self selector:@selector(applicationWill:) name:UIApplicationWillResignActiveNotification object:nil];
            
			[object updateProperties]; document = object; // Retain the supplied ReaderDocument object for our use
            
			[ReaderThumbCache touchThumbCacheWithGUID:object.guid]; // Touch the document thumb cache directory
            
			reader = self; // Return an initialized ReaderViewController object
		}
	}
    
	return reader;
}

- (void)viewDidLoad
{
	[super viewDidLoad];
    
	assert(document != nil); // Must have a valid ReaderDocument
    
	self.view.backgroundColor = [UIColor scrollViewTexturedBackgroundColor];
    
	CGRect viewRect = self.view.bounds; // View controller's view bounds
    
	theScrollView = [[UIScrollView alloc] initWithFrame:viewRect]; // All
    
	theScrollView.scrollsToTop = NO;
	theScrollView.pagingEnabled = YES;
	theScrollView.delaysContentTouches = NO;
	theScrollView.showsVerticalScrollIndicator = NO;
	theScrollView.showsHorizontalScrollIndicator = NO;
	theScrollView.contentMode = UIViewContentModeRedraw;
	theScrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
	theScrollView.backgroundColor = [UIColor clearColor];
	theScrollView.userInteractionEnabled = YES;
	theScrollView.autoresizesSubviews = NO;
	theScrollView.delegate = self;
    
	[self.view addSubview:theScrollView];
    
	UITapGestureRecognizer *singleTapOne = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSingleTap:)];
	singleTapOne.numberOfTouchesRequired = 1; singleTapOne.numberOfTapsRequired = 1; singleTapOne.delegate = self;
	[self.view addGestureRecognizer:singleTapOne];
    
	contentViews = [NSMutableDictionary new]; lastHideTime = [NSDate date];
}

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
    
	if (CGSizeEqualToSize(lastAppearSize, CGSizeZero) == false)
	{
		if (CGSizeEqualToSize(lastAppearSize, self.view.bounds.size) == false)
		{
			[self updateScrollViewContentViews]; // Update content views
		}
        
		lastAppearSize = CGSizeZero; // Reset view size tracking
	}
}

- (void)viewDidAppear:(BOOL)animated
{
	[super viewDidAppear:animated];
    
	if (CGSizeEqualToSize(theScrollView.contentSize, CGSizeZero)) // First time
	{
		[self showDocument];
	}
}

- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
    
	lastAppearSize = self.view.bounds.size; // Track view size
}

- (void)viewDidUnload
{
	theScrollView = nil; contentViews = nil; lastHideTime = nil;
    
	lastAppearSize = CGSizeZero; currentPage = 0;
    
	[super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return YES;
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
	if (isVisible == NO) return; // iOS present modal bodge
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation duration:(NSTimeInterval)duration
{
	if (isVisible == NO) return; // iOS present modal bodge
    
	[self updateScrollViewContentViews]; // Update content views
    
	lastAppearSize = CGSizeZero; // Reset view size tracking
}

- (void)dealloc
{
	[[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark UIScrollViewDelegate methods

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
	__block NSInteger page = 0;
    
	CGFloat contentOffsetX = scrollView.contentOffset.x;
    
	[contentViews enumerateKeysAndObjectsUsingBlock: // Enumerate content views
     ^(id key, id object, BOOL *stop)
     {
         ReaderContentView *contentView = object;
         
         if (contentView.frame.origin.x == contentOffsetX)
         {
             page = contentView.tag; *stop = YES;
         }
     }
     ];
    
	if (page != 0) [self showDocumentPage:page]; // Show the page
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView
{
	[self showDocumentPage:theScrollView.tag]; // Show page
    
	theScrollView.tag = 0; // Clear page number tag
}

#pragma mark UIGestureRecognizerDelegate methods

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)recognizer shouldReceiveTouch:(UITouch *)touch
{
	if ([touch.view isKindOfClass:[UIScrollView class]]) return YES;
    
	return NO;
}

- (void)handleSingleTap:(UITapGestureRecognizer *)recognizer
{
	if (recognizer.state == UIGestureRecognizerStateRecognized)
	{
		CGRect viewRect = recognizer.view.bounds; // View bounds
        
		CGPoint point = [recognizer locationInView:recognizer.view];
        
		CGRect areaRect = CGRectInset(viewRect, TAP_AREA_SIZE, 0.0f); // Area
        
		if (CGRectContainsPoint(areaRect, point)) // Single tap is inside the area
		{
			NSInteger page = [document.pageNumber integerValue]; // Current page #
            
			NSNumber *key = [NSNumber numberWithInteger:page]; // Page number key
            
			ReaderContentView *targetView = [contentViews objectForKey:key];
            
			id target = [targetView processSingleTap:recognizer]; // Target
            
			if (target != nil) // Handle the returned target object
			{
				if ([target isKindOfClass:[NSURL class]]) // Open a URL
				{
					NSURL *url = (NSURL *)target; // Cast to a NSURL object
                    
					if (url.scheme == nil) // Handle a missing URL scheme
					{
						NSString *www = url.absoluteString; // Get URL string
                        
						if ([www hasPrefix:@"www"] == YES) // Check for 'www' prefix
						{
							NSString *http = [NSString stringWithFormat:@"http://%@", www];
                            
							url = [NSURL URLWithString:http]; // Proper http-based URL
						}
					}
                    
					if ([[UIApplication sharedApplication] openURL:url] == NO)
					{
#ifdef DEBUG
                        NSLog(@"%s '%@'", __FUNCTION__, url); // Bad or unknown URL
#endif
					}
				}
				else // Not a URL, so check for other possible object type
				{
					if ([target isKindOfClass:[NSNumber class]]) // Goto page
					{
						NSInteger value = [target integerValue]; // Number
                        
						[self showDocumentPage:value]; // Show the page
					}
				}
			}
            
			return;
		}
	}
}

#pragma mark ThumbsViewControllerDelegate methods

- (void)thumbsViewController:(ThumbsViewController *)viewController gotoPage:(NSInteger)page
{
	[self showDocumentPage:page]; // Show the page
}

#pragma mark UIApplication notification methods

- (void)applicationWill:(NSNotification *)notification
{
	[document saveReaderDocument]; // Save any ReaderDocument object changes
}

@end
