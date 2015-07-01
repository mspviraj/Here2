//
//  MapViewController.m
//  MyLocations
//
//  Created by Matthijs on 16-10-13.
//  Copyright (c) 2013 Razeware LLC. All rights reserved.
//

#import "MapViewController.h"
#import "LocationDetailsViewController.h"
#import "LocationSingleton.h"
#import "PostDetailViewController.h"

@interface MapViewController () <MKMapViewDelegate, UINavigationBarDelegate>

@property (nonatomic, weak) IBOutlet MKMapView *mapView;

@end

@implementation MapViewController
{
    NSArray *objectsFound;
    
    //pass to the locationsViewController, no use for this mapView
    CLLocationManager *_locationManager;
    CLLocation *_location;

    BOOL _updatingLocation;
    NSError *_lastLocationError;
    
    
    //pass to the locationsViewController, no use for this mapView
    CLGeocoder *_geocoder;
    CLPlacemark *_placemark;
    BOOL _performingReverseGeocoding;
    NSError *_lastGeocodingError;
    
    //for this mapView
    CLLocation *_userLocationFromMapView;
    NSMutableArray *_annotations;
    UIBarButtonItem *_rightBar;
}



- (id)initWithCoder:(NSCoder *)aDecoder
{
  if ((self = [super initWithCoder:aDecoder]))
  {
      _locationManager = [[CLLocationManager alloc] init];
      _geocoder = [[CLGeocoder alloc] init];
      _annotations = [NSMutableArray array];
      [self startLocationManager];
      
  }
  return self;
}



- (void)dealloc
{
  [[NSNotificationCenter defaultCenter] removeObserver:self];
}






- (void)viewDidLoad
{
  [super viewDidLoad];
    
    
//  [self updateLocations];
//
//  if ([objectsFound count] > 0) {
//    [self showLocations];
//  }
    
}


- (void)updateLocations{
    if (objectsFound != nil) {
        [self.mapView removeAnnotations:objectsFound];
    }
    
    PFQuery *query = [PFQuery queryWithClassName:@"Messages"];
    NSLog(@"mapView.userLocation is %@",self.mapView.userLocation.location);
    PFGeoPoint *point = [PFGeoPoint geoPointWithLocation:self.mapView.userLocation.location];
    [query whereKey:@"position" nearGeoPoint:point withinMiles:200];
    query.limit = 30;
    
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (error) {
            NSLog(@"Error: %@ %@", error, [error userInfo]);
        }
        else {
            // We found messages!
            objectsFound = objects;
            NSLog(@"Retrieved %lu messages", (unsigned long)objectsFound.count);
            
            for(PFObject *object in objectsFound){
                MKPointAnnotation *annotation = [[MKPointAnnotation alloc]init];
                PFGeoPoint *point = [object objectForKey:@"position"];
                annotation.coordinate = CLLocationCoordinate2DMake(point.latitude, point.longitude);
                annotation.title = [object objectForKey:@"senderName"];
                annotation.subtitle = [object objectForKey:@"category"];
                [_annotations addObject:annotation];
            }
            NSLog(@"%lu annotations added",(unsigned long)[_annotations count]);
            
            if([_annotations count] > 0){
                [self.mapView addAnnotations:_annotations];
                [self showLocations];
            }
        }
    }];
}


- (void)showLocations
{
    MKCoordinateRegion region = [self regionForAnnotations:_annotations];
    [self.mapView setRegion:region animated:YES];
}



- (MKCoordinateRegion)regionForAnnotations:(NSArray *)annotations
{
    MKCoordinateRegion region;
    
    if ([annotations count] == 0) {
        region = MKCoordinateRegionMakeWithDistance(self.mapView.userLocation.coordinate, 1000, 1000);
        
    } else if ([annotations count] == 1) {
        id <MKAnnotation> annotation = [annotations lastObject];
        region = MKCoordinateRegionMakeWithDistance(annotation.coordinate, 1000, 1000);
        
    } else {
        CLLocationCoordinate2D topLeftCoord;
        topLeftCoord.latitude = -90;
        topLeftCoord.longitude = 180;
        
        CLLocationCoordinate2D bottomRightCoord;
        bottomRightCoord.latitude = 90;
        bottomRightCoord.longitude = -180;
        
        for (id <MKAnnotation> annotation in annotations) {
            topLeftCoord.latitude = fmax(topLeftCoord.latitude, annotation.coordinate.latitude);
            topLeftCoord.longitude = fmin(topLeftCoord.longitude, annotation.coordinate.longitude);
            bottomRightCoord.latitude = fmin(bottomRightCoord.latitude, annotation.coordinate.latitude);
            bottomRightCoord.longitude = fmax(bottomRightCoord.longitude, annotation.coordinate.longitude);
        }
        
        const double extraSpace = 1.1;
        region.center.latitude = topLeftCoord.latitude - (topLeftCoord.latitude - bottomRightCoord.latitude) / 2.0;
        region.center.longitude = topLeftCoord.longitude - (topLeftCoord.longitude - bottomRightCoord.longitude) / 2.0;
        region.span.latitudeDelta = fabs(topLeftCoord.latitude - bottomRightCoord.latitude) * extraSpace;
        region.span.longitudeDelta = fabs(topLeftCoord.longitude - bottomRightCoord.longitude) * extraSpace;
    }
    
    return [self.mapView regionThatFits:region];
}




- (IBAction)showUser
{
  MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(self.mapView.userLocation.coordinate, 1000, 1000);
  [self.mapView setRegion:[self.mapView regionThatFits:region] animated:YES];
}


- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([segue.identifier isEqualToString:@"newPost"]){
      UINavigationController *navigationController = segue.destinationViewController;
      LocationDetailsViewController *controller = (LocationDetailsViewController *)navigationController.topViewController;
      controller.coordinate = _location.coordinate;
      controller.placemark = _placemark;
    }else if([segue.identifier isEqualToString:@"showPostDetail"]){
        UINavigationController *navigationController = segue.destinationViewController;
        PostDetailViewController *controller = (PostDetailViewController *)navigationController.topViewController;
        UIButton *button = (UIButton *)sender;
        controller.object = objectsFound[button.tag];
    }
}





- (void)contextDidChange:(NSNotification *)notification
{
  if ([self isViewLoaded]) {
    [self updateLocations];
  }
}

#pragma mark - MKMapViewDelegate

- (void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation{
    if(_userLocationFromMapView == nil){
        _userLocationFromMapView = self.mapView.userLocation.location;
        [self updateLocations];
    }
    
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

    UIButton *button = (UIButton *)annotationView.rightCalloutAccessoryView;
    button.tag = [_annotations indexOfObject:(MKPointAnnotation *)annotation];

    return annotationView;
  }

  return nil;
}


- (void)showPostDetail:(UIButton *)button
{
    [self performSegueWithIdentifier:@"showPostDetail" sender:button];
}



#pragma mark - UINavigationBarDelegate

- (UIBarPosition)positionForBar:(id <UIBarPositioning>)bar
{
  return UIBarPositionTopAttached;
}


#pragma mark - CLLocationManagerDelegate

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    NSLog(@"didFailWithError %@", error);

    if (error.code == kCLErrorLocationUnknown) {
        return;
    }
    
    [self stopLocationManager];
    _lastLocationError = error;
}



- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    CLLocation *newLocation = [locations lastObject];
    
    //set global data to singleton
    LocationSingleton *singleton = [LocationSingleton getInstance];
    [singleton setLocation:newLocation];
    
    NSLog(@"didUpdateLocations %@", newLocation);
    
    // If the time at which the new location object was determined is too long
    // ago (5 seconds in this case), then this is a cached result. We'll ignore
    // these cached locations because they may be out of date.
    if ([newLocation.timestamp timeIntervalSinceNow] < -5.0) {
        return;
    }
    
    // Ignore invalid measurements.
    if (newLocation.horizontalAccuracy < 0) {
        return;
    }
    
    // Calculate the distance between the new reading and the old one. If this
    // is the first reading then there is no previous location to compare to
    // and we set the distance to a very large number (MAXFLOAT).
    CLLocationDistance distance = MAXFLOAT;
    if (_location != nil) {
        distance = [newLocation distanceFromLocation:_location];
    }
    
    // Only perform the following code if the new location provides a more
    // precise reading than the previous one, or if it's the very first.
    if (_location == nil || _location.horizontalAccuracy > newLocation.horizontalAccuracy) {
        
        // Put the new coordinates on the screen.
        _lastLocationError = nil;
        _location = newLocation;
        [self updateLabels];
        
        // We're done if the new location is accurate enough.
        if (newLocation.horizontalAccuracy <= _locationManager.desiredAccuracy) {
            NSLog(@"*** We're done!");
            [self stopLocationManager];
            // We'll force a reverse geocoding for this final result if we
            // haven't already done this location.
            if (distance > 0) {
                _performingReverseGeocoding = NO;
            }
        }
        
        // We're not supposed to perform more than one reverse geocoding
        // request at once, so only continue if we're not already busy.
        if (!_performingReverseGeocoding) {
            NSLog(@"*** Going to geocode");
            
            // Start a new reverse geocoding request and update the screen
            // with the results (a new placemark or error message).
            _performingReverseGeocoding = YES;
            [_geocoder reverseGeocodeLocation:_location completionHandler:^(NSArray *placemarks, NSError *error) {
                NSLog(@"*** Found placemarks: %@, error: %@", placemarks, error);
                
                _lastGeocodingError = error;
                if (error == nil && [placemarks count] > 0) {
                    _placemark = [placemarks lastObject];
                } else {
                    _placemark = nil;
                }
                
                _performingReverseGeocoding = NO;
                [self updateLabels];
            }];
        }
        
        // If the distance did not change significantly since last time and it has
        // been a while since we've received the previous reading (10 seconds) then
        // assume this is the best it's going to be and stop fetching the location.
    } else if (distance < 1.0) {
        NSTimeInterval timeInterval = [newLocation.timestamp timeIntervalSinceDate:_location.timestamp];
        if (timeInterval > 10) {
            NSLog(@"*** Force done!");
            [self stopLocationManager];
            [self updateLabels];
        }
    }
}


- (NSString *)stringFromPlacemark:(CLPlacemark *)thePlacemark
{
    return [NSString stringWithFormat:@"%@ %@\n%@ %@ %@",
            thePlacemark.subThoroughfare, thePlacemark.thoroughfare,
            thePlacemark.locality, thePlacemark.administrativeArea,
            thePlacemark.postalCode];
}



- (void)updateLabels
{
    if (_location != nil) {
        self.postButton.enabled = YES;
    } else {
        self.postButton.enabled = NO;
    }
}



- (void)startLocationManager
{
    if ([CLLocationManager locationServicesEnabled]) {
        _locationManager.delegate = self;
        _locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters;
        [_locationManager requestWhenInUseAuthorization];
        [_locationManager startUpdatingLocation];
        _updatingLocation = YES;

        [self performSelector:@selector(didTimeOut:) withObject:nil afterDelay:60];
    }
}

- (void)stopLocationManager
{
    if (_updatingLocation) {
        [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(didTimeOut:) object:nil];
        
        [_locationManager stopUpdatingLocation];
        _locationManager.delegate = nil;
        _updatingLocation = NO;
    }
}


- (void)didTimeOut:(id)obj
{
    NSLog(@"*** Time out");
    
    // We get here whether we've obtained a location or not. If there no
    // location was obtained by this time, then we stop the location manager
    // from giving us updates and we'll show an error message to the user.
    if (_location == nil) {
        [self stopLocationManager];
        
        // Create an NSError object so that the UI shows an error message.
        _lastLocationError = [NSError errorWithDomain:@"MyLocationsErrorDomain" code:1 userInfo:nil];
        
        [self updateLabels];
    }
}



- (IBAction)newPost:(id)sender;{
    PFUser *currentUser = [PFUser currentUser];
    if(currentUser){
        [self performSegueWithIdentifier:@"newPost" sender:self];
    }else{
        [self performSegueWithIdentifier:@"goToLogin" sender:nil];
        //self.tabBarController.selectedIndex = 1;
    }
}





@end
