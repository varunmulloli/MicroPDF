//
//  ViewController.m
//  MicroPDF
//
//  Created by Varun Mulloli on 02/11/12.
//  Copyright (c) 2012 Varun Mulloli. All rights reserved.
//

#import "PDFViewController.h"

@implementation PDFViewController

@synthesize pdfURL, pageNo;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    CGPDFDocumentRef PDFDocument = CGPDFDocumentCreateWithURL((__bridge CFURLRef)pdfURL);
    CGPDFPageRef PDFPage = CGPDFDocumentGetPage(PDFDocument, pageNo);
    
    [(PDFScrollView *)self.view showPDFPage:PDFPage];
    
    CGPDFDocumentRelease(PDFDocument);
    
}

- (void) viewDidUnload
{
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

@end
