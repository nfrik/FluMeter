//
//  OverlayViewController.m
//  TableView
//
//  Created by iPhone SDK Articles on 1/17/09.
//  Copyright www.iPhoneSDKArticles.com 2009. 
//

#import "OverlayViewController.h"
#import "NationInfo.h"
#import "FluNews.h"

@implementation OverlayViewController

@synthesize rvController;
@synthesize fnController;

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
	
	[rvController doneSearching_Clicked:nil];
    [fnController doneSearching_Clicked:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning]; // Releases the view if it doesn't have a superview
    // Release anything that's not essential, such as cached data
}


- (void)dealloc {
	[rvController release];
    [fnController release];
    [super dealloc];
}


@end
