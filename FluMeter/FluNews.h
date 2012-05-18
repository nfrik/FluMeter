//
//  ThirdTabViewController.h
//  FluMeter
//
//  Created by nikolay on 5/12/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Reachability.h"
#import "Helper.h"

@class WebViewController;
@class OverlayViewController;
@interface FluNews : UITableViewController {
    NSOperationQueue *_queue;
    NSArray *_feeds;
    NSMutableArray *_allEntries;
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
@property (retain) WebViewController *webViewController;
- (void) searchTableView;
- (void) doneSearching_Clicked:(id)sender; 
-(NSString*)stringBetweenString:(NSString*)thestring startstring:(NSString*)start endString:(NSString*)end;

@end
