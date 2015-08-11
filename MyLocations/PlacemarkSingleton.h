//
//  PlacemarkSingleton.h
//  MyLocations
//
//  Created by Yang Lei on 7/6/15.
//  Copyright (c) 2015 Razeware LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PlacemarkSingleton : NSObject{
    CLPlacemark *placemark;
}


+ (PlacemarkSingleton *) getInstance;

- (void)setPlacemark:(CLPlacemark *)newPlacemark;

- (CLPlacemark *)getPlacemark;

@end
