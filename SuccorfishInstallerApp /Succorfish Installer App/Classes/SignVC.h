//
//  SignVC.h
//  Succorfish Installer App
//
//  Created by stuart watts on 24/03/2018.
//  Copyright © 2018 Kalpesh Panchasara. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PJRSignatureView.h"

@interface SignVC : UIViewController
{
    PJRSignatureView * signatureView;
    UIView * signbkView, * PJSignbckView;
    UIImage * imgSign;
    UIImageView * installerSignImgView, * ownerSignImgView;
    UIButton * btnOwner, *btnInstaller;
}
@property BOOL isFromEdit;
@property (nonatomic,strong) NSString * strFromView;
@property (nonatomic,strong) NSString * strInstallId;
@property (nonatomic,strong) NSMutableDictionary * detailDict;

@end
