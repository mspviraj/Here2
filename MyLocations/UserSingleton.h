//
//  UserSingleton.h
//  mylocations
//
//  Created by Yang Lei on 6/15/15.
//  Copyright (c) 2015 Razeware LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Parse/Parse.h>

@interface UserSingleton : NSObject{
    PFUser *user;
}


+ (UserSingleton *) getInstance;

- (void)setUser:(PFUser *)newUser;

- (PFUser *)getUser;

@end
