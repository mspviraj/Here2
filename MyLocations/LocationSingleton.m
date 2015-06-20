//
//  LocationSingleton.m
//  mylocations
//
//  Created by Yang Lei on 5/11/15.
//  Copyright (c) 2015 Razeware LLC. All rights reserved.
//

#import "LocationSingleton.h"

@implementation LocationSingleton

static LocationSingleton *singletonInstance;

+ (LocationSingleton *)getInstance{
    if(singletonInstance == nil){
        singletonInstance = [[super alloc]init];
    }
    return singletonInstance;
}

- (void)setLocation:(CLLocation *)newLocation{
    location = newLocation;
}


- (CLLocation *)getLocation{
    return location;
}

@end
