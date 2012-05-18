//
//  SKProduct+LocalizedPrice.m
//  PMSHelper
//
//  Created by nikolay on 7/10/11.
//  Copyright 2011 iphonedreams.com. All rights reserved.
//

#import "SKProduct+LocalizedPrice.h"


@implementation SKProduct (LocalizedPrice)

-(NSString*)localizedPrice{
    NSNumberFormatter *numberFormatter =[[NSNumberFormatter alloc] init];
    [numberFormatter setFormatterBehavior:NSNumberFormatterBehavior10_4];
    [numberFormatter setNumberStyle:NSNumberFormatterCurrencyStyle];
    [numberFormatter setLocale:self.priceLocale];
    NSString *formattedString = [numberFormatter stringFromNumber:self.price];
    [numberFormatter release];
    return formattedString;
}

@end
