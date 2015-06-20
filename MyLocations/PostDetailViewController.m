//
//  PostDetailViewController.m
//  mylocations
//
//  Created by Yang Lei on 5/31/15.
//  Copyright (c) 2015 Razeware LLC. All rights reserved.
//

#import "PostDetailViewController.h"
#import "LocationSingleton.h"
#import "UIImage+ResizeAndCrop.h"
#import "SenderPostsController.h"
#import "SinglePostMapViewController.h"



@interface PostDetailViewController () <MKMapViewDelegate>

@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UIButton *senderButton;
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@property (weak, nonatomic) IBOutlet UILabel *addressLabel;
@property (weak, nonatomic) IBOutlet UILabel *distanceLabel;
@property (weak, nonatomic) IBOutlet UILabel *categoryLabel;
@property (weak, nonatomic) IBOutlet UILabel *commentLabel;
@property (weak, nonatomic) IBOutlet MKMapView *mapView;


@end



@implementation PostDetailViewController{
    CLLocation *_userLocation;
    NSMutableArray *_annotations;
    
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
    PFGeoPoint *_postPoint;
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


- (void)viewDidLoad {
    self.mapView.delegate = self;
    self.mapView.showsUserLocation = YES;

    _annotations = [NSMutableArray array];
    self.moviePlayer = [[MPMoviePlayerController alloc] init];
    

    //get singleton location
    LocationSingleton *singleton = [LocationSingleton getInstance];
    _userLocation = [singleton getLocation];
    
    _file = [self.object objectForKey:@"file"];
    _fileType = [self.object objectForKey:@"fileType"];
    _senderName = [self.object objectForKey:@"senderName"];
    _senderId = [self.object objectForKey:@"senderId"];
    _descriptionText = [self.object objectForKey:@"text"];
    _address = [self.object objectForKey:@"address"];
    _categoryName = [self.object objectForKey:@"category"];
    _postPoint = [self.object objectForKey:@"position"];
    _date = self.object.createdAt;
    
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
    
    CLLocation *postLocation = [[CLLocation alloc]initWithLatitude:_postPoint.latitude longitude:_postPoint.longitude];
    CGFloat distance = [postLocation distanceFromLocation:_userLocation];
    
    [_senderButton setTitle:_senderName forState:UIControlStateNormal];
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"EEEE, MMMM d yyyy"];
    self.dateLabel.text = [dateFormatter stringFromDate:_date];
    
    self.addressLabel.text = _address;
    self.commentLabel.text = _descriptionText;
    self.distanceLabel.text = [NSString stringWithFormat:@"%.1f miles from here.",distance/1609];
    self.categoryLabel.text = [NSString stringWithFormat:@"Category: %@",_categoryName];
    
    UIImage *smallImage = [_image imageByScalingAndCroppingForSize:self.imageView.frame.size];
    self.imageView.image = smallImage;
    
    
    //add annotations to map view
    MKPointAnnotation *annotation = [[MKPointAnnotation alloc]init];
    annotation.coordinate = CLLocationCoordinate2DMake(_postPoint.latitude, _postPoint.longitude);
    annotation.title = _senderName;
    annotation.subtitle = _categoryName;
    [_annotations addObject:annotation];
    [self.mapView addAnnotations:_annotations];
}


- (void)showPostLocationAroundUserLocation{
    CLLocationCoordinate2D postCoordinate = CLLocationCoordinate2DMake(_postPoint.latitude, _postPoint.longitude);
    CLLocationCoordinate2D userCoordinate = self.mapView.userLocation.coordinate;
    //MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(self.mapView.userLocation.coordinate, 1000, 1000);
    MKCoordinateRegion region = [self regionForPostCoordinate:postCoordinate aroundUserCoordinate:userCoordinate];
    [self.mapView setRegion:region animated:YES];
}



- (MKCoordinateRegion)regionForPostCoordinate:(CLLocationCoordinate2D)postCoordinate aroundUserCoordinate:(CLLocationCoordinate2D)userCoordinate{
    
    MKCoordinateRegion region;
    region.center.latitude = userCoordinate.latitude;
    region.center.longitude = userCoordinate.longitude;
    double const extraSpace = 1.3;
    region.span.latitudeDelta = fabs(postCoordinate.latitude - userCoordinate.latitude) * extraSpace * 2;
    region.span.longitudeDelta = fabs(postCoordinate.longitude - userCoordinate.longitude) * extraSpace * 2;
    return [self.mapView regionThatFits:region];
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if([segue.identifier isEqualToString:@"showSenderPosts"]){
        UINavigationController *navigationController = (UINavigationController *)segue.destinationViewController;
        SenderPostsController *controller = (SenderPostsController *)navigationController.topViewController;
        controller.senderId = _senderId;
    } else if ([segue.identifier isEqualToString:@"showImage"]){
        ImageViewController *controller = (ImageViewController *)segue.destinationViewController;
        controller.object = self.object;
    } else if ([segue.identifier isEqualToString:@"showMapView"]){
        UINavigationController *navigationController = (UINavigationController *)segue.destinationViewController;
        SinglePostMapViewController *controller = (SinglePostMapViewController *)navigationController.topViewController;
        controller.object = self.object;
    }
}



- (IBAction)goBack:(id)sender{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)imageTapped:(id)sender {
    if([_fileType isEqualToString:@"image"]){
        [self performSegueWithIdentifier:@"showImage" sender:sender];
    }
    else{
        //File type is video
        NSURL *fileUrl = [NSURL URLWithString:_file.url];
        self.moviePlayer.contentURL = fileUrl;
        [self.moviePlayer prepareToPlay];
        [self.moviePlayer thumbnailImageAtTime:0 timeOption:MPMovieTimeOptionNearestKeyFrame];
        
        // Add it to the view controller so we can see it;
        [self.view addSubview:self.moviePlayer.view];
        [self.moviePlayer setFullscreen:YES animated:YES];
    }
}

- (IBAction)mapTapped:(id)sender {
    [self performSegueWithIdentifier:@"showMapView" sender:self];
}





#pragma mark - mapView delegate

- (void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation{
    
    [self showPostLocationAroundUserLocation];
}


- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>)annotation
{
    if ([annotation isKindOfClass:[MKPointAnnotation class]]) {
        
        static NSString *identifier = @"Post";
        MKPinAnnotationView *annotationView = (MKPinAnnotationView *)[self.mapView dequeueReusableAnnotationViewWithIdentifier:identifier];
        if (annotationView == nil) {
            annotationView = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:identifier];
            //annotationView.enabled = YES;
            //annotationView.canShowCallout = YES;
            //annotationView.animatesDrop = NO;
            annotationView.pinColor = MKPinAnnotationColorGreen;
            
            //UIButton *rightButton = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
            //[rightButton addTarget:self action:@selector(showPostDetail:) forControlEvents:UIControlEventTouchUpInside];
            //annotationView.rightCalloutAccessoryView = rightButton;
        } else {
            annotationView.annotation = annotation;
        }
        return annotationView;
    }
    return nil;
}


- (void)showPostDetail:(UIButton *)button{
    [self dismissViewControllerAnimated:YES completion:nil];
}













@end
