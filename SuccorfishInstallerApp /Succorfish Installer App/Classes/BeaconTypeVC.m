//
//  BeaconTypeVC.m
//  Succorfish Installer App
//
//  Created by Ashwin on 7/17/20.
//  Copyright © 2020 Kalpesh Panchasara. All rights reserved.
//

#import "BeaconTypeVC.h"
#import "InstallBeaconCell.h"
#import "SSSearchBar.h"

@interface BeaconTypeVC ()<UITableViewDelegate,UITableViewDataSource,SSSearchBarDelegate>
{
    SSSearchBar * beconTypesearch;
    NSMutableArray * arrVslData , *arrCellSelected,*arrSearchedResults;
    UIButton * btnSave;
    
    BOOL  isSearching;
}
@end

@implementation BeaconTypeVC

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
    
    UILabel * lblHeadere = [[UILabel alloc] initWithFrame:CGRectMake(0, 10, DEVICE_WIDTH, 54)];
    lblHeadere.text = @"Beacon Type";
    lblHeadere.textColor = UIColor.whiteColor;
    lblHeadere.font = [UIFont fontWithName:CGRegular size:textSize+5];
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
    
    btnSave = [[UIButton alloc] initWithFrame:CGRectMake(DEVICE_WIDTH-60, 20, 50, 44)];
    btnSave.backgroundColor = UIColor.clearColor;
    [btnSave setTitle:@"Save" forState:UIControlStateNormal];
    [btnSave setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
    [btnSave addTarget:self action:@selector(btnSaveClick) forControlEvents:UIControlEventTouchUpInside];
    [navigView addSubview:btnSave];
    
    beconTypesearch = [[SSSearchBar alloc] initWithFrame:CGRectMake(5, 64, DEVICE_WIDTH-10, 50)];
    beconTypesearch.delegate=self;
    beconTypesearch.backgroundColor=[UIColor blackColor];
    beconTypesearch.layer.borderColor=[UIColor blackColor].CGColor;
    beconTypesearch.backgroundColor = [UIColor clearColor];
    self->beconTypesearch.placeholder =@"Search Beacon Type";
    [self.view addSubview:beconTypesearch];
    
    UILabel * lblLine2 = [[UILabel alloc] initWithFrame:CGRectMake(10,beconTypesearch.frame.size.height-10, beconTypesearch.frame.size.width-20, 1)];
    [lblLine2 setBackgroundColor:[UIColor lightGrayColor]];
    [beconTypesearch addSubview:lblLine2];
    
    tblBeconType = [[UITableView alloc]initWithFrame:CGRectMake(0, 110, DEVICE_WIDTH, DEVICE_HEIGHT-64)];
    tblBeconType.backgroundColor = UIColor.clearColor;
    tblBeconType.delegate = self;
    tblBeconType.dataSource = self;
    tblBeconType.scrollEnabled = YES;
    tblBeconType.separatorStyle = UITableViewCellSelectionStyleNone;
    [self.view addSubview:tblBeconType];
    
      


    NSString * strQuery = [NSString stringWithFormat:@"Select * from tbl_vessel_asset"];
    arrVslData = [[NSMutableArray alloc] init];
    [[DataBaseManager dataBaseManager] execute:strQuery resultsArray:arrVslData];
    arrCellSelected = [NSMutableArray array];
    arrSearchedResults = [NSMutableArray array];
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}
#pragma mark-buttons
-(void)btnBackClick
{
    [self.navigationController popViewControllerAnimated:TRUE];
}
-(void)btnSaveClick
{
    if (arrCellSelected.count > 0)
    {
        NSLog(@"%lu",(unsigned long)arrCellSelected.count);
        
        [self.navigationController popViewControllerAnimated:true];
    }
    else
    {
        URBAlertView * alert =[[URBAlertView alloc] initWithTitle:ALERT_TITLE message:@"Please select to save." cancelButtonTitle:OK_BTN otherButtonTitles:nil, nil];
                [alert showWithAnimation:URBAlertAnimationTopToBottom];
    }
}
#pragma mark - UITableView Delegates
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 50;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (isSearching)
    {
        return [arrSearchedResults count];
    }
    else
    {
        return arrVslData.count;
    }
    return 0;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellReuseIdentifier = @"cellIdentifier";
    InstallBeaconCell *cell = [tableView dequeueReusableCellWithIdentifier:cellReuseIdentifier];
    if (cell == nil)
    {
        cell = [[InstallBeaconCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellReuseIdentifier];
    }
    NSMutableDictionary * tmpDict = [[NSMutableDictionary alloc] init];
    if (isSearching)
    {
        tmpDict = [arrSearchedResults objectAtIndex:indexPath.row];
    }
    else
    {
        tmpDict = [arrVslData objectAtIndex:indexPath.row];
    }
    cell.lblBeaconType.hidden = false;
    cell.lblBeaconType.text = [tmpDict valueForKey:@"vessel_name"];

    if ([arrCellSelected containsObject:indexPath])
    {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
        cell.tintColor = UIColor.whiteColor;
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    }
    else
    {
      cell.accessoryType = UITableViewCellAccessoryNone;
    }
    
    cell.backgroundColor = UIColor.clearColor;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
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
        tmpDict = [arrVslData objectAtIndex:indexPath.row];
         [tableView reloadData];
    }
    
    if ([arrCellSelected containsObject:indexPath])
        {
            [arrCellSelected removeObject:indexPath];
        }
        else
        {
            [arrCellSelected addObject:indexPath];
        }
}
#pragma mark - SSSearchBarDelegate
- (void)searchBarCancelButtonClicked:(SSSearchBar *)searchBar
{
    [beconTypesearch resignFirstResponder];
    beconTypesearch.text = @"";
    isSearching = NO;
    [tblBeconType reloadData];
}
- (void)searchBarSearchButtonClicked:(SSSearchBar *)searchBar
{
    [beconTypesearch resignFirstResponder];
    [self filterContentForSearchText:searchBar.text];
}
- (void)searchBar:(SSSearchBar *)searchBar textDidChange:(NSString *)searchText
{
    isSearching = YES;
    
    [self filterContentForSearchText:searchText];

}
-(void)filterContentForSearchText:(NSString *)searchText
{
    [arrSearchedResults removeAllObjects];
    
    NSPredicate *predicate ;
    NSArray *tempArray =[[NSArray alloc] init];
    
    predicate = [NSPredicate predicateWithFormat:@"vessel_name CONTAINS[cd] %@",searchText];
    tempArray = [arrVslData filteredArrayUsingPredicate:predicate];
    
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
    [tblBeconType reloadData];
}
@end
