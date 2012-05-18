//
//  InAppPurchaseManager.h
//  PMSHelper
//
//  Created by nikolay on 7/10/11.
//  Copyright 2011 iphonedreams.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <StoreKit/StoreKit.h>

// add a couple notifications sent out when the transaction completes
#define kInAppPurchaseManagerTransactionFailedNotification @"kInAppPurchaseManagerTransactionFailedNotification"
#define kInAppPurchaseManagerTransactionSucceededNotification @"kInAppPurchaseManagerTransactionSucceededNotification"
#define kInAppPurchaseManagerProductsFetchedNotification @"kInAppPurchaseManagerProductsFetchedNotification"

@interface InAppPurchaseManager : NSObject <SKProductsRequestDelegate,SKPaymentTransactionObserver>{
    SKProduct *proUpgradeProduct;
    SKProductsRequest *productsRequest;
}

// public methods
- (void)loadStore;
- (BOOL)canMakePurchases;
- (void)purchaseProUpgrade;
- (void)requestProUpgradeProductData;
@end
