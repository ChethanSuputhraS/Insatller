//
//  PasswordVC.h
//  Succorfish Installer App
//
//  Created by stuart watts on 24/02/2018.
//  Copyright © 2018 Kalpesh Panchasara. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PasswordVC : UIViewController<UITextFieldDelegate>
{
    UIScrollView * scrlContent;
    UIView * viewPopUp;
    UITextField * txtPass, * txtConfPass, * txtCurrentPass;
    UIButton * btnShowPass, * btnShowConfPass, * btnCurrentPass;
    BOOL isPassShow, isConfPassShow, isCurrentPass;
    UILabel * lblLine;
}
@property(nonatomic,strong) NSMutableDictionary * dataDict;
@property(nonatomic,strong) NSString * strUserId;
@property BOOL isfromEdit;
@end
