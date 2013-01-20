#import <Foundation/Foundation.h>
@class Controller;

typedef enum {
    ItemBase, ItemBuilding, ItemRoom, ItemMachine, ItemFavorites
} ItemType;

typedef enum {
    MachineNone, MachineAvailable, MachineRunning, MachineOffline
} MachineStatus;

@interface Item : NSObject {
    ItemType type;
    int code;
    NSString* name;
    MachineStatus status;
    int time;
    Item* father;
}

@property (readonly) ItemType type;
@property (readonly) int code;
@property (readonly, strong) NSString* name;
@property (readonly) MachineStatus status;
@property (readonly) int time;
@property (readonly, strong) Item* father;

-(id) initWithType:(ItemType)_type code:(int)_code name:(NSString*)_name status:(MachineStatus)_status time:(int)_time andFather:(Item*)_father;
-(NSString*) navTitle;
-(NSString*) cellText;
-(NSString*) cellDetail;
-(NSString*) cellDetailFavorite;
-(NSString*) alertTitle;
-(NSString*) alertMessage;

+(id) itemWithType:(ItemType)_type code:(int)_code name:(NSString*)_name status:(MachineStatus)_status time:(int)_time andFather:(Item*)_father;

@end

@interface Parser : NSObject {
    NSString* baseURL;
}

-(NSMutableArray*) getChildrenOfFather:(Item*)father;

@end

@interface Push : NSObject

+(void) addLocalNotificationWithMessage:(NSString*)m atTime:(int)t;

+(void) clearLocalNotifications;

@end

@interface Favorites : NSObject {
    NSMutableDictionary* favorites;
}

-(bool) checkFavorite:(Item*)room;
-(void) removeFavorite:(Item*)room;
-(void) addFavorite:(Item*)room;
-(NSMutableArray*) getFavorites;
-(void) clearFavorites;
-(void) store;

@end

@interface Model : NSObject {
    Item* father;
    NSMutableArray* items;
    Parser* parser;
    bool active;
}

@property (readonly) bool active;

-(id) initWithFather:(Item*)_father;
-(void) update;
-(NSMutableArray*) getItemsWithStatus:(MachineStatus)group;

@end
