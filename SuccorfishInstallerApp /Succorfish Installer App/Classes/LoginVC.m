//
//  LoginVC.m
//  Succorfish Installer App
//
//  Created by stuart watts on 19/02/2018.
//  Copyright © 2018 Kalpesh Panchasara. All rights reserved.
//

#import "LoginVC.h"
#import "SignupVC.h"
#import <MessageUI/MessageUI.h>

@interface LoginVC ()<MFMailComposeViewControllerDelegate>
{
    int txtSizse;
}
@end

@implementation LoginVC

- (void)viewDidLoad
{
    txtSizse = 16;
    if (IS_IPHONE_4 || IS_IPHONE_5)
    {
        txtSizse = 15;
    }
    
    self.title = @"Login";

    UIImageView * imgBack = [[UIImageView alloc] init];
    imgBack.frame = CGRectMake(0, 0, DEVICE_WIDTH, DEVICE_HEIGHT);
    imgBack.image = [UIImage imageNamed:@"Splash_bg.png"];
    [self.view addSubview:imgBack];

    isShowPassword = NO;
    
    [self setContentViewFrames];

    

    
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}
#pragma mark - Set UI frames
-(void)setContentViewFrames
{
    scrlContent = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, DEVICE_WIDTH, DEVICE_HEIGHT)];
    scrlContent.showsVerticalScrollIndicator = NO;
    [self.view addSubview:scrlContent];
    
    UILabel * lblName =  [[UILabel alloc] init];
    lblName.frame = CGRectMake(15, 30, DEVICE_WIDTH-30, 30);
    lblName.textAlignment = NSTextAlignmentCenter;
    lblName.textColor = [UIColor whiteColor];
    lblName.text = @"Sign in";
    lblName.font = [UIFont fontWithName:CGRegular size:txtSizse];
    [scrlContent addSubview:lblName];
    
    UIImageView * imgLogo = [[UIImageView alloc] initWithFrame:CGRectMake((DEVICE_WIDTH-(170*approaxSize))/2, 87*approaxSize, 170*approaxSize, 34*approaxSize)];
    [imgLogo setImage:[UIImage imageNamed:@"logo.png"]];
    [imgLogo setClipsToBounds:YES];
    [imgLogo setContentMode:UIViewContentModeScaleAspectFit];
    [scrlContent addSubview:imgLogo];
    
   
    viewPopUp = [[UIView alloc] initWithFrame:CGRectMake(15, 150*approaxSize,DEVICE_WIDTH-30,300*approaxSize)];
    [viewPopUp setBackgroundColor:[UIColor clearColor]];
    viewPopUp.layer.shadowColor = [UIColor darkGrayColor].CGColor;
    viewPopUp.layer.shadowOffset = CGSizeMake(0.1, 0.1);
    viewPopUp.layer.shadowRadius = 25;
    viewPopUp.layer.shadowOpacity = 0.5;
    [scrlContent addSubview:viewPopUp];
    
    if (IS_IPHONE_4)
    {
        imgLogo.frame = CGRectMake((DEVICE_WIDTH-204)/2, 25, 204, 42);
        viewPopUp.frame = CGRectMake(15, 110, DEVICE_WIDTH-30, 300);
        lblName.hidden = YES;
    }
    
    int yy = 30;
    
    UIImageView * imgPopUpBG = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, viewPopUp.frame.size.width, viewPopUp.frame.size.height)];
    [imgPopUpBG setBackgroundColor:[UIColor blackColor]];
    imgPopUpBG.alpha = 0.7;
    imgPopUpBG.layer.cornerRadius = 10;
    [viewPopUp addSubview:imgPopUpBG];
    
    UIBezierPath *shadowPath = [UIBezierPath bezierPathWithRect:imgPopUpBG.bounds];
    imgPopUpBG.layer.masksToBounds = NO;
    imgPopUpBG.layer.shadowColor = [UIColor whiteColor].CGColor;
    imgPopUpBG.layer.shadowOffset = CGSizeMake(0.0f, 1.0f);
    imgPopUpBG.layer.shadowOpacity = 0.5f;
    imgPopUpBG.layer.shadowPath = shadowPath.CGPath;
    
    txtEmail = [[UITextField alloc] initWithFrame:CGRectMake(15, yy, viewPopUp.frame.size.width-30, 35)];
    txtEmail.placeholder = @"Username";
    txtEmail.autocapitalizationType = UITextAutocapitalizationTypeNone;
    txtEmail.delegate = self;
    txtEmail.autocorrectionType = UITextAutocorrectionTypeNo;
    txtEmail.keyboardType = UIKeyboardTypeEmailAddress;
    txtEmail.textColor = [UIColor whiteColor];
    [txtEmail setFont:[UIFont fontWithName:CGRegular size:txtSizse]];
    [APP_DELEGATE getPlaceholderText:txtEmail andColor:UIColor.whiteColor];
    txtEmail.returnKeyType  = UIReturnKeyNext;
    [viewPopUp addSubview:txtEmail];
    
    UILabel * lblEmailLine = [[UILabel alloc] initWithFrame:CGRectMake(0, txtEmail.frame.size.height-2, txtEmail.frame.size.width, 1)];
    [lblEmailLine setBackgroundColor:[UIColor lightGrayColor]];
    [txtEmail addSubview:lblEmailLine];
    
    yy = yy+60;
    
    txtPassword = [[UITextField alloc] initWithFrame:CGRectMake(15, yy, viewPopUp.frame.size.width-30, 35)];
    txtPassword.placeholder = @"Password";
    txtPassword.delegate = self;
    txtPassword.secureTextEntry = YES;
    txtPassword.autocapitalizationType = UITextAutocapitalizationTypeNone;
    txtPassword.textColor = [UIColor whiteColor];
    [txtPassword setFont:[UIFont fontWithName:CGRegular size:txtSizse]];
    [APP_DELEGATE getPlaceholderText:txtPassword andColor:UIColor.whiteColor];
    txtPassword.returnKeyType  = UIReturnKeyDone;
    [viewPopUp addSubview:txtPassword];
    
    UILabel * lblPasswordLine = [[UILabel alloc] initWithFrame:CGRectMake(0, txtPassword.frame.size.height-2, txtPassword.frame.size.width,1)];
    [lblPasswordLine setBackgroundColor:[UIColor lightGrayColor]];
    [txtPassword addSubview:lblPasswordLine];
    
    
    btnShowPass = [UIButton buttonWithType:UIButtonTypeCustom];
    btnShowPass.frame = CGRectMake(viewPopUp.frame.size.width-60, yy, 60, 35);
    btnShowPass.backgroundColor = [UIColor clearColor];
    [btnShowPass addTarget:self action:@selector(showPassclick) forControlEvents:UIControlEventTouchUpInside];
    [btnShowPass setImage:[UIImage imageNamed:@"passShow.png"] forState:UIControlStateNormal];
    [viewPopUp addSubview:btnShowPass];
    
    yy = yy+50*approaxSize;
    
    imgCheck = [[UIImageView alloc] init];
    imgCheck.image = [UIImage imageNamed:@"checkEmpty.png"];
    imgCheck.frame = CGRectMake(15, yy+5, 20, 20);
    [viewPopUp addSubview:imgCheck];
    
    UILabel * lblRemember =  [[UILabel alloc] init];
    lblRemember.frame = CGRectMake(45, yy, DEVICE_WIDTH-30, 30);
//    lblRemember.textAlignment = NSTextAlignmentCenter;
    lblRemember.textColor = [UIColor whiteColor];
    lblRemember.text = @"Remember Me";
    [lblRemember setFont:[UIFont fontWithName:CGRegular size:txtSizse-1]];
    [viewPopUp addSubview:lblRemember];
    
    btnRemember = [UIButton buttonWithType:UIButtonTypeCustom];
    [btnRemember setFrame:CGRectMake(0, yy, viewPopUp.frame.size.width, 44)];
    [btnRemember addTarget:self action:@selector(btnRememberClick) forControlEvents:UIControlEventTouchUpInside];
    btnRemember.backgroundColor = [UIColor clearColor];
    [viewPopUp addSubview:btnRemember];
    
    yy = yy+45*approaxSize;

    
    btnLogin = [UIButton buttonWithType:UIButtonTypeCustom];
    [btnLogin setFrame:CGRectMake(15, yy, viewPopUp.frame.size.width-30, 44)];
    [btnLogin setTitle:@"Login" forState:UIControlStateNormal];
    [btnLogin setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [btnLogin.titleLabel setFont:[UIFont fontWithName:CGRegular size:txtSizse]];
    [btnLogin addTarget:self action:@selector(btnLoginClicked) forControlEvents:UIControlEventTouchUpInside];
    [viewPopUp addSubview:btnLogin];
    [btnLogin setBackgroundImage:[UIImage imageNamed:@"BTN.png"] forState:UIControlStateNormal];
    
    activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    [activityIndicator setFrame:CGRectMake(btnLogin.frame.size.width-40, 5, 30, 30)];
    [btnLogin addSubview:activityIndicator];
  
    
    yy = yy+65*approaxSize;
    
    btnForgotPassword = [UIButton buttonWithType:UIButtonTypeSystem];
    [btnForgotPassword setFrame:CGRectMake(40, yy, viewPopUp.frame.size.width-80, 40)];
    [btnForgotPassword setTitle:@"Forgot your password?" forState:UIControlStateNormal];
    [btnForgotPassword setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [btnForgotPassword setBackgroundColor:[UIColor clearColor]];
    [btnForgotPassword addTarget:self action:@selector(btnForgotPasswordClicked) forControlEvents:UIControlEventTouchUpInside];
    [btnForgotPassword.titleLabel setFont:[UIFont fontWithName:CGBold size:txtSizse]];
    [viewPopUp addSubview:btnForgotPassword];
    
   /* UILabel * loginLbl =[[UILabel alloc] initWithFrame:CGRectMake(0, DEVICE_HEIGHT-55, DEVICE_WIDTH, 35)];
    loginLbl.font=[UIFont fontWithName:CGRegular size:txtSizse];
    loginLbl.textAlignment=NSTextAlignmentCenter;
    loginLbl.textColor=[UIColor whiteColor];
    [scrlContent addSubview:loginLbl];
    
    NSMutableAttributedString *hintText = [[NSMutableAttributedString alloc] initWithString:@"Don't have an account? Sign Up here"];
    UIFontDescriptor *fontDescriptor = [UIFontDescriptor fontDescriptorWithName:CGRegular size:txtSizse];
    UIFontDescriptor *fontDescriptor1 = [UIFontDescriptor fontDescriptorWithName:CGBold size:txtSizse];
    UIFontDescriptor *symbolicFontDescriptor = [fontDescriptor fontDescriptorWithSymbolicTraits:UIFontDescriptorTraitTightLeading];
    
    UIFontDescriptor *symbolicFontDescriptor1 = [fontDescriptor1 fontDescriptorWithSymbolicTraits:UIFontDescriptorTraitBold];
    
    UIFont *fontWithDescriptor = [UIFont fontWithDescriptor:symbolicFontDescriptor size:txtSizse];
    UIFont *fontWithDescriptor1 = [UIFont fontWithDescriptor:symbolicFontDescriptor1 size:txtSizse];
    
    //Red and large
    [hintText setAttributes:@{NSFontAttributeName:fontWithDescriptor, NSForegroundColorAttributeName:[UIColor whiteColor]} range:NSMakeRange(0, 24)];
    
    //Rest of text -- just futura
    [hintText setAttributes:@{NSFontAttributeName:fontWithDescriptor1, NSForegroundColorAttributeName:[UIColor whiteColor]} range:NSMakeRange(23, hintText.length - 23-5)];
    
    loginLbl.textColor=[UIColor whiteColor];
    [loginLbl setAttributedText:hintText];
    
    UIButton * btnSignUp = [UIButton buttonWithType:UIButtonTypeCustom];
    btnSignUp.frame = CGRectMake(0, DEVICE_HEIGHT-50, DEVICE_WIDTH, 35);
    [btnSignUp addTarget:self action:@selector(btnSignupClick) forControlEvents:UIControlEventTouchUpInside];
    [scrlContent addSubview:btnSignUp];
    
    if(IS_IPHONE_X)
    {
    loginLbl.frame =CGRectMake(0, DEVICE_HEIGHT-40-55, DEVICE_WIDTH, 35);
    btnSignUp.frame = CGRectMake(0, DEVICE_HEIGHT-40-50, DEVICE_WIDTH, 35);
    lblName.frame = CGRectMake(15, 40, DEVICE_WIDTH-30, 30);
    }
    */
    
    if (CURRENT_USER_EMAIL != [NSNull null])
    {
        if (CURRENT_USER_EMAIL != nil && CURRENT_USER_EMAIL != NULL && ![CURRENT_USER_EMAIL isEqualToString:@""])
        {
            txtEmail.text = CURRENT_USER_EMAIL;
        }
    }
    if ([[[NSUserDefaults standardUserDefaults] valueForKey:@"IsRemember"] isEqualToString:@"Yes"])
    {
        if (CURRENT_USER_PASS != [NSNull null])
        {
            if (CURRENT_USER_PASS != nil && CURRENT_USER_PASS != NULL && ![CURRENT_USER_PASS isEqualToString:@""])
            {
                txtPassword.text = CURRENT_USER_PASS;
                imgCheck.image = [UIImage imageNamed:@"checked.png"];
            }
        }
    }
    
   
}


#pragma mark - ButtonClickevents
-(void)btnLoginClicked
{
    [self hideKeyboard];
    if ([txtEmail.text isEqualToString:@""])
    {
        URBAlertView *alertView = [[URBAlertView alloc] initWithTitle:ALERT_TITLE message:@"Please enter your username" cancelButtonTitle:OK_BTN otherButtonTitles: nil, nil];
        [alertView setMessageFont:[UIFont fontWithName:CGRegular size:12]];
        [alertView setHandlerBlock:^(NSInteger buttonIndex, URBAlertView *alertView) {
            [alertView hideWithCompletionBlock:^{
                
            }];
        }];
          [alertView showWithAnimation:Alert_Animation_Type];
        if (IS_IPHONE_X) {[alertView showWithAnimation:URBAlertAnimationDefault];}
    }
    else if ([txtPassword.text isEqualToString:@""])
    {
        URBAlertView *alertView = [[URBAlertView alloc] initWithTitle:ALERT_TITLE message:@"Please enter your password" cancelButtonTitle:OK_BTN otherButtonTitles: nil, nil];
        [alertView setMessageFont:[UIFont fontWithName:CGRegular size:12]];
        [alertView setHandlerBlock:^(NSInteger buttonIndex, URBAlertView *alertView) {
            [alertView hideWithCompletionBlock:^{
                
            }];
        }];
          [alertView showWithAnimation:Alert_Animation_Type];
        if (IS_IPHONE_X) {[alertView showWithAnimation:URBAlertAnimationDefault];}
    }
    else
    {
        if ([APP_DELEGATE isNetworkreachable])
        {
            [self VerifyUserWithServer];
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
-(void)btnForgotPasswordClicked
{
    [self hideKeyboard];
    [self setMoreBtnPopUp];
}
-(void)btnSignupClick
{
    SignupVC * signVC = [[SignupVC alloc] init];
    [self.navigationController pushViewController:signVC animated:YES];
}
-(void)showPassclick
{
    if (isShowPassword)
    {
        isShowPassword = NO;
        [btnShowPass setImage:[UIImage imageNamed:@"passShow.png"] forState:UIControlStateNormal];
        txtPassword.secureTextEntry = YES;
    }
    else
    {
        isShowPassword = YES;
        [btnShowPass setImage:[UIImage imageNamed:@"visible.png"] forState:UIControlStateNormal];
        txtPassword.secureTextEntry = NO;
    }
}
-(void)btnRememberClick
{
    if ([[[NSUserDefaults standardUserDefaults] valueForKey:@"IsRemember"] isEqualToString:@"Yes"])
    {
        [[NSUserDefaults standardUserDefaults] setValue:@"No" forKey:@"IsRemember"];
        imgCheck.image = [UIImage imageNamed:@"checkEmpty.png"];
    }
    else
    {
        [[NSUserDefaults standardUserDefaults] setValue:@"Yes" forKey:@"IsRemember"];
        imgCheck.image = [UIImage imageNamed:@"checked.png"];
    }
    [[NSUserDefaults standardUserDefaults] synchronize];
}
-(void)btnCallClick
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
-(void)btnMailClick
{
    
    // Email Subject
    NSString *emailTitle = @"Forgot password";
    // Email Content
    
    // To address
    NSArray *toRecipents = [NSArray arrayWithObject:@"tom@succorfish.com"];
    
    MFMailComposeViewController *mc = [[MFMailComposeViewController alloc] init];
    mc.mailComposeDelegate = self;
    [mc setSubject:emailTitle];
    [mc setMessageBody:@"" isHTML:NO];
    [mc setToRecipients:toRecipents];
    
    if (mc == nil)
    {
        URBAlertView *alertView = [[URBAlertView alloc] initWithTitle:ALERT_TITLE message:@"Please set up a Mail account in order to send email." cancelButtonTitle:OK_BTN otherButtonTitles: nil, nil];
        
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
        [self.navigationController presentViewController:mc animated:YES completion:nil];
    }
}

- (void) mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
    switch (result)
    {
        case MFMailComposeResultCancelled:
            NSLog(@"Mail cancelled");
            break;
        case MFMailComposeResultSaved:
            NSLog(@"Mail saved");
            break;
        case MFMailComposeResultSent:
            NSLog(@"Mail sent");
            break;
        case MFMailComposeResultFailed:
            NSLog(@"Mail sent failure: %@", [error localizedDescription]);
            break;
        default:
            break;
    }
    
    // Close the Mail Interface
    [self dismissViewControllerAnimated:YES completion:NULL];
}
#pragma mark - Set Custom ActionSheet
-(void)setMoreBtnPopUp
{
    [viewOverLay removeFromSuperview];
    viewOverLay = [[UIView alloc] initWithFrame:CGRectMake(0, 0, DEVICE_WIDTH, DEVICE_HEIGHT)];
    [self.view addSubview:viewOverLay];
    
    backView = [[UIView alloc] init];
    backView.frame = CGRectMake(0, 0, DEVICE_WIDTH, DEVICE_HEIGHT);
    backView.backgroundColor = [UIColor blackColor];
    [backView setAlpha:0.4];
    [viewOverLay addSubview:backView];
    
    UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(OverLayTaped:)];
    tapRecognizer.numberOfTapsRequired=1;
    [viewOverLay addGestureRecognizer:tapRecognizer];
    
    [viewMore removeFromSuperview];
    viewMore = [[UIView alloc] initWithFrame:CGRectMake(20, DEVICE_HEIGHT, self.view.frame.size.width-40, 280+20+20+10)];
    [viewMore setBackgroundColor:[UIColor blackColor]];
    viewMore.layer.shadowColor = [UIColor darkGrayColor].CGColor;
    viewMore.layer.shadowOffset = CGSizeMake(0.1, 0.1);
    viewMore.layer.shadowRadius = 3;
    viewMore.layer.shadowOpacity = 0.5;
    [viewOverLay addSubview:viewMore];
    
    UIBezierPath *shadowPath = [UIBezierPath bezierPathWithRect:viewMore.bounds];
    viewMore.layer.masksToBounds = NO;
    viewMore.layer.shadowColor = [UIColor lightGrayColor].CGColor;
    viewMore.layer.shadowOffset = CGSizeMake(0.0f, 1.0f);
    viewMore.layer.shadowOpacity = 0.2f;
    viewMore.layer.shadowPath = shadowPath.CGPath;
    
    btncancel =[UIButton buttonWithType:UIButtonTypeCustom];
    [btncancel setFrame:CGRectMake(viewMore.frame.size.width-50,0, 50, 40)];
    btncancel.backgroundColor = [UIColor clearColor];
    [btncancel setImage:[UIImage imageNamed:@"wClose.png"] forState:UIControlStateNormal];
    [btncancel addTarget:self action:@selector(AlertCancleClicked:) forControlEvents:UIControlEventTouchUpInside];
    [viewMore addSubview:btncancel];
    
    int yy = 10;
    
    UILabel *lblTitle =[[UILabel alloc]initWithFrame:CGRectMake(0, 10, viewMore.frame.size.width, 20)];
    lblTitle.text= @"Forgot Password ?";
    lblTitle.textColor=[UIColor darkGrayColor];
    lblTitle.textAlignment=NSTextAlignmentCenter;
    lblTitle.clipsToBounds=NO;
    [lblTitle setFont:[UIFont fontWithName:CGRegular size:txtSizse]];
    lblTitle.shadowOffset= CGSizeMake(0.0, -1.0);
    lblTitle.shadowColor=[UIColor clearColor];
    [viewMore addSubview:lblTitle];
    
    yy = yy+25+5;
    
    UILabel *lblmessage =[[UILabel alloc]initWithFrame:CGRectMake(5, yy, viewMore.frame.size.width-10, 25)];
    lblmessage.text= @"Contact us on";
    lblmessage.textColor=[UIColor lightGrayColor];
    lblmessage.textAlignment=NSTextAlignmentCenter;
    lblmessage.clipsToBounds=NO;
    lblmessage.shadowOffset= CGSizeMake(0.0, -1.0);
    lblmessage.shadowColor=[UIColor clearColor];
    [lblmessage setFont:[UIFont fontWithName:CGRegular size:txtSizse-1]];
    [viewMore addSubview:lblmessage];
    
    yy = yy+25+5;

    UILabel *lblNumber =[[UILabel alloc]initWithFrame:CGRectMake(5, yy, viewMore.frame.size.width-10, 25)];
    lblNumber.text= @"+44 191 4476883";
    lblNumber.textColor=[UIColor redColor];
    lblNumber.textAlignment=NSTextAlignmentCenter;
    [lblNumber setFont:[UIFont fontWithName:CGRegular size:txtSizse+1]];
    [viewMore addSubview:lblNumber];
    
    yy = yy+25+5;

    UIButton * btnCall =[UIButton buttonWithType:UIButtonTypeSystem];
    [btnCall setFrame:CGRectMake(20, yy, viewMore.frame.size.width-40, 44)];
    [btnCall setTitle:@"Call Us" forState:UIControlStateNormal];
    [btnCall setBackgroundColor:[UIColor blackColor]];
    [btnCall setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    btnCall.layer.borderWidth=0.5;
    btnCall.layer.borderColor=[UIColor darkGrayColor].CGColor;
    btnCall.titleLabel.font = [UIFont fontWithName:CGRegular size:txtSizse];
    [btnCall addTarget:self action:@selector(btnCallClick) forControlEvents:UIControlEventTouchUpInside];
    [viewMore addSubview:btnCall];
    
    yy = yy+25+5+ 44;

    UILabel * lblEmailLine = [[UILabel alloc] initWithFrame:CGRectMake(5,yy,viewMore.frame.size.width-10,1)];
    [lblEmailLine setBackgroundColor:[UIColor grayColor]];
    [viewMore addSubview:lblEmailLine];
    
    UILabel *lblOr =[[UILabel alloc]initWithFrame:CGRectMake((viewMore.frame.size.width-25)/2, yy-12.5, 25, 25)];
    lblOr.text= @"Or";
    lblOr.textColor=[UIColor whiteColor];
    lblOr.textAlignment=NSTextAlignmentCenter;
    [lblOr setFont:[UIFont fontWithName:CGRegular size:txtSizse]];
    lblOr.layer.cornerRadius = 12.5;
    lblOr.layer.masksToBounds = YES;
    lblOr.backgroundColor = [UIColor blackColor];
    [viewMore addSubview:lblOr];
    
    yy = yy+25;
    
    UILabel * lblMailHint =[[UILabel alloc]initWithFrame:CGRectMake(5, yy, viewMore.frame.size.width-10, 25)];
    lblMailHint.textAlignment=NSTextAlignmentCenter;
    [lblMailHint setFont:[UIFont fontWithName:CGRegular size:txtSizse-1]];
    lblMailHint.textColor=[UIColor lightGrayColor];
    lblMailHint.text=@"write mail us on";
    [viewMore addSubview:lblMailHint];
    
    yy = yy+25+5;

    UILabel * lblMail =[[UILabel alloc]initWithFrame:CGRectMake(5, yy, viewMore.frame.size.width-10, 25)];
    lblMail.textAlignment=NSTextAlignmentCenter;
    [lblMail setFont:[UIFont fontWithName:CGRegular size:txtSizse+1]];
    lblMail.textColor=[UIColor redColor];
    lblMail.text=@"tom@succorfish.com";
    [viewMore addSubview:lblMail];
    
    yy = yy+25+5;

    UIButton * btnMail =[UIButton buttonWithType:UIButtonTypeSystem];
    [btnMail setFrame:CGRectMake(20, yy, viewMore.frame.size.width-40, 44)];
    [btnMail setTitle:@"Mail Us" forState:UIControlStateNormal];
    [btnMail setBackgroundColor:[UIColor blackColor]];
    [btnMail setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    btnMail.layer.borderWidth=0.5;
    btnMail.layer.borderColor=[UIColor darkGrayColor].CGColor;
    btnMail.titleLabel.font = [UIFont fontWithName:CGRegular size:txtSizse];
    [btnMail addTarget:self action:@selector(btnMailClick) forControlEvents:UIControlEventTouchUpInside];
    [viewMore addSubview:btnMail];
    
    [self hideMorePopUpView:NO];
}
-(void)hideMorePopUpView:(BOOL)isHide
{
    [txtForgotpasswordEmail resignFirstResponder];
    
    if (isHide == YES)
    {
        [UIView animateWithDuration:0.4
                              delay:0.0
                            options: UIViewAnimationOptionOverrideInheritedCurve
                         animations:^{
                             viewMore.frame = CGRectMake(20, DEVICE_HEIGHT , DEVICE_WIDTH-40, viewMore.frame.size.height);
                         }
                         completion:^(BOOL finished){
                             [viewMore removeFromSuperview];
                             [viewOverLay removeFromSuperview];
                         }];
    }
    else
    {
        [UIView animateWithDuration:0.5 delay:0.0 options: UIViewAnimationOptionOverrideInheritedCurve
                         animations:^{
                             viewMore.frame = CGRectMake(20, (DEVICE_HEIGHT-(viewMore.frame.size.height))/2 , DEVICE_WIDTH-40, viewMore.frame.size.height);
                         }
                         completion:^(BOOL finished)
         {
             
         }];
    }
}

#pragma mark - custome Alert Clicked
-(void)AlertCancleClicked:(id)sender
{
    NSLog(@"AlertCancleClicked");
    [self hideMorePopUpView:YES];
}
-(void)AlertOKClicked:(id)sender
{
    [txtForgotpasswordEmail resignFirstResponder];
    
    if ([APP_DELEGATE validateEmail:txtForgotpasswordEmail.text])
    {
        lblerror.text=@"";
        lblerror.hidden=YES;
        [txtForgotpasswordEmail resignFirstResponder];
        
        if ([APP_DELEGATE isNetworkreachable])
        {
            [self forgotPasswordWebService];
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
    {   lblerror.text=@"Invalid email";
        lblerror.hidden=NO;
    }
}
-(void)cancelBtnClicked:(id)sender
{
    [self hideMorePopUpView:YES];
}

-(void)OverLayTaped:(id)sender
{
    NSLog(@"Tapped");
}

#pragma mark - Web Service Call
-(void)loginViaEmailWebService
{
    [APP_DELEGATE endHudProcess];
    [APP_DELEGATE startHudProcess:@"Logging..."];
    
    [btnLogin setEnabled:NO];
    [activityIndicator startAnimating];
    NSString *websrviceName=@"login";
    
    NSMutableDictionary * dict = [[NSMutableDictionary alloc]init];
    [dict setValue:txtEmail.text forKey:@"email"];
    [dict setValue:txtPassword.text forKey:@"password"];
    
    NSString *deviceToken =deviceTokenStr;
    if (deviceToken == nil || deviceToken == NULL)
    {
        [dict setValue:@"123456789" forKey:@"device_token"];
    }
    else
    {
        [dict setValue:deviceToken forKey:@"device_token"];
    }
    [dict setValue:@"ios" forKey:@"device_type"];
    
    
    URLManager *manager = [[URLManager alloc] init];
    manager.commandName = @"login";
    manager.delegate = self;
    NSString *strServerUrl = @"http://succorfish.in/mobile/";
    [manager postUrlCall:[NSString stringWithFormat:@"%@%@",strServerUrl,websrviceName] withParameters:dict];
}
-(void)forgotPasswordWebService
{
    [self AlertCancleClicked:nil];

    [APP_DELEGATE endHudProcess];
    [APP_DELEGATE startHudProcess:@"Sending Mail..."];

    NSString *websrviceName=@"forgotpassword";
    NSMutableDictionary * dict = [[NSMutableDictionary alloc]init];
    [dict setValue:txtForgotpasswordEmail.text forKey:@"email"];

    URLManager *manager = [[URLManager alloc] init];
    manager.commandName = @"forgotpassword";
    manager.delegate = self;
    NSString *strServerUrl = @"http://succorfish.in/mobile/";
    [manager postUrlCall:[NSString stringWithFormat:@"%@%@",strServerUrl,websrviceName] withParameters:dict];
}
-(void)VerifyUserWithServer
{
    [APP_DELEGATE endHudProcess];
    [APP_DELEGATE startHudProcess:@"Logging..."];

    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0ul);
    dispatch_async(queue, ^{
        {
            NSMutableDictionary *args = [[NSMutableDictionary alloc] init];
            
            NSString * strUrl = [NSString stringWithFormat:@"https://ws.scstg.net/basic/v2/user/getOwn"];
            
            NSString * strbasicAuthToken;
//            NSString * str = [NSString stringWithFormat:@"device_test:dac6hTQXJc"];
            NSString * str = [NSString stringWithFormat:@"%@:%@",txtEmail.text,txtPassword.text];
            NSString * simpleStr = [APP_DELEGATE base64String:str];
            strbasicAuthToken = simpleStr;
            
            AFHTTPRequestOperationManager *manager1 = [[AFHTTPRequestOperationManager alloc] initWithBaseURL:[NSURL URLWithString:@"http://server.url"]];
            NSString *authorization = [NSString stringWithFormat: @"Basic %@",strbasicAuthToken];
            [manager1.requestSerializer setValue:authorization forHTTPHeaderField:@"Authorization"];
            
            AFHTTPRequestOperation *op = [manager1 GET:strUrl parameters:args success:^(AFHTTPRequestOperation *operation, id responseObject){
                NSLog(@"Success Response with Result=%@",responseObject);
                
                NSMutableDictionary * dictID = [[NSMutableDictionary alloc] init];
                dictID = [responseObject mutableCopy];

                [[NSUserDefaults standardUserDefaults] setValue:txtEmail.text forKey:@"CURRENT_USER_EMAIL"];
                [[NSUserDefaults standardUserDefaults] setValue:txtPassword.text forKey:@"CURRENT_USER_PASS"];
                [[NSUserDefaults standardUserDefaults] setValue:[dictID valueForKey:@"accountId"] forKey:@"CURRENT_USER_ACCOUNT_ID"];
                [[NSUserDefaults standardUserDefaults] setObject:@"YES" forKey:@"IS_LOGGEDIN"];
                
                [dictID setObject:txtPassword.text forKey:@"localPassword"];
                
                if ([[self checkforValidString:[dictID valueForKey:@"firstName"]] isEqualToString:@"NA"])
                {
                    
                }
                else
                {
                    NSString * names = [NSString stringWithFormat:@"%@ %@",[dictID valueForKey:@"firstName"],[dictID valueForKey:@"lastName"]];
                    [[NSUserDefaults standardUserDefaults] setValue:names forKey:@"name"];
                }
                [[NSUserDefaults standardUserDefaults] setObject:@"YES" forKey:@"IS_LOGGEDIN"];
                [[NSUserDefaults standardUserDefaults] setValue:txtEmail.text forKey:@"CURRENT_USER_NAME"];
                [[NSUserDefaults standardUserDefaults] setValue:[dictID valueForKey:@"industry"] forKey:@"industry"];
                [[NSUserDefaults standardUserDefaults] setValue:[dictID valueForKey:@"id"] forKey:@"CURRENT_USER_ID"];
//                [[NSUserDefaults standardUserDefaults] setObject:dictID forKey:@"UserDict"];
                [[NSUserDefaults standardUserDefaults] setValue:@"1" forKey:@"isNewVersionAvailable"];
                [[NSUserDefaults standardUserDefaults] setValue:@"0" forKey:@"TotalInstalls"];

                NSString * str = [NSString stringWithFormat:@"%@:%@",txtEmail.text,txtPassword.text];
                NSString * simpleStr = [APP_DELEGATE base64String:str];
                [[NSUserDefaults standardUserDefaults] setObject:simpleStr forKey:@"BasicAuthToken"];
                
                [[NSUserDefaults standardUserDefaults] synchronize];
                
//                [self getAccountdetailsofUser]; //To get industry from 
                URBAlertView *alertView = [[URBAlertView alloc] initWithTitle:ALERT_TITLE message:@"Logged in Successfully." cancelButtonTitle:OK_BTN otherButtonTitles: nil, nil];
                [alertView setMessageFont:[UIFont fontWithName:CGRegular size:14]];
                [alertView setHandlerBlock:^(NSInteger buttonIndex, URBAlertView *alertView) {
                    [alertView hideWithCompletionBlock:^{
                        [UIView beginAnimations:nil context:NULL];
                        [UIView setAnimationDuration:1.3];
                        [UIView setAnimationTransition:UIViewAnimationTransitionFlipFromLeft forView:[[UIApplication sharedApplication] keyWindow] cache:YES];
                        [UIView commitAnimations];
                        [APP_DELEGATE setUpTabBarController];
                    }];
                }];
                [alertView showWithAnimation:URBAlertAnimationTopToBottom];
    if (IS_IPHONE_X){[alertView showWithAnimation:URBAlertAnimationDefault];}
                [APP_DELEGATE endHudProcess];
            }
                                               failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                                   if (error)
                                                   {
                                                       [APP_DELEGATE endHudProcess];
                                                       NSLog(@"Servicer error = %@", error);
                                                       [self ErrorMessagePopup];
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
}
-(void)getAccountdetailsofUser
{
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0ul);
    dispatch_async(queue, ^{
        {
            NSMutableDictionary *args = [[NSMutableDictionary alloc] init];
            
            NSString * strUrl = [NSString stringWithFormat:@"https://ws.scstg.net/basic/v2/account/getOwn"];
            
            NSString * strbasicAuthToken;
            //            NSString * str = [NSString stringWithFormat:@"device_test:dac6hTQXJc"];
            NSString * str = [NSString stringWithFormat:@"%@:%@",txtEmail.text,txtPassword.text];
            NSString * simpleStr = [APP_DELEGATE base64String:str];
            strbasicAuthToken = simpleStr;
            
            AFHTTPRequestOperationManager *manager1 = [[AFHTTPRequestOperationManager alloc] initWithBaseURL:[NSURL URLWithString:@"http://server.url"]];
            NSString *authorization = [NSString stringWithFormat: @"Basic %@",strbasicAuthToken];
            [manager1.requestSerializer setValue:authorization forHTTPHeaderField:@"Authorization"];
            
            AFHTTPRequestOperation *op = [manager1 GET:strUrl parameters:args success:^(AFHTTPRequestOperation *operation, id responseObject){
                NSLog(@"Success Response with Result=%@",responseObject);
                
                NSMutableDictionary * dictID = [[NSMutableDictionary alloc] init];
                dictID = [responseObject mutableCopy];
                
                [[NSUserDefaults standardUserDefaults] setValue:[dictID valueForKey:@"industry"] forKey:@"industry"];
                [[NSUserDefaults standardUserDefaults] synchronize];
                
        
            }
                                               failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                                   if (error)
                                                   {
                                                       [APP_DELEGATE endHudProcess];
                                                       NSLog(@"Servicer error = %@", error);
                                                       [self ErrorMessagePopup];
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
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - UrlManager Delegate
- (void)onResult:(NSDictionary *)result
{
    [APP_DELEGATE endHudProcess];

    NSLog(@"The result is...%@", result);
    
    [btnLogin setEnabled:YES];
    [activityIndicator stopAnimating];
    
    if ([[result valueForKey:@"commandName"] isEqualToString:@"login"])
    {
        if ([[[result valueForKey:@"result"] valueForKey:@"response"] isEqualToString:@"true"])
        {
            [[NSUserDefaults standardUserDefaults] setObject:[[result valueForKey:@"result"] valueForKey:@"auth_token"] forKey:@"auth_token"];
            [[NSUserDefaults standardUserDefaults] setValue:txtEmail.text forKey:@"CURRENT_USER_EMAIL"];
            [[NSUserDefaults standardUserDefaults] setValue:txtPassword.text forKey:@"CURRENT_USER_PASS"];
            [[NSUserDefaults standardUserDefaults] setObject:@"YES" forKey:@"IS_LOGGEDIN"];
            
            NSMutableDictionary * tmpDict = [[NSMutableDictionary alloc] init];
            tmpDict = [[[result valueForKey:@"result"] valueForKey:@"data"] mutableCopy];
            [tmpDict setObject:txtPassword.text forKey:@"localPassword"];
            [[NSUserDefaults standardUserDefaults] setObject:@"YES" forKey:@"IS_LOGGEDIN"];

            [[NSUserDefaults standardUserDefaults] setValue:[tmpDict valueForKey:@"name"] forKey:@"CURRENT_USER_NAME"];
            
            NSString * str = [NSString stringWithFormat:@"%@:%@",[tmpDict valueForKey:@"name"],txtPassword.text];
            NSString * simpleStr = [APP_DELEGATE base64String:str];
            [[NSUserDefaults standardUserDefaults] setObject:simpleStr forKey:@"BasicAuthToken"];

            [[NSUserDefaults standardUserDefaults] setValue:@"1" forKey:@"isNewVersionAvailable"];
            [[NSUserDefaults standardUserDefaults] synchronize];

            [[NSUserDefaults standardUserDefaults] setValue:[tmpDict valueForKey:@"id"] forKey:@"CURRENT_USER_ID"];
            [[NSUserDefaults standardUserDefaults] setObject:tmpDict forKey:@"UserDict"];
            [[NSUserDefaults standardUserDefaults] setValue:@"0" forKey:@"TotalInstalls"];

            
            [[NSUserDefaults standardUserDefaults] synchronize];
            
            URBAlertView *alertView = [[URBAlertView alloc] initWithTitle:ALERT_TITLE message:@"Logged in Successfully." cancelButtonTitle:OK_BTN otherButtonTitles: nil, nil];
            
            [alertView setMessageFont:[UIFont fontWithName:CGRegular size:14]];
            [alertView setHandlerBlock:^(NSInteger buttonIndex, URBAlertView *alertView) {
                [alertView hideWithCompletionBlock:^{
                    
                    [UIView beginAnimations:nil context:NULL];
                    [UIView setAnimationDuration:1.3];
                    [UIView setAnimationTransition:UIViewAnimationTransitionFlipFromLeft forView:[[UIApplication sharedApplication] keyWindow] cache:YES];
                    [UIView commitAnimations];
                    
                    [APP_DELEGATE setUpTabBarController];
                }];
            }];
            [alertView showWithAnimation:URBAlertAnimationTopToBottom];
    if (IS_IPHONE_X){[alertView showWithAnimation:URBAlertAnimationDefault];}
        }
        else
        {
            URBAlertView * alert =[[URBAlertView alloc] initWithTitle:ALERT_TITLE message:[[result valueForKey:@"result"]valueForKey:@"message"] cancelButtonTitle:OK_BTN otherButtonTitles:nil, nil];
            [alert showWithAnimation:URBAlertAnimationTopToBottom];
        }
    }
    else if ([[result valueForKey:@"commandName"] isEqualToString:@"forgotpassword"])
    {
        if ([[[result valueForKey:@"result"] valueForKey:@"response"] isEqualToString:@"true"])
        {
            
            [btnLogin setEnabled:YES];
            [btnOk setTitle:OK_BTN forState:UIControlStateNormal];
            [btncancel setEnabled:YES];
            [btncancel setTitle:ALERT_CANCEL forState:UIControlStateNormal];
            [ForgotpasswordIndicator stopAnimating];
            
//            [self AlertCancleClicked:nil];
            
            URBAlertView * alert =[[URBAlertView alloc] initWithTitle:ALERT_TITLE message:[[result valueForKey:@"result"]valueForKey:@"message"] cancelButtonTitle:OK_BTN otherButtonTitles:nil, nil];
            [alert setHandlerBlock:^(NSInteger buttonIndex, URBAlertView *alertView) {
                [alertView hideWithCompletionBlock:^{
                }];
            }];
            
            [alert showWithAnimation:URBAlertAnimationTopToBottom];
        }
        else
        {
            
            [btnLogin setEnabled:YES];
            [btnOk setTitle:OK_BTN forState:UIControlStateNormal];
            [btncancel setEnabled:YES];
            [btncancel setTitle:ALERT_CANCEL forState:UIControlStateNormal];
            [ForgotpasswordIndicator stopAnimating];
            
            
            URBAlertView * alert =[[URBAlertView alloc] initWithTitle:ALERT_TITLE message:[[result valueForKey:@"result"]valueForKey:@"message"] cancelButtonTitle:OK_BTN otherButtonTitles:nil, nil];
            [alert showWithAnimation:URBAlertAnimationTopToBottom];
        }
        
    }
}

- (void)onError:(NSError *)error
{
    [APP_DELEGATE endHudProcess];

    NSLog(@"The error is...%@", error);
    
    [btnLogin setEnabled:YES];
    [activityIndicator stopAnimating];
    
    [btnLogin setEnabled:YES];
    [btnOk setTitle:OK_BTN forState:UIControlStateNormal];
    [btncancel setEnabled:YES];
    [btncancel setTitle:ALERT_CANCEL forState:UIControlStateNormal];
    [ForgotpasswordIndicator stopAnimating];
    
    
    NSInteger ancode = [error code];
    
    NSMutableDictionary * errorDict = [error.userInfo mutableCopy];
    NSLog(@"errorDict===%@",errorDict);
    
    if (ancode == -1001 || ancode == -1004 || ancode == -1005 || ancode == -1009)
    {
        [APP_DELEGATE ShowErrorPopUpWithErrorCode:ancode andMessage:@""];
    }
    else
    {
        [APP_DELEGATE ShowErrorPopUpWithErrorCode:customErrorCodeForMessage andMessage:@"Please try again later"];
    }
    
    
    NSString * strLoginUrl = [NSString stringWithFormat:@"%@%@",WEB_SERVICE_URL,@"token.json"];
    if ([[errorDict valueForKey:@"NSErrorFailingURLStringKey"] isEqualToString:strLoginUrl])
    {
        NSLog(@"NSErrorFailingURLStringKey===%@",[errorDict valueForKey:@"NSErrorFailingURLStringKey"]);
    }
}

#pragma mark - Hide Keyboard
-(void)hideKeyboard
{
    [txtEmail resignFirstResponder];
    [txtPassword resignFirstResponder];
    [txtForgotpasswordEmail resignFirstResponder];
}

#pragma mark - Textfield Delegates
-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (textField == txtEmail)
    {
        [txtPassword becomeFirstResponder];
    }
    else if (textField == txtPassword)
    {
        [textField resignFirstResponder];
    }
    return YES;
}

-(void)textFieldDidBeginEditing:(UITextField *)textField
{
    if (textField== txtEmail || textField == txtPassword)
    {
        [UIView animateWithDuration:0.3 animations:^{
            if (IS_IPHONE_4)
            {
//                [viewPopUp setFrame:CGRectMake(15, DEVICE_HEIGHT/2-160-70, DEVICE_WIDTH-30, 300)];
            }
        }];
    }
    else
    {
        [UIView animateWithDuration:0.3 animations:^{
            if (IS_IPHONE_4)
            {
                [viewMore setFrame:CGRectMake(20, (DEVICE_HEIGHT-(viewMore.frame.size.height))/2 -140, DEVICE_WIDTH-40, viewMore.frame.size.height)];
            }else
            {
                [viewMore setFrame:CGRectMake(20, (DEVICE_HEIGHT-(viewMore.frame.size.height))/2- 100 , DEVICE_WIDTH-40, viewMore.frame.size.height)];
            }
        }];
    }
    lblLine = [[UILabel alloc] initWithFrame:CGRectMake(0, textField.frame.size.height-2, textField.frame.size.width, 2)];
    
    [lblLine setBackgroundColor:[UIColor whiteColor]];
    [textField addSubview:lblLine];
}

-(void)textFieldDidEndEditing:(UITextField *)textField
{
    if (textField == txtEmail || textField == txtPassword)
    {
        [UIView animateWithDuration:0.3 animations:^{
            if (IS_IPHONE_4)
            {
//                [viewPopUp setFrame:CGRectMake(15, 110, DEVICE_WIDTH-30, 300)];
            }
        }];
    }
    else
    {
        [UIView animateWithDuration:0.3 animations:^{
            [viewMore setFrame:CGRectMake(20, (DEVICE_HEIGHT-(viewMore.frame.size.height))/2 , DEVICE_WIDTH-40, viewMore.frame.size.height)];
        }];
    }
    [lblLine removeFromSuperview];
}
-(void)ErrorMessagePopup
{
    [APP_DELEGATE endHudProcess];
    
    URBAlertView *alertView = [[URBAlertView alloc] initWithTitle:ALERT_TITLE message:@"Username/Password is incorrect. Please check your credential." cancelButtonTitle:OK_BTN otherButtonTitles: nil, nil];
    
    [alertView setMessageFont:[UIFont fontWithName:CGRegular size:14]];
    [alertView setHandlerBlock:^(NSInteger buttonIndex, URBAlertView *alertView) {
        [alertView hideWithCompletionBlock:^{
        }];
    }];
    [alertView showWithAnimation:URBAlertAnimationTopToBottom];
    if (IS_IPHONE_X){[alertView showWithAnimation:URBAlertAnimationDefault];}
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

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
