//
//  SignupVC.h
//  Succorfish Installer App
//
//  Created by stuart watts on 20/02/2018.
//  Copyright © 2018 Kalpesh Panchasara. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "URLManager.h"
#import "CountryPicker.h"

@interface SignupVC : UIViewController<UITextFieldDelegate,URLManagerDelegate,CountryPickerDelegate>
{
    UIScrollView * scrlContent;
    UIView * viewPopUp;
    
    UITextField * txtEmail;
    UITextField * txtName;
    UITextField * txtBusiness;
    UITextField * txtAddress;
    UITextField * txtMobile;

    UIButton * btnNext;

    UILabel *lblerror;
    UILabel * lblLine;
    UIView * viewOverLay;
    
    UILabel * lblCountry;
    UIButton * btnCountry;

    UIView * backPickerView;
    CountryPicker * cntryPickerView;
    UIImageView * imgCountry;
    UIImageView * imgLogo;
    UIImageView * imgBack;
}
@property BOOL isFromEdit;
@end
