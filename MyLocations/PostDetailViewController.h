//
//  PostDetailViewController.h
//  mylocations
//
//  Created by Yang Lei on 5/31/15.
//  Copyright (c) 2015 Razeware LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>
#import <MediaPlayer/MediaPlayer.h>


@interface PostDetailViewController : UIViewController

@property (strong,nonatomic) PFObject *object;

@property (strong,nonatomic) MPMoviePlayerController *moviePlayer;


- (IBAction)goBack:(id)sender;

- (IBAction)imageTapped:(id)sender;

- (IBAction)mapTapped:(id)sender;


@end
