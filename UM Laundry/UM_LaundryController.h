//
//  UM_LaundryController.h
//  UM Laundry
//
//  Created by Ari Chivukula on 8/7/11.
//  Copyright (c) 2013 Ari Chivukula. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UM_LaundryModel.h"

@interface UM_LaundryController : UITableViewController <UIAlertViewDelegate, UIActionSheetDelegate> {
    dispatch_queue_t queue;
    Model* model;
    Item* father;
    Item* selected;
    NSMutableArray* items;
    MachineStatus status;
}

-(id) initWithFather:(Item*)_father;
-(void) setGroup:(UISegmentedControl *)sender;
-(void) updateDisplay;
-(void) updateData;

@end
