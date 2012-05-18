//  Created by Nikolay Frik on 1/24/11.
//  Copyright 2011 Nikolay Frik. All rights reserved.
//  FSEntry is a location cass.

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@interface FSMyself : NSObject <MKAnnotation>{
    NSString *_entryName;
    NSString *_entryAddress;
    NSString *_entryTelephone;
    NSString *_entryDescribtion;    
    NSString *_entryWeb;
    NSString *_entryLatitude;        
    NSString *_entryLongitude;        
}

@property (copy) NSString *entryName;
@property (copy) NSString *entryAddress;
@property (copy) NSString *entryTelephone;
@property (copy) NSString *entryDescribtion;
@property (copy) NSString *entryWeb;
@property (copy) NSString *entryLatitude;
@property (copy) NSString *entryLongitude;

- (id)initWithEntryName:(NSString*)entryName entryAddress:(NSString*)entryAddress entryTelephone:(NSString*)entryTelephone entryDescribtion:(NSString*)entryDescribtion entryWeb:(NSString*)entryWeb entryLatitude:(NSString*)entryLatitude entryLongitude:(NSString*)entryLongitude;

@end

