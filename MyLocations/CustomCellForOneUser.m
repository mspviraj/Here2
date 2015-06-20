//
//  CustomCellForOneUser.m
//  mylocations
//
//  Created by Yang Lei on 5/28/15.
//  Copyright (c) 2015 Razeware LLC. All rights reserved.
//

#import "CustomCellForOneUser.h"
#import "UIImage+ResizeAndCrop.h"

@interface CustomCellForOneUser ()

@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@property (weak, nonatomic) IBOutlet UILabel *commentLabel;
@property (weak, nonatomic) IBOutlet UILabel *distanceLabel;
@property (weak, nonatomic) IBOutlet UIButton *imageButton;

@end



@implementation CustomCellForOneUser{
    CGFloat screen_width;
    PFFile *_file;
    NSString *_fileType;
    NSString *_senderName;
    NSString *_senderId;
    NSString *_descriptionText;
    NSString *_address;
    NSString *_categoryName;
    NSDate *_date;
    UIImage *_image;
    NSString *_videoFilePath;
    PFGeoPoint *_userPoint;
}


+ (CGFloat)heightForPFObject:(PFObject *)object{
    CGFloat screen_width = CGRectGetWidth([UIScreen mainScreen].bounds);
    NSString *descriptionText = [object objectForKey:@"text"];
    
    CGFloat heightLeft = 8 + (screen_width/3 - 8);
    
    //UIFont *font = [UIFont fontWithName:@"Helvetica-BoldOblique" size:21];
    UIFont *font = [UIFont systemFontOfSize:15];
    CGSize constraint = CGSizeMake(screen_width * 2/3 - 16 ,CGFLOAT_MAX);
    NSDictionary *attributes = @{NSFontAttributeName: font};
    CGRect rect = [descriptionText boundingRectWithSize:constraint
                                                options:(NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading)
                                             attributes:attributes context:nil];
    
    CGFloat heightRight = 20*2 + 8*3 + CGRectGetHeight(rect);
    return MAX(heightLeft, heightRight) + 8;
}


- (void)configureCellForPFObject:(PFObject *)object{
    screen_width = CGRectGetWidth([UIScreen mainScreen].bounds);
    _file = [object objectForKey:@"file"];
    _fileType = [object objectForKey:@"fileType"];
    _senderName = [object objectForKey:@"senderName"];
    _descriptionText = [object objectForKey:@"text"];
    _address = [object objectForKey:@"address"];
    _categoryName = [object objectForKey:@"category"];
    _userPoint = [object objectForKey:@"position"];
    _date = object.createdAt;
    
    if([_fileType isEqualToString:@"image"]){
        NSURL *imageFileUrl = [[NSURL alloc] initWithString:_file.url];
        NSData *imageData = [NSData dataWithContentsOfURL:imageFileUrl];
        _image = [UIImage imageWithData:imageData];
    }else{
        //File type is video
        NSURL *videoFileUrl = [NSURL URLWithString:_file.url];
        MPMoviePlayerController *player = [[MPMoviePlayerController alloc] initWithContentURL: videoFileUrl];
        _image = [player thumbnailImageAtTime:1 timeOption:MPMovieTimeOptionExact];
        
    }
    
    CLLocation *postLocation = [[CLLocation alloc]initWithLatitude:_userPoint.latitude longitude:_userPoint.longitude];
    CGFloat distance = [postLocation distanceFromLocation:self.currentLocation];
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"EEEE, MMMM d yyyy"];
    self.dateLabel.text = [dateFormatter stringFromDate:_date];
    
    self.commentLabel.text = _descriptionText;
    self.distanceLabel.text = [NSString stringWithFormat:@"%.1f miles from here.",distance/1609];
    
    UIImage *smallImage = [_image imageByScalingAndCroppingForSize:self.imageButton.frame.size];
    [self.imageButton setImage:smallImage forState:UIControlStateNormal];
    
}



- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
