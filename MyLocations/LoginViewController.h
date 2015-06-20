//
//  LoginViewController.h
//  mylocations
//
//  Created by Yang Lei on 5/7/15.
//  Copyright (c) 2015 Razeware LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LoginViewController : UIViewController

@property (weak, nonatomic) IBOutlet UITextField *usernameField;
@property (weak, nonatomic) IBOutlet UITextField *passwordField;


- (IBAction)login:(id)sender;


@end
