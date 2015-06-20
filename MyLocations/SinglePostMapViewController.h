//
//  SinglePostMapViewController.h
//  mylocations
//
//  Created by Yang Lei on 6/16/15.
//  Copyright (c) 2015 Razeware LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>

@interface SinglePostMapViewController : UIViewController

- (IBAction)goBack:(id)sender;

@property (weak, nonatomic) IBOutlet MKMapView *mapView;

@property (strong,nonatomic) PFObject *object;

@end
