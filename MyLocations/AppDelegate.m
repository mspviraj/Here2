//
//  AppDelegate.m
//  MyLocations
//
//  Created by Matthijs on 08-10-13.
//  Copyright (c) 2013 Razeware LLC. All rights reserved.
//

#import "AppDelegate.h"
#import "LocationsViewController.h"
#import "MapViewController.h"
#import <Parse/Parse.h>
#import "FMDB.h"

NSString * const ManagedObjectContextSaveDidFailNotification = @"ManagedObjectContextSaveDidFailNotification";
@interface AppDelegate () <UIAlertViewDelegate>

@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    NSLog(@"didFinishLaunching first");
    // [Optional] Power your app with Local Datastore. For more info, go to
    // https://parse.com/docs/ios_guide#localdatastore/iOS
    [Parse enableLocalDatastore];
    
    // Initialize Parse.
    [Parse setApplicationId:@"OMxom3O8RM9G3NBedgoe5BL9UpeFujo0FzkQkjLA"
                  clientKey:@"1YRvI01aaIG7c6qRxLAAqV7lIqhijCHpGUwfFWJ1"];
    
    // [Optional] Track statistics around application opens.
    [PFAnalytics trackAppOpenedWithLaunchOptions:launchOptions];
    
    
    
    
    UITabBarController *tabBarController = (UITabBarController *)self.window.rootViewController;
    
    //set tab bar item title
    [[tabBarController.tabBar.items objectAtIndex:2] setTitle:@"My Posts"];
    
    UINavigationController *navController1 = (UINavigationController *)tabBarController.viewControllers[1];
    LocationsViewController *controller1 = (LocationsViewController *)navController1.viewControllers[0];
    controller1.allPostsViewController = YES;
    
    UINavigationController *navController2 = (UINavigationController *)tabBarController.viewControllers[2];
    LocationsViewController *controller2 = (LocationsViewController *)navController2.viewControllers[0];
    controller2.currentUserPostsViewController = YES;
    
    navController2.navigationItem.title = @"My Posts";
    
    
    
    
    NSArray  *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *docsPath = [paths objectAtIndex:0];
    NSString *dbPath = [docsPath stringByAppendingPathComponent:@"portrait.db"];
    NSLog(@"file path is: %@",docsPath);
    FMDatabase *db = [FMDatabase databaseWithPath:dbPath];
    
    if(![db open]){
        NSLog(@"Can't open and create database");
    }
    else{
        NSLog(@"create database successfully");
        BOOL success;
        success = [db executeUpdate:@"create table if not exists portrait (objectId text, url text)"];
        if (!success) {
            NSLog(@"%s: create table error: %@", __FUNCTION__, [db lastErrorMessage]);
        }
    }
    [db close];
    
    
  return YES;
}
							
- (void)applicationWillResignActive:(UIApplication *)application
{
	// Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
	// Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
	// Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
	// If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
	// Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
	// Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
	// Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}



#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)theAlertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
  abort();
}

@end
