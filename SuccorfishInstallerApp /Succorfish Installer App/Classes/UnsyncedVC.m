//
//  UnsyncedVC.m
//  Succorfish Installer App
//
//  Created by stuart watts on 09/03/2018.
//  Copyright © 2018 Kalpesh Panchasara. All rights reserved.
//

#import "UnsyncedVC.h"
#import "NYSegmentedControl.h"
#import "HistoryCustomCell.h"
#import "UnInstalledVC.h"
#import "InspectionVC.h"
#import "SNHVC.h"

@interface UnsyncedVC ()<UITableViewDelegate,UITableViewDataSource>
{
    NYSegmentedControl *blueSegmentedControl;
    NSMutableArray * installArr, * inspectionArr, * unInstallArr;
    NSString * typeSelected;
    UITableView * tblContent;
    
    UILabel * lblNoData;

}
@end

@implementation UnsyncedVC

- (void)viewDidLoad
{
    UIImageView * imgBack = [[UIImageView alloc] init];
    imgBack.frame = CGRectMake(0, 0, DEVICE_WIDTH, DEVICE_HEIGHT);
    imgBack.image = [UIImage imageNamed:@"Splash_bg.png"];
    imgBack.userInteractionEnabled = YES;
    [self.view addSubview:imgBack];

    typeSelected = @"Install";
    
    installArr = [[NSMutableArray alloc] init];
    inspectionArr = [[NSMutableArray alloc] init];
    unInstallArr = [[NSMutableArray alloc] init];

    [self setNavigationViewFrames];

    [super viewDidLoad];
    // Do any additional setup after loading the view.
}
-(void)viewWillAppear:(BOOL)animated
{
    installArr = [[NSMutableArray alloc] init];
    inspectionArr = [[NSMutableArray alloc] init];
    unInstallArr = [[NSMutableArray alloc] init];
    [self getUpdatedData];
    

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
    [lblTitle setText:@"Unsynced"];
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
    
    blueSegmentedControl = [[NYSegmentedControl alloc] initWithItems:@[@"Install", @"Uninstall",@"Inspection"]];
    blueSegmentedControl.titleTextColor = [UIColor blackColor];
    blueSegmentedControl.selectedTitleTextColor = [UIColor whiteColor];
    blueSegmentedControl.segmentIndicatorBackgroundColor = [UIColor blackColor];
    blueSegmentedControl.backgroundColor = [UIColor whiteColor];
    blueSegmentedControl.borderWidth = 0.0f;
    blueSegmentedControl.segmentIndicatorBorderWidth = 0.0f;
    blueSegmentedControl.segmentIndicatorInset = 2.0f;
    blueSegmentedControl.segmentIndicatorBorderColor = self.view.backgroundColor;
    blueSegmentedControl.cornerRadius = 20;
    blueSegmentedControl.usesSpringAnimations = YES;
    [blueSegmentedControl addTarget:self action:@selector(segmentClick:) forControlEvents:UIControlEventValueChanged];
    [blueSegmentedControl setFrame:CGRectMake(10,0+64, DEVICE_WIDTH-20, 40)];
    blueSegmentedControl.layer.cornerRadius = 20;
    blueSegmentedControl.layer.masksToBounds = YES;
    [self.view addSubview:blueSegmentedControl];
    
    int yy = 64 + 60 -10;

    if (IS_IPHONE_4 || IS_IPHONE_5)
    {
        yy = 64 + 60-10;
        viewHeader.frame = CGRectMake(0, 0, DEVICE_WIDTH, yy);
    }
    else if (IS_IPHONE_X)
    {
        yy = 88+70-10;
        viewHeader.frame = CGRectMake(0, 0, DEVICE_WIDTH, yy);
        lblTitle.frame = CGRectMake(50, 40, DEVICE_WIDTH-100, 55);
        backImg.frame = CGRectMake(10, 12+44, 12, 20);
        btnBack.frame = CGRectMake(0, 20, 70, 84);
        [blueSegmentedControl setFrame:CGRectMake(10,0+88, DEVICE_WIDTH-20, 48)];
        blueSegmentedControl.cornerRadius = 24;
        blueSegmentedControl.layer.cornerRadius = 24;
        
    }
    else
    {
        viewHeader.frame = CGRectMake(0, 0, DEVICE_WIDTH, yy);
    }
    
    tblContent = [[UITableView alloc] initWithFrame:CGRectMake(0,yy+5, DEVICE_WIDTH, DEVICE_HEIGHT-yy-5) style:UITableViewStylePlain];
    [tblContent setBackgroundColor:[UIColor clearColor]];
    [tblContent setShowsVerticalScrollIndicator:NO];
    tblContent.separatorStyle = UITableViewCellSeparatorStyleNone;
    tblContent.delegate = self;
    tblContent.dataSource = self;
    [self.view addSubview:tblContent];
    
    if (IS_IPHONE_X)
    {
        tblContent.frame = CGRectMake(0,yy+5, DEVICE_WIDTH, DEVICE_HEIGHT-yy-5-45);
    }
    
    lblNoData =  [[UILabel alloc] initWithFrame:CGRectMake(0, yy-64, DEVICE_WIDTH, DEVICE_HEIGHT-yy)];
    [lblNoData setBackgroundColor:[UIColor clearColor]];
    [lblNoData setText:@"No records found"];
    [lblNoData setTextAlignment:NSTextAlignmentCenter];
    [lblNoData setFont:[UIFont fontWithName:CGBold size:20]];
    [lblNoData setTextColor:[UIColor whiteColor]];
    lblNoData.hidden = YES;
    [viewHeader addSubview:lblNoData];
    
    typeSelected = @"Install";
    if ([installArr count]==0)
    {
        NSString * str = [NSString stringWithFormat:@"Select * from tbl_install where is_sync = 0 and user_id = '%@' order by createdTimeStamp DESC",CURRENT_USER_ID];
        [[DataBaseManager dataBaseManager] execute:str resultsArray:installArr];
    }
    if ([installArr count]==0)
    {
        lblNoData.hidden = NO;
        tblContent.hidden = YES;
    }
    else
    {
        lblNoData.hidden = YES;
        tblContent.hidden = NO;
    }
}

#pragma mark - Button Click events
-(void)btnBackClick
{
    [self.navigationController popViewControllerAnimated:YES];
}
-(void)segmentClick:(NYSegmentedControl *) sender
{
    if (sender.selectedSegmentIndex==0)
    {
        typeSelected = @"Install";
        [self getUpdatedData];
    }
    else if (sender.selectedSegmentIndex==1)
    {
        typeSelected = @"UnInstall";
        [self getUpdatedData];
    }
    else if (sender.selectedSegmentIndex==2)
    {
        typeSelected = @"Inspection";
        [self getUpdatedData];
    }
}

-(void)getUpdatedData
{
    if ([typeSelected isEqualToString:@"Install"])
    {
        if ([installArr count]==0)
        {
            NSString * str = [NSString stringWithFormat:@"Select * from tbl_install where is_sync = 0 and user_id = '%@'order by createdTimeStamp DESC",CURRENT_USER_ID];
            [[DataBaseManager dataBaseManager] execute:str resultsArray:installArr];
        }
        if ([installArr count]==0)
        {
            lblNoData.hidden = NO;
            tblContent.hidden = YES;
        }
        else
        {
            lblNoData.hidden = YES;
            tblContent.hidden = NO;
            [UIApplication sharedApplication].applicationIconBadgeNumber=[installArr count];
        }
        [tblContent reloadData];
    }
    else if ([typeSelected isEqualToString:@"UnInstall"])
    {
        if ([unInstallArr count]==0)
        {
            NSString * str = [NSString stringWithFormat:@"Select * from tbl_uninstall where is_sync = 0 and user_id = '%@'  order by createdTimeStamp DESC",CURRENT_USER_ID];
            [[DataBaseManager dataBaseManager] execute:str resultsArray:unInstallArr];
        }
        if ([unInstallArr count]==0)
        {
            lblNoData.hidden = NO;
            tblContent.hidden = YES;
        }
        else
        {
            lblNoData.hidden = YES;
            tblContent.hidden = NO;
        }
        [tblContent reloadData];
    }
    else if ([typeSelected isEqualToString:@"Inspection"])
    {
        if ([inspectionArr count]==0)
        {
            NSString * str = [NSString stringWithFormat:@"Select * from tbl_inspection where is_sync = 0 and user_id = '%@' order by createdTimeStamp DESC",CURRENT_USER_ID];
            [[DataBaseManager dataBaseManager] execute:str resultsArray:inspectionArr];
        }
        if ([inspectionArr count]==0)
        {
            lblNoData.hidden = NO;
            tblContent.hidden = YES;
        }
        else
        {
            lblNoData.hidden = YES;
            tblContent.hidden = NO;
        }
        [tblContent reloadData];
    }
    
    [APP_DELEGATE updateBadgeCount];
}

#pragma mark- UITableView Methods
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if ([typeSelected isEqualToString:@"Install"])
    {
        return [installArr count];
    }
    else if ([typeSelected isEqualToString:@"UnInstall"])
    {
        return [unInstallArr count];
    }
    else if ([typeSelected isEqualToString:@"Inspection"])
    {
        return [inspectionArr count];
    }
    return 0;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 90;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    HistoryCustomCell *cell = [tableView dequeueReusableCellWithIdentifier:@"HistoryCustomCell"];
    if (cell==nil)
    {
        cell = [[HistoryCustomCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"HistoryCustomCell"];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.backgroundColor = [UIColor whiteColor];

    cell.lblDate.hidden = NO;
    cell.lblStatus.hidden = YES;
    
    if ([typeSelected isEqualToString:@"Install"])
    {
        cell.lblEMI.text = [self checkforValidString:[[installArr objectAtIndex:indexPath.row] valueForKey:@"imei"]];
        cell.lblVessel.text = [self checkforValidString:[[installArr objectAtIndex:indexPath.row] valueForKey:@"vesselname"]];
        cell.lblRegi.text = [self checkforValidString:[[installArr objectAtIndex:indexPath.row] valueForKey:@"portno"]];
        cell.lblDate.text = [self checkforValidString:[[installArr objectAtIndex:indexPath.row] valueForKey:[[NSUserDefaults standardUserDefaults] valueForKey:@"globalDate"]]];
        cell.lblDeviceType.text = [self checkforValidString:[[installArr objectAtIndex:indexPath.row] valueForKey:@"device_type"]];

        if ([[[installArr objectAtIndex:indexPath.row] valueForKey:@"complete_status"] isEqualToString:@"COMPLETE"])
        {
            cell.lblStatus.hidden = YES;
        }
        else
        {
            cell.lblStatus.hidden = NO;
        }
    }
    else if ([typeSelected isEqualToString:@"UnInstall"])
    {
        cell.lblEMI.text = [self checkforValidString:[[unInstallArr objectAtIndex:indexPath.row] valueForKey:@"imei"]];
        cell.lblVessel.text = [self checkforValidString:[[unInstallArr objectAtIndex:indexPath.row] valueForKey:@"vesselname"]];
        cell.lblRegi.text = [self checkforValidString:[[unInstallArr objectAtIndex:indexPath.row] valueForKey:@"portno"]];
        cell.lblDeviceType.text = [self checkforValidString:[[unInstallArr objectAtIndex:indexPath.row] valueForKey:@"device_type"]];
        cell.lblDate.text = [self checkforValidString:[[unInstallArr objectAtIndex:indexPath.row] valueForKey:[[NSUserDefaults standardUserDefaults] valueForKey:@"globalDate"]]];

        if ([[[unInstallArr objectAtIndex:indexPath.row] valueForKey:@"complete_status"] isEqualToString:@"COMPLETE"])
        {
            cell.lblStatus.hidden = YES;
        }
        else
        {
            cell.lblStatus.hidden = NO;
        }
    }
    else if ([typeSelected isEqualToString:@"Inspection"])
    {
        cell.lblEMI.text = [self checkforValidString:[[inspectionArr objectAtIndex:indexPath.row] valueForKey:@"imei"]];
        cell.lblVessel.text = [self checkforValidString:[[inspectionArr objectAtIndex:indexPath.row] valueForKey:@"vesselname"]];
        cell.lblRegi.text = [self checkforValidString:[[inspectionArr objectAtIndex:indexPath.row] valueForKey:@"portno"]];
        cell.lblDeviceType.text = [self checkforValidString:[[inspectionArr objectAtIndex:indexPath.row] valueForKey:@"device_type"]];
        cell.lblDate.text = [self checkforValidString:[[inspectionArr objectAtIndex:indexPath.row] valueForKey:[[NSUserDefaults standardUserDefaults] valueForKey:@"globalDate"]]];

        if ([[[inspectionArr objectAtIndex:indexPath.row] valueForKey:@"complete_status"] isEqualToString:@"COMPLETE"])
        {
            cell.lblStatus.hidden = YES;
        }
        else
        {
            cell.lblStatus.hidden = NO;
            
        }
    }
    cell.lblStatus.frame = CGRectMake(DEVICE_WIDTH/2, 30,DEVICE_WIDTH/2-5,25);
    cell.lblDate.frame = CGRectMake(DEVICE_WIDTH/2, 55,DEVICE_WIDTH/2-5,25);


    return cell;
}
- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath;
{
    cell.backgroundColor = [UIColor clearColor];
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([typeSelected isEqualToString:@"Install"])
    {
//        NewInstallVC * instV = [[NewInstallVC alloc] init];
        SNHVC *instV = [[SNHVC alloc]init];
        instV.isFromeEdit = YES;
        instV.detailDict = [installArr objectAtIndex:indexPath.row];
        instV.strType = @"install";
        [self.navigationController pushViewController:instV animated:YES];
        
    }
    else if ([typeSelected isEqualToString:@"UnInstall"])
    {
        SNHVC *instV = [[SNHVC alloc]init];
        instV.isFromeEdit = YES;
        instV.detailDict = [unInstallArr objectAtIndex:indexPath.row];
        instV.strType = @"uninstall";
        [self.navigationController pushViewController:instV animated:YES];
    }
    else if ([typeSelected isEqualToString:@"Inspection"])
    {
        SNHVC *instV = [[SNHVC alloc]init];
        instV.isFromeEdit = YES;
        instV.detailDict = [inspectionArr objectAtIndex:indexPath.row];
        instV.strType = @"inspection";
        [self.navigationController pushViewController:instV animated:YES];
    }
}
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    URBAlertView *alertView = [[URBAlertView alloc] initWithTitle:ALERT_TITLE message:@"Are you sure want to delete this report?" cancelButtonTitle:@"Yes" otherButtonTitles: @"NO", nil];
    [alertView setMessageFont:[UIFont fontWithName:CGRegular size:12]];
    [alertView setHandlerBlock:^(NSInteger buttonIndex, URBAlertView *alertView) {
        [alertView hideWithCompletionBlock:^{
            if (buttonIndex==0)
            {
                NSString * strTable, * strId;
                if ([typeSelected isEqualToString:@"Install"])
                {
                    strTable = @"tbl_install";
                    strId = [NSString stringWithFormat:@" where id = '%@' and user_id = '%@'",[[installArr objectAtIndex:indexPath.row] valueForKey:@"id"],CURRENT_USER_ID];
                    
                    NSString * strPhotoDelete = [NSString stringWithFormat:@"delete from tbl_installer_photo where inst_local_id = '%@' and inst_photo_user_id = '%@'",[[installArr objectAtIndex:indexPath.row] valueForKey:@"id"],CURRENT_USER_ID];
                    [[DataBaseManager dataBaseManager] execute:strPhotoDelete];
                    
                    [installArr removeObjectAtIndex:indexPath.row];

                }
                else if ([typeSelected isEqualToString:@"UnInstall"])
                {
                    strTable = @"tbl_uninstall";
                    strId = [NSString stringWithFormat:@" where id = '%@' and user_id = '%@'",[[unInstallArr objectAtIndex:indexPath.row] valueForKey:@"id"],CURRENT_USER_ID];

                    [unInstallArr removeObjectAtIndex:indexPath.row];
                }
                else if ([typeSelected isEqualToString:@"Inspection"])
                {
                    strTable = @"tbl_inspection";
                    strId = [NSString stringWithFormat:@" where id = '%@' and user_id = '%@'",[[inspectionArr objectAtIndex:indexPath.row] valueForKey:@"id"],CURRENT_USER_ID];
                    
                    NSString * strPhotoDelete = [NSString stringWithFormat:@"delete from tbl_inspection_photo where insp_local_id = '%@' and insp_photo_user_id = '%@'",[[inspectionArr objectAtIndex:indexPath.row] valueForKey:@"id"],CURRENT_USER_ID];
                    [[DataBaseManager dataBaseManager] execute:strPhotoDelete];
                    
                    [inspectionArr removeObjectAtIndex:indexPath.row];

                }
                [tblContent reloadData];
                NSString * strDelet = [NSString stringWithFormat:@"delete from %@ %@",strTable,strId];
                [[DataBaseManager dataBaseManager] execute:strDelet];
                
                [APP_DELEGATE updateBadgeCount];
            }
            
        }];
    }];
      [alertView showWithAnimation:Alert_Animation_Type];
        if (IS_IPHONE_X) {[alertView showWithAnimation:URBAlertAnimationDefault];}
    
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
