//
//  UpperView.m
//  MyLocations
//
//  Created by Yang Lei on 8/12/15.
//  Copyright (c) 2015 Razeware LLC. All rights reserved.
//

#import "UpperView.h"
#import "LocationSingleton.h"

@implementation UpperView{
    ISDiskCache *_diskCache;
    CLLocation *_currentLocation;
    UIImage *_portraint;
}

- (id)initWithCoder:(NSCoder *)aDecoder{
    self = [super initWithCoder:aDecoder];
    if(self){
        _diskCache = [ISDiskCache sharedCache];
        
        //get current user location singleton
        LocationSingleton *singleton = [LocationSingleton getInstance];
        _currentLocation = [singleton getLocation];
    }
    return self;
}


- (instancetype)initWithFrame:(CGRect)frame withPFObject:(PFObject *)object{
    self = [super initWithFrame:frame];
    if(self){
        NSArray *mediaDataArray = [object objectForKey:@"mediaData"];
        NSString  *mediaType = [object objectForKey:@"mediaType"];
        NSString *senderName = [object objectForKey:@"senderName"];
        NSString *senderId = [object objectForKey:@"senderId"];
        NSString *descriptionText = [object objectForKey:@"text"];
        NSString *address = [object objectForKey:@"address"];
        NSString *categoryName = [object objectForKey:@"category"];
        PFGeoPoint *postPosition = [object objectForKey:@"position"];
        NSDate *date = object.createdAt;
        
        [self configurePortraitButtonWithSenderId:senderId];
        
        [self configureSenderButtonWithSenderName:senderName];
        
        [self configureDistanceDateLabelWithGeoPoint:postPosition withDate:date];
    }
    return self;
}


- (void)configurePortraitButtonWithSenderId:(NSString *)senderId{
        self.portraitButton = [UIButton buttonWithType:UIButtonTypeCustom];
        self.portraitButton.translatesAutoresizingMaskIntoConstraints = NO;
        [self.portraitButton addTarget:self action:@selector(showPortrait:)forControlEvents:UIControlEventTouchUpInside];
        [self.portraitButton setBackgroundColor:[UIConstants getLightColor]];
        [self addSubview:self.portraitButton];

        [self.portraitButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self);
            make.left.equalTo(self);
            make.height.equalTo(@(PORTRAIT_WIDTH));
            make.width.equalTo(@(PORTRAIT_WIDTH));
            make.bottom.equalTo(self);
        }];
    
    NSString *key = [NSString stringWithFormat:@"%@.portrait",senderId];
    if ([_diskCache hasObjectForKey:key]) {
        _portraint = [_diskCache objectForKey:key];
        UIImage *thumbnail = [_diskCache objectForKey:[NSString stringWithFormat:@"%@.thumbnail",key]];
        [self.portraitButton setImage:thumbnail forState:UIControlStateNormal];
    }
    
}


- (void)configureSenderButtonWithSenderName:(NSString *)senderName{
    
}


- (void)configureDistanceDateLabelWithGeoPoint: (PFGeoPoint *)geoPoint withDate:(NSDate*)date{
    
}








@end
