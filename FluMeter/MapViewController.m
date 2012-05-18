/*
     File: MapViewController.m 
 Abstract: The primary view controller containing the MKMapView, adding and removing both MKPinAnnotationViews through its toolbar. 
  Version: 1.2 
  
 Disclaimer: IMPORTANT:  This Apple software is supplied to you by Apple 
 Inc. ("Apple") in consideration of your agreement to the following 
 terms, and your use, installation, modification or redistribution of 
 this Apple software constitutes acceptance of these terms.  If you do 
 not agree with these terms, please do not use, install, modify or 
 redistribute this Apple software. 
  
 In consideration of your agreement to abide by the following terms, and 
 subject to these terms, Apple grants you a personal, non-exclusive 
 license, under Apple's copyrights in this original Apple software (the 
 "Apple Software"), to use, reproduce, modify and redistribute the Apple 
 Software, with or without modifications, in source and/or binary forms; 
 provided that if you redistribute the Apple Software in its entirety and 
 without modifications, you must retain this notice and the following 
 text and disclaimers in all such redistributions of the Apple Software. 
 Neither the name, trademarks, service marks or logos of Apple Inc. may 
 be used to endorse or promote products derived from the Apple Software 
 without specific prior written permission from Apple.  Except as 
 expressly stated in this notice, no other rights or licenses, express or 
 implied, are granted by Apple herein, including but not limited to any 
 patent rights that may be infringed by your derivative works or by other 
 works in which the Apple Software may be incorporated. 
  
 The Apple Software is provided by Apple on an "AS IS" basis.  APPLE 
 MAKES NO WARRANTIES, EXPRESS OR IMPLIED, INCLUDING WITHOUT LIMITATION 
 THE IMPLIED WARRANTIES OF NON-INFRINGEMENT, MERCHANTABILITY AND FITNESS 
 FOR A PARTICULAR PURPOSE, REGARDING THE APPLE SOFTWARE OR ITS USE AND 
 OPERATION ALONE OR IN COMBINATION WITH YOUR PRODUCTS. 
  
 IN NO EVENT SHALL APPLE BE LIABLE FOR ANY SPECIAL, INDIRECT, INCIDENTAL 
 OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF 
 SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS 
 INTERRUPTION) ARISING IN ANY WAY OUT OF THE USE, REPRODUCTION, 
 MODIFICATION AND/OR DISTRIBUTION OF THE APPLE SOFTWARE, HOWEVER CAUSED 
 AND WHETHER UNDER THEORY OF CONTRACT, TORT (INCLUDING NEGLIGENCE), 
 STRICT LIABILITY OR OTHERWISE, EVEN IF APPLE HAS BEEN ADVISED OF THE 
 POSSIBILITY OF SUCH DAMAGE. 
  
 Copyright (C) 2010 Apple Inc. All Rights Reserved. 
  
*/

#import "MapViewController.h"
#import "DetailViewController.h"
#import "FSEntry.h"
#import "FSMyself.h"
#import "ASIHTTPRequest.h"
#import "GDataXMLNode.h"
#import "GDataXMLElement-Extras.h"
#import "NSDate+InternetDateTime.h"
#import "NSArray+Extras.h"
#import "JSON.h"
#import "DSActivityView.h"

enum
{
    kCityAnnotationIndex = 0,
    kBridgeAnnotationIndex
};

@implementation MapViewController

@synthesize mapView, detailViewController, mapAnnotations; 
//@synthesize fluShotLocator;
@synthesize latitude;
@synthesize longitude;
@synthesize address=_address;
@synthesize allEntries=_allEntries;
@synthesize feeds = _feeds;
@synthesize queue = _queue;
@synthesize zip=_zip;

- (void)dealloc 
{
    [mapView release];
    [detailViewController release];
    [mapAnnotations release];
    //[fluShotLocator release];
    //fluShotLocator=nil;
    [latitude release];
    [longitude release];
    [_address release];
    [_allEntries release];
    _allEntries = nil;    
    [_queue release];
    _queue = nil;
    [_feeds release];
    _feeds = nil;
    [_zip release];
    
    [super dealloc];    
}

#pragma mark -

+ (CGFloat)annotationPadding;
{
    return 10.0f;
}
+ (CGFloat)calloutHeight;
{
    return 40.0f;
}

- (void)gotoLocation
{
    // start off by default in San Francisco
    MKCoordinateRegion newRegion;
    newRegion.center.latitude = [self.latitude floatValue];
    newRegion.center.longitude = [self.longitude floatValue];
    newRegion.span.latitudeDelta = 4*0.112872;
    newRegion.span.longitudeDelta = 4*0.109863;

    [self.mapView setRegion:newRegion animated:YES];
}

- (void)viewDidAppear:(BOOL)animated
{
    // bring back the toolbar
    //[self.navigationController setToolbarHidden:NO animated:NO];
    [self gotoLocation];    // finally goto San Francisco    
    [DSBezelActivityView newActivityViewForView:self.view];
}

- (void)viewDidLoad
{
	mapView = [[MKMapView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
	[self.view addSubview:mapView];
	[mapView setDelegate:self];    
    self.mapView.mapType = MKMapTypeStandard;   // also MKMapTypeSatellite or MKMapTypeHybrid    
    self.allEntries=[[NSMutableArray alloc] initWithCapacity:10];
    self.mapAnnotations=[[NSMutableArray alloc] initWithCapacity:10];
    [self updateWithLatitude:latitude longitude:longitude];
    
    // create a custom navigation bar button and set it to always says "Back"
	//UIBarButtonItem *temporaryBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"i" style:UIBarButtonItemStyleBordered target:self action:@selector(gotoLocation)];
    UIBarButtonItem *temporaryBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSearch target:self action:@selector(gotoLocation)];
    self.navigationItem.title = @"Vaccinate!";
	self.navigationItem.rightBarButtonItem = temporaryBarButtonItem;
	[temporaryBarButtonItem release];    
    
    /*
    // create a custom navigation bar button and set it to always says "Back"
	UIBarButtonItem *temporaryBarButtonItem = [[UIBarButtonItem alloc] init];
	temporaryBarButtonItem.title = @"Back";
	self.navigationItem.backBarButtonItem = temporaryBarButtonItem;
	[temporaryBarButtonItem release];*/

        /*
    if (self.fluShotLocator==nil) {
        FSLocator *fsl=[[FSLocator alloc] init];
        self.fluShotLocator=fsl;
        [fsl release];
    }
    [fluShotLocator updateWithLatitude:self.latitude longitude:self.longitude];
    */

    [[NSNotificationCenter defaultCenter]
     addObserver:self
     selector:@selector(fluShotLocationsReceived:)
     name:@"gotFluShotPlaces"
     object:nil]; 
}

- (void)viewDidUnload
{
    self.mapAnnotations = nil;
    self.detailViewController = nil;
    self.mapView = nil;
}


#pragma mark -
#pragma mark ButtonActions

- (IBAction)cityAction:(id)sender
{
    [self gotoLocation];//•• avoid this by checking its region from ours??
    
    [self.mapView removeAnnotations:self.mapView.annotations];  // remove any annotations that exist
    
    [self.mapView addAnnotation:[self.mapAnnotations objectAtIndex:kCityAnnotationIndex]];
}

- (IBAction)bridgeAction:(id)sender
{
    [self gotoLocation];
    [self.mapView removeAnnotations:self.mapView.annotations];  // remove any annotations that exist
    
    [self.mapView addAnnotation:[self.mapAnnotations objectAtIndex:kBridgeAnnotationIndex]];
}

- (IBAction)allAction:(id)sender
{
    [self gotoLocation];
    [self.mapView removeAnnotations:self.mapView.annotations];  // remove any annotations that exist
    
    [self.mapView addAnnotations:self.mapAnnotations];
}

#pragma mark -
#pragma mark MKMapViewDelegate

- (void)showDetails:(id)sender
{
    // the detail view does not want a toolbar so hide it
    //[self.navigationController setToolbarHidden:YES animated:NO];
    
    [self.navigationController pushViewController:self.detailViewController animated:YES];
}

- (MKAnnotationView *)mapView:(MKMapView *)theMapView viewForAnnotation:(id <MKAnnotation>)annotation
{
    static NSString *identifier = @"MyLocation";   
    if ([annotation isKindOfClass:[FSEntry class]]) {
        FSEntry *location = (FSEntry *) annotation;
        
        MKPinAnnotationView *annotationView = (MKPinAnnotationView *) [mapView dequeueReusableAnnotationViewWithIdentifier:identifier];
        if (annotationView == nil) {
            annotationView = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:identifier];
        } else {
            annotationView.annotation = annotation;
        }
        
        annotationView.enabled = YES;
        annotationView.canShowCallout = YES;        
        annotationView.animatesDrop = YES;
        annotationView.pinColor = MKPinAnnotationColorRed;
        return annotationView;
    }
    else if ([annotation isKindOfClass:[FSMyself class]]) {
        FSEntry *location = (FSEntry *) annotation;
        
        MKPinAnnotationView *annotationView = (MKPinAnnotationView *) [mapView dequeueReusableAnnotationViewWithIdentifier:identifier];
        if (annotationView == nil) {
            annotationView = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:identifier];
        } else {
            annotationView.annotation = annotation;
        }
        
        annotationView.enabled = YES;
        annotationView.canShowCallout = YES;        
        annotationView.animatesDrop = YES;        
        annotationView.pinColor = MKPinAnnotationColorPurple;        
        
        return annotationView;
    }
    return nil;    
}

-(void)fluShotLocationsReceived: (NSNotification *) notification
{
    NSLog(@"FLU SHOT LOCATIONS RECEIVED!!!");

    FSMyself *myLocationAnnotation = [[[FSMyself alloc] initWithEntryName:@"You" 
                                                          entryAddress:@"" 
                                                        entryTelephone:@"You" 
                                                      entryDescribtion:@"You" 
                                                              entryWeb:@"You" 
                                                         entryLatitude:self.latitude 
                                                        entryLongitude:self.longitude] autorelease];
/*    
    [self.mapAnnotations addObject:myLocationAnnotation];
    NSLog(@"total locations received: %d",[self.mapAnnotations count]);
    [mapView addAnnotations:myLocationAnnotation];
 */
    [mapView addAnnotation:myLocationAnnotation];
    [myLocationAnnotation release];
    
    [self gotoLocation];    // finally goto San Francisco
    
    [DSBezelActivityView removeViewAnimated:NO];
}

#pragma mark -
#pragma mark web connections services
- (void)refresh {
    
    for (NSString *feed in _feeds) {
        NSURL *url = [NSURL URLWithString:feed];
        ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
        [request setDelegate:self];
        [_queue addOperation:request];
    }
    
}

-(id)initWithZip:(NSString*)zipcode{
    _zip=zipcode;
    
    //http://local.yahooapis.com/LocalSearchService/V3/localSearch?appid=c8eGOK3c&output=xml&query=flu&context=get+flu+shot&zip=99163&results=10
    /* NSString *head = @"http://local.yahooapis.com/LocalSearchService/V3/localSearch?appid=c8eGOK3c&output=xml&query=flu&context=get+flu+shot&zip=";
     NSString *tail = @"&results=10";
     NSString *concat = [[head stringByAppendingString:zipcode] stringByAppendingString:tail];
     self.feeds = [NSArray arrayWithObjects:concat,
     nil];        
     [self refresh];    */
    //allEntries = [[NSMutableArray alloc] init];    
    
    return self;
}

- (void)update:(NSString *)zipcode{
    _zip=zipcode;    
    //http://local.yahooapis.com/LocalSearchService/V3/localSearch?appid=c8eGOK3c&output=xml&query=flu&context=get+flu+shot&zip=99163&results=10
    NSString *head = @"http://local.yahooapis.com/LocalSearchService/V3/localSearch?appid=c8eGOK3c&output=xml&query=flu&context=get+flu+shot&radius=10&zip=";
    NSString *tail = @"&results=10";
    NSString *concat = [[head stringByAppendingString:zipcode] stringByAppendingString:tail];
    self.queue = [[[NSOperationQueue alloc] init] autorelease];
    self.feeds = [NSArray arrayWithObjects:concat,
                  nil];    
    [self refresh];       
}

-(void)updateWithLatitude:(NSString*)latit longitude:(NSString*)longit{
    self.latitude=latit;
    self.longitude=longit;
    NSString *head = @"http://local.yahooapis.com/LocalSearchService/V3/localSearch?appid=c8eGOK3c&output=xml&query=flu&context=get+flu+shot&latitude=";
    NSString *tail = @"&results=10";
    NSString *concat = [[[[head stringByAppendingString:latit] stringByAppendingString:@"&longitude="] stringByAppendingString:longit] stringByAppendingString:tail];
    self.queue = [[[NSOperationQueue alloc] init] autorelease];
    self.feeds = [NSArray arrayWithObjects:concat,
                  nil];    
    [self refresh];       
}

- (void)parseFs:(GDataXMLElement *)rootElement entries:(NSMutableArray *)entries {
    
    NSArray *results = [rootElement elementsForName:@"Result"];
    for (GDataXMLElement *result in results) {            
        
        NSString *entryName = [result valueForChild:@"Title"];
        NSString *entryAddress = [result valueForChild:@"Address"];
        NSString *entryTelephone = [result valueForChild:@"Phone"];
        NSString *entryDescribtion = [result valueForChild:@"City"];    
        NSString *entryWeb = [result valueForChild:@"www.yahoo.com"];
        NSString *entryLatitude = [result valueForChild:@"Latitude"];        
        NSString *entryLongitude = [result valueForChild:@"Longitude"];        
        NSLog(@"%@ %@",entryLatitude,entryLongitude);
        /* FSEntry *entry = [[[FSEntry alloc] initWithBlogTitle:blogTitle 
         articleTitle:articleTitle 
         articleUrl:articleUrl 
         articleDate:articleDate 
         podcast:isPodcast] autorelease];
         */
        
        FSEntry *entry = [[FSEntry alloc] initWithEntryName:entryName 
                                               entryAddress:entryAddress 
                                             entryTelephone:entryTelephone 
                                           entryDescribtion:entryDescribtion 
                                                   entryWeb:entryWeb 
                                              entryLatitude:entryLatitude 
                                             entryLongitude:entryLongitude];
        
        [entries addObject:entry];
        [self.mapAnnotations addObject:entry];
        [mapView addAnnotation:entry];
        [entry release];
    }      
    
    //Push Notification!
    [[NSNotificationCenter defaultCenter]
     postNotificationName:@"gotFluShotPlaces"
     object:nil ];       
}


- (void)parseFeed:(GDataXMLElement *)rootElement entries:(NSMutableArray *)entries {  
    [self parseFs:rootElement entries:entries];
    /* if ([rootElement.name compare:@"rss"] == NSOrderedSame) {
     [self parseRss:rootElement entries:entries];
     } else if ([rootElement.name compare:@"feed"] == NSOrderedSame) {                       
     [self parseAtom:rootElement entries:entries];
     } else {
     NSLog(@"Unsupported root element: %@", rootElement.name);
     }    */
    //[DSBezelActivityView removeViewAnimated:NO];    
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
                
                for (FSEntry *entry in entries) {
                    
                    int insertIdx = [[self allEntries] indexForInsertingObject:entry sortedUsingBlock:^(id a, id b) {
                        FSEntry *entry1 = (FSEntry *) a;
                        FSEntry *entry2 = (FSEntry *) b;
                        return [entry2.entryName compare:entry1.entryName];
                    }];
                    
                    [[self allEntries] insertObject:entry atIndex:insertIdx];                    
                }                            
                
            }];
            
        }        
    }];
}



- (void)requestFailed:(ASIHTTPRequest *)request {
    NSError *error = [request error];
    NSLog(@"Error: %@", error);
}


@end
