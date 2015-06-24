//
//  CustomCell.m
//  mylocations
//
//  Created by Yang Lei on 5/23/15.
//  Copyright (c) 2015 Razeware LLC. All rights reserved.
//

#import "CustomCell.h"
#import "UIImage+ResizeAndCrop.h"
#import "AFNetworking.h"
#import "ISDiskCache.h"

@interface CustomCell ()

@property (weak, nonatomic) IBOutlet UIButton *senderButton;
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@property (weak, nonatomic) IBOutlet UILabel *commentLabel;
@property (weak, nonatomic) IBOutlet UILabel *distanceLabel;
@property (weak, nonatomic) IBOutlet UIButton *imageButton;



@end


@implementation CustomCell{
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
    
    CGFloat heightLeft = 36 + (screen_width/3 - 8);
    
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
        ISDiskCache *diskCache = [ISDiskCache sharedCache];
        if ([diskCache hasObjectForKey:_file.url]) {
            NSLog(@"Cache hasImage");
            dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
            dispatch_async(queue, ^{
                _image = [diskCache objectForKey:_file.url];
                UIImage *smallImage = [diskCache objectForKey:[NSString stringWithFormat:@"%@.thumbnail",_file.url]];
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.imageButton setImage:smallImage forState:UIControlStateNormal];
                });
            });
        }
        else {
            NSLog(@"Cache noImage");
            AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
            manager.responseSerializer = [AFImageResponseSerializer serializer];
            [manager GET:_file.url parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
                NSLog(@"image: %@",responseObject);
                _image = responseObject;
                if(_image){
                    UIImage *smallImage = [_image imageByScalingAndCroppingForSize:self.imageButton.frame.size];
                    [diskCache setObject:_image forKey:_file.url];
                    [diskCache setObject:smallImage forKey:[NSString stringWithFormat:@"%@.thumbnail",_file.url]];
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self.imageButton setImage:smallImage forState:UIControlStateNormal];
                    });
                }
            } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                NSLog(@"AFNetworking error: %@",error);
            }];
//            NSURLRequest *request = [NSURLRequest requestWithURL:URL];
//            [NSURLConnection sendAsynchronousRequest:request
//                                               queue:self.operationQueue
//                                   completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
//                                       UIImage *image = [UIImage imageWithData:data];
//                                       if (image) {
//                                           [diskCache setObject:image forKey:URL];
//                                           dispatch_async(dispatch_get_main_queue(), ^{
//                                               UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
//                                               cell.imageView.image = image;
//                                           });
//                                       }
//                                   }];
        }
        
        
        
//        AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
//        manager.responseSerializer = [AFImageResponseSerializer serializer];
//        [manager GET:_file.url parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
//            NSLog(@"image: %@",responseObject);
//            _image = responseObject;
//        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
//            NSLog(@"Error: %@",error);
//        }];
    }else{
        //File type is video
        NSURL *videoFileUrl = [NSURL URLWithString:_file.url];
        MPMoviePlayerController *player = [[MPMoviePlayerController alloc] initWithContentURL: videoFileUrl];
        _image = [player thumbnailImageAtTime:1 timeOption:MPMovieTimeOptionExact];

    }
    
    CLLocation *postLocation = [[CLLocation alloc]initWithLatitude:_userPoint.latitude longitude:_userPoint.longitude];
    CGFloat distance = [postLocation distanceFromLocation:self.currentLocation];

    [_senderButton setTitle:_senderName forState:UIControlStateNormal];
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"EEEE, MMMM d yyyy"];
    self.dateLabel.text = [dateFormatter stringFromDate:_date];
    
    self.commentLabel.text = _descriptionText;
    self.distanceLabel.text = [NSString stringWithFormat:@"%.1f miles from here.",distance/1609];
    
    //UIImage *smallImage = [_image imageByScalingAndCroppingForSize:self.imageButton.frame.size];
    [self.imageButton setBackgroundColor:[UIColor lightGrayColor]];
    //[self.imageButton setImage:smallImage forState:UIControlStateNormal];
    
    
    
    //Auto Layout Constraint
    
    //UIFont *font = [UIFont systemFontOfSize:15];
    UIFont *font = [UIFont fontWithName:@"HelveticaNeue" size:15];
    //CGSize constraint = CGSizeMake(screen_width * 2/3 - 16 ,500);
    //NSDictionary *attributes = @{NSFontAttributeName: font};
    NSLog(@"_descriptionText is %@",_descriptionText);
    CGFloat height = [SYFrameHelper getExpectedLabelRoundedHeightWithText:_descriptionText withLabelWidth:(screen_width * 2/3 -16) withFont:font];
    NSUInteger leftBaseline = self.imageButton.frame.origin.y + self.imageButton.frame.size.height;
    NSUInteger rightBaseline = 30 + height + 8 + CGRectGetHeight(self.distanceLabel.frame);

    NSLog(@"leftBaseline and rightBaseline are %lu and %lu",(unsigned long)leftBaseline,(unsigned long)rightBaseline);
    
    self.imageButton.translatesAutoresizingMaskIntoConstraints = NO;
    self.distanceLabel.translatesAutoresizingMaskIntoConstraints = NO;
    
    UIButton *leftButton = self.imageButton;
    UILabel *rightLabel = self.distanceLabel;
    NSDictionary *viewDict = NSDictionaryOfVariableBindings(leftButton, rightLabel);
    if(leftBaseline >= rightBaseline){
         [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[leftButton]-4-|" options:0 metrics:0 views:viewDict]];
    }else{
        [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[rightLabel]-4-|" options:0 metrics:0 views:viewDict]];
    }
    
}





- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
