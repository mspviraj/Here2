//
//  SenderPostsController.m
//  mylocations
//
//  Created by Yang Lei on 5/26/15.
//  Copyright (c) 2015 Razeware LLC. All rights reserved.
//

#import "SenderPostsController.h"
#import "LocationsViewController.h"
#import "LocationDetailsViewController.h"
#import "UIImage+Resize.h"
#import "LocationSingleton.h"
#import "CustomCell.h"
#import "CustomCellForOneUser.h"
#import "PostDetailViewController.h"
#import "UserSingleton.h"



@interface SenderPostsController ()

@end

@implementation SenderPostsController
{
    CLLocation *_newLocation;
    NSArray *objectsFound;
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
    
    NSMutableArray *_rowHeights;
}





- (id)initWithCoder:(NSCoder *)aDecoder{
    if ((self = [super initWithCoder:aDecoder])){
        screen_width = CGRectGetWidth([UIScreen mainScreen].bounds);
        
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
    
    self.moviePlayer = [[MPMoviePlayerController alloc] init];
    
    PFUser *currentUser = [PFUser currentUser];
    if(currentUser){
        NSLog(@"current user: %@", currentUser.username);
    }
    else{
        [self performSegueWithIdentifier:@"showLogin" sender:self];
    }

    LocationSingleton *singleton = [LocationSingleton getInstance];
    _newLocation = [singleton getLocation];
    
}


- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    NSString *targetId;
    if(self.senderId != nil){
        targetId = self.senderId;
    }else{
        PFUser *currentUser = [PFUser currentUser];
        if(currentUser == nil)
            return;
        else{
            UserSingleton *singleton = [UserSingleton getInstance];
            PFUser *user = [singleton getUser];
            NSString *previousId = [user objectId];
            NSString *currentId = [currentUser objectId];
            NSLog(@"previousId and currentId are %@ and %@",previousId,currentId);
            if( (user == nil) || ![previousId isEqualToString:currentId]){
                [singleton setUser:currentUser];
            }
            else{
                return;
            }
        }
        targetId = [currentUser objectId];
        self.navigationItem.leftBarButtonItem = nil;
    }
    
    PFQuery *query = [PFQuery queryWithClassName:@"Messages"];
    [query whereKey:@"senderId" equalTo:targetId];
    [query orderByDescending:@"createdAt"];
    query.limit = 30;
    //objectsFound = [query findObjects];
    
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (error) {
            NSLog(@"Error: %@ %@", error, [error userInfo]);
        }
        else {
            // We found messages!
            objectsFound = objects;
            NSLog(@"Retrieved %lu messages", (unsigned long)objectsFound.count);
            
            //cache for cell height
            NSMutableArray *heights = [NSMutableArray new];
            for (int i = 0; i < objectsFound.count; i++){
                [heights addObject: [NSNull null]];
            }
            _rowHeights = heights;
            
            [self.tableView reloadData];
        }
    }];
}



- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if ([segue.identifier isEqualToString:@"showImage"]){
        ImageViewController *controller = (ImageViewController *)segue.destinationViewController;
        UITableViewCell *cell = (UITableViewCell *)[[sender superview]superview];
        NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
        //controller.object = objectsFound[indexPath.row];
        //NSLog(@"imageButton's supersuper view is %@",(UITableViewCell *)[[sender superview]superview]);
        
    } else if ([segue.identifier isEqualToString:@"showPostDetail"]){
        UINavigationController *navigationController = (UINavigationController *)segue.destinationViewController;
        PostDetailViewController *controller = (PostDetailViewController *)navigationController.topViewController;
        NSIndexPath *indexPath = [self.tableView indexPathForCell:sender];
        controller.object = objectsFound[indexPath.row];
    }
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}




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
    
    static NSString *cellIdentifier = @"Cell";
    CustomCellForOneUser *cell = (CustomCellForOneUser *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
    cell.currentLocation = _newLocation;
    [cell configureCellForPFObject:object];
    
    return cell;
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if([objectsFound count]==0)
        return 0;
    else{
        PFObject *object = objectsFound[indexPath.row];
        
        if ([NSNull null] == _rowHeights[indexPath.row]) {
            _rowHeights[indexPath.row] = [NSNumber numberWithFloat: [CustomCellForOneUser heightForPFObject:object]];
        }
        return [_rowHeights[indexPath.row] floatValue];
    }
}




- (IBAction)imageButtonPushed:(id)sender {
    UITableViewCell *cell = (UITableViewCell *)[[sender superview]superview];
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    PFObject *object = objectsFound[indexPath.row];
    
    _fileType = [object objectForKey:@"fileType"];
    if([_fileType isEqualToString:@"image"]){
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




- (IBAction)cancel:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}
@end
