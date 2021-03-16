//
//  SettingsVC.m
//  Succorfish Installer App
//
//  Created by stuart watts on 21/02/2018.
//  Copyright © 2018 Kalpesh Panchasara. All rights reserved.
//

#import "SettingsVC.h"
#import "SignupVC.h"
#import "PasswordVC.h"
#import "LanguageVC.h"

@interface SettingsVC ()<UIPickerViewDelegate,UIPickerViewDataSource>
{
    NSMutableArray * arrContent, * allDateFormatArr;
    int txtSize;
    UIView * typeBackView;
    UIPickerView * deviceTypePicker;
}
@end

@implementation SettingsVC

- (void)viewDidLoad
{
    txtSize = 16;
    if (IS_IPHONE_4 || IS_IPHONE_5)
    {
        txtSize = 15;
    }
    UIImageView * imgBack = [[UIImageView alloc] init];
    imgBack.frame = CGRectMake(0, 0, DEVICE_WIDTH, DEVICE_HEIGHT);
    imgBack.image = [UIImage imageNamed:@"Splash_bg.png"];
    [self.view addSubview:imgBack];
    
    UIView * viewHeader = [[UIView alloc] initWithFrame:CGRectMake(0, 0, DEVICE_WIDTH, 64)];
    [viewHeader setBackgroundColor:[UIColor blackColor]];
    [self.view addSubview:viewHeader];
    
    UILabel * lblTitle = [[UILabel alloc] initWithFrame:CGRectMake(50, 20, DEVICE_WIDTH-100, 44)];
    [lblTitle setBackgroundColor:[UIColor clearColor]];
    [lblTitle setText:@"Settings"];
    [lblTitle setTextAlignment:NSTextAlignmentCenter];
    [lblTitle setFont:[UIFont fontWithName:CGRegular size:txtSize]];
    [lblTitle setTextColor:[UIColor whiteColor]];
    [viewHeader addSubview:lblTitle];

    arrContent = [[NSMutableArray alloc] init];
    
    for (int i = 0; i <5; i++)
    {
        NSMutableDictionary * tempDict = [[NSMutableDictionary alloc] init];
        if (i==0)
        {
            [tempDict setValue:@"profile.png" forKey:@"image"];
            [tempDict setValue:@"Update Profile" forKey:@"name"];
        }
        /*else if (i==1)
        {
            [tempDict setValue:@"password.png" forKey:@"image"];
            [tempDict setValue:@"Change Password" forKey:@"name"];
        }*/
        else if (i==1)
        {
            [tempDict setValue:@"language.png" forKey:@"image"];
            [tempDict setValue:@"Select Language" forKey:@"name"];
        }
        else if (i==2)
        {
            [tempDict setValue:@"date_format.png" forKey:@"image"];
            [tempDict setValue:@"Change Date format" forKey:@"name"];
        }
        else if (i==3)
        {
            [tempDict setValue:@"contactus.png" forKey:@"image"];
            [tempDict setValue:@"Contact Us" forKey:@"name"];
        }
        else if (i==4)
        {
            [tempDict setValue:@"logout.png" forKey:@"image"];
            [tempDict setValue:@"Logout" forKey:@"name"];
        }
        
        
        [arrContent addObject:tempDict];
    }

    NSArray * showArr = [NSArray arrayWithObjects:@"YYYY-MM-dd",@"DD-MM-YYYY",@"DD/MM/YYYY",@"DD MMM YYYY",@"MM/DD/YYYY",@"YYYY/MM/DD", nil];
    
    NSArray * valueArr = [NSArray arrayWithObjects:@"YYYY-MM-dd",@"dd-MM-yyyy",@"dd/MM/yyyy",@"dd MMMM yyyy",@"MM/dd/yyyy",@"yyyy/MM/dd", nil];

    allDateFormatArr = [[NSMutableArray alloc] init];
    for (int i=0; i<[showArr count]; i++)
    {
        NSMutableDictionary * dict = [[NSMutableDictionary alloc] init];
        [dict setObject:[showArr objectAtIndex:i] forKey:@"show"];
        [dict setObject:[valueArr objectAtIndex:i] forKey:@"value"];
        [dict setObject:[NSString stringWithFormat:@"date%d",i+1] forKey:@"date"];
        [allDateFormatArr addObject:dict];
    }

    tblContent = [[UITableView alloc] initWithFrame:CGRectMake(0, 64-25, DEVICE_WIDTH, DEVICE_HEIGHT-64-49) style:UITableViewStyleGrouped];
    [tblContent setBackgroundColor:[UIColor clearColor]];
    [tblContent setShowsVerticalScrollIndicator:NO];
    tblContent.separatorStyle = UITableViewCellSeparatorStyleNone;
    tblContent.delegate = self;
    tblContent.dataSource = self;
    tblContent.scrollEnabled = NO;
    [self.view addSubview:tblContent];
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [arrContent count];
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *cellID = nil;
    
    MoreOptionCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
    if (cell == nil)
    {
        cell = [[MoreOptionCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    [cell.lblEmail setHidden:YES];
    [cell.imgIcon setHidden:NO];
    
    [cell.lblName setFrame:CGRectMake(40, 0,DEVICE_WIDTH-50,50)];
    [cell.imgArrow setFrame:CGRectMake(DEVICE_WIDTH-20, 20, 10, 10)];
    [cell.imgCellBG setFrame:CGRectMake(0, 0, DEVICE_WIDTH, 50)];
    cell.imgCellBG.backgroundColor = [UIColor blackColor];
    cell.imgArrow.image = [UIImage imageNamed:@"arrow.png"];
    
    [cell.lblName setFont:[UIFont fontWithName:CGRegular size:txtSize]];

    cell.lblName.text = [[arrContent objectAtIndex:indexPath.row] valueForKey:@"name"];
    cell.imgIcon.image = [UIImage imageNamed:[[arrContent objectAtIndex:indexPath.row] valueForKey:@"image"]];
    cell.lblName.textColor = [UIColor whiteColor];
    
    if (indexPath.row==2)
    {
        cell.imgArrow.hidden = YES;
        cell.lblEmail.hidden = NO;
        cell.lblEmail.frame =CGRectMake(DEVICE_WIDTH-110, 0,100,50);
        [cell.lblEmail setFont:[UIFont fontWithName:CGRegular size:txtSize-2]];
        cell.lblEmail.textColor = [UIColor lightGrayColor];
        cell.lblEmail.textAlignment = NSTextAlignmentRight;
        cell.lblEmail.text = [[NSUserDefaults standardUserDefaults] valueForKey:@"GloablDateFormatShow"];
    }
    else if (indexPath.row==3)
    {
        cell.imgArrow.hidden = YES;
        cell.lblEmail.hidden = NO;
        cell.lblEmail.frame =CGRectMake(DEVICE_WIDTH-140, 0,130,50);
        [cell.lblEmail setFont:[UIFont fontWithName:CGRegular size:txtSize-1]];
        cell.lblEmail.textColor = [UIColor lightGrayColor];
        cell.lblEmail.textAlignment = NSTextAlignmentRight;
        cell.lblEmail.text = @"+44 191 4476883";
        
    }
    return cell;
}
- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath;
{
    cell.backgroundColor = [UIColor clearColor];
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row ==0)
    {
        SignupVC * signVC = [[SignupVC alloc] init];
        signVC.isFromEdit = YES;
        [self.navigationController pushViewController:signVC animated:YES];
    }
    else if (indexPath.row ==1)
    {
        if ([CURRENT_USER_EMAIL isEqualToString:@"kalpesh"])
        {
            LanguageVC * signVC = [[LanguageVC alloc] init];
            [self.navigationController pushViewController:signVC animated:YES];
        }
    }
    else if (indexPath.row == 2)
    {
        [self changeDateformatClick];
    }
    else if (indexPath.row == 3)
    {
        NSString *number = [NSString stringWithFormat:@"+441914476883"];
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
    else if (indexPath.row==4)
    {
        URBAlertView *alertView = [[URBAlertView alloc] initWithTitle:ALERT_TITLE message:@"Are you sure you want to logout?" cancelButtonTitle:@"Yes" otherButtonTitles: @"No", nil];
        [alertView setMessageFont:[UIFont fontWithName:CGRegular size:12]];
        [alertView setHandlerBlock:^(NSInteger buttonIndex, URBAlertView *alertView) {
            [alertView hideWithCompletionBlock:^{
                
                if (buttonIndex==0)
                {
                    [[NSUserDefaults standardUserDefaults] setObject:@"NO" forKey:@"IS_LOGGEDIN"];
                    [[NSUserDefaults standardUserDefaults] setInteger:0 forKey:@"lastUPInstallID"];
                    [[NSUserDefaults standardUserDefaults] setInteger:0 forKey:@"lastBottomInstallID"];
                    [[NSUserDefaults standardUserDefaults] setInteger:0 forKey:@"lastUPUnInstallID"];
                    [[NSUserDefaults standardUserDefaults] setInteger:0 forKey:@"lastBottomUnInstallID"];
                    [[NSUserDefaults standardUserDefaults] setInteger:0 forKey:@"lastUPInspection"];
                    [[NSUserDefaults standardUserDefaults] setInteger:0 forKey:@"lastBottomInspection"];
                    [[NSUserDefaults standardUserDefaults] setInteger:0 forKey:@"industry"];
                    [[NSUserDefaults standardUserDefaults] synchronize];
                    [APP_DELEGATE movetoLogin];
                }
                else
                {
                    
                }
            }];
        }];
        [alertView showWithAnimation:Alert_Animation_Type];
        if (IS_IPHONE_X) {[alertView showWithAnimation:URBAlertAnimationDefault];}
        
    }
}
-(void)changeDateformatClick
{
    [typeBackView removeFromSuperview];
    
    typeBackView = [[UIView alloc] initWithFrame:CGRectMake(0, DEVICE_HEIGHT, DEVICE_WIDTH, 250)];
    [typeBackView setBackgroundColor:[UIColor whiteColor]];
    [self.view addSubview:typeBackView];
    
    [deviceTypePicker removeFromSuperview];
    deviceTypePicker = nil;
    deviceTypePicker.delegate=nil;
    deviceTypePicker.dataSource=nil;
    deviceTypePicker = [[UIPickerView alloc] initWithFrame:CGRectMake(0, 34, DEVICE_WIDTH, 216)];
    [deviceTypePicker setBackgroundColor:[UIColor blackColor]];
    deviceTypePicker.tag=123;
    [deviceTypePicker setDelegate:self];
    [deviceTypePicker setDataSource:self];
    [typeBackView addSubview:deviceTypePicker];
    
    UIButton * btnCancel = [UIButton buttonWithType:UIButtonTypeCustom];
    [btnCancel setFrame:CGRectMake(0 , 0, DEVICE_WIDTH/2, 44)];
    [btnCancel setBackgroundImage:[UIImage imageNamed:@"BTN.png"] forState:UIControlStateNormal];
    [btnCancel setTitle:@"Cancel" forState:UIControlStateNormal];
    [btnCancel setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    btnCancel.titleLabel.font = [UIFont fontWithName:CGRegular size:16];
    [btnCancel setTag:123];
    [btnCancel addTarget:self action:@selector(btnCancelClick:) forControlEvents:UIControlEventTouchUpInside];
    [typeBackView addSubview:btnCancel];
    
    UIButton * btnDone2 = [UIButton buttonWithType:UIButtonTypeCustom];
    [btnDone2 setFrame:CGRectMake(DEVICE_WIDTH/2 , 0, DEVICE_WIDTH/2, 44)];
    [btnDone2 setBackgroundImage:[UIImage imageNamed:@"BTN.png"] forState:UIControlStateNormal];
    [btnDone2 setTitle:@"Done" forState:UIControlStateNormal];
    [btnDone2 setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    btnDone2.titleLabel.font = [UIFont fontWithName:CGRegular size:16];
    [btnDone2 setTag:123];
    [btnDone2 addTarget:self action:@selector(btnDoneClicked:) forControlEvents:UIControlEventTouchUpInside];
    [typeBackView addSubview:btnDone2];
    
    
    [self ShowPicker:YES andView:typeBackView];
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
#pragma mark - PickerView Delegate
-(NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    if (pickerView == deviceTypePicker)
    {
        return 1;
    }
    else
    {
        return 1;
    }
}

-(NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    if([pickerView tag]==123)
    {
        return [allDateFormatArr count];
    }
    else if([pickerView tag]==126)
    {
        return 1;
    }
    return 1;
}

- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view
{
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, pickerView.frame.size.width, 44)];
    label.backgroundColor = [UIColor clearColor];
    label.textAlignment = NSTextAlignmentCenter;
    label.textColor = [UIColor whiteColor];
    label.font = [UIFont fontWithName:CGBold size:14];
    
    if (component == 0)
    {
        if (pickerView.tag==123)
        {
            label.text = [[allDateFormatArr objectAtIndex:row] valueForKey:@"show"];
            return label;
        }
    }
    return label;
}

-(void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    if (pickerView.tag == 123)
    {
        
    }
}

-(void)btnDoneClicked:(id)sender
{
    if ([sender tag] == 123)
    {
        NSInteger index = [deviceTypePicker selectedRowInComponent:0];
        if ([allDateFormatArr count] >= index)
        {
            [[NSUserDefaults standardUserDefaults] setObject:[[allDateFormatArr objectAtIndex:index]valueForKey:@"value"] forKey:@"GloablDateFormat"];
            [[NSUserDefaults standardUserDefaults] setObject:[[allDateFormatArr objectAtIndex:index]valueForKey:@"show"] forKey:@"GloablDateFormatShow"];
            [[NSUserDefaults standardUserDefaults] setObject:[[allDateFormatArr objectAtIndex:index]valueForKey:@"date"] forKey:@"globalDate"];
            [[NSUserDefaults standardUserDefaults] synchronize];
            [tblContent reloadData];
        }
        [self ShowPicker:NO andView:typeBackView];
    }
}
-(void)btnCancelClick:(id)sender
{
    [self ShowPicker:NO andView:typeBackView];
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
 
 @"lastUPInstallID"
 lastBottomInstallID
 
 lastUPUnInstallID
 lastBottomUnInstallID
 
 lastUPInspection
 lastBottomInspection
*/

@end
