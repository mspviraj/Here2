//
//  UIImage+ResizeAndCrop.h
//  mylocations
//
//  Created by Yang Lei on 5/26/15.
//  Copyright (c) 2015 Razeware LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (ResizeAndCrop)

- (UIImage*)imageByScalingAndCroppingForSize:(CGSize)targetSize;

@end
