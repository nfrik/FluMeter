//
//  Helper.m
//  MG
//
//  Created by nikolay on 8/16/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "Helper.h"

@implementation Helper

@synthesize scrollHelpView;
@synthesize pageControl;
@synthesize thisview;
@synthesize adBannerView = _adBannerView;
@synthesize adBannerViewIsVisible = _adBannerViewIsVisible;
@synthesize pageViews;
@synthesize navigationTitle;

- (void)dealloc {
	[scrollHelpView release];
	[pageControl release];
	//Release banner view, - recommended by stackoverflow
	[self releaseBannerView];	
	_adBannerView=nil;
    [super dealloc];
}

/*
 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
        // Custom initialization
    }
    return self;
}
*/
#pragma mark -
#pragma mark iAd Stuff

- (int)getBannerHeight:(UIDeviceOrientation)orientation {
    if (UIInterfaceOrientationIsLandscape(orientation)) {
        return 32;
    } else {
        return 50;
    }
}

- (int)getBannerHeight {
    return [self getBannerHeight:[UIDevice currentDevice].orientation];
}

- (void)createAdBannerView {
    Class classAdBannerView = NSClassFromString(@"ADBannerView");
    if (classAdBannerView != nil) {
        self.adBannerView = [[[classAdBannerView alloc] 
							  initWithFrame:CGRectZero] autorelease];
        [_adBannerView setRequiredContentSizeIdentifiers:[NSSet setWithObjects: 
														  ADBannerContentSizeIdentifier320x50, 
														  ADBannerContentSizeIdentifier480x32, nil]];
        if (UIInterfaceOrientationIsLandscape([UIDevice currentDevice].orientation)) {
            [_adBannerView setCurrentContentSizeIdentifier:
			 ADBannerContentSizeIdentifier480x32];
        } else {
            [_adBannerView setCurrentContentSizeIdentifier:
			 ADBannerContentSizeIdentifier320x50];            
        }
        [_adBannerView setFrame:CGRectOffset([_adBannerView frame], 0, 
											 -[self getBannerHeight])];
        [_adBannerView setDelegate:self];
		
        [self.view addSubview:_adBannerView];        
    }
}

- (void)fixupAdView:(UIInterfaceOrientation)toInterfaceOrientation {
    if (_adBannerView != nil) {        
        if (UIInterfaceOrientationIsLandscape(toInterfaceOrientation)) {
            [_adBannerView setCurrentContentSizeIdentifier:
			 ADBannerContentSizeIdentifier480x32];
        } else {
            [_adBannerView setCurrentContentSizeIdentifier:
			 ADBannerContentSizeIdentifier320x50];
        }          
        [UIView beginAnimations:@"fixupViews" context:nil];
			CGRect frame = [UIScreen mainScreen].applicationFrame;		
        if (_adBannerViewIsVisible) {
            CGRect adBannerViewFrame = [_adBannerView frame];
            adBannerViewFrame.origin.x = 0;
            adBannerViewFrame.origin.y = 0;
            [_adBannerView setFrame:adBannerViewFrame];
            CGRect contentViewFrame = thisview.frame;
            contentViewFrame.origin.y = 
			[self getBannerHeight:toInterfaceOrientation];
            contentViewFrame.size.height = self.view.frame.size.height - 
			[self getBannerHeight:toInterfaceOrientation];
            thisview.frame = contentViewFrame;
			
			frame.origin.y=0.0f;
			frame.size.height=frame.size.height-44.0f-50.f;
			scrollView.frame=frame;			
			pageControl.frame=CGRectMake(0, 430, 320, 0);			
            
        } else {
            CGRect adBannerViewFrame = [_adBannerView frame];
            adBannerViewFrame.origin.x = 0;
            adBannerViewFrame.origin.y = 
			-[self getBannerHeight:toInterfaceOrientation];
            [_adBannerView setFrame:adBannerViewFrame];
            CGRect contentViewFrame = thisview.frame;
            contentViewFrame.origin.y = 0;
            contentViewFrame.size.height = self.view.frame.size.height;
            thisview.frame = contentViewFrame;            
			
			frame.origin.y=0.0f;
			frame.size.height=frame.size.height-44.0f;
			scrollView.frame=frame;
			pageControl.frame=CGRectMake(0, 430, 320, 0);
        }
        [UIView commitAnimations];
    }   
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
    [self fixupAdView:toInterfaceOrientation];
}

#pragma mark -
#pragma mark ADBannerViewDelegate

- (void)bannerViewDidLoadAd:(ADBannerView *)banner {
    if (!_adBannerViewIsVisible) {                
        _adBannerViewIsVisible = YES;
        [self fixupAdView:[UIDevice currentDevice].orientation];
    }
}

- (void)bannerView:(ADBannerView *)banner didFailToReceiveAdWithError:(NSError *)error
{
    if (_adBannerViewIsVisible)
    {        
        _adBannerViewIsVisible = NO;
        [self fixupAdView:[UIDevice currentDevice].orientation];
    }
}

-(void)releaseBannerView{
	//Test for the ADBannerView Class, 4.0+ only (iAd.framework "weak" link Referenced)
	
	Class iAdClassPresent = NSClassFromString(@"ADBannerView");
	
	//If iOS has the ADBannerView class, then iAds = Okay:
	if (iAdClassPresent != nil) {
		
		//If instance of BannerView is Available:
		if ([_adBannerView view]) {
			
			//Release the Delegate:
			//_adBannerView.delegate = nil;
			[_adBannerView setDelegate:nil];
			
			//Release the bannerView:
			//self.bannerView = nil;
			[_adBannerView setView:nil];
        }
    }	
}

#pragma mark -
#pragma mark Further Controller Implementation

- (CGSize)pageSize {
	CGSize pageSize = scrollView.frame.size;
	if (UIInterfaceOrientationIsLandscape(self.interfaceOrientation)){
		return CGSizeMake(pageSize.height, pageSize.width);
	}
	else{
		//pageSize.height=pageSize.height-44.0f;
		return pageSize;
	}
}

- (void)setPagingMode {
	// reposition pages side by side, add them back to the view
	CGSize pageSize = [self pageSize];
	NSUInteger page = 0;
	for (UIView *view in pageViews) {
		if (!view.superview)
			[scrollView addSubview:view];
		view.frame = CGRectMake(pageSize.width * page++, 0, pageSize.width, pageSize.height);
	}
	
	scrollView.pagingEnabled = YES;
	scrollView.showsVerticalScrollIndicator = scrollView.showsHorizontalScrollIndicator = NO;
	scrollView.contentSize = CGSizeMake(pageSize.width * [pageViews count], pageSize.height);
	scrollView.contentOffset = CGPointMake(pageSize.width * currentPage, 0);
	
	scrollViewMode = ScrollViewModePaging;
}

- (void)setZoomingMode {
	NSLog(@"setZoomingMode");
	scrollViewMode = ScrollViewModeZooming; // has to be set early, or else currentPage will be mistakenly reset by scrollViewDidScroll
	
	CGSize pageSize = [self pageSize];
	
	// hide all pages besides the current one
	NSUInteger page = 0;
	for (UIView *view in pageViews)
		if (currentPage != page++)
			[view removeFromSuperview];
	
	// move the current page to (0, 0), as if no other pages ever existed
	[[pageViews objectAtIndex:currentPage] setFrame:CGRectMake(0, 44.0f, pageSize.width, pageSize.height-44.0f)];
	  
	//scrollView.contentSize=CGSizeMake(<#CGFloat width#>, <#CGFloat height#>);
	scrollView.pagingEnabled = NO;
	scrollView.showsVerticalScrollIndicator = scrollView.showsHorizontalScrollIndicator = YES;
	scrollView.contentSize = pageSize;
	scrollView.contentOffset = CGPointZero;
	scrollView.bouncesZoom = YES;
}

- (void)setCurrentPage:(NSUInteger)page {
	if (page == currentPage)
		return;
	currentPage = page;
	[pageControl setCurrentPage:currentPage];
	// in a real app, this would be a good place to instantiate more view controllers -- see SDK examples
}

// Implement viewDidLoad to do additional setup after loading the view, typifile://localhost/Users/administrator/Library/Application%20Support/Developer/Shared/Xcode/Screenshots/Screenshot%202010.08.26%2023.17.02.pngcally from a nib.
- (void)viewDidLoad {
    
    [super viewDidLoad];
	
	CGRect frame = [UIScreen mainScreen].applicationFrame;
	frame.origin.y=0.0f;
	frame.size.height=frame.size.height-44.0f;
	scrollView = [[ZoomScrollView alloc] initWithFrame:frame];
	scrollView.delegate = self;
	scrollView.maximumZoomScale = 2.0f;
	scrollView.minimumZoomScale = 1.0f;
	
	[scrollView setClipsToBounds:YES];
	scrollView.backgroundColor = [UIColor blackColor];
	scrollView.scrollEnabled = YES;
	scrollView.pagingEnabled = YES;
	scrollView.bounces = YES;
	scrollView.directionalLockEnabled = YES;	
	
	scrollView.zoomInOnDoubleTap = scrollView.zoomOutOnDoubleTap = NO;

	
    /*
    
	UIImageView *imageView1 = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"PHELP1.png"]];
	UIImageView *imageView2 = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"PHELP2.png"]];
	UIImageView *imageView3 = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"PHELP3.png"]];
	UIImageView *imageView4 = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"PHELP4.png"]];	
	
	// in a real app, you most likely want to have an array of view controllers, not views;
	// also should be instantiating those views and view controllers lazily
	pageViews = [[NSArray alloc] initWithObjects:imageView1, imageView2, imageView3, imageView4, nil];
	*/
    
	//setup pageControl
	pageControl=[[UIPageControl alloc] initWithFrame:CGRectMake(0, 420, 320, 0)];
	pageControl.backgroundColor=[UIColor clearColor];
	
	self.pageControl.numberOfPages=[pageViews count];
	//self.pageControl.numberOfPages=4;
	[pageControl setCurrentPage:currentPage];
	
	//self.view = scrollView;
	self.view.backgroundColor=[UIColor blackColor];
	self.thisview.backgroundColor=[UIColor blackColor];
	[self.thisview addSubview:scrollView];
	[self.view addSubview:pageControl];
	//[scrollView setContentSize:CGSizeMake(44.0f, [scrollView bounds].size.height)];
	//[scrollView addSubview:pageControl];	
    
	self.navigationItem.title=navigationTitle;

	scrollViewMode = ScrollViewModeNotInitialized;
	[self setPagingMode];
	
	//iAd banner
	//[self createAdBannerView];	
}

- (void) viewWillAppear:(BOOL)animated {
    //[self refresh];
    [self fixupAdView:[UIDevice currentDevice].orientation];
}


/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/


//Fu#$ng function!!!
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
    [super viewDidUnload];
	[pageViews release]; // need to release all page views here; our array is created in loadView, so just releasing it
	 pageViews = nil;	
	
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}





- (void)scrollViewDidScroll:(UIScrollView *)aScrollView {
	if (scrollViewMode == ScrollViewModePaging)
		[self setCurrentPage:roundf(scrollView.contentOffset.x / [self pageSize].width)];
}

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)aScrollView {
	if (scrollViewMode != ScrollViewModeZooming)
		[self setZoomingMode];
	return [pageViews objectAtIndex:currentPage];
}

- (void)scrollViewDidEndZooming:(UIScrollView *)aScrollView withView:(UIView *)view atScale:(float)scale {
	if (scrollView.zoomScale == scrollView.minimumZoomScale)
		[self setPagingMode];
}


- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
	if (scrollViewMode == ScrollViewModePaging) {
		scrollViewMode = ScrollViewModeNotInitialized;
		[self setPagingMode];
	} else {
		[self setZoomingMode];
	}
}

-(IBAction) pageChanged:(id)sender{
	int i=i;
	
}

@end
