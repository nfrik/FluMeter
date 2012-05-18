//
//  FluMeterAppDelegate.h
//  FluMeter
//
//  Created by nikolay on 5/12/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FluMeterAppDelegate : NSObject <UIApplicationDelegate, UITabBarControllerDelegate, UIAlertViewDelegate> {
     UIImageView *defaultImageView;    
    //UITabBarController *tabbarController;
    UINavigationController *navigationController;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;

@property (nonatomic, retain) IBOutlet UINavigationController *navigationController;

@property (nonatomic, retain) IBOutlet UIImageView *defaultImageView;

-(NSString*)retrieveFromUserDefaults;
-(void)saveToUserDefaults:(NSString*)myString;
//@property (nonatomic, retain) IBOutlet UITabBarController *tabbarController;
//@property (nonatomic, retain) IBOutlet UINavigationController *navigationController;

@end
