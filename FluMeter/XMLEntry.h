//
//  RSSEntry.h
//  RSSFun
//
//  Created by Ray Wenderlich on 1/24/11.
//  Copyright 2011 Ray Wenderlich. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface XMLEntry : NSObject {
    NSString *_stateName;
    NSString *_activityLevel;
    NSDate *_reportDate;
}

@property (copy) NSString *stateName;
@property (copy) NSString *activityLevel;
@property (copy) NSDate *reportDate;

- (id)initWithStateTitle:(NSString*)stateName activityLevel:(NSString*)activityLevel reportDate:(NSDate*)reportDate;

@end

