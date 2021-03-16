//
//  LastWaypointVC.m
//  Succorfish Installer App
//
//  Created by stuart watts on 24/04/2018.
//  Copyright © 2018 Kalpesh Panchasara. All rights reserved.
//

#import "LastWaypointVC.h"
#import "DetailCell.h"
#import "MapClassVC.h"

@interface LastWaypointVC ()

@end

@implementation LastWaypointVC
@synthesize detailDict,strReasonToCome,isfromHistory,strReportType;

- (void)viewDidLoad
{
    UIImageView * imgBack = [[UIImageView alloc] init];
    imgBack.frame = CGRectMake(0, 0, DEVICE_WIDTH, DEVICE_HEIGHT);
    imgBack.image = [UIImage imageNamed:@"Splash_bg.png"];
    imgBack.userInteractionEnabled = YES;
    [self.view addSubview:imgBack];
    
    [self setNavigationViewFrames];
    [self showInstalledView];
    
    [super viewDidLoad];
    // Do any additional setup after loading the view.
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
-(void)showInstalledView
{
    lblArr = [NSArray arrayWithObjects:@"Generated Date",@"IMEI Code",@"Latitude",@"Longitude",@"Installed Location", nil];
    if (isfromHistory)
    {
        lblArr = [NSArray arrayWithObjects:@"Generated Date",@"IMEI Code",@"Asset Name",@"Regi. No",@"Installation Location", nil];
    }
    [installView removeFromSuperview];
    installView = [[UIView alloc] init];
    installView.frame = CGRectMake(0, statusHeight, DEVICE_WIDTH, DEVICE_HEIGHT-statusHeight);
    installView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:installView];
    
    [tblView removeFromSuperview];
    tblView = [[UITableView alloc] initWithFrame:CGRectMake(0,0,DEVICE_WIDTH,DEVICE_HEIGHT-statusHeight) style:UITableViewStylePlain];
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
    [self.navigationController popViewControllerAnimated:YES];
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
        retunStr = [detailDict valueForKey:@"date"];
    }
    else if (indexPath.row == 1)
    {
        retunStr = [detailDict valueForKey:@"imei"];
    }
    if (isfromHistory)
    {
        if (indexPath.row == 2)
        {
            retunStr = [detailDict valueForKey:@"vessel"];
        }
        else if (indexPath.row == 3)
        {
            retunStr = [detailDict valueForKey:@"regino"];
        }
        else if (indexPath.row == 4)
        {
            retunStr = [detailDict valueForKey:@"location"];
        }
    }
    else
    {
        if (indexPath.row == 2)
        {
            retunStr = [detailDict valueForKey:@"latitude"];
        }
        else if (indexPath.row == 3)
        {
            retunStr = [detailDict valueForKey:@"longitude"];
        }
        else if (indexPath.row == 4)
        {
            retunStr = @"See on the Map";
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        }
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
    if (indexPath.row==4)
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
