//
//  CustomCell.h
//  MyLocations
//
//  Created by Yang Lei on 8/12/15.
//  Copyright (c) 2015 Razeware LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>
#import "ISDiskCache.h"
#import "LocationSingleton.h"
#import "UpperView.h"
#import "PhotosView.h"
#import "Masonry.h"
#import "UIConstants.h"

@interface CustomCell : UITableViewCell


@property (nonatomic, strong) UIView *mainView;
@property (nonatomic, strong) UIView *upperView;
@property (nonatomic, strong) UILabel *middleCommentLabel;
@property (nonatomic, strong) UIView *lowerView;
@property (nonatomic, strong) NSMutableArray *arrayOfImageButtons;

@property (nonatomic, strong) UIButton *portraitButton;
@property (nonatomic, strong) UIImage *portrait;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier;

- (void)configureCellWithPFObject:(PFObject *)object;

@end
