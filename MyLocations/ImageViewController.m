//
//  ImageViewController.m
//  mylocations
//
//  Created by Yang Lei on 5/27/15.
//  Copyright (c) 2015 Razeware LLC. All rights reserved.
//

#import "ImageViewController.h"
#import "ISDiskCache.h"


@interface ImageViewController ()

@end

@implementation ImageViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.imageView.backgroundColor = [UIColor blackColor];
    self.imageView.image = self.image;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}



- (IBAction)tapOnImage:(id)sender{
    [self dismissViewControllerAnimated:YES completion:nil];
}


@end
