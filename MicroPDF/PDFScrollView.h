//
//  PDFScrollView.h
//  MicroPDF
//
//  Created by Varun Mulloli on 08/11/12.
//  Copyright (c) 2012 Varun Mulloli. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

#import "TiledPDFView.h"

@interface PDFScrollView : UIScrollView <UIScrollViewDelegate>
{
    CGFloat PDFScale;
    
    CGPDFPageRef _PDFPage;
}

// A low resolution image of the PDF page that is displayed until the TiledPDFView renders its content.
@property (nonatomic, weak) UIImageView *backgroundImageView;

// The TiledPDFView that is currently front most.
@property (nonatomic, weak) TiledPDFView *tiledPDFView;

- (void)showPDFPage:(CGPDFPageRef)PDFPage;

@end
