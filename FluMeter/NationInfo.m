//
//  NationInfo.m
//  FluMeter
//
//  Created by nikolay on 5/17/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "NationInfo.h"
#import "OverlayViewController.h"

#import "XMLEntry.h"
#import "RSSEntry.h"
#import "ASIHTTPRequest.h"
#import "GDataXMLNode.h"
#import "GDataXMLElement-Extras.h"
#import "NSDate+InternetDateTime.h"
#import "NSArray+Extras.h"
#import "XMLReader.h"
#import "DSActivityView.h"

@implementation NationInfo
@synthesize allEntries = _allEntries;
@synthesize feeds = _feeds;
@synthesize queue = _queue;
@synthesize stateF;
@synthesize webViewController = _webViewController;

#pragma mark -
#pragma mark View lifecycle

// Based on the magnitude of the earthquake, return an image indicating its seismic strength.
/*
-(UIImage *)imageForString:(NSString *)string{
    if ([string compare:@"Local"]==NSOrderedSame) {
		return [UIImage imageNamed:@"IndicatorLocal.png"];
	}
	if ( [string compare:@"Widespread"]==NSOrderedSame) {
		return [UIImage imageNamed:@"IndicatorWidespread.png"];	
	}
	if ([string compare:@"Regional"]==NSOrderedSame) {
		return [UIImage imageNamed:@"IndicatorRegional.png"];
	}
	if ([string compare:@"Sporadic"]==NSOrderedSame) {
		return [UIImage imageNamed:@"IndicatorSporadic.png"];
	}
	return [UIImage imageNamed:@"IndicatorNoActivity.png"];
}*/

-(UIImage *)imageForString:(NSString *)string{
    if ([string compare:@"Sporadic"]==NSOrderedSame) {
        return [UIImage imageNamed:@"2.0.png"];        
	}
    if ([string compare:@"Local"]==NSOrderedSame) {
		return [UIImage imageNamed:@"3.0.png"];    	
	}
	if ([string compare:@"Regional"]==NSOrderedSame) {
		return [UIImage imageNamed:@"4.0.png"];
	}
	if ( [string compare:@"Widespread"]==NSOrderedSame) {
		return [UIImage imageNamed:@"5.0.png"];
	}
	return [UIImage imageNamed:@"1.0.png"];
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

- (void)dealloc
{
    [super dealloc];
    [_allEntries release];
    _allEntries = nil;
    [_queue release];
    _queue = nil;
    [_feeds release];
    _feeds = nil;        
	[ovController release];
	[copyListOfItems release];
	[searchBar release];    
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];

//--------
    // Do any additional setup after loading the view from its nib.
	UIBarButtonItem *helpButton = [[UIBarButtonItem alloc] initWithTitle:@"Help" style:UIBarButtonItemStyleBordered target:self action:@selector(toggleHelpXML)];
	//[helpButton setTitle:@"About"];
	self.navigationItem.rightBarButtonItem = helpButton;
	[helpButton release];
    
    //self.title = @"Feeds";
    self.allEntries = [NSMutableArray array];
    self.queue = [[[NSOperationQueue alloc] init] autorelease];
    self.feeds = [NSArray arrayWithObjects:@"http://www.cdc.gov/flu/weekly/flureport.xml",
                  nil];
    /*
    NSArray *countriesToLiveInArray = [NSArray arrayWithObjects:@"Iceland", @"Greenland", @"Switzerland", @"Norway", @"New Zealand", @"Greece", @"Rome", @"Ireland", nil];
    NSDictionary *countriesToLiveInDict = [NSDictionary dictionaryWithObject:countriesToLiveInArray forKey:@"States"];
    
    NSArray *countriesLivedInArray = [NSArray arrayWithObjects:@"India", @"U.S.A", nil];
    NSDictionary *countriesLivedInDict = [NSDictionary dictionaryWithObject:countriesLivedInArray forKey:@"States"];    
    
    [listOfItems addObject:countriesToLiveInDict];
    [listOfItems addObject:countriesLivedInDict]; */
    
    //Initialize the array.
    //_allEntries = [[NSMutableArray alloc] init];    
    
    
    
    //Initialize the copy array.
    copyListOfItems = [[NSMutableArray alloc] init];    
    
    //[DSBezelActivityView setAnimationsEnabled:YES];
    [DSBezelActivityView newActivityViewForView:self.view];
    
    
    stateF = @"[AL,Alabama,AL],"
    "[AK,Alaska,AK],"
    "[AZ,Arizona,AZ],"
    "[AR,Arkansas,AR],"
    "[CA,California,CA],"
    "[CO,Colorado,CO],"
    "[CT,Connecticut,CT],"
    "[DE,Delaware,DE],"
    "[FL,Florida,FL],"
    "[GA,Georgia,GA],"
    "[HI,Hawaii,HI],"
    "[ID,Idaho,ID],"
    "[IL,Illinois,IL],"
    "[IN,Indiana,IN],"
    "[IA,Iowa,IA],"
    "[KS,Kansas,KS],"
    "[KY,Kentucky,KY],"
    "[LA,Louisiana,LA],"
    "[ME,Maine,ME],"
    "[MD,Maryland,MD],"
    "[MA,Massachusetts,MA],"
    "[MI,Michigan,MI],"
    "[MN,Minnesota,MN],"
    "[MS,Mississippi,MS],"
    "[MO,Missouri,MO],"
    "[MT,Montana,MT],"
    "[NE,Nebraska,NE],"
    "[NV,Nevada,NV],"
    "[NH,New Hampshire,NH],"
    "[NJ,New Jersey,NJ],"
    "[NM,New Mexico,NM],"
    "[NY,New York,NY],"
    "[NC,North Carolina,NC],"
    "[ND,North Dakota,ND],"
    "[OH,Ohio,OH],"
    "[OK,Oklahoma,OK],"
    "[OR,Oregon,OR],"
    "[PA,Pennsylvania,PA],"
    "[RI,Rhode Island,RI],"
    "[SC,South Carolina,SC],"
    "[SD,South Dakota,SD],"
    "[TN,Tennessee,TN],"
    "[TX,Texas,TX],"
    "[UT,Utah,UT],"
    "[VT,Vermont,VT],"
    "[VA,Virginia,VA],"
    "[WA,Washington,WA],"
    "[WV,West Virginia,WV],"
    "[WI,Wisconsin,WI],"
    "[WY,Wyoming,WY],"
    "[PR,Puerto Rico,PR],"
    "[VI,Virgin Islands,VI],"
    "[DC,District of Columbia,DC],"
    "[GU,Guam,GU],";
    
//--------    
    
    //Set the title
    self.navigationItem.title = @"Nationwide Info";
    
    //Add the search bar
    self.tableView.tableHeaderView = searchBar;
    searchBar.autocorrectionType = UITextAutocorrectionTypeNo;
    
    searching = NO;
    letUserSelectRow = YES;    

    [self refresh];        
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
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
#pragma mark Request Callbacks

- (void)parseXML:(GDataXMLElement *)rootElement entries:(NSMutableArray *)entries {
    NSArray *timeperiods = [rootElement elementsForName:@"timeperiod"];
    // Convert string to date object
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    //subtitle="Week Ending May 07, 2011- Week 18"
    //[dateFormatter setDateFormat:@"'Week Ending 'MMMM' 'd', 'YYYY'- Week 'w"];
    [dateFormatter setDateFormat:@"MMMM dd YYYY w"];
    GDataXMLElement *timeperiod=[timeperiods lastObject];
    NSArray *states = [timeperiod elementsForName:@"state"];        
    //subtitle = May 07 2011 18
    NSString *subtitle = [[timeperiod attributeForName:@"subtitle"] stringValue];        
    NSString *stateName = nil;
    NSString *activityLevel = nil;        
    subtitle=[subtitle stringByReplacingOccurrencesOfString:@"Week Ending " withString:@""];
    subtitle=[subtitle stringByReplacingOccurrencesOfString:@"- Week" withString:@""];
    subtitle=[subtitle stringByReplacingOccurrencesOfString:@"," withString:@""];
    NSDate *dateOfReport = [dateFormatter dateFromString:subtitle];
    
    // Convert date object to desired output format  
    for (GDataXMLElement *state in states) {
        stateName = [state valueForChild:@"abbrev"];
        activityLevel = [state valueForChild:@"label"];
        
        stateName = [self stringBetweenString:stateF 
                                  startstring:[[@"[" stringByAppendingString:stateName] stringByAppendingString:@","]
                                    endString:[[@"," stringByAppendingString:stateName] stringByAppendingString:@"]"]];
        
        XMLEntry *entry = [[[XMLEntry alloc] initWithStateTitle:stateName 
                                                  activityLevel:activityLevel 
                                                     reportDate:dateOfReport] 
                           autorelease];
        [entries addObject:entry];            
    }
    [dateFormatter release];

    //Remove Activity View
    [DSBezelActivityView removeViewAnimated:NO];
    
}


- (void)parseFeed:(GDataXMLElement *)rootElement entries:(NSMutableArray *)entries {    
    [self parseXML:rootElement entries:entries];
    /*
     if ([rootElement.name compare:@"rss"] == NSOrderedSame) {
     [self parseRss:rootElement entries:entries];
     } else if ([rootElement.name compare:@"feed"] == NSOrderedSame) {                       
     [self parseAtom:rootElement entries:entries];
     } else {
     NSLog(@"Unsupported root element: %@", rootElement.name);
     }*/    
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
            [doc release];
            [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                
                for (XMLEntry *entry in entries) {
                    
                    int insertIdx = [_allEntries indexForInsertingObject:entry sortedUsingBlock:^(id a, id b) {
                        XMLEntry *entry1 = (XMLEntry *) a;
                        XMLEntry *entry2 = (XMLEntry *) b;
                        return [entry2.stateName compare:entry1.stateName];
                    }];
                    
                    [_allEntries insertObject:entry atIndex:insertIdx];
                    [self.tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:insertIdx inSection:0]]
                                          withRowAnimation:UITableViewRowAnimationRight];                    
                    
                }                            
                
            }];
            
        }        
    }]; 
    [self.tableView reloadData];
    
}

- (void)requestFailed:(ASIHTTPRequest *)request {
    NSError *error = [request error];
    NSLog(@"Error: %@", error);
}



#pragma mark - Table view data source


//RootViewController.m
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
    static NSUInteger const kLocationLabelTag = 2;
    static NSUInteger const kDateLabelTag = 3;
    static NSUInteger const kActivityLabelTag = 4;
    static NSUInteger const kActivityImageTag = 5;
    static NSUInteger const kDisclosureImageTag = 6;
    
    // Declare references to the subviews which will display the flu data.
    UILabel *locationLabel = nil;
    UILabel *dateLabel = nil;
    UILabel *activityLabel = nil;
    UIImageView *activityImage = nil;    
    UIImageView *disclosureImage = nil;    
    
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] autorelease];
        locationLabel = [[[UILabel alloc] initWithFrame:CGRectMake(10, 3, 190, 20)] autorelease];
        locationLabel.tag = kLocationLabelTag;
        locationLabel.font = [UIFont boldSystemFontOfSize:17];
        [cell.contentView addSubview:locationLabel];
        
        dateLabel = [[[UILabel alloc] initWithFrame:CGRectMake(10, 28, 170, 14)] autorelease];
        dateLabel.tag = kDateLabelTag;
        dateLabel.font = [UIFont systemFontOfSize:13];
        [cell.contentView addSubview:dateLabel];
        
        activityLabel = [[[UILabel alloc] initWithFrame:CGRectMake(207, 9, 120, 29)] autorelease];
        activityLabel.tag = kActivityLabelTag;
        activityLabel.font = [UIFont systemFontOfSize:14];
        activityLabel.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
        [cell.contentView addSubview:activityLabel];
        
        activityImage = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"IndicatorNoActivity.png"]] autorelease];
        CGRect imageFrame = activityImage.frame;
        imageFrame.origin = CGPointMake(85, 2);
        activityImage.frame = imageFrame;
        activityImage.tag = kActivityImageTag;
        activityImage.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
        [cell.contentView addSubview:activityImage];   
        
        disclosureImage = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"DisclosureIndicator.png"]] autorelease];
        CGRect disclosureImageFrame = disclosureImage.frame;
        disclosureImageFrame.origin = CGPointMake(285, 16);
        disclosureImage.frame = disclosureImageFrame;
        disclosureImage.tag = kDisclosureImageTag;
        disclosureImage.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
        [cell.contentView addSubview:disclosureImage];            
    }
    else{
        // A reusable cell was available, so we just need to get a reference to the subviews
        // using their tags.
        //
        locationLabel = (UILabel *)[cell.contentView viewWithTag:kLocationLabelTag];
        dateLabel = (UILabel *)[cell.contentView viewWithTag:kDateLabelTag];
        activityLabel = (UILabel *)[cell.contentView viewWithTag:kActivityLabelTag];
        activityImage = (UIImageView *)[cell.contentView viewWithTag:kActivityImageTag]; 
        disclosureImage = (UIImageView *)[cell.contentView viewWithTag:kDisclosureImageTag];
    }
    
    //Feeding cells
    
    XMLEntry *entry = [_allEntries objectAtIndex:indexPath.row];
    
    NSDateFormatter * dateFormatter = [[[NSDateFormatter alloc] init] autorelease];
    [dateFormatter setDateFormat:@"w' Week' MMM YYYY"];
    //[dateFormatter setTimeStyle:NSDateFormatterMediumStyle];
    //[dateFormatter setDateStyle:NSDateFormatterMediumStyle];
    NSString *articleDateString = [dateFormatter stringFromDate:entry.reportDate];
    
    //cell.textLabel.text = entry.activityLevel;
    //cell.detailTextLabel.text = [NSString stringWithFormat:@"%@ - %@", articleDateString, entry.stateName];
    
    //----------------------------------------------------------
    
    /*
	 If the requesting table view is the search display controller's table view, configure the cell using the filtered content, otherwise use the main list.
	 */
	XMLEntry *entrant = nil;
	if (searching)
	{
        entrant = [copyListOfItems objectAtIndex:indexPath.row];
    }
	else
	{
        entrant = [_allEntries objectAtIndex:indexPath.row];
    }
	
     activityLabel.text=entrant.activityLevel;
     locationLabel.text=entrant.stateName;
     dateLabel.text=articleDateString;    
     activityImage.image = [self imageForString:entrant.activityLevel];
    
    /*activityLabel.text=entry.activityLevel;
    locationLabel.text=entry.stateName;
    dateLabel.text=articleDateString;*/        
    
    return cell;    
    
    /*
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithFrame:CGRectZero reuseIdentifier:CellIdentifier] autorelease];
    }
    
    // Set up the cell...
    
    if(searching)
        cell.text = [copyListOfItems objectAtIndex:indexPath.row];
    else {
        
        //First get the dictionary object
        NSDictionary *dictionary = [listOfItems objectAtIndex:indexPath.section];
        NSArray *array = [dictionary objectForKey:@"States"];
        NSString *cellValue = [array objectAtIndex:indexPath.row];
        cell.text = cellValue;
    }    
    return cell; */
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    //Get the selected country
    
    XMLEntry *selectedCountry = nil;
    
    if(searching)
        selectedCountry = [copyListOfItems objectAtIndex:indexPath.row];
    else {
        /*
        NSDictionary *dictionary = [_allEntries objectAtIndex:indexPath.section];
        NSArray *array = [dictionary objectForKey:@"States"];*/
        selectedCountry = [_allEntries objectAtIndex:indexPath.row];
    }
    
    //http://www.cdc.gov/flu/weekly/weeklyarchives2010-2011/images/usmap18.jpg
    //http://www.cdc.gov/flu/weekly/weeklyarchives2010-2011/images/ILIIntensity18_small.gif
    NSDateFormatter * dateFormatter = [[[NSDateFormatter alloc] init] autorelease];
    [dateFormatter setDateFormat:@"w"];        
    NSString *usaMapURL=[[@"http://www.cdc.gov/flu/weekly/weeklyarchives2010-2011/images/usmap" stringByAppendingString:[dateFormatter stringFromDate:selectedCountry.reportDate]]stringByAppendingString:@".jpg"];
    NSString *usaILIMapURL=[[@"http://www.cdc.gov/flu/weekly/weeklyarchives2010-2011/images/ILIIntensity" stringByAppendingString:[dateFormatter stringFromDate:selectedCountry.reportDate]]stringByAppendingString:@"_small.gif"];    
    [dateFormatter setDateFormat:@"'Week ending 'MMM d YYYY 'Flu Activity'"];
    RSSEntry *dummyEntry = [[RSSEntry alloc] initWithBlogTitle:[dateFormatter stringFromDate:selectedCountry.reportDate] 
                                                   articleTitle:@"Image" 
                                                     articleUrl:usaMapURL 
                                                    articleDate:selectedCountry.reportDate
                                                       podcast:NO];
    
	if (_webViewController == nil) {
        self.webViewController = [[[WebViewController alloc] initWithNibName:@"WebViewController" bundle:[NSBundle mainBundle]] autorelease];
    }

    _webViewController.entry = dummyEntry;
    [self.navigationController pushViewController:_webViewController animated:YES];    
    
    /*
    //Initialize the detail view controller and display it.
    DetailViewController *dvController = [[DetailViewController alloc] initWithNibName:@"DetailView" bundle:[NSBundle mainBundle]];
    dvController.selectedCountry = selectedCountry;
    [self.navigationController pushViewController:dvController animated:YES];
    [dvController release];
    dvController = nil;
    */
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

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
	
	ovController.rvController = self;
	
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
    
	for (XMLEntry *product in _allEntries)
	{
		//if ([product.stateName isEqualToString:searchText]||[product.activityLevel isEqualToString:searchText]){
			NSComparisonResult result1 = [product.stateName compare:searchText options:(NSCaseInsensitiveSearch|NSDiacriticInsensitiveSearch) range:NSMakeRange(0, [searchText length])];
			NSComparisonResult result2 = [product.activityLevel compare:searchText options:(NSCaseInsensitiveSearch|NSDiacriticInsensitiveSearch) range:NSMakeRange(0, [searchText length])];        
            if ((result1 == NSOrderedSame)||(result2 == NSOrderedSame))
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
	
    //Wee need to bring back Help Button
    // Do any additional setup after loading the view from its nib.
	UIBarButtonItem *helpButton = [[UIBarButtonItem alloc] initWithTitle:@"Help" style:UIBarButtonItemStyleBordered target:self action:@selector(toggleHelpXML)];
	//[helpButton setTitle:@"About"];
	self.navigationItem.rightBarButtonItem = helpButton;
	[helpButton release];    
    
	[self.tableView reloadData];
}

#pragma mark - Table view delegate

//RootViewController.m
- (NSIndexPath *)tableView :(UITableView *)theTableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if(letUserSelectRow)
        return indexPath;
    else
        return nil;
}


#pragma mark -
#pragma Other Functions

-(void)toggleHelpXML{
	Helper *helpView= [[Helper alloc] initWithNibName:@"Helper" bundle:nil];
    
	UIImageView *imageView1 = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"NationWideAbout.png"]] autorelease];
	
	// in a real app, you most likely want to have an array of view controllers, not views;
	// also should be instantiating those views and view controllers lazily
	helpView.pageViews = [[NSArray alloc] initWithObjects:imageView1, nil];    
    helpView.navigationTitle=@"Nationwide Info Help";
	[self.navigationController pushViewController:helpView animated:YES];
	[helpView release];

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
