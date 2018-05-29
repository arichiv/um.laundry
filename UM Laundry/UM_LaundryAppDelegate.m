//
//  UM_LaundryAppDelegate.m
//  UM Laundry
//
//  Created by Ari Chivukula on 9/10/13.
//  Copyright (c) 2013 Ari Chivukula. All rights reserved.
//

#import "UM_LaundryAppDelegate.h"
#import "UM_LaundryModel.h"
#import "UM_LaundryController.h"

@implementation UM_LaundryAppDelegate

@synthesize favorites;

-(BOOL) application:(UIApplication*)application didFinishLaunchingWithOptions:(NSDictionary*)launchOptions {
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    Item* item = [Item itemWithType:ItemBase code:0 name:nil status:MachineNone time:0 andFather:nil];
    UM_LaundryController* controller = [[UM_LaundryController alloc] initWithFather:item];
    self.window.rootViewController = [[UINavigationController alloc] initWithRootViewController: controller];
    favorites = [[Favorites alloc] init];
    [self.window makeKeyAndVisible];
    return YES;
}

-(void) applicationDidEnterBackground:(UIApplication*)application {
    Favorites* favoritesTemp = favorites;
    __block UIBackgroundTaskIdentifier background_task;
    background_task = [application beginBackgroundTaskWithExpirationHandler: ^ {
        [application endBackgroundTask: background_task];
        background_task = UIBackgroundTaskInvalid;
    }];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSLog(@"Starting Background Store");
        [favoritesTemp store];
        NSLog(@"Ending Background Store");
        [application endBackgroundTask: background_task];
        background_task = UIBackgroundTaskInvalid;
    });
}

-(void) application:(UIApplication*)application didReceiveLocalNotification:(UILocalNotification*)notification {
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:[notification alertBody] message:nil delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alertView show];
}

@end
