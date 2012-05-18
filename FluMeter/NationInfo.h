//
//  NationInfo.h
//  FluMeter
//
//  Created by nikolay on 5/17/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CoreLocationController.h"
#import "Reachability.h"
#import "WebViewController.h"
#import "Helper.h"

@class WebViewController;
@class OverlayViewController;
@interface NationInfo : UITableViewController {
    NSOperationQueue *_queue;
    NSArray *_feeds;
    NSMutableArray *_allEntries;    
    
    NSString * stateF;
    WebViewController *_webViewController;
    
    NSMutableArray *listOfItems;
    NSMutableArray *copyListOfItems;
    IBOutlet UISearchBar *searchBar;
    BOOL searching;
    BOOL letUserSelectRow;
	OverlayViewController *ovController;
}



@property (retain) NSOperationQueue *queue;
@property (retain) NSArray *feeds;
@property (retain) NSMutableArray *allEntries;
@property (nonatomic,retain) NSString *stateF;
@property (retain) WebViewController *webViewController;

- (void) searchTableView;
- (void) doneSearching_Clicked:(id)sender; 
-(NSString*)stringBetweenString:(NSString*)thestring startstring:(NSString*)start endString:(NSString*)end;
-(UIImage *)imageForString:(NSString *)string;

@end
