//
//  RSSEntry.m
//  RSSFun
//
//  Created by Ray Wenderlich on 1/24/11.
//  Copyright 2011 Ray Wenderlich. All rights reserved.
//

#import "XMLEntry.h"

@implementation XMLEntry
@synthesize stateName = _stateName;
@synthesize activityLevel = _activityLevel;
@synthesize reportDate = _reportDate;

- (id)initWithStateTitle:(NSString*)stateName activityLevel:(NSString*)activityLevel reportDate:(NSDate*)reportDate;
{
    if ((self = [super init])) {
        _stateName = [stateName copy];
        _activityLevel = [activityLevel copy];
        _reportDate = [reportDate copy];
    }
    return self;
}

- (void)dealloc {
    [_stateName release];
    _stateName = nil;
    [_activityLevel release];
    _activityLevel = nil;
    [_reportDate release];
    _reportDate = nil;
    [super dealloc];
}

@end