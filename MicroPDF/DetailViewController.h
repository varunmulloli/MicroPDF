//
//  DetailViewController.h
//  MicroPDF
//
//  Created by Varun Mulloli on 22/11/12.
//  Copyright (c) 2012 Varun Mulloli. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DetailViewController : UIViewController

@property (strong, nonatomic) id detailItem;

@property (weak, nonatomic) IBOutlet UILabel *detailDescriptionLabel;
@end
