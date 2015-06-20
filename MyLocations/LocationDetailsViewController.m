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

@interface LocationDetailsViewController () <UITextViewDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate>

@property (nonatomic, weak) IBOutlet UITextView *descriptionTextView;
@property (nonatomic, weak) IBOutlet UILabel *categoryLabel;
@property (nonatomic, weak) IBOutlet UILabel *latitudeLabel;
@property (nonatomic, weak) IBOutlet UILabel *longitudeLabel;
@property (nonatomic, weak) IBOutlet UILabel *addressLabel;
@property (nonatomic, weak) IBOutlet UILabel *dateLabel;
@property (nonatomic, weak) IBOutlet UIImageView *imageView;
@property (nonatomic, weak) IBOutlet UILabel *photoLabel;


@end

@implementation LocationDetailsViewController
{
    NSString *_descriptionText;
    NSString *_address;
    NSString *_categoryName;
    NSDate *_date;
    UIImage *_image;
    NSString *_videoFilePath;
    UIActionSheet *_actionSheet;
    UIImagePickerController *_imagePicker;
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
    if (_image == nil && [_videoFilePath length] == 0) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Try again!"
            message:@"Please capture or select a photo or video to share!"
            delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alertView show];
        
        _imagePicker = [[UIImagePickerController alloc] init];
        _imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
        _imagePicker.delegate = self;
        _imagePicker.allowsEditing = YES;
        _imagePicker.videoMaximumDuration = 10;
        _imagePicker.mediaTypes = [UIImagePickerController availableMediaTypesForSourceType:_imagePicker.sourceType];
        
        [self presentViewController:_imagePicker animated:NO completion:nil];
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
      if(self.imageView.hidden){
          return 44;
      }else{
          return 280;
      }
  } else if (indexPath.section == 2 && indexPath.row == 2) {

    // UILabels can display their content in multiple rows but this takes
    // some trickery. We first say to the label: this is your width, now
    // try to fit all the text in there (sizeToFit). This resizes both the
    // label's width and height.

    CGRect rect = CGRectMake(100, 10, 205, 10000);
    self.addressLabel.frame = rect;
    [self.addressLabel sizeToFit];

    // We want the width to remain at 205 points, so we resize the label
    // afterwards to the proper dimensions.
    rect.size.height = self.addressLabel.frame.size.height;
    self.addressLabel.frame = rect;

    return self.addressLabel.frame.size.height + 20;
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
    [self showPhotoMenu];
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
        if (_imagePicker.sourceType == UIImagePickerControllerSourceTypeCamera) {
            // Save the image!
            UIImageWriteToSavedPhotosAlbum(_image, nil, nil, nil);
        }
    }
    else {
        // A video was taken/selected!
        NSURL *imagePickerURL = [info objectForKey:UIImagePickerControllerMediaURL];
        _videoFilePath = [imagePickerURL path];
        if (_imagePicker.sourceType == UIImagePickerControllerSourceTypeCamera) {
            // Save the video!
            if (UIVideoAtPathIsCompatibleWithSavedPhotosAlbum(_videoFilePath)) {
                UISaveVideoAtPathToSavedPhotosAlbum(_videoFilePath, nil, nil, nil);
            }
        }
    }
    
    
    [self showImage:_image];
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
    self.imageView.image = image;
    self.imageView.hidden = NO;
    self.imageView.frame = CGRectMake(10, 10, 260, 260);
    self.photoLabel.hidden = YES;
}


- (void)uploadMessage {
    NSData *fileData;
    NSString *fileName;
    NSString *fileType;
    NSString *text;
    NSString *address;
    NSString *category;
    PFGeoPoint *position;
    
    
    if (_image != nil) {
        UIImage *newImage = [self resizeImage:_image toWidth:320.0f andHeight:480.0f];
        fileData = UIImagePNGRepresentation(newImage);
        fileName = @"image.png";
        fileType = @"image";
    }
    else {
        fileData = [NSData dataWithContentsOfFile:_videoFilePath];
        fileName = @"video.mov";
        fileType = @"video";
    }
    
    text = _descriptionText;
    address = _address;
    category = _categoryName;
    position = [PFGeoPoint geoPointWithLatitude:_coordinate.latitude longitude:_coordinate.longitude];
    
    PFFile *file = [PFFile fileWithName:fileName data:fileData];
    [file saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (error) {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"An error occurred!" message:@"Please try sending your message again."
            delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alertView show];
        }
        else {
            PFObject *message = [PFObject objectWithClassName:@"Messages"];
            [message setObject:file forKey:@"file"];
            [message setObject:fileType forKey:@"fileType"];
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


@end
