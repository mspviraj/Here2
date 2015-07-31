//
//  UIConstants.m
//  GHP
//
//  Created by James Zhou on 4/25/15.
//  Copyright (c) 2015 GHP. All rights reserved.
//

#import "UIConstants.h"

@implementation UIConstants

+ (CGFloat)getPortraitWidth
{
    return 45;
}

+ (CGFloat)getSenderButtonHeight
{
    return 18;
}

+(CGFloat)getDateLabelHeight
{
    return 12;
}
+(CGFloat)getDistanceLabelHeight
{
    return 12;
}

+(CGFloat)getThumbnailWidth
{
    return 80;
}

+ (CGFloat)scaleWidth:(CGFloat)width
{
    return width * CGRectGetWidth([UIScreen mainScreen].bounds) / 375;
}

+ (CGFloat)scaleHeight:(CGFloat)height
{
    return height * CGRectGetHeight([UIScreen mainScreen].bounds) / 667;
}

+(CGFloat)getSenderButtonFontSize
{
    return 18;
}

+(CGFloat)getCommentLabelFontSize
{
    return 15;
}

+(CGFloat)getDateLabelFontSize
{
    return 12;
}

+(CGFloat)getDistanceLabelFontSize
{
    return 12;
}

+(NSString *)getTextFontName
{
    return @"Lantinghei SC";
}

+(UIColor*)getDefaultTextColor
{
    return [UIColor blackColor];
}

+(UIColor*)getSenderButtonColor
{
    return [UIColor blueColor];
}

+(UIColor*)getDefaultButtonColor
{
    return [UIColor grayColor];
}

+(UIColor*)getLightColor
{
    return [UIColor lightGrayColor];
}

+(UIColor*)getThemeColor
{
    return [UIColor colorWithRed:13.0/255.0 green:189.0/255.0 blue:171.0/255.0 alpha:1];
}

+(UIColor*)getLightThemeColor
{
    return [UIColor colorWithRed:240.0/255.0 green:251.0/255.0 blue:249.0/255.0 alpha:1];
}

+(UIColor*)getMedeiumThemeColor
{
    return [UIColor colorWithRed:133.0/255.0 green:221.0/255.0 blue:212.0/255.0 alpha:1];
}

+(UIColor*)getTextHighlightColor
{
    return [UIColor colorWithRed:237.0/255.0 green:144.0/255.0 blue:121.0/255.0 alpha:1];
}



@end
