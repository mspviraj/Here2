//
//  SenderPostsController.h
//  mylocations
//
//  Created by Yang Lei on 5/26/15.
//  Copyright (c) 2015 Razeware LLC. All rights reserved.
//


#import <MediaPlayer/MediaPlayer.h>
#import "ImageViewController.h"
#import <UIKit/UIKit.h>
#import <Parse/Parse.h>

@interface SenderPostsController : UITableViewController

@property (strong,nonatomic) MPMoviePlayerController *moviePlayer;

@property (strong,nonatomic) NSString *senderId;

@property (weak, nonatomic) IBOutlet UIBarButtonItem *cancelButton;

- (IBAction)imageButtonPushed:(id)sender;


@end
