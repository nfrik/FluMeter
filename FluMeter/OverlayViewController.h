//
//  OverlayViewController.h
//  TableView
//
//  Created by iPhone SDK Articles on 1/17/09.
//  Copyright www.iPhoneSDKArticles.com 2009. 
//

#import <UIKit/UIKit.h>

@class NationInfo;
@class FluNews;
@interface OverlayViewController : UIViewController {

	NationInfo *rvController;
    FluNews *fnController;
}

@property (nonatomic, retain) NationInfo *rvController;
@property (nonatomic, retain) FluNews *fnController;

@end
