//
//  InstallBeconVC.m
//  Succorfish Installer App
//
//  Created by Ashwin on 7/16/20.
//  Copyright © 2020 Kalpesh Panchasara. All rights reserved.
//

#import "InstallBeconVC.h"
#import "InstallBeaconCell.h"
#import "BarcodeScanVC.h"
#import "BeaconTypeVC.h"
#import "BeaconBarcodeScnVC.h"
#import "AssetGroupVC.h"

@interface InstallBeconVC ()<UITableViewDelegate,UITableViewDataSource,UITextFieldDelegate,UIPickerViewDelegate,UIPickerViewDataSource,URLManagerDelegate>
{
    int textSize;
    NSMutableArray *arrTable ,*arrayPickrBatry;
    NSString *selectedFromPicker,*strTxtName;
    UIPickerView * pickerBattery;
    BOOL isGroupSelected;
    NSMutableDictionary * dictSelected,*dictScanNum,*dictEnterdData;
}
@end

@implementation InstallBeconVC
@synthesize DataDict,strBLeID;
- (void)viewDidLoad
{
    self.navigationController.navigationBarHidden = true;
    dictSelected = [[NSMutableDictionary alloc] init];
    
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
    lblHeadere.text = @"Install Beacon";
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
    
    tblBeacon = [[UITableView alloc]initWithFrame:CGRectMake(0, 64, DEVICE_WIDTH, 250)];
    tblBeacon.backgroundColor = UIColor.clearColor;
    tblBeacon.delegate = self;
    tblBeacon.dataSource = self;
    tblBeacon.scrollEnabled = false;
    tblBeacon.separatorStyle = UITableViewCellSelectionStyleNone;
    [self.view addSubview:tblBeacon];
    
    UIButton *btnFinish = [[UIButton alloc] initWithFrame:CGRectMake(0, DEVICE_HEIGHT-50, DEVICE_WIDTH, 50)];
    [btnFinish setTitle:@"Finish" forState:normal];
    [btnFinish setTitleColor:UIColor.whiteColor forState:normal];
    btnFinish.backgroundColor = UIColor.blackColor;
    [btnFinish addTarget:self action:@selector(btnFinishClick) forControlEvents:UIControlEventTouchUpInside];
//    btnFinish.alpha = 0.6;
    [self.view addSubview:btnFinish];
     
//    NSLog(@"data from becon Class%@",DataDict);

    arrayPickrBatry =[[NSMutableArray alloc]initWithObjects:@"CR123A",@"DOUBLE_CR123A",@"OTHER", nil];
    

    [super viewDidLoad];
    // Do any additional setup after loading the view.
}
-(void)viewWillAppear:(BOOL)animated
{
    [APP_DELEGATE hideTabBar:self.tabBarController];
    [tblBeacon reloadData];
    [super viewWillAppear:YES];
}
#pragma mark - UITableView Delegates
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 45;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 5;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellReuseIdentifier = @"cellIdentifier";
    InstallBeaconCell *cell = [tableView dequeueReusableCellWithIdentifier:cellReuseIdentifier];
    if (cell == nil)
    {
        cell = [[InstallBeaconCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellReuseIdentifier];
    }
    cell.lblLine.hidden = false;
    if (indexPath.row == 0)
    {
        cell.lblScanDevice.hidden = NO;
        cell.lblScanTxt.hidden = false;
        cell.lblScanTxt.text = strBLeID;
    }
    else if (indexPath.row == 1)
    {
        cell.txtName.hidden = NO;
        [DataDict setValue:cell.txtName.text forKey:@"name"];
    }
    else if (indexPath.row == 2)
    {
        cell.lblBeaconType.hidden = NO;
        cell.lblBecTypeName.hidden = false;
        cell.lblBecTypeName.text = @"AIB";
    }
    else if (indexPath.row == 3)
    {
        cell.lblBeacon.hidden = NO;
        cell.lblBatteryType.hidden = false;
        cell.lblBatteryType.text = selectedFromPicker;
        cell.imgArrow.hidden = false;
    }
    else if (indexPath.row == 4)
    {
        cell.lblGroupAsset.hidden = false;
        cell.imgArrow.hidden = false;
        cell.lblAssestGroup.hidden = false;
        if (dictSelected.count > 0)
        {
            if (isGroupSelected == false)
            {
                cell.lblAssestGroup.text = [NSString stringWithFormat:@"%@",[dictSelected valueForKey:@"vessel_name"]];
            }
            else
            {
                cell.lblAssestGroup.text = [NSString stringWithFormat:@"%@",[dictSelected valueForKey:@"name"]];
            }
            [DataDict setValue:cell.lblAssestGroup.text forKey:@"assetGroup"];
        }
    }
    cell.txtName.tag = 100;
    cell.txtName.delegate = self;

    cell.backgroundColor = UIColor.clearColor;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{

    [self ShowPicker:NO andView:viewBGPicker];
    [self.view endEditing:YES];

        if (indexPath.row == 0)
        {
//            BeaconBarcodeScnVC * sCanVC = [[BeaconBarcodeScnVC alloc] init];
//         sCanVC.isFromInstall = @"Becon NewInstall";
//            [self.navigationController pushViewController:sCanVC animated:true];
        }
        else if (indexPath.row == 1)
        {
        
        }
        else if (indexPath.row == 3)
        {
            [self setupForBeconBAtteryType];
            [self.view endEditing:YES];
        }
        else if (indexPath.row == 4)
        {
        BeconGroupVC * bGroup = [[BeconGroupVC alloc] init];
        if (dictSelected.count > 0)
        {
            bGroup.isFromeEdit = YES;
            bGroup.detailDict = dictSelected;
        }
        [self.navigationController pushViewController:bGroup animated:TRUE];
    }
}
-(void)btnBackClick
{
    [self.navigationController popViewControllerAnimated:true];
}
#pragma mark - Textfield Delegates
-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (textField.tag == 100)
    {
        [textField resignFirstResponder];
    }
    return textField;
}
-(void)textFieldDidBeginEditing:(UITextField *)textField
{
    if (textField.tag == 100)
    {
        [self ShowPicker:NO andView:viewBGPicker];
        strTxtName = textField.text;
    }
}
-(void)textFieldDidEndEditing:(UITextField *)textField
{
    if (textField.tag == 100)
    {
     strTxtName = textField.text;
     textField.textColor = UIColor.lightGrayColor;
    }
}
-(void)setupForBeconBAtteryType
{
    [viewBGPicker removeFromSuperview];
    
    viewBGPicker = [[UIView alloc] initWithFrame:CGRectMake(0, DEVICE_HEIGHT, DEVICE_WIDTH, 250)];
    [viewBGPicker setBackgroundColor:[UIColor whiteColor]];
    [self.view addSubview:viewBGPicker];
    
    [pickerBattery removeFromSuperview];
    pickerBattery = nil;
    pickerBattery.delegate=nil;
    pickerBattery.dataSource=nil;
    pickerBattery = [[UIPickerView alloc] initWithFrame:CGRectMake(0, 34, DEVICE_WIDTH, 216)];
    [pickerBattery setBackgroundColor:[UIColor blackColor]];
    pickerBattery.tag=123;
    [pickerBattery setDelegate:self];
    [pickerBattery setDataSource:self];
//    NSInteger indexSelctTemp = [[NSUserDefaults standardUserDefaults] integerForKey:@"selectIndexBattery"];
//    [pickerBattery selectRow:indexSelctTemp inComponent:0 animated:YES];

    [viewBGPicker addSubview:pickerBattery];
    
    UILabel * lblLine = [[UILabel alloc] initWithFrame:CGRectMake(0, 45, viewListBattry.frame.size.width, 1)];
    lblLine.backgroundColor = UIColor.lightGrayColor;
    [viewListBattry addSubview:lblLine];
    
    
    UIButton * btnDone = [UIButton buttonWithType:UIButtonTypeCustom];
    [btnDone setFrame:CGRectMake(0 , 0, DEVICE_WIDTH, 44)];
    [btnDone setBackgroundImage:[UIImage imageNamed:@"BTN.png"] forState:UIControlStateNormal];
    [btnDone setTitle:@"Done" forState:UIControlStateNormal];
    [btnDone setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    btnDone.titleLabel.font = [UIFont fontWithName:CGRegular size:textSize];
    [btnDone setTag:123];
    [btnDone addTarget:self action:@selector(btnDoneClicked:) forControlEvents:UIControlEventTouchUpInside];
    [viewBGPicker addSubview:btnDone];
    
  [self ShowPicker:YES andView:viewBGPicker];
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

//MARK: piker view
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView;
{
    return 1;
}
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return arrayPickrBatry.count;
}
- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
     return [arrayPickrBatry objectAtIndex:row];
}
- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view
{
    UILabel* pickerLabel = (UILabel*)view;

    if (!pickerLabel)
    {
        pickerLabel = [[UILabel alloc] init];
        pickerLabel.textAlignment=NSTextAlignmentCenter;
        pickerLabel.font = [UIFont fontWithName:CGRegular size:textSize];
        pickerLabel.textColor = UIColor.whiteColor;
        
    }
    [pickerLabel setText:[arrayPickrBatry objectAtIndex:row]];

    return pickerLabel;
}
- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    selectedFromPicker = [arrayPickrBatry objectAtIndex:row];
}
-(void)btnDoneClicked:(id)sender
{
    if ([[APP_DELEGATE checkforValidString:selectedFromPicker] isEqualToString:@"NA"])
    {
        NSInteger index = [pickerBattery selectedRowInComponent:0];
        
        if (index == -1)
        {
            selectedFromPicker = [NSString stringWithFormat:@"%ld",(long)index];
        }
        else
        {
            selectedFromPicker = [arrayPickrBatry objectAtIndex:0];
        }
    }
    [self ShowPicker:NO andView:viewBGPicker];
    [tblBeacon reloadData];
}
#pragma mark- Finish Button
-(void)btnFinishClick
{
   if ([[self checkforValidString:strTxtName] isEqualToString:@"NA"])
    {
        [self ErrorPOPupMsg:@"Please enter \"Name\""];
    }
    else if ([[self checkforValidString:selectedFromPicker] isEqualToString:@"NA"])
    {
        [self ErrorPOPupMsg:@"Please select the \"Battery type\""];
    }
    else if ([[self checkforValidString:[dictSelected valueForKey:@"isSelected"]] isEqual:@"NA"])
    {
        [self ErrorPOPupMsg:@"Please select the \"Asset/Asset Group\"."];
    }
    else
    {
        [self InstallAPICall:@"Install"];
    }
}
-(void)GetAssetSelected:(NSMutableDictionary *)dataDict isAssetGroup:(BOOL)isAssetGroup
{
    dictSelected = dataDict;
    isGroupSelected = isAssetGroup;
    [tblBeacon reloadData];
}
-(void)InsertintoTheTblBecaon
{
    NSDateFormatter *DateFormatter=[[NSDateFormatter alloc] init];
    [DateFormatter setDateFormat:@"dd-MM-yyyy hh:mm:ss"];
    [DateFormatter setTimeZone:[NSTimeZone timeZoneWithName:@"UTC+5:30"]];
    NSString * currentDateAndTime = [NSString stringWithFormat:@"%@",[DateFormatter stringFromDate:[NSDate date]]];

    NSString * strBeaconType = [APP_DELEGATE checkforValidString:@"AIB"];
    NSString * strName = [APP_DELEGATE checkforValidString:[DataDict valueForKey:@"name"]];
    NSString * strBAtteryType = [APP_DELEGATE checkforValidString:selectedFromPicker];
    NSString * strDate = [APP_DELEGATE checkforValidString:[NSString stringWithFormat:@"%@",currentDateAndTime]];
    NSString * strCreatedAt = [APP_DELEGATE checkforValidString:[NSString stringWithFormat:@"%@",currentDateAndTime]];
    NSString * strCompleatState = [APP_DELEGATE checkforValidString:[[DataDict valueForKey:@"result"] valueForKey:@"status"]];
    NSString * strAssGroup = [APP_DELEGATE checkforValidString:[DataDict valueForKey:@"assetGroup"]];
//    NSString * strisActive = [APP_DELEGATE checkforValidString:[[DataDict valueForKey:@"result"] valueForKey:@"id"]];

    NSString* strNA = @"NA";
    NSString * requestStr =[NSString stringWithFormat:@"insert into 'tbl_Beacon_install'('server_id','user_id','beacon_number','asset_id','asset_group_id','beacon_type','name','battery_type','date','latitude','longitude','is_sync','pdf_url','created_at','compleate_status','is_active') values(\"%@\",\"%@\",\"%@\",\"%@\",\"%@\",\"%@\",\"%@\",\"%@\",\"%@\",\"%@\",\"%@\",\"%@\",\"%@\",\"%@\",\"%@\",\"%@\")",strNA,strNA,strNA,strNA,strAssGroup,strBeaconType,strName,strBAtteryType,strDate,strNA,strNA,strNA,strNA,strCreatedAt,strCompleatState,strNA];
        [[DataBaseManager dataBaseManager] executeSw:requestStr];
}
#pragma mark -  API Call
-(void)InstallAPICall:(NSString *)CmdName
{
    if ([APP_DELEGATE isNetworkreachable])
    {
        [APP_DELEGATE endHudProcess];
        [APP_DELEGATE startHudProcess:@"Installing Beacon device...."];
        
        if ([CmdName isEqual:@"Install"])
        {
            [self BeaconInstallatonAPI];
        }
        else
        {
            [self CheckInstallationDevice];
        }
   }
    else
    {
        [self ErrorPOPupMsg:@"Please check the internet conetion."];
    }
}
#pragma mark - UrlManager Delegate
- (void)onResult:(NSDictionary *)result
{
    NSLog(@"Resulrt=====%@",result);
    NSDictionary * dictData = [[NSDictionary alloc] init];
    
    if ([[result valueForKey:@"commandName"] isEqual:@"INSTALL"])
    {
        dictData = [result valueForKey:@"result"];
        if ([dictData isKindOfClass:[NSDictionary class]])
        {
            NSArray * arrKeys = [dictData allKeys];
            if([arrKeys containsObject:@"errors"])
            {
                    [self ErrorPOPupMsg:[NSString stringWithFormat:@"%@", [[result valueForKey:@"result"] valueForKey:@"status"]]];
            }
            else
            {
                
                URBAlertView * alert =[[URBAlertView alloc] initWithTitle:ALERT_TITLE message:@"Beacon device \"INSTALLED\" successfully." cancelButtonTitle:OK_BTN otherButtonTitles:nil, nil];
                       [alert setHandlerBlock:^(NSInteger buttonIndex, URBAlertView *alertView) {
                           [alertView hideWithCompletionBlock:^
                           {
                               [self.navigationController popViewControllerAnimated:true];
                           }];
                       }];
                [alert showWithAnimation:URBAlertAnimationTopToBottom];
            }
        }
        else if ([dictData isKindOfClass:[NSArray class]])
        {
            NSArray * arr = [dictData mutableCopy];
            if ([arr count]>0)
            {
                NSString * str = [[arr objectAtIndex:0] valueForKey:@"errorCode"];
                str = [str stringByReplacingOccurrencesOfString:@"." withString:@" "];
                [self ErrorPOPupMsg:str];
            }
        }
    }
    [APP_DELEGATE endHudProcess];
    NSLog(@"The INSTALLED result is...%@", result);
}
- (void)onError:(NSError *)error
{
    [APP_DELEGATE endHudProcess];
    NSLog(@"The error is...%@", error);
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
-(void)ErrorPOPupMsg:(NSString *)strErrorMsg
{
     URBAlertView * alert =[[URBAlertView alloc] initWithTitle:ALERT_TITLE message:strErrorMsg  cancelButtonTitle:OK_BTN otherButtonTitles:nil, nil];
    [alert showWithAnimation:URBAlertAnimationTopToBottom];
    if (IS_IPHONE_X){[alert showWithAnimation:URBAlertAnimationDefault];}

}
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [self ShowPicker:NO andView:viewBGPicker];
    [self.view endEditing:YES];
}
-(void)BeaconInstallatonAPI
{
    NSString * strUrl = [NSString stringWithFormat:@"https://ws.scstg.net/basic/v2/beacon/install"];// histroy URL have to passs
               NSMutableDictionary *args = [[NSMutableDictionary alloc] init];
              [args setValue:[self checkforValidString:strTxtName] forKey:@"name"];
              [args setValue:[self checkforValidString:selectedFromPicker] forKey:@"battery"];
              [args setValue:@"AIB" forKey:@"type"];
              [args setValue:strBLeID forKey:@"id"];
               
               if (isGroupSelected == YES)
               {
                   [args setValue:[self checkforValidString:[dictSelected valueForKey:@"group_id"]] forKey:@"assetGroupId"];
               }
               else
               {
                   [args setValue:[self checkforValidString:[dictSelected valueForKey:@"vessel_succorfish_id"]] forKey:@"assetId"];
               }
                NSLog(@"%@",args);
               URLManager *manager = [[URLManager alloc] init];
               manager.commandName = @"INSTALL";
               manager.delegate = self;
               [manager postUrlCall:strUrl withParameters:args];
}
-(void)CheckInstallationDevice
{
    [APP_DELEGATE endHudProcess];
    [APP_DELEGATE startHudProcess:@"Getting details..."];

    NSString * strUrl = [NSString stringWithFormat:@"https://ws.scstg.net/basic/v2/beacon/getLatest/%@",strBLeID];// histroy URL have to passs
    URLManager *manager = [[URLManager alloc] init];
    manager.commandName = @"GetBeaconInstallationDetail";
    manager.delegate = self;
    [manager getUrlCall:strUrl withParameters:nil];
}
@end
