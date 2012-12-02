//
//  PDFViewController.h
//  MicroPDF
//
//  Created by Varun Mulloli on 02/12/12.
//  Copyright (c) 2012 Varun Mulloli. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PDFViewController : UIViewController <UIWebViewDelegate>

@property (nonatomic, retain) NSString *bookName;

@property (nonatomic, retain) IBOutlet UIWebView *webView;
@property (nonatomic, retain) IBOutlet UIActivityIndicatorView *activity;

@end
