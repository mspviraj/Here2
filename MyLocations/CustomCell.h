//
//  CustomCell.h
//  mylocations
//
//  Created by Yang Lei on 5/23/15.
//  Copyright (c) 2015 Razeware LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>
#import <MediaPlayer/MediaPlayer.h>
#import "SYFrameHelper.h"

@interface CustomCell : UITableViewCell

@property (strong,nonatomic) CLLocation *currentLocation;


+ (CGFloat)heightForPFObject:(PFObject *)object;

- (void)configureCellForPFObject:(PFObject *)object;



@end
