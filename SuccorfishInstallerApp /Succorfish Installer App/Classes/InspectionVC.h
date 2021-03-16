//
//  InspectionVC.h
//  Succorfish Installer App
//
//  Created by stuart watts on 06/03/2018.
//  Copyright © 2018 Kalpesh Panchasara. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PJRSignatureView.h"

@interface InspectionVC : UIViewController<UIScrollViewDelegate,UIPickerViewDelegate,UIPickerViewDataSource,UITextFieldDelegate,UITableViewDelegate,UITableViewDataSource,UITextFieldDelegate>
{
    UIScrollView * scrlContent;
    UITableView*tblFirstView,*tblSecondView,*tblThirdView;
    NSMutableArray*firstViewArray,*secondViewArray,*thirdViewArray;
    NSArray * arrayTextFieldTagValues;
    UIButton * moveBackBtn, * moveFrwdBtn, * btnShowMap;
    UIView * firstView ;
    UIScrollView * secondView, * thirdView;
    UILabel    * lblLine, * lblLastDate, * lblLastLat;
    NSInteger page;
    UIView * typeBackView;
    UIPickerView * deviceTypePicker;
    NSMutableArray * deviceTypeArr, * actionArr;
    UITextField * txtWarranty;

    
    UITextView * txtResult;
    
    PJRSignatureView * signatureView;
    UIView * signbkView, * PJSignbckView;
    UIImage * imgSign;
    UIImageView * signImgView, * imgLastArrow;
    UIButton * btnSignature;
    NSString *strErrorReport;
    
}
@property BOOL isFromeEdit;
@property (nonatomic,strong) NSMutableDictionary * detailDict;
@property(nonatomic,strong)NSString*installID;
@end
