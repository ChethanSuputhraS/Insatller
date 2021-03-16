//
//  PasswordVC.m
//  Succorfish Installer App
//
//  Created by stuart watts on 24/02/2018.
//  Copyright © 2018 Kalpesh Panchasara. All rights reserved.
//

#import "PasswordVC.h"

@interface PasswordVC ()<URLManagerDelegate>
{
    NSMutableDictionary * userDetailDict;
}
@end

@implementation PasswordVC
@synthesize dataDict,strUserId,isfromEdit;

- (void)viewDidLoad
{
    UIImageView * imgBack = [[UIImageView alloc] init];
    imgBack.frame = CGRectMake(0, 0, DEVICE_WIDTH, DEVICE_HEIGHT);
    imgBack.image = [UIImage imageNamed:@"Splash_bg.png"];
    [self.view addSubview:imgBack];
    
    if (isfromEdit)
    {
        userDetailDict = [[NSMutableDictionary alloc] init];
        userDetailDict=[[[NSUserDefaults standardUserDefaults] objectForKey:@"UserDict"] mutableCopy];
    }

    [self setContentViewFrames];

    [super viewDidLoad];
    // Do any additional setup after loading the view.
}
-(void)setNavigationViewFrames
{
    UIView * viewHeader = [[UIView alloc] initWithFrame:CGRectMake(0, 0, DEVICE_WIDTH, 64)];
    [viewHeader setBackgroundColor:[UIColor blackColor]];
    [self.view addSubview:viewHeader];
    
    UILabel * lblTitle = [[UILabel alloc] initWithFrame:CGRectMake(50, 20, DEVICE_WIDTH-100, 44)];
    [lblTitle setBackgroundColor:[UIColor clearColor]];
    [lblTitle setText:@"Change Password"];
    [lblTitle setTextAlignment:NSTextAlignmentCenter];
    [UIFont fontWithName:CGRegular size:17];
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
        btnBack.frame = CGRectMake(0, 20, 70, 84);
    }
}

#pragma mark - Set UI frames
-(void)setContentViewFrames
{
    scrlContent = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, DEVICE_WIDTH, DEVICE_HEIGHT)];
    scrlContent.showsVerticalScrollIndicator = NO;
    [self.view addSubview:scrlContent];
    
    if (isfromEdit)
    {
        [self setNavigationViewFrames];
    }
    
    UILabel * lblName =  [[UILabel alloc] init];
    lblName.frame = CGRectMake(15, 30, DEVICE_WIDTH-30, 30);
    lblName.textAlignment = NSTextAlignmentCenter;
    lblName.textColor = [UIColor whiteColor];
    lblName.text = @"Set Password";
    [lblName setFont:[UIFont fontWithName:CGRegular size:15]];
    [scrlContent addSubview:lblName];
    
    UIImageView * imgLogo = [[UIImageView alloc] initWithFrame:CGRectMake((DEVICE_WIDTH-(170*approaxSize))/2, 87*approaxSize, 170*approaxSize, 34*approaxSize)];
    [imgLogo setImage:[UIImage imageNamed:@"logo.png"]];
    [imgLogo setClipsToBounds:YES];
    [imgLogo setContentMode:UIViewContentModeScaleAspectFit];
    [scrlContent addSubview:imgLogo];
    
    
    viewPopUp = [[UIView alloc] initWithFrame:CGRectMake(15, 156*approaxSize, DEVICE_WIDTH-30, 250*approaxSize)];
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
    
    if (isfromEdit)
    {
        lblName.hidden = YES;
        imgLogo.hidden = YES;
        viewPopUp.frame = CGRectMake(15, 75, DEVICE_WIDTH-30, (250+50)*approaxSize);
        if (IS_IPHONE_X)
        {
            viewPopUp.frame = CGRectMake(15, 100, DEVICE_WIDTH-30, (250)*approaxSize);
        }
    }
    
    int yy = 30;
    
    UIImageView * imgPopUpBG = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, viewPopUp.frame.size.width, viewPopUp.frame.size.height)];
    [imgPopUpBG setBackgroundColor:[UIColor blackColor]];
    imgPopUpBG.alpha = 0.7;
    imgPopUpBG.layer.cornerRadius = 10;
    [viewPopUp addSubview:imgPopUpBG];
    
    UIBezierPath *shadowPath = [UIBezierPath bezierPathWithRect:imgPopUpBG.bounds];
    imgPopUpBG.layer.masksToBounds = NO;
    imgPopUpBG.layer.shadowColor = [UIColor blackColor].CGColor;
    imgPopUpBG.layer.shadowOffset = CGSizeMake(0.0f, 1.0f);
    imgPopUpBG.layer.shadowOpacity = 0.5f;
    imgPopUpBG.layer.shadowPath = shadowPath.CGPath;
    
    
    if (isfromEdit)
    {
        txtCurrentPass = [[UITextField alloc] initWithFrame:CGRectMake(15, yy, viewPopUp.frame.size.width-30, 35)];
        txtCurrentPass.placeholder = @"Current Password";
        txtCurrentPass.delegate = self;
        txtCurrentPass.secureTextEntry = YES;
        txtCurrentPass.autocapitalizationType = UITextAutocapitalizationTypeNone;
        txtCurrentPass.textColor = [UIColor whiteColor];
        [txtCurrentPass setFont:[UIFont fontWithName:CGRegular size:15]];
        [APP_DELEGATE getPlaceholderText:txtCurrentPass andColor:UIColor.whiteColor];
        txtCurrentPass.returnKeyType = UIReturnKeyNext;
        [viewPopUp addSubview:txtCurrentPass];
        
        UILabel * lblPasswordLine = [[UILabel alloc] initWithFrame:CGRectMake(0, txtCurrentPass.frame.size.height-2, txtCurrentPass.frame.size.width,1)];
        [lblPasswordLine setBackgroundColor:[UIColor lightGrayColor]];
        [txtCurrentPass addSubview:lblPasswordLine];
        
        
        btnCurrentPass = [UIButton buttonWithType:UIButtonTypeCustom];
        btnCurrentPass.frame = CGRectMake(viewPopUp.frame.size.width-60, yy, 60, 35);
        btnCurrentPass.backgroundColor = [UIColor clearColor];
        [btnCurrentPass addTarget:self action:@selector(showCurrentPasswrd) forControlEvents:UIControlEventTouchUpInside];
        [btnCurrentPass setImage:[UIImage imageNamed:@"passShow.png"] forState:UIControlStateNormal];
        [viewPopUp addSubview:btnCurrentPass];
        
        yy = yy + 60;
    }

    
    txtPass = [[UITextField alloc] initWithFrame:CGRectMake(15, yy, viewPopUp.frame.size.width-30, 35)];
    txtPass.placeholder = @"Password";
    txtPass.delegate = self;
    txtPass.secureTextEntry = YES;
    txtPass.autocapitalizationType = UITextAutocapitalizationTypeNone;
    txtPass.textColor = [UIColor whiteColor];
    [txtPass setFont:[UIFont fontWithName:CGRegular size:15]];
    [APP_DELEGATE getPlaceholderText:txtPass andColor:UIColor.whiteColor];
    txtPass.returnKeyType = UIReturnKeyNext;
    [viewPopUp addSubview:txtPass];
    
    UILabel * lblPasswordLine1 = [[UILabel alloc] initWithFrame:CGRectMake(0, txtPass.frame.size.height-2, txtPass.frame.size.width,1)];
    [lblPasswordLine1 setBackgroundColor:[UIColor lightGrayColor]];
    [txtPass addSubview:lblPasswordLine1];
    
  
    btnShowPass = [UIButton buttonWithType:UIButtonTypeCustom];
    btnShowPass.frame = CGRectMake(viewPopUp.frame.size.width-60, yy, 60, 35);
    btnShowPass.backgroundColor = [UIColor clearColor];
    [btnShowPass addTarget:self action:@selector(showPassclick) forControlEvents:UIControlEventTouchUpInside];
    [btnShowPass setImage:[UIImage imageNamed:@"passShow.png"] forState:UIControlStateNormal];
    [viewPopUp addSubview:btnShowPass];
    
    yy = yy + 60;

    txtConfPass = [[UITextField alloc] initWithFrame:CGRectMake(15, yy, viewPopUp.frame.size.width-30, 35)];
    txtConfPass.placeholder = @"Confirm Password";
    txtConfPass.delegate = self;
    txtConfPass.secureTextEntry = YES;
    txtConfPass.autocapitalizationType = UITextAutocapitalizationTypeNone;
    txtConfPass.textColor = [UIColor whiteColor];
    [txtConfPass setFont:[UIFont fontWithName:CGRegular size:15]];
    [APP_DELEGATE getPlaceholderText:txtConfPass andColor:UIColor.whiteColor];
    txtConfPass.returnKeyType = UIReturnKeyDone;
    [viewPopUp addSubview:txtConfPass];
    
    UILabel * lblPasswordLine2 = [[UILabel alloc] initWithFrame:CGRectMake(0, txtConfPass.frame.size.height-2, txtConfPass.frame.size.width,1)];
    [lblPasswordLine2 setBackgroundColor:[UIColor lightGrayColor]];
    [txtConfPass addSubview:lblPasswordLine2];

    btnShowConfPass = [UIButton buttonWithType:UIButtonTypeCustom];
    btnShowConfPass.frame = CGRectMake(viewPopUp.frame.size.width-60, yy, 60, 35);
    btnShowConfPass.backgroundColor = [UIColor clearColor];
    [btnShowConfPass addTarget:self action:@selector(showConfirmPasswrd) forControlEvents:UIControlEventTouchUpInside];
    [btnShowConfPass setImage:[UIImage imageNamed:@"passShow.png"] forState:UIControlStateNormal];
    [viewPopUp addSubview:btnShowConfPass];
    
    
    yy = yy + 40*approaxSize + 30*approaxSize;
    
    UIButton * btnSubmit = [UIButton buttonWithType:UIButtonTypeCustom];
    btnSubmit.frame = CGRectMake(15, yy, viewPopUp.frame.size.width-30, 38);
    [btnSubmit setBackgroundImage:[UIImage imageNamed:@"BTN.png"] forState:UIControlStateNormal];
    [btnSubmit setTitle:@"Save" forState:UIControlStateNormal];
    [btnSubmit setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    btnSubmit.titleLabel.font = [UIFont fontWithName:CGRegular size:14];
    [btnSubmit addTarget:self action:@selector(btnSubmitClick) forControlEvents:UIControlEventTouchUpInside];
    [viewPopUp addSubview:btnSubmit];
    
    if (isfromEdit)
    {
        txtPass.placeholder = @"New Password";
        txtConfPass.placeholder = @"Confirm Password";
    }
    
}

-(void)showPassclick
{
    if (isPassShow)
    {
        isPassShow = NO;
        [btnShowPass setImage:[UIImage imageNamed:@"passShow.png"] forState:UIControlStateNormal];
        txtPass.secureTextEntry = YES;
    }
    else
    {
        isPassShow = YES;
        [btnShowPass setImage:[UIImage imageNamed:@"visible.png"] forState:UIControlStateNormal];
        txtPass.secureTextEntry = NO;
    }
}

-(void)showConfirmPasswrd
{
    if (isConfPassShow)
    {
        isConfPassShow = NO;
        [btnShowConfPass setImage:[UIImage imageNamed:@"passShow.png"] forState:UIControlStateNormal];
        txtConfPass.secureTextEntry = YES;
    }
    else
    {
        isConfPassShow = YES;
        [btnShowConfPass setImage:[UIImage imageNamed:@"visible.png"] forState:UIControlStateNormal];
        txtConfPass.secureTextEntry = NO;
    }
}
-(void)showCurrentPasswrd
{
    if (isCurrentPass)
    {
        isCurrentPass = NO;
        [btnCurrentPass setImage:[UIImage imageNamed:@"passShow.png"] forState:UIControlStateNormal];
        txtCurrentPass.secureTextEntry = YES;
    }
    else
    {
        isCurrentPass = YES;
        [btnCurrentPass setImage:[UIImage imageNamed:@"visible.png"] forState:UIControlStateNormal];
        txtCurrentPass.secureTextEntry = NO;
    }
}
-(void)btnSubmitClick
{
    if (isfromEdit)
    {
        if([txtCurrentPass.text isEqualToString:@""])
        {
            URBAlertView *alertView = [[URBAlertView alloc] initWithTitle:ALERT_TITLE message:@"Please enter current password" cancelButtonTitle:OK_BTN otherButtonTitles: nil, nil];
            
            [alertView setMessageFont:[UIFont fontWithName:CGRegular size:14]];
            [alertView setHandlerBlock:^(NSInteger buttonIndex, URBAlertView *alertView) {
                [alertView hideWithCompletionBlock:^{
                }];
            }];
            [alertView showWithAnimation:URBAlertAnimationTopToBottom];
    if (IS_IPHONE_X){[alertView showWithAnimation:URBAlertAnimationDefault];}

        }
        else if([txtPass.text isEqualToString:@""])
        {
            URBAlertView *alertView = [[URBAlertView alloc] initWithTitle:ALERT_TITLE message:@"Please enter new password" cancelButtonTitle:OK_BTN otherButtonTitles: nil, nil];
            
            [alertView setMessageFont:[UIFont fontWithName:CGRegular size:14]];
            [alertView setHandlerBlock:^(NSInteger buttonIndex, URBAlertView *alertView) {
                [alertView hideWithCompletionBlock:^{
                }];
            }];
            [alertView showWithAnimation:URBAlertAnimationTopToBottom];
    if (IS_IPHONE_X){[alertView showWithAnimation:URBAlertAnimationDefault];}
        }
        else if([txtConfPass.text isEqualToString:@""])
        {
            URBAlertView *alertView = [[URBAlertView alloc] initWithTitle:ALERT_TITLE message:@"Please enter confirm password" cancelButtonTitle:OK_BTN otherButtonTitles: nil, nil];
            
            [alertView setMessageFont:[UIFont fontWithName:CGRegular size:14]];
            [alertView setHandlerBlock:^(NSInteger buttonIndex, URBAlertView *alertView) {
                [alertView hideWithCompletionBlock:^{
                }];
            }];
            [alertView showWithAnimation:URBAlertAnimationTopToBottom];
    if (IS_IPHONE_X){[alertView showWithAnimation:URBAlertAnimationDefault];}
        }
        else if(![txtConfPass.text isEqualToString:txtPass.text])
        {
            URBAlertView *alertView = [[URBAlertView alloc] initWithTitle:ALERT_TITLE message:@"Password not matched" cancelButtonTitle:OK_BTN otherButtonTitles: nil, nil];
            
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
                [self changePasswordService];
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
    else
    {
        if([txtPass.text isEqualToString:@""])
        {
            URBAlertView *alertView = [[URBAlertView alloc] initWithTitle:ALERT_TITLE message:@"Please enter password" cancelButtonTitle:OK_BTN otherButtonTitles: nil, nil];
            
            [alertView setMessageFont:[UIFont fontWithName:CGRegular size:14]];
            [alertView setHandlerBlock:^(NSInteger buttonIndex, URBAlertView *alertView) {
                [alertView hideWithCompletionBlock:^{
                }];
            }];
            [alertView showWithAnimation:URBAlertAnimationTopToBottom];
    if (IS_IPHONE_X){[alertView showWithAnimation:URBAlertAnimationDefault];}
        }
        else if([txtConfPass.text isEqualToString:@""])
        {
            URBAlertView *alertView = [[URBAlertView alloc] initWithTitle:ALERT_TITLE message:@"Please enter confirm password" cancelButtonTitle:OK_BTN otherButtonTitles: nil, nil];
            
            [alertView setMessageFont:[UIFont fontWithName:CGRegular size:14]];
            [alertView setHandlerBlock:^(NSInteger buttonIndex, URBAlertView *alertView) {
                [alertView hideWithCompletionBlock:^{
                }];
            }];
            [alertView showWithAnimation:URBAlertAnimationTopToBottom];
    if (IS_IPHONE_X){[alertView showWithAnimation:URBAlertAnimationDefault];}
        }
        else if(![txtConfPass.text isEqualToString:txtPass.text])
        {
            URBAlertView *alertView = [[URBAlertView alloc] initWithTitle:ALERT_TITLE message:@"Password not matched" cancelButtonTitle:OK_BTN otherButtonTitles: nil, nil];
            
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
                [self sendPasswordToServer];
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
-(void)btnBackClick
{
    [self.navigationController popViewControllerAnimated:YES];
}
#pragma mark - Textfield Delegates
-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (textField == txtCurrentPass)
    {
        [txtPass becomeFirstResponder];
    }
    else if (textField == txtPass)
    {
        [txtConfPass becomeFirstResponder];
    }
    else if (textField == txtConfPass)
    {
        [textField resignFirstResponder];
    }
    return YES;
}

-(void)textFieldDidBeginEditing:(UITextField *)textField
{
    [UIView animateWithDuration:0.3 animations:^{
        if (IS_IPHONE_4)
        {
            [viewPopUp setFrame:CGRectMake(15, DEVICE_HEIGHT/2-160-70, DEVICE_WIDTH-30, 250)];
        }
        else
        {
            //                [viewPopUp setFrame:CGRectMake(20, DEVICE_HEIGHT/2-160-100, DEVICE_WIDTH-40, 320)];
        }
    }];
    
    lblLine = [[UILabel alloc] initWithFrame:CGRectMake(0, textField.frame.size.height-2, textField.frame.size.width, 2)];
    
    [lblLine setBackgroundColor:[UIColor whiteColor]];
    [textField addSubview:lblLine];

}
-(void)textFieldDidEndEditing:(UITextField *)textField
{
    [UIView animateWithDuration:0.3 animations:^{
        if (IS_IPHONE_4)
        {
            [viewPopUp setFrame:CGRectMake(15, 110, DEVICE_WIDTH-30, 250)];
        }
    }];
    [lblLine removeFromSuperview];
}


#pragma mark - Call Webservice to set password
-(void)sendPasswordToServer
{
    [APP_DELEGATE endHudProcess];
    [APP_DELEGATE startHudProcess:@"Saving...."];

    NSString *websrviceName=@"setpassword";
    
    NSMutableDictionary * dict = [[NSMutableDictionary alloc]init];
    [dict setValue:strUserId forKey:@"user_id"];
    [dict setValue:txtPass.text forKey:@"password"];
    
    URLManager *manager = [[URLManager alloc] init];
    manager.commandName = @"setpassword";
    manager.delegate = self;
    NSString *strServerUrl = @"http://succorfish.in/mobile/";
    [manager postUrlCall:[NSString stringWithFormat:@"%@%@",strServerUrl,websrviceName] withParameters:dict];
}
-(void)changePasswordService
{
    [APP_DELEGATE endHudProcess];
    [APP_DELEGATE startHudProcess:@"Changing Password...."];
    
    NSString *websrviceName=@"changepassword";
    
    NSString * strUserids = [userDetailDict valueForKey:@"id"];

    NSMutableDictionary * dict = [[NSMutableDictionary alloc]init];
    [dict setValue:strUserids forKey:@"user_id"];
    [dict setValue:txtCurrentPass.text forKey:@"current_pass"];
    [dict setValue:txtPass.text forKey:@"new_pass"];

    URLManager *manager = [[URLManager alloc] init];
    manager.commandName = @"changepassword";
    manager.delegate = self;
    NSString *strServerUrl = @"http://succorfish.in/mobile/";
    [manager postUrlCall:[NSString stringWithFormat:@"%@%@",strServerUrl,websrviceName] withParameters:dict];
}
#pragma mark - UrlManager Delegate
- (void)onResult:(NSDictionary *)result
{
    [APP_DELEGATE endHudProcess];

    NSLog(@"The result is...%@", result);
    if ([[result valueForKey:@"commandName"] isEqualToString:@"setpassword"])
    {
        if ([[[result valueForKey:@"result"] valueForKey:@"response"] isEqualToString:@"true"])
        {
            if([[result valueForKey:@"result"] valueForKey:@"data"]!=[NSNull null])
            {
                NSMutableDictionary * tmpDict = [[NSMutableDictionary alloc] init];
                tmpDict = [[[result valueForKey:@"result"] valueForKey:@"data"] mutableCopy];
//                [tmpDict setObject:txtPass.text forKey:@"localPassword"];
//                [[NSUserDefaults standardUserDefaults] setObject:tmpDict forKey:@"UserDict"];
//                [[NSUserDefaults standardUserDefaults] setObject:@"YES" forKey:@"IS_LOGGEDIN"];
//
//                [[NSUserDefaults standardUserDefaults] setValue:[tmpDict valueForKey:@"email"] forKey:@"CURRENT_USER_EMAIL"];
//                [[NSUserDefaults standardUserDefaults] setValue:[tmpDict valueForKey:@"id"] forKey:@"CURRENT_USER_ID"];
//                [[NSUserDefaults standardUserDefaults] setValue:txtPass.text forKey:@"CURRENT_USER_PASS"];
                [[NSUserDefaults standardUserDefaults] synchronize];
                
                URBAlertView *alertView = [[URBAlertView alloc] initWithTitle:ALERT_TITLE message:@"Your account has been created successfully. Please login with your credential." cancelButtonTitle:OK_BTN otherButtonTitles: nil, nil];
                
                [alertView setMessageFont:[UIFont fontWithName:CGRegular size:14]];
                [alertView setHandlerBlock:^(NSInteger buttonIndex, URBAlertView *alertView) {
                    [alertView hideWithCompletionBlock:^{

                        [UIView beginAnimations:nil context:NULL];
                        [UIView setAnimationDuration:1.3];
                        [UIView setAnimationTransition:UIViewAnimationTransitionFlipFromLeft forView:[[UIApplication sharedApplication] keyWindow] cache:YES];
                        [UIView commitAnimations];
                        
//                        [APP_DELEGATE setUpTabBarController];
                        [APP_DELEGATE movetoLogin];

                    }];
                }];
                [alertView showWithAnimation:URBAlertAnimationTopToBottom];
    if (IS_IPHONE_X){[alertView showWithAnimation:URBAlertAnimationDefault];}
                
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
    else if ([[result valueForKey:@"commandName"] isEqualToString:@"changepassword"])
    {
        if([[[result valueForKey:@"result"] valueForKey:@"response"] isEqualToString:@"true"])
        {
            NSMutableDictionary * tmpDict = [[NSMutableDictionary alloc] init];
            tmpDict=[[[NSUserDefaults standardUserDefaults] objectForKey:@"UserDict"] mutableCopy];
            [tmpDict setObject:txtPass.text forKey:@"localPassword"];
            [[NSUserDefaults standardUserDefaults] setObject:tmpDict forKey:@"UserDict"];
            [[NSUserDefaults standardUserDefaults] synchronize];

            URBAlertView *alertView = [[URBAlertView alloc] initWithTitle:ALERT_TITLE message:@"Your password has been changed successfully." cancelButtonTitle:OK_BTN otherButtonTitles: nil, nil];
            
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
