//
//  InspectionCell.h
//  Succorfish Installer App
//
//  Created by srivatsa s pobbathi on 15/03/19.
//  Copyright © 2019 Kalpesh Panchasara. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIFloatLabelTextField.h"
@interface InspectionCell : UITableViewCell<UITextFieldDelegate>
{
    
}
@property(nonatomic,strong)UILabel*lblName;
@property(nonatomic,strong)UILabel*lblValue;
@property(nonatomic,strong)UILabel*lblLine;
@property(nonatomic,strong)UIImageView*imgArrow;
@property(nonatomic,strong)UIFloatLabelTextField*txtName;
@property(nonatomic,strong)UIFloatLabelTextField*txtZip;
@property(nonatomic,strong)UILabel*lblZipLine;
@property(nonatomic,strong)UILabel*lblPositionMsg;
@property(nonatomic,strong)UILabel*lblLastReport;
@end
