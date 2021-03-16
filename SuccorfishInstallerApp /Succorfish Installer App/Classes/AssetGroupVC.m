//
//  BeconGroupVC.m
//  Succorfish Installer App
//
//  Created by Ashwin on 7/17/20.
//  Copyright © 2020 Kalpesh Panchasara. All rights reserved.
//

#import "AssetGroupVC.h"
#import "InstallBeaconCell.h"
#import "InstallBeconVC.h"
#import "SSSearchBar.h"

@interface BeconGroupVC ()<UITableViewDelegate,UITableViewDataSource,SSSearchBarDelegate>
{
    int textSize;
    UITableView * tblBeconGroup;
    NSMutableArray * arrVslData ,*arrSearchedResults,*arrAssetGrop;

    SSSearchBar * serachBarBeacon;
    BOOL  isSearching, isAssetGroup;
    UIButton * btnSave;
    
    NSIndexPath * StrSelect;
    NSMutableDictionary * selectedDict;
    
}
@end

@implementation BeconGroupVC
@synthesize isFromeEdit,detailDict,installID;


- (void)viewDidLoad
{
    self.navigationController.navigationBarHidden = true;
    selectedDict = [[NSMutableDictionary alloc] init];
    
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
    lblHeadere.text = @"Asset/Asset Group";
    lblHeadere.textColor = UIColor.whiteColor;
    lblHeadere.font = [UIFont fontWithName:CGRegular size:textSize];
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
    
    btnSave = [[UIButton alloc] initWithFrame:CGRectMake(DEVICE_WIDTH-60, 15, 50, 44)];
    btnSave.backgroundColor = UIColor.clearColor;
    [btnSave setTitle:@"Save" forState:UIControlStateNormal];
    [btnSave setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
    [btnSave addTarget:self action:@selector(btnSaveClick) forControlEvents:UIControlEventTouchUpInside];
    btnSave.titleLabel.font = [UIFont fontWithName:CGRegular size:textSize];
    [navigView addSubview:btnSave];
    
    int yy = 64;
    
    btnAsset = [[UIButton alloc] initWithFrame:CGRectMake(10, yy, DEVICE_WIDTH/2, 44)];
    btnAsset.backgroundColor = UIColor.clearColor;
    [btnAsset setTitle:@"Asset" forState:UIControlStateNormal];
    [btnAsset setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
    [btnAsset addTarget:self action:@selector(btnAssetclick) forControlEvents:UIControlEventTouchUpInside];
    [btnAsset setImage:[UIImage imageNamed:@"radiobuttonSelected.png"] forState:UIControlStateNormal];
    btnAsset.contentHorizontalAlignment = UISemanticContentAttributeForceRightToLeft;
    [self.view addSubview:btnAsset];
    
    btnAssetGrop = [[UIButton alloc] initWithFrame:CGRectMake(DEVICE_WIDTH/2+5, yy, DEVICE_WIDTH/2-5, 44)];
    btnAssetGrop.backgroundColor = UIColor.clearColor;
    [btnAssetGrop setTitle:@"Asset Group" forState:UIControlStateNormal];
    [btnAssetGrop setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
    [btnAssetGrop addTarget:self action:@selector(btnAssetcGrouplick) forControlEvents:UIControlEventTouchUpInside];
    [btnAssetGrop setImage:[UIImage imageNamed:@"radioUnselectedWhite.png"] forState:UIControlStateNormal];
    btnAssetGrop.contentHorizontalAlignment = UISemanticContentAttributeForceRightToLeft;
    [self.view addSubview:btnAssetGrop];
    
    yy=yy+40;
    serachBarBeacon = [[SSSearchBar alloc] initWithFrame:CGRectMake(0, yy, DEVICE_WIDTH, 50)];
    serachBarBeacon.delegate=self;
    serachBarBeacon.backgroundColor = [UIColor blackColor];
    self->serachBarBeacon.placeholder =@"Search Asset";
    [self.view addSubview:serachBarBeacon];

    yy = yy +  50;
    tblBeconGroup = [[UITableView alloc]initWithFrame:CGRectMake(0, yy, DEVICE_WIDTH, DEVICE_HEIGHT-yy)];
    tblBeconGroup.backgroundColor = UIColor.clearColor;
    tblBeconGroup.delegate = self;
    tblBeconGroup.dataSource = self;
    tblBeconGroup.scrollEnabled = YES;
    tblBeconGroup.separatorStyle = UITableViewCellSelectionStyleNone;
    [self.view addSubview:tblBeconGroup];
    
    UILabel * lblLine2 = [[UILabel alloc] initWithFrame:CGRectMake(5,serachBarBeacon.frame.size.height-5, serachBarBeacon.frame.size.width-10, 1)];
    [lblLine2 setBackgroundColor:[UIColor lightGrayColor]];
    [serachBarBeacon addSubview:lblLine2];
    
    NSString * strQuery = [NSString stringWithFormat:@"Select * from tbl_vessel_asset"];
    arrVslData = [[NSMutableArray alloc] init];
    [[DataBaseManager dataBaseManager] execute:strQuery resultsArray:arrVslData];
    [arrVslData setValue:@"0" forKey:@"isSelected"];
    
    NSString * strQuery1 = [NSString stringWithFormat:@"Select * from tbl_Asset_Group"];
    arrAssetGrop = [[NSMutableArray alloc] init];
    [[DataBaseManager dataBaseManager] execute:strQuery1 resultsArray:arrAssetGrop];
    [arrAssetGrop setValue:@"0" forKey:@"isSelected"];

    if (isFromeEdit)
    {
        if (detailDict.count >0)
        {
            if ([[arrVslData valueForKey:@"vessel_succorfish_id"] containsObject:[detailDict valueForKey:@"vessel_succorfish_id"]])
            {
                NSInteger foundIndex = [[arrVslData valueForKey:@"vessel_succorfish_id"] indexOfObject:[detailDict valueForKey:@"vessel_succorfish_id"]];
                if (foundIndex != NSNotFound)
                {
                    if ([arrVslData count] > foundIndex)
                    {
                        [[arrVslData objectAtIndex:foundIndex] setValue:@"1" forKey:@"isSelected"];
                    }
                }
            }
            else if ([[arrAssetGrop valueForKey:@"group_id"] containsObject:[detailDict valueForKey:@"group_id"]])
            {
                NSInteger foundIndex = [[arrAssetGrop valueForKey:@"group_id"] indexOfObject:[detailDict valueForKey:@"group_id"]];
                if (foundIndex != NSNotFound)
                {
                    if ([arrAssetGrop count] > foundIndex)
                    {
                        [[arrAssetGrop objectAtIndex:foundIndex] setValue:@"1" forKey:@"isSelected"];
                    }
                }
            }
        }
    }
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

#pragma mark - UITableView Delegates
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 50;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(isAssetGroup == false)
    {
        if (isSearching)
        {
            return [arrSearchedResults count];
        }
        else
        {
            return arrVslData.count;
        }
    }
    else
    {
        if (isSearching)
        {
            return [arrSearchedResults count];
        }
        else
        {
            return arrAssetGrop.count;
        }
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
    cell.lblCellBgColor.hidden = false;
    cell.lblAsset.hidden = false;
    cell.lblAsset.font =[UIFont fontWithName:CGRegular size:textSize+2];
    NSMutableDictionary * tmpDict = [[NSMutableDictionary alloc] init];
    if(isAssetGroup == false)
    {
        if (isSearching)
        {
            tmpDict = [arrSearchedResults objectAtIndex:indexPath.row];
        }
        else
        {
            tmpDict = [arrVslData objectAtIndex:indexPath.row];
        }
        cell.lblAsset.text = [tmpDict valueForKey:@"vessel_name"];
    }
    else
    {
        if (isSearching)
        {
            tmpDict = [arrSearchedResults objectAtIndex:indexPath.row];
        }
        else
        {
            tmpDict = [arrAssetGrop objectAtIndex:indexPath.row];
        }
        cell.lblAsset.text = [[arrAssetGrop objectAtIndex:indexPath.row] valueForKey:@"name"];
    }

    if([[tmpDict valueForKey:@"isSelected"] isEqualToString:@"1"])
    {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
        cell.tintColor = UIColor.whiteColor;
    }
   else
   {
        cell.accessoryType = UITableViewCellAccessoryNone;
   }


    cell.backgroundColor = [UIColor colorWithRed:33.0/255 green:33.0/255 blue:33.0/255 alpha:0.6];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSMutableDictionary * tmpDict = [[NSMutableDictionary alloc] init];
    if (isSearching)
    {
        [arrSearchedResults setValue:@"0" forKey:@"isSelected"];

        tmpDict = [arrSearchedResults objectAtIndex:indexPath.row];
        [tmpDict setValue:@"1" forKey:@"isSelected"];
        [arrSearchedResults replaceObjectAtIndex:indexPath.row withObject:tmpDict];
        [self UpdateMainArrayIndexfromSearchIndex:indexPath.row withDataDict:tmpDict];
        selectedDict = [tmpDict mutableCopy];
    }
    else
    {
        if(isAssetGroup == false)
        {
            [arrVslData setValue:@"0" forKey:@"isSelected"];
            tmpDict = [arrVslData objectAtIndex:indexPath.row];
            [tmpDict setValue:@"1" forKey:@"isSelected"];
            StrSelect = [[arrVslData objectAtIndex:indexPath.row] valueForKey:@"vessel_name"];
            NSLog(@"selected indexPath====>%@",StrSelect);
            selectedDict = [tmpDict mutableCopy];
        }
        else
        {
            [arrAssetGrop setValue:@"0" forKey:@"isSelected"];
            tmpDict = [arrAssetGrop objectAtIndex:indexPath.row];
            [tmpDict setValue:@"1" forKey:@"isSelected"];
            StrSelect = [[arrAssetGrop objectAtIndex:indexPath.row] valueForKey:@"name"];
            selectedDict = [tmpDict mutableCopy];
            NSLog(@"selected indexPath====>%@",StrSelect);
        }
    }
    
    [tblBeconGroup reloadData];
}
//- (NSUInteger)currentSellectedRowIndex
//{
//    NSIndexPath *selectedIndexPath = [tblBeconGroup indexPathForSelectedRow];
//    if (selectedIndexPath)
//    {
//        return selectedIndexPath.row;
//    }
//    else
//    {
//        return NSNotFound;
//    }
//}
-(void)UpdateMainArrayIndexfromSearchIndex:(NSInteger )strindex withDataDict:(NSMutableDictionary *)dict
{
    NSString * strVal = [[arrSearchedResults objectAtIndex:strindex] valueForKey:@"group_id"];
    if(isAssetGroup == false)
    {
        strVal = [[[arrSearchedResults valueForKey:@"vessel_succorfish_id"] objectAtIndex:strindex] valueForKey:@"vessel_succorfish_id"];
        NSInteger foundIndex = [arrVslData indexOfObject:strVal];
        if (foundIndex != NSNotFound)
        {
            if ([arrVslData count]>foundIndex)
            {
                [arrVslData replaceObjectAtIndex:foundIndex withObject:dict];
            }
        }
    }
    else
    {
        NSInteger foundIndex = [[arrSearchedResults valueForKey:@"group_id"] indexOfObject:strVal];
        if (foundIndex != NSNotFound)
        {
            if ([arrAssetGrop count]>foundIndex)
            {
                [arrAssetGrop replaceObjectAtIndex:foundIndex withObject:dict];
            }
        }
    }
}
#pragma mark - SSSearchBarDelegate
- (void)searchBarCancelButtonClicked:(SSSearchBar *)searchBar
{
    [serachBarBeacon resignFirstResponder];
    serachBarBeacon.text = @"";
    isSearching = NO;
    [tblBeconGroup reloadData];
}
- (void)searchBarSearchButtonClicked:(SSSearchBar *)searchBar
{
    [serachBarBeacon resignFirstResponder];
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
    [tblBeconGroup reloadData];
}
#pragma mark-BUtton
-(void)btnBackClick
{
    [self.navigationController popViewControllerAnimated:true];
}
-(void)btnSaveClick
{
    bool isSelectedAny = false;
    if ([[arrVslData valueForKey:@"isSelected"] containsObject:@"1"])
    {
        isSelectedAny = true;
    }
    else if ([[arrAssetGrop valueForKey:@"isSelected"] containsObject:@"1"])
    {
        isSelectedAny = true;
    }
    if (selectedDict.count == 0)
    {
        isSelectedAny = false;
    }
    if (isSelectedAny == true)
    {
        [globalbeaconVC GetAssetSelected:selectedDict isAssetGroup:isAssetGroup];
        [self.navigationController popViewControllerAnimated:YES];
    }
    else
    {
        URBAlertView * alert =[[URBAlertView alloc] initWithTitle:ALERT_TITLE message:@"Please select any one asset." cancelButtonTitle:OK_BTN otherButtonTitles:nil, nil];
        [alert showWithAnimation:URBAlertAnimationTopToBottom];
    }
}
-(void)btnAssetclick
{
    isAssetGroup = false;
    isSearching = false;
    [arrSearchedResults removeAllObjects];
     [serachBarBeacon resignFirstResponder];
    [arrAssetGrop setValue:@"0" forKey:@"isSelected"];
    [arrVslData setValue:@"0" forKey:@"isSelected"];

    [btnAsset setImage:[UIImage imageNamed:@"radiobuttonSelected.png"] forState:UIControlStateNormal];
        [btnAssetGrop setImage:[UIImage imageNamed:@"radioUnselectedWhite.png"] forState:UIControlStateNormal];
    self->serachBarBeacon.placeholder = @"Search Asset";
    [tblBeconGroup reloadData];
    
}
-(void)btnAssetcGrouplick
{
    isAssetGroup = true;
    isSearching = false;
    [arrSearchedResults removeAllObjects];
    [serachBarBeacon resignFirstResponder];
    [arrAssetGrop setValue:@"0" forKey:@"isSelected"];
    [arrVslData setValue:@"0" forKey:@"isSelected"];

    [btnAssetGrop setImage:[UIImage imageNamed:@"radiobuttonSelected.png"] forState:UIControlStateNormal];
        [btnAsset setImage:[UIImage imageNamed:@"radioUnselectedWhite.png"] forState:UIControlStateNormal];
    self->serachBarBeacon.placeholder = @"Search Asset Group";
    [tblBeconGroup reloadData];
}
@end
