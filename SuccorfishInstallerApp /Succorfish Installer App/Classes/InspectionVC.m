//
//  InspectionVC.m
//  Succorfish Installer App
//
//  Created by stuart watts on 06/03/2018.
//  Copyright © 2018 Kalpesh Panchasara. All rights reserved.
//

#import "InspectionVC.h"
#import "PSProfileStepper.h"
#import "BarcodeScanVC.h"
#import "TestDeviceVC.h"
#import "VesselVC.h"
#import "PhotoView.h"
#import "MapClassVC.h"
#import <MessageUI/MessageUI.h>
#import "LastWaypointVC.h"
#import "SignVC.h"
#import "InspectionCell.h"
@interface InspectionVC ()<UITextViewDelegate,MFMailComposeViewControllerDelegate,URLManagerDelegate>
{
    PSProfileStepper *stepperView;
    int indexOne;
    BOOL isSecondBuilt, isThirdBuilt, isInstalledDetailSynced,isAgreed;
    NSString * strInstallID, * serverInstallationID, * localImageId;
    int intInstallID;
    UIImageView * imgCheck;
    NSMutableDictionary * lastLocationDict;
    NSString * strInstallerSignUrl, * strOwnerSignUrl;
    NSString * strAcionServerValue, * strActionServerName;
    BOOL isTestDeviceDone;
    URBAlertView *alertView;
}
@end

@implementation InspectionVC
@synthesize isFromeEdit,detailDict,installID;
- (void)viewDidLoad
{
    strInstallID = installID;
    installScanID = @"";
    indexOne = 0;
    strInstallerSignUrl = @"NA";
    strOwnerSignUrl = @"NA";
    isTestDeviceDone = NO;
    UIImageView * imgBack = [[UIImageView alloc] init];
    imgBack.frame = CGRectMake(0, 0, DEVICE_WIDTH, DEVICE_HEIGHT);
    imgBack.image = [UIImage imageNamed:@"Splash_bg.png"];
    imgBack.userInteractionEnabled = YES;
    [self.view addSubview:imgBack];
    
    deviceTypeArr = [[NSMutableArray alloc] init];
    [deviceTypeArr addObject:@"SC2"];
    
    actionArr = [[NSMutableArray alloc] init];
    NSArray * actArr = [NSArray arrayWithObjects:@"None",@"Repair",@"Replace out of warranty",@"Replace under warranty", nil];
    NSArray * arrValuesAct = [NSArray arrayWithObjects:@"INSPECTION",@"REPAIR",@"REPLACE_OUT_OF_WARRANTY",@"REPLACE_UNDER_WARRANTY", nil];

    for (int i=0; i<[actArr count]; i++)
    {
        NSMutableDictionary * actDicts = [[NSMutableDictionary alloc] init];
        [actDicts setObject:[actArr objectAtIndex:i] forKey:@"name"];
        [actDicts setObject:[arrValuesAct objectAtIndex:i] forKey:@"value"];
        [actionArr addObject:actDicts];
    }
    
    if (isFromeEdit)
    {
        strInstallID = [self checkforValidString:[detailDict valueForKey:@"id"]];
        strSuccorfishDeviceID = [self checkforValidString:[detailDict valueForKey:@"succor_device_id"]];
        strActionServerName = [self checkforValidString:[detailDict valueForKey:@"insp_action_taken"]];
        strAcionServerValue = [self checkforValidString:[detailDict valueForKey:@"actionvalue"]];

        if (![strInstallID isEqualToString:@"NA"])
        {
            intInstallID = [strInstallID intValue];
        }
        
        NSMutableArray * tmpArr = [[NSMutableArray alloc] init];
        NSString * str = [NSString stringWithFormat:@"select * from tbl_inspection_photo where insp_local_id='%@' and insp_photo_user_id='%@'",strInstallID,CURRENT_USER_ID];
        [[DataBaseManager dataBaseManager] execute:str resultsArray:tmpArr];
        installPhotoCounts = [NSString stringWithFormat:@"%lu",(unsigned long)[tmpArr count]];
    }
    else
    {
        detailDict = [[NSMutableDictionary alloc] init];
    }
    firstViewArray = [[NSMutableArray alloc]init];
    NSArray * arrayTitleFirst = [[NSArray alloc]initWithObjects:@"Scan Device",@"Device Type",@"Asset Name",@"Registration No.",@"Warranty Status",@"Test Device", nil];
    for (int i=0; i<arrayTitleFirst.count; i++)
    {
        NSMutableDictionary *tmpDict = [[NSMutableDictionary alloc]initWithObjectsAndKeys:[arrayTitleFirst objectAtIndex:i],@"title",@"NA",@"value", nil];
        [firstViewArray addObject:tmpDict];
    }
    
    secondViewArray = [[NSMutableArray alloc]init];
    NSArray * arrayTitleSecond = [[NSArray alloc]initWithObjects:@"Owner Name",@"Address",@"City",@"State",@"Email",@"Mobile No.",nil];
    for (int i=0; i<arrayTitleSecond.count; i++)
    {
        NSMutableDictionary *tmpDict = [[NSMutableDictionary alloc]initWithObjectsAndKeys:[arrayTitleSecond objectAtIndex:i],@"title",@"NA",@"value", nil];
        [secondViewArray addObject:tmpDict];
    }
    [[secondViewArray objectAtIndex:3]setValue:@"NA" forKey:@"zipValue"];
    arrayTextFieldTagValues = [[NSArray alloc]initWithObjects:@"101",@"102",@"103",@"104",@"106",@"107", nil];
    
    thirdViewArray = [[NSMutableArray alloc]init];
    NSArray * arrayTitleThird = [[NSArray alloc]initWithObjects:@"Add Inspection Photos",@"Action taken",@"Signatures",@"Test Device", nil];
    for (int i=0; i<arrayTitleThird.count; i++)
    {
        NSMutableDictionary *tmpDict = [[NSMutableDictionary alloc]initWithObjectsAndKeys:[arrayTitleThird objectAtIndex:i],@"title",@"NA",@"value", nil];
        [thirdViewArray addObject:tmpDict];
    }

    [self setNavigationViewFrames];
    [self setContentViews];
    [self setFirstView];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"DeviceInfoForInspection" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(fillDeviceDetails:) name:@"DeviceInfoForInspection" object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"setSignaturePathsforInspections" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(SetSignPaths:) name:@"setSignaturePathsforInspections" object:nil];

    

    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

-(void)viewWillAppear:(BOOL)animated
{
    [APP_DELEGATE hideTabBar:self.tabBarController];
    [self checkForAppearFields];
    [super viewWillAppear:YES];
    
}
#pragma mark - Fill device details
-(void)fillDeviceDetails:(NSNotification *)notify
{
    NSMutableDictionary * tmpDict = [[NSMutableDictionary alloc] init];
    tmpDict = [notify object];
    detailDict = [tmpDict mutableCopy];
    if ([[detailDict valueForKey:@"DataAvail"] isEqualToString:@"Yes"])
    {
        installScanID = [detailDict valueForKey:@"imei"];
        installVesselName = [self checkforValidString:[detailDict valueForKey:@"vesselname"]];
        installedVesselID = [self checkforValidString:[detailDict valueForKey:@"vessel_id"]];
        installRegi = [self checkforValidString:[detailDict valueForKey:@"portno"]];
//        txtWarranty.text = [self checkforValidStringForEdit:[detailDict valueForKey:@"warranty"]];

        if (firstViewArray.count >= 5)
        {
            [[firstViewArray objectAtIndex:0] setValue:[self checkforValidStringForEdit:[detailDict valueForKey:@"imei"]] forKey:@"value"];
            [[firstViewArray objectAtIndex:1] setValue:[self checkforValidStringForEdit:[detailDict valueForKey:@"device_type"]] forKey:@"value"];
            [[firstViewArray objectAtIndex:2] setValue:[self checkforValidStringForEdit:[detailDict valueForKey:@"vesselname"]] forKey:@"value"];
            [[firstViewArray objectAtIndex:3] setValue:[APP_DELEGATE checkforValidString:[detailDict valueForKey:@"portno"]] forKey:@"value"];
            [[firstViewArray objectAtIndex:4] setValue:[self checkforValidStringForEdit:[detailDict valueForKey:@"warranty"]] forKey:@"value"];
        }
        

        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"YYYY-MM-dd HH:mm"];
        NSDate *currentDate = [NSDate date];
        NSDate * resultDate = [formatter dateFromString:[self checkforValidStringForEdit:[detailDict valueForKey:@"warranty"]]];
    
        
        NSString * strActionTakens  = [self checkforValidStringForEdit:[detailDict valueForKey:@"insp_action_taken"]];
        for (int i = 0; i<[actionArr count]; i++)
        {
            if ([[[actionArr objectAtIndex:i] valueForKey:@"value"] isEqualToString:strActionTakens])
            {
                strAcionServerValue = [[actionArr objectAtIndex:i] valueForKey:@"value"];
                strActionServerName = [[actionArr objectAtIndex:i] valueForKey:@"name"];
            }
        }
        
        if (isSecondBuilt)
        {
            if (secondViewArray.count >= 5)
            {
                [[secondViewArray objectAtIndex:0]setValue:[self checkforValidStringForEdit:[detailDict valueForKey:@"owner_name"]] forKey:@"value"];
                [[secondViewArray objectAtIndex:1]setValue:[self checkforValidStringForEdit:[detailDict valueForKey:@"owner_address"]] forKey:@"value"];
                [[secondViewArray objectAtIndex:2]setValue:[self checkforValidStringForEdit:[detailDict valueForKey:@"owner_city"]] forKey:@"value"];
                [[secondViewArray objectAtIndex:3]setValue:[self checkforValidStringForEdit:[detailDict valueForKey:@"owner_state"]] forKey:@"value"];
                [[secondViewArray objectAtIndex:3]setValue:[self checkforValidStringForEdit:[detailDict valueForKey:@"owner_zipcode"]] forKey:@"zipValue"];
                [[secondViewArray objectAtIndex:4]setValue:[self checkforValidStringForEdit:[detailDict valueForKey:@"owner_email"]] forKey:@"value"];
                [[secondViewArray objectAtIndex:5]setValue:[self checkforValidStringForEdit:[detailDict valueForKey:@"owner_phone_no"]] forKey:@"value"];

                [tblSecondView reloadData];
            }
            
        }
        
        if (isThirdBuilt)
        {
            NSString * strActionTakens  = [self checkforValidStringForEdit:[detailDict valueForKey:@"insp_action_taken"]];
            txtResult.text = [self checkforValidStringForEdit:[detailDict valueForKey:@"insp_result"]];
            
            [[thirdViewArray objectAtIndex:0]setValue:[self checkforValidString:installPhotoCounts] forKey:@"value"];
            [[thirdViewArray objectAtIndex:1]setValue:@"" forKey:@"value"];

            for (int i = 0; i<[actionArr count]; i++)
            {
                if ([[[actionArr objectAtIndex:i] valueForKey:@"value"] isEqualToString:strActionTakens])
                {
                    [[thirdViewArray objectAtIndex:1]setValue:[self checkforValidString:[[actionArr objectAtIndex:i] valueForKey:@"name"]] forKey:@"value"];

                    strAcionServerValue = [[actionArr objectAtIndex:i] valueForKey:@"value"];
                    strActionServerName = [[actionArr objectAtIndex:i] valueForKey:@"name"];
                }
            }
            [tblThirdView reloadData];
        }
        [tblFirstView reloadData];
    }
    else
    {
        
    }
   
}
#pragma mark - Set Frames
-(void)setNavigationViewFrames
{
    UIView * viewHeader = [[UIView alloc] initWithFrame:CGRectMake(0, 0, DEVICE_WIDTH, 64)];
    [viewHeader setBackgroundColor:[UIColor blackColor]];
    [self.view addSubview:viewHeader];
    
    UILabel * lblTitle = [[UILabel alloc] initWithFrame:CGRectMake(50, 20, DEVICE_WIDTH-100, 44)];
    [lblTitle setBackgroundColor:[UIColor clearColor]];
    [lblTitle setText:@"Inspection"];
    [lblTitle setTextAlignment:NSTextAlignmentCenter];
    [lblTitle setFont:[UIFont fontWithName:CGRegular size:17]];
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
        btnBack.frame = CGRectMake(0, 20, 70, 84);
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
        scrlContent.frame=CGRectMake(0, 109, DEVICE_WIDTH, DEVICE_HEIGHT-109);
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
    moveBackBtn.titleLabel.font =[UIFont fontWithName:CGRegular size:fontSize];
    moveBackBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    [self.view addSubview:moveBackBtn];
    
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
    
    int textSize = 16;
    int yy = 50;
    if (IS_IPHONE_4)
    {
        yy = 20;
    }
    else
    {
        yy = 50;
    }
    if (IS_IPHONE_4 || IS_IPHONE_5)
    {
        textSize = 14;
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
//    if (isFromeEdit)
    {
        installScanID = [detailDict valueForKey:@"imei"];
        installVesselName = [self checkforValidString:[detailDict valueForKey:@"vesselname"]];
        installedVesselID = [self checkforValidString:[detailDict valueForKey:@"vessel_id"]];
        installRegi = [self checkforValidString:[detailDict valueForKey:@"portno"]];
        
        if (firstViewArray.count >= 5)
        {
            [[firstViewArray objectAtIndex:0]setValue:[self checkforValidStringForEdit:[detailDict valueForKey:@"imei"]] forKey:@"value"];
            [[firstViewArray objectAtIndex:1]setValue:[self checkforValidStringForEdit:[detailDict valueForKey:@"device_type"]] forKey:@"value"];
            [[firstViewArray objectAtIndex:2]setValue:[self checkforValidStringForEdit:[detailDict valueForKey:@"vesselname"]] forKey:@"value"];
            [[firstViewArray objectAtIndex:3]setValue:[APP_DELEGATE checkforValidString:[detailDict valueForKey:@"portno"]] forKey:@"value"];
            [[firstViewArray objectAtIndex:4]setValue:[self checkforValidStringForEdit:[detailDict valueForKey:@"warranty"]] forKey:@"value"];
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
-(void)setsecondView
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
        secondView.scrollEnabled = NO;
        secondView.bounces = YES;
        
        if (IS_IPHONE_5)
        {
            [secondView setContentSize:CGSizeMake(DEVICE_WIDTH, scrlContent.frame.size.height+100)];
        }
        else
        {
            [secondView setContentSize:CGSizeMake(DEVICE_WIDTH, scrlContent.frame.size.height+150)];
        }
    }
    
    
    int yy = 50;
    int textSize = 16;
    
    if (IS_IPHONE_4)
    {
        textSize = 15;
        yy = 20;
    }
    else if(IS_IPHONE_5)
    {
        textSize = 15;
        yy = 20;
    }

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

//    if (isFromeEdit)
    {
        if (secondViewArray.count >= 5)
        {
            [[secondViewArray objectAtIndex:0]setValue:[self checkforValidStringForEdit:[detailDict valueForKey:@"owner_name"]] forKey:@"value"];
            [[secondViewArray objectAtIndex:1]setValue:[self checkforValidStringForEdit:[detailDict valueForKey:@"owner_address"]] forKey:@"value"];
            [[secondViewArray objectAtIndex:2]setValue:[self checkforValidStringForEdit:[detailDict valueForKey:@"owner_city"]] forKey:@"value"];
            [[secondViewArray objectAtIndex:3]setValue:[self checkforValidStringForEdit:[detailDict valueForKey:@"owner_state"]] forKey:@"value"];
            [[secondViewArray objectAtIndex:3]setValue:[self checkforValidStringForEdit:[detailDict valueForKey:@"owner_zipcode"]] forKey:@"zipValue"];
            [[secondViewArray objectAtIndex:4]setValue:[self checkforValidStringForEdit:[detailDict valueForKey:@"owner_email"]] forKey:@"value"];
            [[secondViewArray objectAtIndex:5]setValue:[self checkforValidStringForEdit:[detailDict valueForKey:@"owner_phone_no"]] forKey:@"value"];

            [tblSecondView reloadData];
        }
    }
  

}

#pragma mark - Third view Set up
-(void)setThirdView
{
    [thirdView removeFromSuperview];
    thirdView = [[UIScrollView alloc] init];
    thirdView.frame = CGRectMake(DEVICE_WIDTH*2, 0, DEVICE_WIDTH, scrlContent.frame.size.height);
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
        thirdView.scrollEnabled = NO;
        thirdView.bounces = YES;
        
        if (IS_IPHONE_5)
        {
            [thirdView setContentSize:CGSizeMake(DEVICE_WIDTH, scrlContent.frame.size.height+100)];
        }
        else
        {
            [thirdView setContentSize:CGSizeMake(DEVICE_WIDTH, scrlContent.frame.size.height+150)];
        }
    }
    
    
    int yy = 40;
    int fixedH = 50;
    if (IS_IPHONE_4)
    {
        yy = 20;
        fixedH = 40;
    }
    
    int textSize = 16;
    int textHeight = 50;
    int gapB = 5;
    
    if (IS_IPHONE_4 || IS_IPHONE_5)
    {
        textSize = 15;
        textHeight = 50;
        gapB = 0;
    }
    
    UILabel * lblBackResult = [[UILabel alloc] init];
    lblBackResult.frame = CGRectMake(15, yy, thirdView.frame.size.width-30, 130);
    lblBackResult.backgroundColor = [UIColor blackColor];
    lblBackResult.layer.cornerRadius = 20;
    lblBackResult.layer.masksToBounds = YES;
    lblBackResult.userInteractionEnabled = YES;
    [thirdView addSubview:lblBackResult];

    txtResult = [[UITextView alloc] init];
    txtResult.frame = CGRectMake(25, yy+30, thirdView.frame.size.width-50, 100);
    txtResult.backgroundColor = [UIColor clearColor];
    txtResult.delegate = self;
    txtResult.autocapitalizationType = UITextAutocapitalizationTypeNone;
    txtResult.textColor = [UIColor whiteColor];
    [txtResult setFont:[UIFont fontWithName:CGRegular size:textSize]];
    txtResult.autocorrectionType = UITextAutocorrectionTypeNo;
    txtResult.returnKeyType = UIReturnKeyNext;
    txtResult.layer.cornerRadius = 20;
    txtResult.layer.masksToBounds = YES;
    [thirdView addSubview:txtResult];
    
    UILabel * lblTitle4 = [[UILabel alloc] init];
    lblTitle4.frame = CGRectMake(20, yy, DEVICE_WIDTH-10, 25);
    lblTitle4.backgroundColor = [UIColor clearColor];
    lblTitle4.text = @" Inspection result - Type your findings here";
    lblTitle4.font = [UIFont fontWithName:CGRegular size:textSize-1];
    lblTitle4.layer.cornerRadius = 15;
    lblTitle4.layer.masksToBounds = YES;
    lblTitle4.textColor = [UIColor whiteColor];
    
    [thirdView addSubview:lblTitle4];
    
    if (IS_IPHONE_5 || IS_IPHONE_4)
    {
        lblBackResult.frame = CGRectMake(15, yy, thirdView.frame.size.width-30, 110);
        txtResult.frame = CGRectMake(20, yy+20, thirdView.frame.size.width-40, 90);
        lblTitle4.frame = CGRectMake(20, yy, DEVICE_WIDTH-10, 20);
        yy = yy + gapB + 110;
    }
    else if (IS_IPHONE_X)
    {
        lblBackResult.frame = CGRectMake(15, yy, thirdView.frame.size.width-30, 180);
        txtResult.frame = CGRectMake(20, yy+30, thirdView.frame.size.width-40, 150);
        yy = yy + gapB + 180;
    }
    else
    {
        lblBackResult.frame = CGRectMake(15, yy, thirdView.frame.size.width-30, 130);
        txtResult.frame = CGRectMake(20, yy+20, thirdView.frame.size.width-40, 110);
        yy = yy + gapB + 130;
    }
    
    UIBezierPath *shadowPath = [UIBezierPath bezierPathWithRect:lblBackResult.bounds];
    lblBackResult.layer.masksToBounds = NO;
    lblBackResult.layer.shadowColor = [UIColor grayColor].CGColor;
    lblBackResult.layer.shadowOffset = CGSizeMake(0.0f, 1.0f);
    lblBackResult.layer.shadowOpacity = 0.5f;
    lblBackResult.layer.shadowPath = shadowPath.CGPath;
    
    //Device Photos
    /*
    

    lblLastReport = [[UILabel alloc] init];
    lblLastReport.frame = CGRectMake(110, 32, lblTestDevice.frame.size.width-130, 15);
    lblLastReport.backgroundColor = [UIColor clearColor];
    lblLastReport.numberOfLines = 1;
    lblLastReport.font = [UIFont fontWithName:CGRegular size:textSize-3];
     lblLastReport.textColor = [UIColor whiteColor];
    lblLastReport.userInteractionEnabled = YES;
    lblLastReport.textAlignment = NSTextAlignmentCenter;
    lblLastReport.hidden = false;
    lblLastReport.text = @"Last Report : NA";
    [lblTestDevice addSubview:lblLastReport];

    */
    txtResult.text = [self checkforValidStringForEdit:[detailDict valueForKey:@"insp_result"]];
    strInstallerSignUrl = [self checkforValidString:[detailDict valueForKey:@"local_installer_sign"]];
    strOwnerSignUrl = [self checkforValidString:[detailDict valueForKey:@"local_owner_sign"]] ;
     
    [[thirdViewArray objectAtIndex:0]setValue:[self checkforValidString:installPhotoCounts] forKey:@"value"];
    [[thirdViewArray objectAtIndex:1]setValue:[self checkforValidStringForEdit:strActionServerName] forKey:@"value"];

    [tblThirdView reloadData];
    
    int zz = scrlContent.frame.origin.y+(45*approaxSize);
    if (IS_IPHONE_X)
    {
        zz = scrlContent.frame.origin.y+(45*approaxSize)+40;
    }
    tblThirdView = [[UITableView alloc]init];
    tblThirdView.backgroundColor = UIColor.clearColor;
    tblThirdView.frame = CGRectMake(0, yy, DEVICE_WIDTH, DEVICE_HEIGHT-yy-zz-10);
    tblThirdView.delegate = self;
    tblThirdView.dataSource = self;
    tblThirdView.scrollEnabled = false;
    tblThirdView.separatorStyle = UITableViewCellSelectionStyleNone;
    [thirdView addSubview:tblThirdView];
}
-(void)setTermsConditions:(int)withY
{
    int textSize = 16;
    
    if (IS_IPHONE_4 || IS_IPHONE_5)
    {
        textSize = 15;
    }

    imgCheck = [[UIImageView alloc] init];
    imgCheck.image = [UIImage imageNamed:@"checkEmpty.png"];
    imgCheck.frame = CGRectMake(5, withY+8, 20, 20);
    [thirdView addSubview:imgCheck];
    
    UIButton * btnAgree = [UIButton buttonWithType:UIButtonTypeCustom];
    [btnAgree setFrame:CGRectMake(0, withY-5, 50, 30)];
    [btnAgree addTarget:self action:@selector(agreeClick) forControlEvents:UIControlEventTouchUpInside];
    btnAgree.backgroundColor = [UIColor clearColor];
    [thirdView addSubview:btnAgree];
    
    UILabel * lblTerms =[[UILabel alloc] initWithFrame:CGRectMake(35, withY, DEVICE_WIDTH-35, 40)];
    lblTerms.font=[UIFont fontWithName:CGRegular size:textSize-3];
    lblTerms.textColor=[UIColor whiteColor];
    lblTerms.numberOfLines = 0;
    [thirdView addSubview:lblTerms];
    

    NSMutableAttributedString *hintText = [[NSMutableAttributedString alloc] initWithString:@"The details entered are correct and Succorfish procedures were followed."];
    UIFontDescriptor *fontDescriptor = [UIFontDescriptor fontDescriptorWithName:CGBold size:textSize-2];
    UIFontDescriptor *fontDescriptor1 = [UIFontDescriptor fontDescriptorWithName:CGRegular size:textSize-2];
    UIFontDescriptor *symbolicFontDescriptor = [fontDescriptor fontDescriptorWithSymbolicTraits:UIFontDescriptorTraitTightLeading];
    
    lblTerms.textColor=[UIColor whiteColor];
    [lblTerms setAttributedText:hintText];
    
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
        return 55;
    }
    else if (tableView == tblThirdView)
    {
        return 55;
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
    else if (tableView == tblThirdView)
    {
        return thirdViewArray.count;
    }
    return 0;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellReuseIdentifier = @"cellIdentifier";
    InspectionCell *cell = [tableView dequeueReusableCellWithIdentifier:cellReuseIdentifier];
    if (cell == nil)
    {
        cell = [[InspectionCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellReuseIdentifier];
    }
    if (tableView == tblFirstView)
    {
        cell.lblName.hidden = false;
        cell.lblValue.hidden = false;
        cell.lblLine.hidden = false;
        cell.imgArrow.hidden = false;
        cell.txtName.hidden = true;
        cell.txtZip.hidden = true;
        cell.lblZipLine.hidden = true;
        
        if (indexPath.row == 4)
        {
            cell.imgArrow.hidden = true;
        }
        else
        {
            cell.imgArrow.hidden = false;
        }
        cell.lblName.text = [self checkforValidString:[[firstViewArray objectAtIndex:indexPath.row]valueForKey:@"title"]];

        if([[self checkforValidString:[[firstViewArray objectAtIndex:indexPath.row]valueForKey:@"value"]]isEqualToString:@"NA"])
        {
            cell.lblValue.text = @"";
        }
        else
        {
            cell.lblValue.text = [self checkforValidString:[[firstViewArray objectAtIndex:indexPath.row]valueForKey:@"value"]];
        }
        if (indexPath.row == 3)
        {
            if ([[self checkforValidString:[[firstViewArray objectAtIndex:2]valueForKey:@"value"]]isEqualToString:@"NA"])
            {
                cell.lblValue.text = @"";
            }
            else
            {
                cell.lblValue.text = [self checkforValidString:[[firstViewArray objectAtIndex:indexPath.row]valueForKey:@"value"]];
            }
        }
        if (indexPath.row == 4)
        {
            NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
            [formatter setDateFormat:@"YYYY-MM-dd HH:mm"];
            NSDate *currentDate = [NSDate date];
            NSDate * resultDate = [formatter dateFromString:[self checkforValidStringForEdit:[detailDict valueForKey:@"warranty"]]];
            
            switch ([resultDate compare:currentDate])
            {
                case NSOrderedAscending:
                    //Do your logic when date1 > date2
                     cell.lblValue.textColor = UIColor.redColor;
                    
                    break;
                    
                case NSOrderedDescending:
                    //Do your logic when date1 < date2
                     cell.lblValue.textColor = UIColor.whiteColor;
                    break;
                    
                case NSOrderedSame:
                    //Do your logic when date1 = date2
                    cell.lblValue.textColor = UIColor.whiteColor;
                    break;
            }
        }
    }
    else if (tableView == tblSecondView)
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
        int textHeight = 54;
        
        if (IS_IPHONE_4 || IS_IPHONE_5)
        {
            textHeight = 49;
        }
        cell.lblName.hidden = true;
        cell.lblValue.hidden = true;
        cell.lblLine.hidden = false;
        cell.imgArrow.hidden = true;
        cell.txtName.hidden = false;
        cell.txtZip.hidden = false;
        cell.lblZipLine.hidden = false;
       
        cell.txtName.tag = [[arrayTextFieldTagValues objectAtIndex:indexPath.row] integerValue];
        cell.txtName.delegate = self;
        cell.lblLine.frame = CGRectMake(10,textHeight, DEVICE_WIDTH-20, 1);
        cell.txtName.placeholder = [[secondViewArray objectAtIndex:indexPath.row]valueForKey:@"title"];
        cell.txtZip.tag = 200 + indexPath.row + 1;
  
        if ([[self checkforValidString:[[secondViewArray objectAtIndex:indexPath.row]valueForKey:@"value"]]isEqualToString:@"NA"])
        {
            cell.txtName.text = @"";
        }
        else
        {
            cell.txtName.text = [self checkforValidString:[[secondViewArray objectAtIndex:indexPath.row]valueForKey:@"value"]];
        }

        if(indexPath.row == 3)
        {
            cell.txtZip.hidden = false;
            //            cell.txtZip.tag = 105;
            cell.txtZip.delegate = self;
            cell.lblZipLine.hidden = false;
            cell.txtZip.hidden = false;
            cell.lblLine.frame = CGRectMake(10,textHeight,(DEVICE_WIDTH/2)-20, 1);
                    cell.txtZip.text = [self checkforValidString:[[secondViewArray objectAtIndex:indexPath.row]valueForKey:@"zipValue"]];
            cell.txtName.frame = CGRectMake(10, 8, (DEVICE_WIDTH/2)-20, textHeight-8);
            cell.txtZip.frame = CGRectMake((DEVICE_WIDTH/2)+10, 8, (DEVICE_WIDTH/2)-20, textHeight-8);
            cell.lblZipLine.frame = CGRectMake((DEVICE_WIDTH/2)+10,textHeight,(DEVICE_WIDTH/2)-20, 1);
            if ([[APP_DELEGATE checkforValidString:[[secondViewArray objectAtIndex:indexPath.row]valueForKey:@"zipValue"]]isEqualToString:@"NA"])
            {
                cell.txtZip.text = @"";
            }
            else
            {
                cell.txtZip.text = [APP_DELEGATE checkforValidString:[[secondViewArray objectAtIndex:indexPath.row]valueForKey:@"zipValue"]];
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
        [APP_DELEGATE getPlaceholderText:cell.txtName andColor:UIColor.whiteColor];
        [APP_DELEGATE getPlaceholderText:cell.txtZip andColor:UIColor.whiteColor];
    }
    else if (tableView == tblThirdView)
    {
        cell.lblName.hidden = false;
        cell.lblValue.hidden = false;
        cell.lblLine.hidden = false;
        cell.imgArrow.hidden = false;
        cell.txtName.hidden = true;
        cell.txtZip.hidden = true;
        cell.lblZipLine.hidden = true;
        
        cell.lblName.textColor = UIColor.whiteColor;
        cell.lblName.frame = CGRectMake(10,20, (DEVICE_WIDTH/2)+10, 30);
        cell.lblValue.frame = CGRectMake((DEVICE_WIDTH/2)+25,20, (DEVICE_WIDTH/2)-45, 30);

        cell.lblName.text = [self checkforValidString:[[thirdViewArray objectAtIndex:indexPath.row]valueForKey:@"title"]];
        
        if([[self checkforValidString:[[thirdViewArray objectAtIndex:indexPath.row]valueForKey:@"value"]]isEqualToString:@"NA"])
        {
            cell.lblValue.text = @"";
        }
        else
        {
            cell.lblValue.text = [self checkforValidString:[[thirdViewArray objectAtIndex:indexPath.row]valueForKey:@"value"]];
        }
        if (indexPath.row == 3)
        {
            cell.lblPositionMsg.hidden = false;
            cell.lblLastReport.hidden = false;

            NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
            [formatter setDateFormat:@"YYYY-MM-dd HH:mm"];
            NSDate *currentDate = [NSDate date];
            NSDate * resultDate = [formatter dateFromString:[self checkforValidStringForEdit:[detailDict valueForKey:@"warranty"]]];
            
            switch ([resultDate compare:currentDate])
            {
                case NSOrderedAscending:
                    //Do your logic when date1 > date2
                    cell.lblValue.textColor = UIColor.redColor;
                    
                    break;
                    
                case NSOrderedDescending:
                    //Do your logic when date1 < date2
                    cell.lblValue.textColor = UIColor.whiteColor;
                    break;
                    
                case NSOrderedSame:
                    //Do your logic when date1 = date2
                    cell.lblValue.textColor = UIColor.whiteColor;
                    break;
            }
        }
        else
        {
            cell.lblPositionMsg.hidden = true;
            cell.lblLastReport.hidden = true;
        }
    }
  
    cell.backgroundColor = UIColor.clearColor;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView == tblFirstView)
    {
        if (indexPath.row == 0)
        {
            BarcodeScanVC * barcodeVC = [[BarcodeScanVC alloc] init];
            barcodeVC.isFromInstall = @"Inspection";
            [self.navigationController pushViewController:barcodeVC animated:YES];
        }
        else if (indexPath.row == 1)
        {
            [self deviceTypeClick];
        }
        else if(indexPath.row == 2)
        {
            [self.view endEditing:YES];
            VesselVC * vessel = [[VesselVC alloc] init];
            [self.navigationController pushViewController:vessel animated:YES];
        }
        else if(indexPath.row == 3)
        {
            [self.view endEditing:YES];
            VesselVC * vessel = [[VesselVC alloc] init];
            [self.navigationController pushViewController:vessel animated:YES];
        }
        else if (indexPath.row == 5)
        {
            [self TestDeviceClick];
        }
    }
    else if (tableView == tblThirdView)
    {
        if (indexPath.row == 0)
        {
            PhotoView * photosvc = [[PhotoView alloc] init];
            photosvc.installId = [self checkforValidString:strInstallID];
            photosvc.isfromInspection = YES;
            [self.navigationController pushViewController:photosvc animated:YES];
        }
        else if (indexPath.row == 1)
        {
            [self btnActionTakenClick];
        }
        else if(indexPath.row == 2)
        {
            [self signatureClick];
        }
        else if (indexPath.row == 3)
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
        if (indexOne == 1)
        {
            [self InsertDataforSecondView];
        }
        else if (indexOne == 2)
        {
            [self SavedataforThirdViewBack];
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
                [self InsertDataforFirstView];
                if (isSecondBuilt)
                {
                }
                else
                {
                    [self setsecondView];
                    isSecondBuilt = YES;
                }
                indexOne = indexOne + 1;
                [scrlContent setContentOffset:CGPointMake(DEVICE_WIDTH*indexOne, 0) animated:YES];
                [stepperView setIndex:indexOne animated:YES];
            }
        }
    }
    else if(indexOne == 1)
    {
        if ([self validationforsecondVieww])
        {
            [self InsertDataforSecondView];

            if (isThirdBuilt)
            {
            }
            else
            {
                [self setThirdView];
                isThirdBuilt = YES;
            }
            indexOne = indexOne + 1;
            [scrlContent setContentOffset:CGPointMake(DEVICE_WIDTH*indexOne, 0) animated:YES];
            [stepperView setIndex:indexOne animated:YES];
        }
        if ([APP_DELEGATE isNetworkreachable])
        {
        }
        else
        {
            moveFrwdBtn.enabled = true;
        }
    }
    else if(indexOne == 2)
    {
        if ([self validationforThirdView])
        {
            if (isTestDeviceDone)
            {
                [self InsertDataforThirdView];
                if ([APP_DELEGATE isNetworkreachable])
                {
                    [self SaveReporttoSuccorfishServer];
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

-(void)deviceTypeClick
{
    [self.view endEditing:YES];
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
    [btnDone2 setTag:123];
    btnDone2.titleLabel.font = [UIFont fontWithName:CGRegular size:14];
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
//    [[firstViewArray objectAtIndex:0] valueForKey:@"value"]
    if ([[[firstViewArray objectAtIndex:0] valueForKey:@"value"] length] == 0 || [[firstViewArray objectAtIndex:0] valueForKey:@"value"] == nil || [[APP_DELEGATE checkforValidString:[[firstViewArray objectAtIndex:0] valueForKey:@"value"]] isEqualToString:@"NA"] || [[[firstViewArray objectAtIndex:0] valueForKey:@"value"] isEqualToString:@" "])
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
            //Call service here for checking the status of device in installed or not.
            //            TestDeviceVC * testVC = [[TestDeviceVC alloc] init];
            //            [self.navigationController pushViewController:testVC animated:YES];
//            [self getDeviceDetailService];
            [self getDeviceIDfromIMEIRomanAPI];
        }
        else
        {
            TestDeviceVC * testVC = [[TestDeviceVC alloc] init];
            testVC.strReasonToCome = @"Offline";
            [self.navigationController pushViewController:testVC animated:YES];
        }
    }
}
-(void)btnActionTakenClick
{
    [self.view endEditing:YES];

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
    [btnDone2 setTag:126];
    btnDone2.titleLabel.font = [UIFont fontWithName:CGRegular size:14];
    [btnDone2 addTarget:self action:@selector(btnDoneClicked:) forControlEvents:UIControlEventTouchUpInside];
    [typeBackView addSubview:btnDone2];
    
    [self ShowPicker:YES andView:typeBackView];
}

-(void)btnWarrantClick
{
    
    // Email Subject
    NSString *emailTitle = installScanID;
    // Email Content
//    NSString *messageBody = @"This device's expiry details.";
//    Device "IMEI" from "vessel name & Number Screen 1" will be returned for warranty inspection. Its warranty status "take from the field on Screen 1" and was inspected by "app users name" on date & time.
    
    NSMutableDictionary * userDetailDict = [[NSMutableDictionary alloc] init];
    userDetailDict = [[[NSUserDefaults standardUserDefaults] objectForKey:@"UserDict"] mutableCopy];
    NSString * strName = [self checkforValidString:[userDetailDict valueForKey:@"name"]];
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"YYYY-MM-dd HH:mm"];
    NSString *currentTime = [dateFormatter stringFromDate:[NSDate date]];

    NSString * strMsg = [NSString stringWithFormat:@"Device %@ from %@ & %@ will be returned for warranty inspection. Its warranty status %@ and was inspected by %@ on %@.",installScanID,installVesselName,installRegi,[[firstViewArray objectAtIndex:4]valueForKey:@"value"],strName,currentTime];
    
    // To address
    NSArray *toRecipents = [NSArray arrayWithObject:@"support@succorfish.com"];

    MFMailComposeViewController *mc = [[MFMailComposeViewController alloc] init];
    mc.mailComposeDelegate = self;
    [mc setSubject:emailTitle];
    [mc setMessageBody:strMsg isHTML:NO];
    [mc setToRecipients:toRecipents];

    // Present mail view controller on screen
//    UINavigationController * navv = [[UINavigationController alloc] initWithRootViewController:mc];
    [self.navigationController presentViewController:mc animated:YES completion:nil];
//    [self presentViewController:mc animated:YES completion:NULL];
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
-(BOOL)validationforFirstView
{
    BOOL isAvail = NO;
    
    if ([[[firstViewArray objectAtIndex:0] valueForKey:@"value"] length] == 0 || [[firstViewArray objectAtIndex:0] valueForKey:@"value"] == nil || [[APP_DELEGATE checkforValidString:[[firstViewArray objectAtIndex:0] valueForKey:@"value"]] isEqualToString:@"NA"] || [[[firstViewArray objectAtIndex:0] valueForKey:@"value"] isEqualToString:@" "])
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
    else if ([[[firstViewArray objectAtIndex:1] valueForKey:@"value"] length] == 0 || [[firstViewArray objectAtIndex:1] valueForKey:@"value"] == nil || [[APP_DELEGATE checkforValidString:[[firstViewArray objectAtIndex:1] valueForKey:@"value"]] isEqualToString:@"NA"] || [[[firstViewArray objectAtIndex:1] valueForKey:@"value"] isEqualToString:@" "])
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
    else if ([[[firstViewArray objectAtIndex:2] valueForKey:@"value"] length] == 0 || [[firstViewArray objectAtIndex:2] valueForKey:@"value"] == nil || [[APP_DELEGATE checkforValidString:[[firstViewArray objectAtIndex:2] valueForKey:@"value"]] isEqualToString:@"NA"] || [[[firstViewArray objectAtIndex:2] valueForKey:@"value"] isEqualToString:@" "])
    {
        [self showMessagewithText:@"Please enter Asset name."];
    }
    else if ([[[firstViewArray objectAtIndex:3] valueForKey:@"value"] length] == 0)
    {
        [self showMessagewithText:@"Please enter Registration no."];
    }
    else
    {
        isAvail = YES;
    }
    
    return isAvail;
}
-(BOOL)validationforsecondVieww
{
    BOOL isAvail = NO;
    
    if ([[[secondViewArray objectAtIndex:0]valueForKey:@"value"] length] == 0 || [[secondViewArray objectAtIndex:0]valueForKey:@"value"] == nil || [[APP_DELEGATE checkforValidString:[[secondViewArray objectAtIndex:0]valueForKey:@"value"]] isEqualToString:@"NA"] || [[[secondViewArray objectAtIndex:0]valueForKey:@"value"] isEqualToString:@" "])
    {
        [self showMessagewithText:@"Please enter Owner name."];
    }
    else if ([[[secondViewArray objectAtIndex:1]valueForKey:@"value"] length] == 0 || [[secondViewArray objectAtIndex:1]valueForKey:@"value"] == nil || [[APP_DELEGATE checkforValidString:[[secondViewArray objectAtIndex:1]valueForKey:@"value"]] isEqualToString:@"NA"] || [[[secondViewArray objectAtIndex:1]valueForKey:@"value"] isEqualToString:@" "])
    {
        [self showMessagewithText:@"Please enter Owner address."];
    }
    else if ([[[secondViewArray objectAtIndex:3]valueForKey:@"zipValue"] length] == 0 || [[secondViewArray objectAtIndex:3]valueForKey:@"zipValue"] == nil || [[APP_DELEGATE checkforValidString:[[secondViewArray objectAtIndex:3]valueForKey:@"zipValue"]] isEqualToString:@"NA"] || [[[secondViewArray objectAtIndex:3]valueForKey:@"zipValue"] isEqualToString:@" "])
    {
        [self showMessagewithText:@"Please enter ZipCode."];
    }
    else if ([[[secondViewArray objectAtIndex:4]valueForKey:@"value"] length] == 0 || [[secondViewArray objectAtIndex:4]valueForKey:@"value"] == nil || [[APP_DELEGATE checkforValidString:[[secondViewArray objectAtIndex:4]valueForKey:@"value"]] isEqualToString:@"NA"] || [[[secondViewArray objectAtIndex:4]valueForKey:@"value"] isEqualToString:@" "])
    {
        [self showMessagewithText:@"Please enter Owner email address."];
    }
    else if(![self validateEmailHere:[[secondViewArray objectAtIndex:4]valueForKey:@"value"]])
    {
        [self showMessagewithText:@"Please enter valid email address"];
    }
    else if ([[[secondViewArray objectAtIndex:5]valueForKey:@"value"] length] == 0 || [[secondViewArray objectAtIndex:5]valueForKey:@"value"] == nil || [[APP_DELEGATE checkforValidString:[[secondViewArray objectAtIndex:5]valueForKey:@"value"]] isEqualToString:@"NA"] || [[[secondViewArray objectAtIndex:5]valueForKey:@"value"] isEqualToString:@" "])
    {
        [self showMessagewithText:@"Please enter Owner mobile number."];
    }
    else if([[[secondViewArray objectAtIndex:5]valueForKey:@"value"] length]<10)
    {
        [self showMessagewithText:@"Mobile number should at least 10 digits"];
    }
    else
    {
        isAvail = YES;
    }
    return isAvail;
}

-(BOOL)validationforThirdView
{
    BOOL isAvail = NO;
    
    if ([txtResult.text length] == 0 || txtResult.text == nil || [txtResult.text isEqualToString:@"NA"] || [txtResult.text isEqualToString:@" "])
    {
        [self showMessagewithText:@"Please enter Inspection result."];
    }
    else if ([self isAllFourPhotosAdded] == NO)
    {
        [self showMessagewithText:@"Please add 4 photos of Inspection."];
    }
    else if ([[[thirdViewArray objectAtIndex:1]valueForKey:@"value"] length] == 0 || [[thirdViewArray objectAtIndex:1]valueForKey:@"value"] == nil || [[APP_DELEGATE checkforValidString:[[thirdViewArray objectAtIndex:1]valueForKey:@"value"]] isEqualToString:@"NA"] || [[[thirdViewArray objectAtIndex:1]valueForKey:@"value"] isEqualToString:@" "])
    {
        [self showMessagewithText:@"Please select action taken."];
    }
    else if ([self checkPhotofileExistorNot] == NO)
    {
        [self showMessagewithText:@"There is some photos missing for Inspections. Please check and add missing photos."];
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
-(BOOL)isAllFourPhotosAdded
{
    BOOL isExisted = YES;
    
    NSMutableArray * imgsArr = [[NSMutableArray alloc] init];
    NSString * strQuery = [NSString stringWithFormat:@"select * from tbl_inspection_photo where insp_local_id = '%@' and insp_photo_user_id = '%@'",strInstallID,CURRENT_USER_ID];
    [[DataBaseManager dataBaseManager] execute:strQuery resultsArray:imgsArr];
    
    installPhotoCounts = [NSString stringWithFormat:@"%d",[imgsArr count]];
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
    NSString * strQuery = [NSString stringWithFormat:@"select * from tbl_inspection_photo where insp_local_id = '%@' and insp_photo_user_id ='%@'",strInstallID,CURRENT_USER_ID];
    [[DataBaseManager dataBaseManager] execute:strQuery resultsArray:imgsArr];
    
    for (int k=0; k<[imgsArr count]; k++)
    {
        NSString * filePath = [self documentsPathForFileName:[NSString stringWithFormat:@"InspectionPhotos/%@",[[imgsArr objectAtIndex:k] valueForKey:@"insp_photo_local_url"]]];
        BOOL fileExists = [[NSFileManager defaultManager] fileExistsAtPath:filePath];
        if (fileExists == NO)
        {
            isExisted = NO;
            break;
        }
    }
    return isExisted;
}
- (NSString *)documentsPathForFileName:(NSString *)name
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask, YES);
    NSString *documentsPath = [paths objectAtIndex:0];
    return [documentsPath stringByAppendingPathComponent:name];
}
-(void)signatureBtnClick
{
    int textSize = 16;
    
    if (IS_IPHONE_4 || IS_IPHONE_5)
    {
        textSize = 15;
    }
    [signbkView removeFromSuperview];
    signbkView = [[UIView alloc] init];
    signbkView.frame=CGRectMake(0, 0, DEVICE_WIDTH, DEVICE_HEIGHT);
    signbkView.backgroundColor = [UIColor blackColor];
    signbkView.alpha = 0.5l;
    signbkView.hidden = YES;
    [self.view addSubview:signbkView];
    
    [PJSignbckView removeFromSuperview];
    PJSignbckView = [[UIView alloc] init];
    PJSignbckView.frame= CGRectMake(10, DEVICE_HEIGHT, DEVICE_WIDTH-20, 288);
    PJSignbckView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:PJSignbckView];
    
    [signatureView removeFromSuperview];
    signatureView= [[PJRSignatureView alloc] initWithFrame:CGRectMake(0,0,DEVICE_WIDTH-0,288)];
    signatureView.tag = 0;
    signatureView.backgroundColor = [UIColor whiteColor];
    [PJSignbckView addSubview:signatureView];
    
    UIImageView * backLbl = [[UIImageView alloc] init];
    backLbl.frame = CGRectMake(0, 0, DEVICE_WIDTH, 44);
    backLbl.backgroundColor = [UIColor clearColor];
    backLbl.image = [UIImage imageNamed:@"BTN.png"];
    [PJSignbckView addSubview:backLbl];
    
    UIButton * clearBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    clearBtn.frame = CGRectMake(0, 0, 100, 44);
    [clearBtn setTitle:@"Clear" forState:UIControlStateNormal];
    clearBtn.titleLabel.font = [UIFont fontWithName:CGRegular size:textSize];
    [clearBtn addTarget:self action:@selector(btnSignClearClick) forControlEvents:UIControlEventTouchUpInside];
    [PJSignbckView addSubview:clearBtn];
    
    UIButton * cancelBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    cancelBtn.frame = CGRectMake(signatureView.frame.size.width-110, 0, 100, 44);
    [cancelBtn setTitle:@"Cancel" forState:UIControlStateNormal];
    cancelBtn.titleLabel.font = [UIFont fontWithName:CGRegular size:textSize];
    [cancelBtn addTarget:self action:@selector(btnSignCancelClick) forControlEvents:UIControlEventTouchUpInside];
    [PJSignbckView addSubview:cancelBtn];
    
    UIButton * doneBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    doneBtn.frame = CGRectMake(0, 244, DEVICE_WIDTH, 44);
    [doneBtn setTitle:@"Save" forState:UIControlStateNormal];
    [doneBtn addTarget:self action:@selector(btnSignSaveClick) forControlEvents:UIControlEventTouchUpInside];
    doneBtn.backgroundColor = globalAppColor;
    [doneBtn setBackgroundImage:[UIImage imageNamed:@"BTN.png"] forState:UIControlStateNormal];
    [PJSignbckView addSubview:doneBtn];
    
    [signatureView clearSignature];
    
    [UIView transitionWithView:PJSignbckView duration:0.4
                       options:UIViewAnimationOptionCurveEaseIn
                    animations:^{
                        [PJSignbckView setFrame:CGRectMake(0, (DEVICE_HEIGHT-288)/2, DEVICE_WIDTH, 288)];
                    }
                    completion:^(BOOL finished) {
                    }];
}
-(void)btnSignSaveClick
{
    imgSign = [signatureView getSignatureImage];
    if (imgSign)
    {
//        signbkView.hidden = YES;
        signImgView.image = imgSign;
        [btnSignature setTitle:@"" forState:UIControlStateNormal];
        [self ShowPicker:NO andView:PJSignbckView];
        [self ShowPicker:NO andView:signbkView];
    }
    else
    {
        [btnSignature setImage:nil forState:UIControlStateNormal];
        alertView =[[URBAlertView alloc] initWithTitle:ALERT_TITLE message:@"Please fill up installer sign." cancelButtonTitle:OK_BTN otherButtonTitles:nil, nil];
        [alertView showWithAnimation:URBAlertAnimationTopToBottom];
    }
}
-(void)btnSignClearClick
{
    [signatureView clearSignature];
}
-(void)btnSignCancelClick
{
    signbkView.hidden = YES;
    [self ShowPicker:NO andView:PJSignbckView];
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
-(void)signatureClick
{
    //    strInstallerSignUrl = [tmpDict valueForKey:@"local_installer_sign"];
    //    strOwnerSignUrl =  [tmpDict valueForKey:@"local_owner_sign"];
    
    SignVC * signV = [[SignVC alloc] init];
    signV.isFromEdit = isFromeEdit;
    signV.detailDict = detailDict;
    signV.strInstallId = strInstallID;
    signV.strFromView = @"Inspection";
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
-(void)btnConditions
{
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
        NSString * strVesselID = [self checkforValidString:installedVesselID];
        NSString * strVesselName = [self checkforValidString:installVesselName];
        NSString * strRegiNo = [self checkforValidString:installRegi];
        NSString * strWarranty = [self checkforValidString:[[firstViewArray objectAtIndex:4]valueForKey:@"value"]];
        
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"YYYY-MM-dd HH:mm"];
        NSString *currentTime = [dateFormatter stringFromDate:[NSDate date]];
        
        [detailDict setObject:strEmi forKey:@"imei"];
        [detailDict setObject:strDeviceType forKey:@"device_type"];
        [detailDict setObject:strVesselName forKey:@"vesselname"];
        [detailDict setObject:strRegiNo forKey:@"portno"];
        [detailDict setObject:strWarranty forKey:@"warranty"];

        
        NSString * requestStr =[NSString stringWithFormat:@"update 'tbl_inspection' set 'user_id' = \"%@\",'imei' = \"%@\",'device_type' = \"%@\",'updated_at' = \"%@\", 'vessel_id' = \"%@\",'vesselname' = \"%@\",'portno' = \"%@\",'warranty' = \"%@\", 'succor_device_id' = \"%@\" where id ='%@'",strUserID,strEmi,strDeviceType,currentTime,strVesselID,strVesselName,strRegiNo,strWarranty,strSuccorfishDeviceID,strInstallID];
        [[DataBaseManager dataBaseManager] execute:requestStr];
    }
    else
    {
        NSString * strUserID = [self checkforValidString:CURRENT_USER_ID];
        NSString * strEmi = [self checkforValidString:[[firstViewArray objectAtIndex:0]valueForKey:@"value"]];
        NSString * strDeviceType = [self checkforValidString:[[firstViewArray objectAtIndex:1]valueForKey:@"value"]];
        NSString * strVesselID = [self checkforValidString:installedVesselID];
        NSString * strVesselName = [self checkforValidString:installVesselName];
        NSString * strRegiNo = [self checkforValidString:installRegi];
        NSString * strWarranty = [self checkforValidString:[[firstViewArray objectAtIndex:4]valueForKey:@"value"]];
        
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"YYYY-MM-dd HH:mm"];
        NSString *currentTime = [dateFormatter stringFromDate:[NSDate date]];
        
        int timestamp = [[NSDate date] timeIntervalSince1970];
        NSString * strcurTimeStamp = [NSString stringWithFormat:@"%d",timestamp];
        
        [detailDict setObject:strEmi forKey:@"imei"];
        [detailDict setObject:strDeviceType forKey:@"device_type"];
        [detailDict setObject:strVesselName forKey:@"vesselname"];
        [detailDict setObject:strRegiNo forKey:@"portno"];
        [detailDict setObject:strWarranty forKey:@"warranty"];
        [detailDict setObject:currentTime forKey:@"created_at"];
        [detailDict setObject:currentTime forKey:@"inspection_date"];

        if (isSecondBuilt)
        {
            NSString * requestStr =[NSString stringWithFormat:@"update 'tbl_inspection' set 'user_id' = \"%@\",'imei' = \"%@\",'device_type' = \"%@\",'updated_at' = \"%@\", 'vessel_id' = \"%@\",'vesselname' = \"%@\",'portno' = \"%@\",'warranty' = \"%@\", 'succor_device_id' = \"%@\" where id ='%@'",strUserID,strEmi,strDeviceType,currentTime,strVesselID,strVesselName,strRegiNo,strWarranty,strSuccorfishDeviceID,strInstallID];
            [[DataBaseManager dataBaseManager] execute:requestStr];
        }
        else
        {
            NSString * requestStr = [NSString stringWithFormat:@"update 'tbl_inspection' set 'user_id' = \"%@\",'imei' = \"%@\",'device_type' = \"%@\",'created_at' = \"%@\",'vessel_id' = \"%@\",'vesselname' = \"%@\",'portno' = \"%@\",'warranty' = \"%@\",'createdTimeStamp' = \"%@\",'inspection_date' = \"%@\",'complete_status' = 'INCOMPLETE','succor_device_id' = \"%@\" where id = '%@'",strUserID,strEmi,strDeviceType,currentTime,strVesselID,strVesselName,strRegiNo,strWarranty,strcurTimeStamp,currentTime,strSuccorfishDeviceID,strInstallID];
            
            if(isFromeEdit)
            {
                 requestStr =[NSString stringWithFormat:@"insert into 'tbl_inspection'('user_id','imei','device_type','created_at','vessel_id','vesselname','portno','warranty','createdTimeStamp',inspection_date,'complete_status','succor_device_id') values(\"%@\",\"%@\",\"%@\",\"%@\",\"%@\",\"%@\",\"%@\",\"%@\",\"%@\",\"%@\",'COMPLETE',\"%@\")",strUserID,strEmi,strDeviceType,currentTime,strVesselID,strVesselName,strRegiNo,strWarranty,strcurTimeStamp,currentTime,strSuccorfishDeviceID];
                
                intInstallID = [[DataBaseManager dataBaseManager] executeSw:requestStr];

            }
            [[DataBaseManager dataBaseManager] execute:requestStr];

            [APP_DELEGATE updateBadgeCount];

            if (intInstallID != 0)
            {
                strInstallID = [NSString stringWithFormat:@"%d",intInstallID];
                
                NSString * strDate1 = [self getConvertedDate:currentTime withFormat:@"YYYY-MM-dd"];
                NSString * strDate2 = [self getConvertedDate:currentTime withFormat:@"dd-MM-yyyy"];
                NSString * strDate3 = [self getConvertedDate:currentTime withFormat:@"dd/MM/yyyy"];
                NSString * strDate4 = [self getConvertedDate:currentTime withFormat:@"dd MMMM yyyy"];
                NSString * strDate5 = [self getConvertedDate:currentTime withFormat:@"MM/dd/yyyy"];
                NSString * strDate6 = [self getConvertedDate:currentTime withFormat:@"yyyy/MM/dd"];
                
                NSString * strQuery =[NSString stringWithFormat:@"update 'tbl_inspection' set 'date1' = \"%@\",'date2' = \"%@\",'date3' = \"%@\",'date4' = \"%@\",'date5' = \"%@\",'date6' = \"%@\" where id ='%@'",strDate1,strDate2,strDate3,strDate4,strDate5,strDate6,strInstallID];
                [[DataBaseManager dataBaseManager] execute:strQuery];
            }
        }
    }
}

-(void)InsertDataforSecondView
{
    NSString * strOwner = [self checkforValidString:[[secondViewArray objectAtIndex:0]valueForKey:@"value"]];
    NSString * strEmail = [self checkforValidString:[[secondViewArray objectAtIndex:4]valueForKey:@"value"]];
    NSString * strAddress = [self checkforValidString:[[secondViewArray objectAtIndex:1]valueForKey:@"value"]];
    NSString * strMobile = [self checkforValidString:[[secondViewArray objectAtIndex:5]valueForKey:@"value"]];
    NSString * strCity = [self checkforValidString:[[secondViewArray objectAtIndex:2]valueForKey:@"value"]];
    NSString * strState = [self checkforValidString:[[secondViewArray objectAtIndex:3]valueForKey:@"value"]];
    NSString * strZipCode = [self checkforValidString:[[secondViewArray objectAtIndex:3]valueForKey:@"zipValue"]];
 
    [detailDict setObject:strOwner forKey:@"owner_name"];
    [detailDict setObject:strEmail forKey:@"owner_email"];
    [detailDict setObject:strAddress forKey:@"owner_address"];
    [detailDict setObject:strMobile forKey:@"owner_phone_no"];
    [detailDict setObject:strCity forKey:@"owner_city"];
    [detailDict setObject:strState forKey:@"owner_state"];
    [detailDict setObject:strZipCode forKey:@"owner_zipcode"];

    NSString * requestStr =[NSString stringWithFormat:@"Update 'tbl_inspection'  set 'owner_name' =\"%@\", 'owner_email' = \"%@\",'owner_address'=\"%@\",'owner_phone_no'=\"%@\",'owner_city'=\"%@\",'owner_state'=\"%@\",'owner_zipcode'=\"%@\",'complete_status'='INCOMPLETE' where id ='%@'",strOwner,strEmail,strAddress,strMobile,strCity,strState,strZipCode,strInstallID];
    if(isFromeEdit)
    {
         requestStr =[NSString stringWithFormat:@"Update 'tbl_inspection'  set 'owner_name' =\"%@\", 'owner_email' = \"%@\",'owner_address'=\"%@\",'owner_phone_no'=\"%@\",'owner_city'=\"%@\",'owner_state'=\"%@\",'owner_zipcode'=\"%@\",'complete_status'='COMPLETE' where id ='%@'",strOwner,strEmail,strAddress,strMobile,strCity,strState,strZipCode,strInstallID];
    }
    [[DataBaseManager dataBaseManager] execute:requestStr];
}

-(void)InsertDataforThirdView
{
    NSString * strResult = [self checkforValidString:txtResult.text];
    NSString * strAction = [self checkforValidString:[[thirdViewArray objectAtIndex:1]valueForKey:@"value"]];

    [detailDict setObject:strResult forKey:@"insp_result"];
    [detailDict setObject:strAction forKey:@"insp_action_taken"];

    NSString * requestStr =[NSString stringWithFormat:@"Update 'tbl_inspection'  set 'insp_result' =\"%@\", 'insp_action_taken' = \"%@\",'complete_status'='COMPLETE','actionvalue'=\"%@\" where id ='%@'",strResult,strAction,strAcionServerValue,strInstallID];
    [[DataBaseManager dataBaseManager] execute:requestStr];
}
-(void)SavedataforThirdViewBack
{
    NSString * strResult = [self checkforValidString:txtResult.text];
    NSString * strAction = [self checkforValidString:[[thirdViewArray objectAtIndex:1]valueForKey:@"value"]];
    
    [detailDict setObject:strResult forKey:@"insp_result"];
    [detailDict setObject:strAction forKey:@"insp_action_taken"];
    
    NSString * requestStr =[NSString stringWithFormat:@"Update 'tbl_inspection'  set 'insp_result' =\"%@\", 'insp_action_taken' = \"%@\", 'actionvalue'=\"%@\" where id ='%@'",strResult,strAction,strAcionServerValue,strInstallID];
    [[DataBaseManager dataBaseManager] execute:requestStr];
}
-(NSString *)saveSignatureImagetoDocumentDirectory
{
    NSTimeInterval timeStamp = [[NSDate date] timeIntervalSince1970];
    NSNumber *timeStampObj = [NSNumber numberWithInteger: timeStamp];
    
    int randomID = arc4random() % 9000 + 1000;
    NSString * imageName = [NSString stringWithFormat:@"/SignInspection%@-%d-ID%@-.jpg", strInstallID,randomID,timeStampObj];
    imageName = [imageName stringByReplacingOccurrencesOfString:@" " withString:@""];
    
    NSString * stringPath = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)objectAtIndex:0]stringByAppendingPathComponent:@"InspectionSigns"]; // New Folder is your folder name
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
        return [actionArr count];
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
            label.text = [[actionArr objectAtIndex:row] valueForKey:@"name"];
            strAcionServerValue = [[actionArr objectAtIndex:row] valueForKey:@"value"];
            return label;
        }
    }
    return label;
}

-(void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    if (pickerView.tag == 123)
    {
        if (firstViewArray.count >= 5)
        {
            [[firstViewArray objectAtIndex:1]setValue:[deviceTypeArr objectAtIndex:row] forKey:@"value"];
        }
        [tblFirstView reloadData];
    }
    else if (pickerView.tag == 126)
    {
        if (thirdViewArray.count >= 4)
        {
            [[thirdViewArray objectAtIndex:1]setValue:[[actionArr objectAtIndex:row]valueForKey:@"name"] forKey:@"value"];
            [tblThirdView reloadData];
        }
        strAcionServerValue  =  [[actionArr objectAtIndex:row]valueForKey:@"value"];
    }
}

-(void)btnDoneClicked:(id)sender
{
    if ([sender tag] == 123)
    {
        NSInteger index = [deviceTypePicker selectedRowInComponent:0];
        if ([deviceTypeArr count] >= index)
        {
            [[firstViewArray objectAtIndex:1] setValue:[deviceTypeArr objectAtIndex:index] forKey:@"value"];
            [tblFirstView reloadData];
        }
        [self ShowPicker:NO andView:typeBackView];
    }
    else if ([sender tag] == 126)
    {
        NSInteger index = [deviceTypePicker selectedRowInComponent:0];
        if ([actionArr count] >= index)
        {
            if (thirdViewArray.count >= 4)
            {
                [[thirdViewArray objectAtIndex:1]setValue:[[actionArr objectAtIndex:index]valueForKey:@"name"] forKey:@"value"];
                [tblThirdView reloadData];
            }
            strAcionServerValue  =  [[actionArr objectAtIndex:index]valueForKey:@"value"];
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

#pragma mark - Textfield Delegates
-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
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
-(void)textFieldDidBeginEditing:(UITextField *)textField
{
    if (textField.tag == 104)
    {
        if (IS_IPHONE_4)
        {
            int height = 260;
            
            [UIView animateWithDuration:0.5 animations:^{
                [secondView setFrame:CGRectMake(DEVICE_WIDTH, (heightKeyBrd-height)-45-50, DEVICE_WIDTH, scrlContent.frame.size.height+ 40)];
            }];
        }
        
    }
    else if (textField.tag == 106)
    {
        int height = 200;
        if (IS_IPHONE_5 )
        {
            [UIView animateWithDuration:0.5 animations:^{
                [secondView setFrame:CGRectMake(DEVICE_WIDTH, (heightKeyBrd-height)-45-50, DEVICE_WIDTH, scrlContent.frame.size.height+ 40)];
            }];
        }
    }
    else if (textField.tag == 107)
    {
        int height = 250;
        if (IS_IPHONE_4)
        {
            height = 350;
            [UIView animateWithDuration:0.5 animations:^{
                [secondView setFrame:CGRectMake(DEVICE_WIDTH, (heightKeyBrd-height)-45-50, DEVICE_WIDTH, scrlContent.frame.size.height+ 40)];
            }];
        }
        else if (IS_IPHONE_5 )
        {
            [UIView animateWithDuration:0.5 animations:^{
                [secondView setFrame:CGRectMake(DEVICE_WIDTH, (heightKeyBrd-height)-45-50, DEVICE_WIDTH, scrlContent.frame.size.height+ 40)];
            }];
        }
        else if (IS_IPHONE_6)
        {
            height = 250;
            [UIView animateWithDuration:0.5 animations:^{
                [secondView setFrame:CGRectMake(DEVICE_WIDTH, (heightKeyBrd-height)-45-50, DEVICE_WIDTH, scrlContent.frame.size.height+ 40)];
            }];
        }
        else if (IS_IPHONE_6plus)
        {
            height = 50;
            [UIView animateWithDuration:0.5 animations:^{
                [secondView setFrame:CGRectMake(DEVICE_WIDTH, (heightKeyBrd-height)-45-50, DEVICE_WIDTH, scrlContent.frame.size.height+ 40)];
            }];
        }
        else if (IS_IPHONE_X)
        {
            height = 250;
            [UIView animateWithDuration:0.5 animations:^{
                [secondView setFrame:CGRectMake(DEVICE_WIDTH, (heightKeyBrd-height)-45-50, DEVICE_WIDTH, scrlContent.frame.size.height+ 40)];
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
    
    
    lblLine = [[UILabel alloc] initWithFrame:CGRectMake(0,textField.frame.size.height-2-5,textField.frame.size.width,2)];
    [lblLine setBackgroundColor:[UIColor whiteColor]];
    [textField addSubview:lblLine];
    
    if (page==1)
    {
        lblLine.frame = CGRectMake(0,textField.frame.size.height-1,textField.frame.size.width,2);
    }
}
-(void)doneKeyBoarde
{
    if (IS_IPHONE_4 || IS_IPHONE_5 ||  IS_IPHONE_6 || IS_IPHONE_6plus || IS_IPHONE_X)
    {
        [UIView animateWithDuration:0.4 animations:^{
            [secondView setFrame:CGRectMake(DEVICE_WIDTH, 0, DEVICE_WIDTH, scrlContent.frame.size.height+ 40)];
        }];
        
    }
    UITextField* txtTemp = (UIFloatLabelTextField *)[self.view viewWithTag:107];
    [txtTemp resignFirstResponder];
    
}
-(void)textFieldDidEndEditing:(UITextField *)textField
{
    [lblLine removeFromSuperview];
    
    if (textField.tag == 101)
    {
        [[secondViewArray objectAtIndex:0]setValue:[self checkforValidString:textField.text] forKey:@"value"];
    }
    else if (textField.tag == 102)
    {
        [[secondViewArray objectAtIndex:1]setValue:[self checkforValidString:textField.text] forKey:@"value"];
    }
    else if (textField.tag == 103)
    {
        [[secondViewArray objectAtIndex:2]setValue:[self checkforValidString:textField.text] forKey:@"value"];
    }
    else if (textField.tag == 104)
    {
        [[secondViewArray objectAtIndex:3]setValue:[self checkforValidString:textField.text] forKey:@"value"];
    }
    else if (textField.tag == 204)
    {
        [[secondViewArray objectAtIndex:3]setValue:[self checkforValidString:textField.text] forKey:@"zipValue"];
    }
    else if (textField.tag == 106)
    {
        [[secondViewArray objectAtIndex:4]setValue:[self checkforValidString:textField.text] forKey:@"value"];
    }
    else if (textField.tag == 107)
    {
        [[secondViewArray objectAtIndex:5]setValue:[self checkforValidString:textField.text] forKey:@"value"];
    }
}
-(void)txtViewDoneclick
{
    [txtResult resignFirstResponder];
}
-(void)textViewShouldBeginEditing:(UITextView *)textView
{
    UIToolbar* numberToolbar = [[UIToolbar alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 50)];
    numberToolbar.barStyle =  UIBarStyleDefault;
    UIBarButtonItem *space =[[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    UIBarButtonItem *Done = [[UIBarButtonItem alloc]initWithTitle:@"Done" style:UIBarButtonItemStyleDone target:self action:@selector(txtViewDoneclick)];
    Done.tintColor=[APP_DELEGATE colorWithHexString:App_Header_Color];
    
    numberToolbar.items = [NSArray arrayWithObjects:space,Done,
                           nil];
    [numberToolbar sizeToFit];
    textView.inputAccessoryView = numberToolbar;
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
-(void)checkForAppearFields
{
    if (![installScanID isEqual:[NSNull null]])
    {
        if (installScanID != nil && installScanID != NULL && ![installScanID isEqualToString:@""])
        {
            [[firstViewArray objectAtIndex:0]setValue:installScanID forKey:@"value"] ;
        }
        else
        {
            [[firstViewArray objectAtIndex:0]setValue:@"" forKey:@"value"];
        }
    }
    else
    {
        [[firstViewArray objectAtIndex:0]setValue:@"" forKey:@"value"];
    }
    
    if (![installVesselName isEqual:[NSNull null]])
    {
        if (installVesselName != nil && installVesselName != NULL && ![installVesselName isEqualToString:@""] && ![installVesselName isEqualToString:@"NA"])
        {
            [[firstViewArray objectAtIndex:2]setValue:installVesselName forKey:@"value"];
        }
        else
        {
            [[firstViewArray objectAtIndex:2]setValue:@"" forKey:@"value"];
        }
    }
    else
    {
        [[firstViewArray objectAtIndex:2]setValue:@"" forKey:@"value"];
    }
    
    if (![installRegi isEqual:[NSNull null]])
    {
        if (installRegi != nil && installRegi != NULL && ![installRegi isEqualToString:@""] && ![installRegi isEqualToString:@"NA"])
        {
            [[firstViewArray objectAtIndex:3]setValue:installRegi forKey:@"value"];
        }
        else
        {
            [[firstViewArray objectAtIndex:3]setValue:@"NA" forKey:@"value"];
        }
    }
    else
    {
        [[firstViewArray objectAtIndex:3]setValue:@"NA" forKey:@"value"];
    }
    
    if (![installPhotoCounts isEqual:[NSNull null]])
    {
        if (installPhotoCounts != nil && installPhotoCounts != NULL && ![installPhotoCounts isEqualToString:@""])
        {
            [[thirdViewArray objectAtIndex:0]setValue:installPhotoCounts forKey:@"value"];
            
        }
        else
        {
            [[thirdViewArray objectAtIndex:0]setValue:@"" forKey:@"value"];
            
        }
        [tblThirdView reloadData];
    }
    else
    {
        [[thirdViewArray objectAtIndex:0]setValue:@"" forKey:@"value"];
        [tblThirdView reloadData];
    }
    [tblFirstView reloadData];
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
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(void)SetSignPaths:(NSNotification *)notifyDict
{
    NSMutableDictionary * tmpDict = [notifyDict object];
    strInstallerSignUrl = [tmpDict valueForKey:@"local_installer_sign"];
    strOwnerSignUrl =  [tmpDict valueForKey:@"local_owner_sign"];
    
    [detailDict setObject:strInstallerSignUrl forKey:@"local_installer_sign"];
    [detailDict setObject:strOwnerSignUrl forKey:@"local_owner_sign"];
}
#pragma mark - Webservice Methods
-(void)SaveInspectiontoServer
{
    NSString * strServerIDD = [self checkforValidString:[detailDict valueForKey:@"server_id"]];
    if (isInstalledDetailSynced || ![strServerIDD isEqualToString:@"NA" ])
    {
        [APP_DELEGATE endHudProcess];
        [APP_DELEGATE startHudProcess:@"Saving Inspection photos...."];
        [self saveInstallationPhotostoServer];
    }
    else
    {
        [APP_DELEGATE endHudProcess];
        [APP_DELEGATE startHudProcess:@"Saving Inspection details...."];
        
        NSString * strUserId = CURRENT_USER_ID;
        NSMutableDictionary * dict = [[NSMutableDictionary alloc]init];
        [dict setValue:strUserId forKey:@"user_id"];
        [dict setValue:[self checkforValidString:[detailDict valueForKey:@"imei"]] forKey:@"imei"];
        [dict setValue:[self checkforValidString:[detailDict valueForKey:@"device_type"]] forKey:@"device_type"];
        [dict setValue:[self checkforValidString:[detailDict valueForKey:@"warranty"]] forKey:@"warranty"];
        [dict setValue:[self checkforValidString:[detailDict valueForKey:@"vesselname"]] forKey:@"vessel_name"];
        [dict setValue:[self checkforValidString:[detailDict valueForKey:@"portno"]] forKey:@"port"];
        [dict setValue:[self checkforValidString:[detailDict valueForKey:@"owner_name"]] forKey:@"owner_name"];
        [dict setValue:[self checkforValidString:[detailDict valueForKey:@"owner_address"]] forKey:@"owner_address"];
        [dict setValue:[self checkforValidString:[detailDict valueForKey:@"owner_city"]] forKey:@"owner_city"];
        [dict setValue:[self checkforValidString:[detailDict valueForKey:@"owner_state"]] forKey:@"owner_state"];
        [dict setValue:[self checkforValidString:[detailDict valueForKey:@"owner_zipcode"]] forKey:@"owner_zipcode"];
        [dict setValue:[self checkforValidString:[detailDict valueForKey:@"owner_email"]] forKey:@"owner_email"];
        [dict setValue:[self checkforValidString:[detailDict valueForKey:@"owner_phone_no"]] forKey:@"owner_phone_no"];
        [dict setValue:[self checkforValidString:[detailDict valueForKey:@"created_at"]] forKey:@"inspection_date"];
        [dict setValue:[self checkforValidString:[detailDict valueForKey:@"insp_result"]] forKey:@"inspection_result"];
        [dict setValue:[self checkforValidString:[detailDict valueForKey:@"insp_action_taken"]] forKey:@"action_taken"];
        [dict setValue:[self checkforValidString:[detailDict valueForKey:@"inspection_date"]] forKey:@"inspection_date"];
        [dict setValue:installPhotoCounts forKey:@"image_count"];
        
        
        NSString * strOwnerUrl = [self documentsPathForFileName:[NSString stringWithFormat:@"Inspection/%@",[detailDict valueForKey:@"local_owner_sign"]]];
        NSData *ownerData = [NSData dataWithContentsOfFile:strOwnerUrl];
        
        NSString * strInstallUrl = [self documentsPathForFileName:[NSString stringWithFormat:@"Inspection/%@",[detailDict valueForKey:@"local_installer_sign"]]];
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
        manager.commandName = @"SaveInspection";
        manager.delegate = self;
        NSString *strServerUrl = @"http://succorfish.in/mobile/inspection";
        [manager postUrlCallForMultipleImage:strServerUrl withParameters:dict andMediaData:arr1 andDataParameterName:arr2 andFileName:arr3];
    }
}
-(void)SaveReporttoSuccorfishServer
{
    [APP_DELEGATE endHudProcess];
    [APP_DELEGATE startHudProcess:@"Saving details...."];
    
    NSString * strServerIDD = [self checkforValidString:[detailDict valueForKey:@"server_id"]];
    if (isInstalledDetailSynced || ![strServerIDD isEqualToString:@"NA" ])
    {
        NSString * strCheck1 = [NSString stringWithFormat:@"select * from tbl_uninstall where server_id = '%@'",strServerIDD];
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
        NSString * strUrl = [NSString stringWithFormat:@"https://ws.scstg.net/basic/v2/device/inspect/%@",strSuccorfishDeviceID];
        
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
        [args setObject:dict forKey:@"contactInfo"];
        [args setObject:txtResult.text forKey:@"notes"];
        [args setObject:strAcionServerValue forKey:@"operation"];

        URLManager *manager = [[URLManager alloc] init];
        manager.commandName = @"SaveInspectionSuccorfish";
        manager.delegate = self;
        [manager postUrlCall:strUrl withParameters:args];
    }
}
-(void)saveInstallSignaturesServer
{
    NSMutableDictionary * dict = [[NSMutableDictionary alloc]init];
    
    NSString * localPath = [self documentsPathForFileName:[NSString stringWithFormat:@"Inspection/%@",[detailDict valueForKey:@"local_installer_sign"]]];
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
    
    NSString * localPath = [self documentsPathForFileName:[NSString stringWithFormat:@"Inspection/%@",[detailDict valueForKey:@"local_owner_sign"]]];
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

-(void)saveInstallationPhotostoServer
{
    NSMutableArray * imgTempArr = [[NSMutableArray alloc] init];
    NSString * strQuery = [NSString stringWithFormat:@"select * from tbl_inspection_photo where insp_local_id = '%@' and is_sync = '0' and insp_photo_user_id ='%@'",strInstallID,CURRENT_USER_ID];
    [[DataBaseManager dataBaseManager] execute:strQuery resultsArray:imgTempArr];
    
    if ([imgTempArr count]>0)
    {
        NSMutableDictionary * dict = [[NSMutableDictionary alloc]init];
//        [dict setValue:CURRENT_USER_ID forKey:@"user_id"];
//        [dict setValue:serverInstallationID forKey:@"inspection_id"];
//        [dict setValue:[[imgTempArr objectAtIndex:0] valueForKey:@"photo_type"] forKey:@"image_type"];
        
        NSString * localPath = [NSString stringWithFormat:@"%@",[[imgTempArr objectAtIndex:0] valueForKey:@"insp_photo_local_url"]];
        NSString * filePath = [self documentsPathForFileName:[NSString stringWithFormat:@"InspectionPhotos/%@",localPath]];
        NSData *pngData = [NSData dataWithContentsOfFile:filePath];
        
        localImageId = [NSString stringWithFormat:@"%@",[[imgTempArr objectAtIndex:0] valueForKey:@"insp_photo_local_id"]];
        
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
-(void)getDeviceDetailService
{
    if ([APP_DELEGATE isNetworkreachable])
    {
        [APP_DELEGATE endHudProcess];
        [APP_DELEGATE startHudProcess:@"Getting details..."];
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
-(void)TestDeviceRomanAPI
{
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0ul);
    dispatch_async(queue, ^{
        {
            NSMutableDictionary *args = [[NSMutableDictionary alloc] init];
            
            NSString * strUrl = [NSString stringWithFormat:@"https://ws.scstg.net/basic/v2/waypoint/getLatest/%@",strSuccorfishDeviceID];

            
            NSString * strbasicAuthToken;
//            NSString * str = [NSString stringWithFormat:@"device_test:dac6hTQXJc"];
            NSString * strUserName = [NSString stringWithFormat:@"%@",CURRENT_USER_EMAIL];
            NSString * strPassword = [NSString stringWithFormat:@"%@",CURRENT_USER_PASS];
            NSString * str = [NSString stringWithFormat:@"%@:%@",strUserName,strPassword];

            NSString * simpleStr = [APP_DELEGATE base64String:str];
            strbasicAuthToken = simpleStr;

            
            AFHTTPRequestOperationManager *manager1 = [[AFHTTPRequestOperationManager alloc] initWithBaseURL:[NSURL URLWithString:@"http://server.url"]];
            //[manager1.requestSerializer setValue:@"multipart/form-data" forHTTPHeaderField:@"Content-Type"];
            NSString *authorization = [NSString stringWithFormat: @"Basic %@",strbasicAuthToken];
            [manager1.requestSerializer setValue:authorization forHTTPHeaderField:@"Authorization"];
            //[manager1.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Accept"];
            //manager1.responseSerializer = [AFHTTPResponseSerializer serializer];
            
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
                                //                    NSTimeZone *gmt = [NSTimeZone timeZoneWithAbbreviation:@"UTC"];
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
                    else
                    {
                        if ([responseObject isEqual:[NSNull null]] || [responseObject isEqualToString:@"<nil>"] || responseObject == NULL)
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
            
           /* NSString * strbasicAuthToken ;
            NSString * strAuthToken = [[NSUserDefaults standardUserDefaults] valueForKey:@"BasicAuthToken"];
            if ([[self checkforValidString:strAuthToken] isEqualToString:@"NA"])
            {
                NSString * strUsername = [[NSUserDefaults standardUserDefaults] valueForKey:@"CURRENT_USER_NAME"];
                NSString * strPassword = [[NSUserDefaults standardUserDefaults] valueForKey:@"CURRENT_USER_PASS"];
                
                NSString * str = [NSString stringWithFormat:@"%@:%@",strUsername,strPassword];
                NSString * simpleStr = [APP_DELEGATE base64String:str];
                strbasicAuthToken = simpleStr;
                [[NSUserDefaults standardUserDefaults] setValue:simpleStr forKey:@"BasicAuthToken"];
                [[NSUserDefaults standardUserDefaults] synchronize];
            }
            else
            {
                strbasicAuthToken = strAuthToken;
            }*/
            
            NSString * strbasicAuthToken;
            NSString * str = [NSString stringWithFormat:@"device_test:dac6hTQXJc"];
            NSString * simpleStr = [APP_DELEGATE base64String:str];
            strbasicAuthToken = simpleStr;
            if ([strUrl rangeOfString:@"staging"].location != NSNotFound)
            {
                strbasicAuthToken = [[NSUserDefaults standardUserDefaults] valueForKey:@"BasicAuthToken"];
            }

            
            AFHTTPRequestOperationManager *manager1 = [[AFHTTPRequestOperationManager alloc] initWithBaseURL:[NSURL URLWithString:@"http://server.url"]];
            //[manager1.requestSerializer setValue:@"multipart/form-data" forHTTPHeaderField:@"Content-Type"];
            NSString *authorization = [NSString stringWithFormat: @"Basic %@",strbasicAuthToken];
            [manager1.requestSerializer setValue:authorization forHTTPHeaderField:@"Authorization"];
            //[manager1.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Accept"];
            //manager1.responseSerializer = [AFHTTPResponseSerializer serializer];
            
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
    if (IS_IPHONE_X){[alertView showWithAnimation:URBAlertAnimationDefault];}                }
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
    alertView = [[URBAlertView alloc] initWithTitle:ALERT_TITLE message:@"Do you want to report this bug to the developer team?" cancelButtonTitle:OK_BTN otherButtonTitles: @"Cancel", nil];
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
#pragma mark - UrlManager Delegate
- (void)onResult:(NSDictionary *)result
{
    NSLog(@"The result is...%@", result);
    if ([[result valueForKey:@"commandName"] isEqualToString:@"SaveInspectionSuccorfish"])
    {
        [APP_DELEGATE endHudProcess];
        
        if ([[result valueForKey:@"result"] count]>=10)
        {
            NSMutableDictionary * tmpDict = [[NSMutableDictionary alloc] init];
            tmpDict = [[result valueForKey:@"result"] mutableCopy];
            
            serverInstallationID = [tmpDict valueForKey:@"id"];
            NSString * requestStr =[NSString stringWithFormat:@"update tbl_inspection set server_id = '%@' where id = '%@'",serverInstallationID,strInstallID];
            [[DataBaseManager dataBaseManager] execute:requestStr];
            [APP_DELEGATE endHudProcess];
            [APP_DELEGATE startHudProcess:@"Saving details...."];
            [APP_DELEGATE updateBadgeCount];
            [self saveInstallSignaturesServer];
        }
        else
        {
            if ([[result valueForKey:@"result"] isKindOfClass:[NSArray class]])
            {
                if ([[result valueForKey:@"result"] count]>0)
                {
                    [APP_DELEGATE endHudProcess];
                    
                        NSString * strErrorCode = [[[result valueForKey:@"result"] objectAtIndex:0] valueForKey:@"errorCode"];
                    if ([strErrorCode isEqualToString:@"device.cannot.inspect"] || [strErrorCode rangeOfString:@"device.cannot.inspect"].location != NSNotFound)

                    {
                        alertView = [[URBAlertView alloc] initWithTitle:ALERT_TITLE message:@"This device can not be inspected at this time." cancelButtonTitle:OK_BTN otherButtonTitles: nil, nil];
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
    else if ([[result valueForKey:@"commandName"] isEqualToString:@"SaveFile"])
    {
        [self CallCompleteServiceforInstallation];
    }
    else if ([[result valueForKey:@"commandName"] isEqualToString:@"SavePhotos"])
    {
        if ( [result valueForKey:@"result"] == [NSNull null])
        {
            NSString * requestStr =[NSString stringWithFormat:@"update tbl_inspection_photo set is_sync = 1 where insp_photo_local_id = '%@'",localImageId];
            [[DataBaseManager dataBaseManager] execute:requestStr];
        }
        else
        {
            NSString * requestStr =[NSString stringWithFormat:@"update tbl_inspection_photo set is_sync = 1 where insp_photo_local_id = '%@'",localImageId];
            [[DataBaseManager dataBaseManager] execute:requestStr];
        }
        [self saveInstallationPhotostoServer];
    }
    else if ([[result valueForKey:@"commandName"] isEqualToString:@"SaveInstallSign"])
    {
        if ( [result valueForKey:@"result"] == [NSNull null])
        {
            NSString * requestStr =[NSString stringWithFormat:@"update tbl_inspection set server_installer_sign = 1 where id = '%@'",strInstallID];
            [[DataBaseManager dataBaseManager] execute:requestStr];
        }
        else
        {
            NSString * requestStr =[NSString stringWithFormat:@"update tbl_inspection set server_installer_sign = 1 where id = '%@'",strInstallID];
            [[DataBaseManager dataBaseManager] execute:requestStr];
        }
        [self saveOwnerSignaturesServer];
    }
    else if ([[result valueForKey:@"commandName"] isEqualToString:@"SaveOwnerSign"])
    {
        if ( [result valueForKey:@"result"] == [NSNull null])
        {
            NSString * requestStr =[NSString stringWithFormat:@"update tbl_inspection set server_installer_sign = 1 where id = '%@'",strInstallID];
            [[DataBaseManager dataBaseManager] execute:requestStr];
        }
        else
        {
            NSString * requestStr =[NSString stringWithFormat:@"update tbl_inspection set server_owner_sign = 1 where id = '%@'",strInstallID];
            [[DataBaseManager dataBaseManager] execute:requestStr];
        }
        [self saveInstallationPhotostoServer];
    }

    else if ([[result valueForKey:@"commandName"] isEqualToString:@"SaveInspection"])
    {
        [APP_DELEGATE endHudProcess];
        if ([[[result valueForKey:@"result"] valueForKey:@"response"] isEqualToString:@"true"])
        {
            if ([[[result valueForKey:@"result"] valueForKey:@"message"] isEqualToString:@"Device not found with this IMEI!"])
            {
                NSString * strMsg = [[result valueForKey:@"result"] valueForKey:@"message"];
                alertView = [[URBAlertView alloc] initWithTitle:ALERT_TITLE message:strMsg cancelButtonTitle:OK_BTN otherButtonTitles: nil, nil];
                [alertView setMessageFont:[UIFont fontWithName:CGRegular size:14]];
                [alertView setHandlerBlock:^(NSInteger buttonIndex, URBAlertView *alertView) {
                    [alertView hideWithCompletionBlock:^{
                    }];
                }];
                [alertView showWithAnimation:URBAlertAnimationTopToBottom];
    if (IS_IPHONE_X){[alertView showWithAnimation:URBAlertAnimationDefault];}
            }
            else if ([[[result valueForKey:@"result"] valueForKey:@"message"] isEqualToString:@"Pattern.deviceInstallDto.contactInfo.telephone"])
            {
                alertView = [[URBAlertView alloc] initWithTitle:ALERT_TITLE message:@"Please enter Valid Mobile No" cancelButtonTitle:OK_BTN otherButtonTitles: nil, nil];
                [alertView setMessageFont:[UIFont fontWithName:CGRegular size:14]];
                [alertView setHandlerBlock:^(NSInteger buttonIndex, URBAlertView *alertView) {
                    [alertView hideWithCompletionBlock:^{
                        
                    }];
                }];
                [alertView showWithAnimation:URBAlertAnimationTopToBottom];
                if (IS_IPHONE_X){[alertView showWithAnimation:URBAlertAnimationDefault];}
            }
            else if ([[[result valueForKey:@"result"] valueForKey:@"message"] isEqualToString:@"NotBlank.deviceInspectDto.contactInfo.zipCode"])
            {
                alertView = [[URBAlertView alloc] initWithTitle:ALERT_TITLE message:@"Please enter Valid ZipCode" cancelButtonTitle:OK_BTN otherButtonTitles: nil, nil];
                [alertView setMessageFont:[UIFont fontWithName:CGRegular size:14]];
                [alertView setHandlerBlock:^(NSInteger buttonIndex, URBAlertView *alertView) {
                    [alertView hideWithCompletionBlock:^{
//                        [self.navigationController popViewControllerAnimated:YES];
                    }];
                }];
                [alertView showWithAnimation:URBAlertAnimationTopToBottom];
                if (IS_IPHONE_X){[alertView showWithAnimation:URBAlertAnimationDefault];}
            }
            else
            {
                isInstalledDetailSynced = YES;
                
                NSMutableDictionary * tmpDict = [[NSMutableDictionary alloc] init];
                tmpDict = [[result valueForKey:@"result"] valueForKey:@"data"];
                
                if (tmpDict == [NSNull null] || tmpDict == nil)
                {
                    
                }
                else
                {
                    serverInstallationID = [tmpDict valueForKey:@"id"];
                    NSString * strServerVesselId = [tmpDict valueForKey:@"id"];
                    
                    NSString * requestStr =[NSString stringWithFormat:@"update tbl_inspection set server_id = '%@', vessel_id = '%@', is_sync = 1 where id = '%@'",serverInstallationID,strServerVesselId,strInstallID];
                    [[DataBaseManager dataBaseManager] execute:requestStr];
                    
                    [APP_DELEGATE updateBadgeCount];
                    
                }
                
                [APP_DELEGATE endHudProcess];
                [APP_DELEGATE startHudProcess:@"Saving Inspection photos...."];
                
                [self saveInstallationPhotostoServer];
            }
        }
        else
        {
            if ([[[result valueForKey:@"result"] valueForKey:@"message"] isEqualToString:@"Invalid Token"])
            {
                [APP_DELEGATE showSessionExpirePopup];
            }
            else
            {
                NSString * strMsg = [[result valueForKey:@"result"] valueForKey:@"message"];
                alertView = [[URBAlertView alloc] initWithTitle:ALERT_TITLE message:strMsg cancelButtonTitle:OK_BTN otherButtonTitles: nil, nil];
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
    else if ([[result valueForKey:@"commandName"] isEqualToString:@"SendComplete"])
    {
        [APP_DELEGATE endHudProcess];
        NSString * requestStr =[NSString stringWithFormat:@"update tbl_inspection set is_sync = '1' where id = '%@'",strInstallID];
        [[DataBaseManager dataBaseManager] execute:requestStr];
        
        alertView = [[URBAlertView alloc] initWithTitle:ALERT_TITLE message:@"Inspection has been completed successfully." cancelButtonTitle:OK_BTN otherButtonTitles: nil, nil];
        [alertView setMessageFont:[UIFont fontWithName:CGRegular size:14]];
        [alertView setHandlerBlock:^(NSInteger buttonIndex, URBAlertView *alertView) {
            [alertView hideWithCompletionBlock:^{
//                [self.navigationController popViewControllerAnimated:YES];
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
            if ([[[result valueForKey:@"result"] valueForKey:@"message"] isEqualToString:@"Device already exists with this IMEI!"])
            {
                
                NSMutableDictionary * tmpDict = [[NSMutableDictionary alloc] init];
                tmpDict = [[[result valueForKey:@"result"] valueForKey:@"data"] mutableCopy];
                TestDeviceVC * testVC = [[TestDeviceVC alloc] init];
                testVC.detailDict =tmpDict;
                testVC.strReasonToCome = @"ReadytoUse";
                [self.navigationController pushViewController:testVC animated:YES];
                
            }
            else if ([[[result valueForKey:@"result"] valueForKey:@"message"] isEqualToString:@"Device not exists with this IMEI!"])
            {
                NSMutableDictionary * tmpDict = [[NSMutableDictionary alloc] init];
                tmpDict = [[result valueForKey:@"result"] valueForKey:@"data"];
                
                if (tmpDict == [NSNull null] || tmpDict == nil)
                {
                    NSString * strMessage = [NSString stringWithFormat:@"Something went wrong. Please try again."];
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
                    TestDeviceVC * testVC = [[TestDeviceVC alloc] init];
                    testVC.detailDict =tmpDict;
                    testVC.strReasonToCome = @"ReadytoUse";
                    [self.navigationController pushViewController:testVC animated:YES];
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
                    TestDeviceVC * testVC = [[TestDeviceVC alloc] init];
                    testVC.detailDict =tmpDict;
                    testVC.strReasonToCome = @"ReadytoUse";
                    [self.navigationController pushViewController:testVC animated:YES];
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
            
            NSIndexPath * nowIndex = [NSIndexPath indexPathForRow:3 inSection:0];
            InspectionCell *cell = [tblThirdView cellForRowAtIndexPath:nowIndex];
            
            if ([self GetdifferencebetweenFirstDate:date] == YES)
            {
                
                
                strInfoMsg = @"READY TO GO!";
                strStatus = @"Yes";
                cell.lblPositionMsg.text = strInfoMsg;
                cell.lblPositionMsg.textColor = UIColor.greenColor;

                //                UIImageView * imgInfo = (UIImageView *)[self.view viewWithTag:700+self->selectedIndex];
                //                imgInfo.hidden = YES;
                
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
            [tblThirdView reloadData];
            
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
    NSString * strQuery = [NSString stringWithFormat:@"select * from tbl_question where install_id = '%@' and type = 'inspection'",strInstallID];
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
        
        NSString * content = [NSString stringWithFormat:@"=============================================================================\r\nInspection Health and Safety Questionnaire\r\n============================================================================="];
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
#pragma mark - Navigation
Succorfish Ltd has invited you to test "Succorfish Installer App"
// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
