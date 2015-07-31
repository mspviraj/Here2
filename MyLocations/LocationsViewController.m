//
//  LocationsViewController.m
//  MyLocations
//
//  Created by Matthijs on 15-10-13.
//  Copyright (c) 2013 Razeware LLC. All rights reserved.
//

#import "LocationsViewController.h"
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


@interface LocationsViewController ()

@end

@implementation LocationsViewController
{
    CLLocation *_newLocation;
    NSArray *objectsFound;
    
//    PFFile *_file;
//    NSString *_fileType;
//    NSString *_senderName;
//    NSString *_senderId;
//    NSString *_descriptionText;
//    NSString *_address;
//    NSString *_categoryName;
//    NSDate *_date;
//    UIImage *_image;
//    NSString *_videoFilePath;
    PFGeoPoint *_userPoint;
    
    NSMutableArray *_stringOfPortraitUrls;
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
    
    _stringOfPortraitUrls = [NSMutableArray array];
    self.moviePlayer = [[MPMoviePlayerController alloc] init];
    
    PFUser *currentUser = [PFUser currentUser];
    if(self.currentUserPostsViewController && !currentUser){
        [self performSegueWithIdentifier:@"showLogin" sender:self];
    }
    
    
    //get singleton location
    LocationSingleton *singleton = [LocationSingleton getInstance];
    _newLocation = [singleton getLocation];
    
    
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
    
    if(self.currentUserPostsViewController){
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
  else if ([segue.identifier isEqualToString:@"showImage"]){
      ImageViewController *controller = (ImageViewController *)segue.destinationViewController;
      controller.image = self.imageToImageViewController;
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


//PFFile *_file;
//NSString *_fileType;
//NSString *_senderName;
//NSString *_senderId;
//NSString *_descriptionText;
//NSString *_address;
//NSString *_categoryName;
//NSDate *_date;
//UIImage *_image;
//NSString *_videoFilePath;
//PFGeoPoint *_userPoint;
//NSString *title = [NSString stringWithFormat:@"Sent from %@", senderName];



- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    PFObject *object = objectsFound[indexPath.row];
    ISDiskCache *diskCache = [ISDiskCache sharedCache];
    NSArray *mediaDataArray = [object objectForKey:@"mediaData"];
    NSString  *mediaType = [object objectForKey:@"mediaType"];
    NSString *senderName = [object objectForKey:@"senderName"];
    NSString *senderId = [object objectForKey:@"senderId"];
    NSString *descriptionText = [object objectForKey:@"text"];
    NSString *address = [object objectForKey:@"address"];
    NSString *categoryName = [object objectForKey:@"category"];
    PFGeoPoint *postPosition = [object objectForKey:@"position"];
    NSDate *date = object.createdAt;
    CGFloat xBase = 61;

    
    
    static NSString *cellIdentifier = @"Cell";
    UITableViewCell *cell = (UITableViewCell *)[tableView dequeueReusableCellWithIdentifier:nil];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;

        
        
        
        
        //configure portrait butotn,  use FMDB to store the portrait's url string
        UIButton *portraitButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [cell.contentView addSubview:portraitButton];
        portraitButton.translatesAutoresizingMaskIntoConstraints = NO;
        
        [portraitButton addTarget:self action:@selector(showPortrait:)forControlEvents:UIControlEventTouchUpInside];
        [portraitButton setBackgroundColor:[UIColor lightGrayColor]];
        
        [cell.contentView addConstraint:[NSLayoutConstraint constraintWithItem:portraitButton attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:cell.contentView attribute:NSLayoutAttributeLeading multiplier:1 constant:8]];
        
        [cell.contentView addConstraint:[NSLayoutConstraint constraintWithItem:portraitButton attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:cell.contentView attribute:NSLayoutAttributeTop multiplier:1 constant:8]];
        
        [cell.contentView addConstraint:[NSLayoutConstraint constraintWithItem:portraitButton attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:0 multiplier:1 constant:45]];
        
        [cell.contentView addConstraint:[NSLayoutConstraint constraintWithItem:portraitButton attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:0 multiplier:1 constant:45]];
        
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
            [query whereKey:@"objectId" equalTo:_senderId];
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
        [senderButton.titleLabel setFont:[UIFont systemFontOfSize:18]];
        senderButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
        senderButton.translatesAutoresizingMaskIntoConstraints = NO;
        [cell.contentView addSubview:senderButton];

        [cell.contentView addConstraint:[NSLayoutConstraint constraintWithItem:senderButton attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:cell.contentView attribute:NSLayoutAttributeLeading multiplier:1 constant:xBase]];
        
        [cell.contentView addConstraint:[NSLayoutConstraint constraintWithItem:senderButton attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:cell.contentView attribute:NSLayoutAttributeTop multiplier:1 constant:8]];
        
        [cell.contentView addConstraint:[NSLayoutConstraint constraintWithItem:senderButton attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:cell.contentView attribute:NSLayoutAttributeTrailing multiplier:1 constant:-8]];
        
        [cell.contentView addConstraint:[NSLayoutConstraint constraintWithItem:senderButton attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:0 multiplier:1 constant:18]];
        
        
        
        
        //configure commentLabel
        UILabel *commentLabel = [[UILabel alloc]init];
        commentLabel.text = descriptionText;
        commentLabel.font = [UIFont systemFontOfSize:15];
        commentLabel.numberOfLines = 0;
        //commentLabel.baselineAdjustment = UIBaselineAdjustmentAlignBaselines; // or UIBaselineAdjustmentAlignCenters, or UIBaselineAdjustmentNone
        //commentLabel.adjustsFontSizeToFitWidth = YES;
        //commentLabel.minimumScaleFactor = 10.0f/12.0f;
        //commentLabel.clipsToBounds = YES;
        //commentLabel.textColor = [UIColor blackColor];
        commentLabel.textAlignment = NSTextAlignmentLeft;
        commentLabel.lineBreakMode = NSLineBreakByWordWrapping;
        commentLabel.translatesAutoresizingMaskIntoConstraints = NO;
        [cell.contentView addSubview:commentLabel];
        
        [cell.contentView addConstraint:[NSLayoutConstraint constraintWithItem:commentLabel attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:cell.contentView attribute:NSLayoutAttributeLeading multiplier:1 constant:xBase]];
        
        [cell.contentView addConstraint:[NSLayoutConstraint constraintWithItem:commentLabel attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:cell.contentView attribute:NSLayoutAttributeTop multiplier:1 constant:8 + 18 +4]];
        
        [cell.contentView addConstraint:[NSLayoutConstraint constraintWithItem:commentLabel attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:cell.contentView attribute:NSLayoutAttributeTrailing multiplier:1 constant:-8]];

        
        
        
        
        
        //configue image views
        for(int i=0; i<mediaDataArray.count; ++i){
            PFFile *file = mediaDataArray[i];
            
            UIButton *imageButton  = [UIButton buttonWithType:UIButtonTypeCustom];
            [imageButton addTarget:self action:@selector(showImage:) forControlEvents:UIControlEventTouchUpInside];
            imageButton.tag = i;
            [imageButton setBackgroundColor:[UIColor lightGrayColor]];
            imageButton.translatesAutoresizingMaskIntoConstraints = NO;
            [cell.contentView addSubview:imageButton];
            
            CGFloat xOrigin;
            CGFloat yOrigin;
            
            xOrigin = (i%3)*(80 +4);
            yOrigin = (i/3)*(80 +4);
            
            [cell.contentView addConstraint:[NSLayoutConstraint constraintWithItem:imageButton attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:cell.contentView attribute:NSLayoutAttributeLeading multiplier:1 constant:xBase + xOrigin]];
            
            [cell.contentView addConstraint:[NSLayoutConstraint constraintWithItem:imageButton attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:commentLabel attribute:NSLayoutAttributeBottom multiplier:1 constant:8 + yOrigin]];
            
            [cell.contentView addConstraint:[NSLayoutConstraint constraintWithItem:imageButton attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:0 multiplier:1 constant:80]];
            
            [cell.contentView addConstraint:[NSLayoutConstraint constraintWithItem:imageButton attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:0 multiplier:1 constant:80]];
            
            if(i == mediaDataArray.count-1){
                [cell.contentView addConstraint:[NSLayoutConstraint constraintWithItem:cell.contentView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:imageButton attribute:NSLayoutAttributeBottom multiplier:1 constant:8]];
            }
            
            // whether ISDiskCache has post images
            if ([diskCache hasObjectForKey:file.url]) {
                NSLog(@"ISDiskCache has %d th image",i);
                dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
                dispatch_async(queue, ^{
                    dispatch_async(dispatch_get_main_queue(), ^{
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
    [self performSegueWithIdentifier:@"showImage" sender:button];
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




@end
