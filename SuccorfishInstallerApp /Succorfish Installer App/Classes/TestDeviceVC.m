//
//  TestDeviceVC.m
//  Succorfish Installer App
//
//  Created by stuart watts on 23/02/2018.
//  Copyright © 2018 Kalpesh Panchasara. All rights reserved.
//

#import "TestDeviceVC.h"
#import "DetailCell.h"
#import "MapClassVC.h"
#import "NewInstallVC.h"
#import "InspectionVC.h"
#import "UnInstalledVC.h"

@interface TestDeviceVC ()<URLManagerDelegate>
{
}
@end

@implementation TestDeviceVC
@synthesize detailDict,strReasonToCome,isfromHistory,strReportType;
- (void)viewDidLoad
{
    UIImageView * imgBack = [[UIImageView alloc] init];
    imgBack.frame = CGRectMake(0, 0, DEVICE_WIDTH, DEVICE_HEIGHT);
    imgBack.image = [UIImage imageNamed:@"Splash_bg.png"];
    imgBack.userInteractionEnabled = YES;
    [self.view addSubview:imgBack];
    
    
    [self setNavigationViewFrames];
    
    if (isfromHistory)
    {
        if ([APP_DELEGATE isNetworkreachable])
        {
//            [self getDeviceDetailService];
            [self showInstalledView];
        }
        else
        {
            [self showCallView];
        }
    }
    else
    {
        if ([strReasonToCome isEqualToString:@"Offline"])
        {
            [self showCallView];
        }
        else
        {
            if ([APP_DELEGATE isNetworkreachable])
            {
                NSString * dates = [APP_DELEGATE getConvertedDate:[detailDict valueForKey:@"date"] withFormat:[[NSUserDefaults standardUserDefaults]valueForKey:@"GloablDateFormat"]];
                [detailDict setObject:dates forKey:[[NSUserDefaults standardUserDefaults]valueForKey:@"globalDate"]];

                [self showInstalledView];
            }
            else
            {
                [self showCallView];
            }
        }
    }
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}
-(void)viewWillAppear:(BOOL)animated
{
    [APP_DELEGATE hideTabBar:self.tabBarController];
    [super viewWillAppear:YES];
}
#pragma mark - Set Frames
-(void)setNavigationViewFrames
{
    
    UIView * viewHeader = [[UIView alloc] initWithFrame:CGRectMake(0, 0, DEVICE_WIDTH, 64)];
    [viewHeader setBackgroundColor:[UIColor blackColor]];
    [self.view addSubview:viewHeader];
    
    UILabel * lblTitle = [[UILabel alloc] initWithFrame:CGRectMake(50, 20, DEVICE_WIDTH-100, 44)];
    [lblTitle setBackgroundColor:[UIColor clearColor]];
    [lblTitle setText:@"Test Device"];
    [lblTitle setTextAlignment:NSTextAlignmentCenter];
    [UIFont fontWithName:CGRegular size:17];
    [lblTitle setTextColor:[UIColor whiteColor]];
    [viewHeader addSubview:lblTitle];
    
    if (isfromHistory)
    {
        [lblTitle setText:@"View last Installation"];
    }
    
    if ([strReasonToCome isEqualToString:@"View last Installation"])
    {
        [lblTitle setText:@"View last Installation"];
    }
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
    
    statusHeight = 64;

    if (IS_IPHONE_X)
    {
        statusHeight = 88;
        viewHeader.frame = CGRectMake(0, 0, DEVICE_WIDTH, 88);
        lblTitle.frame = CGRectMake(50, 40, DEVICE_WIDTH-100, 44);
        backImg.frame = CGRectMake(10, 12+44, 12, 20);
        btnBack.frame = CGRectMake(0, 20, 70, 84);
    }
   
}

-(void)showCallView
{
    [callView removeFromSuperview];
    callView = [[UIView alloc] init];
    callView.frame = CGRectMake(0, statusHeight, DEVICE_WIDTH, DEVICE_HEIGHT-statusHeight);
    callView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:callView];

    UIImageView * glasImg = [[UIImageView alloc] initWithFrame:CGRectMake((DEVICE_WIDTH-100)/2, 20, 100, 100)];
    [glasImg setImage:[UIImage imageNamed:@"No connection.png"]];
    [glasImg setContentMode:UIViewContentModeScaleAspectFit];
    glasImg.backgroundColor = [UIColor clearColor];
    [callView addSubview:glasImg];

    int txtSize = 16;
    if (IS_IPHONE_4 || IS_IPHONE_5)
    {
        txtSize = 15;
    }
    
    
    UILabel * lblInts = [[UILabel alloc] initWithFrame:CGRectMake(10, 100+20+20, DEVICE_WIDTH-20, 100)];
    [lblInts setBackgroundColor:[UIColor clearColor]];
    [lblInts setText:@"There is no internet connection. Please contact Adminstration by calling below contact number."];
    [lblInts setTextAlignment:NSTextAlignmentCenter];
    [lblInts setFont:[UIFont fontWithName:CGRegular size:txtSize]];
    lblInts.numberOfLines = 0;
    [lblInts setTextColor:[UIColor whiteColor]];
    [callView addSubview:lblInts];
    
    UILabel * lblNumber = [[UILabel alloc] initWithFrame:CGRectMake(10, 100 + 40 + 100, DEVICE_WIDTH-20, 30)];
    [lblNumber setBackgroundColor:[UIColor clearColor]];
    [lblNumber setText:@"08848056"];
    [lblNumber setTextAlignment:NSTextAlignmentCenter];
    [lblNumber setFont:[UIFont fontWithName:CGBold size:17]];
    lblNumber.numberOfLines = 0;
    [lblNumber setTextColor:[UIColor redColor]];
    lblNumber.backgroundColor = [UIColor clearColor];
    [callView addSubview:lblNumber];
    
    NSMutableAttributedString *attributeString = [[NSMutableAttributedString alloc] initWithString:@"08848056"];
    [attributeString addAttribute:NSUnderlineStyleAttributeName
                            value:[NSNumber numberWithInt:1]
                            range:(NSRange){0,[attributeString length]}];
    lblNumber.attributedText = attributeString;
    
    UIButton * btnCall = [UIButton buttonWithType:UIButtonTypeCustom];
    [btnCall addTarget:self action:@selector(btnCallClick) forControlEvents:UIControlEventTouchUpInside];
    btnCall.frame = CGRectMake(10, 100 + 40 + 100 + 40 + 40, DEVICE_WIDTH-20, 45);
    btnCall.backgroundColor = [UIColor clearColor];
    [btnCall setBackgroundImage:[UIImage imageNamed:@"BTN.png"] forState:UIControlStateNormal];
    [btnCall setTitle:@"Call" forState:UIControlStateNormal];
    btnCall.titleLabel.font = [UIFont fontWithName:CGRegular size:14];
    [btnCall setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [callView addSubview:btnCall];
}
-(void)btnCallClick
{
    NSString *number = [NSString stringWithFormat:@"08848056"];
    NSURL* callUrl=[NSURL URLWithString:[NSString   stringWithFormat:@"tel:%@",number]];
    
    //check  Call Function available only in iphone
    if([[UIApplication sharedApplication] canOpenURL:callUrl])
    {
        [[UIApplication sharedApplication] openURL:callUrl];
    }
    else
    {
        URBAlertView *alertView = [[URBAlertView alloc] initWithTitle:ALERT_TITLE message:@"This function is only available on the iPhone" cancelButtonTitle:OK_BTN otherButtonTitles: nil, nil];
        
        [alertView setMessageFont:[UIFont fontWithName:CGRegular size:14]];
        [alertView setHandlerBlock:^(NSInteger buttonIndex, URBAlertView *alertView) {
            [alertView hideWithCompletionBlock:^{
            }];
        }];
        [alertView showWithAnimation:URBAlertAnimationTopToBottom];
    if (IS_IPHONE_X){[alertView showWithAnimation:URBAlertAnimationDefault];}
    }
}
-(void)showInstalledView
{
    lblArr = [NSArray arrayWithObjects:@"Installed Date",@"IMEI Code",@"Device Type",@"Installer Name",@"Asset Name",@"Reg. No", nil];
    
    [installView removeFromSuperview];
    installView = [[UIView alloc] init];
    installView.frame = CGRectMake(0, statusHeight, DEVICE_WIDTH, DEVICE_HEIGHT-statusHeight);
    installView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:installView];
    
    [tblView removeFromSuperview];
    tblView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, DEVICE_WIDTH, DEVICE_HEIGHT-statusHeight) style:UITableViewStylePlain];
    tblView.delegate = self;
    tblView.dataSource = self;
    tblView.backgroundColor = [UIColor clearColor];
    tblView.separatorStyle = UITableViewCellSeparatorStyleNone;
    tblView.tableFooterView = [UIView new];
    [installView addSubview:tblView];
    if (IS_IPHONE_X)
    {
        tblView.frame = CGRectMake(0, 0, DEVICE_WIDTH, DEVICE_HEIGHT-statusHeight-45);
    }
  
}
#pragma mark - Button Clicks
-(void)btnBackClick
{
    if (isfromHistory)
    {
        [self.navigationController popViewControllerAnimated:YES];
    }
    else
    {
        if ([strReasonToCome isEqualToString:@"ExistAndSee"])
        {
            [self.navigationController popToRootViewControllerAnimated:YES];
        }
        else if ([strReasonToCome isEqualToString:@"Offline"])
        {
            [self.navigationController popViewControllerAnimated:YES];
        }
        else if([strReasonToCome isEqualToString:@"ReadytoUse"])
        {
            [self.navigationController popViewControllerAnimated:YES];
        }
        else if([strReasonToCome isEqualToString:@"View last Installation"])
        {

            NSMutableArray *allViewControllers = [NSMutableArray arrayWithArray:[self.navigationController viewControllers]];
            for (UIViewController *aViewController in allViewControllers)
            {
                
                if ([strReportType isEqualToString:@"UnInstall"])
                {
                    if ([aViewController isKindOfClass:[UnInstalledVC class]])
                    {
                        [self.navigationController popToViewController:aViewController animated:YES];
                    }
                }
                else if ([strReportType isEqualToString:@"NewInstall"])
                {
                    if ([aViewController isKindOfClass:[NewInstallVC class]])
                    {
                        [self.navigationController popToViewController:aViewController animated:YES];
                    }
                }
                else
                {
                    if ([aViewController isKindOfClass:[InspectionVC class]])
                    {
                        [self.navigationController popToViewController:aViewController animated:YES];
                    }
                }
            }
            
        }
        
        else
        {
            [APP_DELEGATE movetoSelectedInex:0];
        }
    }
}

#pragma mark- UITableView Methods
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section;   // custom view for header. will be adjusted to default or specified header height
{
    UIView * headerView =[[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width-146, 45)];
    headerView.backgroundColor = [UIColor clearColor];
    
    UILabel *lblmenu=[[UILabel alloc]init];
    lblmenu.text = @"Previously installed device information";
    [lblmenu setTextColor:[UIColor whiteColor]];
    [lblmenu setFont:[UIFont fontWithName:CGRegular size:15]];
    lblmenu.frame = CGRectMake(10, 0, DEVICE_WIDTH, 45);
    [headerView addSubview:lblmenu];
    
    if (IS_IPHONE_4)
    {
        headerView.frame = CGRectMake(0, 0, self.view.frame.size.width-146, 35);
        lblmenu.frame = CGRectMake(10, 0, DEVICE_WIDTH, 35);

    }
    return headerView;
}
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (IS_IPHONE_X)
    {
        return 55;
    }
    else
    {
        if (IS_IPHONE_4)
        {
            return 35;
        }
        return 45;
    }
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [lblArr count];
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (IS_IPHONE_4)
    {
        return 50;
    }
    else
    {
        return 55;
    }
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    DetailCell *cell = [tableView dequeueReusableCellWithIdentifier:@"HistoryCustomCell"];
    if (cell==nil)
    {
        cell = [[DetailCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"HistoryCustomCell"];
    }
    cell.lblHeader.text = [lblArr objectAtIndex:indexPath.row];
    
    NSString * retunStr;
    if (indexPath.row == 0)
    {
        retunStr = [detailDict valueForKey:[[NSUserDefaults standardUserDefaults] valueForKey:@"globalDate"]];
    }
    else if (indexPath.row == 1)
    {
        retunStr = [detailDict valueForKey:@"imei"];
    }
    else if (indexPath.row == 2)
    {
        retunStr = [detailDict valueForKey:@"device_type"];
    }
    else if (indexPath.row == 3)
    {
        retunStr = [detailDict valueForKey:@"installer_name"];
    }
    else if (indexPath.row == 4)
    {
        retunStr = [detailDict valueForKey:@"vesselname"];
    }
    else if (indexPath.row == 5)
    {
        retunStr = [detailDict valueForKey:@"portno"];
    }
    else if (indexPath.row == 6)
    {
        retunStr = @"See on the Map";
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    retunStr = [self checkforValidString:retunStr];
    cell.lblValue.text = retunStr;

    if (IS_IPHONE_4)
    {
        cell.lblBack.frame = CGRectMake(0, 0,DEVICE_WIDTH,50);
        cell.lblHeader.frame = CGRectMake(10, 5,DEVICE_WIDTH,20);
        cell.lblValue.frame = CGRectMake(10, 25,DEVICE_WIDTH/2-10,25);
        cell.lblLine.frame = CGRectMake(0,49, DEVICE_WIDTH, 1);

    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.backgroundColor = [UIColor whiteColor];
    
    
    return cell;
    
}
- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath;
{
    cell.backgroundColor = [UIColor clearColor];
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row==6)
    {
        MapClassVC * mapV = [[MapClassVC alloc] init];
        mapV.detailsDict = detailDict;
        [self.navigationController pushViewController:mapV animated:YES];
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
-(void)getDeviceDetailService
{
    if ([[self checkforValidString:[detailDict valueForKey:@"imei"]] isEqualToString:@"NA"])
    {
        URBAlertView *alertView = [[URBAlertView alloc] initWithTitle:ALERT_TITLE message:@"Something went wrong. Please try again later." cancelButtonTitle:OK_BTN otherButtonTitles: nil, nil];
        
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
        [APP_DELEGATE endHudProcess];
        [APP_DELEGATE startHudProcess:@"Getting details..."];
    
        NSMutableDictionary * dict = [[NSMutableDictionary alloc]init];
        [dict setValue:[detailDict valueForKey:@"imei"] forKey:@"imei"];
        [dict setValue:CURRENT_USER_ID forKey:@"user_id"];
        
        URLManager *manager = [[URLManager alloc] init];
        manager.commandName = @"TestDevice";
        manager.delegate = self;
        NSString *strServerUrl = @"http://succorfish.in/mobile/ins/last/details";
        [manager postUrlCall:[NSString stringWithFormat:@"%@",strServerUrl] withParameters:dict];
    }
}
#pragma mark - UrlManager Delegate
- (void)onResult:(NSDictionary *)result
{
    [APP_DELEGATE endHudProcess];
//    NSLog(@"The result is...%@", result);
    
    if ([[result valueForKey:@"commandName"] isEqualToString:@"TestDevice"])
    {
        if ([[[result valueForKey:@"result"] valueForKey:@"response"] isEqualToString:@"true"])
        {
            detailDict = [[NSMutableDictionary alloc] init];
            detailDict = [[[result valueForKey:@"result"] valueForKey:@"data"] mutableCopy];
            NSString * dates = [APP_DELEGATE getConvertedDate:[detailDict valueForKey:@"date"] withFormat:[[NSUserDefaults standardUserDefaults]valueForKey:@"GloablDateFormat"]];
            [detailDict setObject:dates forKey:[[NSUserDefaults standardUserDefaults]valueForKey:@"globalDate"]];
            [tblView reloadData];
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
    
    if (ancode == -1001 || ancode == -1004 || ancode == -1005 || ancode == -1009) {
        [APP_DELEGATE ShowErrorPopUpWithErrorCode:ancode andMessage:@""];
    } else {
        [APP_DELEGATE ShowErrorPopUpWithErrorCode:customErrorCodeForMessage andMessage:@"Please try again later"];
    }
    
    
    NSString * strLoginUrl = [NSString stringWithFormat:@"%@%@",WEB_SERVICE_URL,@"token.json"];
    if ([[errorDict valueForKey:@"NSErrorFailingURLStringKey"] isEqualToString:strLoginUrl])
    {
        NSLog(@"NSErrorFailingURLStringKey===%@",[errorDict valueForKey:@"NSErrorFailingURLStringKey"]);
    }
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(NSString *)getConvertedDate:(NSString *)strDate withFormat:(NSString *)strFormat
{
    NSDateFormatter * dateFormater =[[NSDateFormatter alloc] init];
    [dateFormater setDateFormat:[NSString stringWithFormat:@"%@ HH:mm",[[NSUserDefaults standardUserDefaults] valueForKey:@"GloablDateFormat"]]];
    
    NSDate * serverDate =[dateFormater dateFromString:strDate];
    
    NSString * globalDateFormat = [NSString stringWithFormat:@"%@ HH:mm",strFormat];
    [dateFormater setDateFormat:globalDateFormat];
    
    NSString * strDateConverted =[dateFormater stringFromDate:serverDate];
    return strDateConverted;
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
