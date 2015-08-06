//
//  LocationsViewController.m
//  MyLocations
//
//  Created by Matthijs on 15-10-13.
//  Copyright (c) 2013 Razeware LLC. All rights reserved.
//

#import "LocationsViewController.h"
#import "ImageViewController.h"
#import "LocationDetailsViewController.h"
#import "UIImage+Resize.h"
#import <Parse/Parse.h>
#import "LocationSingleton.h"
#import "CustomCell.h"
#import "SenderPostsController.h"
#import "PostDetailViewController.h"
#import "ISDiskCache.h"
#import "FMDB.h"
#import "AFNetworking.h"
#import "UIImage+ResizeAndCrop.h"
#import "Masonry.h"
#import "UIConstants.h"
#import "MWCommon.h"



@interface LocationsViewController ()

@property (nonatomic, strong) NSMutableArray *MWPhotosArrayOfArray;
@property (nonatomic, assign) NSUInteger chosenCellIndex;


@end

@implementation LocationsViewController
{
    CLLocation *_newLocation;
    NSArray *objectsFound;
    PFGeoPoint *_userPoint;
    NSMutableArray *_stringOfPortraitUrls;
    ISDiskCache *diskCache;

}


- (id)initWithCoder:(NSCoder *)aDecoder{
    if ((self = [super initWithCoder:aDecoder])){
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playerPlaybackDidFinish:) name:MPMoviePlayerPlaybackDidFinishNotification object:self.moviePlayer];
    }
    return self;
}



- (void) playerPlaybackDidFinish:(NSNotification*)notification{
    [self.moviePlayer setFullscreen:NO animated:YES];
}



- (void)viewDidLoad
{
  [super viewDidLoad];
    
    //set autolayout to calculate cell height
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.estimatedRowHeight = 44;
    
    //init disk cache
    diskCache = [ISDiskCache sharedCache];
    
    //get singleton location
    LocationSingleton *singleton = [LocationSingleton getInstance];
    _newLocation = [singleton getLocation];
    
    //init mwphoto array of array;
    self.MWPhotosArrayOfArray = [NSMutableArray array];
    
    _stringOfPortraitUrls = [NSMutableArray array];
    self.moviePlayer = [[MPMoviePlayerController alloc] init];

    
    PFUser *currentUser = [PFUser currentUser];
    if(self.currentUserPostsViewController && (currentUser == nil)){
        [self performSegueWithIdentifier:@"showLogin" sender:self];
    }
    
    //deal with it in viewWillAppear
    if(self.currentUserPostsViewController){
        [self.navigationItem.leftBarButtonItem setTitle:@"New Post"];
        return;
    }
    //deal with the other 3 circumstances
    else{
        PFQuery *query;
        query = [PFQuery queryWithClassName:@"Messages"];
        query.limit = 30;

        if(self.allPostsViewController){
            PFGeoPoint *userPosition = [PFGeoPoint geoPointWithLocation:_newLocation];
            [query whereKey:@"position" nearGeoPoint:userPosition withinMiles:200];
            self.navigationItem.leftBarButtonItem = nil;
            self.navigationItem.rightBarButtonItem = nil;
        }
        else if(self.senderId != nil){
            [query whereKey:@"senderId" equalTo:self.senderId];
            [query orderByDescending:@"createdAt"];
            self.navigationItem.rightBarButtonItem = nil;
        }
        else if(self.PFObjectFromMapView != nil){
            PFGeoPoint *postPosition = [self.PFObjectFromMapView objectForKey:@"position"];
            [query whereKey:@"position" nearGeoPoint:postPosition];
            self.navigationItem.rightBarButtonItem = nil;
        }
        
        //objectsFound = [query findObjects]; 这样写会很慢，因为占用了main thread
        [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
            if (error) {
                NSLog(@"Error: %@ %@", error, [error userInfo]);
            }
            else {
                // We found messages!
                objectsFound = objects;
                NSLog(@"Retrieved %lu messages", (unsigned long)objectsFound.count);
                
                //set the navigation bar title
                if(self.senderId != nil){
                    self.navigationItem.title = [[objectsFound lastObject] objectForKey:@"senderName"];
                }
                
                [self.tableView reloadData];
            }
        }];
    }

}


- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    if(self.currentUserPostsViewController && [PFUser currentUser]){
        PFQuery *query = [PFQuery queryWithClassName:@"Messages"];
        [query whereKey:@"senderId" equalTo:[[PFUser currentUser]objectId]];
        [query orderByDescending:@"createdAt"];
        query.limit = 30;
        
        [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
            if (error) {
                NSLog(@"Error: %@ %@", error, [error userInfo]);
            }
            else {
                // We found messages!
                objectsFound = objects;
                NSLog(@"Retrieved %lu messages", (unsigned long)objectsFound.count);

                [self.tableView reloadData];
            }
        }];
    }
    
}


- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
  if ([segue.identifier isEqualToString:@"showSenderPosts"]) {
      UINavigationController *navigationController = segue.destinationViewController;
      LocationsViewController *controller = (LocationsViewController *)navigationController.topViewController;
      UITableViewCell *cell = (UITableViewCell *)[[sender superview]superview];
      NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
      NSLog(@"senderId is %@",[objectsFound[indexPath.row] objectForKey:@"senderId"]);
      PFObject *object = objectsFound[indexPath.row];
      controller.senderId = [object objectForKey:@"senderId"];

  }
  else if ([segue.identifier isEqualToString:@"showPortrait"]){
      ImageViewController *controller = (ImageViewController *)segue.destinationViewController;
      UIButton *button = (UIButton *)sender;
      UIImage *image = [diskCache objectForKey:_stringOfPortraitUrls[button.tag]];
      controller.image = image;
  }
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}




//- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
//{
//}




- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [objectsFound count];
}



- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    PFObject *object = objectsFound[indexPath.row];
    NSArray *mediaDataArray = [object objectForKey:@"mediaData"];
    NSString  *mediaType = [object objectForKey:@"mediaType"];
    NSString *senderName = [object objectForKey:@"senderName"];
    NSString *senderId = [object objectForKey:@"senderId"];
    NSString *descriptionText = [object objectForKey:@"text"];
    NSString *address = [object objectForKey:@"address"];
    NSString *categoryName = [object objectForKey:@"category"];
    PFGeoPoint *postPosition = [object objectForKey:@"position"];
    NSDate *date = object.createdAt;
    
    static NSString *cellIdentifier = @"Cell";
    
    UITableViewCell *cell = (UITableViewCell *)[tableView dequeueReusableCellWithIdentifier:nil];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        //configure portrait butotn,  use FMDB to store the portrait's url string
        UIButton *portraitButton = [UIButton buttonWithType:UIButtonTypeCustom];
        portraitButton.tag = indexPath.row;
        portraitButton.translatesAutoresizingMaskIntoConstraints = NO;
        [portraitButton addTarget:self action:@selector(showPortrait:)forControlEvents:UIControlEventTouchUpInside];
        [portraitButton setBackgroundColor:[UIConstants getLightColor]];
        [cell.contentView addSubview:portraitButton];
        
        [portraitButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(cell.contentView.mas_top).with.offset(SMALL_GAP);
            make.left.equalTo(cell.contentView.mas_left).with.offset(SMALL_GAP);
            make.height.equalTo(@(PORTRAIT_WIDTH));
            make.width.equalTo(@(PORTRAIT_WIDTH));
        }];
        
        
        //get FMDB
        NSArray  *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *docsPath = [paths objectAtIndex:0];
        NSString *dbPath = [docsPath stringByAppendingPathComponent:@"portrait.db"];
        FMDatabase *db = [FMDatabase databaseWithPath:dbPath];
        if(![db open]){
            NSLog(@"can't open database in UITableViewCell");
        }
        FMResultSet *resultSet = [db executeQuery:@"select * from portrait where objectId= ?", senderId];
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
            [_stringOfPortraitUrls addObject:stringOfUrl];
            UIImage *smallImage = [diskCache objectForKey:[NSString stringWithFormat:@"%@.small",stringOfUrl]];
            dispatch_async(dispatch_get_main_queue(), ^{
                [portraitButton setImage:smallImage forState:UIControlStateNormal];
            });
        }
        else{                                          //FMDB doesn't have url
            PFQuery *query = [PFUser query];
            [query whereKey:@"objectId" equalTo: senderId];
            [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error){
                if(error){
                    NSLog(@"Error: %@ %@", error, [error userInfo]);
                }
                else{
                    PFUser *user = [objects lastObject];
                    PFFile *file = [user objectForKey:@"image"];
                    [_stringOfPortraitUrls addObject:file.url];
                    
                    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
                    manager.responseSerializer = [AFImageResponseSerializer serializer];
                    [manager GET:file.url parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
                        UIImage *portrait;
                        portrait = responseObject;
                        if(portrait){
                            UIImage *smallImage = [portrait imageByScalingAndCroppingForSize:CGSizeMake(45, 45)];
                            [diskCache setObject:portrait forKey:file.url];
                            [diskCache setObject:smallImage forKey:[NSString stringWithFormat:@"%@.small",file.url]];
                            
                            [db open];
                            BOOL success;
                            success = [db executeUpdate:@"insert into portrait(objectId,url) values(?,?)",_senderId, file.url];
                            if (!success) {
                                NSLog(@"%s: update table error: %@", __FUNCTION__, [db lastErrorMessage]);
                            }
                            [db close];
                            
                            
                            dispatch_async(dispatch_get_main_queue(), ^{
                                [portraitButton setImage:smallImage forState:UIControlStateNormal];
                            });
                        }
                    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                        NSLog(@"AFNetworking error: %@",error);
                    }];
                }
            }];
        }
        
        
        
        
        //configue  senderButton
        UIButton *senderButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        [senderButton addTarget:self
                   action:@selector(showSenderPosts:)
         forControlEvents:UIControlEventTouchUpInside];
        [senderButton setTitle:senderName forState:UIControlStateNormal];
        [senderButton.titleLabel setFont:[UIFont systemFontOfSize:SENDER_BUTTON_FONT_SIZE]];
        senderButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
        senderButton.translatesAutoresizingMaskIntoConstraints = NO;
        [cell.contentView addSubview:senderButton];
        
        [senderButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(cell.contentView.mas_top).with.offset(SMALL_GAP);
            make.left.equalTo(portraitButton.mas_right).with.offset(SMALL_GAP);
            //button will fitToSize according to text length if there is no end boundary
            //make.right.equalTo(cell.contentView.mas_right).with.offset(-SMALL_GAP);
            make.height.equalTo(@(SENDER_BUTTON_HEIGHT));
        }];
        
        //disable sender button when posts for single user
        if(self.senderId || self.currentUserPostsViewController){
            senderButton.userInteractionEnabled = NO;
        }
        
        
        
        

        
        //configure commentLabel
        UILabel *commentLabel = [[UILabel alloc]init];
        commentLabel.text = descriptionText;
        commentLabel.font = [UIFont systemFontOfSize: COMMENT_LABEL_FONT_SIZE];
        commentLabel.numberOfLines = 0;
        commentLabel.textAlignment = NSTextAlignmentLeft;
        commentLabel.lineBreakMode = NSLineBreakByWordWrapping;
        commentLabel.translatesAutoresizingMaskIntoConstraints = NO;
        [cell.contentView addSubview:commentLabel];
        
        [commentLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(senderButton.mas_bottom).with.offset(SMALLER_GAP);
            make.left.equalTo(portraitButton.mas_right).with.offset(SMALL_GAP);
            make.right.equalTo(cell.contentView.mas_right).with.offset(-SMALL_GAP);
        }];
        
        
        //configure distance label
        UILabel *distanceLabel = [[UILabel alloc]initWithFrame:CGRectZero];
        CLLocation *postLocation = [[CLLocation alloc]initWithLatitude:postPosition.latitude longitude:postPosition.longitude];
        CGFloat distance = [postLocation distanceFromLocation:_newLocation];
        distanceLabel.text = [NSString stringWithFormat:@"%.1f miles from here.",distance/1609];
        distanceLabel.font = [UIFont systemFontOfSize: DISTANCE_LABEL_FONT_SIZE];
        distanceLabel.textColor = [UIConstants getLightColor];
        [cell.contentView addSubview:distanceLabel];
        [distanceLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            if(mediaDataArray.count == 0){
                make.top.equalTo(commentLabel.mas_bottom).with.offset(SMALLER_GAP);
            }
            make.left.equalTo(portraitButton.mas_right).with.offset(SMALL_GAP);
            make.right.equalTo(cell.contentView.mas_right).with.offset(-SMALL_GAP);
            make.height.equalTo(@(DISTANCE_LABEL_HEIGHT));
        }];
        
        
        
        
        //configue image views
        NSMutableArray *MWPhotosOfPost = [[NSMutableArray alloc]initWithCapacity:mediaDataArray.count];
        
        for(int i=0; i<mediaDataArray.count; ++i){
            PFFile *file = mediaDataArray[i];
            
            UIButton *imageButton  = [UIButton buttonWithType:UIButtonTypeCustom];
            [imageButton addTarget:self action:@selector(showImage:) forControlEvents:UIControlEventTouchUpInside];
            imageButton.tag = i;
            [imageButton setBackgroundColor:[UIConstants getLightColor]];
            imageButton.translatesAutoresizingMaskIntoConstraints = NO;
            [cell.contentView addSubview:imageButton];
            
            CGFloat xOrigin;
            CGFloat yOrigin;
            
            xOrigin = (i % NUMBER_OF_IMAGES_PER_ROW) * (THUMBNAIL_WIDTH + SMALLER_GAP);
            yOrigin = (i / NUMBER_OF_IMAGES_PER_ROW)*(THUMBNAIL_WIDTH + SMALLER_GAP);
            
            [imageButton mas_makeConstraints:^(MASConstraintMaker *make) {
                make.top.equalTo(commentLabel.mas_bottom).with.offset(SMALL_GAP + yOrigin);
                make.left.equalTo(portraitButton.mas_right).with.offset(SMALL_GAP + xOrigin);
                make.width.equalTo(@(THUMBNAIL_WIDTH));
                make.height.equalTo(@(THUMBNAIL_WIDTH));
                if(i == mediaDataArray.count-1){
                    make.bottom.equalTo(distanceLabel.mas_top).with.offset(-SMALLER_GAP);
                }
            }];
            
            
            // whether ISDiskCache has post images
            if ([diskCache hasObjectForKey:file.url]) {
                NSLog(@"ISDiskCache has %d th image",i);
                dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
                dispatch_async(queue, ^{
                    dispatch_async(dispatch_get_main_queue(), ^{
                        UIImage *image = [diskCache objectForKey:file.url];
                        MWPhotosOfPost[i] = [MWPhoto photoWithImage:image];
                        
                        UIImage *smallImage = [diskCache objectForKey:[NSString stringWithFormat:@"%@.small",file.url]];
                        [imageButton setImage:smallImage forState:UIControlStateNormal];
                    });
                });
            }
            else{
                AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
                manager.responseSerializer = [AFImageResponseSerializer serializer];
                [manager GET:file.url parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
                    UIImage *image = responseObject;
                    MWPhotosOfPost[i] = [MWPhoto photoWithImage:image];

                    if(image){
                        UIImage *smallImage = [image imageByScalingAndCroppingForSize:CGSizeMake(80, 80)];
                        [diskCache setObject:image forKey:file.url];
                        [diskCache setObject:smallImage forKey:[NSString stringWithFormat:@"%@.small",file.url]];
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [imageButton setImage:smallImage forState:UIControlStateNormal];
                        });
                    }
                } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                    NSLog(@"AFNetworking error: %@",error);
                }];
            }
        }
        
        [self.MWPhotosArrayOfArray addObject:MWPhotosOfPost];
        
    
        
        //configure date label
        UILabel *dateLabel = [[UILabel alloc]initWithFrame:CGRectZero];
        dateLabel.font = [UIFont systemFontOfSize: DATE_LABEL_FONT_SIZE];
        dateLabel.textColor = [UIConstants getLightColor];
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"EEEE, MMMM d yyyy"];
        dateLabel.text = [dateFormatter stringFromDate:date];
        [cell.contentView addSubview:dateLabel];
        [dateLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(distanceLabel.mas_bottom).with.offset(SMALLER_GAP);
            make.left.equalTo(portraitButton.mas_right).with.offset(SMALL_GAP);
            make.right.equalTo(cell.contentView.mas_right).with.offset(-SMALL_GAP);
            make.bottom.equalTo(cell.contentView.mas_bottom).with.offset(-SMALLER_GAP);
            make.height.equalTo(@(DATE_LABEL_HEIGHT));
        }];
        
    }
    return cell;
}


- (void)showPortrait:(UIButton *)button{
    [self performSegueWithIdentifier:@"showPortrait" sender:button];
}


- (void)showSenderPosts:(UIButton *)button{
    [self performSegueWithIdentifier:@"showSenderPosts" sender:button];
}



- (void)showImage:(UIButton *)button{
    UITableViewCell *cell = (UITableViewCell *)[[button superview]superview];
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    self.chosenCellIndex = indexPath.row;
    
    MWPhotoBrowser *browser = [[MWPhotoBrowser alloc] initWithDelegate:self];
    browser.displayActionButton = NO;
    browser.displayNavArrows = NO;
    browser.displaySelectionButtons = NO;
    browser.alwaysShowControls = NO;
    browser.zoomPhotosToFill = YES;
    browser.enableGrid = NO;
    browser.startOnGrid = NO;
    browser.enableSwipeToDismiss = NO;
    [browser setCurrentPhotoIndex:button.tag];
    [self.navigationController pushViewController:browser animated:YES];
}


- (IBAction)logout:(id)sender {
    [PFUser logOut];
    [self performSegueWithIdentifier:@"showLogin" sender:self];
}



- (IBAction)goBackOrNewPost:(id)sender {
    if(self.currentUserPostsViewController){
        [self performSegueWithIdentifier:@"newPost" sender:nil];
    }
    else{
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}





- (IBAction)imageButtonPushed:(id)sender {
    UITableViewCell *cell = (UITableViewCell *)[[sender superview]superview];
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    PFObject *object = objectsFound[indexPath.row];
    
    NSString *fileType = [object objectForKey:@"fileType"];
    if([fileType isEqualToString:@"image"]){
        [self performSegueWithIdentifier:@"showImage" sender:sender];
    }
    else{
        //File type is video
        PFFile *videoFile = [object objectForKey:@"file"];
        NSURL *fileUrl = [NSURL URLWithString:videoFile.url];
        self.moviePlayer.contentURL = fileUrl;
        [self.moviePlayer prepareToPlay];
        [self.moviePlayer thumbnailImageAtTime:0 timeOption:MPMovieTimeOptionNearestKeyFrame];
        
        // Add it to the view controller so we can see it;
        [self.view addSubview:self.moviePlayer.view];
        [self.moviePlayer setFullscreen:YES animated:YES];
    }
}


#pragma mark - CustomCellDelegate methods

- (void)imageTapped:(UIImage *)image{
    self.imageToImageViewController = image;
    [self performSegueWithIdentifier:@"showImage" sender:self];
}

# pragma mark - MWPhotoBrowserDelegate
- (NSUInteger)numberOfPhotosInPhotoBrowser:(MWPhotoBrowser *)photoBrowser
{
    NSMutableArray *array = [self.MWPhotosArrayOfArray objectAtIndex:self.chosenCellIndex];
    return array.count;
}

- (id <MWPhoto>)photoBrowser:(MWPhotoBrowser *)photoBrowser
                photoAtIndex:(NSUInteger)index
{
    NSMutableArray *array = [self.MWPhotosArrayOfArray objectAtIndex:self.chosenCellIndex];
    if (index < array.count) {
        return [array objectAtIndex:index];
    }
    return nil;
}


@end
