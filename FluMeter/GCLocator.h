//
//  GCLocator.h
//  FluMeter
//
//  Created by nikolay on 5/27/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface GCLocator : NSObject {
    NSString *country;
    NSString *state;
    NSString *city;
    NSString *street;
    NSString *zip;
    NSString *latitude;
    NSString *longitude;
}

@property (nonatomic,retain) NSString *country;
@property (nonatomic,retain) NSString *state;
@property (nonatomic,retain) NSString *city;
@property (nonatomic,retain) NSString *street;
@property (nonatomic,retain) NSString *zip;
@property (nonatomic,retain) NSString *latitude;
@property (nonatomic,retain) NSString *longitude;

-(id)initWithLatitudeLongitude:(NSString*)latit Longitude:(NSString*)longit;
-(void)refresh;

@end
