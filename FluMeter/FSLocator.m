//
//  FSLocator.m
//  FluMeter
//
//  Created by nikolay on 5/30/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "FSLocator.h"
#import "FSEntry.h"
#import "ASIHTTPRequest.h"
#import "GDataXMLNode.h"
#import "GDataXMLElement-Extras.h"
#import "NSDate+InternetDateTime.h"
#import "NSArray+Extras.h"
#import "JSON.h"


@implementation FSLocator
//@synthesize allEntries;
@synthesize feeds = _feeds;
@synthesize queue = _queue;
@synthesize zip=_zip;
@synthesize latitude=_latitude;
@synthesize longitude=_longitude;

-(void)dealloc{
  //  [allEntries release];
    [_queue release];
    _queue = nil;
    [_feeds release];
    _feeds = nil;
    [_zip release];
    [_latitude release];
    _latitude=nil;
    [_longitude release];
    _longitude=nil;
    [super dealloc];    
}

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
    NSString *head = @"http://local.yahooapis.com/LocalSearchService/V3/localSearch?appid=c8eGOK3c&output=xml&query=flu&context=get+flu+shot&zip=";
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

-(void)copyEntrees:(NSMutableArray *)mutarray{
    [mutarray initWithArray:self.allEntries copyItems:YES];
}

-(NSMutableArray*) allEntries
{
    static NSMutableArray* theArray = nil;
    if (theArray == nil)
    {
        theArray = [[NSMutableArray alloc] initWithCapacity:10];
    }
    return theArray;
}


- (void)requestFailed:(ASIHTTPRequest *)request {
    NSError *error = [request error];
    NSLog(@"Error: %@", error);
}

@end
