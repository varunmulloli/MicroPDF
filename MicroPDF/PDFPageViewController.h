//
//  ViewController.h
//  PDFScroll
//
//  Created by Varun Mulloli on 23/11/12.
//  Copyright (c) 2012 Varun Mulloli. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

@interface PDFPageViewController : UIViewController <UIScrollViewDelegate>
{
    NSMutableArray *loadedViewControllers, *loadedPages;
	NSUInteger currentPage, numberOfPages;
    CGRect scrollViewFrame;
    
}

@property (strong, nonatomic) IBOutlet UIScrollView *scrollView;
@property (strong, nonatomic) NSString *bookName;

@end
