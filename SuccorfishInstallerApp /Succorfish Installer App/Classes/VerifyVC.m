//
//  VerifyVC.m
//  Succorfish Installer App
//
//  Created by stuart watts on 23/02/2018.
//  Copyright © 2018 Kalpesh Panchasara. All rights reserved.
//

#import "VerifyVC.h"
#import "GSPasswordInputView.h"
#import "PasswordVC.h"

@interface VerifyVC ()<GSPasswordInputViewDelegate,URLManagerDelegate>
{
    GSPasswordInputView *pwdInputView;
    int lastHeight;
}
@end

@implementation VerifyVC
@synthesize dataDict,strUserId;
- (void)viewDidLoad
{
    UIImageView * imgBack = [[UIImageView alloc] init];
    imgBack.frame = CGRectMake(0, 0, DEVICE_WIDTH, DEVICE_HEIGHT);
    imgBack.image = [UIImage imageNamed:@"Splash_bg.png"];
    [self.view addSubview:imgBack];
    
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
    lblName.text = @"Verify Account";
    [lblName setFont:[UIFont fontWithName:CGRegular size:15]];
    [scrlContent addSubview:lblName];
    
    if (IS_IPHONE_X)
    {
        lblName.frame = CGRectMake(15, 40, DEVICE_WIDTH-30, 30);
    }
    UIImageView * imgLogo = [[UIImageView alloc] initWithFrame:CGRectMake((DEVICE_WIDTH-(170*approaxSize))/2, 87*approaxSize, 170*approaxSize, 34*approaxSize)];
    [imgLogo setImage:[UIImage imageNamed:@"logo.png"]];
    [imgLogo setClipsToBounds:YES];
    [imgLogo setContentMode:UIViewContentModeScaleAspectFit];
    [scrlContent addSubview:imgLogo];
    
    
    viewPopUp = [[UIView alloc] initWithFrame:CGRectMake(15, 156*approaxSize, DEVICE_WIDTH-30, 288*approaxSize)];
    [viewPopUp setBackgroundColor:[UIColor clearColor]];
    viewPopUp.layer.shadowColor = [UIColor darkGrayColor].CGColor;
    viewPopUp.layer.shadowOffset = CGSizeMake(0.1, 0.1);
    viewPopUp.layer.shadowRadius = 25;
    viewPopUp.layer.shadowOpacity = 0.5;
    [scrlContent addSubview:viewPopUp];
    
    if (IS_IPHONE_4)
    {
        imgLogo.frame = CGRectMake((DEVICE_WIDTH-204)/2, 25, 204, 42);
        viewPopUp.frame = CGRectMake(15, 110, DEVICE_WIDTH-30, 250);
    }
    
    int yy = 15;
    
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
    
    int txtSize = 15;
    if (IS_IPHONE_4 || IS_IPHONE_5)
    {
        txtSize = 14;
    }
    
    lblHint =  [[UILabel alloc] init];
    lblHint.frame = CGRectMake(15, yy, viewPopUp.frame.size.width-30, 80);
    lblHint.textAlignment = NSTextAlignmentCenter;
    lblHint.numberOfLines = 0;
    lblHint.textColor = [UIColor whiteColor];
    lblHint.text = @"Enter your 4 digit verification code which sent to your email id to verify your account";
    [lblHint setFont:[UIFont fontWithName:CGRegular size:txtSize]];
    [viewPopUp addSubview:lblHint];
    
    
    UILabel * lblEmailLine = [[UILabel alloc] initWithFrame:CGRectMake(0, txtEmail.frame.size.height-2, txtEmail.frame.size.width, 1)];
    [lblEmailLine setBackgroundColor:[UIColor lightGrayColor]];
    [txtEmail addSubview:lblEmailLine];
    
    yy = yy + 80;
    
    lastHeight = yy;
    [pwdInputView removeFromSuperview];
    pwdInputView = [[GSPasswordInputView alloc] initWithFrame:CGRectMake((viewPopUp.frame.size.width-160)/2, (yy)*approaxSize, 160, 40*approaxSize)];
    pwdInputView.numberOfDigit = 4;
    pwdInputView.delegate = self;
    [viewPopUp addSubview:pwdInputView];
    
    yy = yy + 40*approaxSize + 15*approaxSize;
    
    UIButton * btnSubmit = [UIButton buttonWithType:UIButtonTypeCustom];
    btnSubmit.frame = CGRectMake(15, yy, viewPopUp.frame.size.width-30, 38);
    [btnSubmit setBackgroundImage:[UIImage imageNamed:@"BTN.png"] forState:UIControlStateNormal];
    [btnSubmit setTitle:@"SUBMIT" forState:UIControlStateNormal];
    [btnSubmit setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [btnSubmit addTarget:self action:@selector(btnSubmitClick) forControlEvents:UIControlEventTouchUpInside];
    [btnSubmit.titleLabel setFont:[UIFont fontWithName:CGRegular size:txtSize]];
    [viewPopUp addSubview:btnSubmit];
    
    yy = yy +20+ 38 * approaxSize;
    
    UILabel * lblHint2 =  [[UILabel alloc] init];
    lblHint2.frame = CGRectMake(15, yy, viewPopUp.frame.size.width-30, 30);
    lblHint2.textAlignment = NSTextAlignmentCenter;
    lblHint2.numberOfLines = 0;
    lblHint2.textColor = [UIColor lightGrayColor];
    lblHint2.text = @"Didn't recieve the OTP?";
    [lblHint2 setFont:[UIFont fontWithName:CGRegular size:txtSize]];
    [viewPopUp addSubview:lblHint2];
    
    UIButton * btnResnt = [UIButton buttonWithType:UIButtonTypeCustom];
    btnResnt.frame = CGRectMake(15, yy + 30, viewPopUp.frame.size.width-30, 38);
    [btnResnt setTitle:@"Resend OTP" forState:UIControlStateNormal];
    [btnResnt setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [btnResnt addTarget:self action:@selector(btnResendOTP) forControlEvents:UIControlEventTouchUpInside];
    [btnResnt.titleLabel setFont:[UIFont fontWithName:CGBold size:txtSize]];

    [viewPopUp addSubview:btnResnt];
    
}
-(void)setAgainVerify
{
    pwdInputView.delegate = nil;
    [pwdInputView removeFromSuperview];
    pwdInputView = [[GSPasswordInputView alloc] initWithFrame:CGRectMake((viewPopUp.frame.size.width-160)/2, (lastHeight)*approaxSize, 160, 40*approaxSize)];
    pwdInputView.numberOfDigit = 4;
    pwdInputView.delegate = self;
    [viewPopUp addSubview:pwdInputView];
}
- (void)didFinishEditingWithInputView:(GSPasswordInputView *)anInputView text:(NSString *)aText;
{
    [anInputView resignFirstResponder];
    codeStr = aText;
    NSLog(@"Final code =%@",aText);
}
-(void)btnSubmitClick
{

    if ([codeStr length] == 0 || codeStr == nil  || [codeStr isEqualToString:@" "])
    {
        URBAlertView *alertView = [[URBAlertView alloc] initWithTitle:ALERT_TITLE message:@"Please enter verification code." cancelButtonTitle:OK_BTN otherButtonTitles: nil, nil];
        
        [alertView setMessageFont:[UIFont fontWithName:CGRegular size:14]];
        [alertView setHandlerBlock:^(NSInteger buttonIndex, URBAlertView *alertView) {
            [alertView hideWithCompletionBlock:^{
            }];
        }];
        [alertView showWithAnimation:URBAlertAnimationTopToBottom];
    if (IS_IPHONE_X){[alertView showWithAnimation:URBAlertAnimationDefault];}
    }
    else if ([codeStr length]>4)
    {
        URBAlertView *alertView = [[URBAlertView alloc] initWithTitle:ALERT_TITLE message:@"Please enter complete verification code." cancelButtonTitle:OK_BTN otherButtonTitles: nil, nil];
        
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
        if ([APP_DELEGATE isNetworkreachable])
        {
            [self sendOTPtoServer];
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
-(void)resendServiceCall
{
    [APP_DELEGATE endHudProcess];
    [APP_DELEGATE startHudProcess:@"Sending again...."];
    
    NSString *websrviceName=@"resend";
    
    NSMutableDictionary * dict = [[NSMutableDictionary alloc]init];
    [dict setValue:strUserId forKey:@"user_id"];
    
    URLManager *manager = [[URLManager alloc] init];
    manager.commandName = @"resend";
    manager.delegate = self;
    NSString *strServerUrl = @"http://succorfish.in/mobile/";
    [manager postUrlCall:[NSString stringWithFormat:@"%@%@",strServerUrl,websrviceName] withParameters:dict];
}
-(void)btnResendOTP
{
    URBAlertView *alertView = [[URBAlertView alloc] initWithTitle:ALERT_TITLE message:@"Are you sure, you want to resend OTP ?" cancelButtonTitle:@"Yes" otherButtonTitles: @"No", nil];
    [alertView setMessageFont:[UIFont fontWithName:CGRegular size:12]];
    [alertView setHandlerBlock:^(NSInteger buttonIndex, URBAlertView *alertView) {
        [alertView hideWithCompletionBlock:^{
            
            if (buttonIndex==0)
            {
                if ([APP_DELEGATE isNetworkreachable])
                {
                    [self resendServiceCall];
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
        }];
    }];
      [alertView showWithAnimation:Alert_Animation_Type];
        if (IS_IPHONE_X) {[alertView showWithAnimation:URBAlertAnimationDefault];}

}
-(void)sendOTPtoServer
{
    [APP_DELEGATE endHudProcess];
    [APP_DELEGATE startHudProcess:@"Verifying account...."];

    NSString *websrviceName=@"otpverify";
    
    NSMutableDictionary * dict = [[NSMutableDictionary alloc]init];
    [dict setValue:strUserId forKey:@"user_id"];
    [dict setValue:codeStr forKey:@"otp_code"];
    
    URLManager *manager = [[URLManager alloc] init];
    manager.commandName = @"otpverify";
    manager.delegate = self;
    NSString *strServerUrl = @"http://succorfish.in/mobile/";
    [manager postUrlCall:[NSString stringWithFormat:@"%@%@",strServerUrl,websrviceName] withParameters:dict];
}
#pragma mark - UrlManager Delegate
- (void)onResult:(NSDictionary *)result
{
    [APP_DELEGATE endHudProcess];
//    NSLog(@"The result is...%@", result);
    if ([[result valueForKey:@"commandName"] isEqualToString:@"otpverify"])
    {
        if ([[[result valueForKey:@"result"] valueForKey:@"response"] isEqualToString:@"true"])
        {
            if([[result valueForKey:@"result"] valueForKey:@"data"]!=[NSNull null])
            {
                NSMutableDictionary * tmpDict = [[NSMutableDictionary alloc] init];
                tmpDict = [[[result valueForKey:@"result"] valueForKey:@"data"] mutableCopy];
                NSString * userID = [[[result valueForKey:@"result"] valueForKey:@"data"] valueForKey:@"id"];

                PasswordVC * verify = [[PasswordVC alloc] init];
                verify.dataDict = tmpDict;
                verify.strUserId = userID;
                [self.navigationController pushViewController:verify animated:YES];
            }
        }
        else
        {
            [self setAgainVerify];
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
    else if ([[result valueForKey:@"commandName"] isEqualToString:@"resend"])
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
- (void)onError:(NSError *)error
{
    [self setAgainVerify];

    NSLog(@"The error is...%@", error);
    [APP_DELEGATE endHudProcess];

    
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

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
