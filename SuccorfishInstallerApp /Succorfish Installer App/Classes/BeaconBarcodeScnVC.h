//
//  BeaconBarcodeScnVC.h
//  Succorfish Installer App
//
//  Created by Ashwin on 7/18/20.
//  Copyright © 2020 Kalpesh Panchasara. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RMScannerView.h"
#import "ZBarSDK.h"

NS_ASSUME_NONNULL_BEGIN

@interface BeaconBarcodeScnVC : UIViewController<UIAlertViewDelegate,UIBarPositioningDelegate,UITextFieldDelegate,ZBarReaderViewDelegate>
{
    RMScannerView * scannerView;
    
    UILabel * optLbl, * lblerror;
    
    UIButton * btnStart;
    
    UIView * viewMore, * viewOverLay, * backView;
    
    UITextField * txtBleID;
    
    UIButton * btncancel, * btnOk;
    
    BOOL isManual;
    
    ZBarReaderView * _reader;
    
    NSMutableDictionary * gotDeviceDetailDict;

}
@property (nonatomic,strong) NSString *  isFromInstall;

@end

NS_ASSUME_NONNULL_END
