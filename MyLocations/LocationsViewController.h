//
//  LocationsViewController.h
//  MyLocations
//
//  Created by Matthijs on 15-10-13.
//  Copyright (c) 2013 Razeware LLC. All rights reserved.
//


#import <MediaPlayer/MediaPlayer.h>
#import <Parse/Parse.h>
#import "MWPhotoBrowser.h"



@interface LocationsViewController : UITableViewController <MWPhotoBrowserDelegate>

@property (strong,nonatomic) MPMoviePlayerController *moviePlayer;

@property (strong,nonatomic) UIImage *imageToImageViewController;



@property (assign,nonatomic) BOOL allPostsViewController;

@property (assign,nonatomic) BOOL currentUserPostsViewController;

@property (strong,nonatomic) PFObject *PFObjectFromMapView;

@property (strong,nonatomic) NSString *senderId;


- (IBAction)logout:(id)sender;


- (IBAction)goBackOrNewPost:(id)sender;


- (IBAction)showMap:(id)sender;


@end

