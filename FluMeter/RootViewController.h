//
//  RootViewController.h
//  FluMeter
//
//  Created by nikolay on 5/12/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CoreLocationController.h"
#import "Reachability.h"
#import "Helper.h"
#import "NationInfo.h"
#import "FluNews.h"
#import "GCLocator.h"
#import "WebViewController.h"

@class WebViewController;
@class Reachability;
@interface RootViewController : UIViewController<CoreLocationControllerDelegate,UIScrollViewDelegate,UIPickerViewDelegate,UIPickerViewDataSource> {
	UIButton* UINationWide;
	UIButton* UIFluInfo;
	UIButton* UIFluNews;
    UIButton* UIActivity;
    UILabel* HumidityLabel;
    UILabel* TemperatureLabel;
    UILabel* InfoLabel;
    UILabel* currentLocationLabel;
    NSMutableData *responseData;
    NSString *latitude;
    NSString *longitude;
    NSString *mystreet;
    NSString *fluData;
 	NSTimer  *minuteTimer;
    GCLocator *gcLocation;
    CoreLocationController *CLController;
    Reachability *internetReachable;
    Reachability *hostReachable;
    BOOL internetActive;
    WebViewController *_webViewController;
    FluNews *flunews;
    NationInfo *nationinfo;
    UIScrollView *scrollView;
    UIView *scrollableView;
    UIPickerView *numericPicker;
    NSArray *pickerTemperatures;
    NSArray *pickerHumidities;
    UILabel *sliderTemperatureLabel;
    UILabel *sliderHumidityLabel;
    UISlider *sliderTemperature;
    UISlider *sliderHumidity;
    NSString *currentHumidity;
    NSString *currentTemperature_C;
    NSString *currentTemperature_F;
    
     UIImageView *rootImageView;    
     UIImageView *activityImageView;        
}

@property(nonatomic,retain) NSString *currentHumidity;
@property(nonatomic,retain) NSString *currentTemperature_C;
@property(nonatomic,retain) NSString *currentTemperature_F;
@property(nonatomic,retain) IBOutlet UISlider *sliderTemperature; //slider procedures
@property(nonatomic,retain) IBOutlet UISlider *sliderHumidity;
@property(nonatomic,retain) IBOutlet UILabel *sliderTemperatureLabel;
@property(nonatomic,retain) IBOutlet UILabel *sliderHumidityLabel;
@property(nonatomic,retain) NSArray *pickerTemperatures;
@property(nonatomic,retain) NSArray *pickerHumidities;
@property(nonatomic,retain) IBOutlet UIPickerView *numericPicker;
@property (nonatomic, retain) IBOutlet UIScrollView *scrollView;
@property (nonatomic, retain) IBOutlet UIView *scrollableView;
@property(nonatomic,retain) FluNews *flunews;
@property(nonatomic,retain) NationInfo *nationinfo;
@property(retain) WebViewController *webViewController;
@property(nonatomic,retain) IBOutlet UIButton *UINationWide;
@property(nonatomic,retain) IBOutlet UIButton *UIFluInfo;
@property(nonatomic,retain) IBOutlet UIButton *UIFluNews;
@property(nonatomic,retain) IBOutlet UIButton *UIActivity;
@property(nonatomic,retain) IBOutlet UIButton *UIILike;
@property(nonatomic,retain) IBOutlet UILabel *HumidityLabel;
@property(nonatomic,retain) IBOutlet UILabel *TemperatureLabel;
@property(nonatomic,retain) IBOutlet UILabel *InfoLabel;
@property(nonatomic,retain) IBOutlet UILabel *currentLocationLabel;
@property(nonatomic,assign) NSTimer *minuteTimer;
@property(nonatomic,retain) CoreLocationController *CLController;
@property(nonatomic,retain) NSString *latitude;
@property(nonatomic,retain) NSString *longitude;
@property(nonatomic,retain) NSString *mystreet;
@property(nonatomic,retain) NSString *fluData;
@property(nonatomic,assign) BOOL internetActive;
@property(nonatomic,retain) IBOutlet UIImageView *rootImageView;    
@property(nonatomic,retain) IBOutlet UIImageView *activityImageView;    
@property(nonatomic,retain) GCLocator *gcLocation;


-(NSString*)stringBetweenString:(NSString*)thestring startstring:(NSString*)start endString:(NSString*)end;
- (void) NationWide_Clicked:(id)sender;
- (void) FluInfo_Clicked:(id)sender;
- (void) FluNews_Clicked:(id)sender;
- (void) checkNetworkStatus:(NSNotification*)notice;
- (void) makeTabBarHidden:(BOOL)hide;
- (UIImage *)imageForValue:(CGFloat)value; 
- (BOOL)InternetReachable;
-(IBAction)sliderTemperatureChanged:(id)sender;
-(IBAction)sliderHumidityChanged:(id)sender;
-(IBAction)sliderEditingDidEnd:(id)sender;
-(int)celsiusToFarenheit:(int)Tc;
-(void)updateInfo;

@end
