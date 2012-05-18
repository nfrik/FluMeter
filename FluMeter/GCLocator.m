//
//  GCLocator.m
//  FluMeter
//
//  Created by nikolay on 5/27/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "GCLocator.h"
#import "ASIHTTPRequest.h"
#import "JSON.h"

@implementation GCLocator

@synthesize country;
@synthesize state; 
@synthesize city;
@synthesize street;
@synthesize zip;
@synthesize latitude;
@synthesize longitude;

- (id)initWithLatitudeLongitude:(NSString*)latit Longitude:(NSString*)longit{
    
    //http://maps.google.com/maps/geo?q=40.714224,-73.961452&output=json&oe=utf8&sensor=true_or_false&key=ABQIAAAAgcXT8AKJciQuYV_aWL8rgBQsEfrqZRwBwcY1JO9jL1_-M5f8YRTN5U3WQSISMHffNDeAFCliG1Q0mA
    
    self.latitude=latit;
    self.longitude=longit;    
    /*
    NSString *head = @"http://maps.google.com/maps/geo?q=";
    NSString *tail = @"&output=json&oe=utf8&sensor=true_or_false&key=ABQIAAAAgcXT8AKJciQuYV_aWL8rgBQsEfrqZRwBwcY1JO9jL1_-M5f8YRTN5U3WQSISMHffNDeAFCliG1Q0mA";
    NSString *concat = [[[[head stringByAppendingString:latit] stringByAppendingString:@","] stringByAppendingString:longit] stringByAppendingString:tail];
    //NSString *concat = @"http://free.worldweatheronline.com/feed/weather.ashx?q=+46.74,-117.15&format=json&num_of_days=1&key=b70fa719d5232235110405";
    //NSLog(@"concat string value " "%@\"",concat);
    NSURL *url = [NSURL URLWithString:concat];
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
    [request setDelegate:self];
    [request startAsynchronous];  
    */  
    
    return self;
}

- (void)refresh{
    NSString *head = @"http://maps.google.com/maps/geo?q=";
    NSString *tail = @"&output=json&oe=utf8&sensor=true_or_false&key=ABQIAAAAgcXT8AKJciQuYV_aWL8rgBQsEfrqZRwBwcY1JO9jL1_-M5f8YRTN5U3WQSISMHffNDeAFCliG1Q0mA";
    NSString *concat = [[[[head stringByAppendingString:latitude] stringByAppendingString:@","] stringByAppendingString:longitude] stringByAppendingString:tail];
    //NSString *concat = @"http://free.worldweatheronline.com/feed/weather.ashx?q=+46.74,-117.15&format=json&num_of_days=1&key=b70fa719d5232235110405";
    //NSLog(@"concat string value " "%@\"",concat);
    NSURL *url = [NSURL URLWithString:concat];
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
    [request setDelegate:self];
    [request startAsynchronous];    
}

-(void)dealloc{
    [country release];
    [state release];
    [city release];
    [street release];
    [zip release];
    [latitude release];
    [longitude release];
    [super dealloc];
}

- (void)requestFinished:(ASIHTTPRequest *)request
{
    // Use when fetching text data
    NSString *responseString = [request responseString];
    NSLog(@"%@",responseString);
    
    SBJsonParser *json = [[SBJsonParser new] autorelease];
    
    NSDictionary *dictionary = [json objectWithString:responseString];
    if(dictionary == nil){
        NSLog(@"%@",@"Error loading address from google");
    }
    else if ([[[dictionary objectForKey:@"Status"] valueForKey:@"code"] intValue]==200) {
        //     NSDictionary *addressData = [[dictionary objectForKey:@"Placemark"] objectAtIndex:0];
        city = [[[[[[[dictionary objectForKey:@"Placemark"] objectAtIndex:0] objectForKey:@"AddressDetails"] objectForKey:@"Country"] objectForKey:@"AdministrativeArea"] objectForKey:@"Locality"] valueForKey:@"LocalityName"];
        
        country = [[[[[dictionary objectForKey:@"Placemark"] objectAtIndex:0] objectForKey:@"AddressDetails"] objectForKey:@"Country"] valueForKey:@"CountryName"];        
        
        state = [[[[[[dictionary objectForKey:@"Placemark"] objectAtIndex:0] objectForKey:@"AddressDetails"] objectForKey:@"Country"] objectForKey:@"AdministrativeArea"] valueForKey:@"AdministrativeAreaName"];
        
        street = [[[[[[[[dictionary objectForKey:@"Placemark"] objectAtIndex:0] objectForKey:@"AddressDetails"] objectForKey:@"Country"] objectForKey:@"AdministrativeArea"] objectForKey:@"Locality"] objectForKey:@"Thoroughfare"] valueForKey:@"ThoroughfareName"];
        
        zip = [[[[[[[[dictionary objectForKey:@"Placemark"] objectAtIndex:0] objectForKey:@"AddressDetails"] objectForKey:@"Country"] objectForKey:@"AdministrativeArea"] objectForKey:@"Locality"] objectForKey:@"PostalCode"] valueForKey:@"PostalCodeNumber"];        
        
        
        //Push Notification!
        [[NSNotificationCenter defaultCenter]
         postNotificationName:@"addressReceivedEvent"
         object:nil ];        
    }
}

- (void)requestFailed:(ASIHTTPRequest *)request
{
    NSError *error = [request error];
    NSLog(@"Error while retrieving GEOcode location %@",error);
}

@end
