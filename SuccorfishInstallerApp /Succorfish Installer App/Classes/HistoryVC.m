//
//  HistoryVC.m
//  Succorfish Installer App
//
//  Created by stuart watts on 21/02/2018.
//  Copyright © 2018 Kalpesh Panchasara. All rights reserved.
//

#import "HistoryVC.h"
#import "HistoryDetailVC.h"
#import "MNMPullToRefreshManager.h"
#import "MNMBottomPullToRefreshManager.h"

@interface HistoryVC ()<UITableViewDelegate,UITableViewDataSource,URLManagerDelegate,MNMPullToRefreshManagerClient,MNMBottomPullToRefreshManagerClient>
{
    int textSize;
    NSInteger start;
    MNMPullToRefreshManager * topPullToRefreshManager;
    MNMBottomPullToRefreshManager *bottomPullToRefreshManager;
    BOOL isFirstTimeCall,isFromBottom, responseAvail ;

}

@end

@implementation HistoryVC

- (void)viewDidLoad
{
    textSize = 16;
    if (IS_IPHONE_4 || IS_IPHONE_5)
    {
        textSize = 15;
    }
    
    start = 0;
    responseAvail = NO;
    isFirstTimeCall = NO;
    isFromBottom = NO;
//    [topPullToRefreshManager setPullToRefreshViewVisible:NO];

    UIImageView * imgBack = [[UIImageView alloc] init];
    imgBack.frame = CGRectMake(0, 0, DEVICE_WIDTH, DEVICE_HEIGHT);
    imgBack.image = [UIImage imageNamed:@"Splash_bg.png"];
    [self.view addSubview:imgBack];
    
    typeSelected = @"Install";
    
    installArr = [[NSMutableArray alloc] init];
    inspectionArr = [[NSMutableArray alloc] init];
    unInstallArr = [[NSMutableArray alloc] init];
    
    [self setNavigationViewFrame];

//    [topPullToRefreshManager tableViewReloadFinishedAnimated:NO];
//    [bottomPullToRefreshManager setPullToRefreshViewVisible:NO];

    // Do any additional setup after loading the view.
}
-(void)viewWillAppear:(BOOL)animated
{
//    [topPullToRefreshManager setPullToRefreshViewVisible:YES];

    installArr = [[NSMutableArray alloc] init];
    inspectionArr = [[NSMutableArray alloc] init];
    unInstallArr = [[NSMutableArray alloc] init];
    [self getUpdatedData];
    [self getInstallationHistoryfromSuccorfish];

    [APP_DELEGATE showTabBar:self.tabBarController];
    [super viewWillAppear:YES];
}
-(void)setNavigationViewFrame
{
    UIView * viewHeader = [[UIView alloc] initWithFrame:CGRectMake(0, 0, DEVICE_WIDTH, 64)];
    [viewHeader setBackgroundColor:[UIColor blackColor]];
    [self.view addSubview:viewHeader];
    
    UILabel * lblTitle = [[UILabel alloc] initWithFrame:CGRectMake(50, 20, DEVICE_WIDTH-100, 44)];
    [lblTitle setBackgroundColor:[UIColor clearColor]];
    [lblTitle setText:@"History"];
    [lblTitle setTextAlignment:NSTextAlignmentCenter];
    [lblTitle setFont:[UIFont fontWithName:CGRegular size:textSize]];
    [lblTitle setTextColor:[UIColor whiteColor]];
    [viewHeader addSubview:lblTitle];
    
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
    [blueSegmentedControl setFrame:CGRectMake(10,64, DEVICE_WIDTH-20, 40)];
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
        [blueSegmentedControl setFrame:CGRectMake(10,0+88, DEVICE_WIDTH-20, 48)];
        blueSegmentedControl.cornerRadius = 24;
        blueSegmentedControl.layer.cornerRadius = 24;
    }
    else
    {
        viewHeader.frame = CGRectMake(0, 0, DEVICE_WIDTH, yy);
    }
    
    histSeachbar = [[SSSearchBar alloc] initWithFrame:CGRectMake(10, yy, DEVICE_WIDTH-20, 50)];
    histSeachbar.delegate=self;
    histSeachbar.backgroundColor=[UIColor blackColor];
    histSeachbar.layer.borderColor=[UIColor blackColor].CGColor;
    histSeachbar.backgroundColor = [UIColor clearColor];
    [self.view addSubview:histSeachbar];

    UILabel * lblLine2 = [[UILabel alloc] initWithFrame:CGRectMake(10,histSeachbar.frame.size.height-9, histSeachbar.frame.size.width, 1)];
    [lblLine2 setBackgroundColor:[UIColor lightGrayColor]];
    [histSeachbar addSubview:lblLine2];
    
    tblContent = [[UITableView alloc] initWithFrame:CGRectMake(0,yy+50, DEVICE_WIDTH, DEVICE_HEIGHT-yy-50-45) style:UITableViewStylePlain];
    [tblContent setBackgroundColor:[UIColor clearColor]];
    [tblContent setShowsVerticalScrollIndicator:NO];
    tblContent.separatorStyle = UITableViewCellSeparatorStyleNone;
    tblContent.delegate = self;
    tblContent.dataSource = self;
    [self.view addSubview:tblContent];
    
    /*topPullToRefreshManager = [[MNMPullToRefreshManager alloc] initWithPullToRefreshViewHeight:60.0f tableView:tblContent withClient:self];
    [topPullToRefreshManager setPullToRefreshViewVisible:YES];
    bottomPullToRefreshManager = [[MNMBottomPullToRefreshManager alloc] initWithPullToRefreshViewHeight:60.0f tableView:tblContent withClient:self];
    [bottomPullToRefreshManager setPullToRefreshViewVisible:YES];
    [topPullToRefreshManager tableViewReloadFinishedAnimated:YES];
    [bottomPullToRefreshManager setPullToRefreshViewVisible:YES];
    [bottomPullToRefreshManager tableViewReloadFinished];*/
    
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
        NSString * str = [NSString stringWithFormat:@"Select * from tbl_install where is_sync = 1 and user_id = '%@' order by createdTimeStamp DESC",CURRENT_USER_ID];
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
-(void)segmentClick:(NYSegmentedControl *) sender
{
    
    [topPullToRefreshManager tableViewReloadFinishedAnimated:NO];
    [bottomPullToRefreshManager setPullToRefreshViewVisible:NO];

    [histSeachbar resignFirstResponder];
    isSearching = NO;
    histSeachbar.text = @"";
    if (sender.selectedSegmentIndex==0)
    {
        typeSelected = @"Install";
        [self getUpdatedData];
        [self getInstallationHistoryfromSuccorfish];
    }
    else if (sender.selectedSegmentIndex==1)
    {
        typeSelected = @"UnInstall";
        [self getUpdatedData];
        [self getUninstallsHistoryfromSuccorfish];
    }
    else if (sender.selectedSegmentIndex==2)
    {
        typeSelected = @"Inspection";
        [self getUpdatedData];
        [self getInspectionsHistoryfromSuccorfish];
    }
}

-(void)getUpdatedData
{
    if ([typeSelected isEqualToString:@"Install"])
    {
        if ([installArr count]==0)
        {
            NSString * str = [NSString stringWithFormat:@"Select * from tbl_install where is_sync = 1 and user_id = '%@'order by createdTimeStamp DESC",CURRENT_USER_ID];
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
        [tblContent reloadData];
    }
    else if ([typeSelected isEqualToString:@"UnInstall"])
    {
        if ([unInstallArr count]==0)
        {
            NSString * str = [NSString stringWithFormat:@"Select * from tbl_uninstall where is_sync = 1 and user_id = '%@' order by createdTimeStamp DESC",CURRENT_USER_ID];
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
            NSString * str = [NSString stringWithFormat:@"Select * from tbl_inspection where is_sync = 1 and user_id = '%@' order by createdTimeStamp DESC",CURRENT_USER_ID];
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
}
#pragma mark- UITableView Methods
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (isSearching)
    {
        return [arrSearchedResults count];
    }
    else
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
    
    NSMutableDictionary * tmpDict = [[NSMutableDictionary alloc] init];
    
    if (isSearching)
    {
        tmpDict = [arrSearchedResults objectAtIndex:indexPath.row];
        NSString * strFormateDate =  [[arrSearchedResults objectAtIndex:indexPath.row] valueForKey: [[NSUserDefaults standardUserDefaults] valueForKey:@"globalDate"]];

        if ([typeSelected isEqualToString:@"Install"])
        {
            cell.lblDate.text = [self checkforValidString:[APP_DELEGATE dateValueFromDate:[tmpDict valueForKey:@"date"] withGiveDatetoShow:strFormateDate]];
        }
        else if ([typeSelected isEqualToString:@"UnInstall"])
        {
            cell.lblDate.text = [self checkforValidString:[APP_DELEGATE dateValueFromDate:[tmpDict valueForKey:@"uninstall_date"] withGiveDatetoShow:strFormateDate]];
        }
        else if ([typeSelected isEqualToString:@"Inspection"])
        {
            cell.lblDate.text = [self checkforValidString:[APP_DELEGATE dateValueFromDate:[tmpDict valueForKey:@"inspection_date"] withGiveDatetoShow:strFormateDate]];
        }
    }
    else
    {
        if ([typeSelected isEqualToString:@"Install"])
        {
            tmpDict = [installArr objectAtIndex:indexPath.row];
            NSString * strFormateDate =  [[installArr objectAtIndex:indexPath.row] valueForKey: [[NSUserDefaults standardUserDefaults] valueForKey:@"globalDate"]];
            cell.lblDate.text = [self checkforValidString:[APP_DELEGATE dateValueFromDate:[tmpDict valueForKey:@"date"] withGiveDatetoShow:strFormateDate]];
        }
        else if ([typeSelected isEqualToString:@"UnInstall"])
        {
            tmpDict = [unInstallArr objectAtIndex:indexPath.row];
            NSString * strFormateDate =  [[unInstallArr objectAtIndex:indexPath.row] valueForKey: [[NSUserDefaults standardUserDefaults] valueForKey:@"globalDate"]];
            cell.lblDate.text = [self checkforValidString:[APP_DELEGATE dateValueFromDate:[tmpDict valueForKey:@"uninstall_date"] withGiveDatetoShow:strFormateDate]];
        }
        else if ([typeSelected isEqualToString:@"Inspection"])
        {
            tmpDict = [inspectionArr objectAtIndex:indexPath.row];
            NSString * strFormateDate =  [[inspectionArr objectAtIndex:indexPath.row] valueForKey: [[NSUserDefaults standardUserDefaults] valueForKey:@"globalDate"]];
            cell.lblDate.text = [self checkforValidString:[APP_DELEGATE dateValueFromDate:[tmpDict valueForKey:@"inspection_date"] withGiveDatetoShow:strFormateDate]];
        }
    }

    cell.lblEMI.text = [self checkforValidString:[tmpDict valueForKey:@"imei"]];
    cell.lblVessel.text = [self checkforValidString:[tmpDict valueForKey:@"vesselname"]];
    cell.lblRegi.text = [self checkforValidString:[tmpDict valueForKey:@"portno"]];
    cell.lblDeviceType.text = [self checkforValidString:[tmpDict valueForKey:@"device_type"]];

    
    return cell;
}
- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath;
{
    cell.backgroundColor = [UIColor clearColor];
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSMutableDictionary * tmpDict = [[NSMutableDictionary alloc] init];
    BOOL isfromSerch = NO;
    if (isSearching)
    {
        isfromSerch = YES;
        tmpDict = [arrSearchedResults objectAtIndex:indexPath.row];
    }
    else
    {
        isfromSerch = NO;
        if ([typeSelected isEqualToString:@"Install"])
        {
            tmpDict = [installArr objectAtIndex:indexPath.row];
        }
        else if ([typeSelected isEqualToString:@"UnInstall"])
        {
            tmpDict = [unInstallArr objectAtIndex:indexPath.row];
        }
        else if ([typeSelected isEqualToString:@"Inspection"])
        {
            tmpDict = [inspectionArr objectAtIndex:indexPath.row];
        }
    }

    HistoryDetailVC * instV = [[HistoryDetailVC alloc] init];
    instV.detailDict = tmpDict;
    instV.strType = typeSelected;
    instV.isFromSearch = isfromSerch;
    [self.navigationController pushViewController:instV animated:YES];
}
-(NSString *)getSelectedTypeDate:(NSIndexPath *)strDateIndex
{
    NSString * strReturnDate;
    if ([typeSelected isEqualToString:@"Install"])
    {
        
    }
    else if ([typeSelected isEqualToString:@"UnInstall"])
    {
        
    }
    else if ([typeSelected isEqualToString:@"Inspection"])
    {
        
    }

    
    return strReturnDate;
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

#pragma mark -  UISearchBar Delegates
#pragma mark - SSSearchBarDelegate

- (void)searchBarCancelButtonClicked:(SSSearchBar *)searchBar
{
    [histSeachbar resignFirstResponder];
    histSeachbar.text = @"";
    isSearching = NO;
    [tblContent reloadData];
}
- (void)searchBarSearchButtonClicked:(SSSearchBar *)searchBar
{
    [histSeachbar resignFirstResponder];
    [self filterContentForSearchText:searchBar.text];
}
- (void)searchBar:(SSSearchBar *)searchBar textDidChange:(NSString *)searchText
{
    isSearching = YES;
    [self filterContentForSearchText:searchText];
}

-(void)filterContentForSearchText:(NSString *)searchText
{
    // Remove all objects from the filtered search array
    [arrSearchedResults removeAllObjects];
    
    // Filter the array using NSPredicate
    NSPredicate *predicate ;
    NSArray *tempArray =[[NSArray alloc] init];
    if ([typeSelected isEqualToString:@"Install"])
    {
        predicate = [NSPredicate predicateWithFormat:@"vesselname CONTAINS[cd] %@",searchText];
        tempArray = [installArr filteredArrayUsingPredicate:predicate];
    }
    else if ([typeSelected isEqualToString:@"UnInstall"])
    {
        predicate = [NSPredicate predicateWithFormat:@"vesselname CONTAINS[cd] %@",searchText];
        tempArray = [unInstallArr filteredArrayUsingPredicate:predicate];
    }
    else if ([typeSelected isEqualToString:@"Inspection"])
    {
        predicate = [NSPredicate predicateWithFormat:@"vesselname CONTAINS[cd] %@",searchText];
        tempArray = [inspectionArr filteredArrayUsingPredicate:predicate];
    }
    
    if (arrSearchedResults)
    {
        arrSearchedResults = nil;
    }
    arrSearchedResults = [[NSMutableArray alloc] initWithArray:tempArray];
    
    if (searchText == nil || [searchText isEqualToString:@""])
    {
        isSearching = NO;
    }
    else
    {
        isSearching = YES;
    }
    [tblContent reloadData];
}

#pragma mark - ScrollView Delegate
- (void) scrollViewDidScroll:(UIScrollView *)scrollView
{
    [topPullToRefreshManager tableViewScrolled];
    
    [bottomPullToRefreshManager tableViewReleased];
}

-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    if (scrollView.contentOffset.y >=360.0f)
    {
        
    }
    else
        [topPullToRefreshManager tableViewReleased];
}

- (void)pullToRefreshTriggered:(MNMPullToRefreshManager *)manager
{
    [self performSelector:@selector(loadFromTop) withObject:nil afterDelay:0.0f];
}

-(void)loadFromTop
{
    if ([APP_DELEGATE isNetworkreachable])
    {
        if ([typeSelected isEqualToString:@"Install"])
        {
            [self GetInstallHistoryfroTop];
        }
        else if ([typeSelected isEqualToString:@"UnInstall"])
        {
            [self GetUnInstallHistoryforTop];
        }
        else if ([typeSelected isEqualToString:@"Inspection"])
        {
            [self GetInspectionHistoryforTop];
        }
        isFromBottom = NO;
        start = 0;
    }
    else
    {
        [topPullToRefreshManager tableViewReloadFinishedAnimated:NO];
    }
}

- (void)bottomPullToRefreshTriggered:(MNMBottomPullToRefreshManager *)manager
{
    NSLog(@"Bottom Pulling");
    [self performSelector:@selector(loadTable) withObject:nil afterDelay:1.0f];
}

- (void)loadTable
{
    if ([APP_DELEGATE isNetworkreachable])
    {
        if ([typeSelected isEqualToString:@"Install"])
        {
            [self GetInstallHistoryfroBottom];
        }
        else if ([typeSelected isEqualToString:@"UnInstall"])
        {
            [self GetUnInstallHistoryforBottom];
        }
        else if ([typeSelected isEqualToString:@"Inspection"])
        {
            [self GetInspectionHistoryforBottom];
        }
        
        isFromBottom = YES;
        start = start+10;
    }
    else
    {
        [bottomPullToRefreshManager setPullToRefreshViewVisible:NO];
    }

}
#pragma mark - Web Service Call for INSTALL History
-(void)GetInstallHistoryfroTop
{
    [APP_DELEGATE endHudProcess];
    if ([APP_DELEGATE isNetworkreachable])
    {
        [APP_DELEGATE startHudProcess:@"Getting information..."];
    }
    NSString * websrviceName=@"history";
    
    NSMutableDictionary * dict = [[NSMutableDictionary alloc]init];
    [dict setValue:CURRENT_USER_ID forKey:@"user_id"];
    [dict setValue:@"0" forKey:@"offset"];
    [dict setValue:@"" forKey:@"search"];
    [dict setValue:@"10" forKey:@"limit"];
    [dict setValue:@"up" forKey:@"direction"];
    
    NSInteger lastInstID = [[NSUserDefaults standardUserDefaults] integerForKey:@"lastUPInstallID"];
    [dict setValue:[NSString stringWithFormat:@"%ld",(long)lastInstID] forKey:@"max_id"];
    
    URLManager *manager = [[URLManager alloc] init];
    manager.commandName = @"historyTop";
    manager.delegate = self;
    if (isSearching)
    {
        [dict setValue:histSeachbar.text forKey:@"search"];
        manager.commandName = @"HistorySearch";
    }

    [manager postUrlCall:[NSString stringWithFormat:@"http://succorfish.in/mobile/installation/%@",websrviceName] withParameters:dict];
//    NSLog(@"dic==>%@",dict);
}
-(void)GetInstallHistoryfroBottom
{
    [APP_DELEGATE endHudProcess];
    if ([APP_DELEGATE isNetworkreachable])
    {
        [APP_DELEGATE startHudProcess:@"Getting information..."];
    }

    NSString * websrviceName=@"history";
    
    NSMutableDictionary * dict = [[NSMutableDictionary alloc]init];
    [dict setValue:CURRENT_USER_ID forKey:@"user_id"];
    [dict setValue:@"0" forKey:@"offset"];
    [dict setValue:@"" forKey:@"search"];
    [dict setValue:@"10" forKey:@"limit"];
    [dict setValue:@"down" forKey:@"direction"];

    NSInteger lastInstID = [[NSUserDefaults standardUserDefaults] integerForKey:@"lastBottomInstallID"];
    [dict setValue:[NSString stringWithFormat:@"%ld",(long)lastInstID] forKey:@"max_id"];

    URLManager *manager = [[URLManager alloc] init];
    manager.commandName = @"History";
    manager.delegate = self;
    [manager postUrlCall:[NSString stringWithFormat:@"http://succorfish.in/mobile/installation/%@",websrviceName] withParameters:dict];
//    NSLog(@"dic==>%@",dict);
}
-(void)getInstallationHistoryfromSuccorfish
{
    [APP_DELEGATE endHudProcess];
    if ([APP_DELEGATE isNetworkreachable])
    {
        [APP_DELEGATE startHudProcess:@"Getting information..."];
    }
        dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0ul);
        dispatch_async(queue, ^{
            {
                
                NSString * strUrl = [NSString stringWithFormat:@"https://ws.scstg.net/basic/v2/device-history/getInstalledFor/%@",CURRENT_USER_ID];
                
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
                    
                    if ([responseObject isKindOfClass:[NSArray class]])
                    {
                        NSMutableArray * tmpArrs = [[NSMutableArray alloc] init];
                        tmpArrs = [responseObject mutableCopy];
                        
                        strTotalInstallCounts = [NSString stringWithFormat:@"%ld",(unsigned long)[tmpArrs count]];
                        [[NSNotificationCenter defaultCenter] postNotificationName:@"UpdateInstallCount" object:nil];
                        
                        for (int i =0; i<[tmpArrs count]; i++)
                        {
                            [self saveInstallHistoryinDatabase:[tmpArrs objectAtIndex:i]];
                        }
                        installArr = [[NSMutableArray alloc] init];
                        unInstallArr = [[NSMutableArray alloc] init];
                        inspectionArr = [[NSMutableArray alloc] init];
                        [self getUpdatedData];
                    }
                    
                }
                                                   failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                                       if (error) {
                                                           [APP_DELEGATE endHudProcess];
                                                           
//                                                           NSLog(@"Servicer error = %@", error);
//                                                           [self ErrorMessagePopup];
                                                           
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
//     /v2/device-history/getInstalledFor/{userId}
}
#pragma mark - Web Service Call for UNINSTALL History
-(void)GetUnInstallHistoryforTop
{
    [APP_DELEGATE endHudProcess];
    if ([APP_DELEGATE isNetworkreachable])
    {
        [APP_DELEGATE startHudProcess:@"Getting information..."];
    }
    NSString * websrviceName=@"history";
    
    NSMutableDictionary * dict = [[NSMutableDictionary alloc]init];
    [dict setValue:CURRENT_USER_ID forKey:@"user_id"];
    [dict setValue:@"0" forKey:@"offset"];
    [dict setValue:@"" forKey:@"search"];
    [dict setValue:@"10" forKey:@"limit"];
    [dict setValue:@"up" forKey:@"direction"];
    
    NSInteger lastInstID = [[NSUserDefaults standardUserDefaults] integerForKey:@"lastUPUnInstallID"];
    [dict setValue:[NSString stringWithFormat:@"%ld",(long)lastInstID] forKey:@"max_id"];
    
    
    URLManager *manager = [[URLManager alloc] init];
    manager.commandName = @"historyTop";
    manager.delegate = self;
    if (isSearching)
    {
        [dict setValue:histSeachbar.text forKey:@"search"];
        manager.commandName = @"HistorySearch";
    }
    [manager postUrlCall:[NSString stringWithFormat:@"http://succorfish.in/mobile/uninstallation/%@",websrviceName] withParameters:dict];
//    NSLog(@"dic==>%@",dict);
}
-(void)GetUnInstallHistoryforBottom
{
    [APP_DELEGATE endHudProcess];
    if ([APP_DELEGATE isNetworkreachable])
    {
        [APP_DELEGATE startHudProcess:@"Getting information..."];
    }
    NSString * websrviceName=@"history";
    
    NSMutableDictionary * dict = [[NSMutableDictionary alloc]init];
    [dict setValue:CURRENT_USER_ID forKey:@"user_id"];
    [dict setValue:@"0" forKey:@"offset"];
    [dict setValue:@"" forKey:@"search"];
    [dict setValue:@"10" forKey:@"limit"];
    [dict setValue:@"down" forKey:@"direction"];
    
    NSInteger lastInstID = [[NSUserDefaults standardUserDefaults] integerForKey:@"lastBottomUnInstallID"];
    [dict setValue:[NSString stringWithFormat:@"%ld",(long)lastInstID] forKey:@"max_id"];
    
    URLManager *manager = [[URLManager alloc] init];
    manager.commandName = @"History";
    manager.delegate = self;
    
    [manager postUrlCall:[NSString stringWithFormat:@"http://succorfish.in/mobile/uninstallation/%@",websrviceName] withParameters:dict];
//    NSLog(@"dic==>%@",dict);
}
-(void)getUninstallsHistoryfromSuccorfish
{
    [APP_DELEGATE endHudProcess];
    if ([APP_DELEGATE isNetworkreachable])
    {
        [APP_DELEGATE startHudProcess:@"Getting information..."];
    }
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0ul);
    dispatch_async(queue, ^{
        {
            NSString * strUrl = [NSString stringWithFormat:@"https://ws.scstg.net/basic/v2/device-history/getUninstalledFor/%@",CURRENT_USER_ID];
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
//                NSLog(@"Success Response with Result=%@",responseObject);
                [APP_DELEGATE endHudProcess];
                
                if ([responseObject isKindOfClass:[NSArray class]])
                {
                    NSMutableArray * tmpArrs = [[NSMutableArray alloc] init];
                    tmpArrs = [responseObject mutableCopy];
                    for (int i =0; i<[tmpArrs count]; i++)
                    {
                        [self SaveUinInstallRecords:[tmpArrs objectAtIndex:i]];
                    }
                    installArr = [[NSMutableArray alloc] init];
                    unInstallArr = [[NSMutableArray alloc] init];
                    inspectionArr = [[NSMutableArray alloc] init];
                    [self getUpdatedData];
                }
                
            }
                                               failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                                   if (error) {
                                                       [APP_DELEGATE endHudProcess];
                                                       
//                                                       NSLog(@"Servicer error = %@", error);
//                                                       [self ErrorMessagePopup];
                                                       
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
    //     /v2/device-history/getInstalledFor/{userId}
}
#pragma mark - Web Service Call for INSPECTIONS History
-(void)GetInspectionHistoryforTop
{
    [APP_DELEGATE endHudProcess];
    if ([APP_DELEGATE isNetworkreachable])
    {
        [APP_DELEGATE startHudProcess:@"Getting information..."];
    }
    NSMutableDictionary * dict = [[NSMutableDictionary alloc]init];
    [dict setValue:CURRENT_USER_ID forKey:@"user_id"];
    [dict setValue:@"0" forKey:@"offset"];
    [dict setValue:@"" forKey:@"search"];
    [dict setValue:@"10" forKey:@"limit"];
    [dict setValue:@"up" forKey:@"direction"];
    
    NSInteger lastInstID = [[NSUserDefaults standardUserDefaults] integerForKey:@"lastUPInspection"];
    [dict setValue:[NSString stringWithFormat:@"%ld",(long)lastInstID] forKey:@"max_id"];
    
    URLManager *manager = [[URLManager alloc] init];
    manager.commandName = @"historyTop";
    manager.delegate = self;
    if (isSearching)
    {
        [dict setValue:histSeachbar.text forKey:@"search"];
        manager.commandName = @"HistorySearch";
    }
    [manager postUrlCall:[NSString stringWithFormat:@"http://succorfish.in/mobile/inspection/history"] withParameters:dict];
//    NSLog(@"dic==>%@",dict);
}
-(void)GetInspectionHistoryforBottom
{
    [APP_DELEGATE endHudProcess];
    if ([APP_DELEGATE isNetworkreachable])
    {
        [APP_DELEGATE startHudProcess:@"Getting information..."];
    }
    NSMutableDictionary * dict = [[NSMutableDictionary alloc]init];
    [dict setValue:CURRENT_USER_ID forKey:@"user_id"];
    [dict setValue:@"0" forKey:@"offset"];
    [dict setValue:@"" forKey:@"search"];
    [dict setValue:@"10" forKey:@"limit"];
    [dict setValue:@"down" forKey:@"direction"];
    
    NSInteger lastInstID = [[NSUserDefaults standardUserDefaults] integerForKey:@"lastBottomInspection"];
    [dict setValue:[NSString stringWithFormat:@"%ld",(long)lastInstID] forKey:@"max_id"];
    
    URLManager *manager = [[URLManager alloc] init];
    manager.commandName = @"History";
    manager.delegate = self;
    [manager postUrlCall:[NSString stringWithFormat:@"http://succorfish.in/mobile/inspection/history"] withParameters:dict];
//    NSLog(@"dic==>%@",dict);
}
-(void)getInspectionsHistoryfromSuccorfish
{
    [APP_DELEGATE endHudProcess];
    if ([APP_DELEGATE isNetworkreachable])
    {
        [APP_DELEGATE startHudProcess:@"Getting information..."];
    }
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0ul);
    dispatch_async(queue, ^{
        {
            NSString * strUrl = [NSString stringWithFormat:@"https://ws.scstg.net/basic/v2/device-history/getInspectedFor/%@",CURRENT_USER_ID];
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
//                NSLog(@"Success Response with Result=%@",responseObject);
                [APP_DELEGATE endHudProcess];
                
                if ([responseObject isKindOfClass:[NSArray class]])
                {
                    NSMutableArray * tmpArrs = [[NSMutableArray alloc] init];
                    tmpArrs = [responseObject mutableCopy];
                    for (int i =0; i<[tmpArrs count]; i++)
                    {
                        [self SaveInspectionRecords:[tmpArrs objectAtIndex:i]];
                    }
                    installArr = [[NSMutableArray alloc] init];
                    unInstallArr = [[NSMutableArray alloc] init];
                    inspectionArr = [[NSMutableArray alloc] init];
                    [self getUpdatedData];
                }
                
            }
                                               failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                                   if (error) {
                                                       [APP_DELEGATE endHudProcess];
                                                       
//                                                       NSLog(@"Servicer error = %@", error);
//                                                       [self ErrorMessagePopup];
                                                       
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
    //     /v2/device-history/getInstalledFor/{userId}
}

#pragma mark - UrlManager Delegate
- (void)onResult:(NSDictionary *)result
{
    [APP_DELEGATE endHudProcess];
//    NSLog(@"The result is...%@", result);
    if ([[result valueForKey:@"commandName"] isEqualToString:@"History"])
    {
        [APP_DELEGATE endHudProcess];
        
        if ([[[result valueForKey:@"result"] valueForKey:@"response"] isEqualToString:@"true"])
        {
            NSMutableArray * arrTemp = [[NSMutableArray alloc] init];
            arrTemp = [[result valueForKey:@"result"] valueForKey:@"data"];
            if ([arrTemp count]==0)
            {
                [topPullToRefreshManager tableViewReloadFinishedAnimated:NO];
                [bottomPullToRefreshManager setPullToRefreshViewVisible:NO];
            }
            else
            {
                for (int i = 0; i<[arrTemp count]; i++)
                {
                    if ([typeSelected isEqualToString:@"Install"])
                    {
                        [self saveInstallHistoryinDatabase:[arrTemp objectAtIndex:i]];
                    }
                    else if ([typeSelected isEqualToString:@"UnInstall"])
                    {
                        [self SaveUinInstallRecords:[arrTemp objectAtIndex:i]];
                    }
                    else if ([typeSelected isEqualToString:@"Inspection"])
                    {
                        [self SaveInspectionRecords:[arrTemp objectAtIndex:i]];
                    }
                }
                
                installArr = [[NSMutableArray alloc] init];
                unInstallArr = [[NSMutableArray alloc] init];
                inspectionArr = [[NSMutableArray alloc] init];

                [self getUpdatedData];
                
//                [bottomPullToRefreshManager setPullToRefreshViewVisible:YES];
//                [bottomPullToRefreshManager tableViewReloadFinished];
                
                [topPullToRefreshManager tableViewReloadFinishedAnimated:YES];
                [bottomPullToRefreshManager setPullToRefreshViewVisible:NO];
                
                [topPullToRefreshManager tableViewReloadFinishedAnimated:YES];
                [bottomPullToRefreshManager setPullToRefreshViewVisible:YES];
                [bottomPullToRefreshManager tableViewReloadFinished];
            }
//
//            [bottomPullToRefreshManager tableViewReloadFinished];
//            [topPullToRefreshManager tableViewReloadFinishedAnimated:YES];

        }
        else
        {
            if ([[[result valueForKey:@"result"] valueForKey:@"message"] isEqualToString:@"Invalid Token"])
            {
                [APP_DELEGATE showSessionExpirePopup];
            }
            [topPullToRefreshManager tableViewReloadFinishedAnimated:NO];
            [bottomPullToRefreshManager setPullToRefreshViewVisible:NO];
        }
    }
    else if ([[result valueForKey:@"commandName"] isEqualToString:@"historyTop"])
    {
        [APP_DELEGATE endHudProcess];
        
        if ([[[result valueForKey:@"result"] valueForKey:@"response"] isEqualToString:@"true"])
        {
            NSMutableArray * arrTemp = [[NSMutableArray alloc] init];
            arrTemp = [[result valueForKey:@"result"] valueForKey:@"data"];
            if ([arrTemp count]==0)
            {
                [topPullToRefreshManager tableViewReloadFinishedAnimated:NO];
                [bottomPullToRefreshManager setPullToRefreshViewVisible:NO];
            }
            else
            {
                for (int i = 0; i<[arrTemp count]; i++)
                {
                    if ([typeSelected isEqualToString:@"Install"])
                    {
                        [self saveInstallHistoryinDatabase:[arrTemp objectAtIndex:i]];
                    }
                    else if ([typeSelected isEqualToString:@"UnInstall"])
                    {
                        [self SaveUinInstallRecords:[arrTemp objectAtIndex:i]];
                    }
                    else if ([typeSelected isEqualToString:@"Inspection"])
                    {
                        [self SaveInspectionRecords:[arrTemp objectAtIndex:i]];
                    }
                }
                
                installArr = [[NSMutableArray alloc] init];
                unInstallArr = [[NSMutableArray alloc] init];
                inspectionArr = [[NSMutableArray alloc] init];
                
                [self getUpdatedData];
                
//                [topPullToRefreshManager tableViewReloadFinishedAnimated:YES];
//                [topPullToRefreshManager tableViewReloadFinishedAnimated:YES];
                
                [topPullToRefreshManager tableViewReloadFinishedAnimated:YES];
                [bottomPullToRefreshManager setPullToRefreshViewVisible:NO];
                
                [topPullToRefreshManager tableViewReloadFinishedAnimated:YES];
                [bottomPullToRefreshManager setPullToRefreshViewVisible:YES];
                [bottomPullToRefreshManager tableViewReloadFinished];

            }
        }
        else
        {
            if ([[[result valueForKey:@"result"] valueForKey:@"message"] isEqualToString:@"Invalid Token"])
            {
                [APP_DELEGATE showSessionExpirePopup];
            }
            [topPullToRefreshManager tableViewReloadFinishedAnimated:NO];
            [bottomPullToRefreshManager setPullToRefreshViewVisible:NO];
        }
    }
    else if ([[result valueForKey:@"commandName"] isEqualToString:@"HistorySearch"])
    {
        [APP_DELEGATE endHudProcess];
        
        if ([[[result valueForKey:@"result"] valueForKey:@"response"] isEqualToString:@"true"])
        {
            NSMutableArray * arrTemp = [[NSMutableArray alloc] init];
            arrTemp = [[result valueForKey:@"result"] valueForKey:@"data"];
            
            if ([arrTemp count]==0)
            {
                arrSearchedResults = [[NSMutableArray alloc] init];
                [tblContent reloadData];
            }
            else
            {
                arrSearchedResults = [arrTemp mutableCopy];
                [tblContent reloadData];
                for (int i = 0; i<[arrTemp count]; i++)
                {
                    if ([typeSelected isEqualToString:@"Install"])
                    {
                        [self saveInstallHistoryinDatabase:[arrTemp objectAtIndex:i]];
                    }
                    else if ([typeSelected isEqualToString:@"UnInstall"])
                    {
                        [self SaveUinInstallRecords:[arrTemp objectAtIndex:i]];
                    }
                    else if ([typeSelected isEqualToString:@"Inspection"])
                    {
                        [self SaveInspectionRecords:[arrTemp objectAtIndex:i]];
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
        }
    }
}
- (void)onError:(NSError *)error
{
    [APP_DELEGATE endHudProcess];
    
//    NSLog(@"The error is...%@", error);
    NSInteger ancode = [error code];
    
    NSMutableDictionary * errorDict = [error.userInfo mutableCopy];
//    NSLog(@"errorDict===%@",errorDict);
    
    if ([[errorDict valueForKey:@"NSLocalizedDescription"] isEqualToString:@"The request timed out."])
    {
//        [APP_DELEGATE ShowErrorPopUpWithErrorCode:customErrorCodeForMessage andMessage:@"Please try again later"];
    }
    else
    {
        if (ancode == -1001 || ancode == -1004 || ancode == -1005 || ancode == -1009)
        {
//            [APP_DELEGATE ShowErrorPopUpWithErrorCode:ancode andMessage:@""];
        }
        else
        {
//            [APP_DELEGATE ShowErrorPopUpWithErrorCode:customErrorCodeForMessage andMessage:@"Please try again later"];
        }
    }
    NSString * strLoginUrl = [NSString stringWithFormat:@"%@%@",WEB_SERVICE_URL,@"token.json"];
    if ([[errorDict valueForKey:@"NSErrorFailingURLStringKey"] isEqualToString:strLoginUrl])
    {
//        NSLog(@"NSErrorFailingURLStringKey===%@",[errorDict valueForKey:@"NSErrorFailingURLStringKey"]);
    }
}

#pragma mark - Save Install records to Database
-(void)saveInstallHistoryinDatabase:(NSMutableDictionary *)dictHistory
{
    NSString * strUserID = CURRENT_USER_ID;
    NSString * strIMEI = [self checkforValidString:[dictHistory valueForKey:@"deviceImei"]];
    NSString * strType = [self checkforValidString:[dictHistory valueForKey:@"deviceType"]];
    NSString * strLat = @"NA";
    NSString * strLong = @"NA";
    NSString * strCountryName = @"NA";
    NSString * strVesselServerID = [self checkforValidString:[dictHistory valueForKey:@"realAssetId"]];
    NSString * strVesselName = [self checkforValidString:[dictHistory valueForKey:@"realAssetName"]];
    NSString * strRegister = [self checkforValidString:[dictHistory valueForKey:@"realAssetRegNo"]];
    NSString * strWarranty = @"NA";
    NSString * strPower = [self checkforValidString:[dictHistory valueForKey:@"powerSource"]];
    NSString * strLocation = [self checkforValidString:[dictHistory valueForKey:@"installationPlace"]];
    NSString * strTimeStamp = [NSString stringWithFormat:@"%@",[dictHistory valueForKey:@"created"]];
    NSString * strCreated = [self checkforValidString:[self GetRealDatefromTimeStamp1:strTimeStamp]];
    NSString * strUpdated = [self checkforValidString:[self GetRealDatefromTimeStamp1:strTimeStamp]];
    NSString * strInstalDate = [self checkforValidString:[self GetRealDatefromTimeStamp1:strTimeStamp]];
    

    NSString * strName,* strEmail, * strMobile,* strAddress, * strCity, * strState, * strZip, * strOwnerSign, * strInstallerSign, * strServerID, * strPdfPath;
    NSMutableDictionary * dictContact = [dictHistory valueForKey:@"contactInfo"];
    if (dictContact == [NSNull null] || dictContact == nil)
    {
        strName = @"NA";
        strEmail = @"NA";
        strMobile = @"NA";
        strAddress = @"NA";
        strCity = @"NA";
        strState = @"NA";
        strZip = @"NA";
    }
    else
    {
         strName = [self checkforValidString:[dictContact valueForKey:@"name"]];
         strEmail = [self checkforValidString:[dictContact valueForKey:@"email"]];
         strMobile = [self checkforValidString:[dictContact valueForKey:@"telephone"]];
         strAddress = [self checkforValidString:[dictContact valueForKey:@"address"]];
         strCity = [self checkforValidString:[dictContact valueForKey:@"city"]];
         strState = [self checkforValidString:[dictContact valueForKey:@"state"]];
         strZip = [self checkforValidString:[dictContact valueForKey:@"zipCode"]];
    }
    
    strOwnerSign = @"NA";
    strInstallerSign = @"NA";
    strServerID = [self checkforValidString:[dictHistory valueForKey:@"id"]];
    strPdfPath = @"NA";
    NSString * strSuccorDeviceID = [self checkforValidString:[dictHistory valueForKey:@"deviceId"]];


    NSInteger lastInstID = [[NSUserDefaults standardUserDefaults] integerForKey:@"lastUPInstallID"];
    if (lastInstID == 0)
    {
        [[NSUserDefaults standardUserDefaults] setInteger:[strServerID integerValue] forKey:@"lastUPInstallID"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    else
    {
        if (lastInstID < [strServerID integerValue])
        {
            [[NSUserDefaults standardUserDefaults] setInteger:[strServerID integerValue] forKey:@"lastUPInstallID"];
            [[NSUserDefaults standardUserDefaults] synchronize];
        }
    }
 

    NSInteger lastBottomID = [[NSUserDefaults standardUserDefaults] integerForKey:@"lastBottomInstallID"];
    if (lastBottomID == 0)
    {
        [[NSUserDefaults standardUserDefaults] setInteger:[strServerID integerValue] forKey:@"lastBottomInstallID"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    else
    {
        if (lastBottomID > [strServerID integerValue])
        {
            [[NSUserDefaults standardUserDefaults] setInteger:[strServerID integerValue] forKey:@"lastBottomInstallID"];
            [[NSUserDefaults standardUserDefaults] synchronize];
        }
    }
    
    NSString * strStatus = @"COMPLETE";
    NSString * strSyncStatus = @"1";
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"YYYY-MM-dd HH:mm"];
//    [[NSUserDefaults standardUserDefaults] valueForKey:@"GloablDateFormat"]
    NSDate * dateInstalled = [dateFormatter dateFromString:strInstalDate];
    int timestamp = [dateInstalled timeIntervalSince1970];
    NSString * strcurTimeStamp = [NSString stringWithFormat:@"%d",timestamp];
    
    NSString * strDate1 = strInstalDate;
    NSString * strDate2 = [APP_DELEGATE getConvertedDate:strInstalDate withFormat:@"dd-MM-yyyy"];
    NSString * strDate3 = [APP_DELEGATE getConvertedDate:strInstalDate withFormat:@"dd/MM/yyyy"];
    NSString * strDate4 = [APP_DELEGATE getConvertedDate:strInstalDate withFormat:@"dd MMMM yyyy"];
    NSString * strDate5 = [APP_DELEGATE getConvertedDate:strInstalDate withFormat:@"MM/dd/yyyy"];
    NSString * strDate6 = [APP_DELEGATE getConvertedDate:strInstalDate withFormat:@"yyyy/MM/dd"];

    strPdfPath = @"NA";
    NSMutableDictionary * attachDict = [[dictHistory valueForKey:@"attachedFiles"] mutableCopy];
    if (attachDict != nil)
    {
        NSArray * valArr = [attachDict allValues];
        NSArray * keyArr = [attachDict allKeys];

        for (int i=0; i<[valArr count]; i++)
        {
            NSString * strChekStr = [NSString stringWithFormat:@"%@",[valArr objectAtIndex:i]];
            if ([strChekStr rangeOfString:@".pdf"].location != NSNotFound)
            {
                strPdfPath = [NSString stringWithFormat:@"%@",[keyArr objectAtIndex:i]];
                break;
            }
        }
    }
    
    NSString * selectStr  =[NSString stringWithFormat:@"select * from tbl_install where server_id = '%@' and user_id = '%@'",[dictHistory valueForKey:@"id"],CURRENT_USER_ID];
    NSMutableArray * tmpArr = [[NSMutableArray alloc] init];
    [[DataBaseManager dataBaseManager] execute:selectStr resultsArray:tmpArr];
    if ([tmpArr count]>0)
    {
        NSString * requestStr =[NSString stringWithFormat:@"Update 'tbl_install' set 'user_id' =\"%@\",'imei' =\"%@\",'device_type' =\"%@\",'created_at' =\"%@\",'createdTimeStamp' =\"%@\",'updated_at' =\"%@\",'date' =\"%@\",'latitude' =\"%@\",'longitude' =\"%@\",'installation_county' =\"%@\",'vessel_id' =\"%@\",'vesselname' =\"%@\",'portno' =\"%@\",'warranty' =\"%@\",'power' =\"%@\",'device_install_location' =\"%@\",'owner_name' =\"%@\",'owner_email' =\"%@\",'owner_phone_no' =\"%@\",'owner_address' =\"%@\",'owner_city' =\"%@\",'owner_state' =\"%@\",'owner_zipcode' =\"%@\",'server_owner_sign' =\"%@\",'complete_status' =\"%@\",'is_sync' =\"%@\",'pdf_url' =\"%@\",'server_installer_sign' =\"%@\",'succor_device_id'= \"%@\"  where server_id ==\"%@\" ",strUserID,strIMEI,strType,strCreated,strcurTimeStamp,strUpdated,strInstalDate,strLat,strLong,strCountryName,strVesselServerID,strVesselName,strRegister,strWarranty,strPower,strLocation,strName,strEmail,strMobile,strAddress,strCity,strState,strZip,strOwnerSign,strStatus,strSyncStatus,strPdfPath,strInstallerSign,strSuccorDeviceID,strServerID];
        [[DataBaseManager dataBaseManager] execute:requestStr];
        
        NSString *  strQuery =[NSString stringWithFormat:@"update 'tbl_install' set 'date1' = \"%@\",'date2' = \"%@\",'date3' = \"%@\",'date4' = \"%@\",'date5' = \"%@\",'date6' = \"%@\" where server_id ='%@'",strDate1,strDate2,strDate3,strDate4,strDate5,strDate6,strServerID];
        [[DataBaseManager dataBaseManager] execute:strQuery];

    }
    else
    {
        NSString * requestStr =[NSString stringWithFormat:@"insert into 'tbl_install'('user_id','imei','device_type','created_at','createdTimeStamp','updated_at','date','latitude','longitude','installation_county','vessel_id','vesselname','portno','warranty','power','device_install_location','owner_name','owner_email','owner_phone_no','owner_address','owner_city','owner_state','owner_zipcode','server_owner_sign','complete_status','is_sync','server_id','pdf_url','server_installer_sign','succor_device_id') values(\"%@\",\"%@\",\"%@\",\"%@\",\"%@\",\"%@\",\"%@\",\"%@\",\"%@\",\"%@\",\"%@\",\"%@\",\"%@\",\"%@\",\"%@\",\"%@\",\"%@\",\"%@\",\"%@\",\"%@\",\"%@\",\"%@\",\"%@\",\"%@\",\"%@\",\"%@\",\"%@\",\"%@\",\"%@\",\"%@\")",strUserID,strIMEI,strType,strCreated,strcurTimeStamp,strUpdated,strInstalDate,strLat,strLong,strCountryName,strVesselServerID,strVesselName,strRegister,strWarranty,strPower,strLocation,strName,strEmail,strMobile,strAddress,strCity,strState,strZip,strOwnerSign,strStatus,strSyncStatus,strServerID,strPdfPath,strInstallerSign,strSuccorDeviceID];
            int installID = [[DataBaseManager dataBaseManager] executeSw:requestStr];
        if (installID !=0)
        {
            NSString * strID = [NSString stringWithFormat:@"%d",installID];
            NSString * strQuery =[NSString stringWithFormat:@"update 'tbl_install' set 'date1' = \"%@\",'date2' = \"%@\",'date3' = \"%@\",'date4' = \"%@\",'date5' = \"%@\",'date6' = \"%@\" where id ='%@'",strDate1,strDate2,strDate3,strDate4,strDate5,strDate6,strID];
            [[DataBaseManager dataBaseManager] execute:strQuery];

        }
    }
}

#pragma mark - Save UNInstall records to Database
-(void)SaveUinInstallRecords:(NSMutableDictionary *)dictHistory
{
    NSString * strUserID = CURRENT_USER_ID;
    NSString * strIMEI = [self checkforValidString:[dictHistory valueForKey:@"deviceImei"]];
    NSString * strType = [self checkforValidString:[dictHistory valueForKey:@"deviceType"]];
    NSString * strVesselServerID = [self checkforValidString:[dictHistory valueForKey:@"realAssetId"]];
    NSString * strVesselName = [self checkforValidString:[dictHistory valueForKey:@"realAssetName"]];
    NSString * strRegister = [self checkforValidString:[dictHistory valueForKey:@"realAssetRegNo"]];
    NSString * strWarranty = @"NA";
    NSString * strTimeStamp = [NSString stringWithFormat:@"%@",[dictHistory valueForKey:@"created"]];
    NSString * strCreated = [self checkforValidString:[self GetRealDatefromTimeStamp1:strTimeStamp]];
    NSString * strUpdated = [self checkforValidString:[self GetRealDatefromTimeStamp1:strTimeStamp]];
    NSString * strInstalDate = [self checkforValidString:[self GetRealDatefromTimeStamp1:strTimeStamp]];

    NSString * strName,* strEmail, * strMobile,* strAddress, * strCity, * strState, * strZip, * strOwnerSign, * strInstallerSign, * strServerID, * strPdfPath;
    NSMutableDictionary * dictContact = [dictHistory valueForKey:@"contactInfo"];
    if (dictContact == [NSNull null] || dictContact == nil)
    {
        strName = @"NA";
        strEmail = @"NA";
        strMobile = @"NA";
        strAddress = @"NA";
        strCity = @"NA";
        strState = @"NA";
        strZip = @"NA";
    }
    else
    {
        strName = [self checkforValidString:[dictContact valueForKey:@"name"]];
        strEmail = [self checkforValidString:[dictContact valueForKey:@"email"]];
        strMobile = [self checkforValidString:[dictContact valueForKey:@"telephone"]];
        strAddress = [self checkforValidString:[dictContact valueForKey:@"address"]];
        strCity = [self checkforValidString:[dictContact valueForKey:@"city"]];
        strState = [self checkforValidString:[dictContact valueForKey:@"state"]];
        strZip = [self checkforValidString:[dictContact valueForKey:@"zipCode"]];
    }
    
    strOwnerSign = @"NA";
    strInstallerSign = @"NA";
    strServerID = [self checkforValidString:[dictHistory valueForKey:@"id"]];
    strPdfPath = @"id";
    NSString * strSuccorDeviceID = [self checkforValidString:[dictHistory valueForKey:@"deviceId"]];


    NSInteger lastInstID = [[NSUserDefaults standardUserDefaults] integerForKey:@"lastUPUnInstallID"];
    if (lastInstID == 0)
    {
        [[NSUserDefaults standardUserDefaults] setInteger:[strServerID integerValue] forKey:@"lastUPUnInstallID"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    else
    {
        if (lastInstID < [strServerID integerValue])
        {
            [[NSUserDefaults standardUserDefaults] setInteger:[strServerID integerValue] forKey:@"lastUPUnInstallID"];
            [[NSUserDefaults standardUserDefaults] synchronize];
        }
    }
    
    NSInteger lastBottomID = [[NSUserDefaults standardUserDefaults] integerForKey:@"lastBottomUnInstallID"];
    if (lastBottomID == 0)
    {
        [[NSUserDefaults standardUserDefaults] setInteger:[strServerID integerValue] forKey:@"lastBottomUnInstallID"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    else
    {
        if (lastBottomID > [strServerID integerValue])
        {
            [[NSUserDefaults standardUserDefaults] setInteger:[strServerID integerValue] forKey:@"lastBottomUnInstallID"];
            [[NSUserDefaults standardUserDefaults] synchronize];
        }
    }
    NSString * strStatus = @"COMPLETE";
    NSString * strSyncStatus = @"1";
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"YYYY-MM-dd HH:mm"];
    NSDate * dateInstalled = [dateFormatter dateFromString:strInstalDate];
    int timestamp = [dateInstalled timeIntervalSince1970];
    NSString * strcurTimeStamp = [NSString stringWithFormat:@"%d",timestamp];
    
    NSString * strDate1 = strInstalDate;
    NSString * strDate2 = [APP_DELEGATE getConvertedDate:strInstalDate withFormat:@"dd-MM-yyyy"];
    NSString * strDate3 = [APP_DELEGATE getConvertedDate:strInstalDate withFormat:@"dd/MM/yyyy"];
    NSString * strDate4 = [APP_DELEGATE getConvertedDate:strInstalDate withFormat:@"dd MMMM yyyy"];
    NSString * strDate5 = [APP_DELEGATE getConvertedDate:strInstalDate withFormat:@"MM/dd/yyyy"];
    NSString * strDate6 = [APP_DELEGATE getConvertedDate:strInstalDate withFormat:@"yyyy/MM/dd"];

    strPdfPath = @"NA";
    NSMutableDictionary * attachDict = [[dictHistory valueForKey:@"attachedFiles"] mutableCopy];
    if (attachDict != nil)
    {
        NSArray * valArr = [attachDict allValues];
        NSArray * keyArr = [attachDict allKeys];
        
        for (int i=0; i<[valArr count]; i++)
        {
            NSString * strChekStr = [NSString stringWithFormat:@"%@",[valArr objectAtIndex:i]];
            if ([strChekStr rangeOfString:@".pdf"].location != NSNotFound)
            {
                strPdfPath = [NSString stringWithFormat:@"%@",[keyArr objectAtIndex:i]];
                break;
            }
        }
    }
    
    NSString * selectStr  =[NSString stringWithFormat:@"select * from tbl_uninstall where server_id = '%@' and user_id = '%@'",[dictHistory valueForKey:@"id"],CURRENT_USER_ID];
    NSMutableArray * tmpArr = [[NSMutableArray alloc] init];
    [[DataBaseManager dataBaseManager] execute:selectStr resultsArray:tmpArr];
    if ([tmpArr count]>0)
    {
        NSString * requestStr =[NSString stringWithFormat:@"Update 'tbl_uninstall' set 'user_id' =\"%@\",'imei' =\"%@\",'device_type' =\"%@\",'created_at' =\"%@\",'createdTimeStamp' =\"%@\",'updated_at' =\"%@\",'vessel_id' =\"%@\",'vesselname' =\"%@\",'portno' =\"%@\",'warranty' =\"%@\",'owner_name' =\"%@\",'owner_email' =\"%@\",'owner_phone_no' =\"%@\",'owner_address' =\"%@\",'owner_city' =\"%@\",'owner_state' =\"%@\",'owner_zipcode' =\"%@\",'server_owner_sign' =\"%@\",'complete_status' =\"%@\",'is_sync' =\"%@\",'pdf_url'=\"%@\",'uninstall_date'=\"%@\",'server_installer_sign'=\"%@\",'succor_device_id'=\"%@\" where server_id ==\"%@\" ",strUserID,strIMEI,strType,strCreated,strcurTimeStamp,strUpdated,strVesselServerID,strVesselName,strRegister,strWarranty,strName,strEmail,strMobile,strAddress,strCity,strState,strZip,strOwnerSign,strStatus,strSyncStatus,strPdfPath,strInstalDate,strInstallerSign,strSuccorDeviceID,strServerID];
        [[DataBaseManager dataBaseManager] execute:requestStr];
        
        NSString * strQuery =[NSString stringWithFormat:@"update 'tbl_uninstall' set 'date1' = \"%@\",'date2' = \"%@\",'date3' = \"%@\",'date4' = \"%@\",'date5' = \"%@\",'date6' = \"%@\" where server_id ='%@'",strDate1,strDate2,strDate3,strDate4,strDate5,strDate6,strServerID];
        [[DataBaseManager dataBaseManager] execute:strQuery];

    }
    else
    {
        NSString * requestStr =[NSString stringWithFormat:@"insert into 'tbl_uninstall'('user_id','imei','device_type','created_at','createdTimeStamp','updated_at','vessel_id','vesselname','portno','warranty','owner_name','owner_email','owner_phone_no','owner_address','owner_city','owner_state','owner_zipcode','server_owner_sign','complete_status','is_sync','server_id','pdf_url','uninstall_date','server_installer_sign','succor_device_id') values(\"%@\",\"%@\",\"%@\",\"%@\",\"%@\",\"%@\",\"%@\",\"%@\",\"%@\",\"%@\",\"%@\",\"%@\",\"%@\",\"%@\",\"%@\",\"%@\",\"%@\",\"%@\",\"%@\",\"%@\",\"%@\",\"%@\",\"%@\",\"%@\",\"%@\")",strUserID,strIMEI,strType,strCreated,strcurTimeStamp,strUpdated,strVesselServerID,strVesselName,strRegister,strWarranty,strName,strEmail,strMobile,strAddress,strCity,strState,strZip,strOwnerSign,strStatus,strSyncStatus,strServerID,strPdfPath,strInstalDate,strInstallerSign,strSuccorDeviceID];
         int localId = [[DataBaseManager dataBaseManager] executeSw:requestStr];
        if (localId != 0)
        {
            NSString * strId = [NSString stringWithFormat:@"%d",localId];
            NSString * strQuery =[NSString stringWithFormat:@"update 'tbl_uninstall' set 'date1' = \"%@\",'date2' = \"%@\",'date3' = \"%@\",'date4' = \"%@\",'date5' = \"%@\",'date6' = \"%@\" where id ='%@'",strDate1,strDate2,strDate3,strDate4,strDate5,strDate6,strId];
            [[DataBaseManager dataBaseManager] execute:strQuery];
        }
    }
}

#pragma mark - Save Inspections records to Database
-(void)SaveInspectionRecords:(NSMutableDictionary *)dictHistory
{
    NSString * strUserID = CURRENT_USER_ID;
    NSString * strIMEI = [self checkforValidString:[dictHistory valueForKey:@"deviceImei"]];
    NSString * strType = [self checkforValidString:[dictHistory valueForKey:@"deviceType"]];
    NSString * strVesselServerID = [self checkforValidString:[dictHistory valueForKey:@"realAssetId"]];
    NSString * strVesselName = [self checkforValidString:[dictHistory valueForKey:@"realAssetName"]];
    NSString * strRegister = [self checkforValidString:[dictHistory valueForKey:@"realAssetRegNo"]];
    NSString * strWarranty = @"NA";
    NSString * strResult = [self checkforValidString:[dictHistory valueForKey:@"notes"]];
    NSString * strAction = [self checkforValidString:[dictHistory valueForKey:@"operation"]];
    NSString * strTimeStamp = [NSString stringWithFormat:@"%@",[dictHistory valueForKey:@"created"]];
    NSString * strCreated = [self checkforValidString:[self GetRealDatefromTimeStamp1:strTimeStamp]];
    NSString * strUpdated = [self checkforValidString:[self GetRealDatefromTimeStamp1:strTimeStamp]];
    NSString * strInspectDate = [self checkforValidString:[self GetRealDatefromTimeStamp1:strTimeStamp]];

    NSString * strName,* strEmail, * strMobile,* strAddress, * strCity, * strState, * strZip, * strOwnerSign, * strInstallerSign, * strServerID, * strPdfPath;
    NSMutableDictionary * dictContact = [dictHistory valueForKey:@"contactInfo"];
    if (dictContact == [NSNull null] || dictContact == nil)
    {
        strName = @"NA";
        strEmail = @"NA";
        strMobile = @"NA";
        strAddress = @"NA";
        strCity = @"NA";
        strState = @"NA";
        strZip = @"NA";
    }
    else
    {
        strName = [self checkforValidString:[dictContact valueForKey:@"name"]];
        strEmail = [self checkforValidString:[dictContact valueForKey:@"email"]];
        strMobile = [self checkforValidString:[dictContact valueForKey:@"telephone"]];
        strAddress = [self checkforValidString:[dictContact valueForKey:@"address"]];
        strCity = [self checkforValidString:[dictContact valueForKey:@"city"]];
        strState = [self checkforValidString:[dictContact valueForKey:@"state"]];
        strZip = [self checkforValidString:[dictContact valueForKey:@"zipCode"]];
    }
    
    strOwnerSign = @"NA";
    strInstallerSign = @"NA";
    strServerID = [self checkforValidString:[dictHistory valueForKey:@"id"]];
    strPdfPath = @"id";
    NSString * strSuccorDeviceID = [self checkforValidString:[dictHistory valueForKey:@"deviceId"]];
    NSInteger lastInstID = [[NSUserDefaults standardUserDefaults] integerForKey:@"lastUPInspection"];
    if (lastInstID == 0)
    {
        [[NSUserDefaults standardUserDefaults] setInteger:[strServerID integerValue] forKey:@"lastUPInspection"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    else
    {
        if (lastInstID < [strServerID integerValue])
        {
            [[NSUserDefaults standardUserDefaults] setInteger:[strServerID integerValue] forKey:@"lastUPInspection"];
            [[NSUserDefaults standardUserDefaults] synchronize];
        }
    }
    
    
    NSInteger lastBottomID = [[NSUserDefaults standardUserDefaults] integerForKey:@"lastBottomInspection"];
    if (lastBottomID == 0)
    {
        [[NSUserDefaults standardUserDefaults] setInteger:[strServerID integerValue] forKey:@"lastBottomInspection"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    else
    {
        if (lastBottomID > [strServerID integerValue])
        {
            [[NSUserDefaults standardUserDefaults] setInteger:[strServerID integerValue] forKey:@"lastBottomInspection"];
            [[NSUserDefaults standardUserDefaults] synchronize];
        }
    }
    
    NSString * strStatus = @"COMPLETE";
    NSString * strSyncStatus = @"1";
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"YYYY-MM-dd HH:mm"];
    NSDate * dateInstalled = [dateFormatter dateFromString:strInspectDate];
    int timestamp = [dateInstalled timeIntervalSince1970];
    NSString * strcurTimeStamp = [NSString stringWithFormat:@"%d",timestamp];
    
    NSString * strDate1 = strInspectDate;
    NSString * strDate2 = [APP_DELEGATE getConvertedDate:strInspectDate withFormat:@"dd-MM-yyyy"];
    NSString * strDate3 = [APP_DELEGATE getConvertedDate:strInspectDate withFormat:@"dd/MM/yyyy"];
    NSString * strDate4 = [APP_DELEGATE getConvertedDate:strInspectDate withFormat:@"dd MMMM yyyy"];
    NSString * strDate5 = [APP_DELEGATE getConvertedDate:strInspectDate withFormat:@"MM/dd/yyyy"];
    NSString * strDate6 = [APP_DELEGATE getConvertedDate:strInspectDate withFormat:@"yyyy/MM/dd"];

    strPdfPath = @"NA";
    NSMutableDictionary * attachDict = [[dictHistory valueForKey:@"attachedFiles"] mutableCopy];
    if (attachDict != nil)
    {
        NSArray * valArr = [attachDict allValues];
        NSArray * keyArr = [attachDict allKeys];
        
        for (int i=0; i<[valArr count]; i++)
        {
            NSString * strChekStr = [NSString stringWithFormat:@"%@",[valArr objectAtIndex:i]];
            if ([strChekStr rangeOfString:@".pdf"].location != NSNotFound)
            {
                strPdfPath = [NSString stringWithFormat:@"%@",[keyArr objectAtIndex:i]];
                break;
            }
        }
    }
    
    NSString * selectStr  =[NSString stringWithFormat:@"select * from tbl_inspection where server_id = '%@' and user_id = '%@'",[dictHistory valueForKey:@"id"],CURRENT_USER_ID];
    NSMutableArray * tmpArr = [[NSMutableArray alloc] init];
    [[DataBaseManager dataBaseManager] execute:selectStr resultsArray:tmpArr];
    if ([tmpArr count]>0)
    {
        NSString * requestStr =[NSString stringWithFormat:@"Update 'tbl_inspection' set 'user_id' =\"%@\",'imei' =\"%@\",'device_type' =\"%@\",'created_at' =\"%@\",'createdTimeStamp' =\"%@\",'updated_at' =\"%@\",'vessel_id' =\"%@\",'vesselname' =\"%@\",'portno' =\"%@\",'warranty' =\"%@\",'owner_name' =\"%@\",'owner_email' =\"%@\",'owner_phone_no' =\"%@\",'owner_address' =\"%@\",'owner_city' =\"%@\",'owner_state' =\"%@\",'owner_zipcode' =\"%@\",'complete_status' =\"%@\",'is_sync' =\"%@\",'insp_result' =\"%@\",'insp_action_taken' =\"%@\", 'created_at' = \"%@\",'pdf_url' = \"%@\", 'inspection_date'= \"%@\", 'server_installer_sign'= \"%@\", 'succor_device_id' = \"%@\" where server_id ==\"%@\" ",strUserID,strIMEI,strType,strCreated,strcurTimeStamp,strUpdated,strVesselServerID,strVesselName,strRegister,strWarranty,strName,strEmail,strMobile,strAddress,strCity,strState,strZip,strStatus,strSyncStatus,strResult,strAction,strInspectDate,strPdfPath,strInspectDate,strInstallerSign,strSuccorDeviceID,strServerID];
        [[DataBaseManager dataBaseManager] execute:requestStr];
        
        NSString * strQuery =[NSString stringWithFormat:@"update 'tbl_inspection' set 'date1' = \"%@\",'date2' = \"%@\",'date3' = \"%@\",'date4' = \"%@\",'date5' = \"%@\",'date6' = \"%@\" where server_id ='%@'",strDate1,strDate2,strDate3,strDate4,strDate5,strDate6,strServerID];
        [[DataBaseManager dataBaseManager] execute:strQuery];

    }
    else
    {
        NSString * requestStr =[NSString stringWithFormat:@"insert into 'tbl_inspection'('user_id','imei','device_type','created_at','createdTimeStamp','updated_at','vessel_id','vesselname','portno','warranty','owner_name','owner_email','owner_phone_no','owner_address','owner_city','owner_state','owner_zipcode','complete_status','is_sync','server_id','insp_result','insp_action_taken','created_at','pdf_url','inspection_date','server_installer_sign','succor_device_id') values(\"%@\",\"%@\",\"%@\",\"%@\",\"%@\",\"%@\",\"%@\",\"%@\",\"%@\",\"%@\",\"%@\",\"%@\",\"%@\",\"%@\",\"%@\",\"%@\",\"%@\",\"%@\",\"%@\",\"%@\",\"%@\",\"%@\",\"%@\",\"%@\",\"%@\",\"%@\",\"%@\")",strUserID,strIMEI,strType,strCreated,strcurTimeStamp,strUpdated,strVesselServerID,strVesselName,strRegister,strWarranty,strName,strEmail,strMobile,strAddress,strCity,strState,strZip,strStatus,strSyncStatus,strServerID,strResult,strAction,strInspectDate,strPdfPath,strInspectDate,strInstallerSign,strSuccorDeviceID];
         int localId = [[DataBaseManager dataBaseManager] executeSw:requestStr];
        
        if (localId != 0)
        {
            NSString * strId = [NSString stringWithFormat:@"%d",localId];
            NSString * strQuery =[NSString stringWithFormat:@"update 'tbl_inspection' set 'date1' = \"%@\",'date2' = \"%@\",'date3' = \"%@\",'date4' = \"%@\",'date5' = \"%@\",'date6' = \"%@\" where id ='%@'",strDate1,strDate2,strDate3,strDate4,strDate5,strDate6,strId];
            [[DataBaseManager dataBaseManager] execute:strQuery];
        }
    }
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
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(void)ErrorMessagePopup
{
    [APP_DELEGATE endHudProcess];
    
    URBAlertView *alertView = [[URBAlertView alloc] initWithTitle:ALERT_TITLE message:@"Something went wrong. Please try again." cancelButtonTitle:OK_BTN otherButtonTitles: nil, nil];
    
    [alertView setMessageFont:[UIFont fontWithName:CGRegular size:14]];
    [alertView setHandlerBlock:^(NSInteger buttonIndex, URBAlertView *alertView) {
        [alertView hideWithCompletionBlock:^{
        }];
    }];
    [alertView showWithAnimation:URBAlertAnimationTopToBottom];
    if (IS_IPHONE_X){[alertView showWithAnimation:URBAlertAnimationDefault];}
}

-(NSString *)GetRealDatefromTimeStamp1:(NSString *)strTimeStamp
{
    NSString *mainStr = strTimeStamp;
    NSString * newString = [mainStr substringToIndex:[mainStr length]-3];
    
    double unixTimeStamp = [newString doubleValue];
    NSTimeInterval _interval=unixTimeStamp;
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:_interval];
    NSDateFormatter *_formatter=[[NSDateFormatter alloc]init];
    //    NSTimeZone *gmt = [NSTimeZone timeZoneWithAbbreviation:@"UTC"];
    NSTimeZone *gmt = [NSTimeZone localTimeZone];
    
    [_formatter setTimeZone:gmt];
    [_formatter setDateFormat:[NSString stringWithFormat:@"YYYY-MM-dd HH:mm"]];
    NSString *strDates=[_formatter stringFromDate:date];
    
    return strDates;
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
