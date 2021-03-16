//
//  NewInstallVC.h
//  Succorfish Installer App
//
//  Created by stuart watts on 21/02/2018.
//  Copyright © 2018 Kalpesh Panchasara. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CountryPicker.h"
#import "PJRSignatureView.h"

@interface NewInstallVC : UIViewController<UIScrollViewDelegate,UIPickerViewDelegate,UIPickerViewDataSource,CountryPickerDelegate,UITextFieldDelegate>
{
    
    UIScrollView * scrlContent;
    UIButton * moveBackBtn, * moveFrwdBtn;
    UIView * firstView, * back2Viw ;
    
    UIScrollView * secondView,* thirdView;
    NSInteger page;
    
    UIView * typeBackView;
    UIPickerView * deviceTypePicker;
    NSMutableArray * deviceTypeArr, * powerArr;

    NSMutableDictionary * lastLocationDict;
    
    UILabel  * lblLine, * lblCountry, * lblLastDate, * lblLastLat;
    UILabel * lblLastLocation;
    UIDatePicker * datePicker;
    UIView * backPickerView;
    CountryPicker * cntryPickerView;

    NSString * strContCode;
    

    PJRSignatureView * signatureView;
    UIView * signbkView, * PJSignbckView;
    UIImage * imgSign;
    UIImageView * signImgView, * imgLastArrow;
    UIButton * btnSignature, * btnShowMap;
    
    NSString * strErrorReport;
    BOOL isFromNextTest, isTestedAlready, isAllowtoGoAfterTest;


    NSMutableArray *firstViewArray,*secondViewArray,*thirdViewArray;
    NSArray*arrayTextFieldTagValues;
}
@property BOOL isFromeEdit;
@property (nonatomic,strong) NSMutableDictionary * detailDict;
@property(nonatomic,strong)NSString*installID;
@end
