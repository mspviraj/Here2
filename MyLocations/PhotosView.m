//
//  PhotosView.m
//  MyLocations
//
//  Created by Yang Lei on 8/10/15.
//  Copyright (c) 2015 Razeware LLC. All rights reserved.
//

#import "PhotosView.h"
#import <Parse/Parse.h>
#import "UIConstants.h"
#import "Masonry.h"
#import "FMDB.h"
#import "AFNetworking.h"
#import "UIImage+ResizeAndCrop.h"
#import "Masonry.h"
#import "UIConstants.h"
#import "MWCommon.h"
#import <SDWebImage/UIImageView+WebCache.h>


@interface PhotosView()

@property (nonatomic, strong) NSMutableArray *MWPhotosArray;

@end




@implementation PhotosView{
    SDWebImageManager *_manager;
}


- (instancetype)initWithFrame:(CGRect)frame WithMediaFileArray:(NSArray *)mediaDataArray{
    self = [super initWithFrame:frame];
    if (self) {
        CGFloat imageButtonWidth = [self getImageButtonWidth];
        
        self.MWPhotosArray = [NSMutableArray array];
        for (int i=0; i<mediaDataArray.count; ++i){
            [self.MWPhotosArray addObject:[NSNull null]];
        }
        
        _manager = [SDWebImageManager sharedManager];
        
        for(int i=0; i<mediaDataArray.count; ++i){
            PFFile *file = mediaDataArray[i];
            
            UIButton *imageButton  = [UIButton buttonWithType:UIButtonTypeCustom];
            [imageButton addTarget:self action:@selector(showImage:) forControlEvents:UIControlEventTouchUpInside];
            imageButton.tag = i;
            [imageButton setBackgroundColor:[UIConstants getLightColor]];
            imageButton.translatesAutoresizingMaskIntoConstraints = NO;
            [self addSubview:imageButton];
            
            CGFloat xOrigin;
            CGFloat yOrigin;
            
            xOrigin = (i % NUMBER_OF_IMAGES_PER_ROW) * (imageButtonWidth + SMALLER_GAP);
            yOrigin = (i / NUMBER_OF_IMAGES_PER_ROW) * (imageButtonWidth + SMALLER_GAP);
            
            [imageButton mas_makeConstraints:^(MASConstraintMaker *make) {
                make.top.equalTo(self.mas_top).with.offset(yOrigin);
                make.left.equalTo(self.mas_left).with.offset(xOrigin);
                make.width.equalTo(@(imageButtonWidth));
                make.height.equalTo(@(imageButtonWidth));
                if(i == (mediaDataArray.count - 1)){
                    make.bottom.equalTo(self.mas_bottom);
                }
            }];
            
            [_manager downloadImageWithURL:[NSURL URLWithString:file.url]
                                  options:0
                                 progress:^(NSInteger receivedSize, NSInteger expectedSize) {
                                     // progression tracking code
                                 }
                                completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished, NSURL *imageURL) {
                                    if (image) {
                                        if(i < mediaDataArray.count){
                                            self.MWPhotosArray[i] = [MWPhoto photoWithImage:image];
                                        }
                                        UIImage *thumbnail = [image imageByScalingAndCroppingForSize:CGSizeMake(imageButtonWidth, imageButtonWidth)];
                                        dispatch_async(dispatch_get_main_queue(), ^{ // update the user interface
                                            [imageButton setImage:thumbnail forState:UIControlStateNormal];
                                        });
                                    }
                                }];
            
            
            // whether ISDiskCache has post images
//            if ([_diskCache hasObjectForKey:file.url]) {
//                NSLog(@"ISDiskCache has %d th image",i);
//                UIImage *image = [_diskCache objectForKey:file.url];
//                self.MWPhotosArray[i] = [MWPhoto photoWithImage:image];
//                UIImage *smallImage = [_diskCache objectForKey:[NSString stringWithFormat:@"%@.small",file.url]];
//                [imageButton setImage:smallImage forState:UIControlStateNormal];
//            }
        }
    }
    
    
    return self;
}


- (CGFloat)getImageButtonWidth{
    return (([UIScreen mainScreen].bounds.size.width - 2 * MEDIUM_GAP) - (NUMBER_OF_IMAGES_PER_ROW - 1) * SMALLER_GAP) / NUMBER_OF_IMAGES_PER_ROW;
}


- (void)showImage:(UIButton *)button{
    [self.delegate showImageWithPhotosArray:self.MWPhotosArray WithIndex:button.tag];
}


@end
