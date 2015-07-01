//
//  Practice2ViewController.m
//  MyLocations
//
//  Created by Yang Lei on 6/26/15.
//  Copyright (c) 2015 Razeware LLC. All rights reserved.
//

#import "Practice2ViewController.h"

@interface Practice2ViewController ()

@end

@implementation Practice2ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    CGFloat screenWidth = screenRect.size.width;
    CGFloat screenHeight = screenRect.size.height;
    NSLog(@"screen width is %f",screenWidth);
    NSLog(@"screen height is %f",screenHeight);
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
