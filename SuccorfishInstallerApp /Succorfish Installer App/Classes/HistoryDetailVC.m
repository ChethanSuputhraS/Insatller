//
//  HistoryDetailVC.m
//  Succorfish Installer App
//
//  Created by stuart watts on 10/03/2018.
//  Copyright © 2018 Kalpesh Panchasara. All rights reserved.
//

#import "HistoryDetailVC.h"
#import "DetailCell.h"
#import "ViewPDFVC.h"
#import "TestDeviceVC.h"
#import "LastWaypointVC.h"

@interface HistoryDetailVC ()<URLManagerDelegate>
{
    int textSize;
    NSString * serverID;
}
@end

@implementation HistoryDetailVC
@synthesize detailDict,strType,isFromSearch;
- (void)viewDidLoad
{
    textSize = 17;
    if (IS_IPHONE_5 || IS_IPHONE_4)
    {
        textSize = 15;
    }
    UIImageView * imgBack = [[UIImageView alloc] init];
    imgBack.frame = CGRectMake(0, 0, DEVICE_WIDTH, DEVICE_HEIGHT);
    imgBack.image = [UIImage imageNamed:@"Splash_bg.png"];
    imgBack.userInteractionEnabled = YES;
    [self.view addSubview:imgBack];
    
    lblArr = [NSArray arrayWithObjects:@"Date",@"IMEI Code",@"Asset Name",@"Reg. No",@"Device Type", nil];

    [self setNavigationViewFrames];
    [self setMainContentView];
    
   

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
    [lblTitle setText:@"Report Detail"];
    [lblTitle setTextAlignment:NSTextAlignmentCenter];
    [lblTitle setFont:[UIFont fontWithName:CGRegular size:textSize]];
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
    
    UILabel * lblLine9 = [[UILabel alloc] initWithFrame:CGRectMake(0,viewHeader.frame.size.height-1, viewHeader.frame.size.width, 1)];
    [lblLine9 setBackgroundColor:[UIColor grayColor]];
    [viewHeader addSubview:lblLine9];
    
    int yy = 64;
    
 if (IS_IPHONE_X)
    {
        yy = 88;
        viewHeader.frame = CGRectMake(0, 0, DEVICE_WIDTH, yy);
        lblTitle.frame = CGRectMake(50, 40, DEVICE_WIDTH-100, 55);
        backImg.frame = CGRectMake(10, 12+44, 12, 20);
        btnBack.frame = CGRectMake(0, 0, 70, 88);
        lblLine9.frame =  CGRectMake(0,viewHeader.frame.size.height-1, viewHeader.frame.size.width, 1);
    }
    
    tblContent = [[UITableView alloc] initWithFrame:CGRectMake(0,yy + 20, DEVICE_WIDTH, DEVICE_HEIGHT-84-100) style:UITableViewStylePlain];
    [tblContent setBackgroundColor:[UIColor clearColor]];
    [tblContent setShowsVerticalScrollIndicator:NO];
    tblContent.separatorStyle = UITableViewCellSeparatorStyleNone;
    tblContent.delegate = self;
    tblContent.dataSource = self;
    [self.view addSubview:tblContent];
}

-(void)setMainContentView
{
    UIButton * btnPdf = [UIButton buttonWithType:UIButtonTypeCustom];
    [btnPdf setTitle:@"View PDF" forState:UIControlStateNormal];
    [btnPdf setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [btnPdf addTarget:self action:@selector(btnViewPDFClick) forControlEvents:UIControlEventTouchUpInside];
    btnPdf.frame = CGRectMake(0, DEVICE_HEIGHT-50 , DEVICE_WIDTH/2,50);
    btnPdf.titleLabel.font =[UIFont fontWithName:CGRegular size:textSize];
    [btnPdf setBackgroundImage:[UIImage imageNamed:@"BTN.png"] forState:UIControlStateNormal];
    [btnPdf setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.view addSubview:btnPdf];
    
    if ([[self checkforValidString:[detailDict valueForKey:@"pdf_url"]] isEqualToString:@"NA"])
    {
        [btnPdf setEnabled:NO];
        [btnPdf setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
    }
    
    UIButton * btnRecord = [UIButton buttonWithType:UIButtonTypeCustom];
    [btnRecord setTitle:@"View Install Record" forState:UIControlStateNormal];
    [btnRecord setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    btnRecord.titleLabel.numberOfLines = 0;
    [btnRecord addTarget:self action:@selector(btnViewInstallClick) forControlEvents:UIControlEventTouchUpInside];
    btnRecord.frame = CGRectMake(DEVICE_WIDTH/2, DEVICE_HEIGHT-50, DEVICE_WIDTH/2, 50);
    btnRecord.titleLabel.font =[UIFont fontWithName:CGRegular size:textSize];
    [btnRecord setBackgroundImage:[UIImage imageNamed:@"BTN.png"] forState:UIControlStateNormal];
    [self.view addSubview:btnRecord];
    
    if (IS_IPHONE_X)
    {
        btnPdf.frame = CGRectMake(0, DEVICE_HEIGHT-40-50 , DEVICE_WIDTH/2,50);
        btnRecord.frame = CGRectMake(DEVICE_WIDTH/2, DEVICE_HEIGHT-50-40, DEVICE_WIDTH/2, 50);
    }
}



-(void)btnBackClick
{
    [self.navigationController popViewControllerAnimated:YES];
}
-(void)btnViewPDFClick
{
    ViewPDFVC * pdfVC = [[ViewPDFVC alloc] init];
    pdfVC.strPdfUrl = [detailDict valueForKey:@"pdf_url"];
    pdfVC.detailDict = detailDict;
    pdfVC.strReportType = strType;
    pdfVC.strDate = [detailDict valueForKey:[[NSUserDefaults standardUserDefaults] valueForKey:@"globalDate"]];
    pdfVC.strIMEI = [detailDict valueForKey:@"imei"];
    pdfVC.strVessel = [detailDict valueForKey:@"vesselname"];
    [self.navigationController pushViewController:pdfVC animated:YES];
}
-(void)btnViewInstallClick
{
    if ([APP_DELEGATE isNetworkreachable])
    {
        [self TestDeviceRomanAPI];
    }
    else
    {
        TestDeviceVC * pdfVC = [[TestDeviceVC alloc] init];
        pdfVC.detailDict = detailDict;
        pdfVC.isfromHistory = YES;
        [self.navigationController pushViewController:pdfVC animated:YES];
    }
}
-(void)TestDeviceRomanAPI
{
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0ul);
    dispatch_async(queue, ^{
        {
            NSMutableDictionary *args = [[NSMutableDictionary alloc] init];
            
            NSString * strUrl = [NSString stringWithFormat:@"https://ws.scstg.net/basic/v2/device-history/getLatestInstallFor/%@",[detailDict valueForKey:@"succor_device_id"]];
            
            NSString * strbasicAuthToken;
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
                
                if ([responseObject isKindOfClass:[NSDictionary class]])
                {
                    NSMutableDictionary * dictID = [[NSMutableDictionary alloc] init];
                    dictID = [responseObject mutableCopy];
                    NSString * strGeneratDate = [NSString stringWithFormat:@"%@",[dictID valueForKey:@"created"]];

                    NSString *_date= [APP_DELEGATE GetRealDatefromTimeStamp:strGeneratDate];
                    
                    NSMutableDictionary * dtaliDict = [[NSMutableDictionary alloc] init];
                    [dtaliDict setObject:_date forKey:@"date"];
                    [dtaliDict setObject:[detailDict valueForKey:@"imei"] forKey:@"imei"];
                    [dtaliDict setObject:[dictID valueForKey:@"installationPlace"] forKey:@"location"];
                    [dtaliDict setObject:[dictID valueForKey:@"realAssetName"] forKey:@"vessel"];
                    [dtaliDict setObject:[self checkforValidString:[dictID valueForKey:@"realAssetRegNo"]] forKey:@"regino"];

                    LastWaypointVC * lastVC = [[LastWaypointVC alloc] init];
                    lastVC.detailDict = dtaliDict;
                    lastVC.isfromHistory = YES;
                    [self.navigationController pushViewController:lastVC animated:YES];
                }
                else
                {
                    TestDeviceVC * pdfVC = [[TestDeviceVC alloc] init];
                    pdfVC.detailDict = detailDict;
                    pdfVC.isfromHistory = YES;
                    [self.navigationController pushViewController:pdfVC animated:YES];
                    
                }
                
            }
                                               failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                                   if (error) {
                                                       TestDeviceVC * pdfVC = [[TestDeviceVC alloc] init];
                                                       pdfVC.detailDict = detailDict;
                                                       pdfVC.isfromHistory = YES;
                                                       [self.navigationController pushViewController:pdfVC animated:YES];
                                                       
                                                       NSLog(@"Servicer error = %@", error);
                                                       
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
#pragma mark- UITableView Methods
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 5;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    DetailCell *cell = [tableView dequeueReusableCellWithIdentifier:@"HistoryCustomCell"];
    if (cell==nil)
    {
        cell = [[DetailCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"HistoryCustomCell"];
    }
    cell.lblHeader.text = [lblArr objectAtIndex:indexPath.row];
    
    if ([strType isEqualToString:@"Install"])
    {
        cell.lblValue.text = [self getValueforInstalls:indexPath.row];
    }
    else if ([strType isEqualToString:@"UnInstall"])
    {
        cell.lblValue.text = [self getValueforUNInstalls:indexPath.row];
    }
    else if ([strType isEqualToString:@"Inspection"])
    {
        cell.lblValue.text = [self getValueforInspections:indexPath.row];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.backgroundColor = [UIColor whiteColor];
    
    return cell;
    
}
- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath;
{
    cell.backgroundColor = [UIColor clearColor];
}

-(NSString *)getValueforInstalls:(NSInteger)indexx
{
    NSString * retunStr;
    if (indexx == 0)
    {
        retunStr = [detailDict valueForKey:[[NSUserDefaults standardUserDefaults] valueForKey:@"globalDate"]];
    }
    else if (indexx == 1)
    {
        retunStr = [detailDict valueForKey:@"imei"];
    }
    else if (indexx == 2)
    {
        retunStr = [detailDict valueForKey:@"vesselname"];
    }
    else if (indexx == 3)
    {
        retunStr = [detailDict valueForKey:@"portno"];
    }
    else if (indexx == 4)
    {
        retunStr = [detailDict valueForKey:@"device_type"];
    }
    retunStr = [self checkforValidString:retunStr];
    return retunStr;
}

-(NSString *)getValueforUNInstalls:(NSInteger)indexx
{
    NSString * retunStr;
    if (indexx == 0)
    {
        retunStr = [detailDict valueForKey:[[NSUserDefaults standardUserDefaults] valueForKey:@"globalDate"]];
    }
    else if (indexx == 1)
    {
        retunStr = [detailDict valueForKey:@"imei"];
    }
    else if (indexx == 2)
    {
        retunStr = [detailDict valueForKey:@"vesselname"];
    }
    else if (indexx == 3)
    {
        retunStr = [detailDict valueForKey:@"portno"];
    }
    else if (indexx == 4)
    {
        retunStr = [detailDict valueForKey:@"device_type"];
    }
    retunStr = [self checkforValidString:retunStr];
    return retunStr;
}

-(NSString *)getValueforInspections:(NSInteger)indexx
{
    NSString * retunStr;
    if (indexx == 0)
    {
        retunStr = [detailDict valueForKey:[[NSUserDefaults standardUserDefaults] valueForKey:@"globalDate"]];
    }
    else if (indexx == 1)
    {
        retunStr = [detailDict valueForKey:@"imei"];
    }
    else if (indexx == 2)
    {
        retunStr = [detailDict valueForKey:@"vesselname"];
    }
    else if (indexx == 3)
    {
        retunStr = [detailDict valueForKey:@"portno"];
    }
    else if (indexx == 4)
    {
        retunStr = [detailDict valueForKey:@"device_type"];
    }
    retunStr = [self checkforValidString:retunStr];
    return retunStr;
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
- (void)onResult:(NSDictionary *)result
{
    [APP_DELEGATE endHudProcess];
//    NSLog(@"The result is...%@", result);
    
    if ([[result valueForKey:@"commandName"] isEqualToString:@"GetDetails"])
    {
        if ([[[result valueForKey:@"result"] valueForKey:@"response"] isEqualToString:@"true"])
        {
            NSMutableDictionary * tmpDict = [[NSMutableDictionary alloc] init];
            tmpDict = [[result valueForKey:@"result"] valueForKey:@"data"];
            
            if (tmpDict == [NSNull null] || tmpDict == nil)
            {
                
            }
            else
            {
                
                if ([strType isEqualToString:@"Install"])
                {
                    NSString * dates = [APP_DELEGATE getConvertedDate:[tmpDict valueForKey:@"date"] withFormat:[[NSUserDefaults standardUserDefaults]valueForKey:@"GloablDateFormat"]];
                    [detailDict setObject:dates forKey:[[NSUserDefaults standardUserDefaults]valueForKey:@"globalDate"]];
                    [detailDict setValue:[tmpDict valueForKey:@"pdfpath"] forKey:@"pdf_url"];
                    [tblContent reloadData];

                    NSString * pdfPath = [tmpDict valueForKey:@"pdfpath"];
                    NSString * serverID = [tmpDict valueForKey:@"id"];
                    
                    NSString * strUpdate = [NSString stringWithFormat:@"Update 'tbl_install' set pdf_url='%@' where server_id = '%@'",pdfPath,serverID];
                    [[DataBaseManager dataBaseManager] execute:strUpdate];
                }
                else if ([strType isEqualToString:@"UnInstall"])
                {
                    NSString * dates = [APP_DELEGATE getConvertedDate:[tmpDict valueForKey:@"uninstall_date"] withFormat:[[NSUserDefaults standardUserDefaults]valueForKey:@"GloablDateFormat"]];
                    [detailDict setObject:dates forKey:[[NSUserDefaults standardUserDefaults]valueForKey:@"globalDate"]];
                    [detailDict setValue:[tmpDict valueForKey:@"pdfpath"] forKey:@"pdf_url"];
                    [tblContent reloadData];

                    NSString * pdfPath = [tmpDict valueForKey:@"pdfpath"];
                    NSString * serverID = [tmpDict valueForKey:@"id"];
                    
                    NSString * strUpdate = [NSString stringWithFormat:@"Update 'tbl_install' set pdf_url='%@' where server_id = '%@'",pdfPath,serverID];
                    [[DataBaseManager dataBaseManager] execute:strUpdate];
                }
                else if ([strType isEqualToString:@"Inspection"])
                {
                    NSString * dates = [APP_DELEGATE getConvertedDate:[tmpDict valueForKey:@"inspection_date"] withFormat:[[NSUserDefaults standardUserDefaults]valueForKey:@"GloablDateFormat"]];
                    [detailDict setObject:dates forKey:[[NSUserDefaults standardUserDefaults]valueForKey:@"globalDate"]];
                    [detailDict setValue:[tmpDict valueForKey:@"pdfpath"] forKey:@"pdf_url"];
                    [tblContent reloadData];

                    NSString * pdfPath = [tmpDict valueForKey:@"pdfpath"];
                    NSString * serverID = [tmpDict valueForKey:@"id"];
                    
                    NSString * strUpdate = [NSString stringWithFormat:@"Update 'tbl_inspection' set pdf_url='%@' where server_id = '%@'",pdfPath,serverID];
                    [[DataBaseManager dataBaseManager] execute:strUpdate];
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
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
