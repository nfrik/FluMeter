//
//  FSLocator.h
//  FluMeter
//
//  Created by nikolay on 5/30/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface FSLocator : NSObject {
    NSOperationQueue *_queue;
    NSArray *_feeds;
    // NSMutableArray *allEntries;
    NSString *_zip;
    NSString *_latitude;
    NSString *_longitude;
    
}

@property (retain) NSOperationQueue *queue;
@property (retain) NSArray *feeds;
//@property (nonatomic,retain) NSMutableArray *allEntries;
@property (retain) NSString *zip;
@property (retain) NSString *latitude;
@property (retain) NSString *longitude;
-(id)initWithZip:(NSString*)zipcode;
-(void)update:(NSString*)zipcode;
-(void)updateWithLatitude:(NSString*)latit longitude:(NSString*)longit;
-(void)copyEntrees:(NSMutableArray *)mutarray;
-(NSMutableArray*) allEntries;
@end
