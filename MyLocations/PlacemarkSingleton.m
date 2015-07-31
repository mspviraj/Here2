//
//  PlacemarkSingleton.m
//  MyLocations
//
//  Created by Yang Lei on 7/6/15.
//  Copyright (c) 2015 Razeware LLC. All rights reserved.
//

#import "PlacemarkSingleton.h"

@implementation PlacemarkSingleton

static PlacemarkSingleton *placemarkSingleton;


+ (PlacemarkSingleton *) getInstance{
    if(placemarkSingleton == nil){
        placemarkSingleton = [[super alloc]init];
    }
    return placemarkSingleton;
}

- (void)setPlacemark:(CLPlacemark *)newPlacemark{
    placemark = newPlacemark;
}

- (CLPlacemark *)getPlacemark{
    return placemark;
}


@end
