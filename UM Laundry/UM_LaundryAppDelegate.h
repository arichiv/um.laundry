#import <UIKit/UIKit.h>

@class Favorites;

@interface UM_LaundryAppDelegate : UIResponder <UIApplicationDelegate> {
    Favorites* favorites;
}

@property (strong, nonatomic) UIWindow *window;
@property (strong, readonly) Favorites* favorites;

@end
