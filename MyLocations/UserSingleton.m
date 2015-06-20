//
//  UserSingleton.m
//  mylocations
//
//  Created by Yang Lei on 6/15/15.
//  Copyright (c) 2015 Razeware LLC. All rights reserved.
//

#import "UserSingleton.h"

@implementation UserSingleton

static UserSingleton *singletonInstance;

+ (UserSingleton *)getInstance{
    if(singletonInstance == nil){
        singletonInstance = [[super alloc]init];
    }
    return singletonInstance;
}

- (void)setUser:(PFUser *)newUser{
    user = newUser;
}


- (PFUser *)getUser{
    return user;
}

@end
