//
//  LocationSingleton.h
//  mylocations
//
//  Created by Yang Lei on 5/11/15.
//  Copyright (c) 2015 Razeware LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LocationSingleton : NSObject{
    CLLocation *location;
}

+ (LocationSingleton *) getInstance;

- (void)setLocation:(CLLocation *)newLocation;
- (CLLocation *)getLocation;

@end
