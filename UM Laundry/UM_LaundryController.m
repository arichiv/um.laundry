//
//  UM_LaundryController.m
//  UM Laundry
//
//  Created by Ari Chivukula on 8/7/11.
//  Copyright (c) 2013 Ari Chivukula. All rights reserved.
//

#import <FacebookSDK/FacebookSDK.h>
#import <FacebookSDK/FBRequest.h>

#import "UM_LaundryController.h"
#import "UM_LaundryModel.h"
#import "UM_LaundryAppDelegate.h"
#import "UM_LaundryOGProtocols.h"

@implementation UM_LaundryController

-(id) initWithFather:(Item *)_father {
    self = [super initWithStyle: UITableViewStylePlain];
    if (self) {
        queue = dispatch_queue_create("arichiv.um_laundry",NULL);
        father = _father;
        selected = nil;
        items = nil;
        model = nil;
        status = MachineNone;
        if ([father type] != ItemFavorites) {
            model = [[Model alloc] initWithFather:father];
            UIBarButtonItem* refresh = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(updateData)];
            [[self navigationItem] setRightBarButtonItem:refresh animated:true];
        }
        else {
            UIBarButtonItem* options = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(displayFavoritesOptions)];
            [[self navigationItem] setRightBarButtonItem:options animated:true];
        }
        if ([father type] == ItemBase) {
            UIBarButtonItem* options = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(displayBaseOptions)];
            [[self navigationItem] setLeftBarButtonItem:options animated:true];
        }
        [[self navigationItem] setTitle:[father navTitle]];
    }
    return self;
}

-(void) viewDidLoad {
    [super viewDidLoad];
    [self updateData];
}


-(void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if ([father type] == ItemRoom) {
        NSArray *categories = [NSArray arrayWithObjects:@"All", @"Available", @"In Use", nil];
        UISegmentedControl* controlView = [[UISegmentedControl alloc] initWithItems:categories];
        [controlView setSelectedSegmentIndex:0];
        [controlView addTarget:self action:@selector(setGroup:) forControlEvents:UIControlEventValueChanged];
        UIBarButtonItem* seg = [[UIBarButtonItem alloc] initWithCustomView:controlView];
        UIBarButtonItem* add = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(displayRoomOptions)];
        UIBarButtonItem* left = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
        UIBarButtonItem* center = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
        UIBarButtonItem* right = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
        [self setToolbarItems: [NSArray arrayWithObjects:left, seg, center, add, right, nil] animated:true];
        [[self navigationController] setToolbarHidden:false animated:true];
    }
    [self updateDisplay];
}

-(void) viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    if ([father type] == ItemRoom) {
        [[self navigationController] setToolbarHidden:true animated:true];
    }
}

-(BOOL) shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return true;
}

-(NSInteger) numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

-(NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [items count];
}

-(UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    Item* item = [items objectAtIndex:[indexPath row]];
    if (([item type] == ItemMachine && [item status] != MachineRunning) || [item type] == ItemBase)
        [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    else
        [cell setSelectionStyle:UITableViewCellSelectionStyleBlue];
    [[cell textLabel] setText:[item cellText]];
    [[cell detailTextLabel] setText:[item cellDetail]];
    if ([father type] == ItemFavorites)
        [[cell detailTextLabel] setText:[item cellDetailFavorite]];
    return cell;
}

-(void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    selected = [items objectAtIndex:[indexPath row]];
    if ([selected type] == ItemMachine) {
        if ([selected status] == MachineRunning) {
            [[[UIAlertView alloc] initWithTitle:[selected alertTitle] message:[selected alertMessage] delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles: @"Remind", nil] show];
        }
    }
    else  if ([selected type] != ItemBase) {
        UM_LaundryController* detail = [[UM_LaundryController alloc] initWithFather:selected];
        [[self navigationController] pushViewController:detail animated:YES];
    }
    [tableView deselectRowAtIndexPath:indexPath animated:true];
}

-(void) setGroup:(UISegmentedControl *)sender {
    status = (int)[sender selectedSegmentIndex];
    [self updateDisplay];
}

-(void) updateData {
    Model* modelTemp = model;
    UM_LaundryController* controllerTemp = self;
    dispatch_async(queue, ^{
        if (![modelTemp active]) {
            [modelTemp update];
            dispatch_async(dispatch_get_main_queue(),^{
                [controllerTemp updateDisplay];
            });
        }
    });
}

-(void) updateDisplay {
    if ([father type] != ItemFavorites)
        items = [model getItemsWithStatus:status];
    else {
        Favorites* fav = [(UM_LaundryAppDelegate*) [[UIApplication sharedApplication] delegate] favorites];
        items = [fav getFavorites];
    }
    [[self tableView] reloadData];
}

-(void) displayBaseOptions {
    NSString* fbInteraction = NULL;
    if (FBSession.activeSession.isOpen) {
        fbInteraction = @"Log out of Facebook";
    } else {
        fbInteraction = @"Log into Facebook";
    }
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:@"Clear Reminders" otherButtonTitles:@"Washer Reminder (38min)", @"Dryer Reminder (60min)", fbInteraction, nil];
    [actionSheet showInView:self.view];

}

-(void) displayFavoritesOptions {
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:@"Clear Favorites" otherButtonTitles:nil];
    [actionSheet showInView:self.view];
    
}

-(void) displayRoomOptions {
    NSString* title = @"Add to Favorites";
    Favorites* favorites = [(UM_LaundryAppDelegate*) [[UIApplication sharedApplication] delegate] favorites];
    if ([favorites checkFavorite:father])
        title = @"Remove from Favorites";
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:title, nil];
    [actionSheet showFromToolbar: [[self navigationController] toolbar]];
    
}

-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if ([father type] == ItemBase) {
        if (buttonIndex == 0) {
            [[[UIAlertView alloc] initWithTitle:@"Cleared All Reminders" message:nil delegate:nil cancelButtonTitle:@"Okay" otherButtonTitles: nil] show];
            [Push clearLocalNotifications];
        }
        else if (buttonIndex == 1) {
            [[[UIAlertView alloc] initWithTitle:@"Added Washer Reminder" message:@"Will go off in 38 minutes" delegate:nil cancelButtonTitle:@"Okay" otherButtonTitles: nil] show];
            [Push addLocalNotificationWithMessage:@"Washer" atTime:38];
        }
        else if (buttonIndex == 2) {
            [[[UIAlertView alloc] initWithTitle:@"Added Dryer Reminder" message:@"Will go off in 60 minutes" delegate:nil cancelButtonTitle:@"Okay" otherButtonTitles: nil] show];
            [Push addLocalNotificationWithMessage:@"Dryer" atTime:60];
        } else if (buttonIndex == 3) {
            if (FBSession.activeSession.isOpen) {
                [FBSession.activeSession closeAndClearTokenInformation];
            } else {
                [FBSession openActiveSessionWithPublishPermissions:[NSArray arrayWithObjects:@"publish_actions", nil]
                                                   defaultAudience:FBSessionDefaultAudienceFriends
                                                      allowLoginUI:YES
                                                 completionHandler:nil];
            }
        }
    }
    else if ([father type] == ItemRoom) {
        if (buttonIndex == 0) {
            Favorites* favorites = [(UM_LaundryAppDelegate*) [[UIApplication sharedApplication] delegate] favorites];
            if ([favorites checkFavorite:father])
                [favorites removeFavorite:father];
            else
                [favorites addFavorite:father];
        }
    }
    else if ([father type] == ItemFavorites) {
        if (buttonIndex == 0) {
            Favorites* favorites = [(UM_LaundryAppDelegate*) [[UIApplication sharedApplication] delegate] favorites];
            [favorites clearFavorites];
            [self updateDisplay];
        }
    }
}


-(void) alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 1) {
        [Push addLocalNotificationWithMessage:[selected alertMessage] atTime:[selected time]];
        if (FBSession.activeSession.isOpen) {
            NSString *url = @"http://arichiv.com/og_laundry_machine?location=";
            NSString *message = [[selected alertMessage] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
            id<OGLaundryMachine> laundryMachine = (id<OGLaundryMachine>)[FBGraphObject graphObject];
            laundryMachine.url = [url stringByAppendingString:message];
            id<OGUseLaundryMachine> action = (id<OGUseLaundryMachine>)[FBGraphObject graphObject];
            action.laundry_machine = laundryMachine;
            [FBRequestConnection startForPostWithGraphPath:@"me/umlaundry:use"
                                               graphObject:action
                                         completionHandler:nil];
        }
    }
}

@end
