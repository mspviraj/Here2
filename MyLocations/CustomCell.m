//
//  CustomCell.m
//  MyLocations
//
//  Created by Yang Lei on 8/12/15.
//  Copyright (c) 2015 Razeware LLC. All rights reserved.
//

#import "CustomCell.h"
#import "MWCommon.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "ISDiskCache.h"
#import "MWCommon.h"
#import "MWPhotoBrowser.h"
#import "UIImage+ResizeAndCrop.h"



@interface CustomCell()

@property (nonatomic, strong) NSMutableArray *MWPhotosArray;

@end

ISDiskCache *diskCache;
SDWebImageManager *imageManager;


@implementation CustomCell


- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if(self){
        self.contentView.backgroundColor = [UIConstants getLightColor];
        
        self.mainView = [[UIView alloc]initWithFrame:CGRectZero];
        self.upperView = [[UIView alloc]initWithFrame:CGRectZero];
        self.middleCommentLabel = [[UILabel alloc]init];
        self.lowerView = [[UIView alloc]initWithFrame:CGRectZero];
        
        self.arrayOfImageButtons = [NSMutableArray array];
        for (int i=0; i<9; ++i){
            UIButton *imageButton = [UIButton buttonWithType:UIButtonTypeCustom];
            [self.arrayOfImageButtons addObject:imageButton];
        }
        
    }
    return self;
}

//NSArray *mediaDataArray = [object objectForKey:@"mediaData"];
//NSString  *mediaType = [object objectForKey:@"mediaType"];
//NSString *senderName = [object objectForKey:@"senderName"];
//NSString *senderId = [object objectForKey:@"senderId"];
//NSString *descriptionText = [object objectForKey:@"text"];
//NSString *address = [object objectForKey:@"address"];
//NSString *categoryName = [object objectForKey:@"category"];
//PFGeoPoint *postPosition = [object objectForKey:@"position"];
//NSDate *date = object.createdAt;

- (void)configureCellWithPFObject:(PFObject *)object{
    [self configureMainViewWithPFObject:object];
    
    [self configureUpperViewWithPFObject:object];
    
    [self configureMiddleCommentLabelWithPFObject:object];
    
    NSArray *mediaDataArray = [object objectForKey:@"mediaData"];
    if (mediaDataArray.count != 0){
        [self configureLowerViewWithPFObject:object];
    }
    
    
}

- (void)configureMainViewWithPFObject:(PFObject *)object{
    [self.mainView setBackgroundColor:[UIColor whiteColor]];
    [self.contentView addSubview:self.mainView];
    [self.mainView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.and.right.equalTo(self.contentView);
        make.top.equalTo(self.contentView.mas_top).with.offset(SMALLER_GAP);
        make.bottom.equalTo(self.contentView.mas_bottom).with.offset(-SMALLER_GAP);
    }];
}


- (void)configureUpperViewWithPFObject:(PFObject *)object{
    [self.mainView addSubview:self.upperView];
    [self.upperView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.mainView.mas_top).with.offset(MEDIUM_GAP);
        make.left.equalTo(self.mainView.mas_left).with.offset(MEDIUM_GAP);
        make.right.equalTo(self.mainView.mas_right).with.offset(-MEDIUM_GAP);
    }];
    
    self.portraitButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.portraitButton.translatesAutoresizingMaskIntoConstraints = NO;
    [self.portraitButton addTarget:self action:@selector(showPortrait:)forControlEvents:UIControlEventTouchUpInside];
    [self.portraitButton setBackgroundColor:[UIConstants getLightColor]];
    [self addSubview:self.portraitButton];
    
    [self.portraitButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.upperView);
        make.left.equalTo(self.upperView);
        make.height.equalTo(@(PORTRAIT_WIDTH));
        make.width.equalTo(@(PORTRAIT_WIDTH));
        make.bottom.equalTo(self.upperView);
    }];
    
    NSString *senderId = [object objectForKey:@"senderId"];
    NSString *key = [NSString stringWithFormat:@"%@.portrait",senderId];
    if ([diskCache hasObjectForKey:key]) {
        self.portrait = [diskCache objectForKey:key];
        UIImage *thumbnail = [diskCache objectForKey:[NSString stringWithFormat:@"%@.thumbnail",key]];
        [self.portraitButton setImage:thumbnail forState:UIControlStateNormal];
    }
}


- (void)configureMiddleCommentLabelWithPFObject:(PFObject *)object{
    NSArray *mediaDataArray = [object objectForKey:@"mediaData"];
    NSString *descriptionText = [object objectForKey:@"text"];
    self.middleCommentLabel.text = descriptionText;
    self.middleCommentLabel.font = [UIFont systemFontOfSize: COMMENT_LABEL_FONT_SIZE];
    self.middleCommentLabel.numberOfLines = 0;
    self.middleCommentLabel.textAlignment = NSTextAlignmentLeft;
    self.middleCommentLabel.lineBreakMode = NSLineBreakByWordWrapping;
    
    [self.mainView addSubview:self.middleCommentLabel];
    [self.middleCommentLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.upperView.mas_bottom).with.offset(MEDIUM_GAP);
        make.left.equalTo(self.mainView.mas_left).with.offset(MEDIUM_GAP);
        make.right.equalTo(self.mainView.mas_right).with.offset(-MEDIUM_GAP);
        if (mediaDataArray.count == 0){
            make.bottom.equalTo(self.mainView.mas_bottom).with.offset(-MEDIUM_GAP);
        }
    }];
}


- (void)configureLowerViewWithPFObject:(PFObject *)object{
    NSArray *mediaDataArray = [object objectForKey:@"mediaData"];
    [self.mainView addSubview:self.lowerView];
    [self.lowerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.middleCommentLabel.mas_bottom).with.offset(MEDIUM_GAP);
        make.left.equalTo(self.mainView.mas_left).with.offset(MEDIUM_GAP);
        make.right.equalTo(self.mainView.mas_right).with.offset(-MEDIUM_GAP);
        make.bottom.equalTo(self.mainView.mas_bottom).with.offset(-MEDIUM_GAP);
    }];
    
    CGFloat imageButtonWidth = [self getImageButtonWidth];
    
    self.MWPhotosArray = [NSMutableArray array];
    for (int i=0; i<mediaDataArray.count; ++i){
        [self.MWPhotosArray addObject:[NSNull null]];
    }
    
    imageManager = [SDWebImageManager sharedManager];
    
    for(int i=0; i<mediaDataArray.count; ++i){
        PFFile *file = mediaDataArray[i];
        
        UIButton *imageButton  = (UIButton *)self.arrayOfImageButtons[i];
        imageButton.hidden = NO;
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
            make.top.equalTo(self.lowerView.mas_top).with.offset(yOrigin);
            make.left.equalTo(self.lowerView.mas_left).with.offset(xOrigin);
            make.width.equalTo(@(imageButtonWidth));
            make.height.equalTo(@(imageButtonWidth));
            if(i == (mediaDataArray.count - 1)){
                make.bottom.equalTo(self.lowerView.mas_bottom);
            }
        }];
        
        [imageManager downloadImageWithURL:[NSURL URLWithString:file.url]
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
    }
    
    for(int i=mediaDataArray.count; i<9; ++i){
        UIButton *imageButton = (UIButton *)self.arrayOfImageButtons[i];
        imageButton.hidden = YES;
    }
}



- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (CGFloat)getImageButtonWidth{
    return (([UIScreen mainScreen].bounds.size.width - 2 * MEDIUM_GAP) - (NUMBER_OF_IMAGES_PER_ROW - 1) * SMALLER_GAP) / NUMBER_OF_IMAGES_PER_ROW;
}

@end


//
//        //configure portrait butotn,  use FMDB to store the portrait's url string
//        UIButton *portraitButton = [UIButton buttonWithType:UIButtonTypeCustom];
//        portraitButton.tag = indexPath.row;
//        portraitButton.translatesAutoresizingMaskIntoConstraints = NO;
//        [portraitButton addTarget:self action:@selector(showPortrait:)forControlEvents:UIControlEventTouchUpInside];
//        [portraitButton setBackgroundColor:[UIConstants getLightColor]];
//        [cell.contentView addSubview:portraitButton];
//
//        [portraitButton mas_makeConstraints:^(MASConstraintMaker *make) {
//            make.top.equalTo(cell.contentView.mas_top).with.offset(SMALL_GAP);
//            make.left.equalTo(cell.contentView.mas_left).with.offset(SMALL_GAP);
//            make.height.equalTo(@(PORTRAIT_WIDTH));
//            make.width.equalTo(@(PORTRAIT_WIDTH));
//        }];
//
//
//        //get FMDB
//        NSArray  *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
//        NSString *docsPath = [paths objectAtIndex:0];
//        NSString *dbPath = [docsPath stringByAppendingPathComponent:@"portrait.db"];
//        FMDatabase *db = [FMDatabase databaseWithPath:dbPath];
//        if(![db open]){
//            NSLog(@"can't open database in UITableViewCell");
//        }
//        FMResultSet *resultSet = [db executeQuery:@"select * from portrait where objectId= ?", senderId];
//        NSString *stringOfUrl;
//        NSMutableArray *urls = [NSMutableArray array];
//        int count = 0;
//        while ([resultSet next]) {
//            [urls addObject:[resultSet stringForColumn:@"url"]];
//            count++;
//        }
//        [db close];
//
//        if(urls.count > 0){
//            NSLog(@"Found portrait url in FMDB");
//            stringOfUrl = [urls lastObject];
//            [_stringOfPortraitUrls addObject:stringOfUrl];
//            UIImage *smallImage = [diskCache objectForKey:[NSString stringWithFormat:@"%@.small",stringOfUrl]];
//            dispatch_async(dispatch_get_main_queue(), ^{
//                [portraitButton setImage:smallImage forState:UIControlStateNormal];
//            });
//        }
//        else{                                          //FMDB doesn't have url
//            PFQuery *query = [PFUser query];
//            [query whereKey:@"objectId" equalTo: senderId];
//            [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error){
//                if(error){
//                    NSLog(@"Error: %@ %@", error, [error userInfo]);
//                }
//                else{
//                    PFUser *user = [objects lastObject];
//                    PFFile *file = [user objectForKey:@"image"];
//                    [_stringOfPortraitUrls addObject:file.url];
//
//                    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
//                    manager.responseSerializer = [AFImageResponseSerializer serializer];
//                    [manager GET:file.url parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
//                        UIImage *portrait;
//                        portrait = responseObject;
//                        if(portrait){
//                            UIImage *smallImage = [portrait imageByScalingAndCroppingForSize:CGSizeMake(45, 45)];
//                            [diskCache setObject:portrait forKey:file.url];
//                            [diskCache setObject:smallImage forKey:[NSString stringWithFormat:@"%@.small",file.url]];
//
//                            [db open];
//                            BOOL success;
//                            success = [db executeUpdate:@"insert into portrait(objectId,url) values(?,?)",_senderId, file.url];
//                            if (!success) {
//                                NSLog(@"%s: update table error: %@", __FUNCTION__, [db lastErrorMessage]);
//                            }
//                            [db close];
//
//
//                            dispatch_async(dispatch_get_main_queue(), ^{
//                                [portraitButton setImage:smallImage forState:UIControlStateNormal];
//                            });
//                        }
//                    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
//                        NSLog(@"AFNetworking error: %@",error);
//                    }];
//                }
//            }];
//        }
//
//
//
//
//        //configue  senderButton
//        UIButton *senderButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
//        [senderButton addTarget:self
//                         action:@selector(showSenderPosts:)
//               forControlEvents:UIControlEventTouchUpInside];
//        [senderButton setTitle:senderName forState:UIControlStateNormal];
//        [senderButton.titleLabel setFont:[UIFont systemFontOfSize:SENDER_BUTTON_FONT_SIZE]];
//        senderButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
//        senderButton.translatesAutoresizingMaskIntoConstraints = NO;
//        [cell.contentView addSubview:senderButton];
//
//        [senderButton mas_makeConstraints:^(MASConstraintMaker *make) {
//            make.top.equalTo(cell.contentView.mas_top).with.offset(SMALL_GAP);
//            make.left.equalTo(portraitButton.mas_right).with.offset(SMALL_GAP);
//            //button will fitToSize according to text length if there is no end boundary
//            //make.right.equalTo(cell.contentView.mas_right).with.offset(-SMALL_GAP);
//            make.height.equalTo(@(SENDER_BUTTON_HEIGHT));
//        }];
//
//        //disable sender button when posts for single user
//        if(self.senderId || self.currentUserPostsViewController){
//            senderButton.userInteractionEnabled = NO;
//        }
//
//
//
//
//
//
//        //configure commentLabel
//        UILabel *commentLabel = [[UILabel alloc]init];
//        commentLabel.text = descriptionText;
//        commentLabel.font = [UIFont systemFontOfSize: COMMENT_LABEL_FONT_SIZE];
//        commentLabel.numberOfLines = 0;
//        commentLabel.textAlignment = NSTextAlignmentLeft;
//        commentLabel.lineBreakMode = NSLineBreakByWordWrapping;
//        commentLabel.translatesAutoresizingMaskIntoConstraints = NO;
//        [cell.contentView addSubview:commentLabel];
//
//        [commentLabel mas_makeConstraints:^(MASConstraintMaker *make) {
//            make.top.equalTo(senderButton.mas_bottom).with.offset(SMALLER_GAP);
//            make.left.equalTo(portraitButton.mas_right).with.offset(SMALL_GAP);
//            make.right.equalTo(cell.contentView.mas_right).with.offset(-SMALL_GAP);
//        }];
//
//
//        //configure distance label
//        UILabel *distanceLabel = [[UILabel alloc]initWithFrame:CGRectZero];
//        CLLocation *postLocation = [[CLLocation alloc]initWithLatitude:postPosition.latitude longitude:postPosition.longitude];
//        CGFloat distance = [postLocation distanceFromLocation:_newLocation];
//        distanceLabel.text = [NSString stringWithFormat:@"%.1f miles from here.",distance/1609];
//        distanceLabel.font = [UIFont systemFontOfSize: DISTANCE_LABEL_FONT_SIZE];
//        distanceLabel.textColor = [UIConstants getLightColor];
//        [cell.contentView addSubview:distanceLabel];
//        [distanceLabel mas_makeConstraints:^(MASConstraintMaker *make) {
//            if(mediaDataArray.count == 0){
//                make.top.equalTo(commentLabel.mas_bottom).with.offset(SMALLER_GAP);
//            }
//            make.left.equalTo(portraitButton.mas_right).with.offset(SMALL_GAP);
//            make.right.equalTo(cell.contentView.mas_right).with.offset(-SMALL_GAP);
//            make.height.equalTo(@(DISTANCE_LABEL_HEIGHT));
//        }];
//
//
//
//
//
//        //configue image views
//        if(mediaDataArray != nil && mediaDataArray.count != 0){
//
//            PhotosView *photosView = [[PhotosView alloc]initWithFrame:CGRectZero WithMediaFileArray:mediaDataArray];
//            photosView.delegate = self;
//            photosView.tag = indexPath.row;
//            NSUInteger rows = (mediaDataArray.count + NUMBER_OF_IMAGES_PER_ROW -1) / NUMBER_OF_IMAGES_PER_ROW;
//            [cell.contentView addSubview:photosView];
//            [photosView mas_makeConstraints:^(MASConstraintMaker *make) {
//                make.top.equalTo(commentLabel.mas_bottom).with.offset(SMALL_GAP);
//                make.left.equalTo(portraitButton.mas_right).with.offset(SMALL_GAP);
//                make.right.equalTo(cell.contentView.mas_right);
//                make.height.equalTo(@(THUMBNAIL_WIDTH * rows + SMALL_GAP * (rows - 1)));
//                make.bottom.equalTo(distanceLabel.mas_top).with.offset(-SMALL_GAP);
//            }];
//        }
//
//
//        //configure date label
//        UILabel *dateLabel = [[UILabel alloc]initWithFrame:CGRectZero];
//        dateLabel.font = [UIFont systemFontOfSize: DATE_LABEL_FONT_SIZE];
//        dateLabel.textColor = [UIConstants getLightColor];
//        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
//        [dateFormatter setDateFormat:@"EEEE, MMMM d yyyy"];
//        dateLabel.text = [dateFormatter stringFromDate:date];
//        [cell.contentView addSubview:dateLabel];
//        [dateLabel mas_makeConstraints:^(MASConstraintMaker *make) {
//            make.top.equalTo(distanceLabel.mas_bottom).with.offset(SMALLER_GAP);
//            make.left.equalTo(portraitButton.mas_right).with.offset(SMALL_GAP);
//            make.right.equalTo(cell.contentView.mas_right).with.offset(-SMALL_GAP);
//            make.bottom.equalTo(cell.contentView.mas_bottom).with.offset(-SMALLER_GAP);
//            make.height.equalTo(@(DATE_LABEL_HEIGHT));
//        }];
