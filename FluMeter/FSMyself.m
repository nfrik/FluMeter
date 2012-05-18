//
//  RSSEntry.m
//  RSSFun
//
//  Created by Ray Wenderlich on 1/24/11.
//  Copyright 2011 Ray Wenderlich. All rights reserved.
//

#import "FSMyself.h"

@implementation FSMyself

@synthesize entryName=_entryName;
@synthesize entryAddress=_entryAddress;
@synthesize entryTelephone=_entryTelephone;
@synthesize entryDescribtion=_entryDescribtion;    
@synthesize entryWeb=_entryWeb;
@synthesize entryLatitude=_entryLatitude;        
@synthesize entryLongitude=_entryLongitude;

- (id)initWithEntryName:(NSString*)entryName entryAddress:(NSString*)entryAddress entryTelephone:(NSString*)entryTelephone entryDescribtion:(NSString*)entryDescribtion entryWeb:(NSString*)entryWeb entryLatitude:(NSString*)entryLatitude entryLongitude:(NSString*)entryLongitude 
{
    if ((self = [super init])) {
        _entryName=[entryName copy];
        _entryAddress=[entryAddress copy];        
        _entryTelephone=[entryTelephone copy];                
        _entryDescribtion=[entryDescribtion copy];                
        _entryWeb=[entryWeb copy];                
        _entryLatitude = [entryLatitude copy];
        _entryLongitude = [entryLongitude copy];        
    }
    return self;
}

- (void)dealloc {
    [_entryName release];
    _entryName=nil;
    [_entryAddress release];
    _entryAddress=nil;
    [_entryTelephone release];
    _entryTelephone=nil;
    [_entryDescribtion release];
    _entryDescribtion=nil;
    [_entryWeb release];
    _entryWeb=nil;
    [_entryLatitude release];
    _entryLatitude=nil;
    [_entryLongitude release];
    _entryLongitude=nil;
    [super dealloc];
}

- (CLLocationCoordinate2D)coordinate;
{
    CLLocationCoordinate2D theCoordinate;
    theCoordinate.latitude = [self.entryLatitude floatValue];
    theCoordinate.longitude = [self.entryLongitude floatValue];
    return theCoordinate; 
}

// required if you set the MKPinAnnotationView's "canShowCallout" property to YES
- (NSString *)title
{
    return self.entryName;
}

// optional
- (NSString *)subtitle
{
    return self.entryAddress;
}

@end