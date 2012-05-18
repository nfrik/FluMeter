//
//  SKProduct+LocalizedPrice.h
//  PMSHelper
//
//  Created by nikolay on 7/10/11.
//  Copyright 2011 iphonedreams.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <StoreKit/StoreKit.h>


@interface SKProduct (LocalizedPrice)
    
@property (nonatomic,retain) NSString *localizedPrice;

@end
