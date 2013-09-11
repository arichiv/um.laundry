//
//  UM_LaundryModel.m
//  UM Laundry
//
//  Created by Ari Chivukula on 9/10/13.
//  Copyright (c) 2013 Ari Chivukula. All rights reserved.
//

#import "UM_LaundryModel.h"
#import "UM_LaundryController.h"

@implementation Item

@synthesize type, code, name, status, time, father;

-(id) initWithType:(ItemType)_type code:(int)_code name:(NSString*)_name status:(MachineStatus)_status time:(int)_time andFather:(Item*)_father {
    self = [super init];
    type = _type;
    code = _code;
    name = _name;
    status = _status;
    time = _time;
    father = _father;
    return self;
}

-(NSString *) description {
    NSString* string = nil;
    if (type == ItemBuilding)
        string = [[NSString alloc] initWithFormat:@"Building: %i-%@ ", code, name];
    else if (type == ItemRoom)
        string = [[NSString alloc] initWithFormat:@"Room: %i-%@ %@", code, name, father];
    else if (type == ItemMachine)
        string = [[NSString alloc] initWithFormat:@"Machine: %i-%@ %i-%i %@", code, name, status, type, father];
    return string;
}


-(NSString*) navTitle {
    if (type == ItemBase)
        return @"Buildings";
    return name;
}

-(NSString*) cellText {
    if (type == ItemMachine)
        return [[NSString alloc] initWithFormat:@"%@ #%i", name, code];
    return name;
}

-(NSString*) cellDetail {
    if (type == ItemMachine) {
        if (status == MachineAvailable)
            return [[NSString alloc] initWithFormat:@"Available"];
        else if (status == MachineRunning) {
            if (time == 1)
                return [[NSString alloc] initWithFormat:@"Running, 1 minute left"];
            else
                return [[NSString alloc] initWithFormat:@"Running, %i minutes left", time];
        }
        else if (status == MachineOffline)
            return [[NSString alloc] initWithFormat:@"Offline"];
    }
    return nil;
}

-(NSString*) cellDetailFavorite {
    if (type == ItemRoom) {
        return [father name];
    }
    return nil;
}

-(NSString*) alertTitle {
    if (type == ItemMachine) {
        if (status == MachineRunning) {
            if (time == 1)
                return [[NSString alloc] initWithFormat:@"Remind in 1 minute?"];
            else
                return [[NSString alloc] initWithFormat:@"Remind in %i minutes?", time];
        }
    }
    return nil;
}

-(NSString*) alertMessage {
    if (![[father name] isEqualToString:@"All"])
        return [[NSString alloc] initWithFormat:@"%@: %@ %@ #%i", [[father father] name], [father name], name, code];
    return [[NSString alloc] initWithFormat:@"%@: %@ #%i", [[father father] name], name, code];
}

+(id) itemWithType:(ItemType)_type code:(int)_code name:(NSString*)_name status:(MachineStatus)_status time:(int)_time andFather:(Item*)_father {
    return [[Item alloc] initWithType:_type code:_code name:_name status:_status time:_time andFather:_father];
}

@end

@implementation Parser

-(id) init {
	self = [super init];
    baseURL = @"http://housing.umich.edu/laundry-locator/";
    return self;
}

-(NSMutableString*) URLRequest:(NSString*)url {
    NSData *data = [NSURLConnection sendSynchronousRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:url]] returningResponse: nil error: nil];
    return [[NSMutableString alloc] initWithCString:[data bytes] encoding:NSStringEncodingConversionAllowLossy];
}


-(NSMutableArray*) JSONRequest:(NSString*)url withName:(NSString*)name {
    @try {
        NSLog(@"%@", url);
        NSMutableString* string = [self URLRequest:url];
        NSMutableArray* rows = [NSMutableArray new];
        while ([string rangeOfString:name].location != NSNotFound) {
            NSMutableArray* cols = [NSMutableArray new];
            NSRange range = [string rangeOfString:name];
            [string deleteCharactersInRange:NSMakeRange(0, range.location + range.length + 2)];
            range = [string rangeOfString:@"\""];
            [string deleteCharactersInRange:NSMakeRange(0, range.location + range.length)];
            range = [string rangeOfString:@"\""];
            [cols addObject:[string substringWithRange:NSMakeRange(0, range.location)]];
            range = [string rangeOfString:@"code"];
            [string deleteCharactersInRange:NSMakeRange(0, range.location + range.length + 2)];
            range = [string rangeOfString:@"\""];
            [string deleteCharactersInRange:NSMakeRange(0, range.location + range.length)];
            range = [string rangeOfString:@"\""];
            [cols addObject:[string substringWithRange:NSMakeRange(0, range.location)]];
            [string deleteCharactersInRange:NSMakeRange(0, range.location + range.length)];
            [rows addObject:cols];
        }
        return rows;
    }
    @catch (NSException *exception) {
        NSLog(@"Exception: %@", exception);
        return nil;
    }
}

-(NSMutableArray*) HTMLRequest:(NSString*)url {
    @try {
        NSLog(@"%@", url);
        NSMutableString* string = [self URLRequest:url];
        int row_count = [string intValue];
        NSRange tableStart = [string rangeOfString:@"<tr class"];
        [string deleteCharactersInRange:NSMakeRange(0, tableStart.location)];
        [string replaceOccurrencesOfString:@" class=\"mach_busy\"" withString:@"" options:0 range:NSMakeRange(0, [string length])];
        [string replaceOccurrencesOfString:@" class=\"mach_ok\"" withString:@"" options:0 range:NSMakeRange(0, [string length])];
        [string replaceOccurrencesOfString:@"<tr>" withString:@"" options:0 range:NSMakeRange(0, [string length])];
        [string replaceOccurrencesOfString:@"<td>" withString:@"" options:0 range:NSMakeRange(0, [string length])];
        NSRange tableEnd = [string rangeOfString:@"</table>" options:NSBackwardsSearch];
        [string deleteCharactersInRange:NSMakeRange(tableEnd.location, [string length] - tableEnd.location)];
        NSMutableArray* rows = [NSMutableArray new];
        NSArray* outer = [string componentsSeparatedByString:@"</tr>"];
        for (NSString* row in outer) {
            if (![row length])
                continue;
            NSMutableArray* cols = [NSMutableArray new];
            NSArray* inner = [row componentsSeparatedByString:@"</td>"];
            for (NSString* col in inner) {
                if (![col length])
                    continue;
                [cols addObject:col];
            }
            if ([cols count] != 5)
                return nil;
            [rows addObject:cols];
        }
        if ([rows count] != row_count)
            return nil;
        return rows;
    }
    @catch (NSException *exception) {
        NSLog(@"Exception: %@", exception);
        return nil;
    }
}

-(NSMutableArray*) buildingsForBase:(Item*)base {
    NSMutableArray* array = [self JSONRequest: [baseURL stringByAppendingFormat:@"locations/%u", arc4random()] withName:@"building"];
    NSMutableArray* items = [NSMutableArray new];
    for (NSMutableArray* row in array) {
        int code = [[row objectAtIndex:1] intValue];
        NSString* name = [[row objectAtIndex:0]stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        Item* item = [[Item alloc] initWithType:ItemBuilding code:code name:name status:MachineNone time:0 andFather:base];
        [items addObject:item];
    }
    Item* item = [[Item alloc] initWithType:ItemFavorites code:0 name:@"Favorites" status:MachineNone time:0 andFather:base];
    [items insertObject:item atIndex:0];
    return items;
}

-(NSMutableArray*) roomsForBuilding:(Item*)building {
    NSMutableArray* array = [self JSONRequest: [baseURL stringByAppendingFormat:@"rooms/%i/%u", [building code], arc4random()] withName:@"name"];
    NSMutableArray* items = [NSMutableArray new];
    for (NSMutableArray* row in array) {
        int code = [[row objectAtIndex:1] intValue];
        NSString* name = [[row objectAtIndex:0] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        Item* item = [[Item alloc] initWithType:ItemRoom code:code name:name status:MachineNone time:0 andFather:building];
        [items addObject:item];
    }
    if ([items count] > 1) {
        Item* item = [[Item alloc] initWithType:ItemRoom code:0 name:@"All" status:MachineNone time:0 andFather:building];
        [items insertObject:item atIndex:0];
    }
    return items;
}

-(NSMutableArray*) machinesForRooms:(Item*)room {
    NSMutableArray* machines = [self HTMLRequest: [baseURL stringByAppendingFormat:@"report/%i/%i/0/%u", [[room father] code], [room code], arc4random()]];
    NSMutableArray* array = [NSMutableArray new];
    for (NSMutableArray* machine in machines) {
        int code = [[machine objectAtIndex:0] intValue];
        NSString* name = [[machine objectAtIndex:1] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        if ([[room name] isEqualToString:@"All"])
            name = [[[NSString alloc] initWithFormat:@"%@ %@", [machine objectAtIndex:4], [machine objectAtIndex:1]] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        MachineStatus status = 0;
        if ([[machine objectAtIndex:2] isEqualToString:@"Available"])
            status = MachineAvailable;
        else if ([[machine objectAtIndex:2] isEqualToString:@"In Use"])
            status = MachineRunning;
        int time = [[[machine objectAtIndex:3] substringWithRange:NSMakeRange(0, [[machine objectAtIndex:3] length] - 1)] intValue];
        if (status == MachineRunning && !time)
            status = MachineOffline;
        Item* item = [[Item alloc] initWithType:ItemMachine code:code name:name status:status time:time andFather:room];
        [array addObject:item];
    }
    return array;
}

-(NSMutableArray*) getChildrenOfFather:(Item*)father {
    if ([father type] == ItemBase)
        return [self buildingsForBase:father];
    else if ([father type] == ItemBuilding)
        return [self roomsForBuilding:father];
    else if ([father type] == ItemRoom)
        return [self machinesForRooms:father];
    return nil;
}

@end

@implementation Push

+(void) addLocalNotificationWithMessage:(NSString*)message atTime:(int)time {
    UILocalNotification* local = [UILocalNotification new];
    [local setFireDate:[[NSDate date] dateByAddingTimeInterval:(time*60)]];
    [local setTimeZone:[NSTimeZone defaultTimeZone]];
    [local setAlertBody:[[NSString alloc] initWithFormat:@"%@", message]];
    [local setHasAction:false];
    [local setSoundName:UILocalNotificationDefaultSoundName];
    NSLog(@"%@", local);
    [[UIApplication sharedApplication] scheduleLocalNotification:local];
}

+(void) clearLocalNotifications {
    [[UIApplication sharedApplication] cancelAllLocalNotifications];
    NSLog(@"Cleared Notifications");
}

@end

@implementation Favorites

-(id) init {
    self = [super init];
    favorites = [[NSMutableDictionary alloc] init];
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *path = [[paths objectAtIndex:0] stringByAppendingPathComponent:@"favorites.plist"];
    @try {
        NSArray* stored = [NSArray arrayWithContentsOfFile:path];
        NSLog(@"%@", stored);
        Item* base = [Item itemWithType:ItemBase code:0 name:nil status:MachineNone time:0 andFather:nil];
        for (NSDictionary* dict in stored) {
            Item* building = [Item itemWithType:ItemBuilding code:[[dict objectForKey:@"building_code"] intValue] name:[dict objectForKey:@"building_name"] status:MachineNone time:0 andFather:base];
            Item* room = [Item itemWithType:ItemRoom code:[[dict objectForKey:@"room_code"] intValue] name:[dict objectForKey:@"room_name"] status:MachineNone time:0 andFather:building];
            [self addFavorite: room];
        }
        NSLog(@"%@", favorites);
    }
    @catch (NSException *exception) {
        NSLog(@"Error: %@, favorites lost", exception);
        favorites = [[NSMutableDictionary alloc] init];
        [self store];
    }
    return self;
}

-(bool) checkFavorite:(Item*)room {
    NSMutableDictionary* rooms = [favorites objectForKey:[NSNumber numberWithInt:[[room father] code]]];
    if (rooms == nil)
        return false;
    return (bool) [rooms objectForKey:[NSNumber numberWithInt:[room code]]];
}

-(void) removeFavorite:(Item*)room {
    NSMutableDictionary* rooms = [favorites objectForKey:[NSNumber numberWithInt:[[room father] code]]];
    [rooms removeObjectForKey:[NSNumber numberWithInt:[room code]]];
    if ([rooms count] == 0)
        [favorites removeObjectForKey:[NSNumber numberWithInt:[[room father] code]]];
}

-(void) addFavorite:(Item*)room {
    NSMutableDictionary* rooms = [favorites objectForKey:[NSNumber numberWithInt:[[room father] code]]];
    if (rooms == nil) {
        rooms = [[NSMutableDictionary alloc] init];
        [favorites setObject:rooms forKey:[NSNumber numberWithInt:[[room father] code]]];
    }
    [rooms setObject:room forKey:[NSNumber numberWithInt:[room code]]];
}

-(NSMutableArray*) getFavorites {
    NSMutableArray* array = [[NSMutableArray alloc] init];
    for (NSNumber* buildingCode in favorites) {
        for (NSNumber* roomCode in [favorites objectForKey:buildingCode]) {
            [array addObject:[[favorites objectForKey:buildingCode] objectForKey:roomCode]];
        }
    }
    if ([array count] == 0) {
        Item* item = [Item itemWithType:ItemBase code:0 name:@"You currently have no favorites" status:MachineNone time:0 andFather:nil];
        [array addObject:item];
    }
    return array;
}

-(void) clearFavorites {
    [favorites removeAllObjects];
}

-(void) store {
    NSMutableArray* array = [NSMutableArray array];
    for (NSNumber* buildingCode in favorites) {
        for (NSNumber* roomCode in [favorites objectForKey:buildingCode]) {
            Item* item = [[favorites objectForKey:buildingCode] objectForKey:roomCode];
            NSMutableDictionary* dict = [NSMutableDictionary dictionary];
            [dict setObject:roomCode forKey:@"room_code"];
            [dict setObject:[item name] forKey:@"room_name"];
            [dict setObject:buildingCode forKey:@"building_code"];
            [dict setObject:[[item father] name] forKey:@"building_name"];
            [array addObject:dict];
        }
    }
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *path = [[paths objectAtIndex:0] stringByAppendingPathComponent:@"favorites.plist"];
    [array writeToFile:path atomically:YES];
}

@end

@implementation Model

@synthesize active;

-(id) initWithFather:(Item*)_father {
    self = [super init];
    father = _father;
    items = nil;
    parser = [[Parser alloc] init];
    active = false;
    return self;
}

-(NSString *) description {
    NSMutableString* string = [NSMutableString string];
    for (Item* item in items) {
        [string appendFormat:@"%@\n", item];
    }
    return string;
}

-(void) update {
    active = true;
    NSMutableArray* array = nil;
    for (int i = 0; i < 3 && ![array count]; i++) {
        array = [parser getChildrenOfFather:father];
    }
    items = array;
    active = false;
}

-(NSMutableArray*) getItemsWithStatus:(MachineStatus)group {
    if (group == MachineNone) {
        return items;
    }
    NSMutableArray* array = [NSMutableArray new];
    for (Item* item in items) {
        if ([item status] == group)
            [array addObject:item];
    }
    return array;
}

@end
