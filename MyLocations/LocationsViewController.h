//
//  LocationsViewController.h
//  MyLocations
//
//  Created by Matthijs on 15-10-13.
//  Copyright (c) 2013 Razeware LLC. All rights reserved.
//


#import <MediaPlayer/MediaPlayer.h>
#import "ImageViewController.h"
#import "SYFrameHelper.h"


@interface LocationsViewController : UITableViewController

@property (strong,nonatomic) MPMoviePlayerController *moviePlayer;


- (IBAction)imageButtonPushed:(id)sender;


- (IBAction)logout:(id)sender;


@end

