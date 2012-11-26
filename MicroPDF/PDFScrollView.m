//
//  PDFScrollView.m
//  MicroPDF
//
//  Created by Varun Mulloli on 08/11/12.
//  Copyright (c) 2012 Varun Mulloli. All rights reserved.
//

#import "PDFScrollView.h"

@implementation PDFScrollView

@synthesize backgroundImageView = _backgroundImageView;
@synthesize tiledPDFView = _tiledPDFView;

- (id)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self)
    {
        self.decelerationRate = UIScrollViewDecelerationRateFast;
        self.delegate = self;
        self.contentMode = UIViewContentModeScaleAspectFit;
    }
    return self;
}

- (UIImage *) getLowResolutionImage:(CGRect)pageRect
{
    UIGraphicsBeginImageContext(pageRect.size);
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    // First fill the background with white.
    CGContextSetRGBFillColor(context, 1.0,1.0,1.0,1.0);
    CGContextFillRect(context,pageRect);
    
    CGContextSaveGState(context);
    // Flip the context so that the PDF page is rendered right side up.
    CGContextTranslateCTM(context, 0.0, pageRect.size.height);
    CGContextScaleCTM(context, 1.0, -1.0);
    
    // Scale the context so that the PDF page is rendered at the correct size for the zoom level.
    CGContextScaleCTM(context, PDFScale,PDFScale);
    CGContextDrawPDFPage(context, _PDFPage);
    CGContextRestoreGState(context);
    
    UIImage *backgroundImage = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return backgroundImage;
}

- (void)showPDFPage:(CGPDFPageRef)PDFPage
{
    CGPDFPageRetain(PDFPage);
    CGPDFPageRelease(_PDFPage);
    _PDFPage = PDFPage;
    
    //NSLog(@"%f ::: %f", self.frame.size.width,self.frame.size.height);
    
    // Determine the size of the PDF page.
    CGRect pageRect = CGPDFPageGetBoxRect(_PDFPage, kCGPDFMediaBox);
    CGFloat widthScale = self.frame.size.width/pageRect.size.width;
    CGFloat heightScale = self.frame.size.height/pageRect.size.height;
    PDFScale = widthScale < heightScale ? widthScale : heightScale;
    pageRect.size = CGSizeMake(pageRect.size.width*PDFScale, pageRect.size.height*PDFScale);
    
    if (self.backgroundImageView != nil) {
        [self.backgroundImageView removeFromSuperview];
    }
    
    UIImage *backgroundImage = [self getLowResolutionImage:pageRect];
    
    UIImageView *backgroundImageView = [[UIImageView alloc] initWithImage:backgroundImage];
    backgroundImageView.frame = pageRect;
    backgroundImageView.contentMode = UIViewContentModeScaleAspectFit;
    [self addSubview:backgroundImageView];
    [self sendSubviewToBack:backgroundImageView];
    self.backgroundImageView = backgroundImageView;
    
    // Create the TiledPDFView based on the size of the PDF page and scale it to fit the view.
    TiledPDFView *tiledPDFView = [[TiledPDFView alloc] initWithFrame:pageRect scale:PDFScale];
    [tiledPDFView setPage:_PDFPage];
    [self addSubview:tiledPDFView];
    self.tiledPDFView = tiledPDFView;
    
    self.zoomScale = 1.0;
}

- (void)dealloc
{
    // Clean up.
    CGPDFPageRelease(_PDFPage);
}

#pragma mark - Override layoutSubviews to center content

// Use layoutSubviews to center the PDF page in the view.
- (void)layoutSubviews
{
    [super layoutSubviews];
    
    // Center the image as it becomes smaller than the size of the screen.
    
    CGSize boundsSize = self.bounds.size;
    CGRect frameToCenter = self.tiledPDFView.frame;
    
    // Center horizontally.
    
    if (frameToCenter.size.width < boundsSize.width)
        frameToCenter.origin.x = (boundsSize.width - frameToCenter.size.width) / 2;
    else
        frameToCenter.origin.x = 0;
    
    // Center vertically.
    
    if (frameToCenter.size.height < boundsSize.height)
        frameToCenter.origin.y = (boundsSize.height - frameToCenter.size.height) / 2;
    else
        frameToCenter.origin.y = 0;
    
    self.tiledPDFView.frame = frameToCenter;
    self.backgroundImageView.frame = frameToCenter;
    
    /*
     To handle the interaction between CATiledLayer and high resolution screens, set the tiling view's contentScaleFactor to 1.0.
     If this step were omitted, the content scale factor would be 2.0 on high resolution screens, which would cause the CATiledLayer to ask for tiles of the wrong scale.*/
     
    self.tiledPDFView.contentScaleFactor = 1.0;
}

#pragma mark - UIScrollView delegate methods

/*
 A UIScrollView delegate callback, called when the user starts zooming.
 Return the current TiledPDFView.
 */
- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return self.tiledPDFView;
}

@end