//
//  ViewController.m
//  MicroPDF
//
//  Created by Varun Mulloli on 02/11/12.
//  Copyright (c) 2012 Varun Mulloli. All rights reserved.
//

#import "PDFViewController.h"

@implementation PDFViewController

@synthesize bookName, pageNo, pageRect;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    NSArray *pathArray = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,
                                                             NSUserDomainMask, YES);
    NSString *path = [[NSBundle bundleWithPath:[pathArray objectAtIndex:0]] pathForResource:bookName ofType:@"pdf"];
    NSURL *pdfURL = [NSURL fileURLWithPath:path];
    
    CGPDFDocumentRef PDFDocument = CGPDFDocumentCreateWithURL((__bridge CFURLRef)pdfURL);
    CGPDFPageRef PDFPage = CGPDFDocumentGetPage(PDFDocument, pageNo);
    
    self.view.frame = pageRect;
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
