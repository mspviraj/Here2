//
//  UIConstants.h
//  GHP
//
//  Created by James Zhou on 4/25/15.
//  Copyright (c) 2015 GHP. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>


#ifndef GHP_UICONSTANT_H
#define GHP_UICONSTANT_H

#define CONTENT_PADDING (20)
#define TAB_BAR_PADDING (49)
#define DEFAULT_GAP (20)
#define DEFAULT_INSETS (UIEdgeInsetsMake(0, 0, 0, 0))
#define WIDE_GAP (25)
#define SMALL_GAP (8)
#define SMALLER_GAP (4)

#define LOGIN_BUTTONG_HOR_PADDING (27.5)
#define LOGIN_REGISTER_BORDER_WIDTH (1. / [[UIScreen mainScreen] scale])
#define BUTTON_HOR_PADDING (0)
#define BUTTON_BOTTOM_PADDING (0)
#define BUTTON_HEIGHT (50)

#define UPLOAD_BUTTON_HOR_MARGIN (100)
#define COMPUTER_UPLOAD_BUTTON_TOP_MARGIN (80)

#define PROGRESS_BAR_TOP (64)
#define PROGRESS_BAR_HEIGHT (8)

#define INSTRUCTION_LABEL_HEIGHT (30)

#define SCREEN_WIDTH ([[UIScreen mainScreen] bounds].size.width)
#define SCREEN_HEIGHT ([[UIScreen mainScreen] bounds].size.height)

#define IS_IPHONE_5 (SCREEN_HEIGHT == 568.0)
#define IS_IPHONE_6 (SCREEN_HEIGHT == 667.0)

#define IPHONE_5_IMAGE_HEIGHT (454.0)
#define IPHONE_6_IMAGE_HEIGHT (553.0)

#define IPHONE_5_UPLOAD_MARGIN (16.0)
#define IPHONE_5_UPLOAD_WIDTH (136.0)

#define IPHONE_6_UPLOAD_MARGIN (15.0)
#define IPHONE_6_UPLOAD_WIDTH (165.0)

#define NUMBER_OF_IMAGES_PER_ROW (3)

#endif

@interface UIConstants : NSObject

#pragma mark - Helper functions
+(CGFloat)getPortraitWidth;
+(CGFloat)getSenderButtonHeight;
+(CGFloat)getDateLabelHeight;
+(CGFloat)getDistanceLabelHeight;
+(CGFloat)getThumbnailWidth;
+(CGFloat)scaleWidth:(CGFloat)width;
+(CGFloat)scaleHeight:(CGFloat)height;

#pragma mark - FONTS
+(CGFloat)getSenderButtonFontSize;
+(CGFloat)getCommentLabelFontSize;
+(CGFloat)getDateLabelFontSize;
+(CGFloat)getDistanceLabelFontSize;
+(NSString *)getTextFontName;

#pragma mark - COLORS
+(UIColor*)getDefaultTextColor;
+(UIColor*)getSenderButtonColor;
+(UIColor*)getDefaultButtonColor;
+(UIColor*)getLightColor;
+(UIColor*)getThemeColor;
+(UIColor*)getLightThemeColor;
+(UIColor*)getMedeiumThemeColor;
+(UIColor*)getTextHighlightColor;



@end
