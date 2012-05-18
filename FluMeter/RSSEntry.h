//
//  RSSEntry.h
//  RSSFun
//
//  Created by Ray Wenderlich on 1/24/11.
//  Copyright 2011 Ray Wenderlich. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RSSEntry : NSObject {
    NSString *_blogTitle;
    NSString *_articleTitle;
    NSString *_articleUrl;
    NSDate *_articleDate;
    BOOL ispodcast;
}

@property (copy) NSString *blogTitle;
@property (copy) NSString *articleTitle;
@property (copy) NSString *articleUrl;
@property (copy) NSDate *articleDate;
@property (assign) BOOL ispodcast;

- (id)initWithBlogTitle:(NSString*)blogTitle articleTitle:(NSString*)articleTitle articleUrl:(NSString*)articleUrl articleDate:(NSDate*)articleDate podcast:(BOOL)isPodcast;

@end

