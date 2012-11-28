//
//  PDFScrollView.h
//  MicroPDF
//
//  Created by Varun Mulloli on 08/11/12.
//  Copyright (c) 2012 Varun Mulloli. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PDFScrollView : UIScrollView <UIScrollViewDelegate>
{
    CGPDFPageRef _PDFPage;
    UIImageView *PDFImageView;
}

- (void)showPDFPage:(CGPDFPageRef)PDFPage;

@end
