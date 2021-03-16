//
//  AppDelegate.m
//  Succorfish Installer App
//
//  Created by stuart watts on 16/02/2018.
//  Copyright © 2018 Kalpesh Panchasara. All rights reserved.
//

#import "AppDelegate.h"
#import "DashboardVC.h"
#import "HistoryVC.h"
#import "SettingsVC.h"
#import "HelpVC.h"
#import "VerifyVC.h"
#import "PasswordVC.h"
#import "MBProgressHUD.h"
#import "PhotoView.h"
#import "VesselVC.h"
#import "DataBaseManager.h"
#import <Fabric/Fabric.h>
#import <Crashlytics/Crashlytics.h>
#import <objc/runtime.h>

@interface AppDelegate ()
{
    MBProgressHUD * HUD;
}
@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
//    [[NSUserDefaults standardUserDefaults] setValue:@"f0d99950-4305-11e8-8224-90b8d0f72797" forKey:@"CURRENT_USER_ID"];
//    [[NSUserDefaults standardUserDefaults] synchronize];
    
    NSString *version = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
    NSLog(@"APP VERSION=%@",version);
    
    _window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    NSLog(@"%s",__FUNCTION__);
    _window.backgroundColor = [UIColor groupTableViewBackgroundColor];
    
    appLatitude = @"0";
    appLongitude = @"0";
    
    deviceTokenStr = @"1234567";
    
    [Fabric with:@[[Crashlytics class]]];

    
    if (IS_IPHONE_6plus)
    {
        approaxSize = 1.29;
    }
    else if (IS_IPHONE_6 || IS_IPHONE_X)
    {
        approaxSize = 1.17;
    }
    else
    {
        approaxSize = 1;
    }
    
    if (IS_IPHONE_X)
    {
        statusHeight = 88;
    }
    else
    {
        statusHeight = 64;
    }
    [self getLocationMethod];
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *  path = [paths objectAtIndex:0];
    NSLog(@"data base path:%@",[path stringByAppendingPathComponent:@"InstallerApp.sqlite"]);

//    [self createFile];
    
    NSString * strHeight = [[NSUserDefaults standardUserDefaults] valueForKey:@"KeyboardHeight"];
    if ([strHeight isEqualToString:@""] || [strHeight length]==0 || [strHeight isEqual:[NSNull null]] || strHeight == nil)
    {
        [self someMethodWhereYouSetUpYourObserver];
    }
    else
    {
        heightKeyBrd = [strHeight intValue];
    }

    NSString * strGlobalDateformat = [[NSUserDefaults standardUserDefaults] valueForKey:@"globalDate"];
    if ([strGlobalDateformat isEqualToString:@""] || [strGlobalDateformat length]==0 || [strGlobalDateformat isEqual:[NSNull null]] || strGlobalDateformat == nil)
    {
        [[NSUserDefaults standardUserDefaults] setObject:@"date1" forKey:@"globalDate"];
        [[NSUserDefaults standardUserDefaults] setObject:@"YYYY-MM-dd" forKey:@"GloablDateFormat"];
        [[NSUserDefaults standardUserDefaults] setObject:@"YYYY-MM-dd" forKey:@"GloablDateFormatShow"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }

    
    /*-----------Push Notitications----------*/
    if ([application respondsToSelector:@selector(registerUserNotificationSettings:)])
    {
        // Register for Push Notitications, if running iOS 8
        UIUserNotificationType userNotificationTypes = (UIUserNotificationTypeAlert | UIUserNotificationTypeBadge | UIUserNotificationTypeSound);
        UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:userNotificationTypes categories:nil];
        [application registerUserNotificationSettings:settings];
        [application registerForRemoteNotifications];
    }
    else
    {
        // Register for Push Notifications before iOS 8
        [application registerForRemoteNotificationTypes:(UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeAlert | UIRemoteNotificationTypeSound)];
        [application enabledRemoteNotificationTypes];
    }
    /*-------------------------------------------*/
    
    if ([[[NSUserDefaults standardUserDefaults] valueForKey:@"FreshDatabased"] isEqualToString:@"Yes"])
    {
    }
    else
    {
        NSString * strDeletInstall = [NSString stringWithFormat:@"delete from tbl_install"];
        [[DataBaseManager dataBaseManager] execute:strDeletInstall];
        
        NSString * strDeletInstallPhotos = [NSString stringWithFormat:@"delete from tbl_installer_photo"];
        [[DataBaseManager dataBaseManager] execute:strDeletInstallPhotos];
        
        NSString * strDeletUninstall = [NSString stringWithFormat:@"delete from tbl_uninstall"];
        [[DataBaseManager dataBaseManager] execute:strDeletUninstall];
        
        NSString * strDeletInspec = [NSString stringWithFormat:@"delete from tbl_inspection"];
        [[DataBaseManager dataBaseManager] execute:strDeletInspec];
        
        NSString * strDeletInspecPhotos = [NSString stringWithFormat:@"delete from tbl_inspection_photo"];
        [[DataBaseManager dataBaseManager] execute:strDeletInspecPhotos];
        
        [[NSUserDefaults standardUserDefaults] setValue:@"Yes" forKey:@"FreshDatabased"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    [[DataBaseManager dataBaseManager] addDeviceIdcolumnstoUnInstall];
    [[DataBaseManager dataBaseManager] addDeviceIdcolumnstoUnInspection];
    [[DataBaseManager dataBaseManager] addDeviceIdcolumnstoInstalls];
    [[DataBaseManager dataBaseManager] addPowerValuecolumnstoInstalls];
    [[DataBaseManager dataBaseManager] addActionValuescolumnstoInspection];
    [[DataBaseManager dataBaseManager] addlocalOwnerSignscolumnstoInspection];
    [[DataBaseManager dataBaseManager] addServerOwnerSignscolumnstoInspection];
    [[DataBaseManager dataBaseManager] Create_Extra_Vessel_Table];
    [[DataBaseManager dataBaseManager]Create_Question_Table];
    [[DataBaseManager dataBaseManager]Create_Beacon_Install_Table];
    [[DataBaseManager dataBaseManager] Create_Asset_Group_Table];


    if([IS_USER_LOGGED isEqualToString:@"YES"])
    {
        if ([[[NSUserDefaults standardUserDefaults] valueForKey:@"isNewVersionAvailable"] isEqualToString:@"1"])
        {
            [UIView beginAnimations:nil context:NULL];
            [UIView setAnimationDuration:1.3];
            [UIView setAnimationTransition:UIViewAnimationTransitionFlipFromLeft forView:[[UIApplication sharedApplication] keyWindow] cache:YES];
            [UIView commitAnimations];
            [self setUpTabBarController];
        }
        else
        {
            LoginVC * splash = [[LoginVC alloc] init];
            UINavigationController * navControl = [[UINavigationController alloc] initWithRootViewController:splash];
            navControl.navigationBarHidden=YES;
            self.window.rootViewController = navControl;
            [[NSUserDefaults standardUserDefaults] setValue:@"1" forKey:@"isNewVersionAvailable"];
            [[NSUserDefaults standardUserDefaults] synchronize];
        }
    }
    else
    {
        LoginVC * splash = [[LoginVC alloc] init];
        UINavigationController * navControl = [[UINavigationController alloc] initWithRootViewController:splash];
        navControl.navigationBarHidden=YES;
        self.window.rootViewController = navControl;
    }
    [[UIApplication sharedApplication] setStatusBarHidden:NO];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    /*-------------------------------------------*/
    [_window makeKeyAndVisible];
    return YES;
}
#pragma Validation For Empty String
-(NSString *)checkforValidString:(NSString *)strRequest
{
    NSString * strValid;
    
NSCharacterSet *set = [NSCharacterSet whitespaceCharacterSet];
    
    if (![strRequest isEqual:[NSNull null]])
    {
        if (strRequest != nil && strRequest != NULL && ![strRequest isEqualToString:@""] && ![strRequest isEqualToString:@"(null)"] && ![strRequest isEqualToString:@"null"] && [[strRequest stringByTrimmingCharactersInSet: set] length] != 0)
        {
            strValid = strRequest;
        }
        else
        {
            strValid = @"NA";
        }
    }
    else
    {
        strValid = @"NA";
    }
    return strValid;
}
-(void)createFile
{
//    NSString * strkp = [NSString stringWithFormat:@"357152071046633,357152070981152,357152070984388,357152070984230,357152070981285,357152071043317,357164042142508,357152071043234,357164042739089,357152070984578,357164042682289,357152071042483,357164042718083,357152070981467,357152071046625,357164042754070,357164042734577,357152070981343,357152071046690,357152071075327,357152071046716,357152070981350,357152071046674,357152071045528,357152071043341,357164042746647,357164042690613,357164042618085,357152070984016,357152070984354,357164042474646,357164042684434,357164042740202,357152071046583,357164042752272,357152070981400,357152071072886,357152070984164,357152070981442,357164042709306,357164042746506,357152070981384,357164042739303,357152071074643,357152071044992,357152070981046,357152071074981,357152070984487,357152071043333,357164042716947,357152070983968,357152070981301,357152070984305,357164042746142,357152071072696,357164042690746,357152070984271,357164042751548,357152071043218,357152070984156,357152070983950,357152070983984,357152071043291,357152071045007,357152070981558,357164042709322,357164042146418,357164042752280,357152070984149,357164042745532"];
    
    NSString * strkp = [NSString stringWithFormat:@"357164042680762,357152071046591,357164042690662,357164042690258,357152070981327,357152071048969,357164042701303,357164042678790,357164042675283,357152070981665,357164042690407,357152071045833"];
//    "10","359586016791092","SC2","24-04-2019","1","1","1","2018-04-25 00:00:00","2018-04-25 00:00:00"

    NSArray * deviceArr = [strkp componentsSeparatedByString:@","];
    
    NSString * strType = @"SC2";
    NSString * strWarrant = @"12 Months";
    NSString * strCreated = @"1";
    NSString * strCreateAt = @"2018-04-25 00:00:00";

    for (int i=0; i<[deviceArr count]; i++)
    {
        NSString * requestStr =[NSString stringWithFormat:@"insert into 'device'('id','imei','device_type','warranty','created_by','updated_by','created_at','updated_at') values(\"%d\",\"%@\",\"%@\",\"%@\",\"%@\",\"%@\",\"%@\",\"%@\")",80+i+1,[deviceArr objectAtIndex:i],strType,strWarrant,strCreated,strCreated,strCreateAt,strCreateAt];
        [[DataBaseManager dataBaseManager] execute:requestStr];
    }
//    CREATE TABLE `device` ( `id` INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT, `imei` TEXT, `device_type` TEXT, `warranty` TEXT, `created_by` TEXT, `updated_by` TEXT, `created_at` TEXT, `updated_at` TEXT )
    
}
- (void)someMethodWhereYouSetUpYourObserver
{
    // This could be in an init method.
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(myNotificationMethod:)
                                                 name:UIKeyboardDidShowNotification
                                               object:nil];
}

- (void)myNotificationMethod:(NSNotification*)notification
{
    NSDictionary* keyboardInfo = [notification userInfo];
    NSValue* keyboardFrameBegin = [keyboardInfo valueForKey:UIKeyboardFrameBeginUserInfoKey];
    CGRect keyboardFrameBeginRect = [keyboardFrameBegin CGRectValue];
    heightKeyBrd = keyboardFrameBeginRect.size.height;
    
    [[NSUserDefaults standardUserDefaults] setValue:[NSString stringWithFormat:@"%d",heightKeyBrd] forKey:@"KeyboardHeight"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardDidShowNotification object:nil];
    NSLog(@"THIS IS KEYBOARD HEIGHT===%f",keyboardFrameBeginRect.size.height);
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}


- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

-(void)createDatabase
{

//    [[DataBaseManager dataBaseManager] addcolumnsToInstallationTable];
}
#pragma mark - Orientation
-(UIInterfaceOrientationMask)application:(UIApplication *)application supportedInterfaceOrientationsForWindow:(UIWindow *)window
{
    if (isLandscapeRequired == false)
    {
        return UIInterfaceOrientationMaskPortrait;
    }
    else
    {
        return UIInterfaceOrientationMaskLandscapeLeft | UIInterfaceOrientationMaskLandscapeRight | UIInterfaceOrientationMaskPortrait;
    }
}
//- (BOOL) shouldAutorotate
//{
//    return false;
//}

#pragma mark Remote notification

#ifdef __IPHONE_8_0
- (void)application:(UIApplication *)application didRegisterUserNotificationSettings:   (UIUserNotificationSettings *)notificationSettings
{
    //register to receive notifications
    [application registerForRemoteNotifications];
}

- (void)application:(UIApplication *)application handleActionWithIdentifier:(NSString   *)identifier forRemoteNotification:(NSDictionary *)userInfo completionHandler:(void(^)())completionHandler
{
    //handle the actions
    if ([identifier isEqualToString:@"declineAction"]){
    }
    else if ([identifier isEqualToString:@"answerAction"]){
    }
}

#endif

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken
{
    deviceTokenStr = [[[[deviceToken description]
                        stringByReplacingOccurrencesOfString: @"<" withString: @""]
                       stringByReplacingOccurrencesOfString: @">" withString: @""]
                      stringByReplacingOccurrencesOfString: @" " withString: @""] ;
    NSLog(@"My device token ============================>>>>>>>>>>>%@",deviceTokenStr);
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo
{
    
}

- (void)application:(UIApplication*)application didFailToRegisterForRemoteNotificationsWithError:(NSError*)error
{
    NSLog(@"Failed to get token, error: %@", error);
}
#pragma mark - Global Helper Functions
-(BOOL)validateEmail:(NSString*)email
{
    if( (0 != [email rangeOfString:@"@"].length) &&  (0 != [email rangeOfString:@"."].length) )
    {
        NSMutableCharacterSet *invalidCharSet = [[[NSCharacterSet alphanumericCharacterSet] invertedSet]mutableCopy];
        [invalidCharSet removeCharactersInString:@"_-"];
        
        NSRange range1 = [email rangeOfString:@"@" options:NSCaseInsensitiveSearch];
        
        // If username part contains any character other than "."  "_" "-"
        
        NSString *usernamePart = [email substringToIndex:range1.location];
        NSArray *stringsArray1 = [usernamePart componentsSeparatedByString:@"."];
        for (NSString *string in stringsArray1)
        {
            NSRange rangeOfInavlidChars=[string rangeOfCharacterFromSet: invalidCharSet];
            if(rangeOfInavlidChars.length !=0 || [string isEqualToString:@""])
                return FALSE;
        }
        
        NSString *domainPart = [email substringFromIndex:range1.location+1];
        NSArray *stringsArray2 = [domainPart componentsSeparatedByString:@"."];
        
        for (NSString *string in stringsArray2)
        {
            NSRange rangeOfInavlidChars=[string rangeOfCharacterFromSet:invalidCharSet];
            if(rangeOfInavlidChars.length !=0 || [string isEqualToString:@""])
                return FALSE;
        }
        
        return TRUE;
    }
    else {// no '@' or '.' present
        return FALSE;
    }
}

-(UIColor *) colorWithHexString:(NSString *)stringToConvert
{
    // NSLog(@"ColorCode -- %@",stringToConvert);
    NSString *cString = [[stringToConvert stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] uppercaseString];
    
    // String should be 6 or 8 characters
    
    if ([cString length] < 6) return [UIColor blackColor];
    
    // strip 0X if it appears
    
    if ([cString hasPrefix:@"0X"]) cString = [cString substringFromIndex:2];
    
    if ([cString length] != 6) return [UIColor blackColor];
    
    // Separate into r, g, b substrings
    
    NSRange range;
    
    range.location = 0;
    range.length = 2;
    NSString *rString = [cString substringWithRange:range];
    range.location = 2;
    NSString *gString = [cString substringWithRange:range];
    range.location = 4;
    NSString *bString = [cString substringWithRange:range];
    
    // Scan values
    
    unsigned int r, g, b;
    
    [[NSScanner scannerWithString:rString] scanHexInt:&r];
    
    [[NSScanner scannerWithString:gString] scanHexInt:&g];
    
    [[NSScanner scannerWithString:bString] scanHexInt:&b];
    
    return [UIColor colorWithRed:((float) r / 255.0f)
            
                           green:((float) g / 255.0f)
            
                            blue:((float) b / 255.0f)
            
                           alpha:1.0f];
}

- (UIImage *)imageFromColor:(UIColor *)color
{
    CGRect rect = CGRectMake(0, 0, 1, 1);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

#pragma mark - TabBarController Delegate
-(void)tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController
{
    NSLog(@"viewController===%@",viewController);
    
    NSLog(@"tabBarController.selectedIndex===%lu",(unsigned long)tabBarController.selectedIndex);
    
    if (tabBarController.selectedIndex == 0) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"FirstTabChangedNotifiation" object:nil];
    }else if (tabBarController.selectedIndex == 1){
        [[NSNotificationCenter defaultCenter] postNotificationName:@"SecondTabChangedNotifiation" object:nil];
    }else if (tabBarController.selectedIndex == 2){
        [[NSNotificationCenter defaultCenter] postNotificationName:@"ThirdTabChangedNotifiation" object:nil];
    }else if (tabBarController.selectedIndex == 3){
        [[NSNotificationCenter defaultCenter] postNotificationName:@"ForthTabChangedNotifiation" object:nil];
    }else if (tabBarController.selectedIndex == 4){
        //        [[NSNotificationCenter defaultCenter] postNotificationName:@"FifthTabChangedNotifiation" object:nil];
    }
}
#pragma mark - SetUp Tabbar
-(void)setUpTabBarController
{
    DashboardVC * firstViewController = [[DashboardVC alloc]init];
    firstViewController.title=@"Install";
    firstViewController.tabBarItem=[[UITabBarItem alloc] initWithTitle:@"Install" image:[[UIImage imageNamed:@"Install.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal ] selectedImage:[[UIImage imageNamed:@"active_install.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] ];
    firstNavigation = [[UINavigationController alloc]initWithRootViewController:firstViewController];
    firstNavigation.navigationBarHidden = YES;

    
    HistoryVC * secondViewController = [[HistoryVC alloc]init];
    secondViewController.title=@"History";
    secondViewController.tabBarItem=[[UITabBarItem alloc] initWithTitle:@"History" image:[[UIImage imageNamed:@"History.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal ] selectedImage:[[UIImage imageNamed:@"active_history.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] ];
    secondNavigation = [[UINavigationController alloc]initWithRootViewController:secondViewController];
    secondNavigation.navigationBarHidden = YES;

    
    SettingsVC * thirdViewController = [[SettingsVC alloc]init];
    thirdViewController.title = @"Settings";
    thirdViewController.tabBarItem=[[UITabBarItem alloc] initWithTitle:@"Settings" image:[[UIImage imageNamed:@"settings.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal ] selectedImage:[[UIImage imageNamed:@"active_settings.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] ];
    thirdNavigation = [[UINavigationController alloc]initWithRootViewController:thirdViewController];
    thirdNavigation.navigationBarHidden = YES;

    
    HelpVC * forthViewController = [[HelpVC alloc]init];
    forthViewController.title=@"Help";
    forthViewController.tabBarItem=[[UITabBarItem alloc] initWithTitle:@"Help" image:[[UIImage imageNamed:@"help.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal ] selectedImage:[[UIImage imageNamed:@"active_help.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] ];
    forthNavigation = [[UINavigationController alloc]initWithRootViewController:forthViewController];
    forthNavigation.navigationBarHidden = YES;

    mainTabBarController = [[UITabBarController alloc] init];
    mainTabBarController.viewControllers = [[NSArray alloc] initWithObjects:firstNavigation,secondNavigation, thirdNavigation,forthNavigation, nil];
    mainTabBarController.tabBar.tintColor = [UIColor grayColor];
    mainTabBarController.delegate = self;
    mainTabBarController.tabBar.barTintColor = [UIColor blackColor];
    mainTabBarController.selectedIndex = 0;
    
    if (IS_IPHONE_X)
    {
        
    }
    else
    {
        //  The color you want the tab bar to be
        UIColor *barColor = [UIColor colorWithRed:1.0f/255.0 green:1.0f/255.0 blue:1.0f/255.0 alpha:0.2f];
        
        //  Create a 1x1 image from this color
        UIGraphicsBeginImageContext(CGSizeMake(1, 1));
        [barColor set];
        UIRectFill(CGRectMake(0, 0, 1, 1));
        UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        //  Apply it to the tab bar
        [[UITabBar appearance] setBackgroundImage:image];
    }
   
    
    [[UITabBarItem appearance] setTitleTextAttributes:@{NSFontAttributeName : [UIFont fontWithName:CGRegular size:11],
                                                        NSForegroundColorAttributeName : [UIColor whiteColor]
                                                        } forState:UIControlStateSelected];
    
    
    // doing this results in an easier to read unselected state then the default iOS 7 one
    [[UITabBarItem appearance] setTitleTextAttributes:@{NSFontAttributeName : [UIFont fontWithName:CGRegular size:12],
                                                        NSForegroundColorAttributeName : [UIColor grayColor]
                                                        } forState:UIControlStateNormal];
    self.window.rootViewController = mainTabBarController;
}
-(void)removeNetworkConnectionPopUp:(NSTimer*)timer
{
    [UIView transitionWithView:viewNetworkConnectionPopUp duration:0.3
                       options:UIViewAnimationOptionCurveEaseIn
                    animations:^{
                        [viewNetworkConnectionPopUp setFrame:CGRectMake(0, -64, DEVICE_WIDTH, 64)];
                    }
                    completion:^(BOOL finished)
     {
         [viewNetworkConnectionPopUp removeFromSuperview];
     }];
}
#pragma mark - Error Message
//-(void)ShowNoNetworkConnectionPopUpWithErrorCode:(NSInteger)errorCode andMessage:(NSString*)errorMessage
-(void)ShowErrorPopUpWithErrorCode:(NSInteger)errorCode andMessage:(NSString*)errorMessage
{
    NSString * strErrorMessage;
    if (errorCode == -1004)
    {
        strErrorMessage = @"Could not connect to the server";
    }
    else if (errorCode == -1009)
    {
        strErrorMessage = @"No Network Connection";
    }
    else if (errorCode == -1005)
    {
        strErrorMessage = @"Network Connection Lost";
        //        strErrorMessage = @"";
    }
    else if (errorCode == -1001)
    {
        strErrorMessage = @"Request Timed Out";
    }
    else if (errorCode == customErrorCodeForMessage)//custom message
    {
        strErrorMessage = errorMessage;
    }
    
    
    [viewNetworkConnectionPopUp removeFromSuperview];
    [viewNetworkConnectionPopUp setAlpha:0.0];
    
    if (![strErrorMessage isEqualToString:@""])
    {
        viewNetworkConnectionPopUp = [[UIView alloc] initWithFrame:CGRectMake(0, -64, DEVICE_WIDTH, 64)];
        [viewNetworkConnectionPopUp setBackgroundColor:[UIColor clearColor]];
        [self.window addSubview:viewNetworkConnectionPopUp];
        
        UIView * viewTrans = [[UIView alloc] initWithFrame:CGRectMake(0, 0, viewNetworkConnectionPopUp.frame.size.width, viewNetworkConnectionPopUp.frame.size.height)];
        [viewTrans setBackgroundColor:[self colorWithHexString:dark_red_color]];
        [viewTrans setAlpha:0.9];
        [viewNetworkConnectionPopUp addSubview:viewTrans];
        
        UIImageView * imgProfile = [[UIImageView alloc] initWithFrame:CGRectMake(50, 24, 16, 16)];
        [imgProfile setImage:[UIImage imageNamed:@"cross.png"]];
        imgProfile.contentMode = UIViewContentModeScaleAspectFit;
        imgProfile.clipsToBounds = YES;
        //[viewNetworkConnectionPopUp addSubview:imgProfile];
        
        UILabel * lblMessage = [[UILabel alloc] initWithFrame:CGRectMake(20, 20, DEVICE_WIDTH-40, 44)];
        [lblMessage setBackgroundColor:[UIColor clearColor]];
        [lblMessage setTextColor:[UIColor whiteColor]];
        [lblMessage setTextAlignment:NSTextAlignmentCenter];
        [lblMessage setNumberOfLines:2];
        [lblMessage setText:[NSString stringWithFormat:@"%@",strErrorMessage]];
        [lblMessage setFont:[UIFont systemFontOfSize:14]];
        [viewNetworkConnectionPopUp addSubview:lblMessage];
        
        
        [UIView transitionWithView:viewNetworkConnectionPopUp duration:0.3
                           options:UIViewAnimationOptionCurveEaseIn
                        animations:^{
                            [viewNetworkConnectionPopUp setFrame:CGRectMake(0, 0, DEVICE_WIDTH, 64)];
                        }
                        completion:^(BOOL finished) {
                        }];
    }
    
    [timerNetworkConnectionPopUp invalidate];
    timerNetworkConnectionPopUp = [NSTimer scheduledTimerWithTimeInterval:3 target:self selector:@selector(removeNetworkConnectionPopUp:) userInfo:nil repeats:NO];
}

#pragma mark - Location manager delegate
-(void)getLocationMethod
{
    NSLog(@"%s",__FUNCTION__);
    /*-----------Start Location Manager----------*/
    locationManager = [[CLLocationManager alloc] init];
    locationManager.delegate = self;
    locationManager.distanceFilter = kCLDistanceFilterNone; // whenever we move
    locationManager.desiredAccuracy = kCLLocationAccuracyBest; // 100 m
    if(IS_OS_8_OR_LATER)
    {
        [locationManager requestWhenInUseAuthorization];
    }
    [locationManager startUpdatingLocation];
    /*-------------------------------------------*/
}

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation
{
    CLLocation *currentLocation = newLocation;
    
    if (currentLocation != nil)
    {
        if ([appLatitude isEqualToString:@"0"] && [appLongitude isEqualToString:@"0"])
        {
            NSLog(@"%s",__FUNCTION__);
            appLatitude =[NSString stringWithFormat:@"%f",currentLocation.coordinate.latitude];
            appLongitude =[NSString stringWithFormat:@"%f",currentLocation.coordinate.longitude];
            
            [[NSNotificationCenter defaultCenter] postNotificationName:@"reloadRestaurantListNotification" object:nil];
        }
        else
        {
            appLatitude =[NSString stringWithFormat:@"%f",currentLocation.coordinate.latitude];
            appLongitude =[NSString stringWithFormat:@"%f",currentLocation.coordinate.longitude];
        }
    }
    
//    NSLog(@"appLatitude===%@,appLongitude====%@",appLatitude,appLongitude);
    
//    double lati = newLocation.coordinate.latitude;
//    NSString * _geocoder_latitude_str= [NSString stringWithFormat:@"%.4f",lati];
//    [curent_lat_ary addObject:_geocoder_latitude_str];
//    double longi = newLocation.coordinate.longitude;
//    _geocoder_longitude_str=[NSString stringWithFormat:@"%.4f",longi];
//    [cureent_log_ary addObject:_geocoder_longitude_str];
//    NSUserDefaults *current_lat=[NSUserDefaults standardUserDefaults];
//    [current_lat setObject:_geocoder_latitude_str forKey:@"current_lat"];
//    [current_lat setObject:_geocoder_longitude_str forKey:@"current_long"];
//    [locationManager stopUpdatingLocation];
    
    CLGeocoder *reverseGeocoder = [[CLGeocoder alloc] init];
    
    [reverseGeocoder reverseGeocodeLocation:newLocation completionHandler:^(NSArray *placemarks, NSError *error) {
        // NSLog(@"Received placemarks: %@", placemarks);
        
        CLPlacemark *myPlacemark = [placemarks objectAtIndex:0];
        phoneCountryCode = myPlacemark.ISOcountryCode;
        phoneCountryName = myPlacemark.country;
//        NSString *cityName= myPlacemark.subAdministrativeArea;
        
        
//        if (countryName != nil || [countryName length]!=0 || ![countryName isEqual:[NSNull null]])
//        {
//            NSString * savedName = [[NSUserDefaults standardUserDefaults] valueForKey:@"CountryName"];
//            
//            if (savedName != nil || [savedName length]!=0 || ![savedName isEqual:[NSNull null]] || ![savedName isEqualToString:@"<nil>"])
//            {
//                
//            }
//            else
//            {
////                [[NSUserDefaults standardUserDefaults] setValue:countryCode forKey:@"CountryCode"];
////                [[NSUserDefaults standardUserDefaults] setValue:countryName forKey:@"CountryName"];
////                [[NSUserDefaults standardUserDefaults] synchronize];
//            }
//
//        }
       
    }];

}

-(void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    NSLog(@"error===%@",error);
    NSLog(@"%s",__FUNCTION__);
}
#pragma mark  HIDE TAB BAR AT BOTTOM
- (void) hideTabBar:(UITabBarController *) tabbarcontroller
{
    tabbarcontroller.tabBar.hidden = YES;
    mainTabBarController.tabBar.hidden = YES;
}

#pragma mark  SHOW TAB BAR AT BOTTOM
- (void) showTabBar:(UITabBarController *) tabbarcontroller
{
    tabbarcontroller.tabBar.hidden = NO;
}
-(BOOL)isNetworkreachable
{
    Reachability *networkReachability = [[Reachability alloc] init];
    NetworkStatus networkStatus = [networkReachability internetConnectionStatus];
    if (networkStatus == NotReachable)
    {
        return NO;
    }
    else
    {
        return YES;
    }
}
-(void)movetoSelectedInex:(NSInteger)selectedIndex
{
    [mainTabBarController setSelectedIndex:selectedIndex];
}
-(void)movetoLogin
{
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:1.3];
    [UIView setAnimationTransition:UIViewAnimationTransitionFlipFromLeft forView:[[UIApplication sharedApplication] keyWindow] cache:YES];
    [UIView commitAnimations];
    
    LoginVC * splash = [[LoginVC alloc] init];
    UINavigationController * navControl = [[UINavigationController alloc] initWithRootViewController:splash];
    navControl.navigationBarHidden=YES;
    self.window.rootViewController = navControl;
}
#pragma mark Hud Method
-(void)startHudProcess:(NSString *)text
{
    HUD = [[MBProgressHUD alloc] initWithView:self.window];
    HUD.labelText = text;
    [self.window addSubview:HUD];
    [HUD show:YES];
}
-(void)endHudProcess
{
    [HUD hide:YES];
}
-(void)showSessionExpirePopup
{
    [alertView hide];
    [alertView removeFromSuperview];
    alertView = [[URBAlertView alloc] initWithTitle:ALERT_TITLE message:@"Your session has expired. Please login first." cancelButtonTitle:OK_BTN otherButtonTitles: nil, nil];
    alertView.tag = 412;
    [alertView setMessageFont:[UIFont fontWithName:CGRegular size:14]];
    [alertView setHandlerBlock:^(NSInteger buttonIndex, URBAlertView *alertView) {
        [alertView hideWithCompletionBlock:^{
            
            [[NSUserDefaults standardUserDefaults] setObject:@"NO" forKey:@"IS_LOGGEDIN"];
            [[NSUserDefaults standardUserDefaults] synchronize];
            
            [APP_DELEGATE movetoLogin];
            
        }];
    }];
    [alertView showWithAnimation:URBAlertAnimationTopToBottom];
    if (IS_IPHONE_X){[alertView showWithAnimation:URBAlertAnimationDefault];}
}

-(void)updateBadgeCount
{
    NSMutableArray * tmp1 = [[NSMutableArray alloc] init];
    NSMutableArray * tmp2 = [[NSMutableArray alloc] init];
    NSMutableArray * tmp3 = [[NSMutableArray alloc] init];

    NSString * str1 = [NSString stringWithFormat:@"Select * from tbl_install where is_sync = 0 and user_id = '%@'",CURRENT_USER_ID];
    [[DataBaseManager dataBaseManager] execute:str1 resultsArray:tmp1];

    NSString * str2 = [NSString stringWithFormat:@"Select * from tbl_uninstall where is_sync = 0 and user_id = '%@'",CURRENT_USER_ID];
    [[DataBaseManager dataBaseManager] execute:str2 resultsArray:tmp2];

    NSString * str3 = [NSString stringWithFormat:@"Select * from tbl_inspection where is_sync = 0 and user_id = '%@'",CURRENT_USER_ID];
    [[DataBaseManager dataBaseManager] execute:str3 resultsArray:tmp3];

    [UIApplication sharedApplication].applicationIconBadgeNumber=[tmp1 count] + [tmp2 count] + [tmp3 count];
}

-(NSString *)getConvertedDate:(NSString *)strDate withFormat:(NSString *)strFormat
{
    NSDateFormatter * dateFormater =[[NSDateFormatter alloc] init];
    [dateFormater setDateFormat:@"YYYY-MM-dd HH:mm"];
    
    NSDate * serverDate =[dateFormater dateFromString:strDate];
    
    NSString * globalDateFormat = [NSString stringWithFormat:@"%@ HH:mm",strFormat];
    [dateFormater setDateFormat:globalDateFormat];
    
    NSString * strDateConverted =[dateFormater stringFromDate:serverDate];
    return strDateConverted;
}

-(NSString *)base64String:(NSString *)str
{
    NSData *theData = [str dataUsingEncoding: NSASCIIStringEncoding];
    const uint8_t* input = (const uint8_t*)[theData bytes];
    NSInteger length = [theData length];
    
    static char table[] = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/=";
    
    NSMutableData* data = [NSMutableData dataWithLength:((length + 2) / 3) * 4];
    uint8_t* output = (uint8_t*)data.mutableBytes;
    
    NSInteger i;
    for (i=0; i < length; i += 3) {
        NSInteger value = 0;
        NSInteger j;
        for (j = i; j < (i + 3); j++)
        {
            value <<= 8;
            if (j < length) {
                
                value |= (0xFF & input[j]);
            }
        }
        
        NSInteger theIndex = (i / 3) * 4;
        output[theIndex + 0] =                    table[(value >> 18) & 0x3F];
        output[theIndex + 1] =                    table[(value >> 12) & 0x3F];
        output[theIndex + 2] = (i + 1) < length ? table[(value >> 6)  & 0x3F] : '=';
        output[theIndex + 3] = (i + 2) < length ? table[(value >> 0)  & 0x3F] : '=';
    }
    
    return [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];
}
-(NSString *)GetRealDatefromTimeStamp:(NSString *)strTimeStamp
{
    NSString *mainStr = strTimeStamp;
    NSString * newString = [mainStr substringToIndex:[mainStr length]-3];
    
    double unixTimeStamp = [newString doubleValue];
    NSTimeInterval _interval=unixTimeStamp;
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:_interval];
    NSDateFormatter *_formatter=[[NSDateFormatter alloc]init];
//    NSTimeZone *gmt = [NSTimeZone timeZoneWithAbbreviation:@"UTC"];
    NSTimeZone *gmt = [NSTimeZone localTimeZone];

    [_formatter setTimeZone:gmt];
    [_formatter setDateFormat:[NSString stringWithFormat:@"%@ HH:mm",[[NSUserDefaults standardUserDefaults] valueForKey:@"GloablDateFormat"]]];
    NSString *strDates=[_formatter stringFromDate:date];

    return strDates;
}
-(void)getPlaceholderText:(UITextField *)txtField  andColor:(UIColor*)color
{
    Ivar ivar =  class_getInstanceVariable([UITextField class], "_placeholderLabel");
          UILabel *placeholderLabel = object_getIvar(txtField, ivar);
          placeholderLabel.textColor = color;
}

- (NSString *)dateValueFromDate:(NSString *)dateStr withGiveDatetoShow:(NSString *)strAttachDate
{
    NSString * globalDateFormat = [NSString stringWithFormat:@"YYYY-MM-dd HH:mm"];

    NSDateFormatter *_formatter=[[NSDateFormatter alloc]init];
    [_formatter setDateFormat:globalDateFormat];
    NSTimeZone *gmt = [NSTimeZone localTimeZone];
    [_formatter setTimeZone:gmt];

    NSDate * serverDate =[_formatter dateFromString:dateStr];
    [_formatter setDateFormat:globalDateFormat];
    
//    NSString * strDateConverted =[_formatter stringFromDate:serverDate];

    NSCalendar *calender = [NSCalendar currentCalendar];
    NSDateComponents *compenents = [calender components:(NSCalendarUnitYear |
                                                         NSCalendarUnitMonth |
                                                         NSCalendarUnitDay |
                                                         NSCalendarUnitHour |
                                                         NSCalendarUnitMinute |
                                                         NSCalendarUnitSecond) fromDate:serverDate];
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    
    NSTimeZone *timeZone = [NSTimeZone localTimeZone];
    [dateFormatter setTimeZone:timeZone];
    [dateFormatter setDateFormat:[NSString stringWithFormat:@"YYYY-MM-dd HH:mm"]];
    NSString *currnetDate = [dateFormatter stringFromDate:[NSDate date]];
    
    NSDateComponents *currentDateComponents = [calender components:(NSCalendarUnitYear |
                                                                    NSCalendarUnitMonth |
                                                                    NSCalendarUnitDay |
                                                                    NSCalendarUnitHour |
                                                                    NSCalendarUnitMinute |
                                                                    NSCalendarUnitSecond) fromDate:[dateFormatter dateFromString:currnetDate]];
    if (compenents.year < currentDateComponents.year)
    {
        NSString * strReturn = [NSString stringWithFormat:@"%i",(currentDateComponents.year - compenents.year)];
        if ([strReturn isEqualToString:@"1"])
        {
            return [NSString stringWithFormat:@"%@ \n(%i Year ago)",strAttachDate,(currentDateComponents.year - compenents.year)];
        }
        else
        {
            return [NSString stringWithFormat:@"%@ \n(%i Years ago)",strAttachDate,(currentDateComponents.year - compenents.year)];
        }
    }
    else if (compenents.month < currentDateComponents.month)
    {
        NSString * strReturn = [NSString stringWithFormat:@"%i",(currentDateComponents.month - compenents.month)];
        if ([strReturn isEqualToString:@"1"])
        {
            return [NSString stringWithFormat:@"%@ \n(%i Month ago)",strAttachDate,(currentDateComponents.month - compenents.month)];
        }
        else
        {
            return [NSString stringWithFormat:@"%@ \n(%i Months ago)",strAttachDate,(currentDateComponents.month - compenents.month)];
        }
    }
    else if (compenents.day < currentDateComponents.day)
    {
        NSString * strReturn = [NSString stringWithFormat:@"%i",(currentDateComponents.day - compenents.day)];
        if ([strReturn isEqualToString:@"1"])
        {
            return [NSString stringWithFormat:@"%@ \n(%i Day ago)",strAttachDate,(currentDateComponents.day - compenents.day)];
        }
        else
        {
            return [NSString stringWithFormat:@"%@ \n(%i Days ago)",strAttachDate,(currentDateComponents.day - compenents.day)];
        }
    }
    else if (compenents.hour < currentDateComponents.hour)
    {
        NSString * strReturn = [NSString stringWithFormat:@"%i",(currentDateComponents.hour - compenents.hour)];
        if ([strReturn isEqualToString:@"1"])
        {
            return [NSString stringWithFormat:@"%@ \n(%i Hour ago)",strAttachDate,(currentDateComponents.hour - compenents.hour)];
        }
        else
        {
            return [NSString stringWithFormat:@"%@ \n(%i Hours ago)",strAttachDate,(currentDateComponents.hour - compenents.hour)];
        }
    }
    else
    {
        NSString * strReturn = [NSString stringWithFormat:@"%i",(currentDateComponents.minute - compenents.minute)];
        if ([strReturn isEqualToString:@"1"])
        {
            return [NSString stringWithFormat:@"%@ \n(%i Minute ago)",strAttachDate,(currentDateComponents.minute - compenents.minute)];
        }
        else
        {
            return [NSString stringWithFormat:@"%@ \n(%i Minutes ago)",strAttachDate,(currentDateComponents.minute - compenents.minute)];
        }
    }
    return kEmptyString;
}
// LIVE  https:// ws.succorfish.net
// STAGING https://  ws.scstg.net/
@end
