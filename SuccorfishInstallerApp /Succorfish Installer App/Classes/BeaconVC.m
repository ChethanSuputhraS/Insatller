//
//  BeaconVC.m
//  Succorfish Installer App
//
//  Created by Ashwin on 7/30/20.
//  Copyright © 2020 Kalpesh Panchasara. All rights reserved.
//
#import "Reachability.h"
#import "BeaconVC.h"
#import "BeaconHistory.h"
#import "BeaconBarcodeScnVC.h"
#import "InstallBeconVC.h"

@interface BeaconVC ()<URLManagerDelegate>
{
    int textSize;
    NSMutableDictionary *dictScanData,*dictSelected;
    UILabel * lblScanID;
    NSString * strLocalBleNum;
    BOOL isUninstallClick;

}
@end

@implementation BeaconVC

- (void)viewDidLoad
{
    self.navigationController.navigationBarHidden = true;
    
    textSize = 16;
       if (IS_IPHONE_4 || IS_IPHONE_5)
       {
           textSize = 14;
       }
    
    UIImageView * imgBack = [[UIImageView alloc] init];
    imgBack.frame = CGRectMake(0, 0, DEVICE_WIDTH, DEVICE_HEIGHT);
    imgBack.image = [UIImage imageNamed:@"Splash_bg.png"];
    imgBack.userInteractionEnabled = YES;
    [self.view addSubview:imgBack];
    
    UIView * navigView = [[UIView alloc] initWithFrame:CGRectMake(0, 0 , DEVICE_WIDTH, 64)];
    navigView.backgroundColor = UIColor.blackColor;
    [self.view addSubview:navigView];
    
    UILabel * lblHeadere = [[UILabel alloc] initWithFrame:CGRectMake(50, 20, DEVICE_WIDTH-100, 44)];
    lblHeadere.text = @"Beacon";
    lblHeadere.textColor = UIColor.whiteColor;
    lblHeadere.font = [UIFont fontWithName:CGRegular size:textSize+1];
    lblHeadere.textAlignment = NSTextAlignmentCenter;
    [navigView addSubview:lblHeadere];
    
    UIImageView * backImg = [[UIImageView alloc] initWithFrame:CGRectMake(10, 12+20, 12, 20)];
    [backImg setImage:[UIImage imageNamed:@"back_icon.png"]];
    [backImg setContentMode:UIViewContentModeScaleAspectFit];
    backImg.backgroundColor = [UIColor clearColor];
    [navigView addSubview:backImg];
    
    UIButton * btnBack = [UIButton buttonWithType:UIButtonTypeCustom];
     btnBack.frame = CGRectMake(0, 10, 70, 54);
     [btnBack addTarget:self action:@selector(btnBackClick) forControlEvents:UIControlEventTouchUpInside];
     btnBack.backgroundColor = [UIColor clearColor];
//    [btnBack setImage:[UIImage imageNamed:@"back_icon.png"] forState:UIControlStateNormal];
    [navigView addSubview:btnBack];
    
    int yy = 60;
    UILabel * lblNote = [[UILabel alloc] initWithFrame:CGRectMake(0, yy, DEVICE_WIDTH, 30)];
    lblNote.text = @"Please scan Beacon ID to access Beacon features";
    lblNote.textColor = UIColor.whiteColor;
    lblNote.backgroundColor = UIColor.blackColor;
    lblNote.font = [UIFont fontWithName:CGRegular size:textSize-1];
    lblNote.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:lblNote];
    
//    UILabel * lblLineN = [[UILabel alloc] initWithFrame:CGRectMake(5, 29, DEVICE_WIDTH-10, 0.5)];
//    lblLineN.backgroundColor = UIColor.blackColor;
//    [lblNote addSubview:lblLineN];
    
    yy = yy +60;
    
    UIButton * btnScanBeacon =[[UIButton alloc] initWithFrame:CGRectMake(0, yy, DEVICE_WIDTH, 50)];
    [btnScanBeacon setTitle:@"  Scan Beacon ID" forState:UIControlStateNormal];
    [btnScanBeacon addTarget:self action:@selector(btnscanClick) forControlEvents:UIControlEventTouchUpInside];
    btnScanBeacon.backgroundColor = UIColor.clearColor;
//    [btnScanBeacon setImage:[UIImage imageNamed:@"arrow.png"] forState:UIControlStateNormal];
    btnScanBeacon.contentHorizontalAlignment = UIMenuControllerArrowRight;
    btnScanBeacon.titleLabel.font = [UIFont fontWithName:CGRegular size:textSize+1];
    [btnScanBeacon setTitleColor:UIColor.whiteColor forState:normal];
    [self.view addSubview:btnScanBeacon];
    
        UIImageView * arrowImg = [[UIImageView alloc] initWithFrame:CGRectMake(DEVICE_WIDTH-15, 17, 9, 15)];
        [arrowImg setImage:[UIImage imageNamed:@"rightArrow.png"]];
        [btnScanBeacon addSubview:arrowImg];
     
    UILabel * lblLine = [[UILabel alloc] initWithFrame:CGRectMake(5, 42, DEVICE_WIDTH-10, 0.5)];
    lblLine.backgroundColor = UIColor.whiteColor;
    [btnScanBeacon addSubview:lblLine];
    
    
    lblScanID = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, DEVICE_WIDTH-20, 50)];
    lblScanID.textColor = UIColor.whiteColor;
    lblScanID.font = [UIFont fontWithName:CGBoldItalic size:textSize];
    lblScanID.textAlignment = NSTextAlignmentRight;
    [btnScanBeacon addSubview:lblScanID];
    
    
//    NSLog(@"ScanData=====>>>%@",dictScanData);
    [self SetupForButtons];
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}
-(void)viewWillAppear:(BOOL)animated
{
    [APP_DELEGATE hideTabBar:self.tabBarController];
    
    [super viewWillAppear:YES];
}
-(void)SetupForButtons
{
      
    UIView * viewForButton = [[UIView alloc] initWithFrame:CGRectMake(30, 190, DEVICE_WIDTH-60, DEVICE_HEIGHT-250)];
    viewForButton.backgroundColor = UIColor.clearColor;
    [self.view addSubview:viewForButton];
    
     int xx = 15;
     int yy = 0;
     int cnt = 0;
//     int vWidth = (DEVICE_WIDTH/2);
//     int vHeighth = (DEVICE_WIDTH/2) + 10;
    
     int vWidth = (viewForButton.frame.size.width/2);
     int vHeighth = (viewForButton.frame.size.width/2) + 10;
    
    if (IS_IPHONE_4)
    {
        vHeighth = (DEVICE_WIDTH/3);
        viewForButton.frame = CGRectMake(30, (66+65+40)*approaxSize, DEVICE_WIDTH-60, 270*approaxSize);
    }
    else if (IS_IPHONE_X)
    {
        viewForButton.frame = CGRectMake(30, (160)*approaxSize, DEVICE_WIDTH-60, 300*approaxSize);
    }
    
    NSArray * nameArr = [NSArray arrayWithObjects:@"Install Beacon",@"Uninstall Beacon",@"Mark as faulty",@"Beacon History", nil];
    
    NSArray * imgArr = [NSArray arrayWithObjects:@"new installation.png",@"uninstall.png",@"unsynced.png",@"install guide.png", nil];
    
    for (int i=0; i<2; i++)
       {
           xx=0;
             int columCount = 2;
           
           for (int j=0; j<columCount; j++)
           {
               UILabel * lblTmp = [[UILabel alloc] init];
               lblTmp.frame = CGRectMake(xx, yy, vWidth, vHeighth);
               lblTmp.backgroundColor = [UIColor clearColor];
               lblTmp.userInteractionEnabled = YES;
               lblTmp.text = @" ";
               [viewForButton addSubview:lblTmp];
               
               UIImageView * img = [[UIImageView alloc] init];
               img.frame = CGRectMake((vWidth-90)/2,(vHeighth-90)/2, 90, 90); // (vWidth-80)/2
               img.image = [UIImage imageNamed:[imgArr objectAtIndex:cnt]];
               img.backgroundColor = [UIColor clearColor];
               [lblTmp addSubview:img];
               
                UILabel * lblName = [[UILabel alloc] init];
               lblName.frame = CGRectMake(0, vHeighth-40, vWidth, 30);
               lblName.text = [NSString stringWithFormat:@"%@",[nameArr objectAtIndex:cnt]];
               [lblName setFont:[UIFont fontWithName:CGRegular size:textSize]];
               lblName.textColor = [UIColor whiteColor];
               lblName.textAlignment = NSTextAlignmentCenter;
               [lblTmp addSubview:lblName];
               
               UIButton * btnTap = [UIButton buttonWithType:UIButtonTypeCustom];
               btnTap.frame = lblTmp.frame;
               [btnTap addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
               btnTap.tag = cnt;
               [viewForButton addSubview:btnTap];
               
               if (IS_IPHONE_4 || IS_IPHONE_5)
                 {
                     [lblName setFont:[UIFont fontWithName:CGRegular size:13]];
                     lblName.frame = CGRectMake(0, vHeighth-15, vWidth, 20);
                 }

                 if (IS_IPHONE_4)
                 {
                     img.frame = CGRectMake((vWidth-70)/2,(vHeighth-70)/2-0, 70, 70); //(vWidth-70)/2
                     lblName.frame = CGRectMake(0, vHeighth-15, vWidth, 20);
                 }
               
           xx = vWidth + xx;
            cnt = cnt +1;
        }
        yy = yy + vHeighth + 10 ;
    }
}
-(void)btnClick:(id)sender
{
    if ([[self checkforValidString:strLocalBleNum] isEqualToString:@"NA"])
    {
        URBAlertView * alert =[[URBAlertView alloc] initWithTitle:ALERT_TITLE message:@"Please scan  \"Beacon device ID\"." cancelButtonTitle:@"Cancel" otherButtonTitles:@"Scan", nil];
           [alert setHandlerBlock:^(NSInteger buttonIndex, URBAlertView *alertView) {
           [alertView hideWithCompletionBlock:^
               {
               if (buttonIndex==0)
               {
               }
               else
               {
                   BeaconBarcodeScnVC * barCodeScan = [[BeaconBarcodeScnVC alloc] init];
                   [self.navigationController pushViewController:barCodeScan animated:true];
               }
           }];
 }];
               [alert showWithAnimation:URBAlertAnimationTopToBottom];
    }
    else
    {
        if ([sender tag] == 0)
           {
            [self getLatestStatusofBeacon:@"checkStatusforInstall"];
           }
           else if ([sender tag] == 1)
           {
               [self getLatestStatusofBeacon:@"checkStatusforUnInstall"];
           }
           else if ([sender tag] == 2)
           {
              [self getLatestStatusofBeacon:@"checkStatusforfaulty"];
           }
           else if ([sender tag] == 3)
           {
               [self getLatestStatusofBeacon:@"checkStatusforHistory"];
           }
    }
}
-(void)btnBackClick
{
    [self.navigationController popViewControllerAnimated:true];
}
-(void)btnscanClick
{
    BeaconBarcodeScnVC * bScan = [[BeaconBarcodeScnVC alloc] init];
    [self.navigationController pushViewController:bScan animated:true];
}
-(void)GetBeaconNumber:(NSMutableDictionary *)dataDict // it for calling api
{
    dictScanData = dataDict ;
    lblScanID.text = [dataDict valueForKey:@"id"];
}
-(void)GetLocalBleNUmber :(NSString *)strLocalBleNumBer // now only get the manually enterd number in scan vc
{
    lblScanID.text = strLocalBleNumBer;
    strLocalBleNum = strLocalBleNumBer;
}
#pragma mark - Web Service Call
-(void)getLatestStatusofBeacon:(NSString *)strStatus
{
    if ([APP_DELEGATE isNetworkreachable])
    {
        [APP_DELEGATE endHudProcess];
        [APP_DELEGATE startHudProcess:@"Fetching beacon details..."];
        NSString * strUrl = [NSString stringWithFormat:@"https://ws.scstg.net/basic/v2/beacon/getLatest/%@",strLocalBleNum];// strLocalBleNum ble number
        URLManager *manager = [[URLManager alloc] init];
        manager.commandName = strStatus;
        manager.delegate = self;
        [manager getUrlCall:strUrl withParameters:nil];
    }
    else
    {
        [self ErrorPOPupMsg:@"Please check internet connection and try again."];
    }
}
-(void)UninstallBeaconDeviceAPIcall
{
    if ([APP_DELEGATE isNetworkreachable])
    {
        [APP_DELEGATE endHudProcess];
        [APP_DELEGATE startHudProcess:@"Uninstalling..."];

        NSString * strUrlUninsatll = [NSString stringWithFormat:@"https://ws.scstg.net/basic/v2/beacon/uninstall/%@",strLocalBleNum];
        URLManager *manager = [[URLManager alloc] init];
        manager.commandName = @"Uninstall";
        manager.delegate = self;
        [manager postUrlCall:strUrlUninsatll withParameters:nil];
    }
    else
    {
        [self ErrorPOPupMsg:@"Please check internet connection and try again."];
    }
}
-(void)MarkDeviceBeaconDeviceasFaultyAPIcall
{
    if ([APP_DELEGATE isNetworkreachable])
    {
        [APP_DELEGATE endHudProcess];
        [APP_DELEGATE startHudProcess:@"Marking  as faulty..."];

        NSString * strUrlMArkFaulty = [NSString stringWithFormat:@"https://ws.scstg.net/basic/v2/beacon/markAsFaulty/%@",strLocalBleNum];
        URLManager *manager = [[URLManager alloc] init];
        manager.commandName = @"MarkFaulty";
        manager.delegate = self;
        [manager postUrlCall:strUrlMArkFaulty withParameters:nil];
    }
    else
    {
        [self ErrorPOPupMsg:@"Please check internet connection and try again."];
    }
}

-(NSString *)checkforValidString:(NSString *)strRequest
{
    NSString * strValid;
    if (![strRequest isEqual:[NSNull null]])
    {
        if (strRequest != nil && strRequest != NULL && ![strRequest isEqualToString:@""])
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
    strValid = [strValid stringByReplacingOccurrencesOfString:@"\"" withString:@""];

    return strValid;
}
#pragma mark - UrlManager Delegate
- (void)onResult:(NSMutableDictionary *)result
{
    //    NSLog(@"The result is...%@", result);
    [APP_DELEGATE endHudProcess];
    NSMutableDictionary * dictResult = [[NSMutableDictionary alloc] init];
    dictResult = [result valueForKey:@"result"];
    
    if ([dictResult isKindOfClass:[NSDictionary class]])
    {
        NSArray * arrKeys = [dictResult allKeys];
        if([arrKeys containsObject:@"errors"])
        {
            [self ErrorPOPupMsg:[NSString stringWithFormat:@"%@", [[result valueForKey:@"result"] valueForKey:@"status"]]];
        }
        else
        {
            if([[result valueForKey:@"commandName"] isEqual:@"checkStatusforInstall"])
            {
                    [self checkStatusforInstall:dictResult];
            }
            else if ([[result valueForKey:@"commandName"] isEqual:@"checkStatusforUnInstall"])
            {
                if ([[dictResult valueForKey:@"status"] isEqual:@"INSTALLED"])
                {
                    [self checkStatusforUNInstall:dictResult];
                }
                else
                {
                    [self ErrorPOPupMsg:@"Beacon device is \"NOT INSTALLED\" ."];
                }
            }
            else if ([[result valueForKey:@"commandName"] isEqual:@"checkStatusforfaulty"])
            {
                [self checkStatusformarkFaulty:dictResult];
             }
            else if ([[result valueForKey:@"commandName"] isEqual:@"checkStatusforHistory"])
            {
                BeaconHistory * hvc = [[BeaconHistory alloc] init];
                hvc.dictData = result;
                [self.navigationController pushViewController:hvc animated:true];
            }
            else if ([[result valueForKey:@"commandName"]  isEqual:@"Uninstall"])
            {
            [self ErrorPOPupMsg:@"\"UNINSTALLED\"  successfully."];
             }
            else if ([[result valueForKey:@"commandName"]  isEqual:@"MarkFaulty"])
              {
               [self ErrorPOPupMsg:@"Beacon device \"MARKED AS FAULTY\" ."];
              }
        }
    }
    else if ([dictResult isKindOfClass:[NSArray class]])
    {
        NSArray * arr = [dictResult mutableCopy];
        if ([arr count]>0)
        {
            NSString * str = [[arr objectAtIndex:0] valueForKey:@"errorCode"];
            str = [str stringByReplacingOccurrencesOfString:@"." withString:@" "];
            [self ErrorPOPupMsg:str];
        }
    }
}
- (NSString *)StatusCodeRead:(NSString *)url // for testing status code: 200 // not required
{
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setHTTPMethod:@"GET"];
    [request setURL:[NSURL URLWithString:url]];

    NSError *error = nil;
    NSHTTPURLResponse *responseCode = nil;
    NSData *oResponseData = [NSURLConnection sendSynchronousRequest:request returningResponse:&responseCode error:&error];
    return [[NSString alloc] initWithData:oResponseData encoding:NSUTF8StringEncoding];
}
-(void)checkStatusforInstall:(NSMutableDictionary *)arrData
{
    if ([[arrData valueForKey:@"status"] isEqual:@"INSTALLED"])
     {
         [self ErrorPOPupMsg:@"Beacon device is already \"INSTALLED\" . \"UNINSTALL\" first and try again"];
     }
     else if ([[arrData valueForKey:@"status"] isEqual:@"IN_STOCK"])
     {
         [self ErrorPOPupMsg:@"Beacon device is not ready to install now. Its in \"IN STOCK\" status."];
     }
     else if ([[arrData valueForKey:@"status"] isEqual:@"FAULTY"])
     {
         [self ErrorPOPupMsg:@"Beacon device looks like \"FAULTY\".Please try diffrent one."];
     }
    else if ([[arrData valueForKey:@"status"] isEqual:@"DELIVERED"] || [[arrData valueForKey:@"status"] isEqual:@"UNINSTALLED"] )
    {
        [self InstallStatus];
    }
}
-(void)checkStatusforUNInstall:(NSMutableDictionary *)dictdata
{
    if ([[dictdata valueForKey:@"status"] isEqual:@"INSTALLED"])
    {
         URBAlertView * alert =[[URBAlertView alloc] initWithTitle:ALERT_TITLE message:@"Are you sure to \"UNINSTALL\" Beacon device ?" cancelButtonTitle:@"Cancel" otherButtonTitles:@"Yes", nil];
                   [alert showWithAnimation:URBAlertAnimationTopToBottom];
                   [alert setHandlerBlock:^(NSInteger buttonIndex, URBAlertView *alertView) {
                   [alertView hideWithCompletionBlock:^
                              {
                       if (buttonIndex==0)
                       {
                       }
                       else
                       {
                           [self UninstallBeaconDeviceAPIcall];
                       }
                   }];
               }];
        [alert showWithAnimation:URBAlertAnimationTopToBottom];
    }
    else
    {
        [self ErrorPOPupMsg:@"Beacon device is not \"INSTALLED\"."];
    }
}
-(void)checkStatusformarkFaulty:(NSMutableDictionary *)dictdata
{
    if ([[dictdata valueForKey:@"status"] isEqual:@"FAULTY"])
    {
        [self ErrorPOPupMsg:@"Beacon device is already \"MARKED AS FAULTY\"."];
    }
    else if([[dictdata valueForKey:@"status"] isEqual:@"IN_STOCK"])
    {
        [self ErrorPOPupMsg:@"You can't mark as \"FAULTY\". Its in \"IN STOCK\" status."];
    }
    else
    {
        URBAlertView * alert =[[URBAlertView alloc] initWithTitle:ALERT_TITLE message:@"Are you sure Beacon device is \"FAULTY\" ?" cancelButtonTitle:@"Cancel" otherButtonTitles:@"Yes", nil];
            [alert setHandlerBlock:^(NSInteger buttonIndex, URBAlertView *alertView) {
                [alertView hideWithCompletionBlock:^
                {
                    if (buttonIndex==0)
                    {
                    }
                    else
                    {
                        [self MarkDeviceBeaconDeviceasFaultyAPIcall];
                    }
                 }];
        }];
            [alert showWithAnimation:URBAlertAnimationTopToBottom];
    }
}
-(void)InstallStatus
{
    URBAlertView *alertView = [[URBAlertView alloc] initWithTitle:ALERT_TITLE message:@"Beacon device is ready to \"INSTALL\"." cancelButtonTitle:@"Cancel" otherButtonTitles: @"Install", nil];
    [alertView setMessageFont:[UIFont fontWithName:CGRegular size:14]];
    [alertView setHandlerBlock:^(NSInteger buttonIndex, URBAlertView *alertView) {
        [alertView hideWithCompletionBlock:^{
            [UIView beginAnimations:nil context:NULL];
            [UIView setAnimationDuration:1.3];
            [UIView commitAnimations];
            if (buttonIndex==0)
            {
            }
            else
            {
                globalbeaconVC = [[InstallBeconVC alloc] init];
                globalbeaconVC.strBLeID = lblScanID.text;
                [self.navigationController pushViewController:globalbeaconVC animated:true];
            }
        }];
    }];
    [alertView showWithAnimation:URBAlertAnimationTopToBottom];
}
- (void)onError:(NSError *)error
{
    [APP_DELEGATE endHudProcess];
    [self ErrorPOPupMsg:@"Please check \"Beacon device ID\""];
    NSLog(@"The error is...%@", error);
}
-(void)ErrorPOPupMsg:(NSString *)strErrorMsg
{
     URBAlertView * alert =[[URBAlertView alloc] initWithTitle:ALERT_TITLE message:strErrorMsg  cancelButtonTitle:OK_BTN otherButtonTitles:nil, nil];
    [alert showWithAnimation:URBAlertAnimationTopToBottom];
    if (IS_IPHONE_X){[alert showWithAnimation:URBAlertAnimationDefault];}

}
@end
