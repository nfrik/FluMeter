//
//  WebViewController.m
//  RSSFun
//
//  Created by Ray Wenderlich on 1/24/11.
//  Copyright 2011 Ray Wenderlich. All rights reserved.
//

#import "WebViewController.h"
#import "RSSEntry.h"
#import "DSActivityView.h"
#import "SHK.h"

@implementation WebViewController
@synthesize webView = _webView;
@synthesize entry = _entry;

// The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
/*
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization.
    }
    return self;
}
*/

/*
// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
}
*/

/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations.
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

- (void)viewWillAppear:(BOOL)animated {    
    self.view.autoresizesSubviews = YES;
    //create a frame that will be used to size and place the web view
    _webView.scalesPageToFit = YES;
    //_webView.autoresizingMask = YES;
    _webView.autoresizingMask = (UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth);
    NSURL *url = [NSURL URLWithString:_entry.articleUrl];    
    [_webView loadRequest:[NSURLRequest requestWithURL:url]];
    _webView.delegate=self;
}

- (void)viewDidLoad{

    self.navigationItem.title = _entry.blogTitle;    
    [DSBezelActivityView newActivityViewForView:self.view];
    UIBarButtonItem *sharebutton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(share)];
    self.navigationItem.rightBarButtonItem = sharebutton;
    [sharebutton release];
}

- (void)share{
    //SHKItem *item = [SHKItem URL: title:@"ShareKit is Awesome!"];
    SHKItem *item = [SHKItem URL:[NSURL URLWithString:_entry.articleUrl] title:_entry.articleTitle];
    
	// Get the ShareKit action sheet
	SHKActionSheet *actionSheet = [SHKActionSheet actionSheetForItem:item];
    
	// Display the action sheet
	[actionSheet showFromToolbar:self.navigationController.toolbar];
}

- (void)viewWillDisappear:(BOOL)animated {
    
    [_webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"about:blank"]]];
    
}

-(void)webViewDidFinishLoad:(UIWebView *)webView{
    [DSBezelActivityView removeViewAnimated:YES];
}

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc. that aren't in use.
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}



- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations.
    return YES;
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    
    if(fromInterfaceOrientation == UIInterfaceOrientationPortrait){
        NSString* result = [_webView stringByEvaluatingJavaScriptFromString:@"rotate(0)"];
        //NSString a = *result;
        NSLog(result);
        NSLog(@"rotated");
        
    }
    else{
        [_webView stringByEvaluatingJavaScriptFromString:@"rotate(1)"];
        NSLog(@"rotated");        
    }
    
    //[self.webView sizeToFit];
    //CGRect curBounds = [[UIScreen mainScreen] bounds];
    //[self.webView setBounds:self.origViewRectangle];
    //[[UIScreen mainScreen] bounds]]
    //NSLog(@"orienting");
}

- (void)dealloc {
    [_entry release];
    _entry = nil;
    [_webView release];
    _webView = nil;
    [super dealloc];
}


@end
