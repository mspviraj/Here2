//
//  UpperView.h
//  MyLocations
//
//  Created by Yang Lei on 8/12/15.
//  Copyright (c) 2015 Razeware LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>
#import "ISDiskCache.h"
#import "Masonry.h"
#import "UIConstants.h"

@interface UpperView : UIView

@property (nonatomic, strong) UIButton *portraitButton;
@property (nonatomic, strong) UIButton *senderButton;
@property (nonatomic, strong) UILabel *distanceDateLabel;

- (instancetype)initWithFrame:(CGRect)frame withPFObject:(PFObject *)object;

@end
