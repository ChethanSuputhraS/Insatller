//
//  UnInstalledVC.h
//  Succorfish Installer App
//
//  Created by stuart watts on 03/03/2018.
//  Copyright © 2018 Kalpesh Panchasara. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PJRSignatureView.h"

@interface UnInstalledVC : UIViewController<UIScrollViewDelegate,UIPickerViewDelegate,UIPickerViewDataSource,UITextFieldDelegate,UITableViewDelegate,UITableViewDataSource,UITextFieldDelegate>
{
    UIScrollView * scrlContent;
    UIButton * moveBackBtn, * moveFrwdBtn;
    UIView * firstView ;
    UIScrollView * secondView, * thirdView;
    UILabel      * lblLine;
    NSInteger page;
    UIView * typeBackView;
    UIPickerView * deviceTypePicker;
    NSMutableArray * deviceTypeArr, * powerArr,*firstViewArray,*secondViewArray;
    NSArray*arrayTextFieldTagValues;

    
    PJRSignatureView * signatureView;
    UIView * signbkView, * PJSignbckView;
    UIImage * imgSign;
    UIImageView * signImgView;
    UIButton * btnSignature;
    
    BOOL isInstalledDetailSynced;
    NSString * serverInstallationID;
    NSString * strErrorReport;

    UITableView *tblFirstView,*tblSecondView;
}
@property BOOL isFromeEdit;
@property (nonatomic,strong) NSMutableDictionary * detailDict;
@property(nonatomic,strong)NSString*installID;
@end
