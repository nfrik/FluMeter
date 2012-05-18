//
//  WebViewController.h
//  RSSFun
//
//  Created by Ray Wenderlich on 1/24/11.
//  Copyright 2011 Ray Wenderlich. All rights reserved.
//

#import <UIKit/UIKit.h>


@class RSSEntry;

@interface WebViewController : UIViewController<UIWebViewDelegate> {
    UIWebView *_webView;
    RSSEntry *_entry;
}

@property (retain) IBOutlet UIWebView *webView;
@property (retain) RSSEntry *entry;

@end
