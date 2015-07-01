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
#import "FMDB.h"

@interface CustomCell ()

@property (weak, nonatomic) IBOutlet UIButton *senderButton;
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@property (weak, nonatomic) IBOutlet UILabel *commentLabel;
@property (weak, nonatomic) IBOutlet UILabel *distanceLabel;
@property (weak, nonatomic) IBOutlet UIButton *portraitButton;
@property (weak, nonatomic) IBOutlet UIView *viewOfImage;



@end


@implementation CustomCell{
    CGFloat screen_width;
    NSArray *_mediaDataArray;
    NSString *_mediaType;
    NSString *_senderName;
    NSString *_senderId;
    NSString *_descriptionText;
    NSString *_address;
    NSString *_categoryName;
    NSDate *_date;
    NSString *_videoFilePath;
    PFGeoPoint *_postPosition;
    UIImage *_portrait;
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



//PFObject *message = [PFObject objectWithClassName:@"Messages"];
//[message setObject:_mediaDataArray forKey:@"mediaData"];
//[message setObject:mediaType forKey:@"mediaType"];
//[message setObject:[[PFUser currentUser] objectId] forKey:@"senderId"];
//[message setObject:[[PFUser currentUser] username] forKey:@"senderName"];
//[message setObject:text forKey:@"text"];
//[message setObject:address forKey:@"address"];
//[message setObject:position forKey:@"position"];
//[message setObject:category forKey:@"category"];



- (void)configureCellForPFObject:(PFObject *)object{
    screen_width = CGRectGetWidth([UIScreen mainScreen].bounds);
    _mediaDataArray = [object objectForKey:@"mediaData"];
    _mediaType = [object objectForKey:@"mediaType"];
    _senderName = [object objectForKey:@"senderName"];
    _senderId = [object objectForKey:@"senderId"];
    _descriptionText = [object objectForKey:@"text"];
    _address = [object objectForKey:@"address"];
    _categoryName = [object objectForKey:@"category"];
    _postPosition = [object objectForKey:@"position"];
    _date = object.createdAt;
    
    ISDiskCache *diskCache = [ISDiskCache sharedCache];
    
    
    
    
    
    
    //deal with post sender portrait, use FMDB to store the portrait's url string
    
    NSArray  *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *docsPath = [paths objectAtIndex:0];
    NSString *dbPath = [docsPath stringByAppendingPathComponent:@"portrait.db"];
    FMDatabase *db = [FMDatabase databaseWithPath:dbPath];
    
    if(![db open]){
        NSLog(@"can't open database in CustomCell");
    }
    FMResultSet *resultSet = [db executeQuery:@"select * from portrait where objectId= ?", _senderId];
    NSString *stringOfUrl;
    NSMutableArray *urls = [NSMutableArray array];
    int count = 0;
    
    while ([resultSet next]) {
        [urls addObject:[resultSet stringForColumn:@"url"]];
        count++;
    }
    [db close];
    
    if(urls.count > 0){
        NSLog(@"Found portrait url in FMDB");
        stringOfUrl = [urls lastObject];
        self.portraitStringOfUrl = stringOfUrl;
        UIImage *smallImage = [diskCache objectForKey:[NSString stringWithFormat:@"%@.small",stringOfUrl]];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.portraitButton setImage:smallImage forState:UIControlStateNormal];
            [self.portraitButton addTarget:self action:@selector(showPortrait:) forControlEvents:UIControlEventTouchUpInside];
        });
    }
    else{                                          //FMDB doesn't have url
        PFQuery *query = [PFUser query];
        [query whereKey:@"objectId" equalTo:_senderId];
        [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error){
            if(error){
                NSLog(@"Error: %@ %@", error, [error userInfo]);
            }
            else{
                PFUser *user = [objects lastObject];
                PFFile *file = [user objectForKey:@"image"];
                self.portraitStringOfUrl = file.url;
                
                AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
                manager.responseSerializer = [AFImageResponseSerializer serializer];
                [manager GET:file.url parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
                    _portrait = responseObject;
                    if(_portrait){
                        UIImage *smallImage = [_portrait imageByScalingAndCroppingForSize:self.portraitButton.frame.size];
                        [diskCache setObject:_portrait forKey:file.url];
                        [diskCache setObject:smallImage forKey:[NSString stringWithFormat:@"%@.small",file.url]];
                        
                        [db open];
                        BOOL success;
                        success = [db executeUpdate:@"insert into portrait(objectId,url) values(?,?)",_senderId, file.url];
                        if (!success) {
                            NSLog(@"%s: update table error: %@", __FUNCTION__, [db lastErrorMessage]);
                        }
                        [db close];

                        
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [self.portraitButton setImage:smallImage forState:UIControlStateNormal];
                            [self.portraitButton addTarget:self action:@selector(showPortrait:) forControlEvents:UIControlEventTouchUpInside];
                        });
                    }
                } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                    NSLog(@"AFNetworking error: %@",error);
                }];
            }
        }];
    }
    
    
    
    
    
    
    
    //whether there is media uploaded and how many media files it contains, 1 or more
    
    if(_mediaDataArray.count == 0){
        self.viewOfImage.hidden = YES;
        [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.dateLabel attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.commentLabel attribute:NSLayoutAttributeBottom multiplier:1 constant:8]];
    }
    else if(_mediaDataArray.count == 1){
        [self.viewOfImage setBackgroundColor:[UIColor whiteColor]];
        PFFile *file = _mediaDataArray[0];
        [self.arrayOfUrls addObject:file.url];
        
        if ([diskCache hasObjectForKey:file.url]) {
            NSLog(@"ISDiskCache has %d th image",0);
            dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
            dispatch_async(queue, ^{
                dispatch_async(dispatch_get_main_queue(), ^{
                    UIImage *smallImage = [diskCache objectForKey:[NSString stringWithFormat:@"%@.small",file.url]];
                    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
                    [button addTarget:self
                               action:@selector(showImage:)
                     forControlEvents:UIControlEventTouchUpInside];
                    button.frame = CGRectMake(0, 0, smallImage.size.width, smallImage.size.height);
                    button.tag = 0;
                    [button setBackgroundColor:[UIColor lightGrayColor]];
                    [button setImage:smallImage forState:UIControlStateNormal];
                    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.viewOfImage attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:0 multiplier:1 constant:button.frame.size.height]];
                    [self.viewOfImage addSubview:button];
                });
            });
        }
        else{
            AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
            manager.responseSerializer = [AFImageResponseSerializer serializer];
            [manager GET:file.url parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
                UIImage *image = responseObject;
                if(image){
                    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
                    [button addTarget:self
                               action:@selector(showImage:)
                     forControlEvents:UIControlEventTouchUpInside];
                    CGFloat resizedHeight;
                    CGFloat resizedWidth;
                    if(image.size.height > image.size.width){
                        resizedHeight = 200;
                        resizedWidth = image.size.width/image.size.height * 200;
                    }
                    else{
                        resizedHeight = image.size.height/image.size.width * 200;
                        resizedWidth = 200;
                    }
                    button.frame = CGRectMake(0, 0, resizedWidth, resizedHeight);
                    button.tag = 0;
                    [button setBackgroundColor:[UIColor lightGrayColor]];
                    UIImage *smallImage = [image imageByScalingAndCroppingForSize:button.frame.size];
                    [button setImage:smallImage forState:UIControlStateNormal];
                    
                    [diskCache setObject:image forKey:file.url];
                    [diskCache setObject:smallImage forKey:[NSString stringWithFormat:@"%@.small",file.url]];
                    
                    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.viewOfImage attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:0 multiplier:1 constant:resizedHeight]];
                    [self.viewOfImage addSubview:button];
                }
            } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                NSLog(@"AFNetworking error: %@",error);
            }];
        }
    }
    else{       //more than 1 image
        CGFloat viewOfImageHeight = ((_mediaDataArray.count-1) /3 + 1) * (80+4) - 4;
        [self.viewOfImage setBackgroundColor:[UIColor whiteColor]];
        self.viewOfImage.translatesAutoresizingMaskIntoConstraints  = NO;
        [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.viewOfImage attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:0 multiplier:1 constant:viewOfImageHeight]];
        NSLog(@"%d photos received",_mediaDataArray.count);
        
        if([_mediaType isEqualToString:@"image"]){
            
            for (int i=0; i<_mediaDataArray.count; ++i) {
                PFFile *file = _mediaDataArray[i];
                [self.arrayOfUrls addObject:file.url];
                
                CGFloat xOrigin = (i%3)*(80 +4);
                CGFloat yOrigin = (i/3)*(80 +4);
                
                UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
                [button addTarget:self
                           action:@selector(showImage:)
                 forControlEvents:UIControlEventTouchUpInside];
                button.frame = CGRectMake(xOrigin, yOrigin, 80, 80);
                button.tag = i;
                [button setBackgroundColor:[UIColor lightGrayColor]];
                [self.viewOfImage addSubview:button];

                
                
                // whether ISDiskCache has post images
                if ([diskCache hasObjectForKey:file.url]) {
                    NSLog(@"ISDiskCache has %d th image",i);
                    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
                    dispatch_async(queue, ^{
                        dispatch_async(dispatch_get_main_queue(), ^{
                            UIImage *smallImage = [diskCache objectForKey:[NSString stringWithFormat:@"%@.small",file.url]];
                            [button setImage:smallImage forState:UIControlStateNormal];
                        });
                    });
                }
                else{
                    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
                    manager.responseSerializer = [AFImageResponseSerializer serializer];
                    [manager GET:file.url parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
                        UIImage *image = responseObject;
                        if(image){
                            UIImage *smallImage = [image imageByScalingAndCroppingForSize:button.frame.size];
                            [diskCache setObject:image forKey:file.url];
                            [diskCache setObject:smallImage forKey:[NSString stringWithFormat:@"%@.small",file.url]];
                            dispatch_async(dispatch_get_main_queue(), ^{
                                [button setImage:smallImage forState:UIControlStateNormal];
                            });
                        }
                    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                        NSLog(@"AFNetworking error: %@",error);
                    }];
                }
            }
        }else{
            //File type is video
            //NSURL *videoFileUrl = [NSURL URLWithString:_file.url];
            //MPMoviePlayerController *player = [[MPMoviePlayerController alloc] initWithContentURL: videoFileUrl];
            //_image = [player thumbnailImageAtTime:1 timeOption:MPMovieTimeOptionExact];

        }
    }
    
    
    
    //deal with other labels and buttons
    CLLocation *postLocation = [[CLLocation alloc]initWithLatitude:_postPosition.latitude longitude:_postPosition.longitude];
    CGFloat distance = [postLocation distanceFromLocation:self.currentLocation];

    [_senderButton setTitle:_senderName forState:UIControlStateNormal];
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"EEEE, MMMM d yyyy"];
    self.dateLabel.text = [dateFormatter stringFromDate:_date];
    
    self.commentLabel.text = _descriptionText;
    self.distanceLabel.text = [NSString stringWithFormat:@"%.1f miles from here.",distance/1609];
    
}


- (void)showImage:(UIButton *)button{
    NSString *stringOfUrl = self.arrayOfUrls[button.tag];
    UIImage *image = [[ISDiskCache sharedCache] objectForKey:stringOfUrl];
    [self.delegate imageTapped:image];
}

- (void)showPortrait:(UIButton *)button{
    UIImage *image = [[ISDiskCache sharedCache] objectForKey:self.portraitStringOfUrl];
    [self.delegate imageTapped:image];
}

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
