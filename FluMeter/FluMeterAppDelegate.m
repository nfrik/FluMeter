//
//  FluMeterAppDelegate.m
//  FluMeter
//
//  Created by nikolay on 5/12/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "FluMeterAppDelegate.h"
#import "RootViewController.h"
#import "DSActivityView.h"

@implementation FluMeterAppDelegate


@synthesize window=_window;

@synthesize navigationController;

@synthesize defaultImageView;

//@synthesize tabbarController=tabbarController;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.
    // Add the navigation controller's view to the window and display.
    //self.window.rootViewController = self.navigationController;
    //[self.window addSubview:self.navigationController.view];
    
    [self.window addSubview:defaultImageView];
    //[self.window addSubview:[navigationController view]];
    [self.window makeKeyAndVisible];
    
    NSString *var=[self retrieveFromUserDefaults];
	NSString *DisclaimerMessage=@"Please read these terms and conditions of use carefully before agreeing to use this application.\r\n This App Does Not Provide Medical Advice\r\n The contents of FluMeter, text, graphics, images and information obtained from the Center for Disease Control and empirically based research are for informational purposes only.  The Content is not intended to be a substitute for professional medical advice, diagnosis, or treatment. Always seek the advice of your physician or other qualified health provider with any questions you may have regarding the flu or flu-like symptoms you may be experiencing.\r\n FluMeter Disclaimer\r\nTHE MATERIAL EMBODIED IN THIS SOFTWARE IS PROVIDED TO YOU \"AS-IS\" AND WITHOUT WARRANTY OF ANY KIND, EXPRESS, IMPLIED OR OTHERWISE, INCLUDING WITHOUT LIMITATION, ANY WARRANTY OF FITNESS FOR A PARTICULAR PURPOSE.\r\n IN NO EVENT SHALL THE CENTERS FOR DISEASE CONTROL AND PREVENTION (CDC), THE UNITED STATES (U.S.) GOVERNMENT, OR IPHONE DREAMS BE LIABLE TO YOU OR ANYONE ELSE FOR ANY DIRECT, SPECIAL, INCIDENTAL, INDIRECT OR CONSEQUENTIAL DAMAGES OF ANY KIND, OR ANY DAMAGES WHATSOEVER, INCLUDING WITHOUT LIMITATION, LOSS OF PROFIT, LOSS OF USE, SAVINGS OR REVENUE, OR THE CLAIMS OF THIRD PARTIES, WHETHER OR NOT CDC, THE U.S. GOVERNMENT, OR IPHONE DREAMS HAS BEEN ADVISED OF THE POSSIBILITY OF SUCH LOSS, HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, ARISING OUT OF OR IN CONNECTION WITH THE POSSESSION, USE OR PERFORMANCE OF THIS SOFTWARE.\r\nThe creators of FluMeter and iPhone Dreams make no representations or warranties with respect to the FluMeter iPhone application, its contents or any website with which it is linked.  They also make no representations or warranties as to whether the information accessible via this application, or any website with which it is linked, is accurate, complete, or current.";
	
	if (var==NULL) {
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Disclaimer"
                                                        message:DisclaimerMessage
                                                       delegate:self
                                              cancelButtonTitle:nil
                                              otherButtonTitles:nil];
		[alert addButtonWithTitle:@"Agree"];
		[alert setTag:8];
        [alert show];
        [alert release];
	}
    else{
        
        // No need for a property for the activity view:
        [DSBezelActivityView newActivityViewForView:_window];
        
        // Normally you'd do other work to load the data etc, then remove the activity view; faking that delay here:
        [self performSelector:@selector(setupWindow) withObject:nil afterDelay:1.0];            
    }

    
    return YES;
}

- (void)setupWindow
{
	[_window addSubview:[navigationController view]];
    [defaultImageView removeFromSuperview];
    
    // Easily remove the activity view (there's also animated variations for the bezel and keyboard styles):
    [DSBezelActivityView removeViewAnimated:NO];

}

- (void)applicationWillResignActive:(UIApplication *)application
{
    /*
     Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
     Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
     */
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    /*
     Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
     If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
     */
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    /*
     Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
     */
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    /*
     Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
     */
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    /*
     Called when the application is about to terminate.
     Save data if appropriate.
     See also applicationDidEnterBackground:.
     */
}

- (void)dealloc
{
    [_window release];
    [navigationController release];
    //[tabbarController release];
    [super dealloc];
}

#pragma mark -
#pragma mark Application Data

-(void)saveToUserDefaults:(NSString*)myString
{
    NSUserDefaults *standardUserDefaults = [NSUserDefaults standardUserDefaults];
	
    if (standardUserDefaults) {
        [standardUserDefaults setObject:myString forKey:@"Prefs"];
        [standardUserDefaults synchronize];
    }
}

-(NSString*)retrieveFromUserDefaults
{
    NSUserDefaults *standardUserDefaults = [NSUserDefaults standardUserDefaults];
    NSString *val = nil;
	
    if (standardUserDefaults) 
        val = [standardUserDefaults objectForKey:@"Prefs"];
	
    return val;
}

- (void)alertView:(UIAlertView *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    // the user clicked one of the OK/Cancel buttons
    if (buttonIndex == 0)
    {
        NSLog(@"ok");
        
		[self saveToUserDefaults:@"Agreed"];        
        
        // No need for a property for the activity view:
        [DSBezelActivityView newActivityViewForView:_window];
        
        // Normally you'd do other work to load the data etc, then remove the activity view; faking that delay here:
        [self performSelector:@selector(setupWindow) withObject:nil afterDelay:1.0];        
        
    }
    else
    {
        NSLog(@"cancel");
    }
}

@end
