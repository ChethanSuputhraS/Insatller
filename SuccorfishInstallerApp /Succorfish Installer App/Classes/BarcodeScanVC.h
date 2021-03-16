//
//  BarcodeScanVC.h
//  Succorfish Installer App
//
//  Created by stuart watts on 22/02/2018.
//  Copyright © 2018 Kalpesh Panchasara. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RMScannerView.h"
#import "ZBarSDK.h"

@interface BarcodeScanVC : UIViewController<UIAlertViewDelegate,UIBarPositioningDelegate,UITextFieldDelegate,ZBarReaderViewDelegate>
{
    RMScannerView * scannerView;
    
    UILabel * optLbl, * lblerror;
    
    UIButton * btnStart;
    
    UIView * viewMore, * viewOverLay, * backView;
    
    UITextField * txtEmi;
    
    UIButton * btncancel, * btnOk;
    
    BOOL isManual;
    
    ZBarReaderView * _reader;
    
    NSMutableDictionary * gotDeviceDetailDict;

}
@property (nonatomic,strong) NSString *  isFromInstall;
@end
