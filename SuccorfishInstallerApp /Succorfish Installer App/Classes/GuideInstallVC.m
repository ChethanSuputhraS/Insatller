//
//  GuideInstallVC.m
//  Succorfish Installer App
//
//  Created by stuart watts on 12/03/2018.
//  Copyright © 2018 Kalpesh Panchasara. All rights reserved.
//

#import "GuideInstallVC.h"
#import "MoreOptionCell.h"
#import "InstallGuidePDF.h"

@interface GuideInstallVC ()<UIWebViewDelegate>
{
    UIWebView * webView;
    NSMutableArray * arrContent;
}

@end

@implementation GuideInstallVC
@synthesize isfromInstallGuide;
- (void)viewDidLoad
{
    UIImageView * imgBack = [[UIImageView alloc] init];
    imgBack.frame = CGRectMake(0, 0, DEVICE_WIDTH, DEVICE_HEIGHT);
    imgBack.image = [UIImage imageNamed:@"Splash_bg.png"];
    imgBack.userInteractionEnabled = YES;
    [self.view addSubview:imgBack];
    
    [self setNavigationViewFrames];
    [super viewDidLoad];
    
    arrContent = [[NSMutableArray alloc] init];
    
    if (isfromInstallGuide)
    {
        for (int i = 0; i <2; i++)
        {
            NSMutableDictionary * tempDict = [[NSMutableDictionary alloc] init];
            if (i==0)
            {
                [tempDict setValue:@"land.png" forKey:@"image"];
                [tempDict setValue:@"Land installation Guide" forKey:@"name"];
                [tempDict setValue:@"Land" forKey:@"filename"];
            }
            else if (i==1)
            {
                [tempDict setValue:@"marine.png" forKey:@"image"];
                [tempDict setValue:@"Marine installation Guide" forKey:@"name"];
                [tempDict setValue:@"Marine" forKey:@"filename"];
            }
            [arrContent addObject:tempDict];
        }
    }
    else
    {
        for (int i = 0; i <3; i++)
        {
            NSMutableDictionary * tempDict = [[NSMutableDictionary alloc] init];
            if (i==0)
            {
                [tempDict setValue:@"t&c.png" forKey:@"image"];
                [tempDict setValue:@"Succorfish Terms & Conditions" forKey:@"name"];
                [tempDict setValue:@"Terms" forKey:@"filename"];
            }
            else if (i==1)
            {
                [tempDict setValue:@"warranty.png" forKey:@"image"];
                [tempDict setValue:@"Succorfish Warranty" forKey:@"name"];
                [tempDict setValue:@"Warranty" forKey:@"filename"];
            }
//            else if (i==2)
//            {
//                [tempDict setValue:@"health.png" forKey:@"image"];
//                [tempDict setValue:@"Information Security Privacy Policy" forKey:@"name"];
//                [tempDict setValue:@"Health" forKey:@"filename"];
//            }
            else if (i==2)
            {
                [tempDict setValue:@"health.png" forKey:@"image"];
                [tempDict setValue:@"Information Security Privacy Policy" forKey:@"name"];
                [tempDict setValue:@"PrivacyPolicy" forKey:@"filename"];
            }
            [arrContent addObject:tempDict];
        }
    }
   

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
    [lblTitle setText:@"Install Guide"];
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
    
    if (isfromInstallGuide)
    {
        [lblTitle setText:@"Install Guide"];
    }
    else
    {
        [lblTitle setText:@"Legal Docs"];
    }
    if (IS_IPHONE_X)
    {
        viewHeader.frame = CGRectMake(0, 0, DEVICE_WIDTH, 88);
        lblTitle.frame = CGRectMake(50, 40, DEVICE_WIDTH-100, 44);
        backImg.frame = CGRectMake(10, 12+44, 12, 20);
        btnBack.frame = CGRectMake(0, 0, 70, 88);
        [self setMainViewContent:88];
    }
    else
    {
        [self setMainViewContent:64];
    }
}

-(void)setMainViewContent:(int)yAxis
{
    tblContent = [[UITableView alloc] initWithFrame:CGRectMake(0, yAxis, DEVICE_WIDTH, DEVICE_HEIGHT-yAxis) style:UITableViewStyleGrouped];
    [tblContent setBackgroundColor:[UIColor clearColor]];
    [tblContent setShowsVerticalScrollIndicator:NO];
    tblContent.separatorStyle = UITableViewCellSeparatorStyleNone;
    tblContent.delegate = self;
    tblContent.dataSource = self;
    tblContent.scrollEnabled = NO;
    [self.view addSubview:tblContent];
    
    if (IS_IPHONE_X)
    {
        tblContent.frame = CGRectMake(0, yAxis, DEVICE_WIDTH, DEVICE_HEIGHT-yAxis-40);
    }
    

}
#pragma mark - Button Click events
-(void)btnBackClick
{
    [self.navigationController popViewControllerAnimated:YES];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return arrContent.count;
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
    cell.imgCellBG.alpha = 0.5;
    
    cell.lblName.textColor = [UIColor whiteColor];
        cell.lblName.text = [[arrContent objectAtIndex:indexPath.row] valueForKey:@"name"];
        cell.imgIcon.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@",[[arrContent objectAtIndex:indexPath.row] valueForKey:@"image"]]];
    return cell;
}
- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath;
{
    cell.backgroundColor = [UIColor clearColor];
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    InstallGuidePDF * guidePdf = [[InstallGuidePDF alloc] init];
    guidePdf.strFrom = [[arrContent objectAtIndex:indexPath.row] valueForKey:@"filename"];
    guidePdf.strTitle = [[arrContent objectAtIndex:indexPath.row] valueForKey:@"name"];
    guidePdf.isfromInstallGuide = isfromInstallGuide;
    [self.navigationController pushViewController:guidePdf animated:YES];
    
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
