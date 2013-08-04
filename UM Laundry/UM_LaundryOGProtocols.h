//
//  UM_LaundryOGProtocols.h
//  UM Laundry
//
//  Created by Ari Chivukula on 8/4/13.
//  Copyright (c) 2013 Ari Chivukula. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <FacebookSDK/FacebookSDK.h>

@protocol OGProtocols <NSObject>

@end

@protocol OGLaundryMachine<FBGraphObject>

@property (retain, nonatomic) NSString *id;
@property (retain, nonatomic) NSString *url;

@end

@protocol OGUseLaundryMachine<FBOpenGraphAction>

@property (retain, nonatomic) id<OGLaundryMachine> laundry_machine;

@end
