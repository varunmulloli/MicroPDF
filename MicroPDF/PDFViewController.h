//
//  ViewController.h
//  MicroPDF
//
//  Created by Varun Mulloli on 02/11/12.
//  Copyright (c) 2012 Varun Mulloli. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "PDFScrollView.h"

@interface PDFViewController : UIViewController

@property (nonatomic, retain) NSString *bookName;
@property (nonatomic) NSInteger pageNo;
@property (nonatomic) CGRect pageRect;

@end
