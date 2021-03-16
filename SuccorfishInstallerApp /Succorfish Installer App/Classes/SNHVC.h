//
//  SNHVC.h
//  Succorfish Installer App
//
//  Created by srivatsa s pobbathi on 29/03/19.
//  Copyright © 2019 Kalpesh Panchasara. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "customRadioButtonVC.h"
@interface SNHVC : UIViewController<UIScrollViewDelegate,UITextViewDelegate,UIPickerViewDelegate,UIPickerViewDataSource>
{
    UIScrollView*scrllView,*scrllView1,*scrllView2;
   int textSize,zz;
    UIButton*btnGo,*moveFrwdBtn,*moveBackBtn;
    UITextView*txtQ1,*txtQ2,*txtQ3,*txtQ4,*txtQ5,*txtQ6;
    UILabel*lblQ1PlaceHolder,*lblQ2PlaceHolder,*lblQ3PlaceHolder,*lblQ4PlaceHolder,*lblQ5PlaceHolder,*lblQ6PlaceHolder,*lblHazard;
    UIView*viewq1,*viewq2,*viewq3,*viewq4,*viewq5,*viewq6,*typeBackView;
    UIPickerView * hazardTypePicker;
    customRadioButtonVC*btnRadioView1,*btnRadioView2,*btnRadioView3,*btnRadioView4,*btnRadioView5;
    NSMutableArray*arrayHandS;
    int intscreen;
    long intSelectedHazrd;
    NSArray*hazardArray;
    long indexHazard;
    NSString *strInstallID;
    UIImageView * btmView;
    bool isNextClikced;
}
@property(nonatomic,strong)NSString*strType;
@property (nonatomic) BOOL isFromeEdit;
@property(nonatomic,strong)NSMutableDictionary*detailDict;

@end
