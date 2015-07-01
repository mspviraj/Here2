//
//  PracticeViewController.m
//  MyLocations
//
//  Created by Yang Lei on 6/23/15.
//  Copyright (c) 2015 Razeware LLC. All rights reserved.
//

#import "PracticeViewController.h"
#import <Parse/Parse.h>
#import "FMDB.h"

@interface PracticeViewController ()

@end

@implementation PracticeViewController{
    NSArray *objectsFound;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSArray  *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *docsPath = [paths objectAtIndex:0];
    NSString *dbPath = [docsPath stringByAppendingPathComponent:@"test.db"];
    NSLog(@"file path is: %@",docsPath);
    FMDatabase *db = [FMDatabase databaseWithPath:dbPath];
//    if (![db open]) {
//        return;
//    }
    [db open];
    
    
    
    BOOL success;
    success = [db executeUpdate:@"create table if not exists test (objectId text, address text, category text, fileType text, latitude double, longitude double, comment text, senderId text, senderName text, date double)"];
    if (!success) {
        NSLog(@"%s: create table error: %@", __FUNCTION__, [db lastErrorMessage]);
    }
    
    
    

    PFQuery *query = [PFQuery queryWithClassName:@"Messages"];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (error) {
            NSLog(@"Error: %@ %@", error, [error userInfo]);
        }
        else {
            // We found messages!
            objectsFound = objects;
            NSLog(@"Retrieved %lu messages", (unsigned long)objectsFound.count);
            
            for (int i=0; i<[objectsFound count]; ++i) {
                PFObject *object = objectsFound[i];
                PFGeoPoint *position = [object objectForKey:@"position"];
                NSDate *date = object.createdAt;
                BOOL success;
                success = [db executeUpdate:@"insert into test(objectId, address, category, fileType, latitude, longitude, comment, senderId, senderName, date) values (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)",
                           object.objectId,
                           [object objectForKey:@"address"],
                           [object objectForKey:@"category"],
                           [object objectForKey:@"fileType"],
                           [NSNumber numberWithFloat: position.latitude],
                           [NSNumber numberWithFloat: position.longitude],
                           [object objectForKey:@"text"],
                           [object objectForKey:@"senderId"],
                           [object objectForKey:@"senderName"],
                           date
                           ];
                if (!success) {
                    NSLog(@"%s: insert error: %@", __FUNCTION__, [db lastErrorMessage]);
                    
                    // do whatever you need to upon error
                }
            }
        }
    }];
    
    FMResultSet *resultSet = [db executeQuery:@"select address FROM test where senderId= ?",@"b5FFiQwde6"];
//    while ([resultSet next]) {
//        NSLog(@"address is %@",resultSet[0]);
//        
//    }
    if([resultSet next]){
        NSLog(@"found it");
    }
    else{
        NSLog(@"found nothing");
    }

    [db close];
    

    
    
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

@end
