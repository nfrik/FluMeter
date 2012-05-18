//
//  Helper.h
//  MG
//
//  Created by nikolay on 8/16/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ZoomScrollView.h"
#import <iAd/ADBannerView.h>

typedef enum {
	ScrollViewModeNotInitialized,           // view has just been loaded
	ScrollViewModePaging,                   // fully zoomed out, swiping enabled
	ScrollViewModeZooming,                  // zoomed in, panning enabled
} ScrollViewMode;

@interface Helper : UIViewController <UIScrollViewDelegate, ADBannerViewDelegate> {
	UIScrollView *scrollHelpView;
	IBOutlet UIPageControl *pageControl;
	UIView *thisview;	
	ZoomScrollView *scrollView;
	NSArray *pageViews;
	NSUInteger currentPage;
	ScrollViewMode scrollViewMode;
    NSString *navigationTitle;
	
	id _adBannerView;
	BOOL _adBannerViewIsVisible;	

}

@property (nonatomic, retain) IBOutlet UIScrollView *scrollHelpView;
@property (nonatomic, retain)          UIPageControl *pageControl;
@property (nonatomic, retain) IBOutlet UIView *thisview;
@property (retain) NSArray *pageViews;
@property (retain) NSString *navigationTitle;

@property (nonatomic, retain) id adBannerView;
@property (nonatomic) BOOL adBannerViewIsVisible;

-(IBAction) pageChanged:(id)sender;

-(void)releaseBannerView;


@end
