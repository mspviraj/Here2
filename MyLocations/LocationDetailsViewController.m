//
//  LocationDetailsViewController.m
//  MyLocations
//
//  Created by Matthijs on 11-10-13.
//  Copyright (c) 2013 Razeware LLC. All rights reserved.
//

#import "LocationDetailsViewController.h"
#import "CategoryPickerViewController.h"
#import <MobileCoreServices/UTCoreTypes.h>
#import "UIImage+ResizeAndCrop.h"
#import "ImageViewController.h"

@interface LocationDetailsViewController () <UITextViewDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate>

@property (nonatomic, weak) IBOutlet UITextView *descriptionTextView;
@property (nonatomic, weak) IBOutlet UILabel *categoryLabel;
@property (nonatomic, weak) IBOutlet UILabel *latitudeLabel;
@property (nonatomic, weak) IBOutlet UILabel *longitudeLabel;
@property (nonatomic, weak) IBOutlet UILabel *addressLabel;
@property (nonatomic, weak) IBOutlet UILabel *dateLabel;

@end




@implementation LocationDetailsViewController
{
    CGFloat _screenWidth;
    CGFloat _screenHeight;
    NSString *_descriptionText;
    NSString *_address;
    NSString *_categoryName;
    NSDate *_date;
    
    UIImage *_image;
    NSMutableArray *_images;
    NSString *_videoFilePath;
    NSMutableArray *_mediaDataArray;

    UIActionSheet *_actionSheet;
    UIImagePickerController *_imagePicker;
    NSUInteger _scrollViewIndex;
}




- (id)initWithCoder:(NSCoder *)aDecoder
{
  if ((self = [super initWithCoder:aDecoder])) {
    _descriptionText = @"";
    _categoryName = @"No Category";
    _date = [NSDate date];
      
      
    [[NSNotificationCenter defaultCenter] addObserver:self
        selector:@selector(applicationDidEnterBackground)
        name:UIApplicationDidEnterBackgroundNotification
        object:nil];
  }
  return self;
}



- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}




- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _screenWidth = [[UIScreen mainScreen]bounds].size.width;
    _screenWidth = [[UIScreen mainScreen]bounds].size.height;
    
    _images = [NSMutableArray array];
    _mediaDataArray = [NSMutableArray array];
    
    _scrollViewIndex = 0;
    

    self.descriptionTextView.text = _descriptionText;
    self.categoryLabel.text = _categoryName;

    if (self.placemark != nil) {
        _address = [self stringFromPlacemark:self.placemark];
    } else {
        _address = @"No Address Found";
    }
    
    self.latitudeLabel.text = [NSString stringWithFormat:@"%.8f", self.coordinate.latitude];
    self.longitudeLabel.text = [NSString stringWithFormat:@"%.8f", self.coordinate.longitude];
    self.addressLabel.text = _address;

    self.dateLabel.text = [self formatDate:_date];

  UITapGestureRecognizer *gestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideKeyboard:)];
  gestureRecognizer.cancelsTouchesInView = NO;
  [self.tableView addGestureRecognizer:gestureRecognizer];
}





- (void)applicationDidEnterBackground {
    if (_imagePicker != nil) {
        [self dismissViewControllerAnimated:NO completion:nil];
        _imagePicker = nil;
    }
    if (_actionSheet != nil) {
        [_actionSheet dismissWithClickedButtonIndex:_actionSheet.cancelButtonIndex animated:NO];
        _actionSheet = nil;
    }
    [self.descriptionTextView resignFirstResponder];
}





- (void)hideKeyboard:(UIGestureRecognizer *)gestureRecognizer
{
  CGPoint point = [gestureRecognizer locationInView:self.tableView];
  NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:point];

  // If the user is tapping in the row with the text field, then we
  // don't want to hide the keyboard.

  if (indexPath != nil && indexPath.section == 0 && indexPath.row == 0) {
    return;
  }

  [self.descriptionTextView resignFirstResponder];
}



- (NSString *)stringFromPlacemark:(CLPlacemark *)placemark
{
  return [NSString stringWithFormat:@"%@ %@, %@, %@ %@, %@",
    placemark.subThoroughfare, placemark.thoroughfare,
    placemark.locality, placemark.administrativeArea,
    placemark.postalCode, placemark.country];
}



- (NSString *)formatDate:(NSDate *)theDate
{
  static NSDateFormatter *formatter = nil;
  if (formatter == nil) {
    formatter = [[NSDateFormatter alloc] init];
    [formatter setDateStyle:NSDateFormatterMediumStyle];
    [formatter setTimeStyle:NSDateFormatterShortStyle];
  }

  return [formatter stringFromDate:theDate];
}




- (IBAction)done:(id)sender
{
    if ([_descriptionText length]==0 &&  _image == nil && [_videoFilePath length] == 0) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Try again!"
            message:@"Please express what's in your mind or capture or select a photo or video to share!"
            delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alertView show];
    }
    else {
        [self uploadMessage];
        [self dismissViewControllerAnimated:YES completion:nil];
        //[self.tabBarController setSelectedIndex:1];
    }
}




- (IBAction)cancel:(id)sender
{
  [self closeScreen];
}



- (void)closeScreen
{
  [self dismissViewControllerAnimated:YES completion:nil];
}




- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
  if ([segue.identifier isEqualToString:@"PickCategory"]) {
    CategoryPickerViewController *controller = segue.destinationViewController;
    controller.selectedCategoryName = _categoryName;
  }else if([segue.identifier isEqualToString:@"showImage"]){
      UIButton *button = (UIButton *)sender;
      ImageViewController *controller = (ImageViewController *)segue.destinationViewController;
      controller.image = [_images objectAtIndex:button.tag];
  }
}



- (IBAction)categoryPickerDidPickCategory:(UIStoryboardSegue *)segue
{
  CategoryPickerViewController *viewController = segue.sourceViewController;
  _categoryName = viewController.selectedCategoryName;
  self.categoryLabel.text = _categoryName;
}



#pragma mark - UITableViewDelegate


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
  if (indexPath.section == 0 && indexPath.row == 0) {
          return 88;
  } else if (indexPath.section == 1 && indexPath.row == 0) {
      
      if(_scrollView.hidden){
          return 44;
      }else{
          return 48 + 180;
      }
      
  } else if (indexPath.section == 1 && indexPath.row == 3) {

      UIFont *font = [UIFont systemFontOfSize:15];
      CGSize constraint = CGSizeMake(150 ,NSUIntegerMax);
      NSDictionary *attributes = @{NSFontAttributeName: font};
      CGRect rect = [_address boundingRectWithSize:constraint
                                         options:(NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading)
                                      attributes:attributes 
                                         context:nil];
      return rect.size.height + 16;
  } else {
    return 44;
  }
}

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
  if (indexPath.section == 0 || indexPath.section == 1) {
    return indexPath;
  } else {
    return nil;
  }
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
  if (indexPath.section == 0 && indexPath.row == 0) {
    [self.descriptionTextView becomeFirstResponder];
  }
  else if (indexPath.section == 1 && indexPath.row == 0) {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    //[self showPhotoMenu];
  }
}


- (void)takePhoto {
    _imagePicker = [[UIImagePickerController alloc] init];
    _imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
    _imagePicker.delegate = self;
    _imagePicker.allowsEditing = YES;
    _imagePicker.videoMaximumDuration = 10;
    _imagePicker.mediaTypes = [UIImagePickerController availableMediaTypesForSourceType:_imagePicker.sourceType];
    [self presentViewController:_imagePicker animated:YES completion:nil];
}

- (void)choosePhotoFromLibrary {
    _imagePicker = [[UIImagePickerController alloc] init];
    _imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    _imagePicker.delegate = self;
    _imagePicker.allowsEditing = YES;
    [self presentViewController:_imagePicker animated:YES completion:nil];
}

- (void)showPhotoMenu {
    if ([UIImagePickerController isSourceTypeAvailable: UIImagePickerControllerSourceTypeCamera]) {
        _actionSheet = [[UIActionSheet alloc]initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil
            otherButtonTitles:@"Take Photo", @"Choose From Library", nil];
        [_actionSheet showInView:self.view];
    } else {
        [self choosePhotoFromLibrary];
    }
}

#pragma mark - UITextViewDelegate

- (BOOL)textView:(UITextView *)theTextView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
  _descriptionText = [theTextView.text stringByReplacingCharactersInRange:range withString:text];
  return YES;
}

- (void)textViewDidEndEditing:(UITextView *)theTextView
{
  _descriptionText = theTextView.text;
}



#pragma mark - UIImagePickerControllerDelegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    NSString *mediaType = [info objectForKey:UIImagePickerControllerMediaType];
    
    if ([mediaType isEqualToString:(NSString *)kUTTypeImage]) {
        // A photo was taken/selected!
        _image = [info objectForKey:UIImagePickerControllerOriginalImage];
    }
//    else {
//        // A video was taken/selected!
//        NSURL *imagePickerURL = [info objectForKey:UIImagePickerControllerMediaURL];
//        _videoFilePath = [imagePickerURL path];
//        if (_imagePicker.sourceType == UIImagePickerControllerSourceTypeCamera) {
//            // Save the video!
//            if (UIVideoAtPathIsCompatibleWithSavedPhotosAlbum(_videoFilePath)) {
//                UISaveVideoAtPathToSavedPhotosAlbum(_videoFilePath, nil, nil, nil);
//            }
//        }
//    }
    
    UIImage *resizedImage = [self resizeImage:_image toWidth:320.0f andHeight:480.0f];
    [_images addObject:resizedImage];
    [self showImage:resizedImage];
    [self.tableView reloadData];
    [self dismissViewControllerAnimated:YES completion:nil];
    _imagePicker = nil;
}


- (void)imagePickerControllerDidCancel: (UIImagePickerController *)picker
{
    [self dismissViewControllerAnimated:YES completion:nil];
    _imagePicker = nil;
}


#pragma mark - UIActionSheetDelegate
- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0) {
        [self takePhoto];
    } else if (buttonIndex == 1) {
        [self choosePhotoFromLibrary];
    }
    _actionSheet = nil;
}





#pragma mark - Helper methods

- (void)showImage:(UIImage *)image {
    if(self.scrollView.hidden){
        self.scrollView.hidden = NO;
    }
    CGFloat xOrigin =  _scrollViewIndex * (120 + 8);
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button addTarget:self action:@selector(showImageSegue:) forControlEvents:UIControlEventTouchUpInside];
    
    button.frame = CGRectMake(xOrigin, 0, 120, 180);
    UIImage *smallImage = [image imageByScalingAndCroppingForSize:button.frame.size];
    [button setImage:smallImage forState:UIControlStateNormal];
    
    button.tag = _scrollViewIndex;
    [self.scrollView addSubview:button];
    
    //set the scroll view content size
    _scrollViewIndex++;
    self.scrollView.contentSize = CGSizeMake((120 + 8)*_scrollViewIndex, 180);
    
    //let the new added photo always in view
    if(self.scrollView.contentSize.width > self.scrollView.frame.size.width){
        CGPoint endOffset = CGPointMake(self.scrollView.contentSize.width - self.scrollView.frame.size.width,0);
        [self.scrollView setContentOffset:endOffset];
    }

}


- (void)showImageSegue:(UIButton *)button{
    [self performSegueWithIdentifier:@"showImage" sender:button];
}





- (void)uploadMessage {
//    NSData *fileData;
//    NSString *fileName;
//    NSString *fileType;
    NSString *text;
    NSString *address;
    NSString *category;
    NSString *mediaType;
    PFGeoPoint *position;
    
    
    
//    if (_image != nil) {
//        UIImage *newImage = [self resizeImage:_image toWidth:320.0f andHeight:480.0f];
//        fileData = UIImagePNGRepresentation(newImage);
//        fileName = @"image.png";
//        fileType = @"image";
//    }
//    else {
//        fileData = [NSData dataWithContentsOfFile:_videoFilePath];
//        fileName = @"video.mov";
//        fileType = @"video";
//    }
    
    text = _descriptionText;
    address = _address;
    category = _categoryName;
    position = [PFGeoPoint geoPointWithLatitude:_coordinate.latitude longitude:_coordinate.longitude];
    mediaType = @"image";
    
    //PFFile *file = [PFFile fileWithName:fileName data:fileData];
    for(NSUInteger i=0; i<_images.count; ++i){
        NSData *fileData = UIImagePNGRepresentation(_images[i]);
        NSString *fileName = [NSString stringWithFormat:@"image%d",i];
        PFFile *file = [PFFile fileWithName:fileName data:fileData];
        [_mediaDataArray addObject:file];
    }
    
    
    PFObject *message = [PFObject objectWithClassName:@"Messages"];
    [message setObject:_mediaDataArray forKey:@"mediaData"];
    [message setObject:mediaType forKey:@"mediaType"];
    [message setObject:[[PFUser currentUser] objectId] forKey:@"senderId"];
    [message setObject:[[PFUser currentUser] username] forKey:@"senderName"];
    [message setObject:text forKey:@"text"];
    [message setObject:address forKey:@"address"];
    [message setObject:position forKey:@"position"];
    [message setObject:category forKey:@"category"];

    [message saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (error) {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"An error occurred!" message:@"Please try sending your message again." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alertView show];
        }
        else {
            // Everything was successful!
            [self reset];
        }
    }];

}


- (UIImage *)resizeImage:(UIImage *)image toWidth:(float)width andHeight:(float)height {
    CGSize newSize = CGSizeMake(width, height);
    CGRect newRectangle = CGRectMake(0, 0, width, height);
    UIGraphicsBeginImageContext(newSize);
    [_image drawInRect:newRectangle];
    UIImage *resizedImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return resizedImage;
}

- (void)reset {
    _image = nil;
    _videoFilePath = nil;
}


- (IBAction)addPhoto:(id)sender {
    [self showPhotoMenu];
}
@end
