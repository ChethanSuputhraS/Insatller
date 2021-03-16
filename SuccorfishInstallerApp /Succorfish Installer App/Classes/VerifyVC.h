//
//  VerifyVC.h
//  Succorfish Installer App
//
//  Created by stuart watts on 23/02/2018.
//  Copyright © 2018 Kalpesh Panchasara. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface VerifyVC : UIViewController<UITextFieldDelegate>
{
    UIScrollView * scrlContent;
    UIView * viewPopUp;
    
    UITextField * txtEmail;
    UILabel * lblHint;
    NSString * codeStr;
}
@property(nonatomic,strong)NSMutableDictionary * dataDict;
@property(nonatomic,strong)NSString  * strUserId;

@end
