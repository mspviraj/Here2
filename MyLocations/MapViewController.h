//
//  MapViewController.h
//  MyLocations
//
//  Created by Matthijs on 16-10-13.
//  Copyright (c) 2013 Razeware LLC. All rights reserved.
//

@interface MapViewController : UIViewController <CLLocationManagerDelegate>

@property (weak, nonatomic) IBOutlet UINavigationBar *navigationBar;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *postButton;

- (IBAction)newPost:(id)sender;

@end
