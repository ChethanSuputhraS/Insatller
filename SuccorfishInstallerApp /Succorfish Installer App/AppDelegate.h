//
//  AppDelegate.h
//  Succorfish Installer App
//
//  Created by stuart watts on 16/02/2018.
//  Copyright © 2018 Kalpesh Panchasara. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LoginVC.h"
#import <CoreLocation/CoreLocation.h>
#import "Reachability.h"
#import "URBAlertView.h"
#import "InstallBeconVC.h"
#import "BeaconVC.h"

NSString * deviceTokenStr;
NSString * appLatitude;
NSString * appLongitude;
NSString * installScanID;
NSString * installVesselName;
NSString * installedVesselID;
NSString * installRegi;
NSString * phoneCountryCode;
NSString * phoneCountryName;
NSString * installPhotoCounts;
NSString * globalDeviceType;
NSString * globalWarrantyStatus;
NSString * strSuccorfishDeviceID;
NSString * strTotalInstallCounts;
NSString * strAccountID;

NSData * kpsData;
bool isLandscapeRequired;
int statusHeight;
int heightKeyBrd;
CGFloat approaxSize;
NSMutableArray * installImgArr;

InstallBeconVC * globalbeaconVC;

BeaconVC * globalBeaconInstVC;

@interface AppDelegate : UIResponder <UIApplicationDelegate,UITabBarControllerDelegate,CLLocationManagerDelegate>
{
    UITabBarController * mainTabBarController;
    
    UINavigationController *firstNavigation;
    UINavigationController *secondNavigation;
    UINavigationController *thirdNavigation;
    UINavigationController *forthNavigation;
    UINavigationController *fifthNavigation;
    
    UIView * viewNetworkConnectionPopUp;
    NSTimer * timerNetworkConnectionPopUp;
    CLLocationManager * locationManager;
    URBAlertView *alertView;


}
@property (strong, nonatomic) UIWindow *window;

#pragma mark - Helper Methods
-(UIColor *) colorWithHexString:(NSString *)stringToConvert;
-(BOOL)validateEmail:(NSString*)email;
- (UIImage *)imageFromColor:(UIColor *)color;

-(void)setUpTabBarController;
-(void)getLocationMethod;
-(void)ShowErrorPopUpWithErrorCode:(NSInteger)errorCode andMessage:(NSString*)errorMessage;

-(void)hideTabBar:(UITabBarController *) tabbarcontroller;
-(void)showTabBar:(UITabBarController *) tabbarcontroller;
-(BOOL)isNetworkreachable;
-(void)movetoSelectedInex:(NSInteger)selectedIndex;

-(void)startHudProcess:(NSString *)text;
-(void)endHudProcess;
-(void)movetoLogin;
-(void)showSessionExpirePopup;
-(void)updateBadgeCount;
-(NSString *)getConvertedDate:(NSString *)strDate withFormat:(NSString *)strFormat;
-(NSString *)base64String:(NSString *)str;
-(NSString *)GetRealDatefromTimeStamp:(NSString *)strTimeStamp;
//- (NSString *)dateValueFromDate:(NSString *)dateStrl;
- (NSString *)dateValueFromDate:(NSString *)dateStr withGiveDatetoShow:(NSString *)strAttachDate;
-(NSString *)checkforValidString:(NSString *)strRequest;
-(void)getPlaceholderText:(UITextField *)txtField  andColor:(UIColor*)color;


@end

