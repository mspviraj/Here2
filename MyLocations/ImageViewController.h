//
//  ImageViewController.h
//  mylocations
//
//  Created by Yang Lei on 5/27/15.
//  Copyright (c) 2015 Razeware LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>

@interface ImageViewController : UIViewController

@property (strong,nonatomic) UIImage *image;

@property (weak, nonatomic) IBOutlet UIImageView *imageView;

- (IBAction)tapOnImage:(id)sender;


@end
