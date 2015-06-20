//
//  SinglePostMapViewController.m
//  mylocations
//
//  Created by Yang Lei on 6/16/15.
//  Copyright (c) 2015 Razeware LLC. All rights reserved.
//

#import "SinglePostMapViewController.h"

@interface SinglePostMapViewController () <MKMapViewDelegate>

@end

@implementation SinglePostMapViewController{
    NSMutableArray *_annotations;

    NSString *_senderName;
    NSString *_categoryName;
    PFGeoPoint *_postPoint;
}



- (void)viewDidLoad {
    [super viewDidLoad];

    self.mapView.delegate = self;
    self.mapView.showsUserLocation = YES;
    
    _annotations = [NSMutableArray array];

    _senderName = [self.object objectForKey:@"senderName"];
    _categoryName = [self.object objectForKey:@"category"];
    _postPoint = [self.object objectForKey:@"position"];
    
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



/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/


- (void)closeScreen{
    [self dismissViewControllerAnimated:YES completion:nil];
}


- (IBAction)goBack:(id)sender {
    [self closeScreen];
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
            annotationView.enabled = YES;
            annotationView.canShowCallout = YES;
            annotationView.animatesDrop = NO;
            annotationView.pinColor = MKPinAnnotationColorGreen;
            
            UIButton *rightButton = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
            [rightButton addTarget:self action:@selector(showPostDetail:) forControlEvents:UIControlEventTouchUpInside];
            annotationView.rightCalloutAccessoryView = rightButton;
        } else {
            annotationView.annotation = annotation;
        }
        return annotationView;
    }
    return nil;
}



- (void)showPostDetail:(UIButton *)button{
    [self closeScreen];
}






@end
