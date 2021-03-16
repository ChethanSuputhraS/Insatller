//
//  SignupVC.m
//  Succorfish Installer App
//
//  Created by stuart watts on 20/02/2018.
//  Copyright © 2018 Kalpesh Panchasara. All rights reserved.
//

#import "SignupVC.h"
#import "VerifyVC.h"

@interface SignupVC ()
{
    NSString * codeSignCntry;
    int txtSize;
    NSMutableDictionary * userDetailDict;
    UIImageView * imgCheck;
    BOOL isAgreed;
}
@end

@implementation SignupVC
@synthesize isFromEdit;

- (void)viewDidLoad
{
    txtSize= 16;
    if (IS_IPHONE_5 || IS_IPHONE_4)
    {
        txtSize = 15;
    }
    [imgBack removeFromSuperview];
    imgBack = [[UIImageView alloc] init];
    imgBack.frame = CGRectMake(0, 0, DEVICE_WIDTH, DEVICE_HEIGHT);
    imgBack.image = [UIImage imageNamed:@"Splash_bg.png"];
    [self.view addSubview:imgBack];
    
   
    [self setContentViewFrames];

    
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

-(void)viewDidAppear:(BOOL)animated
{
        [self setupforCountryPicker];
}
#pragma mark - Set UI frames
-(void)setNavigationViewFrames
{
    UIView * viewHeader = [[UIView alloc] initWithFrame:CGRectMake(0, 0, DEVICE_WIDTH, 64)];
    [viewHeader setBackgroundColor:[UIColor blackColor]];
    [self.view addSubview:viewHeader];
    
    UILabel * lblTitle = [[UILabel alloc] initWithFrame:CGRectMake(50, 20, DEVICE_WIDTH-100, 44)];
    [lblTitle setBackgroundColor:[UIColor clearColor]];
    [lblTitle setText:@"User Profile"];
    [lblTitle setTextAlignment:NSTextAlignmentCenter];
    [lblTitle setFont:[UIFont fontWithName:CGRegular size:txtSize]];
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
    
    
    if (IS_IPHONE_X)
    {
        viewHeader.frame = CGRectMake(0, 0, DEVICE_WIDTH, 88);
        lblTitle.frame = CGRectMake(50, 40, DEVICE_WIDTH-100, 44);
        backImg.frame = CGRectMake(10, 12+44, 12, 20);
        btnBack.frame = CGRectMake(0, 0, 70, 88);
    }
}

-(void)setContentViewFrames
{
    [scrlContent removeFromSuperview];
    scrlContent = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, DEVICE_WIDTH, DEVICE_HEIGHT)];
    scrlContent.showsVerticalScrollIndicator = NO;
    [self.view addSubview:scrlContent];
    
    if (isFromEdit)
    {
        [self setNavigationViewFrames];
    }
    UILabel * lblName =  [[UILabel alloc] init];
    lblName.frame = CGRectMake(15, 25, DEVICE_WIDTH-30, 30);
    lblName.textAlignment = NSTextAlignmentCenter;
    lblName.textColor = [UIColor whiteColor];
    lblName.text = @"Sign Up";
    [lblName setFont:[UIFont fontWithName:CGRegular size:txtSize]];
    [scrlContent addSubview:lblName];

    
    [imgLogo removeFromSuperview];
    imgLogo = [[UIImageView alloc] initWithFrame:CGRectMake((DEVICE_WIDTH-(170*approaxSize))/2, 67*approaxSize, 170*approaxSize, 34*approaxSize)];
    [imgLogo setImage:[UIImage imageNamed:@"logo.png"]];
    [imgLogo setClipsToBounds:YES];
    [imgLogo setContentMode:UIViewContentModeScaleAspectFit];
    [scrlContent addSubview:imgLogo];
    
    [viewPopUp removeFromSuperview];
    viewPopUp = [[UIView alloc] initWithFrame:CGRectMake(15, 115*approaxSize, DEVICE_WIDTH-30, 300*approaxSize)];
    [viewPopUp setBackgroundColor:[UIColor clearColor]];
    viewPopUp.layer.shadowColor = [UIColor darkGrayColor].CGColor;
    viewPopUp.layer.shadowOffset = CGSizeMake(0.1, 0.1);
    viewPopUp.layer.shadowRadius = 50;
    viewPopUp.layer.shadowOpacity = 0.5;
    [scrlContent addSubview:viewPopUp];
    
    
    if (IS_IPHONE_4)
    {
        lblName.frame = CGRectMake(15, 20, DEVICE_WIDTH-30, 30);
        imgLogo.hidden = YES;
        imgLogo.frame = CGRectMake((DEVICE_WIDTH-204)/2, 20, 204, 42);
        viewPopUp.frame = CGRectMake(15, 50, DEVICE_WIDTH-30, 300);
    }
    else if (IS_IPHONE_5)
    {
        imgLogo.frame = CGRectMake((DEVICE_WIDTH-(170*approaxSize))/2, 64*approaxSize, 170*approaxSize, 34*approaxSize);
        viewPopUp.frame = CGRectMake(15, 115*approaxSize, DEVICE_WIDTH-30, 300);
    }
    if (isFromEdit)
    {
        imgLogo.hidden = YES;
        lblName.hidden = YES;
        viewPopUp.frame = CGRectMake(15, 75*approaxSize, DEVICE_WIDTH-30, 370*approaxSize);
        if (IS_IPHONE_4)
        {
            viewPopUp.frame = CGRectMake(15, 75, DEVICE_WIDTH-30, 400-30);
        }
        else if (IS_IPHONE_X)
        {
            viewPopUp.frame = CGRectMake(15, 98, DEVICE_WIDTH-30, 400+30);
        }
        
    }
    int yy = 15;
    
    UILabel * imgPopUpBG = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, viewPopUp.frame.size.width, viewPopUp.frame.size.height)];
    [imgPopUpBG setBackgroundColor:[UIColor blackColor]];
    imgPopUpBG.alpha = 0.7;
    imgPopUpBG.layer.cornerRadius = 10;
    imgPopUpBG.userInteractionEnabled = YES;
    [viewPopUp addSubview:imgPopUpBG];
    
    UIBezierPath *shadowPath = [UIBezierPath bezierPathWithRect:imgPopUpBG.bounds];
    imgPopUpBG.layer.masksToBounds = NO;
    imgPopUpBG.layer.shadowColor = [UIColor whiteColor].CGColor;
    imgPopUpBG.layer.shadowOffset = CGSizeMake(0.0f, 1.0f);
    imgPopUpBG.layer.shadowOpacity = 0.5f;
    imgPopUpBG.layer.shadowPath = shadowPath.CGPath;
    
    txtName = [[UITextField alloc] initWithFrame:CGRectMake(15, yy, viewPopUp.frame.size.width-30, 35*approaxSize)];
    txtName.placeholder = @"Name";
    txtName.autocapitalizationType = UITextAutocapitalizationTypeNone;
    txtName.delegate = self;
    txtName.autocorrectionType = UITextAutocorrectionTypeNo;
    txtName.textColor = [UIColor whiteColor];
    [txtName setFont:[UIFont fontWithName:CGRegular size:txtSize]];
    txtName.returnKeyType = UIReturnKeyNext;
    [APP_DELEGATE getPlaceholderText:txtName andColor:UIColor.whiteColor];
    [viewPopUp addSubview:txtName];
    txtName.returnKeyType  = UIReturnKeyNext;
    
    UILabel * nameLine = [[UILabel alloc] initWithFrame:CGRectMake(0,(35*approaxSize)-2, txtName.frame.size.width, 1)];
    [nameLine setBackgroundColor:[UIColor lightGrayColor]];
    [txtName addSubview:nameLine];
    
    yy = yy+50*approaxSize;
    
    txtBusiness = [[UITextField alloc] initWithFrame:CGRectMake(15, yy, viewPopUp.frame.size.width-30, 35*approaxSize)];
    txtBusiness.placeholder = @"Business name";
    txtBusiness.delegate = self;
    txtBusiness.autocapitalizationType = UITextAutocapitalizationTypeNone;
    txtBusiness.textColor = [UIColor whiteColor];
    txtBusiness.autocorrectionType = UITextAutocorrectionTypeNo;
    [txtBusiness setFont:[UIFont fontWithName:CGRegular size:txtSize]];
    txtBusiness.returnKeyType = UIReturnKeyNext;
    [viewPopUp addSubview:txtBusiness];
    [APP_DELEGATE getPlaceholderText:txtBusiness andColor:UIColor.whiteColor];
    txtBusiness.returnKeyType  = UIReturnKeyNext;

    UILabel * lblBusinessLine = [[UILabel alloc] initWithFrame:CGRectMake(0, txtBusiness.frame.size.height-2, txtBusiness.frame.size.width,1)];
    [lblBusinessLine setBackgroundColor:[UIColor lightGrayColor]];
    [txtBusiness addSubview:lblBusinessLine];
    
    
    yy = yy+50*approaxSize;
    
    txtAddress = [[UITextField alloc] initWithFrame:CGRectMake(15, yy, viewPopUp.frame.size.width-30, 35*approaxSize)];
    txtAddress.placeholder = @"Address";
    txtAddress.delegate = self;
    txtAddress.autocapitalizationType = UITextAutocapitalizationTypeNone;
    txtAddress.textColor = [UIColor whiteColor];
    txtAddress.autocorrectionType = UITextAutocorrectionTypeNo;
    [txtAddress setFont:[UIFont fontWithName:CGRegular size:txtSize]];
    txtAddress.returnKeyType = UIReturnKeyNext;
    [viewPopUp addSubview:txtAddress];
    [APP_DELEGATE getPlaceholderText:txtAddress andColor:UIColor.whiteColor];
    txtAddress.returnKeyType  = UIReturnKeyNext;

    UILabel * lblAddressLine = [[UILabel alloc] initWithFrame:CGRectMake(0, txtAddress.frame.size.height-2, txtAddress.frame.size.width,1)];
    [lblAddressLine setBackgroundColor:[UIColor lightGrayColor]];
    [txtAddress addSubview:lblAddressLine];
    
    yy = yy+50*approaxSize;
    
    txtEmail = [[UITextField alloc] initWithFrame:CGRectMake(15, yy, viewPopUp.frame.size.width-30, 35*approaxSize)];
    txtEmail.placeholder = @"Email";
    txtEmail.delegate = self;
    txtEmail.autocapitalizationType = UITextAutocapitalizationTypeNone;
    txtEmail.textColor = [UIColor whiteColor];
    [txtEmail setFont:[UIFont fontWithName:CGRegular size:txtSize]];
    txtEmail.autocorrectionType = UITextAutocorrectionTypeNo;
    txtEmail.keyboardType = UIKeyboardTypeEmailAddress;
    txtEmail.returnKeyType = UIReturnKeyNext;
    [viewPopUp addSubview:txtEmail];
    [APP_DELEGATE getPlaceholderText:txtEmail andColor:UIColor.whiteColor];

    UILabel * lblmailLine = [[UILabel alloc] initWithFrame:CGRectMake(0, txtEmail.frame.size.height-2, txtEmail.frame.size.width,1)];
    [lblmailLine setBackgroundColor:[UIColor lightGrayColor]];
    [txtEmail addSubview:lblmailLine];

    
    yy = yy+50*approaxSize;
    
    txtMobile = [[UITextField alloc] initWithFrame:CGRectMake(15, yy, viewPopUp.frame.size.width-30, 35*approaxSize)];
    txtMobile.placeholder = @"Mobile No.";
    txtMobile.delegate = self;
    txtMobile.autocapitalizationType = UITextAutocapitalizationTypeNone;
    txtMobile.textColor = [UIColor whiteColor];
    [txtMobile setFont:[UIFont fontWithName:CGRegular size:txtSize]];
    txtMobile.autocorrectionType = UITextAutocorrectionTypeNo;
    txtMobile.returnKeyType = UIReturnKeyNext;
    txtMobile.keyboardType = UIKeyboardTypePhonePad;
    [viewPopUp addSubview:txtMobile];
    [APP_DELEGATE getPlaceholderText:txtMobile andColor:UIColor.whiteColor];

    UILabel * lblMobileLine = [[UILabel alloc] initWithFrame:CGRectMake(0, txtMobile.frame.size.height-2, txtMobile.frame.size.width,1)];
    [lblMobileLine setBackgroundColor:[UIColor lightGrayColor]];
    [txtMobile addSubview:lblMobileLine];
    
    /*yy = yy + 50*approaxSize;
    
    imgCountry = [[UIImageView alloc] initWithFrame:CGRectMake(15, yy+10, 30, 20)];
    [imgCountry setBackgroundColor:[UIColor clearColor]];
    [viewPopUp addSubview:imgCountry];
    
    lblCountry =[[UILabel alloc] initWithFrame:CGRectMake(50+15, yy, viewPopUp.frame.size.width-50, 35*approaxSize)];
    [lblCountry setFont:[UIFont fontWithName:CGRegular size:txtSize]];
    lblCountry.textColor=[UIColor whiteColor];
    [lblCountry setText:@"Select Country"];
    [viewPopUp addSubview:lblCountry];
    
    UILabel * lblCntry = [[UILabel alloc] initWithFrame:CGRectMake(15, yy + lblCountry.frame.size.height-2, lblCountry.frame.size.width+15,1)];
    [lblCntry setBackgroundColor:[UIColor lightGrayColor]];
    [viewPopUp addSubview:lblCntry];

    btnCountry = [UIButton buttonWithType:UIButtonTypeCustom];
    [btnCountry setFrame:CGRectMake(0,yy,DEVICE_WIDTH  ,35*approaxSize)];
    [btnCountry setBackgroundColor:[UIColor clearColor]];
    [btnCountry addTarget:self action:@selector(CountryClick) forControlEvents:UIControlEventTouchUpInside];
    [viewPopUp addSubview:btnCountry];*/
    
    yy = yy+55;
    
    if (isFromEdit)
    {
        
    }
    else
    {
        if (IS_IPHONE_4)
        {
            [self setTermsConditions:yy-10];
            yy = yy+25;
        }
        else if (IS_IPHONE_5)
        {
            [self setTermsConditions:yy-10];
            yy = yy+35;
        }
        else
        {
            [self setTermsConditions:yy];
            yy = yy+45;
        }
    }

    

    btnNext = [UIButton buttonWithType:UIButtonTypeCustom];
    [btnNext setFrame:CGRectMake(15, yy, viewPopUp.frame.size.width-30, 38*approaxSize)];
    [btnNext setTitle:@"Next" forState:UIControlStateNormal];
    [btnNext setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [btnNext setBackgroundImage:[UIImage imageNamed:@"BTN.png"] forState:UIControlStateNormal];
    [btnNext setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [btnNext.titleLabel setFont:[UIFont fontWithName:CGRegular size:txtSize]];
    [btnNext addTarget:self action:@selector(btnNextClicked) forControlEvents:UIControlEventTouchUpInside];
//    [viewPopUp addSubview:btnNext];
    
    if (isFromEdit)
    {
        [btnNext setTitle:@"SAVE" forState:UIControlStateNormal];
        [self fillForm];
    }
    if(IS_IPHONE_X)
    {
        lblName.frame = CGRectMake(15, 40, DEVICE_WIDTH-30, 30);
    }
    [self setBottomView];
    
    
    txtName.userInteractionEnabled = NO;
    txtBusiness.userInteractionEnabled = NO;
    txtAddress.userInteractionEnabled = NO;
    txtEmail.userInteractionEnabled = NO;
    txtMobile.userInteractionEnabled = NO;
    btnCountry.userInteractionEnabled = NO;

}
-(void)setTermsConditions:(int)withY
{
    imgCheck = [[UIImageView alloc] init];
    imgCheck.image = [UIImage imageNamed:@"checkEmpty.png"];
    imgCheck.frame = CGRectMake(5, withY+8, 20, 20);
    [viewPopUp addSubview:imgCheck];
    
    UIButton * btnAgree = [UIButton buttonWithType:UIButtonTypeCustom];
    [btnAgree setFrame:CGRectMake(0, withY-5, 60, 40)];
    [btnAgree addTarget:self action:@selector(agreeClick) forControlEvents:UIControlEventTouchUpInside];
    btnAgree.backgroundColor = [UIColor clearColor];
    [viewPopUp addSubview:btnAgree];
    
    UILabel * lblTerms =[[UILabel alloc] initWithFrame:CGRectMake(30, withY, viewPopUp.frame.size.width-30, 35)];
    lblTerms.font=[UIFont fontWithName:CGRegular size:txtSize];
    lblTerms.textColor=[UIColor whiteColor];
    [viewPopUp addSubview:lblTerms];
    
    NSMutableAttributedString *hintText = [[NSMutableAttributedString alloc] initWithString:@"I agree to the terms and conditions"];
    UIFontDescriptor *fontDescriptor = [UIFontDescriptor fontDescriptorWithName:CGBold size:txtSize];
    UIFontDescriptor *fontDescriptor1 = [UIFontDescriptor fontDescriptorWithName:CGRegular size:txtSize];
    UIFontDescriptor *symbolicFontDescriptor = [fontDescriptor fontDescriptorWithSymbolicTraits:UIFontDescriptorTraitTightLeading];
    
    UIFontDescriptor *symbolicFontDescriptor1 = [fontDescriptor1 fontDescriptorWithSymbolicTraits:UIFontDescriptorTraitBold];
    
    UIFont *fontWithDescriptor = [UIFont fontWithDescriptor:symbolicFontDescriptor size:txtSize];
    UIFont *fontWithDescriptor1 = [UIFont fontWithDescriptor:symbolicFontDescriptor1 size:txtSize];
    
    //Red and large
    [hintText setAttributes:@{NSFontAttributeName:fontWithDescriptor, NSForegroundColorAttributeName:[UIColor grayColor]} range:NSMakeRange(0, 14)];
    
    //Rest of text -- just futura
    [hintText setAttributes:@{NSFontAttributeName:fontWithDescriptor1, NSForegroundColorAttributeName:[UIColor whiteColor]} range:NSMakeRange(14, hintText.length -14)];
    
    lblTerms.textColor=[UIColor whiteColor];
    [lblTerms setAttributedText:hintText];
    
    UIButton * btnSignUp = [UIButton buttonWithType:UIButtonTypeCustom];
    btnSignUp.frame = CGRectMake(0, withY, DEVICE_WIDTH, 35);
    [btnSignUp addTarget:self action:@selector(btnConditions) forControlEvents:UIControlEventTouchUpInside];
    [scrlContent addSubview:btnSignUp];
    
    if (isFromEdit)
    {
        lblTerms.hidden = YES;
    }
    if(IS_IPHONE_X)
    {
//        btnSignUp.frame = CGRectMake(0, DEVICE_HEIGHT-40-50, DEVICE_WIDTH, 35);
    }
}
-(void)setBottomView
{
    UILabel * loginLbl =[[UILabel alloc] initWithFrame:CGRectMake(0, DEVICE_HEIGHT-45, DEVICE_WIDTH, 35)];
    loginLbl.font=[UIFont fontWithName:CGRegular size:txtSize];
    loginLbl.textAlignment=NSTextAlignmentCenter;
    loginLbl.textColor=[UIColor whiteColor];
    [scrlContent addSubview:loginLbl];
    
    NSMutableAttributedString *hintText = [[NSMutableAttributedString alloc] initWithString:@"Already have an account? Sign In here"];
    UIFontDescriptor *fontDescriptor = [UIFontDescriptor fontDescriptorWithName:CGBold size:txtSize];
    UIFontDescriptor *fontDescriptor1 = [UIFontDescriptor fontDescriptorWithName:CGRegular size:txtSize];
    UIFontDescriptor *symbolicFontDescriptor = [fontDescriptor fontDescriptorWithSymbolicTraits:UIFontDescriptorTraitTightLeading];
    
    UIFontDescriptor *symbolicFontDescriptor1 = [fontDescriptor1 fontDescriptorWithSymbolicTraits:UIFontDescriptorTraitBold];
    
    UIFont *fontWithDescriptor = [UIFont fontWithDescriptor:symbolicFontDescriptor size:txtSize];
    UIFont *fontWithDescriptor1 = [UIFont fontWithDescriptor:symbolicFontDescriptor1 size:txtSize];
    
    //Red and large
    [hintText setAttributes:@{NSFontAttributeName:fontWithDescriptor, NSForegroundColorAttributeName:[UIColor whiteColor]} range:NSMakeRange(0, 23)];
    
    //Rest of text -- just futura
    [hintText setAttributes:@{NSFontAttributeName:fontWithDescriptor1, NSForegroundColorAttributeName:[UIColor whiteColor]} range:NSMakeRange(24, hintText.length - 23-5)];
    
    loginLbl.textColor=[UIColor whiteColor];
    [loginLbl setAttributedText:hintText];
    
    UIButton * btnSignUp = [UIButton buttonWithType:UIButtonTypeCustom];
    btnSignUp.frame = CGRectMake(0, DEVICE_HEIGHT-50, DEVICE_WIDTH, 35);
    [btnSignUp addTarget:self action:@selector(btnLoginBack) forControlEvents:UIControlEventTouchUpInside];
    [scrlContent addSubview:btnSignUp];
    
    if (isFromEdit)
    {
        loginLbl.hidden = YES;
    }
    if (IS_IPHONE_4 || IS_IPHONE_5)
    {
        loginLbl.frame =CGRectMake(0, DEVICE_HEIGHT-30, DEVICE_WIDTH, 30);
        btnSignUp.frame = CGRectMake(0, DEVICE_HEIGHT-40, DEVICE_WIDTH, 40);
    }
    if(IS_IPHONE_X)
    {
        loginLbl.frame =CGRectMake(0, DEVICE_HEIGHT-40-55, DEVICE_WIDTH, 35);
        btnSignUp.frame = CGRectMake(0, DEVICE_HEIGHT-40-50, DEVICE_WIDTH, 35);
    }
}
-(void)setupforCountryPicker
{
    [backPickerView removeFromSuperview];
    
    backPickerView = [[UIView alloc] initWithFrame:CGRectMake(0, DEVICE_HEIGHT, DEVICE_WIDTH, 250)];
    [backPickerView setBackgroundColor:[UIColor whiteColor]];
    [self.view addSubview:backPickerView];
    
    [cntryPickerView removeFromSuperview];
    cntryPickerView = nil;
    cntryPickerView.delegate=nil;
    cntryPickerView = [[CountryPicker alloc] initWithFrame:CGRectMake(0, 34, DEVICE_WIDTH, 216)];
    cntryPickerView.delegate=self;
    [cntryPickerView setBackgroundColor:[UIColor blackColor]];
    [backPickerView addSubview:cntryPickerView];
    
    NSString * strCntr = phoneCountryCode;
    NSString * strCntrName = phoneCountryName;
    
    if (isFromEdit == NO)
    {
        codeSignCntry = phoneCountryCode;
        [cntryPickerView setSelectedCountryCode:strCntr animated:YES];

        lblCountry.text = strCntrName;
        if (strCntrName == nil || [strCntrName length]==0 || [strCntrName isEqual:[NSNull null]] || [strCntrName isEqualToString:@"<nil>"])
        {
            phoneCountryCode = @"GB";
            phoneCountryName = @"United Kingdom";
            codeSignCntry = phoneCountryCode;
            lblCountry.text = phoneCountryName;
        }
        NSString *imagePath = [NSString stringWithFormat:@"CountryPicker.bundle/%@",phoneCountryCode];
        imgCountry.image = [UIImage imageNamed:imagePath inBundle:[NSBundle bundleForClass:[cntryPickerView class]] compatibleWithTraitCollection:nil];
    }
    
    UIButton * btnDone2 = [UIButton buttonWithType:UIButtonTypeCustom];
    [btnDone2 setFrame:CGRectMake(0 , 0, DEVICE_WIDTH, 34)];
    [btnDone2 setBackgroundColor:[UIColor groupTableViewBackgroundColor]];
    [btnDone2 setTitle:@"Done" forState:UIControlStateNormal];
    [btnDone2 setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
    [btnDone2 addTarget:self action:@selector(btnDoneClicked:) forControlEvents:UIControlEventTouchUpInside];
    [backPickerView addSubview:btnDone2];
}
-(void)fillForm
{
    userDetailDict = [[NSMutableDictionary alloc] init];
    userDetailDict = [[[NSUserDefaults standardUserDefaults] objectForKey:@"UserDict"] mutableCopy];
    
    if ([[NSUserDefaults standardUserDefaults] valueForKey:@"name"] == nil || [[[NSUserDefaults standardUserDefaults] valueForKey:@"name"] length]==0)
    {
        
    }
    else
    {
        txtName.text = [[NSUserDefaults standardUserDefaults] valueForKey:@"name"];
    }
    
    if ([[NSUserDefaults standardUserDefaults] valueForKey:@"industry"] == nil || [[[NSUserDefaults standardUserDefaults] valueForKey:@"industry"] length]==0)
    {
        
    }
    else
    {
        txtBusiness.text = [[NSUserDefaults standardUserDefaults] valueForKey:@"industry"];
    }

    if ([[NSUserDefaults standardUserDefaults] valueForKey:@"address"] == nil || [[[NSUserDefaults standardUserDefaults] valueForKey:@"address"] length]==0)
    {
        
    }
    else
    {
        txtAddress.text = [[NSUserDefaults standardUserDefaults] valueForKey:@"address"];
    }
    
    if ([[NSUserDefaults standardUserDefaults] valueForKey:@"email"] == nil || [[[NSUserDefaults standardUserDefaults] valueForKey:@"email"] length]==0)
    {
        
    }
    else
    {
        txtEmail.text = [[NSUserDefaults standardUserDefaults] valueForKey:@"email"];
    }
    
    if ([[NSUserDefaults standardUserDefaults] valueForKey:@"phone"] == nil || [[[NSUserDefaults standardUserDefaults] valueForKey:@"phone"] length]==0)
    {
        
    }
    else
    {
        txtMobile.text = [[NSUserDefaults standardUserDefaults] valueForKey:@"phone"];
    }
    if ([[NSUserDefaults standardUserDefaults] valueForKey:@"postCode"] == nil || [[[NSUserDefaults standardUserDefaults] valueForKey:@"postCode"] length]==0)
    {
        
    }
    else
    {
        NSString *countryName = [[NSLocale currentLocale] displayNameForKey:NSLocaleCountryCode value:[[NSUserDefaults standardUserDefaults] valueForKey:@"postCode"]];
        
        codeSignCntry = [[NSUserDefaults standardUserDefaults] valueForKey:@"postCode"];
        //workaround for simulator bug
        if (!countryName)
        {
            countryName = [[NSLocale localeWithLocaleIdentifier:@"en_US"] displayNameForKey:NSLocaleCountryCode value:codeSignCntry];
        }
        lblCountry.text = countryName;
        NSString *imagePath = [NSString stringWithFormat:@"CountryPicker.bundle/%@",codeSignCntry];
        imgCountry.image = [UIImage imageNamed:imagePath inBundle:[NSBundle bundleForClass:[cntryPickerView class]] compatibleWithTraitCollection:nil];

    }
    txtEmail.userInteractionEnabled = NO;
}
#pragma mark - All button click events
-(void)btnBackClick
{
    [self.navigationController popViewControllerAnimated:YES];
}
-(void)CountryClick
{
    if (isFromEdit)
    {
        [cntryPickerView setSelectedCountryCode:codeSignCntry animated:YES];
    }
    [self ShowPicker:YES andView:backPickerView];

}
-(void)btnLoginBack
{
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)btnNextClicked
{
    [self hideKeyboard];
    if([txtName.text isEqualToString:@""])
    {
        [self showMessagewithText:@"Please enter your name"];
    }
    else if([txtBusiness.text isEqualToString:@""])
    {
        [self showMessagewithText:@"Please enter your Business name"];
    }
    else if([txtEmail.text isEqualToString:@""])
    {
        [self showMessagewithText:@"Please enter your email address"];
    }
    else if(![APP_DELEGATE validateEmail:txtEmail.text])
    {
        [self showMessagewithText:@"Please enter valid email address"];
    }
    else if([txtMobile.text isEqualToString:@""])
    {
        [self showMessagewithText:@"Please enter your mobile number"];
    }
    else if([txtMobile.text length]<10)
    {
        [self showMessagewithText:@"Mobile number should at least 10 digits"];
    }
    else if([lblCountry.text isEqualToString:@""])
    {
        [self showMessagewithText:@"Please select your Country"];
    }
    else
    {
        if (isFromEdit)
        {
            if ([APP_DELEGATE isNetworkreachable])
            {
                [self updateProfileService];
            }
            else
            {
                URBAlertView *alertView = [[URBAlertView alloc] initWithTitle:ALERT_TITLE message:@"There is no internet connection. Please connect to internet first then try again later." cancelButtonTitle:OK_BTN otherButtonTitles: nil, nil];
                [alertView setMessageFont:[UIFont fontWithName:CGRegular size:12]];
                [alertView setHandlerBlock:^(NSInteger buttonIndex, URBAlertView *alertView) {
                    [alertView hideWithCompletionBlock:^{
                        
                    }];
                }];
                  [alertView showWithAnimation:Alert_Animation_Type];
        if (IS_IPHONE_X) {[alertView showWithAnimation:URBAlertAnimationDefault];}
            }
        }
        else
        {
            if (isAgreed == NO)
            {
                [self showMessagewithText:@"Please agree to Terms and Conditions."];
            }
            else
            {
                if ([APP_DELEGATE isNetworkreachable])
                {
                    [self RegisterService];
                }
                else
                {
                    URBAlertView *alertView = [[URBAlertView alloc] initWithTitle:ALERT_TITLE message:@"There is no internet connection. Please connect to internet first then try again later." cancelButtonTitle:OK_BTN otherButtonTitles: nil, nil];
                    [alertView setMessageFont:[UIFont fontWithName:CGRegular size:12]];
                    [alertView setHandlerBlock:^(NSInteger buttonIndex, URBAlertView *alertView) {
                        [alertView hideWithCompletionBlock:^{
                            
                        }];
                    }];
                      [alertView showWithAnimation:Alert_Animation_Type];
        if (IS_IPHONE_X) {[alertView showWithAnimation:URBAlertAnimationDefault];}
                }
            }
        }
    }
}
-(void)showMessagewithText:(NSString *)strText
{
    URBAlertView *alertView = [[URBAlertView alloc] initWithTitle:ALERT_TITLE message:strText cancelButtonTitle:OK_BTN otherButtonTitles: nil, nil];
    
    [alertView setMessageFont:[UIFont fontWithName:CGRegular size:14]];
    [alertView setHandlerBlock:^(NSInteger buttonIndex, URBAlertView *alertView) {
        [alertView hideWithCompletionBlock:^{
        }];
    }];
    [alertView showWithAnimation:URBAlertAnimationTopToBottom];
    if (IS_IPHONE_X){[alertView showWithAnimation:URBAlertAnimationDefault];}
}
-(void)RegisterService
{
    [APP_DELEGATE endHudProcess];
    [APP_DELEGATE startHudProcess:@"Registering...."];
    NSString *websrviceName=@"sigup";
    
    NSMutableDictionary * dict = [[NSMutableDictionary alloc]init];
    [dict setValue:txtEmail.text forKey:@"email"];
    [dict setValue:@"123456789" forKey:@"device_token"];
    [dict setValue:txtBusiness.text forKey:@"business_name"];
    [dict setValue:txtName.text forKey:@"name"];
    [dict setValue:txtAddress.text forKey:@"address"];
    [dict setValue:txtMobile.text forKey:@"mobile_no"];
    [dict setValue:codeSignCntry forKey:@"phonecode"];
    [dict setValue:@"ios" forKey:@"device_type"];

    NSString *deviceToken =deviceTokenStr;
    if (deviceToken == nil || deviceToken == NULL)
    {
        [dict setValue:@"sdffds" forKey:@"device_token"];
    }
    else
    {
        [dict setValue:deviceToken forKey:@"device_token"];
    }
    
    URLManager *manager = [[URLManager alloc] init];
    manager.commandName = @"sigup";
    manager.delegate = self;
    NSString *strServerUrl = @"http://succorfish.in/mobile/";
    [manager postUrlCall:[NSString stringWithFormat:@"%@%@",strServerUrl,websrviceName] withParameters:dict];
}
-(void)btnConditions
{
    
}
-(void)agreeClick
{
    if (isAgreed)
    {
        imgCheck.image = [UIImage imageNamed:@"checkEmpty.png"];
        isAgreed = NO;
    }
    else
    {
        imgCheck.image = [UIImage imageNamed:@"checked.png"];
        isAgreed = YES;
    }
}
-(void)updateProfileService
{
    [APP_DELEGATE endHudProcess];
    [APP_DELEGATE startHudProcess:@"Updating details...."];
    
    NSString * strUserId = [userDetailDict valueForKey:@"id"];
    
    NSMutableDictionary * dict = [[NSMutableDictionary alloc]init];
    [dict setValue:txtBusiness.text forKey:@"business_name"];
    [dict setValue:txtName.text forKey:@"name"];
    [dict setValue:txtAddress.text forKey:@"address"];
    [dict setValue:txtMobile.text forKey:@"mobile_no"];
    [dict setValue:strUserId forKey:@"user_id"];
    [dict setValue:codeSignCntry forKey:@"phonecode"];

    
    URLManager *manager = [[URLManager alloc] init];
    manager.commandName = @"UpdateProfile";
    manager.delegate = self;
    NSString *strServerUrl = @"http://succorfish.in/mobile/user/profile/edit";
    [manager postUrlCall:[NSString stringWithFormat:@"%@",strServerUrl] withParameters:dict];
}
#pragma mark - UrlManager Delegate
- (void)onResult:(NSDictionary *)result
{
    [APP_DELEGATE endHudProcess];
    NSLog(@"The result is...%@", result);
    if ([[result valueForKey:@"commandName"] isEqualToString:@"sigup"])
    {
        if ([[[result valueForKey:@"result"] valueForKey:@"response"] isEqualToString:@"true"])
        {
            if ([[[result valueForKey:@"result"] valueForKey:@"message"] isEqualToString:@"You have already signup, Please verify OTP!"])
            {
                    [[NSUserDefaults standardUserDefaults] setObject:[[result valueForKey:@"result"] valueForKey:@"auth_token"] forKey:@"auth_token"];
                    [[NSUserDefaults standardUserDefaults] synchronize];
                    
                    NSMutableDictionary * tmpDict = [[NSMutableDictionary alloc] init];
                    tmpDict = [[[result valueForKey:@"result"] valueForKey:@"data"] mutableCopy];
                
                    NSString * userID = [[[result valueForKey:@"result"] valueForKey:@"data"] valueForKey:@"id"];
                    VerifyVC * verify = [[VerifyVC alloc] init];
                    verify.dataDict = tmpDict;
                    verify.strUserId = userID;
                    [self.navigationController pushViewController:verify animated:YES];
            }
            else
            {
                if([[result valueForKey:@"result"] valueForKey:@"data"]!=[NSNull null] || [[result valueForKey:@"result"] valueForKey:@"data"] != nil)
                {
                    [[NSUserDefaults standardUserDefaults] setObject:[[result valueForKey:@"result"] valueForKey:@"auth_token"] forKey:@"auth_token"];
                    [[NSUserDefaults standardUserDefaults] synchronize];
                    
                    NSString * userID = [[[result valueForKey:@"result"] valueForKey:@"data"] valueForKey:@"id"];

                    NSMutableDictionary * tmpDict = [[NSMutableDictionary alloc] init];
                    tmpDict = [[[result valueForKey:@"result"] valueForKey:@"data"] mutableCopy];
                    VerifyVC * verify = [[VerifyVC alloc] init];
                    verify.strUserId = userID;
                    verify.dataDict = tmpDict;
                    [self.navigationController pushViewController:verify animated:YES];
                }
                else
                {
                    URBAlertView *alertView = [[URBAlertView alloc] initWithTitle:ALERT_TITLE message:@"Something went wrong. Please try again later." cancelButtonTitle:OK_BTN otherButtonTitles: nil, nil];
                    
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
        else
        {
            NSString * strMsg = [[result valueForKey:@"result"] valueForKey:@"message"];
            URBAlertView *alertView = [[URBAlertView alloc] initWithTitle:ALERT_TITLE message:strMsg cancelButtonTitle:OK_BTN otherButtonTitles: nil, nil];
            
            [alertView setMessageFont:[UIFont fontWithName:CGRegular size:14]];
            [alertView setHandlerBlock:^(NSInteger buttonIndex, URBAlertView *alertView) {
                [alertView hideWithCompletionBlock:^{
                }];
            }];
            [alertView showWithAnimation:URBAlertAnimationTopToBottom];
    if (IS_IPHONE_X){[alertView showWithAnimation:URBAlertAnimationDefault];}
        }
    }
    else if ([[result valueForKey:@"commandName"] isEqualToString:@"UpdateProfile"])
    {
        if ([[[result valueForKey:@"result"] valueForKey:@"response"] isEqualToString:@"true"])
        {
            [self updateAllfields];
            URBAlertView *alertView = [[URBAlertView alloc] initWithTitle:ALERT_TITLE message:@"Profile has been updated successfully." cancelButtonTitle:OK_BTN otherButtonTitles: nil, nil];
            
            [alertView setMessageFont:[UIFont fontWithName:CGRegular size:14]];
            [alertView setHandlerBlock:^(NSInteger buttonIndex, URBAlertView *alertView) {
                [alertView hideWithCompletionBlock:^{
                    [self.navigationController popViewControllerAnimated:YES];
                }];
            }];
            [alertView showWithAnimation:URBAlertAnimationTopToBottom];
    if (IS_IPHONE_X){[alertView showWithAnimation:URBAlertAnimationDefault];}

        }
        else
        {
            NSString * strMsg = [[result valueForKey:@"result"] valueForKey:@"message"];
            URBAlertView *alertView = [[URBAlertView alloc] initWithTitle:ALERT_TITLE message:strMsg cancelButtonTitle:OK_BTN otherButtonTitles: nil, nil];
            
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
- (void)onError:(NSError *)error
{
    [APP_DELEGATE endHudProcess];

    NSLog(@"The error is...%@", error);
    
    [btnNext setEnabled:YES];
    
    NSInteger ancode = [error code];
    
    NSMutableDictionary * errorDict = [error.userInfo mutableCopy];
    NSLog(@"errorDict===%@",errorDict);
    
    if (ancode == -1001 || ancode == -1004 || ancode == -1005 || ancode == -1009) {
        [APP_DELEGATE ShowErrorPopUpWithErrorCode:ancode andMessage:@""];
    } else {
        [APP_DELEGATE ShowErrorPopUpWithErrorCode:customErrorCodeForMessage andMessage:@"Please try again later"];
    }
    
    
    NSString * strLoginUrl = [NSString stringWithFormat:@"%@%@",WEB_SERVICE_URL,@"token.json"];
    if ([[errorDict valueForKey:@"NSErrorFailingURLStringKey"] isEqualToString:strLoginUrl])
    {
        NSLog(@"NSErrorFailingURLStringKey===%@",[errorDict valueForKey:@"NSErrorFailingURLStringKey"]);
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)btnDoneClicked:(id)sender
{
    [self ShowPicker:NO andView:backPickerView];
}

#pragma mark - Animations
-(void)ShowPicker:(BOOL)isShow andView:(UIView *)myView
{
    if (isShow == YES)
    {
        [UIView transitionWithView:myView duration:0.4
                           options:UIViewAnimationOptionCurveEaseIn
                        animations:^{
                            
                            [myView setFrame:CGRectMake(0, DEVICE_HEIGHT-250,DEVICE_WIDTH, 250)];
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
                            [myView setFrame:CGRectMake(0, DEVICE_HEIGHT, DEVICE_WIDTH, 250)];
                        }
                        completion:^(BOOL finished)
         {
         }];
    }
}

- (void)countryPicker:(__unused CountryPicker *)picker didSelectCountryWithName:(NSString *)name code:(NSString *)code withImg:(NSInteger)imgCode
{
//    imgCountry.image = imgCode;
    lblCountry.text = name;
    
    NSString *imagePath = [NSString stringWithFormat:@"CountryPicker.bundle/%@",code];

    codeSignCntry = code;
    imgCountry.image = [UIImage imageNamed:imagePath inBundle:[NSBundle bundleForClass:[picker class]] compatibleWithTraitCollection:nil];

//    self.nameLabel.text = name;
//    self.codeLabel.text = code;
}

#pragma mark - Hide Keyboard
-(void)hideKeyboard
{
    [self.inputView resignFirstResponder];
}
#pragma mark - Textfield Delegates
-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [self hideKeyboard];
    if (textField == txtName)
    {
        [txtBusiness becomeFirstResponder];
    }
    else if (textField == txtBusiness)
    {
        [txtAddress becomeFirstResponder];
    }
    else if (textField == txtAddress)
    {
        if (isFromEdit)
        {
            [txtMobile becomeFirstResponder];
        }
        else
        {
            [txtEmail becomeFirstResponder];
        }
    }
    else if (textField == txtEmail)
    {
        [txtMobile becomeFirstResponder];
    }
    else if (textField == txtMobile)
    {
        [textField resignFirstResponder];
    }
    return YES;
}

-(void)textFieldDidBeginEditing:(UITextField *)textField
{
    
    if (textField== txtName || textField == txtBusiness || textField == txtAddress || textField == txtEmail)
    {
        [UIView animateWithDuration:0.3 animations:^{
            if (IS_IPHONE_4)
            {
                [viewPopUp setFrame:CGRectMake(15, DEVICE_HEIGHT/2-160-70, DEVICE_WIDTH-30, 400)];
            }
        }];
    }
    else
    {
        if (IS_IPHONE_4 || IS_IPHONE_5 || IS_IPHONE_6)
        {
            if (textField == txtMobile)
            {
                [UIView animateWithDuration:0.3 animations:^{
                    [viewPopUp setFrame:CGRectMake(15, (heightKeyBrd-txtMobile.frame.origin.y)-45-50, DEVICE_WIDTH-30, 400)];
                }];
            }
        }
    }
    lblLine = [[UILabel alloc] initWithFrame:CGRectMake(0, textField.frame.size.height-2, textField.frame.size.width, 2)];
    [lblLine setBackgroundColor:[UIColor whiteColor]];
    [textField addSubview:lblLine];
    
    if (textField == txtMobile)
    {
        UIToolbar* numberToolbar = [[UIToolbar alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 50)];
        numberToolbar.barStyle =  UIBarStyleDefault;
        UIBarButtonItem *space =[[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
        UIBarButtonItem *Done = [[UIBarButtonItem alloc]initWithTitle:@"Done" style:UIBarButtonItemStyleDone target:self action:@selector(doneKeyBoarde)];
        Done.tintColor=[APP_DELEGATE colorWithHexString:App_Header_Color];
        numberToolbar.items = [NSArray arrayWithObjects:space,Done,
                               nil];
        [numberToolbar sizeToFit];
        textField.inputAccessoryView = numberToolbar;
    }
}

-(void)textFieldDidEndEditing:(UITextField *)textField
{
    if (textField== txtName || textField == txtBusiness || textField == txtAddress || textField == txtEmail)
    {
        [UIView animateWithDuration:0.3 animations:^{
            if (IS_IPHONE_4)
            {
                if (isFromEdit)
                {
                    [viewPopUp setFrame:CGRectMake(15, 75, DEVICE_WIDTH-30, 400-30)];
                }
                else
                {
                    [viewPopUp setFrame:CGRectMake(15, 50, DEVICE_WIDTH-30, 400-0)];
                }
            }
        }];
    }
    [lblLine removeFromSuperview];
}
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if (textField == txtMobile)
    {
        if(range.length + range.location > textField.text.length)
        {
            return NO;
        }
        NSUInteger newLength = [textField.text length] + [string length] - range.length;
        if(newLength <= 15)
        {
            if ([string isEqualToString:@","] || [string isEqualToString:@";"] || [string isEqualToString:@"*"] || [string isEqualToString:@"#"])
            {
                return NO;
            }
            else
            {
                return YES;
            }
        }
        else
        {
            return  NO;
        }
    }
    else
    {
        return YES;
    }
}
-(void)doneKeyBoarde
{
    if (IS_IPHONE_X)
    {
        
    }
    else
    {
        int fixHeight = 115;
        if (isFromEdit)
        {
            fixHeight = 75;
        }
        if (IS_IPHONE_4)
        {
            viewPopUp.frame = CGRectMake(15, 50, DEVICE_WIDTH-30, 400);
            if (isFromEdit)
            {
                viewPopUp.frame = CGRectMake(15, 75, DEVICE_WIDTH-30, 400-30);
            }
        }
        else if (IS_IPHONE_5)
        {
            viewPopUp.frame = CGRectMake(15, 115*approaxSize, DEVICE_WIDTH-30, 400);
        }
        else
        {
            [viewPopUp setFrame:CGRectMake(15, (fixHeight+10)*approaxSize, DEVICE_WIDTH-30, 400*approaxSize)];
        }
    }
   
    [txtMobile resignFirstResponder];
}

-(void)updateAllfields
{
    [userDetailDict setValue:txtBusiness.text forKey:@"business_name"];
    [userDetailDict setValue:txtName.text forKey:@"name"];
    [userDetailDict setValue:txtAddress.text forKey:@"address"];
    [userDetailDict setValue:txtMobile.text forKey:@"mobile_no"];
    [userDetailDict setValue:codeSignCntry forKey:@"phonecode"];
    
    [[NSUserDefaults standardUserDefaults] setObject:userDetailDict forKey:@"UserDict"];
    [[NSUserDefaults standardUserDefaults] synchronize];

}

- (BOOL)validatePhone:(NSString *)phoneNumber
{
    NSString *phoneRegex = @"^((\\+)|(00))[0-9]{6,14}$";
    NSPredicate *phoneTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", phoneRegex];
    
    return [phoneTest evaluateWithObject:phoneNumber];
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
