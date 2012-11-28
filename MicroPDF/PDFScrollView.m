//
//  PDFScrollView.m
//  MicroPDF
//
//  Created by Varun Mulloli on 08/11/12.
//  Copyright (c) 2012 Varun Mulloli. All rights reserved.
//

#import "PDFScrollView.h"

@implementation PDFScrollView

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

- (void)showPDFPage:(CGPDFPageRef)PDFPage
{
    CGPDFPageRetain(PDFPage);
    CGPDFPageRelease(_PDFPage);
    _PDFPage = PDFPage;
    
    // Determine the size of the PDF page.
    CGRect pageRect = CGPDFPageGetBoxRect(_PDFPage, kCGPDFMediaBox);
    
    UIGraphicsBeginImageContext(pageRect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    // First fill the background with white.
    CGContextSetRGBFillColor(context, 1.0,1.0,1.0,1.0);
    CGContextFillRect(context,pageRect);
    CGContextSaveGState(context);
    // Flip the context so that the PDF page is rendered right side up.
    CGContextTranslateCTM(context, 0.0, pageRect.size.height);
    CGContextScaleCTM(context, 1.0, -1.0);
    CGContextDrawPDFPage(context, _PDFPage);
    CGContextRestoreGState(context);
    UIImage *PDFImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();

    CGFloat PDFScale = MIN(self.frame.size.width/pageRect.size.width, self.frame.size.height/pageRect.size.height);
    pageRect.size = CGSizeMake(pageRect.size.width*PDFScale, pageRect.size.height*PDFScale);
    
    PDFImageView = [[UIImageView alloc] initWithImage:PDFImage];
    PDFImageView.frame = pageRect;
    PDFImageView.contentMode = UIViewContentModeScaleAspectFit;
    [self addSubview:PDFImageView];
    
    self.zoomScale = 1.0;
}

- (void)dealloc
{
    CGPDFPageRelease(_PDFPage);
}

#pragma mark - Override layoutSubviews to center content

// Use layoutSubviews to center the PDF page in the view.
- (void)layoutSubviews
{
    [super layoutSubviews];
    
    // Center the image as it becomes smaller than the size of the screen.
    CGSize boundsSize = self.bounds.size;
    CGRect frameToCenter = PDFImageView.frame;
    
    // Center horizontally
    if (frameToCenter.size.width < boundsSize.width)
        frameToCenter.origin.x = (boundsSize.width - frameToCenter.size.width) / 2;
    else
        frameToCenter.origin.x = 0;
    
    // Center vertically
    if (frameToCenter.size.height < boundsSize.height)
        frameToCenter.origin.y = (boundsSize.height - frameToCenter.size.height) / 2;
    else
        frameToCenter.origin.y = 0;

    PDFImageView.frame = frameToCenter;
}

#pragma mark - UIScrollView delegate methods

//A UIScrollView delegate callback, called when the user starts zooming.
- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return PDFImageView;
}

@end