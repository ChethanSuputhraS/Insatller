//
//  VesselVC.m
//  Succorfish Installer App
//
//  Created by stuart watts on 27/02/2018.
//  Copyright © 2018 Kalpesh Panchasara. All rights reserved.
//

#import "VesselVC.h"

@interface VesselVC ()
{
    int yVessel, yRegister;
    int textSize;
    BOOL isSelectedReal;
}

@end

@implementation VesselVC

- (void)viewDidLoad
{
    textSize = 16;
    if (IS_IPHONE_4 || IS_IPHONE_5)
    {
        textSize = 15;
    }
    
    UIImageView * imgBack = [[UIImageView alloc] init];
    imgBack.frame = CGRectMake(0, 0, DEVICE_WIDTH, DEVICE_HEIGHT);
    imgBack.image = [UIImage imageNamed:@"Splash_bg.png"];
    imgBack.userInteractionEnabled = YES;
    [self.view addSubview:imgBack];

    isVesselSearch = YES;
    vesselArr = [[NSMutableArray alloc] init];
    [self setVesselArray];
    regiNoArr = [[NSMutableArray alloc] init];
    for (int i=0; i<100; i++)
    {
        NSString * strName = [NSString stringWithFormat:@"Reg. %d",i+1];
        NSMutableDictionary * dict = [[NSMutableDictionary alloc] init];
        [dict setObject:strName forKey:@"name"];
        [regiNoArr addObject:dict];
    }
    [self setNavigationViewFrames];
    [self setViewFrame];
    [super viewDidLoad];
    
    // Do any additional setup after loading the view.
}

-(void)setVesselArray
{
    NSString * strQuery = [NSString stringWithFormat:@"Select * from tbl_vessel_extra"];
    vesselArr = [[NSMutableArray alloc] init];
    [[DataBaseManager dataBaseManager] execute:strQuery resultsArray:vesselArr];
    
    if ([vesselArr count]==0)
    {
        NSString * strQuery = [NSString stringWithFormat:@"Select * from tbl_vessel_asset"];
        vesselArr = [[NSMutableArray alloc] init];
        [[DataBaseManager dataBaseManager] execute:strQuery resultsArray:vesselArr];
    }
}
#pragma mark - Set Frames
-(void)setNavigationViewFrames
{
    UIView * viewHeader = [[UIView alloc] initWithFrame:CGRectMake(0, 0, DEVICE_WIDTH, 64)];
    [viewHeader setBackgroundColor:[UIColor blackColor]];
    [self.view addSubview:viewHeader];
    
    UILabel * lblTitle = [[UILabel alloc] initWithFrame:CGRectMake(50, 20, DEVICE_WIDTH-100, 44)];
    [lblTitle setBackgroundColor:[UIColor clearColor]];
    [lblTitle setText:@"Add Assets"];
    [lblTitle setTextAlignment:NSTextAlignmentCenter];
    [lblTitle setFont:[UIFont fontWithName:CGRegular size:textSize+1]];
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
    
    UIButton * btnSave = [UIButton buttonWithType:UIButtonTypeCustom];
    [btnSave addTarget:self action:@selector(btnSaveClick) forControlEvents:UIControlEventTouchUpInside];
    btnSave.frame = CGRectMake(DEVICE_WIDTH-50, 20, 50, 44);
    btnSave.backgroundColor = [UIColor clearColor];
    [btnSave setTitle:@"Save" forState:UIControlStateNormal];
    [btnSave setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [btnSave.titleLabel setFont:[UIFont fontWithName:CGRegular size:textSize]];
    [viewHeader addSubview:btnSave];
    

    if (IS_IPHONE_X)
    {
        statusHeight = 88;
        viewHeader.frame = CGRectMake(0, 0, DEVICE_WIDTH, 88);
        lblTitle.frame = CGRectMake(50, 40, DEVICE_WIDTH-100, 44);
        backImg.frame = CGRectMake(10, 12+44, 12, 20);
        btnBack.frame = CGRectMake(0, 20, 70, 84);
        btnSave.frame = CGRectMake(DEVICE_WIDTH-50, 40, 50, 44);
    }
}
-(void)btnBackClick
{
    [self.navigationController popViewControllerAnimated:YES];
}
-(void)btnSaveClick
{
    if ([txtVessels.text length]==0)
    {
        URBAlertView *alertView = [[URBAlertView alloc] initWithTitle:ALERT_TITLE message:@"Please enter Asset name." cancelButtonTitle:OK_BTN otherButtonTitles: nil, nil];
        
        [alertView setMessageFont:[UIFont fontWithName:CGRegular size:14]];
        [alertView setHandlerBlock:^(NSInteger buttonIndex, URBAlertView *alertView) {
            [alertView hideWithCompletionBlock:^{
            }];
        }];
        [alertView showWithAnimation:URBAlertAnimationTopToBottom];
    if (IS_IPHONE_X){[alertView showWithAnimation:URBAlertAnimationDefault];}
    }
    else if ([txtRegisterNo.text length]==0)
    {
        URBAlertView *alertView = [[URBAlertView alloc] initWithTitle:ALERT_TITLE message:@"Please enter Registration No." cancelButtonTitle:OK_BTN otherButtonTitles: nil, nil];
        
        [alertView setMessageFont:[UIFont fontWithName:CGRegular size:14]];
        [alertView setHandlerBlock:^(NSInteger buttonIndex, URBAlertView *alertView) {
            [alertView hideWithCompletionBlock:^{
            }];
        }];
        [alertView showWithAnimation:URBAlertAnimationTopToBottom];
    if (IS_IPHONE_X){[alertView showWithAnimation:URBAlertAnimationDefault];}
    }
    else
    {
        if (isSelectedReal)
        {
            installRegi = txtRegisterNo.text;
            installVesselName = txtVessels.text;
            [self.navigationController popViewControllerAnimated:YES];
        }
        else
        {
            URBAlertView *alertView = [[URBAlertView alloc] initWithTitle:ALERT_TITLE message:@"Please contact administrator if you require a new Asset added to the account." cancelButtonTitle:OK_BTN otherButtonTitles: nil, nil];
            [alertView setMessageFont:[UIFont fontWithName:CGRegular size:14]];
            [alertView setHandlerBlock:^(NSInteger buttonIndex, URBAlertView *alertView) {
                [alertView hideWithCompletionBlock:^{
                }];
            }];
            [alertView showWithAnimation:URBAlertAnimationTopToBottom];
    if (IS_IPHONE_X){[alertView showWithAnimation:URBAlertAnimationDefault];}
        }
    }
}
-(void)setViewFrame
{
    [mainView removeFromSuperview];
    mainView = [[UIView alloc] init];
    mainView.frame = CGRectMake(0, statusHeight, DEVICE_WIDTH, DEVICE_HEIGHT-statusHeight);
    mainView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:mainView];

    int yy = 20;

    txtVessels=[[UISearchBar alloc] initWithFrame:CGRectMake(10, yy, DEVICE_WIDTH-20, 50)];
    txtVessels.delegate=self;
    txtVessels.backgroundColor=[UIColor clearColor];
    txtVessels.barTintColor=[UIColor whiteColor];
    txtVessels.layer.borderColor=[UIColor blackColor].CGColor;
    
    for (UIView *subView in txtVessels.subviews)
    {
        for (UIView *secondLevelSubview in subView.subviews) {
            if ([secondLevelSubview isKindOfClass:NSClassFromString(@"UISearchBarBackground")])
            {
            }
        }
    }
    [txtVessels setBackgroundImage: [UIImage new]];
    
    txtVessels.backgroundImage = [[UIImage alloc] init];
    txtVessels.backgroundColor = [UIColor clearColor];
    [mainView addSubview:txtVessels];
    
    UITextField *txfSearchField = [txtVessels valueForKey:@"_searchField"];
    [txfSearchField setBackgroundColor:[UIColor clearColor]];
    [txfSearchField setLeftView:UITextFieldViewModeNever];
    [txfSearchField setBorderStyle:UITextBorderStyleNone];
    [txfSearchField setTextColor:[UIColor blackColor]];
    txfSearchField.layer.borderColor = [UIColor clearColor].CGColor;
    txfSearchField.textColor=[UIColor whiteColor];
    txfSearchField.textAlignment = NSTextAlignmentLeft;
    txfSearchField.placeholder = @" Enter Asset name here                                    ";
    [APP_DELEGATE getPlaceholderText:txfSearchField andColor:UIColor.whiteColor];
    txfSearchField.autocorrectionType = UITextAutocorrectionTypeNo;
    txfSearchField.font = [UIFont fontWithName:CGRegular size:textSize];


    UILabel * lblLine2 = [[UILabel alloc] initWithFrame:CGRectMake(10,txtVessels.frame.size.height-9, txtVessels.frame.size.width, 1)];
    [lblLine2 setBackgroundColor:[UIColor lightGrayColor]];
    [txtVessels addSubview:lblLine2];
    
    UILabel * lblTitle = [[UILabel alloc] initWithFrame:CGRectMake(10,yy-10, txtVessels.frame.size.width, 25)];
    lblTitle.textColor = [UIColor whiteColor];
    lblTitle.font = [UIFont fontWithName:CGRegular size:textSize-2];
    lblTitle.text= @"Asset Name:";
    [lblTitle setBackgroundColor:[UIColor clearColor]];
    [mainView addSubview:lblTitle];

    yVessel = yy + 50-9;
    
    
    yy = yy + 50 + 25;
    
    UILabel * lblTitle1 = [[UILabel alloc] initWithFrame:CGRectMake(10,yy-10, txtVessels.frame.size.width, 25)];
    lblTitle1.textColor = [UIColor whiteColor];
    lblTitle1.font = [UIFont fontWithName:CGRegular size:textSize-2];
    lblTitle1.text= @"Registration No:";
    [lblTitle1 setBackgroundColor:[UIColor clearColor]];
    [mainView addSubview:lblTitle1];
    
    txtRegisterNo=[[UISearchBar alloc] initWithFrame:CGRectMake(10, yy, DEVICE_WIDTH-20, 50)];
    txtRegisterNo.delegate=self;
    txtRegisterNo.backgroundColor=[UIColor clearColor];
    txtRegisterNo.barTintColor=[UIColor clearColor];
    txtRegisterNo.layer.borderColor=[UIColor blackColor].CGColor;
    
    for (UIView *subView in txtRegisterNo.subviews)
    {
        for (UIView *secondLevelSubview in subView.subviews) {
            if ([secondLevelSubview isKindOfClass:NSClassFromString(@"UISearchBarBackground")])
            {
            }
        }
    }
    [txtRegisterNo setBackgroundImage: [UIImage new]];
    [mainView addSubview:txtRegisterNo];
    
    txtRegisterNo.backgroundImage = [[UIImage alloc] init];
    txtRegisterNo.backgroundColor = [UIColor clearColor];

    UITextField *txfSearchField1 = [txtRegisterNo valueForKey:@"_searchField"];
    [txfSearchField1 setBackgroundColor:[UIColor clearColor]];
    [txfSearchField1 setLeftView:UITextFieldViewModeNever];
    [txfSearchField1 setBorderStyle:UITextBorderStyleNone];
    [txfSearchField1 setTextColor:[UIColor blackColor]];
    txfSearchField1.layer.borderColor = [UIColor clearColor].CGColor;
    txfSearchField1.textColor=[UIColor whiteColor];
    txfSearchField1.textAlignment = NSTextAlignmentLeft;
    txfSearchField1.placeholder = @"Enter Registration No. here                                    ";
    [APP_DELEGATE getPlaceholderText:txfSearchField1 andColor:UIColor.whiteColor];
    txfSearchField1.autocorrectionType = UITextAutocorrectionTypeNo;
    txfSearchField1.font = [UIFont fontWithName:CGRegular size:textSize];

    UILabel * lblLine = [[UILabel alloc] initWithFrame:CGRectMake(10,txtRegisterNo.frame.size.height-7, txtRegisterNo.frame.size.width, 1)];
    [lblLine setBackgroundColor:[UIColor lightGrayColor]];
    [txtRegisterNo addSubview:lblLine];
    
    
    if (IS_IPHONE_5 || IS_IPHONE_4)
    {
        txfSearchField1.placeholder = @" Enter Registration No. here                       ";
        txfSearchField.placeholder = @" Enter Asset name here                             ";
    }
    yRegister = yy + 50-14;

    [tblView removeFromSuperview];
    tblView = [[UITableView alloc] initWithFrame:CGRectMake(0, 124, DEVICE_WIDTH, DEVICE_HEIGHT-124) style:UITableViewStylePlain];
    tblView.delegate = self;
    tblView.dataSource = self;
    tblView.backgroundColor = [UIColor clearColor];
    tblView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    tblView.separatorColor = [UIColor darkGrayColor];
    tblView.hidden = YES;
    [self.view addSubview:tblView];
    
    if (IS_IPHONE_X)
    {
        tblView.frame = CGRectMake(0, 124, DEVICE_WIDTH, DEVICE_HEIGHT-124-45);
    }
    
    if (installRegi != nil || [installRegi length]>0)
    {
        txtRegisterNo.text = installRegi;
    }
    
    if (installVesselName != nil || [installVesselName length]>0)
    {
        txtVessels.text = installVesselName;
    }

    if ([txtRegisterNo.text isEqualToString:@"NA"])
    {
        txtRegisterNo.text = @"";
    }
    
    if ([txtVessels.text isEqualToString:@"NA"])
    {
        txtVessels.text = @"";
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (isSearching)
    {
        return [arrSearchedResults count];
    }
    else
    {
        if (isVesselSearch)
        {
            return [vesselArr count];
        }
        else
        {
            return [regiNoArr count];
        }
    }
 
    return [vesselArr count];
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 38;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *CellIdentifier = @"CellIdentifier";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if(!cell)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    if (isSearching)
    {
        if (isVesselSearch)
        {
            cell.textLabel.text = [[arrSearchedResults objectAtIndex:indexPath.row] valueForKey:@"vessel_name"];
        }
        else
        {
            cell.textLabel.text = [[arrSearchedResults objectAtIndex:indexPath.row] valueForKey:@"vessel_regi_no"];
        }

//        cell.textLabel.text = [[arrSearchedResults objectAtIndex:indexPath.row] valueForKey:@"vessel_name"];
    }
    else
    {
        if (isVesselSearch)
        {
            cell.textLabel.text = [[vesselArr objectAtIndex:indexPath.row] valueForKey:@"vessel_name"];
        }
        else
        {
            cell.textLabel.text = [[regiNoArr objectAtIndex:indexPath.row] valueForKey:@"vessel_name"];
        }
    }
    cell.textLabel.font = [UIFont fontWithName:CGRegular size:textSize];

    cell.textLabel.textColor = [UIColor whiteColor];
    return cell;
}
- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath;
{
    cell.backgroundColor = [UIColor blackColor];
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath;
{
    if (isSearching)
    {
        if (isVesselSearch)
        {
            isSelectedReal = YES;
            installedVesselID = [[arrSearchedResults objectAtIndex:indexPath.row] valueForKey:@"vessel_succorfish_id"];
            txtVessels.text = [[arrSearchedResults objectAtIndex:indexPath.row] valueForKey:@"vessel_name"];
            txtRegisterNo.text = [[arrSearchedResults objectAtIndex:indexPath.row] valueForKey:@"vessel_regi_no"];
        }
        else
        {
            txtRegisterNo.text = [[arrSearchedResults objectAtIndex:indexPath.row] valueForKey:@"vessel_regi_no"];
        }
    }
    else
    {
        NSArray *allViews = [txtRegisterNo subviews];
        if (isVesselSearch)
        {
            isSelectedReal = YES;
            allViews = [txtVessels subviews];
            txtVessels.text = [[vesselArr objectAtIndex:indexPath.row] valueForKey:@"vessel_name"];
            txtRegisterNo.text = [[vesselArr objectAtIndex:indexPath.row] valueForKey:@"vessel_regi_no"];
            installedVesselID = [[vesselArr objectAtIndex:indexPath.row] valueForKey:@"vessel_succorfish_id"];
        }
        else
        {
            txtRegisterNo.text = [[regiNoArr objectAtIndex:indexPath.row] valueForKey:@"vessel_regi_no"];
        }
        for(UIView *obj in allViews)
        {
            NSArray *allViews1 = [obj subviews];
            for(UIView *obj in allViews1)
            {
                if ([obj isKindOfClass:[UITextField class ]])
                {
                    UITextField *temp =(UITextField *)obj;
                    temp.textColor = [UIColor whiteColor];
                }
            }
        }
    }
    [txtVessels resignFirstResponder];
    [txtRegisterNo resignFirstResponder];
    txtVessels.showsCancelButton = NO;
    isVesselSearch = NO;
}
#pragma mark - Textfield Delegates
-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}
-(void)textFieldDidBeginEditing:(UITextField *)textField
{
    tblView.hidden = NO;
}
-(void)textFieldDidEndEditing:(UITextField *)textField
{
    tblView.hidden = YES;
}
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string;   // return NO to not change text
{
    if ([textField.text length]>0)
    {
        isSearching = YES;
        tblView.hidden = NO;
        [self filterContentForSearchText:textField.text];
    }
    else
    {
//        tblView.hidden = YES;
        isSearching = NO;
        [tblView reloadData];
    }
    return YES;
}

-(void)filterContentForSearchText:(NSString *)searchText
{
    // Remove all objects from the filtered search array
    [arrSearchedResults removeAllObjects];
    
    // Filter the array using NSPredicate
    NSPredicate *predicate ;
    NSArray *tempArray =[[NSArray alloc] init];
    if (isVesselSearch)
    {
        predicate = [NSPredicate predicateWithFormat:@"vessel_name CONTAINS[cd] %@",searchText];
        tempArray = [vesselArr filteredArrayUsingPredicate:predicate];
    }
    else
    {
        predicate = [NSPredicate predicateWithFormat:@"vessel_regi_no CONTAINS[cd] %@",searchText];
        tempArray = [vesselArr filteredArrayUsingPredicate:predicate];
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
        tblView.hidden = NO;
        [tblView reloadData];
    }
    [tblView reloadData];
}

#pragma mark -  UISearchBar Delegates
- (BOOL)searchDisplayController:(UISearchBar *)controller shouldReloadTableForSearchString:(NSString *)searchString;
{
    return YES;
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText1
{
    if (searchBar == txtVessels)
    {
        isVesselSearch = YES;
        NSArray *allViews = [txtVessels subviews];
        
        for(UIView *obj in allViews)
        {
            NSArray *allViews1 = [obj subviews];
            for(UIView *obj in allViews1)
            {
                if ([obj isKindOfClass:[UITextField class ]])
                {
                    UITextField *temp =(UITextField *)obj;
                    temp.textColor = [UIColor whiteColor];
                }
            }
        }
    }
    else
    {
        isVesselSearch = NO;
        NSArray *allViews = [txtRegisterNo subviews];
        
        for(UIView *obj in allViews)
        {
            NSArray *allViews1 = [obj subviews];
            for(UIView *obj in allViews1)
            {
                if ([obj isKindOfClass:[UITextField class ]])
                {
                    UITextField *temp =(UITextField *)obj;
                    temp.textColor = [UIColor whiteColor];
                }
            }
        }
    }
    if ([searchText1 length]>0)
    {
        tblView.hidden = NO;
      [self filterContentForSearchText:searchText1];
        searchBar.showsCancelButton = YES;
    }
    else
    {
        tblView.hidden = NO;
        isSearching = NO;
        NSLog(@"Hello");
        searchBar.showsCancelButton = YES;
        [searchBar resignFirstResponder];
        [tblView reloadData];
    }
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    NSString *searchStr1 = [NSString stringWithFormat:@"%@",searchBar.text];
    
    if (searchStr1.length >0)
    {
        isSearching=YES;
         [self filterContentForSearchText:searchStr1];
        searchBar.showsCancelButton = YES;
    }
    [searchBar resignFirstResponder];
}
-(void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar
{
    tblView.hidden = NO;
    searchBar.showsCancelButton = YES;
    
    if (searchBar == txtVessels)
    {
        isVesselSearch = YES;
//        tblView.frame = CGRectMake(0, 64+yVessel, DEVICE_WIDTH, DEVICE_HEIGHT-yVessel);
        tblView.frame = CGRectMake(0, 124, DEVICE_WIDTH, DEVICE_HEIGHT-124);
        if (IS_IPHONE_X)
        {
            tblView.frame = CGRectMake(0, 204+50, DEVICE_WIDTH, DEVICE_HEIGHT-204-350);

        }

    }
    else
    {
        isVesselSearch = NO;
//        tblView.frame = CGRectMake(0, 64+yRegister, DEVICE_WIDTH, DEVICE_HEIGHT-yVessel);
        tblView.frame = CGRectMake(0, 204, DEVICE_WIDTH, DEVICE_HEIGHT-204);
        
        if (IS_IPHONE_X)
        {
            tblView.frame = CGRectMake(0, 204+50, DEVICE_WIDTH, DEVICE_HEIGHT-204-350);

        }
    }
    [tblView reloadData];
//    searchImgGlass.hidden=YES;
}

- (void)searchBarTextDidEndEditing:(UISearchBar *)searchBar
{
    tblView.hidden = YES;

    searchBar.showsCancelButton = NO;
    
    if (searchBar.text.length==0)
    {
//        searchImgGlass.hidden=NO;
    }
    else
    {
    }
}
- (void)searchBarCancelButtonClicked:(UISearchBar *) searchBar
{
    isSearching=NO;
    
//    [self callCurrentWebServiceFirstTimeWithCommand:@"getInstallationListFirstTime" AndServiceName:@"getInstallationsList"];
    
    // if you want the keyboard to go away
    searchBar.text = @"";
    [searchBar resignFirstResponder];
    [tblView reloadData];
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
