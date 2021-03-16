//
//  DashboardVC.m
//  Succorfish Installer App
//
//  Created by stuart watts on 21/02/2018.
//  Copyright © 2018 Kalpesh Panchasara. All rights reserved.
//

#import "DashboardVC.h"
#import "NewInstallVC.h"
#import "UnInstalledVC.h"
#import "InspectionVC.h"
#import "UnsyncedVC.h"
#import "HistoryVC.h"
#import "GuideInstallVC.h"
#import "LegalDocsVC.h"
#import "SNHVC.h"
#import "InstallBeconVC.h"
#import "BeaconVC.h"
@interface DashboardVC ()<URLManagerDelegate>
{
    int textSize;
    NSString * strUserName;
    int globalYvalue;
    UILabel * lblInstalls, * lblUnSynced;
}

@end

@implementation DashboardVC

- (void)viewDidLoad
{
    textSize = 16;
    if (IS_IPHONE_4 || IS_IPHONE_5)
    {
        textSize = 14;
    }
    
    if (![[self checkforValidString:[[NSUserDefaults standardUserDefaults] objectForKey:@"name"]] isEqualToString:@"NA"])
    {
        strUserName = [[NSUserDefaults standardUserDefaults] objectForKey:@"name"];
    }
    UIImageView * imgBack = [[UIImageView alloc] init];
    imgBack.frame = CGRectMake(0, 0, DEVICE_WIDTH, DEVICE_HEIGHT);
    imgBack.image = [UIImage imageNamed:@"Splash_bg.png"];
    [self.view addSubview:imgBack];

    [self setNavigationViewFrames];
    [self setMainView];
    
    [APP_DELEGATE updateBadgeCount];

    if ([[[NSUserDefaults standardUserDefaults] valueForKey:@"isAllVesselsCalled"] isEqualToString:@"1"])
    {
        
    }
    else
    {
        [self getVesselsfromSuccorfishServer];
        [[NSUserDefaults standardUserDefaults] setValue:@"1" forKey:@"isAllVesselsCalled"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    [self getVesselsfromSuccorfishServer];

    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"UpdateInstallCount" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(UpdateInstallCount) name:@"UpdateInstallCount" object:nil];

    [self getAssetGroupfromSuccorfishServer];
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}
-(void)viewWillAppear:(BOOL)animated
{
    installPhotoCounts = 0;
    installScanID = @"";
    installVesselName = @"";
    installRegi = @"";

    {
        NSString * strCounts = [[NSUserDefaults standardUserDefaults] valueForKey:@"TotalInstalls"];
        if ([[self checkforValidString:strCounts] isEqualToString:@"NA"])
        {
            [lblInstalls setText:@"Total Installation : 0"];
        }
        else
        {
            if ([strCounts isEqualToString:@"1"])
            {
                [lblInstalls setText:@"Total Installation : 1"];
            }
            else
            {
                [lblInstalls setText:[NSString stringWithFormat:@"Total Installations : %@",strCounts]];
            }
        }
    }
    [APP_DELEGATE updateBadgeCount];
    if ([UIApplication sharedApplication].applicationIconBadgeNumber == 0)
    {
        lblUnSynced.hidden = YES;
        lblUnSynced.text = [NSString stringWithFormat:@" "];
    }
    else
    {
        lblUnSynced.hidden = NO;
        lblUnSynced.text = [NSString stringWithFormat:@"%ld",(long)[UIApplication sharedApplication].applicationIconBadgeNumber];
    }
    [APP_DELEGATE showTabBar:self.tabBarController];
    [super viewWillAppear:YES];
}
-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:YES];
}
-(void)UpdateInstallCount
{
    if ([[self checkforValidString:strTotalInstallCounts] isEqualToString:@"NA"])
    {
        [lblInstalls setText:@"Total Installations : 0"];
    }
    else
    {
        [[NSUserDefaults standardUserDefaults] setObject:strTotalInstallCounts forKey:@"TotalInstalls"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        if ([strTotalInstallCounts isEqualToString:@"1"])
        {
            [lblInstalls setText:@"Total Installation : 1"];
        }
        else
        {
            [lblInstalls setText:[NSString stringWithFormat:@"Total Installations : %@",strTotalInstallCounts]];
        }
    }

}
#pragma mark - Web Service Call
-(void)getInstallCounts
{
    NSMutableDictionary * dict = [[NSMutableDictionary alloc]init];
    [dict setValue:CURRENT_USER_ID forKey:@"user_id"];
    
    URLManager *manager = [[URLManager alloc] init];
    manager.commandName = @"GetCounts";
    manager.delegate = self;
    NSString *strServerUrl = @"http://succorfish.in/mobile/ins/count";
    [manager postUrlCall:[NSString stringWithFormat:@"%@",strServerUrl] withParameters:dict];

}
#pragma mark - Set View Frames
-(void)setNavigationViewFrames
{
    UIView * viewHeader = [[UIView alloc] initWithFrame:CGRectMake(0, 0, DEVICE_WIDTH, 64)];
    [viewHeader setBackgroundColor:[UIColor clearColor]];
    [self.view addSubview:viewHeader];
    
    UIImageView * img = [[UIImageView alloc] init];
    img.frame = CGRectMake((DEVICE_WIDTH-150)/2,34, 150, 30);
    img.image = [UIImage imageNamed:@"logo.png"];
    img.backgroundColor = [UIColor clearColor];
    [viewHeader addSubview:img];
    
    UIView * topView = [[UIView alloc] init];
    topView.frame = CGRectMake(0, 86*approaxSize, DEVICE_WIDTH-0, 70*approaxSize);
    topView.backgroundColor = [UIColor clearColor];
    topView.layer.cornerRadius = 10;
    topView.layer.masksToBounds = YES;
    [self.view addSubview:topView];
    
    UIImageView * imgProf = [[UIImageView alloc] init];
    imgProf.frame = CGRectMake(20*approaxSize,10*approaxSize, 43*approaxSize, 36*approaxSize);
    imgProf.image = [UIImage imageNamed:@"user_kp.png"];
    imgProf.backgroundColor = [UIColor clearColor];
    [topView addSubview:imgProf];
    
    UILabel * lblName = [[UILabel alloc] initWithFrame:CGRectMake(75*approaxSize, 10*approaxSize, topView.frame.size.width-30, 20*approaxSize)];
    [lblName setBackgroundColor:[UIColor clearColor]];
    [lblName setText:@"Hello Kalpesh!"];
    [lblName setFont:[UIFont fontWithName:CGRegular size:textSize]];
    [lblName setTextColor:[UIColor lightGrayColor]];
    [topView addSubview:lblName];
    
    if ([strUserName length]==0 || strUserName == nil)
    {
        [lblName setText:@"Hello!"];
    }
    else
    {
        NSArray * arr = [strUserName componentsSeparatedByString:@"."];
        if ([arr count]>0)
        {
            NSString * str = [NSString stringWithFormat:@"%@",[arr objectAtIndex:0]];
            [lblName setText:[NSString stringWithFormat:@"Hello %@!",str]];
        }
        else
        {
            NSString * str = [strUserName uppercaseString];
            [lblName setText:[NSString stringWithFormat:@"Hello %@!",str]];
        }
    }
    
    lblInstalls = [[UILabel alloc] initWithFrame:CGRectMake(75*approaxSize,30*approaxSize,topView.frame.size.width-30, 25*approaxSize)];
    [lblInstalls setBackgroundColor:[UIColor clearColor]];
    [lblInstalls setText:@"Total Installations : 0"];
    [lblInstalls setFont:[UIFont fontWithName:CGBold size:textSize]];
    [lblInstalls setTextColor:[UIColor whiteColor]];
    [topView addSubview:lblInstalls];
    
    UILabel * lblLine = [[UILabel alloc] init];
    lblLine.frame = CGRectMake(10, (65-1)*approaxSize, DEVICE_WIDTH-20, 0.5);
    lblLine.backgroundColor  =[UIColor whiteColor];
    [topView addSubview:lblLine];
    
    if (IS_IPHONE_4)
    {
        img.frame = CGRectMake((DEVICE_WIDTH-150)/2,28, 150, 30);
        topView.frame = CGRectMake(0, 66*approaxSize, DEVICE_WIDTH-0, 65*approaxSize);
        lblLine.frame = CGRectMake(10, (65-1)*approaxSize, DEVICE_WIDTH-20, 0.5);
    }
    else if (IS_IPHONE_X)
    {
        NSLog(@"device height=%f",[[UIScreen mainScreen] bounds].size.height);
        viewHeader.frame = CGRectMake(0, 0, DEVICE_WIDTH, 88);

        img.frame = CGRectMake((DEVICE_WIDTH-150)/2,50, 150, 30);
        topView.frame = CGRectMake(0, 100, DEVICE_WIDTH-0, 70);
        lblLine.frame = CGRectMake(10, (70-1), DEVICE_WIDTH-20, 0.5);
    }
}

-(void)setMainView
{
    scrlView = [[UIScrollView alloc] init];
    scrlView.frame = CGRectMake(0, (86+60)*approaxSize, DEVICE_WIDTH-0, 390*approaxSize);
    scrlView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:scrlView];
    
    int xx = 15;
    int yy = 0;
    int cnt = 0;
    int vWidth = (DEVICE_WIDTH/3);
    int vHeighth = (DEVICE_WIDTH/3) + 10;
    
    if (IS_IPHONE_4)
    {
        vHeighth = (DEVICE_WIDTH/3);
        scrlView.frame = CGRectMake(0, (66+65+40)*approaxSize, DEVICE_WIDTH-0, 270*approaxSize);
    }
    else if (IS_IPHONE_X)
    {
        scrlView.frame = CGRectMake(0, (150)*approaxSize, DEVICE_WIDTH-0, 380*approaxSize);
    }
    NSArray * nameArr = [NSArray arrayWithObjects:@"New Installation",@"Uninstall",@"Inspection",@"Beacon",@"Unsynced",@"Install Guide",@"Legal Docs", nil];
    
    NSArray * imgArr = [NSArray arrayWithObjects:@"new installation.png",@"uninstall.png",@"unsynced.png",@"newBeacon.png",@"unsynced.png",@"install guide.png",@"legal docs.png", nil];

    for (int i=0; i<3; i++)
    {
        xx=0;
          int columCount = 3;
        if (i == 2)
        {
            columCount = 1;
        }
        
        for (int j=0; j<columCount; j++)
        {
            UILabel * lblTmp = [[UILabel alloc] init];
            lblTmp.frame = CGRectMake(xx, yy, vWidth, vHeighth);
            lblTmp.backgroundColor = [UIColor clearColor];
            lblTmp.userInteractionEnabled = YES;
            lblTmp.text = @" ";
            [scrlView addSubview:lblTmp];
            
            UIImageView * img = [[UIImageView alloc] init];
            img.frame = CGRectMake((vWidth-80)/2,(vHeighth-80)/2, 80, 80);
            img.image = [UIImage imageNamed:[imgArr objectAtIndex:cnt]];
            img.backgroundColor = [UIColor clearColor];
            [lblTmp addSubview:img];
            
            UILabel * lblName = [[UILabel alloc] init];
            lblName.frame = CGRectMake(0, vHeighth-30, vWidth, 30);
            lblName.text = [NSString stringWithFormat:@"%@",[nameArr objectAtIndex:cnt]];
            [lblName setFont:[UIFont fontWithName:CGRegular size:textSize]];
            lblName.textColor = [UIColor whiteColor];
            lblName.textAlignment = NSTextAlignmentCenter;
            [lblTmp addSubview:lblName];
            
            UIButton * btnTap = [UIButton buttonWithType:UIButtonTypeCustom];
            btnTap.frame = lblTmp.frame;
            [btnTap addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
            btnTap.tag = cnt;
            [scrlView addSubview:btnTap];
            
            if (cnt == 4)
            {
                [lblUnSynced removeFromSuperview];
                lblUnSynced= [[UILabel alloc] init];
                lblUnSynced.frame = CGRectMake(xx+vWidth-30, yy+12, 24, 24);
                lblUnSynced.text = [NSString stringWithFormat:@" "];
                [lblUnSynced setFont:[UIFont fontWithName:CGRegular size:12]];
                lblUnSynced.textColor = [UIColor whiteColor];
                lblUnSynced.textAlignment = NSTextAlignmentCenter;
                lblUnSynced.layer.cornerRadius = 12;
                lblUnSynced.layer.masksToBounds = YES;
                lblUnSynced.backgroundColor = [UIColor colorWithRed:244/255.0 green:0 blue:0 alpha:1.0];
                
                if (IS_IPHONE_6plus || IS_IPHONE_X)
                {
                    lblUnSynced.frame = CGRectMake(xx+vWidth-30-12, yy+12+12, 24, 24);
                }
                else if (IS_IPHONE_6)
                {
                    lblUnSynced.frame = CGRectMake(xx+vWidth-30-6, yy+12+6, 24, 24);
                }
                
                if ([UIApplication sharedApplication].applicationIconBadgeNumber == 0)
                {
                    lblUnSynced.hidden = YES;
                    lblUnSynced.text = [NSString stringWithFormat:@" "];
                }
                else
                {
                    lblUnSynced.hidden = NO;
                    lblUnSynced.text = [NSString stringWithFormat:@"%ld",(long)[UIApplication sharedApplication].applicationIconBadgeNumber];
                }
                [scrlView addSubview:lblUnSynced];
            }
            
            if (IS_IPHONE_4 || IS_IPHONE_5)
            {
                [lblName setFont:[UIFont fontWithName:CGRegular size:13]];
                lblName.frame = CGRectMake(0, vHeighth-15, vWidth, 20);
            }
            
            if (IS_IPHONE_4)
            {
                img.frame = CGRectMake((vWidth-70)/2,(vHeighth-70)/2-0, 70, 70);
                lblName.frame = CGRectMake(0, vHeighth-15, vWidth, 20);
            }
            xx = vWidth + xx;
            cnt = cnt +1;
        }
        yy = yy + vHeighth + 10 ;
    }
    
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)btnClick:(id)sender
{
    if ([sender tag] == 0)
    {
        SNHVC * instV = [[SNHVC alloc] init];
        instV.strType = @"install";
        [self.navigationController pushViewController:instV animated:YES];
    }
    else if ([sender tag] == 1)
    {
        SNHVC * uninstV = [[SNHVC alloc] init];
        uninstV.strType = @"uninstall";
        [self.navigationController pushViewController:uninstV animated:YES];
    }
    else if ([sender tag] == 2)
    {
        SNHVC * inspV = [[SNHVC alloc] init];
        inspV.strType = @"inspection";
        [self.navigationController pushViewController:inspV animated:YES];
    }
    else if ([sender tag] == 3)
    {
//        globalbeaconVC = [[InstallBeconVC alloc] init];
//        [self.navigationController pushViewController:globalbeaconVC animated:YES];

        globalBeaconInstVC  = [[BeaconVC alloc] init];
        [self.navigationController pushViewController:globalBeaconInstVC animated:YES];
    }
    else if ([sender tag] == 4)
    {
        UnsyncedVC * instV = [[UnsyncedVC alloc] init];
        [self.navigationController pushViewController:instV animated:YES];
    }
    else if ([sender tag] == 5)
    {
        GuideInstallVC * instV = [[GuideInstallVC alloc] init];
        instV.isfromInstallGuide = YES;
        [self.navigationController pushViewController:instV animated:YES];
    }
    else if ([sender tag] == 6)
    {
        GuideInstallVC * instV = [[GuideInstallVC alloc] init];
        instV.isfromInstallGuide = NO;
        [self.navigationController pushViewController:instV animated:YES];
    }
}

#pragma mark - UrlManager Delegate
- (void)onResult:(NSDictionary *)result
{
    [APP_DELEGATE endHudProcess];
    NSLog(@"The result is...%@", result);
    
    if ([[result valueForKey:@"commandName"] isEqualToString:@"GetCounts"])
    {
        if ([[[result valueForKey:@"result"] valueForKey:@"response"] isEqualToString:@"true"])
        {
            NSString * strCounts = [NSString stringWithFormat:@"%@",[[result valueForKey:@"result"] valueForKey:@"data"]];
            if ([[self checkforValidString:strCounts] isEqualToString:@"NA"])
            {
                [lblInstalls setText:@"Total Installations : 0"];
            }
            else
            {
                [[NSUserDefaults standardUserDefaults] setObject:strCounts forKey:@"TotalInstalls"];
                [[NSUserDefaults standardUserDefaults] synchronize];
                if ([strCounts isEqualToString:@"1"])
                {
                    [lblInstalls setText:@"Total Installation : 1"];
                }
                else
                {
                    [lblInstalls setText:[NSString stringWithFormat:@"Total Installations : %@",strCounts]];
                }
            }
        }
        else
        {
            if ([[[result valueForKey:@"result"] valueForKey:@"message"] isEqualToString:@"Invalid Token"])
            {
                [APP_DELEGATE showSessionExpirePopup];
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
    
    
    
    NSString * strLoginUrl = [NSString stringWithFormat:@"%@%@",WEB_SERVICE_URL,@"token.json"];
    if ([[errorDict valueForKey:@"NSErrorFailingURLStringKey"] isEqualToString:strLoginUrl])
    {
        NSLog(@"NSErrorFailingURLStringKey===%@",[errorDict valueForKey:@"NSErrorFailingURLStringKey"]);
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
#pragma mark - Web Service Call
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
            NSString * strUrl = [NSString stringWithFormat:@"https://ws.scstg.net/basic/v2/asset/getForAccountWithoutDevice/%@",CURRENT_USER_ID];
            
            NSString * strbasicAuthToken;
            NSString * strUserName = [NSString stringWithFormat:@"%@",CURRENT_USER_EMAIL];
            NSString * strPassword = [NSString stringWithFormat:@"%@",CURRENT_USER_PASS];

            NSString * str = [NSString stringWithFormat:@"%@:%@",strUserName,strPassword];
            NSString * simpleStr = [APP_DELEGATE base64String:str];
            strbasicAuthToken = simpleStr;
            
            AFHTTPRequestOperationManager *manager1 = [[AFHTTPRequestOperationManager alloc] initWithBaseURL:[NSURL URLWithString:@"http://server.url"]];
            NSString *authorization = [NSString stringWithFormat: @"Basic %@",strbasicAuthToken];
            [manager1.requestSerializer setValue:authorization forHTTPHeaderField:@"Authorization"];
            
            AFHTTPRequestOperation *op = [manager1 GET:strUrl parameters:args success:^(AFHTTPRequestOperation *operation, id responseObject){
//                NSLog(@"Success Response with Result=%@",responseObject);
                
                [APP_DELEGATE endHudProcess];
                
                NSMutableArray * dictID = [[NSMutableArray alloc] init];
                dictID = [responseObject mutableCopy];
                
                NSString * strDelete = [NSString stringWithFormat:@"delete from tbl_vessel_asset"];
                [[DataBaseManager dataBaseManager] execute:strDelete];
                
                [[DataBaseManager dataBaseManager] saveVesselsintoDatabase:dictID];
            }
          failure:^(AFHTTPRequestOperation *operation, NSError *error)
            {
                if (error) {
                                                       
                    [APP_DELEGATE endHudProcess];
                    NSLog(@"Servicer error = %@", error);
                    [self ErrorMessagePopup];
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
#pragma mark - Web Service Call
-(void)getAssetGroupfromSuccorfishServer
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
            NSString * strUrl = [NSString stringWithFormat:@"https://ws.scstg.net/basic/v2/asset-group/getForAccount/%@",CURRENT_USER_ACCOUNT_ID]; // please change group asset api
            
            NSString * strbasicAuthToken;
            NSString * strUserName = [NSString stringWithFormat:@"%@",CURRENT_USER_EMAIL];
            NSString * strPassword = [NSString stringWithFormat:@"%@",CURRENT_USER_PASS];
            NSString * str = [NSString stringWithFormat:@"%@:%@",strUserName,strPassword];
                        

            NSString * simpleStr = [APP_DELEGATE base64String:str];
            strbasicAuthToken = simpleStr;
            
            AFHTTPRequestOperationManager *manager1 = [[AFHTTPRequestOperationManager alloc] initWithBaseURL:[NSURL URLWithString:@"http://server.url"]];
            NSString *authorization = [NSString stringWithFormat: @"Basic %@",strbasicAuthToken];
            [manager1.requestSerializer setValue:authorization forHTTPHeaderField:@"Authorization"];
            
            AFHTTPRequestOperation *op = [manager1 GET:strUrl parameters:args success:^(AFHTTPRequestOperation *operation, id responseObject)
            {
//                NSLog(@"Success Response with Result=%@",responseObject);
                
                [APP_DELEGATE endHudProcess];
                
                NSMutableArray * dictID = [[NSMutableArray alloc] init];
                dictID = [responseObject mutableCopy];
                NSLog(@"%@",responseObject);
                NSString * strDelete = [NSString stringWithFormat:@"delete from tbl_Asset_Group"];
                [[DataBaseManager dataBaseManager] execute:strDelete];

                for (int i = 0 ; i< [dictID count]; i++)
                {
                    NSString * strAccID = [[dictID objectAtIndex:i] valueForKey:@"accountId"];
                    NSString * strName = [[dictID objectAtIndex:i] valueForKey:@"name"];
                    NSString * strGroupID = [[dictID objectAtIndex:i] valueForKey:@"id"];
                    NSString * strDiscription = [[dictID objectAtIndex:i] valueForKey:@"description"];
                    
                    NSString * requestStr =[NSString stringWithFormat:@"insert into 'tbl_Asset_Group'('account_id','group_id','name','discription') values(\"%@\",\"%@\",\"%@\",\"%@\")",strAccID,strGroupID,strName,strDiscription];
                        [[DataBaseManager dataBaseManager] executeSw:requestStr];
                }
            }
          failure:^(AFHTTPRequestOperation *operation, NSError *error)
            {
                if (error) {
                                                       
                    [APP_DELEGATE endHudProcess];
                    NSLog(@"Servicer error = %@", error);
                    [self ErrorMessagePopup];
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
-(void)ErrorMessagePopup
{
    
    [APP_DELEGATE endHudProcess];
    
    URBAlertView *alertView = [[URBAlertView alloc] initWithTitle:ALERT_TITLE message:@"Something went wrong. Please try again." cancelButtonTitle:OK_BTN otherButtonTitles: nil, nil];
    
    [alertView setMessageFont:[UIFont fontWithName:CGRegular size:14]];
    [alertView setHandlerBlock:^(NSInteger buttonIndex, URBAlertView *alertView) {
        [alertView hideWithCompletionBlock:^{
            [self.navigationController popViewControllerAnimated:YES];
        }];
    }];
    [alertView showWithAnimation:URBAlertAnimationTopToBottom];
    if (IS_IPHONE_X){[alertView showWithAnimation:URBAlertAnimationDefault];}
}


@end
