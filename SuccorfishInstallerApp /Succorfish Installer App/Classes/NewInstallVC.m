//
//  NewInstallVC.m
//  Succorfish Installer App
//
//  Created by stuart watts on 21/02/2018.
//  Copyright © 2018 Kalpesh Panchasara. All rights reserved.
//

#import "NewInstallVC.h"
#import "PSProfileStepper.h"
#import "BarcodeScanVC.h"
#import "TestDeviceVC.h"
#import "VesselVC.h"
#import "PhotoView.h"
#import "SignVC.h"
#import "MapClassVC.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import <Photos/Photos.h>
#import "ALAssetsLibrary+CustomPhotoAlbum.h"
#import "AFHTTPRequestOperation.h"
#import "AFHTTPRequestOperationManager.h"
#import "LastWaypointVC.h"
#import <MessageUI/MessageUI.h>
#import "NewInstallCell.h"
@interface NewInstallVC ()<UITextFieldDelegate,URLManagerDelegate,MFMailComposeViewControllerDelegate,UITableViewDelegate,UITableViewDataSource>
{
    PSProfileStepper *stepperView;
    int indexOne,intInstallID,textSize;
    BOOL isSecondBuilt, isThirdBuilt, isAgreed, isInstalledDetailSynced;
    NSString * strInstallID, * strDateTime;
    UIImageView * imgCheck;
    NSString * localImageId, * serverInstallationID;
    NSString * strInstallerSignUrl, * strOwnerSignUrl;
//    NSString * strSuccorfishDeviceID;
    NSString * strPowerValues;
    BOOL isTestDeviceDone;
    UITableView*tblFirstView,*tblSecondView,*tblthirdView;
    URBAlertView *alertView;
}
@end

@implementation NewInstallVC
@synthesize isFromeEdit,detailDict,installID;

- (void)viewDidLoad
{
//    [self ErrorMessagePopup];

    strInstallID = installID;
    isTestDeviceDone = NO;
    isAllowtoGoAfterTest = NO;
    textSize = 16;
    if (IS_IPHONE_4 || IS_IPHONE_5)
    {
        textSize = 14;
    }
    
    globalDeviceType = @"";
    installScanID = @"";
    indexOne = 0;
    strInstallerSignUrl = @"NA";
    strOwnerSignUrl = @"NA";

    installVesselName = nil;
    installRegi = nil;

    UIImageView * imgBack = [[UIImageView alloc] init];
    imgBack.frame = CGRectMake(0, 0, DEVICE_WIDTH, DEVICE_HEIGHT);
    imgBack.image = [UIImage imageNamed:@"Splash_bg.png"];
    imgBack.userInteractionEnabled = YES;
    [self.view addSubview:imgBack];
    
    firstViewArray = [[NSMutableArray alloc]init];
    NSArray * arrayTitleFirst = [[NSArray alloc]initWithObjects:@"Scan Device",@"Device Type",@"Test Device",nil];
    for (int i=0; i<arrayTitleFirst.count; i++)
    {
        NSMutableDictionary *tmpDict = [[NSMutableDictionary alloc]initWithObjectsAndKeys:[arrayTitleFirst objectAtIndex:i],@"title",@"NA",@"value", nil];
        [firstViewArray addObject:tmpDict];
    }
    secondViewArray = [[NSMutableArray alloc]init];
    NSArray * arrayTitleSecond = [[NSArray alloc]initWithObjects:@"Date",@"latitude",@"Asset Name",@"Registration No.",@"Power Source",@"Device install location eg. up mast",@"Add Installation Photos",nil];
    for (int i=0; i<arrayTitleSecond.count; i++)
    {
        NSMutableDictionary *tmpDict = [[NSMutableDictionary alloc]initWithObjectsAndKeys:[arrayTitleSecond objectAtIndex:i],@"title",@"NA",@"value", nil];
        [secondViewArray addObject:tmpDict];
    }
    [[secondViewArray objectAtIndex:1]setValue:@"NA" forKey:@"longitudeValue"];
    
    thirdViewArray = [[NSMutableArray alloc]init];
    NSArray * arrayTitleThird = [[NSArray alloc]initWithObjects:@"Owner Name",@"Address",@"City",@"State",@"Email",@"Mobile No.",@"Signatures",@"Test Device",nil];
    for (int i=0; i<arrayTitleThird.count; i++)
    {
        NSMutableDictionary *tmpDict = [[NSMutableDictionary alloc]initWithObjectsAndKeys:[arrayTitleThird objectAtIndex:i],@"title",@"NA",@"value", nil];
        [thirdViewArray addObject:tmpDict];
    }
    [[thirdViewArray objectAtIndex:3]setValue:@"NA" forKey:@"zipValue"];
    arrayTextFieldTagValues = [[NSArray alloc]initWithObjects:@"101",@"102",@"103",@"104",@"106",@"107",@"108",@"109", nil];
    
    
    [self setNavigationViewFrames];
    [self setContentViews];
    [self setFirstView];
    
    deviceTypeArr = [[NSMutableArray alloc] init];
    powerArr = [[NSMutableArray alloc] init];
    installImgArr = [[NSMutableArray alloc] init];

    if (isFromeEdit)
    {
        strInstallID = [self checkforValidString:[detailDict valueForKey:@"id"]];
        strSuccorfishDeviceID = [self checkforValidString:[detailDict valueForKey:@"succor_device_id"]];

        if (![strInstallID isEqualToString:@"NA"])
        {
            intInstallID = [strInstallID intValue];
        }
    }
    else
    {
        detailDict = [[NSMutableDictionary alloc] init];
    }

    [self getDataforView];
    
    [super viewDidLoad];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"setSignaturePathsforInstalls" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(SetSignPaths:) name:@"setSignaturePathsforInstalls" object:nil];
    
//    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"DeviceInfoForInstall" object:nil];
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(fillDeviceDetails:) name:@"DeviceInfoForInstall" object:nil];

    // Do any additional setup after loading the view.
}

-(void)viewWillAppear:(BOOL)animated
{
    [APP_DELEGATE hideTabBar:self.tabBarController];
    
    [self checkForAppearFields];
    [super viewWillAppear:YES];
}
-(void)fillDeviceDetails:(NSNotification *)notify
{
    NSMutableDictionary * dict = [notify object];
    NSString * latitudeStr = [dict valueForKey:@"latitude"];
    NSString * longitudeStr = [dict valueForKey:@"longitude"];
    NSString * lastDateStr = [dict valueForKey:@"date"];
    
    lastLocationDict = [[NSMutableDictionary alloc] init];
    lastLocationDict = dict;
    if ([[self checkforValidString:latitudeStr] isEqualToString:@"NA"])
    {
        
    }
    else
    {
        if ([latitudeStr length]>=5)
        {
            latitudeStr=[latitudeStr substringToIndex:5];
        }
        
        if ([longitudeStr length]>=5)
        {
            longitudeStr=[longitudeStr substringToIndex:5];
        }
        lblLastLat.text = [NSString stringWithFormat:@"%@ , %@",latitudeStr,longitudeStr];
        imgLastArrow.hidden = NO;
        btnShowMap.hidden = NO;
    }
    
    if ([[self checkforValidString:lastDateStr] isEqualToString:@"NA"])
    {
        
    }
    else
    {
        NSString * dates = [APP_DELEGATE getConvertedDate:lastDateStr withFormat:[[NSUserDefaults standardUserDefaults]valueForKey:@"GloablDateFormat"]];

        if (![[self checkforValidString:dates] isEqualToString:@"NA"])
        {
            lblLastDate.text = [NSString stringWithFormat:@"%@",dates];
        }
    }
}
-(void)getDataforView
{
    [deviceTypeArr addObject:@"SC2"];
    NSArray * arrPowers = [NSArray arrayWithObjects:@"Constant 6-36V",@"Constant regulated 6-36V",@"Periodic 6-36V",@"Periodic regulated 6-36V",@"Solar",@"Internal rechargable Battery", nil];
    
    NSArray * arrKeys = [NSArray arrayWithObjects:@"CONSTANT",@"CONSTANT_REGULATED",@"PERIODIC",@"PERIODIC_REGULATED",@"SOLAR",@"BATTERY", nil];

    for (int i=0; i<[arrPowers count]; i++)
    {
        NSMutableDictionary * dicts = [[NSMutableDictionary alloc] init];
        [dicts setObject:[arrPowers objectAtIndex:i] forKey:@"name"];
        [dicts setObject:[arrKeys objectAtIndex:i] forKey:@"values"];
        [powerArr addObject:dicts];
    }
}

-(void)SetSignPaths:(NSNotification *)notifyDict
{
    NSMutableDictionary * tmpDict = [notifyDict object];
    strInstallerSignUrl = [tmpDict valueForKey:@"local_installer_sign"];
    strOwnerSignUrl =  [tmpDict valueForKey:@"local_owner_sign"];
    
    [detailDict setObject:strInstallerSignUrl forKey:@"local_installer_sign"];
    [detailDict setObject:strOwnerSignUrl forKey:@"local_owner_sign"];
}
#pragma mark - Set Frames
-(void)setNavigationViewFrames
{
    UIView * viewHeader = [[UIView alloc] initWithFrame:CGRectMake(0, 0, DEVICE_WIDTH, 64)];
    [viewHeader setBackgroundColor:[UIColor blackColor]];
    [self.view addSubview:viewHeader];
    
    UILabel * lblTitle = [[UILabel alloc] initWithFrame:CGRectMake(50, 20, DEVICE_WIDTH-100, 44)];
    [lblTitle setBackgroundColor:[UIColor clearColor]];
    [lblTitle setText:@"New Install"];
    [lblTitle setTextAlignment:NSTextAlignmentCenter];
    [lblTitle setFont:[UIFont fontWithName:CGRegular size:textSize+1]];
    [lblTitle setTextColor:[UIColor whiteColor]];
    [viewHeader addSubview:lblTitle];
    
    UIImageView * backImg = [[UIImageView alloc] initWithFrame:CGRectMake(10, 12+20, 12, 20)];
    [backImg setImage:[UIImage imageNamed:@"back_icon.png"]];
    [backImg setContentMode:UIViewContentModeScaleAspectFit];
    backImg.backgroundColor = [UIColor clearColor];
    [viewHeader addSubview:backImg];
    
    UIButton * btnBack = [UIButton buttonWithType:UIButtonTypeCustom];
    [btnBack addTarget:self action:@selector(btnBackClick) forControlEvents:UIControlEventTouchUpInside];
    btnBack.frame = CGRectMake(0, 0, 70, 64);
    btnBack.backgroundColor = [UIColor clearColor];
    [viewHeader addSubview:btnBack];
    
    stepperView = [[PSProfileStepper alloc] init];
    stepperView.frame = CGRectMake(20, 74, DEVICE_WIDTH-40, 24);
    stepperView.circleCount = 3;
    stepperView.lineHeight=2;
    stepperView.lineCircleRadius = 12;
    stepperView.sliderCircleRadius = 0;
    stepperView.labelFontSize = 15;
    stepperView.maxCount = 3;
    stepperView.lineColor = [UIColor grayColor];
    stepperView.sliderCircleColor = [UIColor clearColor];
    stepperView.innerCircleColor = [UIColor blackColor];
    stepperView.innerCircleNormalColor = [UIColor grayColor];
    stepperView.tintColor = [UIColor whiteColor];
    [self.view addSubview:stepperView];
    [stepperView setIndex:0 animated:YES];
    
    if (IS_IPHONE_4 || IS_IPHONE_5)
    {
        stepperView.frame = CGRectMake(20, 64, DEVICE_WIDTH-40, 18);
        if (IS_IPHONE_5)
        {
            stepperView.frame = CGRectMake(20, 68, DEVICE_WIDTH-40, 18);
        }
        stepperView.lineCircleRadius = 9;
        stepperView.labelFontSize = 10;
        viewHeader.frame = CGRectMake(0, 0, DEVICE_WIDTH, 64);
    }
    else if (IS_IPHONE_X)
    {
        viewHeader.frame = CGRectMake(0, 0, DEVICE_WIDTH, 88);
        lblTitle.frame = CGRectMake(50, 40, DEVICE_WIDTH-100, 44);
        backImg.frame = CGRectMake(10, 12+44, 12, 20);
        btnBack.frame = CGRectMake(0, 0, 70, 88);
        stepperView.frame = CGRectMake(20, 109, DEVICE_WIDTH-40, 24);
    }
}
-(void)setContentViews
{
    [scrlContent removeFromSuperview];
    scrlContent = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 143, 768, 1024-143)];
    [scrlContent setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"bg2"]]];
    scrlContent.showsHorizontalScrollIndicator = NO;
    scrlContent.showsVerticalScrollIndicator = NO;
    scrlContent.pagingEnabled = YES;
    scrlContent.bounces = NO;
    scrlContent.delegate = self;
    scrlContent.scrollEnabled = NO;
    scrlContent.backgroundColor = [UIColor clearColor];
    [self.view addSubview:scrlContent];
    
    [scrlContent setContentSize:CGSizeMake(768*3, 1024)];
    [scrlContent setContentOffset:CGPointMake(0, 0) animated:YES];
    if (IS_IPHONE)
    {
        scrlContent.frame=CGRectMake(0, 109-30, DEVICE_WIDTH, DEVICE_HEIGHT-109-30);
        [scrlContent setContentSize:CGSizeMake(DEVICE_WIDTH*3, DEVICE_HEIGHT)];
    }
    if (IS_IPHONE_5)
    {
        scrlContent.frame=CGRectMake(0, 68, DEVICE_WIDTH, DEVICE_HEIGHT-68-45);
    }
    if (IS_IPHONE_4)
    {
        scrlContent.frame=CGRectMake(0, 64, DEVICE_WIDTH, DEVICE_HEIGHT-64-45);
        [scrlContent setContentSize:CGSizeMake(DEVICE_WIDTH*3, DEVICE_HEIGHT)];
    }
     if (IS_IPHONE_X)
     {
         scrlContent.frame=CGRectMake(0, 140, DEVICE_WIDTH, DEVICE_HEIGHT-140);
         [scrlContent setContentSize:CGSizeMake(DEVICE_WIDTH*3, DEVICE_HEIGHT)];
     }
    [self performSelector:@selector(doAnimate) withObject:nil afterDelay:0];
    
    int fontSize = 17;
    if (IS_IPHONE_5 || IS_IPHONE_4)
    {
        fontSize = 15;
    }
    
    UIImageView * btmView = [[UIImageView alloc] init];
    btmView.frame= CGRectMake(0, DEVICE_HEIGHT-45*approaxSize, DEVICE_WIDTH, 45*approaxSize);
    btmView.userInteractionEnabled = YES;
    btmView.backgroundColor = [UIColor blackColor];
    [self.view addSubview:btmView];
    
    moveBackBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [moveBackBtn setTitle:@"  BACK " forState:UIControlStateNormal];
    [moveBackBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [moveBackBtn addTarget:self action:@selector(moveBackClick) forControlEvents:UIControlEventTouchUpInside];
    moveBackBtn.frame = CGRectMake(0, DEVICE_HEIGHT-45*approaxSize , DEVICE_WIDTH/2, btmView.frame.size.height);
    moveBackBtn.titleLabel.textAlignment = NSTextAlignmentLeft;
    moveBackBtn.titleLabel.font = [UIFont fontWithName:CGRegular size:fontSize];
    moveBackBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    [self.view addSubview:moveBackBtn];
//    moveBackBtn.hidden = YES;
    
    moveFrwdBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [moveFrwdBtn setTitle:@"NEXT   " forState:UIControlStateNormal];
    [moveFrwdBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [moveFrwdBtn addTarget:self action:@selector(moveNextClick) forControlEvents:UIControlEventTouchUpInside];
    moveFrwdBtn.frame = CGRectMake(DEVICE_WIDTH/2-10, DEVICE_HEIGHT-45*approaxSize, DEVICE_WIDTH/2, btmView.frame.size.height);
    moveFrwdBtn.titleLabel.font =[UIFont fontWithName:CGRegular size:fontSize];
    moveFrwdBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
    [self.view addSubview:moveFrwdBtn];
    
    if (IS_IPHONE_4)
    {
        btmView.frame= CGRectMake(0, DEVICE_HEIGHT-45, DEVICE_WIDTH, 45);
        moveBackBtn.frame = CGRectMake(0, DEVICE_HEIGHT-45, DEVICE_WIDTH/2, 45);
        moveFrwdBtn.frame = CGRectMake(DEVICE_WIDTH/2-10, DEVICE_HEIGHT-45, DEVICE_WIDTH/2, 45);
    }
    else if (IS_IPHONE_X)
    {
        btmView.frame= CGRectMake(0, DEVICE_HEIGHT-40-45*approaxSize, DEVICE_WIDTH, 45*approaxSize);
        moveBackBtn.frame = CGRectMake(0, DEVICE_HEIGHT-40-45*approaxSize , DEVICE_WIDTH/2, btmView.frame.size.height);
        moveFrwdBtn.frame = CGRectMake(DEVICE_WIDTH/2-10, DEVICE_HEIGHT-40-45*approaxSize , DEVICE_WIDTH/2, btmView.frame.size.height);
    }
}
#pragma mark - First View Setup
-(void)setFirstView
{
    [firstView removeFromSuperview];
    firstView = [[UIView alloc] init];
    firstView.frame = CGRectMake(0, 0, DEVICE_WIDTH, scrlContent.frame.size.height);
    firstView.backgroundColor = [UIColor clearColor];
    [scrlContent addSubview:firstView];

    int yy = 40;
    int fixedH = 50;
    if (IS_IPHONE_4)
    {
        yy = 20;
        fixedH = 40;
    }
    
    int zz = scrlContent.frame.origin.y+(45*approaxSize);
    if (IS_IPHONE_X)
    {
        zz = scrlContent.frame.origin.y+(45*approaxSize)+40;
    }
    tblFirstView = [[UITableView alloc]init];
    tblFirstView.backgroundColor = UIColor.clearColor;
    tblFirstView.frame = CGRectMake(0, yy, DEVICE_WIDTH, DEVICE_HEIGHT-yy-zz);
    tblFirstView.delegate = self;
    tblFirstView.dataSource = self;
    tblFirstView.scrollEnabled = false;
    tblFirstView.separatorStyle = UITableViewCellSelectionStyleNone;
    [firstView addSubview:tblFirstView];
    if (isFromeEdit)
    {
        installScanID = [detailDict valueForKey:@"imei"];
        globalDeviceType = [detailDict valueForKey:@"device_type"];
        installVesselName = [self checkforValidString:[detailDict valueForKey:@"vesselname"]];
        installRegi = [self checkforValidString:[detailDict valueForKey:@"portno"]];
        
        if (firstViewArray.count >= 3)
        {
            [[firstViewArray objectAtIndex:0] setValue:[self checkforValidStringForEdit:[detailDict valueForKey:@"imei"]] forKey:@"value"];
            [[firstViewArray objectAtIndex:1] setValue:[self checkforValidStringForEdit:[detailDict valueForKey:@"device_type"]] forKey:@"value"];
            [tblFirstView reloadData];
        }
    }
}

-(void)setShadowtoView:(UILabel *)lbl
{
    UIBezierPath *shadowPath = [UIBezierPath bezierPathWithRect:lbl.bounds];
    lbl.layer.masksToBounds = NO;
    lbl.layer.shadowColor = [UIColor blackColor].CGColor;
    lbl.layer.shadowOffset = CGSizeMake(0.0f, 1.0f);
    lbl.layer.shadowOpacity = 0.5f;
    lbl.layer.shadowPath = shadowPath.CGPath;
}

#pragma mark - Second view Set up
-(void)setSecondView
{
    [secondView removeFromSuperview];
    secondView = [[UIScrollView alloc] init];
    secondView.frame = CGRectMake(DEVICE_WIDTH, 0, DEVICE_WIDTH, scrlContent.frame.size.height);
    secondView.backgroundColor = [UIColor clearColor];
    secondView.showsHorizontalScrollIndicator = NO;
    secondView.showsVerticalScrollIndicator = NO;
    secondView.pagingEnabled = YES;
    secondView.bounces = NO;
    secondView.delegate = self;
    secondView.scrollEnabled = NO;
    [scrlContent addSubview:secondView];
    
    if (IS_IPHONE_4 || IS_IPHONE_5)
    {
        secondView.scrollEnabled = YES;
        secondView.bounces = YES;

        if (IS_IPHONE_5)
        {
            secondView.scrollEnabled = NO;
            secondView.bounces = YES;

            [secondView setContentSize:CGSizeMake(DEVICE_WIDTH, scrlContent.frame.size.height+100)];
        }
        else
        {
            [secondView setContentSize:CGSizeMake(DEVICE_WIDTH, scrlContent.frame.size.height+150)];
        }
    }

    int yy =50;
    int fixedH = 50;
    if (IS_IPHONE_4)
    {
        yy = 20;
        fixedH = 40;
    }
    
    int gapB = 60;
    textSize = 16;
    if (IS_IPHONE_4 || IS_IPHONE_5)
    {
        textSize = 14;
        gapB = 55;
        yy = 20;
    }
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:[NSString stringWithFormat:@"%@ HH:mm",[[NSUserDefaults standardUserDefaults] valueForKey:@"GloablDateFormat"]]];
    NSString *currentTime = [dateFormatter stringFromDate:[NSDate date]];
    strDateTime = currentTime;

    int zz = scrlContent.frame.origin.y+(45*approaxSize);
    if (IS_IPHONE_X)
    {
        zz = scrlContent.frame.origin.y+(45*approaxSize)+40;
    }
    tblSecondView = [[UITableView alloc]init];
    tblSecondView.backgroundColor = UIColor.clearColor;
    tblSecondView.frame = CGRectMake(0, yy, DEVICE_WIDTH, DEVICE_HEIGHT-yy-zz);
    tblSecondView.delegate = self;
    tblSecondView.dataSource = self;
    tblSecondView.scrollEnabled = false;
    tblSecondView.separatorStyle = UITableViewCellSelectionStyleNone;
    [secondView addSubview:tblSecondView];
    
    if (IS_IPHONE_4) {
        tblSecondView.frame = CGRectMake(0, yy, DEVICE_WIDTH, DEVICE_HEIGHT);

    }
    if (![appLatitude isEqual:[NSNull null]])
    {
        if (appLatitude != nil && appLatitude != NULL && ![appLatitude isEqualToString:@""])
        {
            [[secondViewArray objectAtIndex:1]setValue:appLatitude forKey:@"value"];
        }
        else
        {
            [[secondViewArray objectAtIndex:1]setValue:@"" forKey:@"value"];
        }
    }
    else
    {
        [[secondViewArray objectAtIndex:1]setValue:@"" forKey:@"value"];
    }

    if (![appLongitude isEqual:[NSNull null]])
    {
        if (appLongitude != nil && appLongitude != NULL && ![appLongitude isEqualToString:@""])
        {
            [[secondViewArray objectAtIndex:1]setValue:appLongitude forKey:@"longitudeValue"];
        }
        else
        {
            [[secondViewArray objectAtIndex:1]setValue:@"" forKey:@"longitudeValue"];
        }
    }
    else
    {
        [[secondViewArray objectAtIndex:1]setValue:@"" forKey:@"longitudeValue"];
    }
    
    if (isFromeEdit)
    {
        strPowerValues = [self checkforValidStringForEdit:[detailDict valueForKey:@"powervalue"]];

        if (secondViewArray.count >= 7)
        {
            [[secondViewArray objectAtIndex:0]setValue:[self checkforValidStringForEdit:[detailDict valueForKey:[[NSUserDefaults standardUserDefaults] valueForKey:@"globalDate"]]] forKey:@"title"];
            [[secondViewArray objectAtIndex:1]setValue:[self checkforValidStringForEdit:[detailDict valueForKey:@"latitude"]] forKey:@"value"];
            [[secondViewArray objectAtIndex:1]setValue:[self checkforValidStringForEdit:[detailDict valueForKey:@"longitudeValue"]] forKey:@"longitudeValue"];
            [[secondViewArray objectAtIndex:2]setValue:[self checkforValidStringForEdit:[detailDict valueForKey:@"vesselname"]] forKey:@"value"];
            [[secondViewArray objectAtIndex:3] setValue:[APP_DELEGATE checkforValidString:[detailDict valueForKey:@"portno"]] forKey:@"value"];
            [[secondViewArray objectAtIndex:4]setValue:[self checkforValidStringForEdit:[detailDict valueForKey:@"power"]] forKey:@"value"];
            [[secondViewArray objectAtIndex:5]setValue:[self checkforValidStringForEdit:[detailDict valueForKey:@"device_install_location"]] forKey:@"value"];


        }
        
        installVesselName = [self checkforValidString:[detailDict valueForKey:@"vesselname"]];
        installRegi = [self checkforValidString:[detailDict valueForKey:@"portno"]];
        installedVesselID = [self checkforValidString:[detailDict valueForKey:@"vessel_id"]];
//        strContCode = [self checkforValidString:[detailDict valueForKey:@"country_code"]];
        
        if ([[[secondViewArray objectAtIndex:0]valueForKey:@"title"] isEqualToString:@""])
        {
            [[secondViewArray objectAtIndex:0]setValue:[NSString stringWithFormat:@"%@",currentTime] forKey:@"title"];
        }
        if ([[self checkforValidString:[[secondViewArray objectAtIndex:1]valueForKey:@"value"]]isEqualToString:@"NA"])
        {
            [[secondViewArray objectAtIndex:1]setValue:[NSString stringWithFormat:@" %@",appLatitude] forKey:@"value"]  ;
        }
        if ([[self checkforValidString:[[secondViewArray objectAtIndex:1]valueForKey:@"longitudeValue"]]isEqualToString:@"NA"])
        {
            [[secondViewArray objectAtIndex:1]setValue:[NSString stringWithFormat:@" %@",appLongitude] forKey:@"longitudeValue"];
        }
        /*if ([lblCountry.text isEqualToString:@""])
        {
            lblCountry.text = phoneCountryName;
        }*/
        
        NSMutableArray * tmpArr = [[NSMutableArray alloc] init];
        NSString * str = [NSString stringWithFormat:@"select * from tbl_installer_photo where inst_local_id='%@' and inst_photo_user_id = '%@'",strInstallID,CURRENT_USER_ID];
        [[DataBaseManager dataBaseManager] execute:str resultsArray:tmpArr];
        installPhotoCounts = [NSString stringWithFormat:@"%lu",(unsigned long)[tmpArr count]];
        [[secondViewArray objectAtIndex:6] setValue:installPhotoCounts forKey:@"value"];
        [tblSecondView reloadData];
    }
}

#pragma mark - Third view Set up
-(void)setThirdView
{
    [thirdView removeFromSuperview];
    thirdView = [[UIScrollView alloc] init];
    thirdView.frame = CGRectMake(DEVICE_WIDTH*2, 0, DEVICE_WIDTH, scrlContent.frame.size.height+40);
    thirdView.backgroundColor = [UIColor clearColor];
    thirdView.showsHorizontalScrollIndicator = NO;
    thirdView.showsVerticalScrollIndicator = NO;
    thirdView.pagingEnabled = YES;
    thirdView.bounces = NO;
    thirdView.delegate = self;
    thirdView.scrollEnabled = NO;
    [scrlContent addSubview:thirdView];
    
    if (IS_IPHONE_4 || IS_IPHONE_5)
    {
        thirdView.bounces = YES;
        
        if (IS_IPHONE_5)
        {
            
            [thirdView setContentSize:CGSizeMake(DEVICE_WIDTH, scrlContent.frame.size.height+100)];
        }
        else
        {
            thirdView.scrollEnabled = YES;
            [thirdView setContentSize:CGSizeMake(DEVICE_WIDTH, scrlContent.frame.size.height+150)];
        }
    }
    
    
    int yy = 40;
    if (IS_IPHONE_4)
    {
        yy = 25;
    }
    
    textSize = 16;

    if (IS_IPHONE_4 || IS_IPHONE_5)
    {
        yy = 20;
        textSize = 15;
        
    }
    else if (IS_IPHONE_6)
    {
        yy = 40;
      
    }
    else if (IS_IPHONE_X)
    {
        
    }
   
    int zz = scrlContent.frame.origin.y+(45*approaxSize);
    if (IS_IPHONE_X)
    {
        zz = scrlContent.frame.origin.y+(45*approaxSize)+40;
    }
    tblthirdView = [[UITableView alloc]init];
    tblthirdView.backgroundColor = UIColor.clearColor;
    tblthirdView.frame = CGRectMake(0, yy, DEVICE_WIDTH, DEVICE_HEIGHT-yy-zz);
    tblthirdView.delegate = self;
    tblthirdView.dataSource = self;
    tblthirdView.scrollEnabled = false;
    tblthirdView.separatorStyle = UITableViewCellSelectionStyleNone;
    [thirdView addSubview:tblthirdView];
    
    if (isFromeEdit)
    {

        strInstallerSignUrl = [self checkforValidString:[detailDict valueForKey:@"local_installer_sign"]];
        strOwnerSignUrl = [self checkforValidString:[detailDict valueForKey:@"local_owner_sign"]] ;
        if (thirdViewArray.count >= 8)
        {
            [[thirdViewArray objectAtIndex:0]setValue:[self checkforValidStringForEdit:[detailDict valueForKey:@"owner_name"]] forKey:@"value"];
            [[thirdViewArray objectAtIndex:1]setValue:[self checkforValidStringForEdit:[detailDict valueForKey:@"owner_address"]] forKey:@"value"];
            [[thirdViewArray objectAtIndex:2]setValue:[self checkforValidStringForEdit:[detailDict valueForKey:@"owner_city"]] forKey:@"value"];
            [[thirdViewArray objectAtIndex:3]setValue:[self checkforValidStringForEdit:[detailDict valueForKey:@"owner_state"]] forKey:@"value"];
            [[thirdViewArray objectAtIndex:4]setValue:[self checkforValidStringForEdit:[detailDict valueForKey:@"owner_email"]] forKey:@"value"];
            [[thirdViewArray objectAtIndex:5]setValue:[self checkforValidStringForEdit:[detailDict valueForKey:@"owner_phone_no"]] forKey:@"value"];
            [[thirdViewArray objectAtIndex:3]setValue:[self checkforValidStringForEdit:[detailDict valueForKey:@"owner_zipcode"]] forKey:@"zipValue"];

            
            [tblthirdView reloadData];
        }
    }
}

- (NSString *)documentsPathForFileName:(NSString *)name
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask, YES);
    NSString *documentsPath = [paths objectAtIndex:0];
    return [documentsPath stringByAppendingPathComponent:name];
}
#pragma mark - UITableView Delegates
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView == tblFirstView)
    {
        return 55;
    }
    else if (tableView == tblSecondView)
    {
        if(IS_IPHONE_4 || IS_IPHONE_5)
        {
            return 50;
        }
        else
        {
            return 55;
        }
    }
    else if (tableView == tblthirdView)
    {
        if (IS_IPHONE_4 || IS_IPHONE_5)
        {
            return 45;
        }
        else
        {
            return 50;
        }
    }
    return true;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (tableView == tblFirstView)
    {
        return firstViewArray.count;
    }
    else if (tableView == tblSecondView)
    {
        return secondViewArray.count;
    }
    else if (tableView == tblthirdView)
    {
        return thirdViewArray.count;
    }
    return true;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellReuseIdentifier = @"cellIdentifier";
    NewInstallCell *cell = [tableView dequeueReusableCellWithIdentifier:cellReuseIdentifier];
    if (cell == nil)
    {
        cell = [[NewInstallCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellReuseIdentifier];
    }
    if (tableView == tblFirstView)
    {
        cell.lblName.text = [self checkforValidString:[[firstViewArray objectAtIndex:indexPath.row]valueForKey:@"title"]];
        
        if([[self checkforValidString:[[firstViewArray objectAtIndex:indexPath.row]valueForKey:@"value"]]isEqualToString:@"NA"])
        {
            cell.lblValue.text = @"";
        }
        else
        {
            cell.lblValue.text = [self checkforValidString:[[firstViewArray objectAtIndex:indexPath.row]valueForKey:@"value"]];
        }
    }
    else if (tableView == tblSecondView)
    {
        int txtheight = 54;
        {
            if (IS_IPHONE_4 || IS_IPHONE_5)
            {
                txtheight = 49;
            }
        }
        
        cell.txtName.delegate = self;
        cell.txtZip.delegate = self;
        if(IS_IPHONE_4 || IS_IPHONE_5)
        {
            cell.lblName.frame = CGRectMake(10,19, (DEVICE_WIDTH/2)-10, 30);
            cell.lblValue.frame = CGRectMake((DEVICE_WIDTH/2)-15,19, (DEVICE_WIDTH/2)-10, 30);
            cell.lblLine.frame = CGRectMake(5,txtheight-1, DEVICE_WIDTH-5, 1);
            cell.imgArrow.frame = CGRectMake(DEVICE_WIDTH-15, 27.5, 9, 15);
        }
        else
        {
            cell.lblName.frame = CGRectMake(10,20, (DEVICE_WIDTH/2)-10, 30);
            cell.lblValue.frame = CGRectMake((DEVICE_WIDTH/2)-15,20, (DEVICE_WIDTH/2)-10, 30);
            cell.lblLine.frame = CGRectMake(5,txtheight-1, DEVICE_WIDTH-5, 1);
            cell.imgArrow.frame = CGRectMake(DEVICE_WIDTH-15, 27.5, 9, 15);
        }
        if (indexPath.row == 0)
        {
            cell.lblValue.hidden = true;
            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
            [dateFormatter setDateFormat:[NSString stringWithFormat:@"%@ HH:mm",[[NSUserDefaults standardUserDefaults] valueForKey:@"GloablDateFormat"]]];
            NSString *currentTime = [dateFormatter stringFromDate:[NSDate date]];
            strDateTime = currentTime;

            if ([[self checkforValidString:[[secondViewArray objectAtIndex:0] valueForKey:@"title"]] isEqualToString:@"NA"] || [[self checkforValidString:[[secondViewArray objectAtIndex:0] valueForKey:@"title"]] isEqualToString:@"Date"])
            {
                cell.lblName.text = [NSString stringWithFormat:@"%@",[self checkforValidString:currentTime]];
                [[secondViewArray objectAtIndex:indexPath.row]setValue:[self checkforValidString:currentTime] forKey:@"title"];
            }
            else
            {
                cell.lblName.text = [self checkforValidString:[[secondViewArray objectAtIndex:indexPath.row]valueForKey:@"title"]];
            }
            cell.imgArrow.frame = CGRectMake(DEVICE_WIDTH-26, 22, 20, 20);
            cell.imgArrow.image = [UIImage imageNamed:@"calendar.png"];
        }
        else if (indexPath.row == 1)
        {
            cell.txtName.tag = 1011;
            cell.txtZip.tag =1022;
            cell.txtName.returnKeyType = UIReturnKeyNext;
            cell.lblZipLine.hidden = false;
            cell.imgArrow.hidden = true;
            cell.lblName.hidden = true;
            cell.txtName.hidden = false;
            cell.lblValue.hidden = true;
            cell.txtName.frame = CGRectMake(5, 9, (DEVICE_WIDTH/2)-20, txtheight-9);
            cell.txtZip.hidden = false;
            cell.lblZipLine.frame = CGRectMake((DEVICE_WIDTH/2)+10,txtheight-1,(DEVICE_WIDTH/2)-20, 1);
            cell.txtZip.frame = CGRectMake((DEVICE_WIDTH/2)+10, 9, (DEVICE_WIDTH/2)-20, txtheight-9);
            cell.lblLine.frame = CGRectMake(5,txtheight-1,(DEVICE_WIDTH/2)-20, 1);
            cell.lblZipLine.frame = CGRectMake((DEVICE_WIDTH/2)+10,txtheight-1,(DEVICE_WIDTH/2)-20, 1);
            cell.txtName.placeholder = [self checkforValidString:[[secondViewArray objectAtIndex:indexPath.row]valueForKey:@"title"]];
            if ([[self checkforValidString:[[secondViewArray objectAtIndex:indexPath.row]valueForKey:@"value"]] isEqualToString:@"NA"])
            {
                cell.txtName.text = @"";
            }
            else
            {
                cell.txtName.text = [self checkforValidString:[[secondViewArray objectAtIndex:1] valueForKey:@"value"]];
            }
            if ([[self checkforValidString:[[secondViewArray objectAtIndex:indexPath.row]valueForKey:@"longitudeValue"]] isEqualToString:@"NA"])
            {
                cell.txtZip.text = @"";
            }
            else
            {
                cell.txtZip.text = [self checkforValidString:[[secondViewArray objectAtIndex:1] valueForKey:@"longitudeValue"]];
            }
        }
        else if(indexPath.row == 5)
        {
            cell.lblValue.hidden = true;
            cell.txtName.tag = 1033;
            cell.txtName.returnKeyType = UIReturnKeyDone;
            cell.lblZipLine.hidden = true;
            cell.imgArrow.hidden = true;
            cell.lblName.hidden = true;
            cell.txtName.hidden = false;
            cell.txtZip.hidden = true;
            cell.lblLine.frame = CGRectMake(5,txtheight-1, DEVICE_WIDTH-5, 1);
            cell.txtName.frame = CGRectMake(5, 9, (DEVICE_WIDTH), txtheight-9);
            cell.txtName.placeholder = [self checkforValidString:[[secondViewArray objectAtIndex:5]valueForKey:@"title"]];
            if ([[self checkforValidString:[[secondViewArray objectAtIndex:indexPath.row]valueForKey:@"value"]] isEqualToString:@"NA"])
            {
                cell.txtName.text = @"";
            }
            else
            {
                cell.txtName.text = [[secondViewArray objectAtIndex:5] valueForKey:@"value"];
            }
        }
        else
        {
            if(indexPath.row == 6)
            {
                cell.lblName.frame = CGRectMake(10,20, (DEVICE_WIDTH/2)+20, 30);
                cell.lblValue.frame = CGRectMake((DEVICE_WIDTH/2)+35,20, (DEVICE_WIDTH/2)-55, 30);
            }
            else
            {
                cell.lblName.frame = CGRectMake(10,20, (DEVICE_WIDTH/2)-10, 30);
                cell.lblValue.frame = CGRectMake((DEVICE_WIDTH/2)-15,20, (DEVICE_WIDTH/2)-10, 30);
            }
            cell.lblValue.hidden = false;
            cell.lblZipLine.hidden = true;
            cell.txtZip.hidden = true;
            cell.imgArrow.hidden = false;
            cell.txtName.hidden = true;
            cell.lblName.hidden = false;
            cell.imgArrow.frame = CGRectMake(DEVICE_WIDTH-15, 27.5, 9, 15);
            cell.imgArrow.image = [UIImage imageNamed:@"arrow.png"];
            cell.lblName.text = [self checkforValidString:[[secondViewArray objectAtIndex:indexPath.row]valueForKey:@"title"]];
            cell.lblLine.frame = CGRectMake(5,txtheight-1, DEVICE_WIDTH-5, 1);
            
            if ([[self checkforValidString:[[secondViewArray objectAtIndex:indexPath.row]valueForKey:@"value"]]isEqualToString:@"NA"])
            {
                cell.lblValue.text = @"";
            }
            else
            {
                cell.lblValue.text = [self checkforValidString:[[secondViewArray objectAtIndex:indexPath.row]valueForKey:@"value"]];
            }
            if (indexPath.row == 3)
            {
                if ([[self checkforValidString:[[secondViewArray objectAtIndex:2]valueForKey:@"value"]]isEqualToString:@"NA"])
                {
                    cell.lblValue.text = @"";
                }
                else
                {
                    cell.lblValue.text = [self checkforValidString:[[secondViewArray objectAtIndex:indexPath.row]valueForKey:@"value"]];
                }
            }
        }
        cell.lblName.textColor = UIColor.whiteColor;
    }
    else if (tableView == tblthirdView)
    {
        if(indexPath.row == 4)
        {
            cell.txtName.keyboardType = UIKeyboardTypeEmailAddress;
            cell.txtName.returnKeyType = UIReturnKeyNext;
        }
        else if (indexPath.row == 5)
        {
            cell.txtName.keyboardType = UIKeyboardTypeNumberPad;
            cell.txtName.returnKeyType = UIReturnKeyDone;
        }
        else
        {
            cell.txtName.keyboardType = UIKeyboardTypeDefault;
            cell.txtName.returnKeyType = UIReturnKeyNext;
        }
        int textHeight = 49;
        
        if (IS_IPHONE_4 || IS_IPHONE_5)
        {
            textHeight = 44;
        }
        cell.lblName.hidden = true;
        cell.lblValue.hidden = true;
        cell.imgArrow.hidden = true;
        cell.txtZip.hidden = true;
        cell.lblZipLine.hidden = true;
        cell.txtName.hidden = false;
        cell.lblLine.hidden = false;
        cell.txtName.tag = [[arrayTextFieldTagValues objectAtIndex:indexPath.row] integerValue];
        cell.txtName.delegate = self;
        cell.lblLine.frame = CGRectMake(10,textHeight, DEVICE_WIDTH-20, 1);
        cell.txtName.placeholder = [[thirdViewArray objectAtIndex:indexPath.row]valueForKey:@"title"];
        cell.txtZip.tag = 200 + indexPath.row + 1;
        
        if(indexPath.row == 3)
        {
            cell.txtZip.hidden = false;
            cell.txtZip.placeholder = @"ZipCode";
            cell.txtZip.delegate = self;
            cell.lblZipLine.hidden = false;
            cell.txtZip.hidden = false;
            cell.txtZip.text = [[thirdViewArray objectAtIndex:indexPath.row]valueForKey:@"zipValue"];
            cell.lblLine.frame = CGRectMake(10,textHeight,(DEVICE_WIDTH/2)-20, 1);
            cell.txtName.frame = CGRectMake(10, 8, (DEVICE_WIDTH/2)-20, textHeight-8);
            cell.txtZip.frame = CGRectMake((DEVICE_WIDTH/2)+10, 8, (DEVICE_WIDTH/2)-20, textHeight-8);
            cell.lblZipLine.frame = CGRectMake((DEVICE_WIDTH/2)+10,textHeight,(DEVICE_WIDTH/2)-20, 1);
            if ([[self checkforValidString:[[thirdViewArray objectAtIndex:indexPath.row]valueForKey:@"zipValue"]]isEqualToString:@"NA"] || [[self checkforValidString:[[thirdViewArray objectAtIndex:indexPath.row]valueForKey:@"zipValue"]]isEqualToString:@""])
            {
                cell.txtZip.text = @"";
            }
            else
            {
                cell.txtZip.text = [self checkforValidString:[[thirdViewArray objectAtIndex:indexPath.row]valueForKey:@"zipValue"]];
            }
        }
        else
        {
            cell.txtZip.frame = CGRectMake((DEVICE_WIDTH), 4, (DEVICE_WIDTH/2)-20, textHeight-4);
            cell.txtZip.hidden = true;
            cell.lblZipLine.hidden = true;
            cell.txtName.frame = CGRectMake(10, 4, DEVICE_WIDTH-20, textHeight-4);
            cell.lblLine.frame = CGRectMake(10,textHeight, DEVICE_WIDTH-20, 1);
        }
        if (indexPath.row == 6 ||indexPath.row == 7 )
        {
            cell.txtName.hidden = true;
            cell.lblName.hidden = false;
            cell.imgArrow.hidden = false;
            cell.lblName.frame = CGRectMake(10,0, (DEVICE_WIDTH/2)-10, textHeight);
            cell.imgArrow.frame = CGRectMake(DEVICE_WIDTH-20, (textHeight/2)-7.5, 9, 15);
            cell.lblName.text = [[thirdViewArray objectAtIndex:indexPath.row]valueForKey:@"title"];
            if (indexPath.row == 7)
            {
                cell.lblPositionMsg.hidden = false;
                cell.lblLastReport.hidden = false;
            }
            else
            {
                cell.lblPositionMsg.hidden = true;
                cell.lblLastReport.hidden = true;
            }
        }
        else
        {
            if ([[self checkforValidString:[[thirdViewArray objectAtIndex:indexPath.row]valueForKey:@"value"]]isEqualToString:@"NA"] || [[self checkforValidString:[[thirdViewArray objectAtIndex:indexPath.row]valueForKey:@"value"]]isEqualToString:@""])
            {
                cell.txtName.text = @"";
            }
            else
            {
                cell.txtName.text = [self checkforValidString:[[thirdViewArray objectAtIndex:indexPath.row]valueForKey:@"value"]];
            }
            cell.lblPositionMsg.hidden = true;
            cell.lblLastReport.hidden = true;
            cell.txtName.hidden = false;
            cell.lblName.hidden = true;
            cell.imgArrow.hidden = true;
        }
    }
    cell.backgroundColor = UIColor.clearColor;
    [APP_DELEGATE getPlaceholderText:cell.txtName andColor:UIColor.whiteColor];
    [APP_DELEGATE getPlaceholderText:cell.txtZip andColor:UIColor.whiteColor];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView == tblFirstView)
    {
        if (indexPath.row == 0)
        {
            [self ShowPicker:NO andView:typeBackView];
            BarcodeScanVC * barcodeVC = [[BarcodeScanVC alloc] init];
            barcodeVC.isFromInstall = @"NewInstall";
            [self.navigationController pushViewController:barcodeVC animated:YES];
        }
        else if (indexPath.row == 1)
        {
            [self deviceTypeClick];
        }
        else if (indexPath.row == 2)
        {
            [self ShowPicker:NO andView:typeBackView];
            [self TestDeviceClick];
        }
    }
    else if (tableView == tblSecondView)
    {
        if (indexPath.row == 0)
        {
            [self selectDateClick];
        }
        else if (indexPath.row == 2)
        {
            [self vesselClick];
        }
        else if (indexPath.row == 3)
        {
            [self vesselClick];
        }
        else if (indexPath.row == 4)
        {
            [self powerSelectClick];
        }
        else if (indexPath.row == 6)
        {
            if (IS_IPHONE_4 || IS_IPHONE_5)
            {
                [UIView animateWithDuration:0.4 animations:^{
                    [secondView setFrame:CGRectMake(DEVICE_WIDTH, 0, DEVICE_WIDTH, scrlContent.frame.size.height+ 40)];
                }];
            }
            PhotoView * photosvc = [[PhotoView alloc] init];
            photosvc.installId = [self checkforValidString:strInstallID];
            [self.navigationController pushViewController:photosvc animated:YES];
        }
        
    }
    else if (tableView == tblthirdView)
    {
        if (indexPath.row == 6)
        {
            [self signatureClick];
        }
        else if (indexPath.row == 7)
        {
            [self btnTestDevClick];
        }
    }
}
#pragma mark - Scrollview Declaration
-(void)doAnimate
{
    [scrlContent setContentOffset:CGPointMake(0, 0) animated:YES];
}
- (void) scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (scrollView == scrlContent)
    {
        CGFloat pageWidth = scrollView.frame.size.width;
        page = floor((scrollView.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
        [self.view endEditing:YES];
    }
}
-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    if (scrollView == scrlContent)
    {
        CGFloat pageWidth = scrollView.frame.size.width;
        page = floor((scrollView.contentOffset.x - pageWidth / 2) / pageWidth) + 1;        
    }
}

#pragma mark - Button Click Events
-(void)btnBackClick
{
    if (page==0)
    {
        installPhotoCounts = 0;
        installScanID = @"";
        installVesselName = @"";
        installRegi = @"";
        [self.navigationController popViewControllerAnimated:YES];
    }
    else
    {
        [self moveBackClick];
    }
}
- (void)moveBackClick
{
    moveFrwdBtn.enabled = true;
    moveBackBtn.enabled = true;
    if (indexOne == 0)
    {
        [self.navigationController popViewControllerAnimated:true];
    }
    else if (indexOne >= 1 )
    {
        if (indexOne ==1)
        {
            if (IS_IPHONE_4 || IS_IPHONE_5)
            {
                [UIView animateWithDuration:0.4 animations:^{
                    [secondView setFrame:CGRectMake(DEVICE_WIDTH, 0, DEVICE_WIDTH, scrlContent.frame.size.height+ 40)];
                }];
            }
            [self InsertDataforSecondView];
        }
        else if (indexOne == 2)
        {
            [self saveDataonThirdBack];
        }
        indexOne = indexOne - 1;
        [scrlContent setContentOffset:CGPointMake(DEVICE_WIDTH*indexOne, 0) animated:YES];
    }
    [moveFrwdBtn setTitle:@"NEXT" forState:UIControlStateNormal];
    [stepperView setIndex:indexOne animated:YES];
}
- (void)moveNextClick
{
    if (indexOne == 0)
    {
        if ([self validationforFirstView])
        {
            if (indexOne < stepperView.maxCount - 1)
            {
                isFromNextTest = YES;
                if (isTestedAlready)
                {
                    if (isAllowtoGoAfterTest)
                    {
                        [self AllowtoMoveforSecondScreen];
                    }
                }
                else
                {
                    if ([APP_DELEGATE isNetworkreachable])
                    {
                        if (isAllowtoGoAfterTest)
                        {
                            [self AllowtoMoveforSecondScreen];
                        }
                        else
                        {
                            if ([APP_DELEGATE isNetworkreachable])
                            {
                                [self TestDeviceRomanAPI];
                            }
                            else
                            {
                                [self AllowtoMoveforSecondScreen];
                            }
                        }
                    }
                    else
                    {
                        [self AllowtoMoveforSecondScreen];
                    }
                }
            }
        }
    }
    else if(indexOne == 1)
    {
        if ([self validationforSecondVieww])
        {
            if (indexOne < stepperView.maxCount - 1)
            {
                if (isThirdBuilt)
                {
                }
                else
                {
                    [self setThirdView];
                    isThirdBuilt = YES;
                }
                [self InsertDataforSecondView];
                indexOne = indexOne + 1;
                [scrlContent setContentOffset:CGPointMake(DEVICE_WIDTH*indexOne, 0) animated:YES];
                [stepperView setIndex:indexOne animated:YES];
                
                if ([APP_DELEGATE isNetworkreachable])
                {
                }
                else
                {
                    moveFrwdBtn.enabled = true;
                }
            }
        }
    }
    else if(indexOne == 2)
    {
        if ([self validationforThirdVieww])
        {
            if (isTestDeviceDone)
            {
                [self InsertDataforThirdView];
                
                if ([APP_DELEGATE isNetworkreachable])
                {
                    [self kpSavInstall];
                }
                else
                {
                    alertView = [[URBAlertView alloc] initWithTitle:ALERT_TITLE message:@"Report has been saved successfully but not submitted to server because of No intenet connection. Please sync it later when internet available." cancelButtonTitle:OK_BTN otherButtonTitles: nil, nil];
                    
                    [alertView setMessageFont:[UIFont fontWithName:CGRegular size:14]];
                    [alertView setHandlerBlock:^(NSInteger buttonIndex, URBAlertView *alertView) {
                        [alertView hideWithCompletionBlock:^{
//                            [self.navigationController popViewControllerAnimated:YES];
                            [self.navigationController popToViewController:[self.navigationController.viewControllers objectAtIndex:0] animated:YES];
                            
                        }];
                    }];
                    [alertView showWithAnimation:URBAlertAnimationTopToBottom];
                    if (IS_IPHONE_X){[alertView showWithAnimation:URBAlertAnimationDefault];}
                }
            }
            else
            {
                alertView = [[URBAlertView alloc] initWithTitle:ALERT_TITLE message:@"Please tap on Test Device first to check the status of Device." cancelButtonTitle:OK_BTN otherButtonTitles: nil, nil];
                [alertView setMessageFont:[UIFont fontWithName:CGRegular size:14]];
                [alertView setHandlerBlock:^(NSInteger buttonIndex, URBAlertView *alertView) {
                    [alertView hideWithCompletionBlock:^{
                    }];
                }];
                [alertView showWithAnimation:URBAlertAnimationTopToBottom];
                if (IS_IPHONE_X){[alertView showWithAnimation:URBAlertAnimationDefault];}
            }
        }
    }
    if (indexOne==2)
    {
        [moveFrwdBtn setTitle:@"SUBMIT" forState:UIControlStateNormal];
    }
    else
    {
        [moveFrwdBtn setTitle:@"NEXT" forState:UIControlStateNormal];
    }
}
-(void)AllowtoMoveforSecondScreen
{
    [self InsertDataforFirstView];
    if (isSecondBuilt)
    {
    }
    else
    {
        [self setSecondView];
        isSecondBuilt = YES;
    }
//    moveBackBtn.hidden = NO;
    indexOne = indexOne + 1;
    [scrlContent setContentOffset:CGPointMake(DEVICE_WIDTH*indexOne, 0) animated:YES];
    [stepperView setIndex:indexOne animated:YES];
    
    if ([APP_DELEGATE isNetworkreachable])
    {
        [self getVesselsfromSuccorfishServer];
    }
}
-(void)deviceTypeClick
{
    [typeBackView removeFromSuperview];
    
    typeBackView = [[UIView alloc] initWithFrame:CGRectMake(0, DEVICE_HEIGHT, DEVICE_WIDTH, 250)];
    [typeBackView setBackgroundColor:[UIColor whiteColor]];
    [self.view addSubview:typeBackView];
    
    [deviceTypePicker removeFromSuperview];
    deviceTypePicker = nil;
    deviceTypePicker.delegate=nil;
    deviceTypePicker.dataSource=nil;
    deviceTypePicker = [[UIPickerView alloc] initWithFrame:CGRectMake(0, 34, DEVICE_WIDTH, 216)];
    [deviceTypePicker setBackgroundColor:[UIColor blackColor]];
    deviceTypePicker.tag=123;
    [deviceTypePicker setDelegate:self];
    [deviceTypePicker setDataSource:self];
    [typeBackView addSubview:deviceTypePicker];
    
    UIButton * btnDone2 = [UIButton buttonWithType:UIButtonTypeCustom];
    [btnDone2 setFrame:CGRectMake(0 , 0, DEVICE_WIDTH, 44)];
    [btnDone2 setBackgroundImage:[UIImage imageNamed:@"BTN.png"] forState:UIControlStateNormal];
    [btnDone2 setTitle:@"Done" forState:UIControlStateNormal];
    [btnDone2 setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    btnDone2.titleLabel.font = [UIFont fontWithName:CGRegular size:textSize];
    [btnDone2 setTag:123];
    [btnDone2 addTarget:self action:@selector(btnDoneClicked:) forControlEvents:UIControlEventTouchUpInside];
    [typeBackView addSubview:btnDone2];
    
    [self ShowPicker:YES andView:typeBackView];
}
-(void)btnShowMapForLastLocation
{
    MapClassVC * mapV = [[MapClassVC alloc] init];
    mapV.detailsDict = lastLocationDict;
    [self.navigationController pushViewController:mapV animated:YES];
}
-(void)TestDeviceClick
{
//    [[firstViewArray objectAtIndex:0]valueForKey:@"value"];
    if ([[[firstViewArray objectAtIndex:0]valueForKey:@"value"] length] == 0 || [[firstViewArray objectAtIndex:0]valueForKey:@"value"] == nil || [[self checkforValidString:[[firstViewArray objectAtIndex:0]valueForKey:@"value"]] isEqualToString:@"NA"] || [[[firstViewArray objectAtIndex:0]valueForKey:@"value"] isEqualToString:@" "])
    {
        alertView = [[URBAlertView alloc] initWithTitle:ALERT_TITLE message:@"Please get device id first by using Scan device option." cancelButtonTitle:OK_BTN otherButtonTitles: nil, nil];
        [alertView setMessageFont:[UIFont fontWithName:CGRegular size:14]];
        [alertView setHandlerBlock:^(NSInteger buttonIndex, URBAlertView *alertView) {
            [alertView hideWithCompletionBlock:^{
            }];
        }];
        [alertView showWithAnimation:URBAlertAnimationTopToBottom];
    if (IS_IPHONE_X){[alertView showWithAnimation:URBAlertAnimationDefault];}
    }
    else
    {
        if ([APP_DELEGATE isNetworkreachable])
        {
            isFromNextTest = NO;

            if (isFromeEdit)
            {
                if ([[self checkforValidString:[detailDict valueForKey:@"server_id"]] isEqualToString:@"NA"])
                {
                    [self getDeviceIDfromIMEIRomanAPI];;
                }
                else
                {
                    [self AllowtoMoveforSecondScreen];
                }
            }
            else
            {
                [self getDeviceIDfromIMEIRomanAPI];
            }
        }
        else
        {
            TestDeviceVC * testVC = [[TestDeviceVC alloc] init];
            testVC.strReasonToCome = @"Offline";
            [self.navigationController pushViewController:testVC animated:YES];
        }
    }
}
-(void)selectDateClick
{
    [secondView setFrame:CGRectMake(DEVICE_WIDTH, 0, DEVICE_WIDTH, scrlContent.frame.size.height)];
    [typeBackView removeFromSuperview];
    
    typeBackView = [[UIView alloc] initWithFrame:CGRectMake(0, DEVICE_HEIGHT, DEVICE_WIDTH, 250)];
    [typeBackView setBackgroundColor:[UIColor whiteColor]];
    [self.view addSubview:typeBackView];
    
    [datePicker removeFromSuperview];
    datePicker = nil;
    datePicker = [[UIDatePicker alloc] initWithFrame:CGRectMake(0, 34, DEVICE_WIDTH, 216)];
    [datePicker setBackgroundColor:[UIColor clearColor]];
    datePicker.tag=124;
    datePicker.datePickerMode=UIDatePickerModeDateAndTime;
    datePicker.timeZone = [NSTimeZone localTimeZone];
    
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:[NSString stringWithFormat:@"%@ HH:mm",[[NSUserDefaults standardUserDefaults] valueForKey:@"GloablDateFormat"]]];
    [typeBackView addSubview:datePicker];
    
    UIButton * btnDone2 = [UIButton buttonWithType:UIButtonTypeCustom];
    [btnDone2 setFrame:CGRectMake(0 , 0, DEVICE_WIDTH, 44)];
    [btnDone2 setBackgroundImage:[UIImage imageNamed:@"BTN.png"] forState:UIControlStateNormal];
    [btnDone2 setTitle:@"Done" forState:UIControlStateNormal];
    [btnDone2 setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [btnDone2 setTag:124];
    btnDone2.titleLabel.font = [UIFont fontWithName:CGRegular size:textSize];
    [btnDone2 addTarget:self action:@selector(btnDoneClicked:) forControlEvents:UIControlEventTouchUpInside];
    [typeBackView addSubview:btnDone2];
    
    [self ShowPicker:YES andView:typeBackView];
}
-(void)selectCountry
{
    [secondView setFrame:CGRectMake(DEVICE_WIDTH, 0, DEVICE_WIDTH, scrlContent.frame.size.height)];
    
    [backPickerView removeFromSuperview];
    backPickerView = [[UIView alloc] initWithFrame:CGRectMake(0, DEVICE_HEIGHT, DEVICE_WIDTH, 250)];
    [backPickerView setBackgroundColor:[UIColor whiteColor]];
    [self.view addSubview:backPickerView];
    
    [cntryPickerView removeFromSuperview];
    cntryPickerView = nil;
    cntryPickerView.delegate=nil;
    cntryPickerView = [[CountryPicker alloc] initWithFrame:CGRectMake(0, 34, DEVICE_WIDTH, 216)];
    cntryPickerView.delegate=self;
    [cntryPickerView setBackgroundColor:[UIColor blackColor]];
    [backPickerView addSubview:cntryPickerView];
    [cntryPickerView setSelectedCountryCode:strContCode animated:YES];
    
    UIButton * btnDone2 = [UIButton buttonWithType:UIButtonTypeCustom];
    [btnDone2 setFrame:CGRectMake(0 , 0, DEVICE_WIDTH, 44)];
    [btnDone2 setBackgroundImage:[UIImage imageNamed:@"BTN.png"] forState:UIControlStateNormal];
    [btnDone2 setTitle:@"Done" forState:UIControlStateNormal];
    [btnDone2 setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [btnDone2 setTag:125];
    btnDone2.titleLabel.font = [UIFont fontWithName:CGRegular size:textSize];
    [btnDone2 addTarget:self action:@selector(btnDoneClicked:) forControlEvents:UIControlEventTouchUpInside];
    [backPickerView addSubview:btnDone2];
    
    [self ShowPicker:YES andView:backPickerView];
}
-(void)vesselClick
{
    VesselVC * vessel = [[VesselVC alloc] init];
    [self.navigationController pushViewController:vessel animated:YES];
}
-(void)powerSelectClick
{
    [secondView setFrame:CGRectMake(DEVICE_WIDTH, 0, DEVICE_WIDTH, scrlContent.frame.size.height)];

    [typeBackView removeFromSuperview];
    typeBackView = [[UIView alloc] initWithFrame:CGRectMake(0, DEVICE_HEIGHT, DEVICE_WIDTH, 250)];
    [typeBackView setBackgroundColor:[UIColor whiteColor]];
    [self.view addSubview:typeBackView];
    
    [deviceTypePicker removeFromSuperview];
    deviceTypePicker = nil;
    deviceTypePicker.delegate=nil;
    deviceTypePicker.dataSource=nil;
    deviceTypePicker = [[UIPickerView alloc] initWithFrame:CGRectMake(0, 34, DEVICE_WIDTH, 216)];
    [deviceTypePicker setBackgroundColor:[UIColor blackColor]];
    deviceTypePicker.tag=126;
    [deviceTypePicker setDelegate:self];
    [deviceTypePicker setDataSource:self];
    [typeBackView addSubview:deviceTypePicker];
    
    UIButton * btnDone2 = [UIButton buttonWithType:UIButtonTypeCustom];
    [btnDone2 setFrame:CGRectMake(0 , 0, DEVICE_WIDTH, 44)];
    [btnDone2 setBackgroundImage:[UIImage imageNamed:@"BTN.png"] forState:UIControlStateNormal];
    [btnDone2 setTitle:@"Done" forState:UIControlStateNormal];
    [btnDone2 setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    btnDone2.titleLabel.font = [UIFont fontWithName:CGRegular size:textSize];
    [btnDone2 setTag:126];
    [btnDone2 addTarget:self action:@selector(btnDoneClicked:) forControlEvents:UIControlEventTouchUpInside];
    [typeBackView addSubview:btnDone2];
    
    [self ShowPicker:YES andView:typeBackView];
}
-(void)signatureClick
{
//    strInstallerSignUrl = [tmpDict valueForKey:@"local_installer_sign"];
//    strOwnerSignUrl =  [tmpDict valueForKey:@"local_owner_sign"];

    SignVC * signV = [[SignVC alloc] init];
    signV.isFromEdit = isFromeEdit;
    signV.detailDict = detailDict;
    signV.strInstallId = strInstallID;
    signV.strFromView = @"Install";
    if ([[self checkforValidString:strInstallerSignUrl] isEqualToString: @"NA"]  || [[self checkforValidString:strOwnerSignUrl] isEqualToString: @"NA"])
    {
        signV.isFromEdit = isFromeEdit;
    }
    else
    {
        signV.isFromEdit = YES;
    }
    [self.navigationController pushViewController:signV animated:YES];
}

-(void)agreeClick
{
    if (isAgreed)
    {
        imgCheck.image = [UIImage imageNamed:@"checkEmpty.png"];
        isAgreed = NO;
    }
    else
    {
        imgCheck.image = [UIImage imageNamed:@"checked.png"];
        isAgreed = YES;
    }
}
-(void)btnTestDevClick
{
    if(indexOne == 2)
    {
        isTestDeviceDone = YES;
        moveFrwdBtn.enabled = true;
    }
    if ([APP_DELEGATE isNetworkreachable])
    {
        [self TestDeviceRomanAPI];
    }
    else
    {
        alertView = [[URBAlertView alloc] initWithTitle:ALERT_TITLE message:@"There is no internet connection. Please connect to internet first then try again later." cancelButtonTitle:OK_BTN otherButtonTitles: nil, nil];
        [alertView setMessageFont:[UIFont fontWithName:CGRegular size:12]];
        [alertView setHandlerBlock:^(NSInteger buttonIndex, URBAlertView *alertView) {
            [alertView hideWithCompletionBlock:^{
                
            }];
        }];
        [alertView showWithAnimation:Alert_Animation_Type];
        
    }
}
#pragma mark - DatabaseMethods
-(void)InsertDataforFirstView
{
    if (isFromeEdit)
    {
        NSString * strUserID = [self checkforValidString:CURRENT_USER_ID];
        NSString * strEmi = [self checkforValidString:[[firstViewArray objectAtIndex:0]valueForKey:@"value"]];
        NSString * strDeviceType = [self checkforValidString:[[firstViewArray objectAtIndex:1]valueForKey:@"value"]];
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"YYYY-MM-dd HH:mm"];
        NSString *currentTime = [dateFormatter stringFromDate:[NSDate date]];
        
        [detailDict setObject:strEmi forKey:@"imei"];
        [detailDict setObject:strDeviceType forKey:@"device_type"];

        NSString * requestStr =[NSString stringWithFormat:@"update 'tbl_install' set 'user_id' = \"%@\",'imei' = \"%@\",'device_type' = \"%@\",'created_at' = \"%@\" where id ='%@'",strUserID,strEmi,strDeviceType,currentTime,strInstallID];
        [[DataBaseManager dataBaseManager] execute:requestStr];
    }
    else
    {
        NSString * strUserID = [self checkforValidString:CURRENT_USER_ID];
        NSString * strEmi = [self checkforValidString:[[firstViewArray objectAtIndex:0]valueForKey:@"value"]];
        NSString * strDeviceType = [self checkforValidString:[[firstViewArray objectAtIndex:1]valueForKey:@"value"]];
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"YYYY-MM-dd HH:mm"];
        NSString *currentTime = [dateFormatter stringFromDate:[NSDate date]];
        int timestamp = [[NSDate date] timeIntervalSince1970];
        NSString * strcurTimeStamp = [NSString stringWithFormat:@"%d",timestamp];

        [detailDict setObject:strEmi forKey:@"imei"];
        [detailDict setObject:strDeviceType forKey:@"device_type"];

        if (isSecondBuilt)
        {
            NSString * requestStr =[NSString stringWithFormat:@"update 'tbl_install' set 'user_id' = \"%@\",'imei' = \"%@\",'device_type' = \"%@\",succor_device_id = \"%@\",'created_at' = \"%@\" where id ='%@'",strUserID,strEmi,strDeviceType,strSuccorfishDeviceID,currentTime,strInstallID];
            [[DataBaseManager dataBaseManager] execute:requestStr];
        }
        else
        {
            NSString * requestStr = [NSString stringWithFormat:@"update 'tbl_install' set 'user_id' = \"%@\",'imei' = \"%@\",'device_type' = \"%@\",'created_at' = \"%@\",'createdTimeStamp' = \"%@\",'complete_status' = 'INCOMPLETE','succor_device_id' = \"%@\" where id = '%@'",strUserID,strEmi,strDeviceType,currentTime,strcurTimeStamp,strSuccorfishDeviceID,strInstallID];
            
            if (isFromeEdit)
            {
                requestStr =[NSString stringWithFormat:@"insert into 'tbl_install'('user_id','imei','device_type','created_at','createdTimeStamp','complete_status','succor_device_id') values(\"%@\",\"%@\",\"%@\",\"%@\",\"%@\",'COMPLETE',\"%@\")",strUserID,strEmi,strDeviceType,currentTime,strcurTimeStamp,strSuccorfishDeviceID];
                intInstallID = [[DataBaseManager dataBaseManager] executeSw:requestStr];
            }
            [[DataBaseManager dataBaseManager] execute:requestStr];

            if (intInstallID != 0)
            {
                strInstallID = [NSString stringWithFormat:@"%d",intInstallID];
                
                NSString * strDate1 = [self getConvertedDate:currentTime withFormat:@"YYYY-MM-dd"];
                NSString * strDate2 = [self getConvertedDate:currentTime withFormat:@"dd-MM-yyyy"];
                NSString * strDate3 = [self getConvertedDate:currentTime withFormat:@"dd/MM/yyyy"];
                NSString * strDate4 = [self getConvertedDate:currentTime withFormat:@"dd MMMM yyyy"];
                NSString * strDate5 = [self getConvertedDate:currentTime withFormat:@"MM/dd/yyyy"];
                NSString * strDate6 = [self getConvertedDate:currentTime withFormat:@"yyyy/MM/dd"];

                NSString * strQuery =[NSString stringWithFormat:@"update 'tbl_install' set 'date1' = \"%@\",'date2' = \"%@\",'date3' = \"%@\",'date4' = \"%@\",'date5' = \"%@\",'date6' = \"%@\" where id ='%@'",strDate1,strDate2,strDate3,strDate4,strDate5,strDate6,strInstallID];
                [[DataBaseManager dataBaseManager] execute:strQuery];
            }
            [APP_DELEGATE updateBadgeCount];
        }
    }
}
-(void)InsertDataforSecondView
{
    NSString * strDate = [self checkforValidString:strDateTime];
    NSString * strLate = [self checkforValidString:[[secondViewArray objectAtIndex:1]valueForKey:@"value"]];
    NSString * strLong = [self checkforValidString:[[secondViewArray objectAtIndex:1]valueForKey:@"longitudeValue"]];
    NSString * strCode = [self checkforValidString:strContCode];
    NSString * strCountry = @"NA";
    NSString * strVessel = [self checkforValidString:installVesselName];
    NSString * strVesselID = [self checkforValidString:installedVesselID];
    NSString * strRegi = [self checkforValidString:installRegi];
    NSString * strPower = [self checkforValidString:[[secondViewArray objectAtIndex:4]valueForKey:@"value"]];
    NSString * strLocation = [self checkforValidString:[[secondViewArray objectAtIndex:5]valueForKey:@"value"]];
    NSString * strWarantyStatus = [self checkforValidString:globalWarrantyStatus];
    NSString * strPowersValuess = [self checkforValidString:strPowerValues];

    
    
    [detailDict setObject:strDate forKey:@"date"];
    [detailDict setObject:strLate forKey:@"latitude"];
    [detailDict setObject:strLong forKey:@"longitude"];
    [detailDict setObject:@"NA" forKey:@"country_code"];
    [detailDict setObject:@"NA" forKey:@"installation_county"];
    [detailDict setObject:strVesselID forKey:@"vessel_id"];
    [detailDict setObject:strVessel forKey:@"vesselname"];
    [detailDict setObject:strRegi forKey:@"portno"];
    [detailDict setObject:strWarantyStatus forKey:@"warranty"];
    [detailDict setObject:strPower forKey:@"power"];
    [detailDict setObject:strLocation forKey:@"device_install_location"];
    [detailDict setObject:strPowersValuess forKey:@"powervalue"];

    NSString * requestStr =[NSString stringWithFormat:@"Update 'tbl_install'  set 'date' = \"%@\",'latitude'=\"%@\",'longitude'=\"%@\",'country_code'=\"%@\",'installation_county'=\"%@\",'vessel_id'=\"%@\",'vesselname'=\"%@\",'portno'=\"%@\",'warranty'=\"%@\",'power'=\"%@\",'device_install_location'=\"%@\",'powervalue'=\"%@\" where id ='%@'",strDate,strLate,strLong,strCode,strCountry,strVesselID,strVessel,strRegi,strWarantyStatus,strPower,strLocation,strPowersValuess,strInstallID];
    [[DataBaseManager dataBaseManager] execute:requestStr];
    
}
-(void)InsertDataforThirdView
{
    NSString * strOwner = [self checkforValidString:[[thirdViewArray objectAtIndex:0]valueForKey:@"value"]];
    NSString * strEmail = [self checkforValidString:[[thirdViewArray objectAtIndex:4]valueForKey:@"value"]];
    NSString * strAddress = [self checkforValidString:[[thirdViewArray objectAtIndex:1]valueForKey:@"value"]];
    NSString * strMobile = [self checkforValidString:[[thirdViewArray objectAtIndex:5]valueForKey:@"value"]];
    NSString * strCity = [self checkforValidString:[[thirdViewArray objectAtIndex:2]valueForKey:@"value"]];
    NSString * strState = [self checkforValidString:[[thirdViewArray objectAtIndex:3]valueForKey:@"value"]];
    NSString * strZipCode = [self checkforValidString:[[thirdViewArray objectAtIndex:3]valueForKey:@"zipValue"]];
    
    [detailDict setObject:strOwner forKey:@"owner_name"];
    [detailDict setObject:strEmail forKey:@"owner_email"];
    [detailDict setObject:strAddress forKey:@"owner_address"];
    [detailDict setObject:strMobile forKey:@"owner_phone_no"];
    [detailDict setObject:strCity forKey:@"owner_city"];
    [detailDict setObject:strState forKey:@"owner_state"];
    [detailDict setObject:strZipCode forKey:@"owner_zipcode"];

    NSString * requestStr =[NSString stringWithFormat:@"Update 'tbl_install'  set 'owner_name' =\"%@\", 'owner_email' = \"%@\",'owner_phone_no'=\"%@\",'owner_address'=\"%@\",'owner_city'=\"%@\",'owner_state'=\"%@\",'owner_zipcode'=\"%@\",'complete_status'='COMPLETE' where id ='%@'",strOwner,strEmail,strMobile,strAddress,strCity,strState,strZipCode,strInstallID];
    [[DataBaseManager dataBaseManager] execute:requestStr];
}
-(void)saveDataonThirdBack
{
    NSString * strOwner = [self checkforValidString:[[thirdViewArray objectAtIndex:0]valueForKey:@"value"]];
    NSString * strEmail = [self checkforValidString:[[thirdViewArray objectAtIndex:4]valueForKey:@"value"]];
    NSString * strAddress = [self checkforValidString:[[thirdViewArray objectAtIndex:1]valueForKey:@"value"]];
    NSString * strMobile = [self checkforValidString:[[thirdViewArray objectAtIndex:5]valueForKey:@"value"]];
    NSString * strCity = [self checkforValidString:[[thirdViewArray objectAtIndex:2]valueForKey:@"value"]];
    NSString * strState = [self checkforValidString:[[thirdViewArray objectAtIndex:3]valueForKey:@"value"]];
    NSString * strZipCode = [self checkforValidString:[[thirdViewArray objectAtIndex:3]valueForKey:@"zipValue"]];
    
    [detailDict setObject:strOwner forKey:@"owner_name"];
    [detailDict setObject:strEmail forKey:@"owner_email"];
    [detailDict setObject:strAddress forKey:@"owner_address"];
    [detailDict setObject:strMobile forKey:@"owner_phone_no"];
    [detailDict setObject:strCity forKey:@"owner_city"];
    [detailDict setObject:strState forKey:@"owner_state"];
    [detailDict setObject:strZipCode forKey:@"owner_zipcode"];
    
    NSString * requestStr =[NSString stringWithFormat:@"Update 'tbl_install'  set 'owner_name' =\"%@\", 'owner_email' = \"%@\",'owner_phone_no'=\"%@\",'owner_address'=\"%@\",'owner_city'=\"%@\",'owner_state'=\"%@\",'owner_zipcode'=\"%@\" where id ='%@'",strOwner,strEmail,strMobile,strAddress,strCity,strState,strZipCode,strInstallID];
    [[DataBaseManager dataBaseManager] execute:requestStr];
}
-(NSString *)saveSignatureImagetoDocumentDirectory
{
    NSTimeInterval timeStamp = [[NSDate date] timeIntervalSince1970];
    NSNumber *timeStampObj = [NSNumber numberWithInteger: timeStamp];
    
    int randomID = arc4random() % 9000 + 1000;
    NSString * imageName = [NSString stringWithFormat:@"/SignUninstall%@-%d-ID%@-.jpg", strInstallID,randomID,timeStampObj];
    imageName = [imageName stringByReplacingOccurrencesOfString:@" " withString:@""];
    
    NSString * stringPath = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)objectAtIndex:0]stringByAppendingPathComponent:@"InstallSigns"]; // New Folder is your folder name
    NSError *error = nil;
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:stringPath])        [[NSFileManager defaultManager] createDirectoryAtPath:stringPath withIntermediateDirectories:NO attributes:nil error:&error];
    NSString *fileName = [stringPath stringByAppendingString:imageName];
    NSData *data = UIImageJPEGRepresentation(signImgView.image, 0.2);
    [data writeToFile:fileName atomically:YES];
    
    return imageName;
}
#pragma mark - PickerView Delegate
-(NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    if (pickerView == deviceTypePicker)
    {
        return 1;
    }
    else
    {
        return 1;
    }
}

-(NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    if([pickerView tag]==123)
    {
        return [deviceTypeArr count];
    }
    else if([pickerView tag]==126)
    {
        return [powerArr count];
    }
    return 1;
}

- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view
{
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, pickerView.frame.size.width, 44)];
    label.backgroundColor = [UIColor clearColor];
    label.textAlignment = NSTextAlignmentCenter;
    label.textColor = [UIColor whiteColor];
    label.font = [UIFont fontWithName:CGBold size:14];
    
    if (component == 0)
    {
        if (pickerView.tag==123)
        {
            label.text = [deviceTypeArr objectAtIndex:row];
            return label;
        }
        else if([pickerView tag]==126)
        {
            label.text = [[powerArr objectAtIndex:row] valueForKey:@"name"];
            strPowerValues = [[powerArr objectAtIndex:row] valueForKey:@"values"];
            return label;
        }
    }
    return label;
}

-(void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    if (pickerView.tag == 123)
    {
        if (firstViewArray.count >= 3)
        {
            [[firstViewArray objectAtIndex:1]setValue:[deviceTypeArr objectAtIndex:row] forKey:@"value"];
            [tblFirstView reloadData];
        }
    }
    else if (pickerView.tag == 126)
    {
        [[secondViewArray objectAtIndex:4] setValue:[[powerArr objectAtIndex:row] valueForKey:@"name"] forKey:@"value"];
        strPowerValues = [[powerArr objectAtIndex:row] valueForKey:@"values"];
        [tblSecondView reloadData];
    }
}

-(void)btnDoneClicked:(id)sender
{
    if ([sender tag] == 123)
    {
        NSInteger index = [deviceTypePicker selectedRowInComponent:0];
        if ([deviceTypeArr count] >= index)
        {
            if (firstViewArray.count >= 3)
            {
                [[firstViewArray objectAtIndex:1]setValue:[deviceTypeArr objectAtIndex:index] forKey:@"value"];
                [tblFirstView reloadData];
            }
        }
        [self ShowPicker:NO andView:typeBackView];
    }
    else if ([sender tag] == 124)
    {
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:[NSString stringWithFormat:@"%@ HH:mm",[[NSUserDefaults standardUserDefaults] valueForKey:@"GloablDateFormat"]]];
        NSString *currentTime = [dateFormatter stringFromDate:datePicker.date];
        [[secondViewArray objectAtIndex:0]setValue:[NSString stringWithFormat:@"%@",[self checkforValidString:currentTime]] forKey:@"title"];
        strDateTime = currentTime;
        [self ShowPicker:NO andView:typeBackView];
        [tblSecondView reloadData];
    }
    else if ([sender tag] == 125)
    {
        [self ShowPicker:NO andView:backPickerView];
    }
    else if ([sender tag] == 126)
    {
        NSInteger index = [deviceTypePicker selectedRowInComponent:0];
        if ([powerArr count] >= index)
        {
            [[secondViewArray objectAtIndex:4] setValue:[[powerArr objectAtIndex:index] valueForKey:@"name"] forKey:@"value"];
            strPowerValues = [[powerArr objectAtIndex:index] valueForKey:@"values"];
            [tblSecondView reloadData];
        }
        [self ShowPicker:NO andView:typeBackView];
    }
}

#pragma mark - Animations
-(void)ShowPicker:(BOOL)isShow andView:(UIView *)myView
{
    int viewHeight = 250;
    if (IS_IPHONE_4)
    {
        viewHeight = 230;
    }
    if (isShow == YES)
    {
        [UIView transitionWithView:myView duration:0.4
                           options:UIViewAnimationOptionCurveEaseIn
                        animations:^{
                            [myView setFrame:CGRectMake(0, DEVICE_HEIGHT-viewHeight,DEVICE_WIDTH, viewHeight)];
                        }
                        completion:^(BOOL finished)
         {
         }];
    }
    else
    {
        [UIView transitionWithView:myView duration:0.4
                           options:UIViewAnimationOptionTransitionNone
                        animations:^{
                            [myView setFrame:CGRectMake(0, DEVICE_HEIGHT, DEVICE_WIDTH, viewHeight)];
                        }
                        completion:^(BOOL finished)
         {
         }];
    }
}


-(BOOL)validationforFirstView
{
    BOOL isAvail = NO;
    if ([[[firstViewArray objectAtIndex:0]valueForKey:@"value"] length] == 0 || [[firstViewArray objectAtIndex:0]valueForKey:@"value"] == nil || [[APP_DELEGATE checkforValidString:[[firstViewArray objectAtIndex:0]valueForKey:@"value"]] isEqualToString:@"NA"] || [[[firstViewArray objectAtIndex:0]valueForKey:@"value"] isEqualToString:@" "])
    {
        alertView = [[URBAlertView alloc] initWithTitle:ALERT_TITLE message:@"Please get device id first by using Scan device option." cancelButtonTitle:OK_BTN otherButtonTitles: nil, nil];

        [alertView setMessageFont:[UIFont fontWithName:CGRegular size:14]];
        [alertView setHandlerBlock:^(NSInteger buttonIndex, URBAlertView *alertView) {
            [alertView hideWithCompletionBlock:^{
            }];
        }];
        [alertView showWithAnimation:URBAlertAnimationTopToBottom];
    if (IS_IPHONE_X){[alertView showWithAnimation:URBAlertAnimationDefault];}
    }
    else if ([[[firstViewArray objectAtIndex:1]valueForKey:@"value"] length] == 0 || [[firstViewArray objectAtIndex:1]valueForKey:@"value"] == nil || [[APP_DELEGATE checkforValidString:[[firstViewArray objectAtIndex:1]valueForKey:@"value"]] isEqualToString:@"NA"] || [[[firstViewArray objectAtIndex:1]valueForKey:@"value"] isEqualToString:@" "])
    {
        alertView = [[URBAlertView alloc] initWithTitle:ALERT_TITLE message:@"Please select device type." cancelButtonTitle:OK_BTN otherButtonTitles: nil, nil];

        [alertView setMessageFont:[UIFont fontWithName:CGRegular size:14]];
        [alertView setHandlerBlock:^(NSInteger buttonIndex, URBAlertView *alertView) {
            [alertView hideWithCompletionBlock:^{
            }];
        }];
        [alertView showWithAnimation:URBAlertAnimationTopToBottom];
    if (IS_IPHONE_X){[alertView showWithAnimation:URBAlertAnimationDefault];}
    }
    else
    {
        isAvail = YES;
    }
    
    return isAvail;
}
-(BOOL)validationforSecondVieww
{
    BOOL isAvail = NO;
    
    if ([[[secondViewArray objectAtIndex:0]valueForKey:@"title"] length] == 0 || [[secondViewArray objectAtIndex:0]valueForKey:@"title"] == nil || [[APP_DELEGATE checkforValidString:[[secondViewArray objectAtIndex:0]valueForKey:@"title"]] isEqualToString:@"NA"] || [[[secondViewArray objectAtIndex:0]valueForKey:@"title"] isEqualToString:@" "] || [[[secondViewArray objectAtIndex:0]valueForKey:@"title"] isEqualToString:@"Date"])
    {
        [self showMessagewithText:@"Please set date and time."];
    }
    else if ([[[secondViewArray objectAtIndex:1]valueForKey:@"value"] length] == 0 || [[secondViewArray objectAtIndex:1]valueForKey:@"value"] == nil || [[APP_DELEGATE checkforValidString:[[secondViewArray objectAtIndex:1]valueForKey:@"value"]] isEqualToString:@"NA"] || [[[secondViewArray objectAtIndex:1]valueForKey:@"value"] isEqualToString:@" "])
    {
        [self showMessagewithText:@"Please enter latitude."];
    }
    else if ([[[secondViewArray objectAtIndex:1]valueForKey:@"longitudeValue"] length] == 0 || [[secondViewArray objectAtIndex:1]valueForKey:@"longitudeValue"] == nil || [[APP_DELEGATE checkforValidString:[[secondViewArray objectAtIndex:1]valueForKey:@"longitudeValue"]] isEqualToString:@"NA"] || [[[secondViewArray objectAtIndex:1]valueForKey:@"longitudeValue"] isEqualToString:@" "])
    {
        [self showMessagewithText:@"Please enter longitude."];
    }
   
    else if ([[[secondViewArray objectAtIndex:2]valueForKey:@"value"] length] == 0 || [[secondViewArray objectAtIndex:2]valueForKey:@"value"] == nil || [[APP_DELEGATE checkforValidString:[[secondViewArray objectAtIndex:2]valueForKey:@"value"]] isEqualToString:@"NA"] || [[[secondViewArray objectAtIndex:2]valueForKey:@"value"] isEqualToString:@" "])
    {
        [self showMessagewithText:@"Please enter Asset name."];
    }
    else if ([[[secondViewArray objectAtIndex:3]valueForKey:@"value"] length] == 0)
    {
        [self showMessagewithText:@"Please enter Registration no."];
    }
    else if ([[[secondViewArray objectAtIndex:4]valueForKey:@"value"] length] == 0 || [[secondViewArray objectAtIndex:4]valueForKey:@"value"] == nil || [[APP_DELEGATE checkforValidString:[[secondViewArray objectAtIndex:4]valueForKey:@"value"]] isEqualToString:@"NA"] || [[[secondViewArray objectAtIndex:4]valueForKey:@"value"] isEqualToString:@" "])
    {
        [self showMessagewithText:@"Please select Power."];
    }
     else if ([[[secondViewArray objectAtIndex:5]valueForKey:@"value"] length] == 0 || [[secondViewArray objectAtIndex:5]valueForKey:@"value"] == nil || [[APP_DELEGATE checkforValidString:[[secondViewArray objectAtIndex:5]valueForKey:@"value"]] isEqualToString:@"NA"] || [[[secondViewArray objectAtIndex:5]valueForKey:@"value"] isEqualToString:@" "])
    {
        [self showMessagewithText:@"Please enter device install location."];
    }
//    else if ([installPhotoCounts isEqual:[NSNull null]] || installPhotoCounts == nil || installPhotoCounts == NULL || [installPhotoCounts isEqualToString:@""] || [installPhotoCounts isEqualToString:@"0"] )
    else if ([self isAllFourPhotosAdded] == NO)
    {
        [self showMessagewithText:@"Please add 4 photos of Installation."];
    }
    else if ([self checkPhotofileExistorNot] == NO)
    {
        [self showMessagewithText:@"There is some photos missing for Installation. Please check and add missing photos."];
    }
    else
    {
        isAvail = YES;
    }
    return isAvail;
}
-(BOOL)isAllFourPhotosAdded
{
    BOOL isExisted = YES;

    NSMutableArray * imgsArr = [[NSMutableArray alloc] init];
    NSString * strQuery = [NSString stringWithFormat:@"select * from tbl_installer_photo where inst_local_id = '%@' and inst_photo_user_id = '%@'",strInstallID,CURRENT_USER_ID];
    [[DataBaseManager dataBaseManager] execute:strQuery resultsArray:imgsArr];
    
    if ([imgsArr count]>=4)
    {
        
    }
    else
    {
        isExisted = NO;
    }
    return isExisted;
}
-(BOOL)checkPhotofileExistorNot
{
    BOOL isExisted = YES;
    
    NSMutableArray * imgsArr = [[NSMutableArray alloc] init];
    NSString * strQuery = [NSString stringWithFormat:@"select * from tbl_installer_photo where inst_local_id = '%@' and inst_photo_user_id = '%@'",strInstallID,CURRENT_USER_ID];
    [[DataBaseManager dataBaseManager] execute:strQuery resultsArray:imgsArr];
    
    for (int k=0; k<[imgsArr count]; k++)
    {
        NSString * filePath = [self documentsPathForFileName:[NSString stringWithFormat:@"InstallPhotos/%@",[[imgsArr objectAtIndex:k] valueForKey:@"inst_photo_local_url"]]];
        BOOL fileExists = [[NSFileManager defaultManager] fileExistsAtPath:filePath];
        if (fileExists == NO)
        {
            isExisted = NO;
            break;
        }
    }
    return isExisted;
}
-(BOOL)validationforThirdVieww
{
    BOOL isAvail = NO;
    
    if ([[[thirdViewArray objectAtIndex:0]valueForKey:@"value"] length] == 0 || [[thirdViewArray objectAtIndex:0]valueForKey:@"value"] == nil || [[APP_DELEGATE checkforValidString:[[thirdViewArray objectAtIndex:0]valueForKey:@"value"]] isEqualToString:@"NA"] || [[[thirdViewArray objectAtIndex:0]valueForKey:@"value"] isEqualToString:@" "])
    {
        [self showMessagewithText:@"Please enter Owner name."];
    }
    else if ([[[thirdViewArray objectAtIndex:1]valueForKey:@"value"] length] == 0 || [[thirdViewArray objectAtIndex:1]valueForKey:@"value"] == nil || [[APP_DELEGATE checkforValidString:[[thirdViewArray objectAtIndex:1]valueForKey:@"value"]] isEqualToString:@"NA"] || [[[thirdViewArray objectAtIndex:1]valueForKey:@"value"] isEqualToString:@" "])
    {
        [self showMessagewithText:@"Please enter Owner address."];
    }
    else if ([[[thirdViewArray objectAtIndex:3]valueForKey:@"zipValue"] length] == 0 || [[thirdViewArray objectAtIndex:3]valueForKey:@"zipValue"] == nil || [[APP_DELEGATE checkforValidString:[[thirdViewArray objectAtIndex:3]valueForKey:@"zipValue"]] isEqualToString:@"NA"] || [[[thirdViewArray objectAtIndex:3]valueForKey:@"zipValue"] isEqualToString:@" "])
    {
        [self showMessagewithText:@"Please enter ZipCode."];
    }
    else if ([[[thirdViewArray objectAtIndex:4]valueForKey:@"value"] length] == 0 || [[thirdViewArray objectAtIndex:4]valueForKey:@"value"] == nil || [[APP_DELEGATE checkforValidString:[[thirdViewArray objectAtIndex:4]valueForKey:@"value"]] isEqualToString:@"NA"] || [[[thirdViewArray objectAtIndex:4]valueForKey:@"value"] isEqualToString:@" "])
    {
        [self showMessagewithText:@"Please enter Owner email address."];
    }
    else if(![self validateEmailHere:[[thirdViewArray objectAtIndex:4]valueForKey:@"value"]])
    {
        [self showMessagewithText:@"Please enter valid email address"];
    }
    else if ([[[thirdViewArray objectAtIndex:5]valueForKey:@"value"] length] == 0 || [[thirdViewArray objectAtIndex:5]valueForKey:@"value"] == nil || [[APP_DELEGATE checkforValidString:[[thirdViewArray objectAtIndex:5]valueForKey:@"value"]] isEqualToString:@"NA"] || [[[thirdViewArray objectAtIndex:5]valueForKey:@"value"] isEqualToString:@" "])
    {
        [self showMessagewithText:@"Please enter Owner mobile number."];
    }
    else if([[[thirdViewArray objectAtIndex:5]valueForKey:@"value"] length]<10)
    {
        [self showMessagewithText:@"Mobile number should at least 10 digits"];
    }
    else if ([[self checkforValidString:strOwnerSignUrl] isEqualToString:@"NA"])
    {
        [self showMessagewithText:@"Please ask Owner to sign."];
    }
    else if ([[self checkforValidString:strInstallerSignUrl] isEqualToString:@"NA"])
    {
        [self showMessagewithText:@"Please make Installer's sign."];
    }
    else
    {
        isAvail = YES;
    }
    return isAvail;
}
-(void)showMessagewithText:(NSString *)strText
{
    alertView = [[URBAlertView alloc] initWithTitle:ALERT_TITLE message:strText cancelButtonTitle:OK_BTN otherButtonTitles: nil, nil];
    
    [alertView setMessageFont:[UIFont fontWithName:CGRegular size:14]];
    [alertView setHandlerBlock:^(NSInteger buttonIndex, URBAlertView *alertView) {
        [alertView hideWithCompletionBlock:^{
        }];
    }];
    [alertView showWithAnimation:URBAlertAnimationTopToBottom];
    if (IS_IPHONE_X){[alertView showWithAnimation:URBAlertAnimationDefault];}
  
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Textfield Delegates
-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    //Second view
    UITextField * txtTemp2;
    if (textField.tag == 1011)
    {
        [textField resignFirstResponder];
        txtTemp2 = (UIFloatLabelTextField *)[self.view viewWithTag:1022];
        [txtTemp2 becomeFirstResponder];
    }
    else if (textField.tag == 1022)
    {
        [textField resignFirstResponder];
    }
    else if (textField.tag == 1033)
    {
        if (IS_IPHONE_4 || IS_IPHONE_5)
        {
            [UIView animateWithDuration:0.4 animations:^{
                [secondView setFrame:CGRectMake(DEVICE_WIDTH, 0, DEVICE_WIDTH, scrlContent.frame.size.height+ 40)];
            }];
        }
        [textField resignFirstResponder];

    }
    //third view
    UITextField * txtTemp;
    if (textField.tag == 101)
    {
        [textField resignFirstResponder];
        txtTemp = (UIFloatLabelTextField *)[self.view viewWithTag:102];
        [txtTemp becomeFirstResponder];
    }
    else if (textField.tag == 102)
    {
        [textField resignFirstResponder];
        txtTemp = (UIFloatLabelTextField *)[self.view viewWithTag:103];
        [txtTemp becomeFirstResponder];
    }
    else if (textField.tag == 103)
    {
        [textField resignFirstResponder];
        txtTemp = (UIFloatLabelTextField *)[self.view viewWithTag:104];
        [txtTemp becomeFirstResponder];
    }
    else if (textField.tag == 104)
    {
        [textField resignFirstResponder];
        txtTemp = (UIFloatLabelTextField *)[self.view viewWithTag:204];
        [txtTemp becomeFirstResponder];
    }
    else if (textField.tag == 204)
    {
        [textField resignFirstResponder];
        txtTemp = (UIFloatLabelTextField *)[self.view viewWithTag:106];
        [txtTemp becomeFirstResponder];
    }
    else if (textField.tag == 106)
    {
        [textField resignFirstResponder];
        txtTemp = (UIFloatLabelTextField *)[self.view viewWithTag:107];
        [txtTemp becomeFirstResponder];
    }
    else if (textField.tag == 107)
    {
        [textField resignFirstResponder];
    }

    return YES;
}

-(void)textFieldDidBeginEditing:(UITextField *)textField
{
    if (textField.tag == 1033)
    {
        if (IS_IPHONE_4 || IS_IPHONE_5)
        {
            int height = 250;
            
            [UIView animateWithDuration:0.5 animations:^{
                [secondView setFrame:CGRectMake(DEVICE_WIDTH, (heightKeyBrd-height)-45-50, DEVICE_WIDTH, scrlContent.frame.size.height+ 40)];
            }];
        }
        
    }

    if (textField.tag == 104)
    {
        if (IS_IPHONE_4)
        {
            int height = 260;
            
            [UIView animateWithDuration:0.5 animations:^{
                [thirdView setFrame:CGRectMake(DEVICE_WIDTH*2, (heightKeyBrd-height)-45-50, DEVICE_WIDTH, scrlContent.frame.size.height+ 40)];
            }];
        }
        
    }
    else if (textField.tag == 107)
    {
        int height = 250;
        if (IS_IPHONE_6)
        {
            height = 200;
        }
        if (IS_IPHONE_5 )
        {
            [UIView animateWithDuration:0.5 animations:^{
                [thirdView setFrame:CGRectMake(DEVICE_WIDTH*2, (heightKeyBrd-height)-45-50, DEVICE_WIDTH, scrlContent.frame.size.height+ 40)];
            }];
        }
        if (IS_IPHONE_6)
        {
            [UIView animateWithDuration:0.5 animations:^{
                [thirdView setFrame:CGRectMake(DEVICE_WIDTH*2, (heightKeyBrd-height)-45-50, DEVICE_WIDTH, scrlContent.frame.size.height+ 40)];
            }];
        }
        
        UIToolbar* numberToolbar = [[UIToolbar alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 50)];
        numberToolbar.barStyle =  UIBarStyleDefault;
        UIBarButtonItem *space =[[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
        UIBarButtonItem *Done = [[UIBarButtonItem alloc]initWithTitle:@"Done" style:UIBarButtonItemStyleDone target:self action:@selector(doneKeyBoarde)];
        Done.tintColor=[APP_DELEGATE colorWithHexString:App_Header_Color];
        
        numberToolbar.items = [NSArray arrayWithObjects:space,Done,
                               nil];
        [numberToolbar sizeToFit];
        textField.inputAccessoryView = numberToolbar;
    }
    
    lblLine = [[UILabel alloc] initWithFrame:CGRectMake(5,textField.frame.size.height-2-5,textField.frame.size.width,2)];
    [lblLine setBackgroundColor:[UIColor whiteColor]];
    [textField addSubview:lblLine];
    if (page==1  || page==2)
    {
        lblLine.frame = CGRectMake(0,textField.frame.size.height-2,textField.frame.size.width,2);
    }
}
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if (textField.tag == 107)
    {
        if(range.length + range.location > textField.text.length)
        {
            return NO;
        }
        NSUInteger newLength = [textField.text length] + [string length] - range.length;
        if(newLength <= 15)
        {
            if ([string isEqualToString:@","] || [string isEqualToString:@";"] || [string isEqualToString:@"*"] || [string isEqualToString:@"#"])
            {
                return NO;
            }
            else
            {
                return YES;
            }
        }
        else
        {
            return  NO;
        }
    }
    else
    {
        return YES;
    }
}
-(void)textFieldDidEndEditing:(UITextField *)textField
{
    //second view
    if (textField.tag == 1011)
    {
        [[secondViewArray objectAtIndex:1]setValue:[self checkforValidString:textField.text] forKey:@"value"];
    }
    else  if (textField.tag == 1022)
    {
        [[secondViewArray objectAtIndex:1]setValue:[self checkforValidString:textField.text] forKey:@"longitudeValue"];
    }
    else  if (textField.tag == 1033)
    {
        [[secondViewArray objectAtIndex:5]setValue:[self checkforValidString:textField.text] forKey:@"value"];
    }
    
    //third view
    if (textField.tag == 101)
    {
        [[thirdViewArray objectAtIndex:0]setValue:[self checkforValidString:textField.text] forKey:@"value"];
    }
    else if (textField.tag == 102)
    {
        [[thirdViewArray objectAtIndex:1]setValue:[self checkforValidString:textField.text] forKey:@"value"];
    }
    else if (textField.tag == 103)
    {
        [[thirdViewArray objectAtIndex:2]setValue:[self checkforValidString:textField.text] forKey:@"value"];
    }
    else if (textField.tag == 104)
    {
        [[thirdViewArray objectAtIndex:3]setValue:[self checkforValidString:textField.text] forKey:@"value"];
    }
    else if (textField.tag == 204)
    {
        [[thirdViewArray objectAtIndex:3]setValue:[self checkforValidString:textField.text] forKey:@"zipValue"];
    }
    else if (textField.tag == 106)
    {
        [[thirdViewArray objectAtIndex:4]setValue:[self checkforValidString:textField.text] forKey:@"value"];
    }
    else if (textField.tag == 107)
    {
        [[thirdViewArray objectAtIndex:5]setValue:[self checkforValidString:textField.text] forKey:@"value"];
    }
    [lblLine removeFromSuperview];
}

-(void)doneKeyBoarde
{
    if (IS_IPHONE_4 || IS_IPHONE_5 ||  IS_IPHONE_6)
    {
        [UIView animateWithDuration:0.4 animations:^{
            [thirdView setFrame:CGRectMake(DEVICE_WIDTH*2, 0, DEVICE_WIDTH, scrlContent.frame.size.height+ 40)];
        }];
        
    }
    UITextField* txtTemp = (UIFloatLabelTextField *)[self.view viewWithTag:107];
    [txtTemp resignFirstResponder];
    
}

-(BOOL)validateEmailHere:(NSString*)email
{
    if ([email isEqualToString:@"NA"])
    {
        return true;
    }
    else
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
        else
        {// no '@' or '.' present
            return FALSE;
        }
    }
}
#pragma mark - Country Picker delegate
- (void)countryPicker:(__unused CountryPicker *)picker didSelectCountryWithName:(NSString *)name code:(NSString *)code withImg:(NSInteger)imgCode
{
    lblCountry.text = [NSString stringWithFormat:@"  %@",name];
    strContCode = code;
    strContCode = code;
}

-(void)checkForAppearFields
{
    if (![installScanID isEqual:[NSNull null]])
    {
        if (installScanID != nil && installScanID != NULL && ![installScanID isEqualToString:@""])
        {
            [[firstViewArray objectAtIndex:0]setValue:installScanID forKey:@"value"];
        }
        else
        {
            [[firstViewArray objectAtIndex:0]setValue:@"" forKey:@"value"];
        }
        [tblFirstView reloadData];
    }
    else
    {
        [[firstViewArray objectAtIndex:0]setValue:@"" forKey:@"value"];
        [tblFirstView reloadData];
    }

    if (![globalDeviceType isEqual:[NSNull null]])
    {
        if (![[self checkforValidString:globalDeviceType] isEqualToString:@"NA"])
        {
            [[firstViewArray objectAtIndex:1]setValue:globalDeviceType forKey:@"value"];
        }
        else
        {
            [[firstViewArray objectAtIndex:1]setValue:@"" forKey:@"value"];
        }
        [tblFirstView reloadData];
    }
    else
    {
        [[firstViewArray objectAtIndex:1]setValue:@"" forKey:@"value"];
        [tblFirstView reloadData];
    }
    
    if (![installVesselName isEqual:[NSNull null]])
    {
        if (installVesselName != nil && installVesselName != NULL && ![installVesselName isEqualToString:@""] && ![installVesselName isEqualToString:@"NA"])
        {
            [[secondViewArray objectAtIndex:2] setValue:installVesselName forKey:@"value"];
        }
        else
        {
            [[secondViewArray objectAtIndex:2] setValue:@"" forKey:@"value"];

        }
        [tblSecondView reloadData];
    }
    else
    {
        [[secondViewArray objectAtIndex:2] setValue:@"" forKey:@"value"];
        [tblSecondView reloadData];
    }
    
    if (![installRegi isEqual:[NSNull null]])
    {
        if (installRegi != nil && installRegi != NULL && ![installRegi isEqualToString:@""] && ![installRegi isEqualToString:@"NA"])
        {
            [[secondViewArray objectAtIndex:3] setValue:installRegi forKey:@"value"];
        }
        else
        {
            [[secondViewArray objectAtIndex:3] setValue:@"NA" forKey:@"value"];
        }
        [tblSecondView reloadData];
    }
    else
    {
        [[secondViewArray objectAtIndex:3] setValue:@"NA" forKey:@"value"];
        [tblSecondView reloadData];
    }
    
    if (![installPhotoCounts isEqual:[NSNull null]])
    {
        if (installPhotoCounts != nil && installPhotoCounts != NULL && ![installPhotoCounts isEqualToString:@""])
        {
            [[secondViewArray objectAtIndex:6] setValue:installPhotoCounts forKey:@"value"];
        }
        else
        {
            [[secondViewArray objectAtIndex:6] setValue:@"" forKey:@"value"];
        }
        [tblSecondView reloadData];
    }
    else
    {
        [[secondViewArray objectAtIndex:6] setValue:@"" forKey:@"value"];
        [tblSecondView reloadData];
    }
    
    if (![[self checkforValidString:[[firstViewArray objectAtIndex:1]valueForKey:@"value"]] isEqualToString:@"NA"])
    {
        
    }
    else
    {
        [[firstViewArray objectAtIndex:1]setValue:@"" forKey:@"value"];
        [tblFirstView reloadData];
    }
    
    NSString * strCntrName = phoneCountryName;
    if (strCntrName == nil || [strCntrName length]==0 || [strCntrName isEqual:[NSNull null]] || [strCntrName isEqualToString:@"<nil>"])
    {
        phoneCountryCode = @"GB";
        phoneCountryName = @"United Kingdom";
        lblCountry.text = phoneCountryName;
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

-(NSString *)checkforValidStringForEdit:(NSString *)strRequest
{
    NSString * strValid;
    if (![strRequest isEqual:[NSNull null]])
    {
        if (strRequest != nil && strRequest != NULL && ![strRequest isEqualToString:@""] && ![strRequest isEqualToString:@"NA"])
        {
            strValid = strRequest;
        }
        else
        {
            strValid = @"";
        }
    }
    else
    {
        strValid = @"";
    }
    strValid = [strValid stringByReplacingOccurrencesOfString:@"\"" withString:@""];

    return strValid;
}
- (UIImage *)imageWithImageKP:(UIImage *)image scaledToSize:(CGSize)newSize
{
    //UIGraphicsBeginImageContext(newSize);
    // In next line, pass 0.0 to use the current device's pixel scaling factor (and thus account for Retina resolution).
    // Pass 1.0 to force exact pixel size.
    UIGraphicsBeginImageContextWithOptions(newSize, NO, 0.0);
    [image drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}
#pragma mark - Web Service Call
-(void)getDeviceDetailService
{
    if ([APP_DELEGATE isNetworkreachable])
    {
        [APP_DELEGATE endHudProcess];
        if (isFromNextTest)
        {
            [APP_DELEGATE startHudProcess:@"Checking details..."];
        }
        else
        {
            [APP_DELEGATE startHudProcess:@"Getting details..."];
        }
    }

    NSString *websrviceName=@"testdevice";
    
    NSMutableDictionary * dict = [[NSMutableDictionary alloc]init];
    [dict setValue:installScanID forKey:@"imei"];
    [dict setValue:CURRENT_USER_ID forKey:@"user_id"];
    
    URLManager *manager = [[URLManager alloc] init];
    manager.commandName = @"TestDevice";
    manager.delegate = self;
    NSString *strServerUrl = @"http://succorfish.in/mobile/";
    [manager postUrlCall:[NSString stringWithFormat:@"%@%@",strServerUrl,websrviceName] withParameters:dict];
}
-(void)SaveInstalltoServer
{
    NSString * strServerIDD = [self checkforValidString:[detailDict valueForKey:@"server_id"]];
    if (isInstalledDetailSynced || ![strServerIDD isEqualToString:@"NA" ])
    {
        [APP_DELEGATE endHudProcess];
        [APP_DELEGATE startHudProcess:@"Saving Installation photos...."];
        [self saveInstallationPhotostoServer];
    }
    else
    {
        [APP_DELEGATE endHudProcess];
        [APP_DELEGATE startHudProcess:@"Saving Installation details...."];
        
        NSString * strUserId = CURRENT_USER_ID;
        
        NSMutableDictionary * dict = [[NSMutableDictionary alloc]init];
        [dict setValue:strUserId forKey:@"user_id"];
        [dict setValue:[self checkforValidString:[detailDict valueForKey:@"imei"]] forKey:@"imei"];
        [dict setValue:[self checkforValidString:[detailDict valueForKey:@"device_type"]] forKey:@"device_type"];
        [dict setValue:[self checkforValidString:[detailDict valueForKey:@"warranty"]] forKey:@"warranty"];
        [dict setValue:[self checkforValidString:[detailDict valueForKey:@"date"]] forKey:@"date"];
        [dict setValue:[self checkforValidString:[detailDict valueForKey:@"latitude"]] forKey:@"latitude"];
        [dict setValue:[self checkforValidString:[detailDict valueForKey:@"longitude"]] forKey:@"longitude"];
        [dict setValue:[self checkforValidString:[detailDict valueForKey:@"vesselname"]] forKey:@"vessel_name"];
        [dict setValue:[self checkforValidString:[detailDict valueForKey:@"portno"]] forKey:@"port"];
        [dict setValue:[self checkforValidString:[detailDict valueForKey:@"power"]] forKey:@"power"];
        [dict setValue:[self checkforValidString:[detailDict valueForKey:@"device_install_location"]] forKey:@"device_install_location"];
        [dict setValue:[self checkforValidString:[detailDict valueForKey:@"owner_name"]] forKey:@"owner_name"];
        [dict setValue:[self checkforValidString:[detailDict valueForKey:@"owner_address"]] forKey:@"owner_address"];
        [dict setValue:[self checkforValidString:[detailDict valueForKey:@"owner_city"]] forKey:@"owner_city"];
        [dict setValue:[self checkforValidString:[detailDict valueForKey:@"owner_state"]] forKey:@"owner_state"];
        [dict setValue:[self checkforValidString:[detailDict valueForKey:@"owner_zipcode"]] forKey:@"owner_zipcode"];
        [dict setValue:[self checkforValidString:[detailDict valueForKey:@"owner_email"]] forKey:@"owner_email"];
        [dict setValue:[self checkforValidString:[detailDict valueForKey:@"owner_phone_no"]] forKey:@"owner_phone_no"];
        [dict setValue:[self checkforValidString:[detailDict valueForKey:@"installation_county"]] forKey:@"installation_county"];
        [dict setValue:installPhotoCounts forKey:@"image_count"];
        
        NSString * strOwnerUrl = [self documentsPathForFileName:[NSString stringWithFormat:@"InstallSigns/%@",[detailDict valueForKey:@"local_owner_sign"]]];
        NSData *ownerData = [NSData dataWithContentsOfFile:strOwnerUrl];
        
        NSString * strInstallUrl = [self documentsPathForFileName:[NSString stringWithFormat:@"InstallSigns/%@",[detailDict valueForKey:@"local_installer_sign"]]];
        NSData *installerData = [NSData dataWithContentsOfFile:strInstallUrl];

        NSMutableArray * arr1 = [[NSMutableArray alloc] init];
        [arr1 addObject:ownerData];
        [arr1 addObject:installerData];

        NSMutableArray * arr2 = [[NSMutableArray alloc] init];
        [arr2 addObject:@"sign_image"];
        [arr2 addObject:@"ins_sign_image"];

        NSMutableArray * arr3 = [[NSMutableArray alloc] init];
        [arr3 addObject:strOwnerUrl];
        [arr3 addObject:strInstallUrl];

        URLManager *manager = [[URLManager alloc] init];
        manager.commandName = @"SaveInstall";
        manager.delegate = self;
        NSString *strServerUrl = @"http://succorfish.in/mobile/installation";
        
        [manager postUrlCallForMultipleImage:strServerUrl withParameters:dict andMediaData:arr1 andDataParameterName:arr2 andFileName:arr3];
    }
}
-(void)saveInstallationPhotostoServer
{
    NSMutableArray * imgTempArr = [[NSMutableArray alloc] init];
    NSString * strQuery = [NSString stringWithFormat:@"select * from tbl_installer_photo where inst_local_id = '%@' and is_sync = '0' and inst_photo_user_id ='%@'",strInstallID,CURRENT_USER_ID];
    [[DataBaseManager dataBaseManager] execute:strQuery resultsArray:imgTempArr];
    
    if ([imgTempArr count]>0)
    {
        NSMutableDictionary * dict = [[NSMutableDictionary alloc]init];

        NSString * localPath = [NSString stringWithFormat:@"%@",[[imgTempArr objectAtIndex:0] valueForKey:@"inst_photo_local_url"]];
        NSString * filePath = [self documentsPathForFileName:[NSString stringWithFormat:@"InstallPhotos/%@",localPath]];
        NSData *pngData = [NSData dataWithContentsOfFile:filePath];
        
        localImageId = [NSString stringWithFormat:@"%@",[[imgTempArr objectAtIndex:0] valueForKey:@"inst_photo_local_id"]];
        
        NSMutableArray * arr1 = [[NSMutableArray alloc] init];
        [arr1 addObject:pngData];
        
        NSMutableArray * arr2 = [[NSMutableArray alloc] init];
        NSString * strinstller = @"file";
        [arr2 addObject:strinstller];
        
        NSMutableArray * arr3 = [[NSMutableArray alloc] init];
        [arr3 addObject:filePath];
        
        URLManager *manager = [[URLManager alloc] init];
        manager.commandName = @"SavePhotos";
        manager.delegate = self;
        NSString *strServerUrl = [NSString stringWithFormat:@"https://ws.scstg.net/basic/v2/device-history/uploadBinaryFile/%@",serverInstallationID];
        
        [manager postUrlCallForMultipleImage:strServerUrl withParameters:dict andMediaData:arr1 andDataParameterName:arr2 andFileName:arr3];
    }
    else
    {
        NSMutableDictionary * dict = [[NSMutableDictionary alloc]init];
        
        NSString * localPath = [self writeToTextFile];
        NSData *pngData = [NSData dataWithContentsOfFile:localPath];
        
//        localImageId = [NSString stringWithFormat:@"%@",[[imgTempArr objectAtIndex:0] valueForKey:@"inst_photo_local_id"]];
        
        NSMutableArray * arr1 = [[NSMutableArray alloc] init];
        [arr1 addObject:pngData];
        
        NSMutableArray * arr2 = [[NSMutableArray alloc] init];
        NSString * strinstller = @"file";
        [arr2 addObject:strinstller];
        
        NSMutableArray * arr3 = [[NSMutableArray alloc] init];
        [arr3 addObject:localPath];
        
        URLManager *manager = [[URLManager alloc] init];
        manager.commandName = @"SaveFile";
        manager.delegate = self;
        NSString *strServerUrl = [NSString stringWithFormat:@"https://ws.scstg.net/basic/v2/device-history/uploadBinaryFile/%@",serverInstallationID];
        
        [manager postUrlCallForMultipleImage:strServerUrl withParameters:dict andMediaData:arr1 andDataParameterName:arr2 andFileName:arr3];
    }
}
-(void)CallCompleteServiceforInstallation
{
    URLManager *manager = [[URLManager alloc] init];
    manager.commandName = @"SendComplete";
    manager.delegate = self;
    NSString *strServerUrl = [NSString stringWithFormat:@"https://ws.scstg.net/basic/v2/device-history/complete/%@",serverInstallationID];
    NSMutableDictionary * dict = [[NSMutableDictionary alloc]init];
    [manager postUrlCall:strServerUrl withParameters:dict];
}
-(void)TestDeviceRomanAPI
{
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0ul);
    dispatch_async(queue, ^{
        {
            NSString * strUrl = [NSString stringWithFormat:@"https://ws.scstg.net/basic/v2/waypoint/getLatest/%@",strSuccorfishDeviceID];
            NSString * strbasicAuthToken;
            NSString * strUserName = [NSString stringWithFormat:@"%@",CURRENT_USER_EMAIL];
            NSString * strPassword = [NSString stringWithFormat:@"%@",CURRENT_USER_PASS];
            NSString * str = [NSString stringWithFormat:@"%@:%@",strUserName,strPassword];
            NSString * simpleStr = [APP_DELEGATE base64String:str];
            strbasicAuthToken = simpleStr;
            NSMutableDictionary *args = [[NSMutableDictionary alloc] init];

            AFHTTPRequestOperationManager *manager1 = [[AFHTTPRequestOperationManager alloc] initWithBaseURL:[NSURL URLWithString:@"http://server.url"]];
            NSString *authorization = [NSString stringWithFormat: @"Basic %@",strbasicAuthToken];
            [manager1.requestSerializer setValue:authorization forHTTPHeaderField:@"Authorization"];
            AFHTTPRequestOperation *op = [manager1 GET:strUrl parameters:args success:^(AFHTTPRequestOperation *operation, id responseObject){
                NSLog(@"Success Response with Result=%@",responseObject);
                [APP_DELEGATE endHudProcess];
                {
                    if ([responseObject isKindOfClass:[NSDictionary class]])
                    {
                        if (indexOne == 2)
                        {
                            [self testDevice3rdScreen:responseObject];
                        }
                        else
                        {
                            if (isFromNextTest)
                            {
                                [self AllowtoMoveforSecondScreen];
                            }
                            else
                            {
                                NSMutableDictionary * dictID = [[NSMutableDictionary alloc] init];
                                dictID = [responseObject mutableCopy];
                                NSString * strGeneratDate = [NSString stringWithFormat:@"%@",[dictID valueForKey:@"generatedDate"]];
                                if ([[self checkforValidString:strGeneratDate] isEqualToString:@"NA"])
                                {
                                    NSMutableDictionary * dtaliDict = [[NSMutableDictionary alloc] init];
                                    [dtaliDict setObject:strGeneratDate forKey:@"date"];
                                    [dtaliDict setObject:installScanID forKey:@"imei"];
                                    [dtaliDict setObject:[NSString stringWithFormat:@"%@",[dictID valueForKey:@"lat"]] forKey:@"latitude"];
                                    [dtaliDict setObject:[NSString stringWithFormat:@"%@",[dictID valueForKey:@"lng"]] forKey:@"longitude"];
                                    
                                    LastWaypointVC * lastVC = [[LastWaypointVC alloc] init];
                                    lastVC.detailDict = dtaliDict;
                                    [self.navigationController pushViewController:lastVC animated:YES];
                                }
                                else
                                {
                                    NSString *mainStr = strGeneratDate;
                                    NSString * newString = [mainStr substringToIndex:[mainStr length]-3];
                                    
                                    double unixTimeStamp = [newString doubleValue];
                                    NSTimeInterval _interval=unixTimeStamp;
                                    NSDate *date = [NSDate dateWithTimeIntervalSince1970:_interval];
                                    NSDateFormatter *_formatter=[[NSDateFormatter alloc]init];
                                    NSTimeZone *gmt = [NSTimeZone localTimeZone];
                                    
                                    [_formatter setTimeZone:gmt];
                                    [_formatter setDateFormat:[NSString stringWithFormat:@"%@ HH:mm",[[NSUserDefaults standardUserDefaults] valueForKey:@"GloablDateFormat"]]];
                                    NSString *_date=[_formatter stringFromDate:date];
                                    NSLog(@"THE FINAL DATE===>>>%@",_date);
                                    
                                    NSMutableDictionary * dtaliDict = [[NSMutableDictionary alloc] init];
                                    [dtaliDict setObject:_date forKey:@"date"];
                                    [dtaliDict setObject:installScanID forKey:@"imei"];
                                    [dtaliDict setObject:[NSString stringWithFormat:@"%@",[dictID valueForKey:@"lat"]] forKey:@"latitude"];
                                    [dtaliDict setObject:[NSString stringWithFormat:@"%@",[dictID valueForKey:@"lng"]] forKey:@"longitude"];
                                    
                                    LastWaypointVC * lastVC = [[LastWaypointVC alloc] init];
                                    lastVC.detailDict = dtaliDict;
                                    [self.navigationController pushViewController:lastVC animated:YES];
                                }
                            }
                        }
                    }
                    else
                    {
                        if ([responseObject isEqual:[NSNull null]] || [responseObject isEqualToString:@"<nil>"] || responseObject == NULL)
                        {
                            if (indexOne == 2)
                            {
                                alertView = [[URBAlertView alloc] initWithTitle:ALERT_TITLE message:@"Device has never submitted any positional data to the system" cancelButtonTitle:OK_BTN otherButtonTitles: nil, nil];
                                [alertView setMessageFont:[UIFont fontWithName:CGRegular size:14]];
                                [alertView setHandlerBlock:^(NSInteger buttonIndex, URBAlertView *alertView) {
                                    [alertView hideWithCompletionBlock:^{
                                    }];
                                }];
                                [alertView showWithAnimation:URBAlertAnimationTopToBottom];
                                if (IS_IPHONE_X){[alertView showWithAnimation:URBAlertAnimationDefault];}
                                
                            }
                            else
                            {
                                if (isFromNextTest)
                                {
                                    [self AllowtoMoveforSecondScreen];
                                }
                                else
                                {
                                    alertView = [[URBAlertView alloc] initWithTitle:ALERT_TITLE message:@"Device has never submitted any positional data to the system" cancelButtonTitle:OK_BTN otherButtonTitles: nil, nil];
                                    [alertView setMessageFont:[UIFont fontWithName:CGRegular size:14]];
                                    [alertView setHandlerBlock:^(NSInteger buttonIndex, URBAlertView *alertView) {
                                        [alertView hideWithCompletionBlock:^{
                                        }];
                                    }];
                                    [alertView showWithAnimation:URBAlertAnimationTopToBottom];
                                    if (IS_IPHONE_X){[alertView showWithAnimation:URBAlertAnimationDefault];}
                                    
                                }
                            }
                            
                        }
                    }
                }
    
            }
                                               failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                                   if (error) {
                                                       [APP_DELEGATE endHudProcess];
                                                       
                                                       NSLog(@"Servicer error = %@", error);
                                                       [APP_DELEGATE endHudProcess];
                                                       
                                                       alertView = [[URBAlertView alloc] initWithTitle:ALERT_TITLE message:@"Something went wrong. Please try again." cancelButtonTitle:OK_BTN otherButtonTitles: nil, nil];
                                                       [alertView setMessageFont:[UIFont fontWithName:CGRegular size:14]];
                                                       [alertView setHandlerBlock:^(NSInteger buttonIndex, URBAlertView *alertView) {
                                                           [alertView hideWithCompletionBlock:
                                                            ^{

                                                            }];
                                                       }];
                                                       [alertView showWithAnimation:URBAlertAnimationTopToBottom];
    if (IS_IPHONE_X){[alertView showWithAnimation:URBAlertAnimationDefault];}
                                                   }
                                               }];
            [op start];
        }
        // Perform async operation
        // Call your method/function here
        // Example:
        dispatch_sync(dispatch_get_main_queue(), ^{
            //Method call finish here
        });
    });
}
-(void)getDeviceIDfromIMEIRomanAPI
{
    if ([APP_DELEGATE isNetworkreachable])
    {
        [APP_DELEGATE endHudProcess];
        [APP_DELEGATE startHudProcess:@"Getting details..."];
    }
    
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0ul);
    dispatch_async(queue, ^{
        {
            NSMutableDictionary *args = [[NSMutableDictionary alloc] init];
            
            NSString * strUrl = [NSString stringWithFormat:@"https://ws.scstg.net/basic/v2/device/getForImei/%@",installScanID];
//            NSString * strUrl = [NSString stringWithFormat:@"https://ws.scstg.net/basic/v2/device/getForImei/123123123123123"];

            NSString * strbasicAuthToken;
//            NSString * str = [NSString stringWithFormat:@"device_test:dac6hTQXJc"];
            NSString * strUserName = [NSString stringWithFormat:@"%@",CURRENT_USER_EMAIL];
            NSString * strPassword = [NSString stringWithFormat:@"%@",CURRENT_USER_PASS];
            NSString * str = [NSString stringWithFormat:@"%@:%@",strUserName,strPassword];

            NSString * simpleStr = [APP_DELEGATE base64String:str];
            strbasicAuthToken = simpleStr;
            if ([strUrl rangeOfString:@"staging"].location != NSNotFound)
            {
                strbasicAuthToken = [[NSUserDefaults standardUserDefaults] valueForKey:@"BasicAuthToken"];
            }
            

          

            AFHTTPRequestOperationManager *manager1 = [[AFHTTPRequestOperationManager alloc] initWithBaseURL:[NSURL URLWithString:@"http://server.url"]];
            NSString *authorization = [NSString stringWithFormat: @"Basic %@",strbasicAuthToken];
            [manager1.requestSerializer setValue:authorization forHTTPHeaderField:@"Authorization"];
            
            AFHTTPRequestOperation *op = [manager1 GET:strUrl parameters:args success:^(AFHTTPRequestOperation *operation, id responseObject){
            NSLog(@"Success Response with Result=%@",responseObject);
                
                NSMutableDictionary * dictID = [[NSMutableDictionary alloc] init];
                dictID = [responseObject mutableCopy];

                if ([[self checkforValidString:[dictID valueForKey:@"id"]] isEqualToString:@"NA"])
                {
                    [APP_DELEGATE endHudProcess];
                    
                    alertView = [[URBAlertView alloc] initWithTitle:ALERT_TITLE message:@"Something went wrong. Please try again." cancelButtonTitle:OK_BTN otherButtonTitles: nil, nil];
                    [alertView setMessageFont:[UIFont fontWithName:CGRegular size:14]];
                    [alertView setHandlerBlock:^(NSInteger buttonIndex, URBAlertView *alertView) {
                        [alertView hideWithCompletionBlock:
                         ^{
                         }];
                    }];
                    [alertView showWithAnimation:URBAlertAnimationTopToBottom];
    if (IS_IPHONE_X){[alertView showWithAnimation:URBAlertAnimationDefault];}
                }
                else
                {
                    strSuccorfishDeviceID = [self checkforValidString:[dictID valueForKey:@"id"]];
                    [self TestDeviceRomanAPI];
                }
            }
                                               failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                                   if (error) {
                                                       [APP_DELEGATE endHudProcess];
                                                       NSLog(@"Servicer error = %@", error);
                                                       [APP_DELEGATE endHudProcess];
                                                       
                                                       alertView = [[URBAlertView alloc] initWithTitle:ALERT_TITLE message:@"Something went wrong. Please try again." cancelButtonTitle:OK_BTN otherButtonTitles: nil, nil];
                                                       [alertView setMessageFont:[UIFont fontWithName:CGRegular size:14]];
                                                       [alertView setHandlerBlock:^(NSInteger buttonIndex, URBAlertView *alertView) {
                                                           [alertView hideWithCompletionBlock:
                                                            ^{
                                                            }];
                                                       }];
                                                       [alertView showWithAnimation:URBAlertAnimationTopToBottom];
    if (IS_IPHONE_X){[alertView showWithAnimation:URBAlertAnimationDefault];}
                                                   }
                                               }];
            [op start];
        }
        // Perform async operation
        // Call your method/function here
        // Example:
        dispatch_sync(dispatch_get_main_queue(), ^{
            //Method call finish here
        });
    });
}

-(void)kpSavInstall
{
    [APP_DELEGATE endHudProcess];
    [APP_DELEGATE startHudProcess:@"Saving Installation details...."];
    
    NSString * strServerIDD = [self checkforValidString:[detailDict valueForKey:@"server_id"]];
    if (isInstalledDetailSynced || ![strServerIDD isEqualToString:@"NA" ])
    {
        NSString * strCheck1 = [NSString stringWithFormat:@"select * from tbl_install where server_id = '%@'",strServerIDD];
        NSMutableArray * tmpArr = [[NSMutableArray alloc] init];
        [[DataBaseManager dataBaseManager] execute:strCheck1 resultsArray:tmpArr];
        if ([tmpArr count]>0)
        {
            if ([[[tmpArr objectAtIndex:0] valueForKey:@"server_installer_sign"] isEqualToString:@"1"])
            {
                if ([[[tmpArr objectAtIndex:0] valueForKey:@"server_owner_sign"] isEqualToString:@"1"])
                {
                    [self saveInstallationPhotostoServer];
                }
                else
                {
                    [self saveOwnerSignaturesServer];
                }
            }
            else
            {
                [self saveInstallSignaturesServer];
            }
        }
        else
        {
            [APP_DELEGATE endHudProcess];
            [APP_DELEGATE startHudProcess:@"Saving Installation photos...."];
            [self saveInstallationPhotostoServer];
        }
    }
    else
    {
        NSString * strUrl = [NSString stringWithFormat:@"https://ws.scstg.net/basic/v2/device/install/%@",strSuccorfishDeviceID];
        
        NSString * strbasicAuthToken;
        NSString * strUserName = [NSString stringWithFormat:@"%@",CURRENT_USER_EMAIL];
        NSString * strPassword = [NSString stringWithFormat:@"%@",CURRENT_USER_PASS];
        NSString * str = [NSString stringWithFormat:@"%@:%@",strUserName,strPassword];
        NSString * simpleStr = [APP_DELEGATE base64String:str];
        strbasicAuthToken = simpleStr;
        
        NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
        [dict setValue:[self checkforValidString:[detailDict valueForKey:@"owner_name"]] forKey:@"name"];
        [dict setValue:[self checkforValidString:[detailDict valueForKey:@"owner_address"]] forKey:@"address"];
        [dict setValue:[self checkforValidString:[detailDict valueForKey:@"owner_city"]] forKey:@"city"];
        [dict setValue:[self checkforValidString:[detailDict valueForKey:@"owner_state"]] forKey:@"state"];
        [dict setValue:[self checkforValidString:[detailDict valueForKey:@"owner_zipcode"]] forKey:@"zipCode"];
        [dict setValue:[self checkforValidString:[detailDict valueForKey:@"owner_email"]] forKey:@"email"];
        [dict setValue:[self checkforValidString:[detailDict valueForKey:@"owner_phone_no"]] forKey:@"telephone"];
        [dict setValue:@"NA" forKey:@"occupation"];
        
        NSMutableDictionary *args = [[NSMutableDictionary alloc] init];
        [args setValue:[self checkforValidString:installedVesselID] forKey:@"assetId"];
        [args setValue:[self checkforValidString:installedVesselID] forKey:@"installationPlace"];
        [args setValue:[self checkforValidString:[detailDict valueForKey:@"device_install_location"]] forKey:@"installationPlace"];
        [args setValue:[self checkforValidString:[detailDict valueForKey:@"power"]] forKey:@"powerSource"];
        [args setValue:strPowerValues forKey:@"powerSource"];
        [args setObject:dict forKey:@"contactInfo"];
        
        URLManager * manager = [[URLManager alloc] init];
        manager.commandName = @"SaveInstallkp";
        manager.delegate = self;
        [manager postUrlCall:strUrl withParameters:args];
    }
}
-(void)saveInstallSignaturesServer
{
    NSMutableDictionary * dict = [[NSMutableDictionary alloc]init];
    
    NSString * localPath = [self documentsPathForFileName:[NSString stringWithFormat:@"InstallSigns/%@",[detailDict valueForKey:@"local_installer_sign"]]];
    NSData *pngData = [NSData dataWithContentsOfFile:localPath];
    
    NSMutableArray * arr1 = [[NSMutableArray alloc] init];
    [arr1 addObject:pngData];
    
    NSMutableArray * arr2 = [[NSMutableArray alloc] init];
    NSString * strinstller = @"file";
    [arr2 addObject:strinstller];
    
    NSMutableArray * arr3 = [[NSMutableArray alloc] init];
    [arr3 addObject:localPath];
    
    URLManager *manager = [[URLManager alloc] init];
    manager.commandName = @"SaveInstallSign";
    manager.delegate = self;
    NSString *strServerUrl = [NSString stringWithFormat:@"https://ws.scstg.net/basic/v2/device-history/uploadBinaryFile/%@",serverInstallationID];
    
    [manager postUrlCallForMultipleImage:strServerUrl withParameters:dict andMediaData:arr1 andDataParameterName:arr2 andFileName:arr3];
}
-(void)saveOwnerSignaturesServer
{
    NSMutableDictionary * dict = [[NSMutableDictionary alloc]init];
    
    NSString * localPath = [self documentsPathForFileName:[NSString stringWithFormat:@"InstallSigns/%@",[detailDict valueForKey:@"local_owner_sign"]]];
    NSData *pngData = [NSData dataWithContentsOfFile:localPath];
    
    NSMutableArray * arr1 = [[NSMutableArray alloc] init];
    [arr1 addObject:pngData];
    
    NSMutableArray * arr2 = [[NSMutableArray alloc] init];
    NSString * strinstller = @"file";
    [arr2 addObject:strinstller];
    
    NSMutableArray * arr3 = [[NSMutableArray alloc] init];
    [arr3 addObject:localPath];
    
    URLManager *manager = [[URLManager alloc] init];
    manager.commandName = @"SaveOwnerSign";
    manager.delegate = self;
    NSString *strServerUrl = [NSString stringWithFormat:@"https://ws.scstg.net/basic/v2/device-history/uploadBinaryFile/%@",serverInstallationID];
    
    [manager postUrlCallForMultipleImage:strServerUrl withParameters:dict andMediaData:arr1 andDataParameterName:arr2 andFileName:arr3];
}

-(void)ErrorMessagePopup
{
    [APP_DELEGATE endHudProcess];

    alertView = [[URBAlertView alloc] initWithTitle:ALERT_TITLE message:@"Something went wrong. Please try again." cancelButtonTitle:OK_BTN otherButtonTitles: nil, nil];
    [alertView setMessageFont:[UIFont fontWithName:CGRegular size:14]];
    [alertView setHandlerBlock:^(NSInteger buttonIndex, URBAlertView *alertView) {
        [alertView hideWithCompletionBlock:
         ^{
             [self SendErrorReport];
        }];
    }];
    [alertView showWithAnimation:URBAlertAnimationTopToBottom];
    if (IS_IPHONE_X){[alertView showWithAnimation:URBAlertAnimationDefault];}
}
-(void)SendErrorReport
{
    alertView = [[URBAlertView alloc] initWithTitle:ALERT_TITLE message:@"Do you want to report this bug to the developer team?" cancelButtonTitle:OK_BTN otherButtonTitles:@"Cancel", nil];
    [alertView setMessageFont:[UIFont fontWithName:CGRegular size:14]];
    [alertView setHandlerBlock:^(NSInteger buttonIndex, URBAlertView *alertView)
    {
        [alertView hideWithCompletionBlock:
         ^{
             if (buttonIndex == 0)
             {
                 [self btnMailClick];

             }
         }];
    }];
    [alertView showWithAnimation:URBAlertAnimationTopToBottom];
    if (IS_IPHONE_X){[alertView showWithAnimation:URBAlertAnimationDefault];}
}
#pragma mark - Compose Mail
-(void)btnMailClick
{
    
    // Email Subject
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"yyyy-MM-dd HH:mm";
    NSString *strCurrentDate = [formatter stringFromDate:[NSDate date]];
 //   NSString *emailTitle = @"Report:Installation   ";
    NSString *emailTitle = [NSString stringWithFormat:@"Report:Installation %@",strCurrentDate];
    // Email Content
    
    // To address
  //  NSArray *toRecipents = [NSArray arrayWithObject:@"tom@succorfish.com",@"kalpesh@succorfish.com"];
    NSArray *toRecipents = [NSArray arrayWithObjects:@"tom@succorfish.com",@"kalpesh@succorfish.com", nil];
    
    MFMailComposeViewController *mc = [[MFMailComposeViewController alloc] init];
    mc.mailComposeDelegate = self;
    [mc setSubject:emailTitle];
   // [mc setMessageBody:@"" isHTML:NO];
    [mc setMessageBody:[NSString stringWithFormat:@"%@",strErrorReport] isHTML:true];
    [mc setToRecipients:toRecipents];
    
    if (mc == nil)
    {
        alertView = [[URBAlertView alloc] initWithTitle:ALERT_TITLE message:@"Please set up a Mail account in order to send email." cancelButtonTitle:OK_BTN otherButtonTitles: nil, nil];
        
        [alertView setMessageFont:[UIFont fontWithName:CGRegular size:14]];
        [alertView setHandlerBlock:^(NSInteger buttonIndex, URBAlertView *alertView) {
            [alertView hideWithCompletionBlock:^{
            }];
        }];
        [alertView showWithAnimation:URBAlertAnimationTopToBottom];
    if (IS_IPHONE_X){[alertView showWithAnimation:URBAlertAnimationDefault];}
    }
    else
    {
        [self.navigationController presentViewController:mc animated:YES completion:nil];
    }
}

- (void) mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
    switch (result)
    {
        case MFMailComposeResultCancelled:
            NSLog(@"Mail cancelled");
            break;
        case MFMailComposeResultSaved:
            NSLog(@"Mail saved");
            break;
        case MFMailComposeResultSent:
            NSLog(@"Mail sent");
            break;
        case MFMailComposeResultFailed:
            NSLog(@"Mail sent failure: %@", [error localizedDescription]);
            break;
        default:
            break;
    }
    
    // Close the Mail Interface
    [self dismissViewControllerAnimated:YES completion:NULL];
}
#pragma mark - UrlManager Delegate
- (void)onResult:(NSDictionary *)result
{
    NSLog(@"The result is...%@", result);
    if ([[result valueForKey:@"commandName"] isEqualToString:@"SaveInstallkp"])
    {
        [APP_DELEGATE endHudProcess];

        if ([[result valueForKey:@"result"] count]>=10)
        {
            NSMutableDictionary * tmpDict = [[NSMutableDictionary alloc] init];
            tmpDict = [[result valueForKey:@"result"] mutableCopy];

            serverInstallationID = [tmpDict valueForKey:@"id"];
            NSString * requestStr =[NSString stringWithFormat:@"update tbl_install set server_id = '%@' where id = '%@'",serverInstallationID,strInstallID];
            [[DataBaseManager dataBaseManager] execute:requestStr];
            [detailDict setValue:serverInstallationID forKey:@"server_id"];

            [APP_DELEGATE endHudProcess];
            [APP_DELEGATE startHudProcess:@"Saving Installation photos...."];
            [APP_DELEGATE updateBadgeCount];
            [self saveInstallSignaturesServer];
        }
        else
        {
            if ([[result valueForKey:@"result"] isKindOfClass:[NSArray class]])
            {
                if ([[result valueForKey:@"result"] count]>0)
                {
//                    if ([checkStr rangeOfString:@"Vithamas"].location != NSNotFound)
                    NSString * strErrorCode  = [[[result valueForKey:@"result"] objectAtIndex:0] valueForKey:@"errorCode"];
                    if ([strErrorCode isEqualToString:@"device.cannot.install"])
                    {
                        alertView = [[URBAlertView alloc] initWithTitle:ALERT_TITLE message:@"This device can not be installed at this time." cancelButtonTitle:OK_BTN otherButtonTitles: nil, nil];
                        [alertView setMessageFont:[UIFont fontWithName:CGRegular size:14]];
                        [alertView setHandlerBlock:^(NSInteger buttonIndex, URBAlertView *alertView) {
                            [alertView hideWithCompletionBlock:^{
//                                [self.navigationController popViewControllerAnimated:YES];
                                [self.navigationController popToViewController:[self.navigationController.viewControllers objectAtIndex:0] animated:YES];
                            }];
                        }];
                        [alertView showWithAnimation:URBAlertAnimationTopToBottom];
    if (IS_IPHONE_X){[alertView showWithAnimation:URBAlertAnimationDefault];}
                    }
                    else if ([strErrorCode isEqualToString:@"device.cannot.install.invalid.asset"])
                    {
                        alertView = [[URBAlertView alloc] initWithTitle:ALERT_TITLE message:@"Because of Invalid Asset, Device cannot be installed at this time." cancelButtonTitle:OK_BTN otherButtonTitles: nil, nil];
                        [alertView setMessageFont:[UIFont fontWithName:CGRegular size:14]];
                        [alertView setHandlerBlock:^(NSInteger buttonIndex, URBAlertView *alertView) {
                            [alertView hideWithCompletionBlock:^{
//                                [self.navigationController popViewControllerAnimated:YES];
                                [self.navigationController popToViewController:[self.navigationController.viewControllers objectAtIndex:0] animated:YES];
                            }];
                        }];
                        [alertView showWithAnimation:URBAlertAnimationTopToBottom];
    if (IS_IPHONE_X){[alertView showWithAnimation:URBAlertAnimationDefault];}

                    }
                    else if ([strErrorCode isEqualToString:@"device.state.inconsistent"] || [strErrorCode rangeOfString:@"device.state.inconsistent"].location != NSNotFound)
                    {
                        NSString * strErrorMsg = [NSString stringWithFormat:@"Device %@ is not correctly registered in the system. Please, contact administrator right away.",installScanID];
                        alertView = [[URBAlertView alloc] initWithTitle:ALERT_TITLE message:strErrorMsg cancelButtonTitle:OK_BTN otherButtonTitles: nil, nil];
                        [alertView setMessageFont:[UIFont fontWithName:CGRegular size:14]];
                        [alertView setHandlerBlock:^(NSInteger buttonIndex, URBAlertView *alertView) {
                            [alertView hideWithCompletionBlock:^{
                            }];
                        }];
                        [alertView showWithAnimation:URBAlertAnimationTopToBottom];
    if (IS_IPHONE_X){[alertView showWithAnimation:URBAlertAnimationDefault];}
                    }
                    else if ([strErrorCode isEqualToString:@"Pattern.deviceInstallDto.contactInfo.telephone"])
                    {
                        alertView = [[URBAlertView alloc] initWithTitle:ALERT_TITLE message:@"Please enter Valid Mobile Number" cancelButtonTitle:OK_BTN otherButtonTitles: nil, nil];
                        [alertView setMessageFont:[UIFont fontWithName:CGRegular size:14]];
                        [alertView setHandlerBlock:^(NSInteger buttonIndex, URBAlertView *alertView) {
                            [alertView hideWithCompletionBlock:^{
                            }];
                        }];
                        [alertView showWithAnimation:URBAlertAnimationTopToBottom];
                        if (IS_IPHONE_X){[alertView showWithAnimation:URBAlertAnimationDefault];}
                    }
                    else if ([strErrorCode isEqualToString:@"NotBlank.deviceInspectDto.contactInfo.zipCode"])
                    {
                        alertView = [[URBAlertView alloc] initWithTitle:ALERT_TITLE message:@"Please enter Valid ZipCode" cancelButtonTitle:OK_BTN otherButtonTitles: nil, nil];
                        [alertView setMessageFont:[UIFont fontWithName:CGRegular size:14]];
                        [alertView setHandlerBlock:^(NSInteger buttonIndex, URBAlertView *alertView) {
                            [alertView hideWithCompletionBlock:^{
//                                [self.navigationController popViewControllerAnimated:YES];
                            }];
                        }];
                        [alertView showWithAnimation:URBAlertAnimationTopToBottom];
                        if (IS_IPHONE_X){[alertView showWithAnimation:URBAlertAnimationDefault];}
                    }
                    else
                    {
                        strErrorReport = [NSString stringWithFormat:@"Error is %@", result];
                        [self ErrorMessagePopup];
                    }
                }
                else
                {
                    strErrorReport = [NSString stringWithFormat:@"Error is %@", result];
                    [self ErrorMessagePopup];
                }
            }
            else
            {
                strErrorReport = [NSString stringWithFormat:@"Error is %@", result];
                [self ErrorMessagePopup];
            }
        }
    }
    else if ([[result valueForKey:@"commandName"] isEqualToString:@"SaveInstallSign"])
    {
        NSString * requestStr =[NSString stringWithFormat:@"update tbl_install set server_installer_sign = 1 where id = '%@'",strInstallID];
        [[DataBaseManager dataBaseManager] execute:requestStr];
        [self saveOwnerSignaturesServer];
    }
    else if ([[result valueForKey:@"commandName"] isEqualToString:@"SaveOwnerSign"])
    {
        NSString * requestStr =[NSString stringWithFormat:@"update tbl_install set server_owner_sign = 1 where id = '%@'",strInstallID];
        [[DataBaseManager dataBaseManager] execute:requestStr];
        [self saveInstallationPhotostoServer];
    }
    else if ([[result valueForKey:@"commandName"] isEqualToString:@"SavePhotos"])
    {
        NSString * requestStr =[NSString stringWithFormat:@"update tbl_installer_photo set is_sync = 1 where inst_photo_local_id = '%@'",localImageId];
        [[DataBaseManager dataBaseManager] execute:requestStr];
        [self saveInstallationPhotostoServer];
    }
    else if ([[result valueForKey:@"commandName"] isEqualToString:@"SaveFile"])
    {
        [self CallCompleteServiceforInstallation];
    }
    else if ([[result valueForKey:@"commandName"] isEqualToString:@"SendComplete"])
    {
        [APP_DELEGATE endHudProcess];
        
        NSString * requestStr =[NSString stringWithFormat:@"update tbl_install set is_sync = '1' where id = '%@'",strInstallID];
        [[DataBaseManager dataBaseManager] execute:requestStr];
        
        alertView = [[URBAlertView alloc] initWithTitle:ALERT_TITLE message:@"Installation has been completed successfully." cancelButtonTitle:OK_BTN otherButtonTitles: nil, nil];
        
        [alertView setMessageFont:[UIFont fontWithName:CGRegular size:14]];
        [alertView setHandlerBlock:^(NSInteger buttonIndex, URBAlertView *alertView) {
            [alertView hideWithCompletionBlock:^{
[self.navigationController popToViewController:[self.navigationController.viewControllers objectAtIndex:0] animated:YES];
            }];
        }];
        [alertView showWithAnimation:URBAlertAnimationTopToBottom];
    if (IS_IPHONE_X){[alertView showWithAnimation:URBAlertAnimationDefault];}
    }
    
    else if ([[result valueForKey:@"commandName"] isEqualToString:@"TestDevice"])
    {
        [APP_DELEGATE endHudProcess];

        if ([[[result valueForKey:@"result"] valueForKey:@"response"] isEqualToString:@"true"])
        {
            isTestedAlready = YES;
            if ([[[result valueForKey:@"result"] valueForKey:@"message"] isEqualToString:@"Device already exists with this IMEI!"])
            {
                isAllowtoGoAfterTest = NO;

                NSMutableDictionary * tmpDict = [[NSMutableDictionary alloc] init];
                tmpDict = [[[result valueForKey:@"result"] valueForKey:@"data"] mutableCopy];

                NSString * strMessage = [NSString stringWithFormat:@"This device %@ is already installed somewhere. Please uninstall first and then try again to Install it.",installScanID];
                alertView = [[URBAlertView alloc] initWithTitle:ALERT_TITLE message:strMessage cancelButtonTitle:@"Go to Dashboard" otherButtonTitles: @"View last Installation", nil];
                [alertView setMessageFont:[UIFont fontWithName:CGRegular size:12]];
                [alertView setHandlerBlock:^(NSInteger buttonIndex, URBAlertView *alertView) {
                    [alertView hideWithCompletionBlock:^{
                        
                        if (buttonIndex==0)
                        {
                            [self.navigationController popViewControllerAnimated:YES];
                        }
                        else
                        {
                            TestDeviceVC * testVC = [[TestDeviceVC alloc] init];
                            testVC.detailDict =tmpDict;
                            testVC.strReasonToCome = @"ExistAndSee";
                            [self.navigationController pushViewController:testVC animated:YES];
                        }
                    }];
                }];
                  [alertView showWithAnimation:Alert_Animation_Type];
        if (IS_IPHONE_X) {[alertView showWithAnimation:URBAlertAnimationDefault];}
                
            }
            else if ([[[result valueForKey:@"result"] valueForKey:@"message"] isEqualToString:@"Device not exists with this IMEI!"])
            {
                NSMutableDictionary * tmpDict = [[NSMutableDictionary alloc] init];
                tmpDict = [[result valueForKey:@"result"] valueForKey:@"data"];

                if (tmpDict == [NSNull null] || tmpDict == nil)
                {
                    NSString * strMessage = [NSString stringWithFormat:@"Device not exists with this IMEI!."];
                    alertView = [[URBAlertView alloc] initWithTitle:ALERT_TITLE message:strMessage cancelButtonTitle:@"OK" otherButtonTitles: nil, nil];
                    [alertView setMessageFont:[UIFont fontWithName:CGRegular size:12]];
                    [alertView setHandlerBlock:^(NSInteger buttonIndex, URBAlertView *alertView) {
                        [alertView hideWithCompletionBlock:^{
                        }];
                    }];
                      [alertView showWithAnimation:Alert_Animation_Type];
        if (IS_IPHONE_X) {[alertView showWithAnimation:URBAlertAnimationDefault];}
                }
                else
                {
                    isAllowtoGoAfterTest = YES;
                    
                    if (isFromNextTest)
                    {
                        [self AllowtoMoveforSecondScreen];
                    }
                    else
                    {
                        NSString * strMessage = [NSString stringWithFormat:@"This device %@ is ready to use.",installScanID];
                        alertView = [[URBAlertView alloc] initWithTitle:ALERT_TITLE message:strMessage cancelButtonTitle:OK_BTN otherButtonTitles: @"View last Installation", nil];
                        [alertView setMessageFont:[UIFont fontWithName:CGRegular size:12]];
                        [alertView setHandlerBlock:^(NSInteger buttonIndex, URBAlertView *alertView) {
                            [alertView hideWithCompletionBlock:^{
                                if (buttonIndex==0)
                                {
                                }
                                else
                                {
                                    TestDeviceVC * testVC = [[TestDeviceVC alloc] init];
                                    testVC.detailDict =tmpDict;
                                    testVC.strReasonToCome = @"ReadytoUse";
                                    [self.navigationController pushViewController:testVC animated:YES];
                                }
                            }];
                        }];
                          [alertView showWithAnimation:Alert_Animation_Type];
        if (IS_IPHONE_X) {[alertView showWithAnimation:URBAlertAnimationDefault];}
                    }
                }
            }
        }
        else
        {
            if ([[[result valueForKey:@"result"] valueForKey:@"message"] isEqualToString:@"Invalid Token"])
            {
                [APP_DELEGATE showSessionExpirePopup];
            }
            else if([[[result valueForKey:@"result"] valueForKey:@"message"] isEqualToString:@"Device not exists with this IMEI!"])
            {
                NSMutableDictionary * tmpDict = [[NSMutableDictionary alloc] init];
                tmpDict = [[result valueForKey:@"result"] valueForKey:@"data"];
                
                if (tmpDict == [NSNull null] || tmpDict == nil)
                {
                    isAllowtoGoAfterTest = YES;
                    if (isFromNextTest)
                    {
                        [self AllowtoMoveforSecondScreen];
                    }
                }
                else
                {
                    isAllowtoGoAfterTest = YES;
                    
                    if (isFromNextTest)
                    {
                        [self AllowtoMoveforSecondScreen];
                    }
                    else
                    {
                        NSString * strMessage = [NSString stringWithFormat:@"This device %@ is ready to use.",installScanID];
                        alertView = [[URBAlertView alloc] initWithTitle:ALERT_TITLE message:strMessage cancelButtonTitle:OK_BTN otherButtonTitles: @"View last Installation", nil];
                        [alertView setMessageFont:[UIFont fontWithName:CGRegular size:12]];
                        [alertView setHandlerBlock:^(NSInteger buttonIndex, URBAlertView *alertView) {
                            [alertView hideWithCompletionBlock:^{
                                if (buttonIndex==0)
                                {
                                }
                                else
                                {
                                    TestDeviceVC * testVC = [[TestDeviceVC alloc] init];
                                    testVC.detailDict =tmpDict;
                                    testVC.strReasonToCome = @"ReadytoUse";
                                    [self.navigationController pushViewController:testVC animated:YES];
                                }
                            }];
                        }];
                          [alertView showWithAnimation:Alert_Animation_Type];
        if (IS_IPHONE_X) {[alertView showWithAnimation:URBAlertAnimationDefault];}
                    }
                }
            }
        }
    }
}
- (void)onError:(NSError *)error
{
    [APP_DELEGATE endHudProcess];
    
    NSLog(@"The error is...%@", error);
    NSInteger ancode = [error code];
    
    NSMutableDictionary * errorDict = [error.userInfo mutableCopy];
    NSLog(@"errorDict===%@",errorDict);
    
    if ([[errorDict valueForKey:@"NSLocalizedDescription"] isEqualToString:@"The request timed out."])
    {
        [APP_DELEGATE ShowErrorPopUpWithErrorCode:customErrorCodeForMessage andMessage:@"Please try again later"];
    }
    else
    {
        if (ancode == -1001 || ancode == -1004 || ancode == -1005 || ancode == -1009)
        {
            [APP_DELEGATE ShowErrorPopUpWithErrorCode:ancode andMessage:@""];
        }
        else
        {
            [APP_DELEGATE ShowErrorPopUpWithErrorCode:customErrorCodeForMessage andMessage:@"Please try again later"];
        }
    }
    NSString * strLoginUrl = [NSString stringWithFormat:@"%@%@",WEB_SERVICE_URL,@"token.json"];
    if ([[errorDict valueForKey:@"NSErrorFailingURLStringKey"] isEqualToString:strLoginUrl])
    {
        NSLog(@"NSErrorFailingURLStringKey===%@",[errorDict valueForKey:@"NSErrorFailingURLStringKey"]);
    }
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
-(void)getVesselsfromSuccorfishServer
{
    if ([APP_DELEGATE isNetworkreachable])
    {
        [APP_DELEGATE endHudProcess];
        [APP_DELEGATE startHudProcess:@"Getting details..."];
    }
    
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0ul);
    dispatch_async(queue, ^{
        {
            NSMutableDictionary *args = [[NSMutableDictionary alloc] init];
            NSString * strUrl = [NSString stringWithFormat:@"https://ws.scstg.net/basic/v2/asset/getForAccountWithoutDevice/%@",strAccountID];
            
            NSString * strbasicAuthToken;
            NSString * strUserName = [NSString stringWithFormat:@"%@",CURRENT_USER_EMAIL];
            NSString * strPassword = [NSString stringWithFormat:@"%@",CURRENT_USER_PASS];
            
            NSString * str = [NSString stringWithFormat:@"%@:%@",strUserName,strPassword];
            NSString * simpleStr = [APP_DELEGATE base64String:str];
            strbasicAuthToken = simpleStr;
            
            AFHTTPRequestOperationManager *manager1 = [[AFHTTPRequestOperationManager alloc] initWithBaseURL:[NSURL URLWithString:@"http://server.url"]];
            NSString *authorization = [NSString stringWithFormat: @"Basic %@",strbasicAuthToken];
            [manager1.requestSerializer setValue:authorization forHTTPHeaderField:@"Authorization"];
            [manager1.requestSerializer setValue:strAccountID forHTTPHeaderField:@"ManagedAccountId"];
            
            AFHTTPRequestOperation *op = [manager1 GET:strUrl parameters:args success:^(AFHTTPRequestOperation *operation, id responseObject){
                
                NSLog(@"========> Asset Account without device Success Response with Result=%@",responseObject);
                
                [APP_DELEGATE endHudProcess];
                
                NSMutableArray * dictID = [[NSMutableArray alloc] init];
                dictID = [responseObject mutableCopy];
                
                NSString * strDelete = [NSString stringWithFormat:@"delete from tbl_vessel_extra"];
                [[DataBaseManager dataBaseManager] execute:strDelete];
                [[DataBaseManager dataBaseManager] SaveVesselinExtraTable:dictID];
                
            }
                                               failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                                   if (error) {
                                                       
                                                       [APP_DELEGATE endHudProcess];
                                                       
                                                       NSLog(@"Servicer error = %@", error);
                                                       [APP_DELEGATE endHudProcess];
                                                       
                                                       alertView = [[URBAlertView alloc] initWithTitle:ALERT_TITLE message:@"Something went wrong. Please try again." cancelButtonTitle:OK_BTN otherButtonTitles: nil, nil];
                                                       [alertView setMessageFont:[UIFont fontWithName:CGRegular size:14]];
                                                       [alertView setHandlerBlock:^(NSInteger buttonIndex, URBAlertView *alertView) {
                                                           [alertView hideWithCompletionBlock:
                                                            ^{

                                                            }];
                                                       }];
                                                       [alertView showWithAnimation:URBAlertAnimationTopToBottom];
    if (IS_IPHONE_X){[alertView showWithAnimation:URBAlertAnimationDefault];}                                                   }
                                               }];
            [op start];
        }
        // Perform async operation
        // Call your method/function here
        // Example:
        dispatch_sync(dispatch_get_main_queue(), ^{
            //Method call finish here
        });
    });
}
-(void)testDevice3rdScreen:(NSMutableDictionary *)dict3rdScreenData
{
    if ([dict3rdScreenData isKindOfClass:[NSDictionary class]])
    {
        NSMutableDictionary * dictID = [[NSMutableDictionary alloc] init];
        dictID = [dict3rdScreenData mutableCopy];
        NSString * strGeneratDate = [NSString stringWithFormat:@"%@",[dictID valueForKey:@"generatedDate"]];
        
        if ([[self checkforValidString:strGeneratDate] isEqualToString:@"NA"])
        {
            NSMutableDictionary * dtaliDict = [[NSMutableDictionary alloc] init];
            [dtaliDict setObject:strGeneratDate forKey:@"date"];
            [dtaliDict setObject:[NSString stringWithFormat:@"%@",[dictID valueForKey:@"lat"]] forKey:@"latitude"];
            [dtaliDict setObject:[NSString stringWithFormat:@"%@",[dictID valueForKey:@"lng"]] forKey:@"longitude"];
        }
        else
        {
            NSString *mainStr = strGeneratDate;
            NSString * newString = [mainStr substringToIndex:[mainStr length]-3];
            
            double unixTimeStamp = [newString doubleValue];
            NSTimeInterval _interval=unixTimeStamp;
            NSDate *date = [NSDate dateWithTimeIntervalSince1970:_interval];
            NSDateFormatter *_formatter=[[NSDateFormatter alloc]init];
            NSTimeZone *gmt = [NSTimeZone localTimeZone];
            
            [_formatter setTimeZone:gmt];
            [_formatter setDateFormat:[NSString stringWithFormat:@"dd-MM-YYYY HH:mm"]];
            //            NSString *_date = [APP_DELEGATE checkforValidString:[NSString stringWithFormat:@"%@",[_formatter stringFromDate:date]]];
            NSString *_date = [self checkforValidString:[NSString stringWithFormat:@"%@",[_formatter stringFromDate:date]]];
            
            
            NSString * strDates = [self checkforValidString:_date];
            NSString * strInfoMsg, * strStatus ;
            
            NSIndexPath * nowIndex = [NSIndexPath indexPathForRow:7 inSection:0];
            NewInstallCell *cell = [tblthirdView cellForRowAtIndexPath:nowIndex];
            if ([self GetdifferencebetweenFirstDate:date] == YES)
            {
                strInfoMsg = @"READY TO GO!";
                strStatus = @"Yes";
                cell.lblPositionMsg.text = strInfoMsg;
                cell.lblPositionMsg.textColor = UIColor.greenColor;
            }
            else
            {
                strInfoMsg = @"No position report in last 2 hours.";
                strStatus = @"No";
                cell.lblPositionMsg.text = strInfoMsg;
                cell.lblPositionMsg.textColor = UIColor.redColor;
            }
            
            cell.lblLastReport.textColor = UIColor.whiteColor;
            cell.lblLastReport.text = [NSString stringWithFormat:@"Last report : %@",[self checkforValidString:strDates]];
            [tblthirdView reloadData];
        }
    }
    
}
-(BOOL )GetdifferencebetweenFirstDate:(NSDate *)serverDate
{
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
    
    BOOL isOntime = NO;
    
    if (compenents.year < currentDateComponents.year)
    {
        return isOntime;
    }
    else if (compenents.month < currentDateComponents.month)
    {
        return isOntime;
    }
    else if (compenents.day < currentDateComponents.day)
    {
        return isOntime;
    }
    else if (compenents.hour < currentDateComponents.hour)
    {
        NSString * strReturn = [NSString stringWithFormat:@"%i",(currentDateComponents.hour - compenents.hour)];
        if ([strReturn isEqualToString:@"1"])
        {
            isOntime = YES;
            return isOntime;
        }
        else
        {
            isOntime = NO;
            return isOntime;
        }
    }
    else
    {
        return YES;
    }
}
//Method writes a string to a text file
-(NSString*)writeToTextFile
{
    NSMutableArray * arrayHandS = [[NSMutableArray alloc] init];
    NSString * strQuery = [NSString stringWithFormat:@"select * from tbl_question where install_id = '%@' and type = 'install'",strInstallID];
    [[DataBaseManager dataBaseManager] execute:strQuery resultsArray:arrayHandS];
    NSString *fileName = @"NA";
    if ([arrayHandS count]>0)
    {
        //get the documents directory:
        NSArray *paths = NSSearchPathForDirectoriesInDomains
        (NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentsDirectory = [paths objectAtIndex:0];
        
        //make a file name to write the data to using the documents directory:
        fileName = [NSString stringWithFormat:@"%@/HealthNSafety.txt",
                              documentsDirectory];
        
        NSString * content = [NSString stringWithFormat:@"=============================================================================\r\nInstaller Health and Safety Questionnaire\r\n============================================================================="];
        //Q1
        //create content - four lines of text
        NSString * question1 = @"\r\n\r\nQ1: Are you wearing the prescribed PPE (including lifejacket if working near water)?";
        NSString * answer1 = [NSString stringWithFormat: @"\r\nANSWER: %@",[[arrayHandS objectAtIndex:0]valueForKey:@"q1"]];
        NSString * reason1;
        if ([[[arrayHandS objectAtIndex:0]valueForKey:@"q1ans"] isEqualToString:@"YES"] || [[[arrayHandS objectAtIndex:0]valueForKey:@"q1ans"] isEqualToString:@"NA"])
        {
            reason1 = @"";
        }
        else
        {
            reason1 = [NSString stringWithFormat: @"\r\nREASON : %@",[[arrayHandS objectAtIndex:0]valueForKey:@"q1ans"]];
        }
        answer1 = [question1 stringByAppendingString:answer1];
        content = [content stringByAppendingString:[answer1 stringByAppendingString:reason1]];
        
        //save content to the documents directory
        
        
        //Q2
        NSString * question2 = @"\r\n\r\nQ2: Have you completed your equipment pre-inspection?";
        NSString * answer2 = [NSString stringWithFormat: @"\r\nANSWER: %@",[[arrayHandS objectAtIndex:0]valueForKey:@"q2"]];
        NSString * reason2;
        if ([[[arrayHandS objectAtIndex:0]valueForKey:@"q2ans"] isEqualToString:@"YES"] || [[[arrayHandS objectAtIndex:0]valueForKey:@"q2ans"] isEqualToString:@"NA"])
        {
            reason2 = @"";
        }
        else
        {
            reason2 = [NSString stringWithFormat: @"\r\nREASON : %@",[[arrayHandS objectAtIndex:0]valueForKey:@"q2ans"]];
        }
        answer2 = [question2 stringByAppendingString:answer2];
        content = [content stringByAppendingString:[answer2 stringByAppendingString:reason2]];

        //Q3
        NSString * question3 = @"\r\n\r\nQ3: Have you completed your pre-inspection for working at height?";
        NSString * answer3 = [NSString stringWithFormat: @"\r\nANSWER: %@",[[arrayHandS objectAtIndex:0]valueForKey:@"q3"]];
        NSString * reason3 ;
        if ([[[arrayHandS objectAtIndex:0]valueForKey:@"q3ans"] isEqualToString:@"YES"] || [[[arrayHandS objectAtIndex:0]valueForKey:@"q3ans"] isEqualToString:@"NA"])
        {
            reason3 = @"";
        }
        else
        {
            reason3 = [NSString stringWithFormat: @"\r\nREASON : %@",[[arrayHandS objectAtIndex:0]valueForKey:@"q3ans"]];
        }
        answer3 = [question3 stringByAppendingString:answer3];
        content = [content stringByAppendingString:[answer3 stringByAppendingString:reason3]];
        
        //Q4
        NSString * question4 = @"\r\n\r\nQ4: Have you reviewed the installation for Asbestos risk?";
        NSString * answer4 = [NSString stringWithFormat: @"\r\nANSWER: %@",[[arrayHandS objectAtIndex:0]valueForKey:@"q4"]];
        NSString * reason4;
        if ([[[arrayHandS objectAtIndex:0]valueForKey:@"q4ans"] isEqualToString:@"YES"] || [[[arrayHandS objectAtIndex:0]valueForKey:@"q4ans"] isEqualToString:@"NA"])
        {
            reason4 = @"";
        }
        else
        {
            reason4 = [NSString stringWithFormat: @"\r\nREASON : %@",[[arrayHandS objectAtIndex:0]valueForKey:@"q4ans"]];
        }
        answer4 = [question4 stringByAppendingString:answer4];
        content = [content stringByAppendingString:[answer4 stringByAppendingString:reason4]];
        
        //Q5
        NSString * question5 = @"\r\n\r\nQ5: Do you require service isolation?";
        NSString * answer5 = [NSString stringWithFormat: @"\r\nANSWER: %@",[[arrayHandS objectAtIndex:0]valueForKey:@"q5"]];
        NSString * reason5;
        if ([[[arrayHandS objectAtIndex:0]valueForKey:@"q5ans"] isEqualToString:@"YES"] || [[[arrayHandS objectAtIndex:0]valueForKey:@"q5ans"] isEqualToString:@"NA"])
        {
            reason5 = @"";
        }
        else
        {
            reason5 = [NSString stringWithFormat: @"\r\nREASON : %@",[[arrayHandS objectAtIndex:0]valueForKey:@"q5ans"]];
        }
        answer5 = [question5 stringByAppendingString:answer5];
        content = [content stringByAppendingString:[answer5 stringByAppendingString:reason5]];
        
        //Q6
        NSString * question6 = @"\r\n\r\nQ6: Please select hazard from the list below and describe additional precaution taken not listed in the Succorfish Risk Assessment?";
        NSString * answer6 = [NSString stringWithFormat: @"\r\nANSWER: %@",[[arrayHandS objectAtIndex:0]valueForKey:@"q6"]];
        NSString * reason6;
        if ([[[arrayHandS objectAtIndex:0]valueForKey:@"q6ans"] isEqualToString:@"YES"] || [[[arrayHandS objectAtIndex:0]valueForKey:@"q6ans"] isEqualToString:@"NA"])
        {
            reason6 = @"";
        }
        else
        {
            reason6 = [NSString stringWithFormat: @"\r\nREASON : %@",[[arrayHandS objectAtIndex:0]valueForKey:@"q6ans"]];
        }
        answer6 = [question6 stringByAppendingString:answer6];
        content = [content stringByAppendingString:[answer6 stringByAppendingString:reason6]];
        
        [content writeToFile:fileName
                  atomically:NO
                    encoding:NSStringEncodingConversionAllowLossy
                       error:nil];
    }
    
    return fileName;
}
/*
// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
