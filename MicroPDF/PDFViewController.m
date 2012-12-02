//
//  PDFViewController.m
//  MicroPDF
//
//  Created by Varun Mulloli on 02/12/12.
//  Copyright (c) 2012 Varun Mulloli. All rights reserved.
//

#import "PDFViewController.h"

@implementation PDFViewController

@synthesize bookName, webView, activity;

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    self.title = bookName;
    NSArray *pathArray = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,
                                                             NSUserDomainMask, YES);
    NSString *path = [[NSBundle bundleWithPath:[pathArray objectAtIndex:0]] pathForResource:[bookName stringByDeletingPathExtension] ofType:@"pdf"];
    webView.backgroundColor = [UIColor clearColor];
    
    NSURL *url = [NSURL fileURLWithPath:path];
    NSURLRequest *requestObj = [NSURLRequest requestWithURL:url];
    
    [webView loadRequest:requestObj];
}

-(void) webViewDidStartLoad:(UIWebView *)webView
{
    [activity startAnimating];
}

- (void) webViewDidFinishLoad:(UIWebView *)webView
{
    [activity stopAnimating];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return YES;
}

@end
