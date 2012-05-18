//
//  CoreLocationController.h
//  StopFlu
//
//  Created by nikolay on 5/6/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CoreLocation/CoreLocation.h"

@protocol CoreLocationControllerDelegate 
@required
- (void)locationUpdate:(CLLocation *)location; // Our location updates are sent here
- (void)locationError:(NSError *)error; // Any errors are sent here
@end

@interface CoreLocationController : NSObject <CLLocationManagerDelegate> {
	CLLocationManager *locMgr;
	id delegate;
}

@property (nonatomic, retain) CLLocationManager *locMgr;
@property (nonatomic, assign) id delegate;

@end

