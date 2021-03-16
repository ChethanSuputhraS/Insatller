//
//  LoginVC.h
//  Succorfish Installer App
//
//  Created by stuart watts on 19/02/2018.
//  Copyright © 2018 Kalpesh Panchasara. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "URLManager.h"

@interface LoginVC : UIViewController<UITextFieldDelegate,URLManagerDelegate>
{
    UIScrollView * scrlContent;
    UIView * viewPopUp;
    
    UITextField * txtEmail;
    UITextField * txtPassword;
    UITextField *txtForgotpasswordEmail;
    UILabel *lblerror;
    
    UIButton *btncancel;
    UIButton *btnOk;
    
    UIButton * btnLogin;
    UIButton * btnRegister;
    UIButton * btnForgotPassword;
    
    UIActivityIndicatorView * activityIndicator;
    UIActivityIndicatorView * ForgotpasswordIndicator;
    
    UILabel * lblLine;
    
    
    UIView * viewMore;
    UIView * viewOverLay;
    UIView * backView;

    UIButton * btnShowPass;
    
    BOOL isShowPassword;
    
    UIButton * btnRemember;
    UIImageView * imgCheck;
}

@end
