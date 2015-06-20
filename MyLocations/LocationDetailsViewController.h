//
//  LocationDetailsViewController.h
//  MyLocations
//
//  Created by Matthijs on 11-10-13.
//  Copyright (c) 2013 Razeware LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>

@class Location;

@interface LocationDetailsViewController : UITableViewController

@property (nonatomic, assign) CLLocationCoordinate2D coordinate;
@property (nonatomic, strong) CLPlacemark *placemark;


@end
