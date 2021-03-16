//
//  UnInstalledVC.m
//  Succorfish Installer App
//
//  Created by stuart watts on 03/03/2018.
//  Copyright © 2018 Kalpesh Panchasara. All rights reserved.
//

#import "UnInstalledVC.h"
#import "PSProfileStepper.h"
#import "BarcodeScanVC.h"
#import "TestDeviceVC.h"
#import "VesselVC.h"
#import "PhotoView.h"
#import "SignVC.h"
#import <MessageUI/MessageUI.h>
#import "UninstalledCell.h"
#import "DashboardVC.h"
@interface UnInstalledVC ()<URLManagerDelegate,MFMailComposeViewControllerDelegate>
{
    PSProfileStepper *stepperView;
    
    int indexOne, textSize, intInstallID;
    
    BOOL isSecondBuilt,isAgreed;
    
    NSString * strInstallID;
    
    UIImageView * imgCheck;
    
    NSString * strInstallerSignUrl, * strOwnerSignUrl;
    
    BOOL isTestDeviceDone;

}
@end

@implementation UnInstalledVC
@synthesize isFromeEdit,detailDict,installID;
- (void)viewDidLoad
{
    strInstallID = installID;
    isTestDeviceDone = NO;
    
    installScanID = @"";
    indexOne = 0;
    strInstallerSignUrl = @"NA";
    strOwnerSignUrl = @"NA";

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
    
    deviceTypeArr = [[NSMutableArray alloc] init];
    [deviceTypeArr addObject:@"SC2"];
    
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
    
    firstViewArray = [[NSMutableArray alloc]init];
    NSArray * arrayTitleFirst = [[NSArray alloc]initWithObjects:@"Scan Device",@"Device Type",@"Asset Name",@"Registration No.",@"Warranty Status", nil];
    for (int i=0; i<arrayTitleFirst.count; i++)
    {
        NSMutableDictionary *tmpDict = [[NSMutableDictionary alloc]initWithObjectsAndKeys:[arrayTitleFirst objectAtIndex:i],@"title",@"NA",@"value", nil];
        [firstViewArray addObject:tmpDict];
    }
    
    secondViewArray = [[NSMutableArray alloc]init];
    NSArray * arrayTitleSecond = [[NSArray alloc]initWithObjects:@"Owner Name",@"Address",@"City",@"State",@"Email",@"Mobile No.",@"Signatures",@"Warranty return",@"Test Device",nil];
    for (int i=0; i<arrayTitleSecond.count; i++)
    {
        NSMutableDictionary *tmpDict = [[NSMutableDictionary alloc]initWithObjectsAndKeys:[arrayTitleSecond objectAtIndex:i],@"title",@"NA",@"value", nil];
        [secondViewArray addObject:tmpDict];
    }
    [[secondViewArray objectAtIndex:3]setValue:@"NA" forKey:@"zipValue"];
    arrayTextFieldTagValues = [[NSArray alloc]initWithObjects:@"101",@"102",@"103",@"104",@"106",@"107",@"108",@"109",@"110", nil];
    
    [self setNavigationViewFrames];
    [self setContentViews];
    [self setFirstView];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"DeviceInfoForUninstall" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(fillDeviceDetails:) name:@"DeviceInfoForUninstall" object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"setSignaturePathsforUNInstalls" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(SetSignPaths:) name:@"setSignaturePathsforUNInstalls" object:nil];
    
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}
-(void)viewWillAppear:(BOOL)animated
{
    [APP_DELEGATE hideTabBar:self.tabBarController];
    [self checkForAppearFields];
    [super viewWillAppear:YES];
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
    [lblTitle setText:@"Uninstall"];
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
    stepperView.maxCount = 2;
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
    
    [scrlContent setContentSize:CGSizeMake(768*2, 1024)];
    [scrlContent setContentOffset:CGPointMake(0, 0) animated:YES];
    if (IS_IPHONE)
    {
        scrlContent.frame=CGRectMake(0, 109-30, DEVICE_WIDTH, DEVICE_HEIGHT-109-30);
        [scrlContent setContentSize:CGSizeMake(DEVICE_WIDTH*2, DEVICE_HEIGHT)];
    }
    if (IS_IPHONE_5)
    {
        scrlContent.frame=CGRectMake(0, 68, DEVICE_WIDTH, DEVICE_HEIGHT-68-45);
    }
    if (IS_IPHONE_4)
    {
        scrlContent.frame=CGRectMake(0, 64, DEVICE_WIDTH, DEVICE_HEIGHT-64-45);
        [scrlContent setContentSize:CGSizeMake(DEVICE_WIDTH*2, DEVICE_HEIGHT)];
    }
    if (IS_IPHONE_X)
    {
        scrlContent.frame=CGRectMake(0, 140, DEVICE_WIDTH, DEVICE_HEIGHT-140-40-45);
        [scrlContent setContentSize:CGSizeMake(DEVICE_WIDTH*2, DEVICE_HEIGHT)];
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


#pragma mark - Details from Barcode
-(void)fillDeviceDetails:(NSNotification *)notify
{
    NSMutableDictionary * dict = [notify object];
    detailDict = [dict mutableCopy];
    
    installScanID = [detailDict valueForKey:@"imei"];
    installVesselName = [self checkforValidStringForEdit:[detailDict valueForKey:@"vesselname"]];
    installRegi = [self checkforValidStringForEdit:[detailDict valueForKey:@"portno"]];
    installedVesselID = [self checkforValidStringForEdit:[detailDict valueForKey:@"vessel_id"]];

    if (firstViewArray.count >= 4)
    {
        [[firstViewArray objectAtIndex:0] setValue:[self checkforValidStringForEdit:[detailDict valueForKey:@"imei"]] forKey:@"value"];
        [[firstViewArray objectAtIndex:1] setValue:[self checkforValidStringForEdit:[detailDict valueForKey:@"device_type"]] forKey:@"value"];
        [[firstViewArray objectAtIndex:2] setValue:[self checkforValidStringForEdit:[detailDict valueForKey:@"vesselname"]] forKey:@"value"];
        [[firstViewArray objectAtIndex:3] setValue:[APP_DELEGATE checkforValidString:[detailDict valueForKey:@"portno"]] forKey:@"value"];
        [[firstViewArray objectAtIndex:4] setValue:[self checkforValidStringForEdit:[detailDict valueForKey:@"warranty"]] forKey:@"value"];
    }
    if (isSecondBuilt)
    {
        if (secondViewArray.count >= 8)
        {
            [[secondViewArray objectAtIndex:0] setValue:[self checkforValidStringForEdit:[detailDict valueForKey:@"owner_name"]] forKey:@"value"] ;
            [[secondViewArray objectAtIndex:1] setValue:[self checkforValidStringForEdit:[self checkforValidStringForEdit:[detailDict valueForKey:@"owner_address"]]] forKey:@"value"];
            [[secondViewArray objectAtIndex:2] setValue:[self checkforValidStringForEdit:[detailDict valueForKey:@"owner_city"]] forKey:@"value"];
            [[secondViewArray objectAtIndex:3] setValue:[self checkforValidStringForEdit:[detailDict valueForKey:@"owner_state"]] forKey:@"value"];
            [[secondViewArray objectAtIndex:4] setValue:[self checkforValidStringForEdit:[detailDict valueForKey:@"owner_email"]] forKey:@"value"];
            [[secondViewArray objectAtIndex:5] setValue:[self checkforValidStringForEdit:[detailDict valueForKey:@"owner_phone_no"]] forKey:@"value"];
            [[secondViewArray objectAtIndex:3] setValue:[self checkforValidStringForEdit:[detailDict valueForKey:@"owner_zipcode"]] forKey:@"zipValue"];
        }
       

        
        NSString * filePath = [self documentsPathForFileName:[NSString stringWithFormat:@"UnInstallSigns/%@",[detailDict valueForKey:@"local_sign_url"]]];
        NSData *pngData = [NSData dataWithContentsOfFile:filePath];
        UIImage *image = [UIImage imageWithData:pngData];
        signImgView.image = image;
        
        if (signImgView.image != nil)
        {
            imgCheck.image = [UIImage imageNamed:@"checked.png"];
            isAgreed = YES;
        }
        [tblSecondView reloadData];
    }
    
    [self GetVesselInformation];
    [tblFirstView reloadData];
}
#pragma mark - First View Setup
-(void)setFirstView
{
    [firstView removeFromSuperview];
    firstView = [[UIView alloc] init];
    firstView.frame = CGRectMake(0, 0, DEVICE_WIDTH, scrlContent.frame.size.height);
    firstView.backgroundColor = [UIColor clearColor];
    [scrlContent addSubview:firstView];
    
    int yy = 20;
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

    if (isFromeEdit)
    {
        installScanID = [detailDict valueForKey:@"imei"];
        installVesselName = [self checkforValidStringForEdit:[detailDict valueForKey:@"vesselname"]];
        installRegi = [self checkforValidStringForEdit:[detailDict valueForKey:@"portno"]];
        installedVesselID = [self checkforValidStringForEdit:[detailDict valueForKey:@"vessel_id"]];

        
        if (firstViewArray.count >= 4)
        {
            [[firstViewArray objectAtIndex:0] setValue:[self checkforValidStringForEdit:[detailDict valueForKey:@"imei"]] forKey:@"value"];
            [[firstViewArray objectAtIndex:1] setValue:[self checkforValidStringForEdit:[detailDict valueForKey:@"device_type"]] forKey:@"value"];
            [[firstViewArray objectAtIndex:2] setValue:[self checkforValidStringForEdit:[detailDict valueForKey:@"vesselname"]] forKey:@"value"];
            [[firstViewArray objectAtIndex:3] setValue:[APP_DELEGATE checkforValidString:[detailDict valueForKey:@"portno"]] forKey:@"value"];
            [[firstViewArray objectAtIndex:4] setValue:[self checkforValidStringForEdit:[detailDict valueForKey:@"warranty"]] forKey:@"value"];
        }
        
        [tblFirstView reloadData];
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
    [thirdView removeFromSuperview];
    thirdView = [[UIScrollView alloc] init];
    thirdView.frame = CGRectMake(DEVICE_WIDTH, 0, DEVICE_WIDTH, scrlContent.frame.size.height+ 40);
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
    int textHeight = 50;
    int gapB = 10;

    if (IS_IPHONE_4)
    {
        yy = 20;
        textHeight = 40;
        textSize = 15;
        gapB = 0;
    }
    else if ( IS_IPHONE_5)
    {
        yy = 20;
        textSize = 15;
        gapB = 0;
        textHeight = 45;

    }
    else if (IS_IPHONE_6)
    {
        yy = 40;
        gapB = 5;
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
    [thirdView addSubview:tblSecondView];


//    if (isFromeEdit)
    {
        if (secondViewArray.count >= 8)
        {
            [[secondViewArray objectAtIndex:0] setValue:[self checkforValidStringForEdit:[detailDict valueForKey:@"owner_name"]] forKey:@"value"];
            [[secondViewArray objectAtIndex:1] setValue:[self checkforValidStringForEdit:[detailDict valueForKey:@"owner_address"]] forKey:@"value"];
            [[secondViewArray objectAtIndex:2] setValue:[self checkforValidStringForEdit:[detailDict valueForKey:@"owner_city"]] forKey:@"value"];
            [[secondViewArray objectAtIndex:3] setValue:[self checkforValidStringForEdit:[detailDict valueForKey:@"owner_state"]] forKey:@"value"];
            [[secondViewArray objectAtIndex:4] setValue:[self checkforValidStringForEdit:[detailDict valueForKey:@"owner_email"]] forKey:@"value"];
            [[secondViewArray objectAtIndex:5] setValue:[self checkforValidStringForEdit:[detailDict valueForKey:@"owner_phone_no"]] forKey:@"value"];
            [[secondViewArray objectAtIndex:3] setValue:[self checkforValidStringForEdit:[detailDict valueForKey:@"owner_zipcode"]] forKey:@"zipValue"];
        }

        
        strInstallerSignUrl = [self checkforValidString:[detailDict valueForKey:@"local_installer_sign"]];
        strOwnerSignUrl = [self checkforValidString:[detailDict valueForKey:@"local_owner_sign"]] ;

        [tblSecondView reloadData];
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
    else
    {
        return secondViewArray.count;
    }
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellReuseIdentifier = @"cellIdentifier";
    UninstalledCell *cell = [tableView dequeueReusableCellWithIdentifier:cellReuseIdentifier];
    if (cell == nil)
    {
        cell = [[UninstalledCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellReuseIdentifier];
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
        cell.lblPositionMsg.hidden = true;
        cell.lblLastReport.hidden = true;
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
        cell.txtName.placeholder = [[secondViewArray objectAtIndex:indexPath.row]valueForKey:@"title"];
        cell.txtZip.tag = 200 + indexPath.row + 1;
        
        
        if(indexPath.row == 3)
        {
            cell.txtZip.hidden = false;
//            cell.txtZip.tag = 105;
            cell.txtZip.delegate = self;
            cell.lblZipLine.hidden = false;
            cell.txtZip.hidden = false;
            cell.txtZip.text = [[secondViewArray objectAtIndex:indexPath.row]valueForKey:@"zipValue"];
            cell.lblLine.frame = CGRectMake(10,textHeight,(DEVICE_WIDTH/2)-20, 1);
            cell.txtName.frame = CGRectMake(10, 8, (DEVICE_WIDTH/2)-20, textHeight-8);
            cell.txtZip.frame = CGRectMake((DEVICE_WIDTH/2)+10, 8, (DEVICE_WIDTH/2)-20, textHeight-8);
            cell.lblZipLine.frame = CGRectMake((DEVICE_WIDTH/2)+10,textHeight,(DEVICE_WIDTH/2)-20, 1);
            if ([[APP_DELEGATE checkforValidString:[[secondViewArray objectAtIndex:indexPath.row]valueForKey:@"zipValue"]]isEqualToString:@"NA"])
            {
                cell.txtZip.text = @"";
            }
            else
            {
                cell.txtZip.text = [self checkforValidString:[[secondViewArray objectAtIndex:indexPath.row]valueForKey:@"zipValue"]];
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
        if (indexPath.row == 6 ||indexPath.row == 7 || indexPath.row == 8)
        {
            cell.txtName.hidden = true;
            cell.lblName.hidden = false;
            cell.imgArrow.hidden = false;
            cell.lblName.frame = CGRectMake(10,0, (DEVICE_WIDTH/2)-10, textHeight);
            cell.imgArrow.frame = CGRectMake(DEVICE_WIDTH-20, (textHeight/2)-7.5, 9, 15);
            cell.lblName.text = [[secondViewArray objectAtIndex:indexPath.row]valueForKey:@"title"];
            if (indexPath.row == 8)
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
            cell.lblPositionMsg.hidden = true;
            cell.lblLastReport.hidden = true;
            cell.txtName.hidden = false;
            cell.lblName.hidden = true;
            cell.imgArrow.hidden = true;
            if ([[self checkforValidString:[[secondViewArray objectAtIndex:indexPath.row]valueForKey:@"value"]]isEqualToString:@"NA"])
            {
                cell.txtName.text = @"";
            }
            else
            {
                cell.txtName.text = [self checkforValidString:[[secondViewArray objectAtIndex:indexPath.row]valueForKey:@"value"]];
            }
        }
        
       
    }
    [APP_DELEGATE getPlaceholderText:cell.txtName andColor:UIColor.whiteColor];
    [APP_DELEGATE getPlaceholderText:cell.txtZip andColor:UIColor.whiteColor];
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
            barcodeVC.isFromInstall = @"UnInstall";
            [self.navigationController pushViewController:barcodeVC animated:YES];
        }
        else if (indexPath.row == 1)
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
        else if (indexPath.row == 2)
        {
            VesselVC * vessel = [[VesselVC alloc] init];
            [self.navigationController pushViewController:vessel animated:YES];
        }
        else if (indexPath.row == 3)
        {
            VesselVC * vessel = [[VesselVC alloc] init];
            [self.navigationController pushViewController:vessel animated:YES];
        }
    }
    else if (tableView == tblSecondView)
    {
        if (indexPath.row == 6)
        {
            if (IS_IPHONE_4 || IS_IPHONE_5 ||  IS_IPHONE_6)
            {
                [UIView animateWithDuration:0.4 animations:^{
                    [thirdView setFrame:CGRectMake(DEVICE_WIDTH, 0, DEVICE_WIDTH, scrlContent.frame.size.height+ 40)];
                }];
            }
            
            SignVC * signV = [[SignVC alloc] init];
            signV.isFromEdit = isFromeEdit;
            signV.detailDict = detailDict;
            signV.strInstallId = strInstallID;
            signV.strFromView = @"UnInstall";
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
        else if (indexPath.row == 7)
        {
            if (IS_IPHONE_4 || IS_IPHONE_5 ||  IS_IPHONE_6)
            {
                [UIView animateWithDuration:0.4 animations:^{
                    [thirdView setFrame:CGRectMake(DEVICE_WIDTH, 0, DEVICE_WIDTH, scrlContent.frame.size.height+ 40)];
                }];
                
            }
            [self btnWarrantClick];
        }
        else if (indexPath.row == 8)
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
        
        [[NSNotificationCenter defaultCenter] removeObserver:self name:@"DeviceInfoForUninstall" object:nil];

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
            [self SaveDataforSecondViewBack];
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
                NSString * strOwner = [self checkforValidString:[detailDict valueForKey:@"owner_name"]];
                NSString * strEmail = [self checkforValidString:[detailDict valueForKey:@"owner_email"]];
                NSString * strAddress = [self checkforValidString:[detailDict valueForKey:@"owner_address"]];
                NSString * strMobile = [self checkforValidString:[detailDict valueForKey:@"owner_phone_no"]];
                NSString * strCity = [self checkforValidString:[detailDict valueForKey:@"owner_city"]];
                NSString * strState = [self checkforValidString:[detailDict valueForKey:@"owner_state"]];
                NSString * strZipCode = [self checkforValidString:[detailDict valueForKey:@"owner_zipcode"]];

                NSString * requestStr =[NSString stringWithFormat:@"Update 'tbl_uninstall'  set 'owner_name' =\"%@\", 'owner_email' = \"%@\",'owner_address'=\"%@\",'owner_phone_no'=\"%@\",'owner_city'=\"%@\",'owner_state'=\"%@\",'owner_zipcode'=\"%@\",'complete_status'='INCOMPLETE' where id ='%@'",strOwner,strEmail,strAddress,strMobile,strCity,strState,strZipCode,strInstallID];
                [[DataBaseManager dataBaseManager] execute:requestStr];
                
                if (isSecondBuilt)
                {
                }
                else
                {
                    [self setSecondView];
                    isSecondBuilt = YES;
                }
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
    else if(indexOne == 1)
    {
        if ([self validationforSecondView])
        {
            if (isTestDeviceDone)
            {
                [self InsertDataforSecondView];
                
                if ([APP_DELEGATE isNetworkreachable])
                {
                    [self SaveReporttoSuccorfishServer];
                }
                else
                {
                    URBAlertView *alertView = [[URBAlertView alloc] initWithTitle:ALERT_TITLE message:@"Report has been saved successfully but not submitted to server because of No intenet connection. Please sync it later when internet available." cancelButtonTitle:OK_BTN otherButtonTitles: nil, nil];
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
                URBAlertView *alertView = [[URBAlertView alloc] initWithTitle:ALERT_TITLE message:@"Please tap on Test Device first to check the status of Device." cancelButtonTitle:OK_BTN otherButtonTitles: nil, nil];
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
    
    if (indexOne==1)
    {
        [moveFrwdBtn setTitle:@"SUBMIT" forState:UIControlStateNormal];
    }
    else
    {
        [moveFrwdBtn setTitle:@"NEXT" forState:UIControlStateNormal];
    }
}



-(void)btnConditions
{
    
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
    
    NSString * strMsg = [NSString stringWithFormat:@"Device %@ from %@ & %@ will be returned for warranty inspection. Its warranty status %@ and was inspected by %@ on %@.",installScanID,installVesselName,installRegi,[self checkforValidString:[[firstViewArray objectAtIndex:4]valueForKey:@"value"]],strName,currentTime];
    
    // To address
    NSArray *toRecipents = [NSArray arrayWithObject:@"warranties@succorfish.com"];
    
    MFMailComposeViewController *mc = [[MFMailComposeViewController alloc] init];
    mc.mailComposeDelegate = self;
    [mc setSubject:emailTitle];
    [mc setMessageBody:strMsg isHTML:NO];
    [mc setToRecipients:toRecipents];
    
    
    
    // Present mail view controller on screen
    //    UINavigationController * navv = [[UINavigationController alloc] initWithRootViewController:mc];
    
    
    if (mc == nil)
    {
        URBAlertView *alertView = [[URBAlertView alloc] initWithTitle:ALERT_TITLE message:@"Please set up a Mail account in order to send email." cancelButtonTitle:OK_BTN otherButtonTitles: nil, nil];
        
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
        URBAlertView *alertView = [[URBAlertView alloc] initWithTitle:ALERT_TITLE message:@"Please get device id first by using Scan device option." cancelButtonTitle:OK_BTN otherButtonTitles: nil, nil];

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
        URBAlertView *alertView = [[URBAlertView alloc] initWithTitle:ALERT_TITLE message:@"Please select device type." cancelButtonTitle:OK_BTN otherButtonTitles: nil, nil];

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
-(BOOL)validationforSecondView
{
    BOOL isAvail = NO;
    if([[[secondViewArray objectAtIndex:0] valueForKey:@"value"] length] == 0 || [[secondViewArray objectAtIndex:0] valueForKey:@"value"] == nil || [[APP_DELEGATE checkforValidString:[[secondViewArray objectAtIndex:0] valueForKey:@"value"]] isEqualToString:@"NA"] || [[[secondViewArray objectAtIndex:0] valueForKey:@"value"] isEqualToString:@" "])
    {
        [self showMessagewithText:@"Please enter Owner name."];
    }
    else if ([[[secondViewArray objectAtIndex:1] valueForKey:@"value"] length] == 0 || [[secondViewArray objectAtIndex:1] valueForKey:@"value"] == nil || [[APP_DELEGATE checkforValidString:[[secondViewArray objectAtIndex:1] valueForKey:@"value"]] isEqualToString:@"NA"] || [[[secondViewArray objectAtIndex:1] valueForKey:@"value"] isEqualToString:@" "])
    {
        [self showMessagewithText:@"Please enter Owner address."];
    }
    else if ([[[secondViewArray objectAtIndex:3] valueForKey:@"zipValue"] length] == 0 || [[secondViewArray objectAtIndex:3] valueForKey:@"zipValue"] == nil || [[APP_DELEGATE checkforValidString:[[secondViewArray objectAtIndex:3] valueForKey:@"zipValue"]] isEqualToString:@"NA"] || [[[secondViewArray objectAtIndex:3] valueForKey:@"zipValue"] isEqualToString:@" "])
    {
        [self showMessagewithText:@"Please enter ZipCode."];
    }
    else if ([[[secondViewArray objectAtIndex:4] valueForKey:@"value"] length] == 0 || [[secondViewArray objectAtIndex:4] valueForKey:@"value"] == nil || [[APP_DELEGATE checkforValidString:[[secondViewArray objectAtIndex:4] valueForKey:@"value"]] isEqualToString:@"NA"] || [[[secondViewArray objectAtIndex:4] valueForKey:@"value"] isEqualToString:@" "])
    {
        [self showMessagewithText:@"Please enter Owner email address."];
    }
    else if(![self validateEmailHere:[[secondViewArray objectAtIndex:4]valueForKey:@"value"]])
    {
        [self showMessagewithText:@"Please enter valid email address"];
    }
    else if ([[[secondViewArray objectAtIndex:5] valueForKey:@"value"] length] == 0 || [[secondViewArray objectAtIndex:5] valueForKey:@"value"] == nil || [[APP_DELEGATE checkforValidString:[[secondViewArray objectAtIndex:5] valueForKey:@"value"]] isEqualToString:@"NA"] || [[[secondViewArray objectAtIndex:5] valueForKey:@"value"] isEqualToString:@" "])
    {
        [self showMessagewithText:@"Please enter Owner mobile number."];
    }
    else if([[[secondViewArray objectAtIndex:5]valueForKey:@"value"]length]<10)
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
    URBAlertView *alertView = [[URBAlertView alloc] initWithTitle:ALERT_TITLE message:strText cancelButtonTitle:OK_BTN otherButtonTitles: nil, nil];
    
    [alertView setMessageFont:[UIFont fontWithName:CGRegular size:14]];
    [alertView setHandlerBlock:^(NSInteger buttonIndex, URBAlertView *alertView) {
        [alertView hideWithCompletionBlock:^{
        }];
    }];
    [alertView showWithAnimation:URBAlertAnimationTopToBottom];
    if (IS_IPHONE_X){[alertView showWithAnimation:URBAlertAnimationDefault];}
}
-(void)btnTestDevClick
{
    isTestDeviceDone = YES;
    
    if ([APP_DELEGATE isNetworkreachable])
    {
        [self TestDeviceRomanAPI];
    }
    else
    {
        URBAlertView *alertView = [[URBAlertView alloc] initWithTitle:ALERT_TITLE message:@"There is no internet connection. Please connect to internet first then try again later." cancelButtonTitle:OK_BTN otherButtonTitles: nil, nil];
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
        
//        NSString * strEmi = [self checkforValidString:[lblDeviceID.text]];
//        NSString * strDeviceType = [self checkforValidString:lblDeviceType.text];
        NSString * strEmi = [self checkforValidString:[[firstViewArray objectAtIndex:0]valueForKey:@"value"]];
        NSString * strDeviceType = [self checkforValidString:[[firstViewArray objectAtIndex:1]valueForKey:@"value"]];

        NSString * strVesselID = [self checkforValidString:installedVesselID];
        NSString * strVesselName = [self checkforValidString:installVesselName];
        NSString * strRegiNo = [self checkforValidString:installRegi];
        NSString * strWarranty = [self checkforValidString:[[firstViewArray objectAtIndex:4]valueForKey:@"value"]];
        
        
        [detailDict setObject:strEmi forKey:@"imei"];
        [detailDict setObject:strDeviceType forKey:@"device_type"];
        [detailDict setObject:strVesselName forKey:@"vesselname"];
        [detailDict setObject:strRegiNo forKey:@"portno"];
        [detailDict setObject:strWarranty forKey:@"warranty"];

        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"YYYY-MM-dd HH:mm"];
        NSString *currentTime = [dateFormatter stringFromDate:[NSDate date]];
        
        
        NSString * requestStr =[NSString stringWithFormat:@"update 'tbl_uninstall' set 'user_id' = \"%@\",'imei' = \"%@\",'device_type' = \"%@\",'updated_at' = \"%@\", 'vessel_id' = \"%@\",'vesselname' = \"%@\",'portno' = \"%@\",'warranty' = \"%@\",'succor_device_id'=\"%@\" where id ='%@'",strUserID,strEmi,strDeviceType,currentTime,strVesselID,strVesselName,strRegiNo,strWarranty,strSuccorfishDeviceID,strInstallID];
        [[DataBaseManager dataBaseManager] execute:requestStr];
    }
    else
    {
        NSString * strUserID = [self checkforValidString:CURRENT_USER_ID];
        
//        NSString * strEmi = [self checkforValidString:lblDeviceID.text];
        //        NSString * strDeviceType = [self checkforValidString:lblDeviceType.text];

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
        [detailDict setObject:currentTime forKey:@"uninstall_date"];

        if (isSecondBuilt)
        {
            NSString * requestStr =[NSString stringWithFormat:@"update 'tbl_uninstall' set 'user_id' = \"%@\",'imei' = \"%@\",'device_type' = \"%@\",'updated_at' = \"%@\", 'vessel_id' = \"%@\",'vesselname' = \"%@\",'portno' = \"%@\",'warranty' = \"%@\", 'succor_device_id'= \"%@\" where id ='%@'",strUserID,strEmi,strDeviceType,currentTime,strVesselID,strVesselName,strRegiNo,strWarranty,strSuccorfishDeviceID,strInstallID];
            [[DataBaseManager dataBaseManager] execute:requestStr];
        }
        else
        {
            
            NSString * requestStr = [NSString stringWithFormat:@"update 'tbl_uninstall' set 'user_id' = \"%@\",'imei' = \"%@\",'device_type' = \"%@\",'created_at' = \"%@\",'vessel_id' = \"%@\",'vesselname' = \"%@\",'portno' = \"%@\",'warranty' = \"%@\",'createdTimeStamp' = \"%@\",'uninstall_date' = \"%@\",'complete_status' = 'INCOMPLETE','succor_device_id' = \"%@\" where id = '%@'",strUserID,strEmi,strDeviceType,currentTime,strVesselID,strVesselName,strRegiNo,strWarranty,strcurTimeStamp,currentTime,strSuccorfishDeviceID,strInstallID];
            
            if (isFromeEdit)
            {
               requestStr =[NSString stringWithFormat:@"insert into 'tbl_uninstall'('user_id','imei','device_type','created_at','vessel_id','vesselname','portno','warranty','createdTimeStamp','uninstall_date','complete_status','succor_device_id') values(\"%@\",\"%@\",\"%@\",\"%@\",\"%@\",\"%@\",\"%@\",\"%@\",\"%@\",\"%@\",'COMPLETE',\"%@\")",strUserID,strEmi,strDeviceType,currentTime,strVesselID,strVesselName,strRegiNo,strWarranty,strcurTimeStamp,currentTime,strSuccorfishDeviceID];
                
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
                
                NSString * strQuery =[NSString stringWithFormat:@"update 'tbl_uninstall' set 'date1' = \"%@\",'date2' = \"%@\",'date3' = \"%@\",'date4' = \"%@\",'date5' = \"%@\",'date6' = \"%@\" where id ='%@'",strDate1,strDate2,strDate3,strDate4,strDate5,strDate6,strInstallID];
                [[DataBaseManager dataBaseManager] execute:strQuery];
            }
        }
    }
}
-(void)InsertDataforSecondView
{
    NSString * strOwner = [self checkforValidString:[[secondViewArray objectAtIndex:0]valueForKey:@"value"]];
    NSString * strAddress = [self checkforValidString:[[secondViewArray objectAtIndex:1]valueForKey:@"value"]];
    NSString * strCity = [self checkforValidString:[[secondViewArray objectAtIndex:2]valueForKey:@"value"]];
    NSString * strState = [self checkforValidString:[[secondViewArray objectAtIndex:3]valueForKey:@"value"]];
    NSString * strZipCode = [self checkforValidString:[[secondViewArray objectAtIndex:3]valueForKey:@"zipValue"]];
    NSString * strEmail = [self checkforValidString:[[secondViewArray objectAtIndex:4]valueForKey:@"value"]];
    NSString * strMobile = [self checkforValidString:[[secondViewArray objectAtIndex:5]valueForKey:@"value"]];

    [detailDict setObject:strOwner forKey:@"owner_name"];
    [detailDict setObject:strEmail forKey:@"owner_email"];
    [detailDict setObject:strAddress forKey:@"owner_address"];
    [detailDict setObject:strMobile forKey:@"owner_phone_no"];
    [detailDict setObject:strCity forKey:@"owner_city"];
    [detailDict setObject:strState forKey:@"owner_state"];
    [detailDict setObject:strZipCode forKey:@"owner_zipcode"];

    NSString * requestStr =[NSString stringWithFormat:@"Update 'tbl_uninstall'  set 'owner_name' =\"%@\", 'owner_email' = \"%@\",'owner_address'=\"%@\",'owner_phone_no'=\"%@\",'owner_city'=\"%@\",'owner_state'=\"%@\",'owner_zipcode'=\"%@\",'complete_status'='COMPLETE' where id ='%@'",strOwner,strEmail,strAddress,strMobile,strCity,strState,strZipCode,strInstallID];
    [[DataBaseManager dataBaseManager] execute:requestStr];
    
    [tblSecondView reloadData];
}

-(void)SaveDataforSecondViewBack
{
    NSString * strOwner = [self checkforValidString:[[secondViewArray objectAtIndex:0]valueForKey:@"value"]];
    NSString * strAddress = [self checkforValidString:[[secondViewArray objectAtIndex:1]valueForKey:@"value"]];
    NSString * strCity = [self checkforValidString:[[secondViewArray objectAtIndex:2]valueForKey:@"value"]];
    NSString * strState = [self checkforValidString:[[secondViewArray objectAtIndex:3]valueForKey:@"value"]];
    NSString * strZipCode = [self checkforValidString:[[secondViewArray objectAtIndex:3]valueForKey:@"zipValue"]];
    NSString * strEmail = [self checkforValidString:[[secondViewArray objectAtIndex:4]valueForKey:@"value"]];
    NSString * strMobile = [self checkforValidString:[[secondViewArray objectAtIndex:5]valueForKey:@"value"]];

    
    [detailDict setObject:strOwner forKey:@"owner_name"];
    [detailDict setObject:strEmail forKey:@"owner_email"];
    [detailDict setObject:strAddress forKey:@"owner_address"];
    [detailDict setObject:strMobile forKey:@"owner_phone_no"];
    [detailDict setObject:strCity forKey:@"owner_city"];
    [detailDict setObject:strState forKey:@"owner_state"];
    [detailDict setObject:strZipCode forKey:@"owner_zipcode"];
    
    NSString * requestStr =[NSString stringWithFormat:@"Update 'tbl_uninstall'  set 'owner_name' =\"%@\", 'owner_email' = \"%@\",'owner_address'=\"%@\",'owner_phone_no'=\"%@\",'owner_city'=\"%@\",'owner_state'=\"%@\",'owner_zipcode'=\"%@\" where id ='%@'",strOwner,strEmail,strAddress,strMobile,strCity,strState,strZipCode,strInstallID];
    [[DataBaseManager dataBaseManager] execute:requestStr];
    
    [tblSecondView reloadData];
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
            label.text = [powerArr objectAtIndex:row];
            return label;
        }
    }
    return label;
}

-(void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    if (pickerView.tag == 123)
    {
        if (firstViewArray.count >= 4)
        {
            [[firstViewArray objectAtIndex:1]setValue:[deviceTypeArr objectAtIndex:row] forKey:@"value"];
            [tblFirstView reloadData];
        }
    }
}

-(void)btnDoneClicked:(id)sender
{
    if ([sender tag] == 123)
    {
        NSInteger index = [deviceTypePicker selectedRowInComponent:0];
        if ([deviceTypeArr count] >= index)
        {
            if (firstViewArray.count >= 4)
            {
                [[firstViewArray objectAtIndex:1] setValue:[deviceTypeArr objectAtIndex:index] forKey:@"value"];
                [tblFirstView reloadData];
            }
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
                [thirdView setFrame:CGRectMake(DEVICE_WIDTH, (heightKeyBrd-height)-45-50, DEVICE_WIDTH, scrlContent.frame.size.height+ 40)];
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
                    [thirdView setFrame:CGRectMake(DEVICE_WIDTH, (heightKeyBrd-height)-45-50, DEVICE_WIDTH, scrlContent.frame.size.height+ 40)];
                }];
        }
        if (IS_IPHONE_6)
        {
            [UIView animateWithDuration:0.5 animations:^{
                [thirdView setFrame:CGRectMake(DEVICE_WIDTH, (heightKeyBrd-height)-45-50, DEVICE_WIDTH, scrlContent.frame.size.height+ 40)];
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
    if (IS_IPHONE_4 || IS_IPHONE_5 ||  IS_IPHONE_6)
    {
        [UIView animateWithDuration:0.4 animations:^{
            [thirdView setFrame:CGRectMake(DEVICE_WIDTH, 0, DEVICE_WIDTH, scrlContent.frame.size.height+ 40)];
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

-(void)checkForAppearFields
{
    if (![installScanID isEqual:[NSNull null]])
    {
        if (installScanID != nil && installScanID != NULL && ![installScanID isEqualToString:@""])
        {
            [[firstViewArray objectAtIndex:0] setValue:installScanID forKey:@"value"];
        }
        else
        {
            [[firstViewArray objectAtIndex:0] setValue:@"" forKey:@"value"];
        }
    }
    else
    {
        [[firstViewArray objectAtIndex:0] setValue:@"" forKey:@"value"];
    }
    
    if (![installVesselName isEqual:[NSNull null]])
    {
        if (installVesselName != nil && installVesselName != NULL && ![installVesselName isEqualToString:@""] && ![installVesselName isEqualToString:@"NA"])
        {
//            lblVessel.text = installVesselName;
            [[firstViewArray objectAtIndex:2] setValue:installVesselName forKey:@"value"];
        }
        else
        {
            [[firstViewArray objectAtIndex:2] setValue:@"" forKey:@"value"];
        }
    }
    else
    {
        [[firstViewArray objectAtIndex:2] setValue:@"" forKey:@"value"];
    }
    
    if (![installRegi isEqual:[NSNull null]])
    {
        if (installRegi != nil && installRegi != NULL && ![installRegi isEqualToString:@""] && ![installRegi isEqualToString:@"NA"])
        {
            [[firstViewArray objectAtIndex:3] setValue:installRegi forKey:@"value"];
        }
        else
        {
//            lblRegister.text = @"NA";
            [[firstViewArray objectAtIndex:3] setValue:@"NA" forKey:@"value"];
        }
    }
    else
    {
        [[firstViewArray objectAtIndex:3] setValue:@"NA" forKey:@"value"];
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
        if (strRequest != nil && strRequest != NULL && ![strRequest isEqualToString:@""]  &&  ![strRequest isEqualToString:@"NA"])
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


#pragma mark - Webservices List
-(void)SaveUnInstalltoServer
{
    [APP_DELEGATE endHudProcess];
    [APP_DELEGATE startHudProcess:@"Saving details...."];
    
    NSString * strUserId = CURRENT_USER_ID;
    
    NSMutableDictionary * dict = [[NSMutableDictionary alloc]init];
    [dict setValue:strUserId forKey:@"user_id"];
    [dict setValue:[self checkforValidString:[detailDict valueForKey:@"imei"]] forKey:@"imei"];
    [dict setValue:[self checkforValidString:[detailDict valueForKey:@"device_type"]] forKey:@"device_type"];
    [dict setValue:[self checkforValidString:[detailDict valueForKey:@"warranty"]] forKey:@"warranty"];
    [dict setValue:[self checkforValidString:[detailDict valueForKey:@"date"]] forKey:@"date"];
    [dict setValue:[self checkforValidString:[detailDict valueForKey:@"vesselname"]] forKey:@"vessel_name"];
    [dict setValue:[self checkforValidString:[detailDict valueForKey:@"portno"]] forKey:@"port"];
    [dict setValue:[self checkforValidString:[detailDict valueForKey:@"owner_name"]] forKey:@"owner_name"];
    [dict setValue:[self checkforValidString:[detailDict valueForKey:@"owner_address"]] forKey:@"owner_address"];
    [dict setValue:[self checkforValidString:[detailDict valueForKey:@"owner_city"]] forKey:@"owner_city"];
    [dict setValue:[self checkforValidString:[detailDict valueForKey:@"owner_state"]] forKey:@"owner_state"];
    [dict setValue:[self checkforValidString:[detailDict valueForKey:@"owner_zipcode"]] forKey:@"owner_zipcode"];
    [dict setValue:[self checkforValidString:[detailDict valueForKey:@"owner_email"]] forKey:@"owner_email"];
    [dict setValue:[self checkforValidString:[detailDict valueForKey:@"owner_phone_no"]] forKey:@"owner_phone_no"];
    [dict setValue:[self checkforValidString:[detailDict valueForKey:@"uninstall_date"]] forKey:@"uninstall_date"];
    
    NSString * strOwnerUrl = [self documentsPathForFileName:[NSString stringWithFormat:@"UnInstallSigns/%@",[detailDict valueForKey:@"local_owner_sign"]]];
    NSData *ownerData = [NSData dataWithContentsOfFile:strOwnerUrl];
    
    NSString * strInstallUrl = [self documentsPathForFileName:[NSString stringWithFormat:@"UnInstallSigns/%@",[detailDict valueForKey:@"local_installer_sign"]]];
    NSData *installerData = [NSData dataWithContentsOfFile:strInstallUrl];

    
    
    NSMutableArray * arr1 = [[NSMutableArray alloc] init];
    [arr1 addObject:ownerData];
    [arr1 addObject:installerData];
    
    NSMutableArray * arr2 = [[NSMutableArray alloc] init];
    [arr2 addObject:@"sign_image"];
    [arr2 addObject:@"un_sign_image"];
    
    NSMutableArray * arr3 = [[NSMutableArray alloc] init];
    [arr3 addObject:strOwnerUrl];
    [arr3 addObject:strInstallUrl];

    
    URLManager *manager = [[URLManager alloc] init];
    manager.commandName = @"SaveInstall";
    manager.delegate = self;
    NSString *strServerUrl = @"http://succorfish.in/mobile/uninstallation";
    
    [manager postUrlCallForMultipleImage:strServerUrl withParameters:dict andMediaData:arr1 andDataParameterName:arr2 andFileName:arr3];
}
-(void)saveUninstallationQuestionsServer
{
    NSMutableDictionary * dict = [[NSMutableDictionary alloc]init];
    
    NSString * localPath = [self writeToTextFile];
    NSData *pngData = [NSData dataWithContentsOfFile:localPath];
    
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
                    [APP_DELEGATE endHudProcess];
                    
                    NSString * requestStr =[NSString stringWithFormat:@"update tbl_uninstall set is_sync = 1 where id = '%@'",strInstallID];
                    [[DataBaseManager dataBaseManager] execute:requestStr];

                    URBAlertView *alertView = [[URBAlertView alloc] initWithTitle:ALERT_TITLE message:@"Report has been uninstalled successfully." cancelButtonTitle:OK_BTN otherButtonTitles: nil, nil];
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
    }
    else
    {
        NSString * strUrl = [NSString stringWithFormat:@"https://ws.scstg.net/basic/v2/device/uninstall/%@",strSuccorfishDeviceID];
        
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
        
        URLManager *manager = [[URLManager alloc] init];
        manager.commandName = @"SaveUninstallSuccorfish";
        manager.delegate = self;
        
        [manager postUrlCall:strUrl withParameters:args];
    }
}

-(void)saveInstallSignaturesServer
{
    NSMutableDictionary * dict = [[NSMutableDictionary alloc]init];
    
    NSString * localPath = [self documentsPathForFileName:[NSString stringWithFormat:@"UnInstallSigns/%@",[detailDict valueForKey:@"local_installer_sign"]]];
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
    
    NSString * localPath = [self documentsPathForFileName:[NSString stringWithFormat:@"UnInstallSigns/%@",[detailDict valueForKey:@"local_owner_sign"]]];
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
                
                if ([responseObject isKindOfClass:[NSDictionary class]])
                {
                    NSMutableDictionary * dictID = [[NSMutableDictionary alloc] init];
                    dictID = [responseObject mutableCopy];
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
                        
                        NSIndexPath * nowIndex = [NSIndexPath indexPathForRow:8 inSection:0];
                        UninstalledCell *cell = [tblSecondView cellForRowAtIndexPath:nowIndex];
                        
                        if ([self GetdifferencebetweenFirstDate:date] == YES)
                        {
    
                            strInfoMsg = @"READY TO GO!";
                            strStatus = @"Yes";
//                            lblDisplayMsg.text = strInfoMsg;
//                            lblDisplayMsg.textColor = UIColor.greenColor;
                            cell.lblPositionMsg.text = strInfoMsg;
                            cell.lblPositionMsg.textColor = UIColor.greenColor;
                        }
                        else
                        {
                            
                            strInfoMsg = @"No position report in last 2 hours.";
                            strStatus = @"No";
//                            lblDisplayMsg.text = strInfoMsg;
//                            lblDisplayMsg.textColor = UIColor.redColor;
                            cell.lblPositionMsg.text = strInfoMsg;
                            cell.lblPositionMsg.textColor = UIColor.redColor;
                        }
                        
//                        lblLastReport.textColor = UIColor.whiteColor;
//                        lblLastReport.text = [NSString stringWithFormat:@"Last report : %@",[self checkforValidString:strDates]];
                        cell.lblLastReport.textColor = UIColor.whiteColor;
                        cell.lblLastReport.text = [NSString stringWithFormat:@"Last report : %@",[self checkforValidString:strDates]];
                        [tblSecondView reloadData];
                    }
                }
                else
                {
                    if ([responseObject isEqual:[NSNull null]] || [responseObject isEqualToString:@"<nil>"] || responseObject == NULL)
                    {
                        URBAlertView *alertView = [[URBAlertView alloc] initWithTitle:ALERT_TITLE message:@"Device has never submitted any positional data to the system" cancelButtonTitle:OK_BTN otherButtonTitles: nil, nil];
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
                                               failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                                   if (error) {
                                                       [APP_DELEGATE endHudProcess];
                                                       
                                                       NSLog(@"Servicer error = %@", error);
                                                       [APP_DELEGATE endHudProcess];
                                                       
                                                       URBAlertView *alertView = [[URBAlertView alloc] initWithTitle:ALERT_TITLE message:@"Something went wrong. Please try again." cancelButtonTitle:OK_BTN otherButtonTitles: nil, nil];
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
#pragma mark - UrlManager Delegate
- (void)onResult:(NSDictionary *)result
{

    NSLog(@"The result is...%@", result);
    if ([[result valueForKey:@"commandName"] isEqualToString:@"SaveUninstallSuccorfish"])
    {
        
        if ([[result valueForKey:@"result"] count]>=10)
        {
            NSMutableDictionary * tmpDict = [[NSMutableDictionary alloc] init];
            tmpDict = [[result valueForKey:@"result"] mutableCopy];
            
            serverInstallationID = [tmpDict valueForKey:@"id"];
            NSString * requestStr =[NSString stringWithFormat:@"update tbl_uninstall set server_id = '%@' where id = '%@'",serverInstallationID,strInstallID];
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
                    if ([strErrorCode isEqualToString:@"device.cannot.uninstall"] || [strErrorCode rangeOfString:@"device.cannot.uninstall"].location != NSNotFound)
                    {
                        URBAlertView *alertView = [[URBAlertView alloc] initWithTitle:ALERT_TITLE message:@"This device can not be uninstalled at this time." cancelButtonTitle:OK_BTN otherButtonTitles: nil, nil];
                        [alertView setMessageFont:[UIFont fontWithName:CGRegular size:14]];
                        [alertView setHandlerBlock:^(NSInteger buttonIndex, URBAlertView *alertView) {
                            [alertView hideWithCompletionBlock:^{
                            }];
                        }];
                        [alertView showWithAnimation:URBAlertAnimationTopToBottom];
    if (IS_IPHONE_X){[alertView showWithAnimation:URBAlertAnimationDefault];}
                    }
                    else if ([strErrorCode isEqualToString:@"Pattern.deviceUninstallDto.contactInfo.telephone"])
                    {
                        URBAlertView *alertView = [[URBAlertView alloc] initWithTitle:ALERT_TITLE message:@"Please enter Valid Mobile Number" cancelButtonTitle:OK_BTN otherButtonTitles: nil, nil];
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
        if ( [result valueForKey:@"result"] == [NSNull null])
        {
            NSString * requestStr =[NSString stringWithFormat:@"update tbl_uninstall set server_installer_sign = 1 where id = '%@'",strInstallID];
            [[DataBaseManager dataBaseManager] execute:requestStr];
        }
        else
        {
            NSString * requestStr =[NSString stringWithFormat:@"update tbl_uninstall set server_installer_sign = 1 where id = '%@'",strInstallID];
            [[DataBaseManager dataBaseManager] execute:requestStr];
        }
        [self saveOwnerSignaturesServer];
    }
    else if ([[result valueForKey:@"commandName"] isEqualToString:@"SaveOwnerSign"])
    {
        [self saveUninstallationQuestionsServer];
    }
    else if ([[result valueForKey:@"commandName"] isEqualToString:@"SaveFile"])
    {
        [self CallCompleteServiceforInstallation];
    }
    else if ([[result valueForKey:@"commandName"] isEqualToString:@"SendComplete"])
    {
        if ( [result valueForKey:@"result"] == [NSNull null])
        {
            NSString * requestStr =[NSString stringWithFormat:@"update tbl_uninstall set server_installer_sign = 1 where id = '%@'",strInstallID];
            [[DataBaseManager dataBaseManager] execute:requestStr];
        }
        else
        {
            NSString * requestStr =[NSString stringWithFormat:@"update tbl_uninstall set server_owner_sign = 1 where id = '%@'",strInstallID];
            [[DataBaseManager dataBaseManager] execute:requestStr];
        }
        [APP_DELEGATE updateBadgeCount];
        
        NSString * requestStr =[NSString stringWithFormat:@"update tbl_uninstall set is_sync = 1 where id = '%@'",strInstallID];
        [[DataBaseManager dataBaseManager] execute:requestStr];
        
        [APP_DELEGATE endHudProcess];

        URBAlertView *alertView = [[URBAlertView alloc] initWithTitle:ALERT_TITLE message:@"Report has been uninstalled successfully." cancelButtonTitle:OK_BTN otherButtonTitles: nil, nil];
        
        [alertView setMessageFont:[UIFont fontWithName:CGRegular size:14]];
        [alertView setHandlerBlock:^(NSInteger buttonIndex, URBAlertView *alertView) {
            [alertView hideWithCompletionBlock:^{
              [self.navigationController popToViewController:[self.navigationController.viewControllers objectAtIndex:0] animated:YES];
//                [self.navigationController popViewControllerAnimated:YES];
            }];
        }];
        [alertView showWithAnimation:URBAlertAnimationTopToBottom];
    if (IS_IPHONE_X){[alertView showWithAnimation:URBAlertAnimationDefault];}
    }
    else if ([[result valueForKey:@"commandName"] isEqualToString:@"SaveInstall"])
    {
        [APP_DELEGATE endHudProcess];
        if ([[[result valueForKey:@"result"] valueForKey:@"response"] isEqualToString:@"true"])
        {
            if ([[[result valueForKey:@"result"] valueForKey:@"message"] isEqualToString:@"Device already uninstalled with this IMEI number!"])
            {
                URBAlertView *alertView = [[URBAlertView alloc] initWithTitle:ALERT_TITLE message:@"This device is already uninstalled with this IMEI number!" cancelButtonTitle:OK_BTN otherButtonTitles: nil, nil];
                [alertView setMessageFont:[UIFont fontWithName:CGRegular size:14]];
                [alertView setHandlerBlock:^(NSInteger buttonIndex, URBAlertView *alertView) {
                    [alertView hideWithCompletionBlock:^{
//                        [self.navigationController popViewControllerAnimated:YES];
                        [self.navigationController popToViewController:[self.navigationController.viewControllers objectAtIndex:0] animated:YES];
                    }];
                }];
                [alertView showWithAnimation:URBAlertAnimationTopToBottom];
    if (IS_IPHONE_X){[alertView showWithAnimation:URBAlertAnimationDefault];}
            }
            else if ([[[result valueForKey:@"result"] valueForKey:@"message"] isEqualToString:@"Pattern.deviceInstallDto.contactInfo.telephone"])
            {
                URBAlertView *alertView = [[URBAlertView alloc] initWithTitle:ALERT_TITLE message:@"Please enter Valid Mobile No" cancelButtonTitle:OK_BTN otherButtonTitles: nil, nil];
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
                URBAlertView *alertView = [[URBAlertView alloc] initWithTitle:ALERT_TITLE message:@"Please enter Valid ZipCode" cancelButtonTitle:OK_BTN otherButtonTitles: nil, nil];
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
                NSMutableDictionary * tmpDict = [[NSMutableDictionary alloc] init];
                tmpDict = [[result valueForKey:@"result"] valueForKey:@"data"];
                
                if (tmpDict == [NSNull null] || tmpDict == nil)
                {
                    
                }
                else
                {
                    NSString * strServerVesselId = [tmpDict valueForKey:@"vessel_id"];
                    NSString * strUnInstallId = [tmpDict valueForKey:@"id"];
                    
                    NSString * requestStr =[NSString stringWithFormat:@"update tbl_uninstall set server_id = '%@', vessel_id = '%@', is_sync = 1 where id = '%@'",strUnInstallId,strServerVesselId,strInstallID];
                    [[DataBaseManager dataBaseManager] execute:requestStr];
                    
                    [APP_DELEGATE updateBadgeCount];

                }
                URBAlertView *alertView = [[URBAlertView alloc] initWithTitle:ALERT_TITLE message:@"Report has been uninstalled successfully." cancelButtonTitle:OK_BTN otherButtonTitles: nil, nil];
                
                [alertView setMessageFont:[UIFont fontWithName:CGRegular size:14]];
                [alertView setHandlerBlock:^(NSInteger buttonIndex, URBAlertView *alertView) {
                    [alertView hideWithCompletionBlock:^{
                        
//                        [self.navigationController popViewControllerAnimated:YES];
                        [self.navigationController popToViewController:[self.navigationController.viewControllers objectAtIndex:0] animated:YES];
                    }];
                }];
                [alertView showWithAnimation:URBAlertAnimationTopToBottom];
    if (IS_IPHONE_X){[alertView showWithAnimation:URBAlertAnimationDefault];}
                
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
                URBAlertView *alertView = [[URBAlertView alloc] initWithTitle:ALERT_TITLE message:strMsg cancelButtonTitle:OK_BTN otherButtonTitles: nil, nil];
                
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
-(void)ErrorMessagePopup
{
    [APP_DELEGATE endHudProcess];
    
    URBAlertView *alertView = [[URBAlertView alloc] initWithTitle:ALERT_TITLE message:@"Something went wrong. Please try again." cancelButtonTitle:OK_BTN otherButtonTitles: nil, nil];
    
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
-(void)GetVesselInformation
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
            NSString * strUrl = [NSString stringWithFormat:@"https://ws.scstg.net/basic/v2/asset/getForAccountWithDevice/%@",strAccountID];
            
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
                //                NSLog(@"Success Response with Result=%@",responseObject);
                
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
                                                       
                                                       URBAlertView *alertView = [[URBAlertView alloc] initWithTitle:ALERT_TITLE message:@"Something went wrong. Please try again." cancelButtonTitle:OK_BTN otherButtonTitles: nil, nil];
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
-(void)SendErrorReport
{
    URBAlertView *alertView = [[URBAlertView alloc] initWithTitle:ALERT_TITLE message:@"Do you want to report this bug to the developer team?" cancelButtonTitle:OK_BTN otherButtonTitles: @"Cancel", nil];
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
        URBAlertView *alertView = [[URBAlertView alloc] initWithTitle:ALERT_TITLE message:@"Please set up a Mail account in order to send email." cancelButtonTitle:OK_BTN otherButtonTitles: nil, nil];
        
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
    NSString * strQuery = [NSString stringWithFormat:@"select * from tbl_question where install_id = '%@' and type = 'uninstall'",strInstallID];
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
        
        NSString * content = [NSString stringWithFormat:@"=============================================================================\r\nUninstaller Health and Safety Questionnaire\r\n============================================================================="];
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

//- (void) mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
//{
//    switch (result)
//    {
//        case MFMailComposeResultCancelled:
//            NSLog(@"Mail cancelled");
//            break;
//        case MFMailComposeResultSaved:
//            NSLog(@"Mail saved");
//            break;
//        case MFMailComposeResultSent:
//            NSLog(@"Mail sent");
//            break;
//        case MFMailComposeResultFailed:
//            NSLog(@"Mail sent failure: %@", [error localizedDescription]);
//            break;
//        default:
//            break;
//    }

    // Close the Mail Interface
//    [self dismissViewControllerAnimated:YES completion:NULL];
//}

/*

 #pragma mark - Navigation
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

@end

