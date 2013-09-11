//
//  UM_LaundryAppDelegate.h
//  UM Laundry
//
//  Created by Ari Chivukula on 9/10/13.
//  Copyright (c) 2013 Ari Chivukula. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Favorites;

@interface UM_LaundryAppDelegate : UIResponder <UIApplicationDelegate> {
    Favorites* favorites;
}

@property (strong, nonatomic) UIWindow *window;
@property (strong, readonly) Favorites* favorites;

@end
