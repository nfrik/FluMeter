//
//  FluNews.m
//  FluMeter
//
//  Created by nikolay on 5/18/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "FluNews.h"
#import "RootViewController.h"
#import "RSSEntry.h"
#import "ASIHTTPRequest.h"
#import "GDataXMLNode.h"
#import "GDataXMLElement-Extras.h"
#import "NSDate+InternetDateTime.h"
#import "NSArray+Extras.h"
#import "WebViewController.h"
#import "OverlayViewController.h"
#import "DSActivityView.h"

@implementation FluNews
@synthesize allEntries = _allEntries;
@synthesize feeds = _feeds;
@synthesize queue = _queue;
@synthesize webViewController = _webViewController;

- (void)dealloc
{
    [super dealloc];        
    [_allEntries release];
    _allEntries = nil;
    [_queue release];
    _queue = nil;
    [_feeds release];
    _feeds = nil;
    [_webViewController release];
    _webViewController = nil;
	[ovController release];
	[copyListOfItems release];
	[searchBar release];        
}

- (void)refresh {
    
    for (NSString *feed in _feeds) {
        NSURL *url = [NSURL URLWithString:feed];
        ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
        [request setDelegate:self];
        [_queue addOperation:request];
    }
    
}

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}



- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
    self.webViewController = nil;   
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Do any additional setup after loading the view from its nib.
	UIBarButtonItem *helpButton = [[UIBarButtonItem alloc] initWithTitle:@"Help" style:UIBarButtonItemStyleBordered target:self action:@selector(toggleHelpRSS)];
	self.navigationItem.rightBarButtonItem = helpButton;
	[helpButton release];
    
    //self.title = @"Feeds";
    self.allEntries = [NSMutableArray array];
    self.queue = [[[NSOperationQueue alloc] init] autorelease];
    /*  self.feeds = [NSArray arrayWithObjects:@"http://feeds.feedburner.com/RayWenderlich",
     @"http://feeds.feedburner.com/vmwstudios",
     @"http://idtypealittlefaster.blogspot.com/feeds/posts/default", 
     @"http://www.71squared.com/feed/",
     @"http://feeds.feedburner.com/maniacdev",
     @"http://feeds.feedburner.com/macindie",
     nil];*/    
    self.feeds = [NSArray arrayWithObjects:@"http://www2c.cdc.gov/podcasts/createrss.asp?t=r&c=20",
                  @"http://www2c.cdc.gov/podcasts/searchandcreaterss.asp?topic=flu",
                  nil];
    self.tableView.rowHeight=80.0;
    //Initialize the copy array.
    copyListOfItems = [[NSMutableArray alloc] init];    
    
    //[DSBezelActivityView setAnimationsEnabled:YES];
    //[DSBezelActivityView newActivityViewForView:self.view];    
    
    
    //Set the title
    self.navigationItem.title = @"Flu News";
    
    //Add the search bar
    self.tableView.tableHeaderView = searchBar;
    //self.navigationItem.titleView = searchBar;
    searchBar.autocorrectionType = UITextAutocorrectionTypeNo;
    
    searching = NO;
    letUserSelectRow = YES;    
    
    [DSBezelActivityView newActivityViewForView:self.view];
    
    [self refresh];

}

- (void)parseRss:(GDataXMLElement *)rootElement entries:(NSMutableArray *)entries {
    
    NSArray *channels = [rootElement elementsForName:@"channel"];
    for (GDataXMLElement *channel in channels) {            
        
        NSString *blogTitle = [channel valueForChild:@"title"];                    
        
        NSArray *items = [channel elementsForName:@"item"];
        for (GDataXMLElement *item in items) {
            
            NSString *articleTitle = [item valueForChild:@"title"];
            NSString *articleUrl = [item valueForChild:@"link"];            
            NSString *articleDateString = [item valueForChild:@"pubDate"];
            NSString *podcastUrl = nil;
            
            NSArray *enclosures = [item elementsForName:@"enclosure"];
            
            for(GDataXMLElement *enclosure in enclosures) {
                podcastUrl = [[enclosure attributeForName:@"url"] stringValue];
            }            
            
            NSDate *articleDate = [NSDate dateFromInternetDateTimeString:articleDateString formatHint:DateFormatHintRFC822];
            
            BOOL isPodcast = NO;
            
            if (podcastUrl!=nil) {
                articleUrl=podcastUrl;
                isPodcast = YES;
            }
            
            RSSEntry *entry = [[[RSSEntry alloc] initWithBlogTitle:blogTitle 
                                                     articleTitle:articleTitle 
                                                       articleUrl:articleUrl 
                                                      articleDate:articleDate 
                                                          podcast:isPodcast] autorelease];
            
            [entries addObject:entry];
            
        }      
    }
    
}

- (void)parseAtom:(GDataXMLElement *)rootElement entries:(NSMutableArray *)entries {
    
    NSString *blogTitle = [rootElement valueForChild:@"title"];                    
    
    NSArray *items = [rootElement elementsForName:@"entry"];
    for (GDataXMLElement *item in items) {
        
        NSString *articleTitle = [item valueForChild:@"title"];
        NSString *articleUrl = nil;
        NSArray *links = [item elementsForName:@"link"];        
        for(GDataXMLElement *link in links) {
            NSString *rel = [[link attributeForName:@"rel"] stringValue];
            NSString *type = [[link attributeForName:@"type"] stringValue]; 
            if ([rel compare:@"alternate"] == NSOrderedSame && 
                [type compare:@"text/html"] == NSOrderedSame) {
                articleUrl = [[link attributeForName:@"href"] stringValue];
            }
        }
        
        NSString *articleDateString = [item valueForChild:@"updated"];        
        NSDate *articleDate = [NSDate dateFromInternetDateTimeString:articleDateString formatHint:DateFormatHintRFC3339];
        
        RSSEntry *entry = [[[RSSEntry alloc] initWithBlogTitle:blogTitle 
                                                  articleTitle:articleTitle 
                                                    articleUrl:articleUrl 
                                                   articleDate:articleDate
                                                       podcast:NO] autorelease];
        [entries addObject:entry];
        
    }      
    
}

- (void)parseFeed:(GDataXMLElement *)rootElement entries:(NSMutableArray *)entries {    
    if ([rootElement.name compare:@"rss"] == NSOrderedSame) {
        [self parseRss:rootElement entries:entries];
    } else if ([rootElement.name compare:@"feed"] == NSOrderedSame) {                       
        [self parseAtom:rootElement entries:entries];
    } else {
        NSLog(@"Unsupported root element: %@", rootElement.name);
    }    
    [DSBezelActivityView removeViewAnimated:NO];    
}

- (void)requestFinished:(ASIHTTPRequest *)request {
    
    [_queue addOperationWithBlock:^{
        
        NSError *error;
        GDataXMLDocument *doc = [[GDataXMLDocument alloc] initWithData:[request responseData] 
                                                               options:0 error:&error];
        if (doc == nil) { 
            NSLog(@"Failed to parse %@", request.url);
        } else {
            
            NSMutableArray *entries = [NSMutableArray array];
            [self parseFeed:doc.rootElement entries:entries];                
            
            [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                [doc release];
                for (RSSEntry *entry in entries) {
                    
                    int insertIdx = [_allEntries indexForInsertingObject:entry sortedUsingBlock:^(id a, id b) {
                        RSSEntry *entry1 = (RSSEntry *) a;
                        RSSEntry *entry2 = (RSSEntry *) b;
                        return [entry1.articleDate compare:entry2.articleDate];
                    }];
                    
                    [_allEntries insertObject:entry atIndex:insertIdx];
                    [self.tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:insertIdx inSection:0]]
                                          withRowAnimation:UITableViewRowAnimationRight];
                    
                }                            
                
            }];
            
        }        
    }]; 
    
    [self.tableView reloadData];
    
    [DSBezelActivityView removeViewAnimated:NO];
    /*
     NSError *error;
     GDataXMLDocument *doc = [[GDataXMLDocument alloc] initWithData:[request responseData] 
     options:0 error:&error];
     if (doc == nil) {
     NSLog(@"Failed to parse %@", request.url);
     }
     else{
     NSLog(@"%@", doc.rootElement);
     }
     */
    
}

- (void)requestFailed:(ASIHTTPRequest *)request {
    NSError *error = [request error];
    NSLog(@"Error: %@", error);
}


- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


#pragma mark -
#pragma mark Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    RSSEntry *selectedBlog = nil;
    
    if(searching)
        selectedBlog = [copyListOfItems objectAtIndex:indexPath.row];
    else {
        selectedBlog = [_allEntries objectAtIndex:indexPath.row];
    }    
    
	if (_webViewController == nil) {
        self.webViewController = [[[WebViewController alloc] initWithNibName:@"WebViewController" bundle:[NSBundle mainBundle]] autorelease];
    }

    _webViewController.entry = selectedBlog;
    [self.navigationController pushViewController:_webViewController animated:YES];
    
}

//RootViewController.m
- (NSIndexPath *)tableView :(UITableView *)theTableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if(letUserSelectRow)
        return indexPath;
    else
        return nil;
}

#pragma mark -
#pragma mark Table view data source

// Customize the number of sections in the table view.
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
    
    if (searching)
        return 1;
    else
        return [_allEntries count];
}


// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    //return [_allEntries count];
    
    if (searching)
        return [copyListOfItems count];
    else {
        
        return [_allEntries count];
        /*
         //Number of rows it should expect should be based on the section
         NSDictionary *dictionary = [_allEntries objectAtIndex:section];
         NSArray *array = [dictionary objectForKey:@"States"];
         return [array count];*/
    }
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    // Each subview in the cell will be identified by a unique tag.
    static NSUInteger const kBlogTitleLabelTag = 2;
    static NSUInteger const kDateLabelTag = 3;
    static NSUInteger const kArticleTitleLabelTag = 4;
    static NSUInteger const kBlogImageTag = 5;
    
    // Declare references to the subviews which will display the flu data.
    UILabel *blogTitleLabel = nil;
    UILabel *dateLabel = nil;
    UILabel *articleTitleLabel = nil;
    UIImageView *blogImage = nil;    
    
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] autorelease];
        
        articleTitleLabel = [[[UILabel alloc] initWithFrame:CGRectMake(10, 3, 280, 50)] autorelease];
        articleTitleLabel.tag = kArticleTitleLabelTag;
        articleTitleLabel.font = [UIFont boldSystemFontOfSize:14];
        articleTitleLabel.lineBreakMode=UILineBreakModeWordWrap;
        articleTitleLabel.numberOfLines=0;
        //articleTitleLabel.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
        [cell.contentView addSubview:articleTitleLabel];

        blogTitleLabel = [[[UILabel alloc] initWithFrame:CGRectMake(10, 65, 220, 15)] autorelease];
        blogTitleLabel.tag = kBlogTitleLabelTag;
        blogTitleLabel.font = [UIFont systemFontOfSize:12];
        blogTitleLabel.textColor = [UIColor greenColor];
        [cell.contentView addSubview:blogTitleLabel];

        dateLabel = [[[UILabel alloc] initWithFrame:CGRectMake(240, 60, 120, 20)] autorelease];
        dateLabel.tag = kDateLabelTag;
        dateLabel.font = [UIFont systemFontOfSize:12];
        dateLabel.autoresizingMask=UIViewAutoresizingFlexibleRightMargin;
        dateLabel.textColor = [UIColor blueColor];
        [cell.contentView addSubview:dateLabel];

        
        blogImage = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"DisclosureIndicator.png"]] autorelease];
        CGRect imageFrame = blogImage.frame;
        imageFrame.origin = CGPointMake(285, 32);
        blogImage.frame = imageFrame;
        blogImage.tag = kBlogImageTag;
        blogImage.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
        [cell.contentView addSubview:blogImage];   
    }
    else{
        // A reusable cell was available, so we just need to get a reference to the subviews
        // using their tags.
        //
        blogTitleLabel = (UILabel *)[cell.contentView viewWithTag:kBlogTitleLabelTag];
        dateLabel = (UILabel *)[cell.contentView viewWithTag:kDateLabelTag];
        articleTitleLabel = (UILabel *)[cell.contentView viewWithTag:kArticleTitleLabelTag];
        blogImage = (UIImageView *)[cell.contentView viewWithTag:kBlogImageTag];        
    }
    
    //Feeding cells
    
    RSSEntry *entry = [_allEntries objectAtIndex:indexPath.row];
    
    NSDateFormatter * dateFormatter = [[[NSDateFormatter alloc] init] autorelease];
    [dateFormatter setDateFormat:@"MMM d YYYY"];
    //[dateFormatter setTimeStyle:NSDateFormatterMediumStyle];
    //[dateFormatter setDateStyle:NSDateFormatterMediumStyle];
    NSString *articleDateString = [dateFormatter stringFromDate:entry.articleDate];
    
    //cell.textLabel.text = entry.activityLevel;
    //cell.detailTextLabel.text = [NSString stringWithFormat:@"%@ - %@", articleDateString, entry.stateName];
    
    //----------------------------------------------------------
    
    /*
	 If the requesting table view is the search display controller's table view, configure the cell using the filtered content, otherwise use the main list.
	 */
	RSSEntry *entrant = nil;
	if (searching)
	{
        entrant = [copyListOfItems objectAtIndex:indexPath.row];
    }
	else
	{
        entrant = [_allEntries objectAtIndex:indexPath.row];
    }
	
    if (entrant.ispodcast > 0){
        blogTitleLabel.textColor = [UIColor orangeColor];        
        blogTitleLabel.text=@"CDC Podcast";
    }
    else{
        blogTitleLabel.textColor = [UIColor redColor];        
        blogTitleLabel.text=@"CDC News";
    }
    
    articleTitleLabel.text=entrant.articleTitle;
    dateLabel.text=articleDateString;
    //activityImage.image = [self imageForString:entrant.activityLevel];    
    /*activityLabel.text=entry.activityLevel;
     locationLabel.text=entry.stateName;
     dateLabel.text=articleDateString;*/        
    
    return cell;        
    
    
    
   /* static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] autorelease];
    }
    
    RSSEntry *entry = [_allEntries objectAtIndex:indexPath.row];
    
    NSDateFormatter * dateFormatter = [[[NSDateFormatter alloc] init] autorelease];
    [dateFormatter setTimeStyle:NSDateFormatterMediumStyle];
    [dateFormatter setDateStyle:NSDateFormatterMediumStyle];
    NSString *articleDateString = [dateFormatter stringFromDate:entry.articleDate];
    
    
    RSSEntry *entrant = nil;
	if (searching)
	{
        entrant = [copyListOfItems objectAtIndex:indexPath.row];
    }
	else
	{
        entrant = [_allEntries objectAtIndex:indexPath.row];
    }    
    
    cell.textLabel.text = entrant.articleTitle;        
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%@ - %@", articleDateString, entrant.blogTitle];
    
    return cell; */

    
    
}



- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

/*
 - (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
 {
 // Return YES for supported orientations
 return (interfaceOrientation == UIInterfaceOrientationPortrait);
 }
 */

- (void)toggleHelpRSS{
	Helper *helpView= [[Helper alloc] initWithNibName:@"Helper" bundle:nil];
    
	UIImageView *imageView1 = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"FluNewsAbout.png"]] autorelease];
	
	// in a real app, you most likely want to have an array of view controllers, not views;
	// also should be instantiating those views and view controllers lazily
	helpView.pageViews = [[NSArray alloc] initWithObjects:imageView1, nil];    
    helpView.navigationTitle=@"Flu News Help";    
	[self.navigationController pushViewController:helpView animated:YES];
	[helpView release]; 
}


#pragma mark -
#pragma mark Searching Procedures

//RootViewController.m
- (void) searchBarTextDidBeginEditing:(UISearchBar *)theSearchBar {
    
    if (searching) {
        return;
    }
    
	
	//Add the overlay view.
	if(ovController == nil)
		ovController = [[OverlayViewController alloc] initWithNibName:@"OverlayView" bundle:[NSBundle mainBundle]];
	
	CGFloat yaxis = self.navigationController.navigationBar.frame.size.height;
	CGFloat width = self.view.frame.size.width;
	CGFloat height = self.view.frame.size.height;
	
	//Parameters x = origion on x-axis, y = origon on y-axis.
	CGRect frame = CGRectMake(0, yaxis, width, height);
	ovController.view.frame = frame;	
	ovController.view.backgroundColor = [UIColor grayColor];
	ovController.view.alpha = 0.5;
	
	ovController.fnController = self;
	
	[self.tableView insertSubview:ovController.view aboveSubview:self.parentViewController.view];
	
	searching = YES;
	letUserSelectRow = NO;
	self.tableView.scrollEnabled = NO;
	
	//Add the done button.
	self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc] 
											   initWithBarButtonSystemItem:UIBarButtonSystemItemDone 
											   target:self action:@selector(doneSearching_Clicked:)] autorelease];
}

//RootViewController.m
- (void)searchBar:(UISearchBar *)theSearchBar textDidChange:(NSString *)searchText {
    
	//Remove all objects first.
	[copyListOfItems removeAllObjects];
	
	if([searchText length] > 0) {
		
		[ovController.view removeFromSuperview];
		searching = YES;
		letUserSelectRow = YES;
		self.tableView.scrollEnabled = YES;
		[self searchTableView];
	}
	else {
		
		[self.tableView insertSubview:ovController.view aboveSubview:self.parentViewController.view];
		
		searching = NO;
		letUserSelectRow = NO;
		self.tableView.scrollEnabled = NO;
	}
	
	[self.tableView reloadData];
    
}

//RootViewController.m
- (void) searchBarSearchButtonClicked:(UISearchBar *)theSearchBar {
    
    [self searchTableView];
}

- (void) searchTableView {
    
    NSString *searchText = searchBar.text;
    /*
     for (NSDictionary *dictionary in _allEntries)
     {
     NSArray *array = [dictionary objectForKey:@"States"];
     [searchArray addObjectsFromArray:array];
     }*/
    
	for (RSSEntry *product in _allEntries)
	{
		//if ([product.stateName isEqualToString:searchText]||[product.activityLevel isEqualToString:searchText]){
        NSRange range1 = [product.articleTitle rangeOfString:searchText options:(NSCaseInsensitiveSearch|NSDiacriticInsensitiveSearch)];
        NSRange range2 = [product.blogTitle rangeOfString:searchText options:(NSCaseInsensitiveSearch|NSDiacriticInsensitiveSearch)];        
       /* NSComparisonResult result1 = [product.articleTitle compare:searchText options:(NSCaseInsensitiveSearch|NSDiacriticInsensitiveSearch) range:NSMakeRange(0, [searchText length])];
        NSComparisonResult result2 = [product.blogTitle compare:searchText options:(NSCaseInsensitiveSearch|NSDiacriticInsensitiveSearch) range:NSMakeRange(0, [searchText length])];        
        if ((result1 == NSOrderedSame)||(result2 == NSOrderedSame))
        {
            [copyListOfItems addObject:product];
        }*/
        if ((range1.length>0)||(range2.length>0))
        {
            [copyListOfItems addObject:product];
        }        
		//}
	} 
    
    /*
     for (NSString *sTemp in _allEntries)
     {
     
     NSRange titleResultsRange = [sTemp rangeOfString:searchText options:NSCaseInsensitiveSearch];        
     
     if (titleResultsRange.length > 0)
     [copyListOfItems addObject:sTemp];
     }*/
}

//RootViewController.m
- (void) doneSearching_Clicked:(id)sender {
    
	
	searchBar.text = @"";
	[searchBar resignFirstResponder];
	
	letUserSelectRow = YES;
	searching = NO;
	self.navigationItem.rightBarButtonItem = nil;
	self.tableView.scrollEnabled = YES;
	
	[ovController.view removeFromSuperview];
	[ovController release];
	ovController = nil;
    
    //Wee need to bring help button back
    // Do any additional setup after loading the view from its nib.
	UIBarButtonItem *helpButton = [[UIBarButtonItem alloc] initWithTitle:@"Help" style:UIBarButtonItemStyleBordered target:self action:@selector(toggleHelpRSS)];
	//[helpButton setTitle:@"About"];
	self.navigationItem.rightBarButtonItem = helpButton;
	[helpButton release];    
    
	
	[self.tableView reloadData];
}

-(NSString*)stringBetweenString:(NSString*)thestring startstring:(NSString*)start endString:(NSString*)end{
    NSScanner* scanner = [NSScanner scannerWithString:thestring];
    [scanner setCharactersToBeSkipped:nil];
    [scanner scanUpToString:start intoString:NULL];
    if ([scanner scanString:start intoString:NULL]) {
        NSString* result = nil;
        if ([scanner scanUpToString:end intoString:&result]) {
            return result;
        }
    }
    return nil; 
}


@end
