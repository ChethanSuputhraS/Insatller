//
//  InstallGuidePDF.h
//  Succorfish Installer App
//
//  Created by stuart watts on 10/04/2018.
//  Copyright © 2018 Kalpesh Panchasara. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface InstallGuidePDF : UIViewController
{
   BOOL isInLandscapeMode;
    UIView * viewHeader;
    UILabel * lblTitle;
    UIImageView * backImg;
    UIButton*btnBack;
}
@property(nonatomic,strong) NSString * strFrom;
@property(nonatomic,strong) NSString * strTitle;

@property BOOL isfromInstallGuide;
@end
