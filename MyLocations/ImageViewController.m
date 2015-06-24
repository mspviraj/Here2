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
    
    ISDiskCache *diskCache = [ISDiskCache sharedCache];
    PFFile *imageFile = [self.object objectForKey:@"file"];
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(queue, ^{
        UIImage *image = [diskCache objectForKey:imageFile.url];
        dispatch_async(dispatch_get_main_queue(), ^{
            self.imageView.image = image;
        });
    });
    
    NSString *senderName = [self.object objectForKey:@"senderName"];
    NSString *title = [NSString stringWithFormat:@"%@", senderName];
    self.navigationItem.title = title;
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

- (IBAction)tapOnImage:(id)sender{
    [self dismissViewControllerAnimated:YES completion:nil];
}


@end
