//
//  BeaconHistory.m
//  Succorfish Installer App
//
//  Created by Ashwin on 7/30/20.
//  Copyright © 2020 Kalpesh Panchasara. All rights reserved.
//

#import "BeaconHistory.h"
#import "BeaconHistroyCell.h"

@interface BeaconHistory ()<URLManagerDelegate,UITableViewDelegate,UITableViewDataSource>
{
    int textSize;
    NSMutableArray * arrHistory;
    

}
@end

@implementation BeaconHistory
@synthesize dictData;

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
    lblHeadere.text = @"History";
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
    [btnBack addTarget:self action:@selector(btnBackClick) forControlEvents:UIControlEventTouchUpInside];
    btnBack.frame = CGRectMake(0, 0, 70, 64);
    btnBack.backgroundColor = [UIColor clearColor];
    [navigView addSubview:btnBack];
    
    tblBeaconHistroy = [[UITableView alloc] initWithFrame:CGRectMake(0, 64, DEVICE_WIDTH, DEVICE_HEIGHT-64)];
    tblBeaconHistroy.delegate = self;
    tblBeaconHistroy.dataSource = self;
    tblBeaconHistroy.backgroundColor = UIColor.clearColor;
    tblBeaconHistroy.separatorStyle = UITableViewCellSelectionStyleNone;
    [self.view addSubview:tblBeaconHistroy];
    arrHistory = [[NSMutableArray alloc] init];

    [self getDeviceHistoryBLERomanAPI];
    

    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

#pragma mark - UITableView Delegates
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 82;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return arrHistory.count;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellReuseIdentifier = @"cellIdentifier";
    BeaconHistroyCell *cell = [tableView dequeueReusableCellWithIdentifier:cellReuseIdentifier];
    if (cell == nil)
    {
        cell = [[BeaconHistroyCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellReuseIdentifier];
    }
    
    cell.lblbeaconNum.text = [[arrHistory objectAtIndex:indexPath.row] valueForKey:@"id"];
    cell.lblName.text = [NSString stringWithFormat:@"Name : %@",[self checkforValidString:[[arrHistory objectAtIndex:indexPath.row] valueForKey:@"name"]]];
    cell.lblBatteryType.text =[NSString stringWithFormat:@"Battery : %@",[self checkforValidString:[[arrHistory objectAtIndex:indexPath.row] valueForKey:@"battery"]]];
    cell.lblBeconType.text = @"Beacon Type: AIB";
    cell.lblStatus.text = [[arrHistory objectAtIndex:indexPath.row] valueForKey:@"status"];
    cell.lblDate.text = [self DateConverting:[[arrHistory objectAtIndex:indexPath.row]valueForKey:@"date"]];
    
    cell.backgroundColor = UIColor.clearColor;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

#pragma mark - Web Service Call
-(void)getDeviceHistoryBLERomanAPI
{
    if ([APP_DELEGATE isNetworkreachable])
    {
        [APP_DELEGATE endHudProcess];
        [APP_DELEGATE startHudProcess:@"Fetching history..."];
        
        NSString * strBleID = [[dictData valueForKey:@"result"] valueForKey:@"id"];
        NSString * strUrl = [NSString stringWithFormat:@"https://ws.scstg.net/basic/v2/beacon/getForId/%@",strBleID];// histroy URL have to passs
        URLManager *manager = [[URLManager alloc] init];
        manager.commandName = @"GetBeaconHistoryDetail";
        manager.delegate = self;
        [manager getUrlCall:strUrl withParameters:nil];
    }
    else
    {
         URBAlertView * alert =[[URBAlertView alloc] initWithTitle:ALERT_TITLE message:@"Please check internet connection and try again." cancelButtonTitle:OK_BTN otherButtonTitles:nil, nil];
        [alert showWithAnimation:URBAlertAnimationTopToBottom];
    }
}
#pragma mark - UrlManager Delegate
- (void)onResult:(NSDictionary *)result
{
    if([[result valueForKey:@"commandName"] isEqual:@"GetBeaconHistoryDetail"])
    {
        if (result.count > 0)
        {
            arrHistory = [result valueForKey:@"result"];
            
            NSSortDescriptor *sort = [NSSortDescriptor sortDescriptorWithKey:@"date" ascending:NO];
            [arrHistory sortUsingDescriptors:[NSArray arrayWithObject:sort]];
            [tblBeaconHistroy reloadData];
        }
    }
    [APP_DELEGATE endHudProcess];
//    NSLog(@"The Histroy result is...%@", arrHistory);
}
- (void)onError:(NSError *)error
{
    [APP_DELEGATE endHudProcess];
    NSLog(@"The error is...%@", error);
}
-(NSString *)DateConverting:(NSString *)strDate
{
      long timeStamp = [[NSString stringWithFormat:@"%@",strDate] longLongValue];
      NSTimeInterval timeInterval=timeStamp/1000;
      NSDate *date = [NSDate dateWithTimeIntervalSince1970:timeInterval];
      NSDateFormatter *dateformatter=[[NSDateFormatter alloc]init];
      [dateformatter setDateFormat:@"dd/MM/yyyy hh:mm"];
      [dateformatter setTimeZone:[NSTimeZone timeZoneWithName:@"GMT+5:30"]]; // GMT+5:30
      NSString * cDateAndTime = [NSString stringWithFormat:@"%@",[dateformatter stringFromDate:date]];
      return cDateAndTime;
}
-(void)btnBackClick
{
    [self.navigationController popViewControllerAnimated:true];
}
-(NSString *)checkforValidString:(NSString *)strRequest
{
    NSString * strValid;
    if (![strRequest isEqual:[NSNull null]])
    {
        if ((strRequest != nil && strRequest != NULL && ![strRequest isEqualToString:@""]) && ![strRequest isEqualToString:@"<null>"])
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
@end
