//
//  InstallBeaconCell.h
//  Succorfish Installer App
//
//  Created by Ashwin on 7/16/20.
//  Copyright © 2020 Kalpesh Panchasara. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIFloatLabelTextField.h"

NS_ASSUME_NONNULL_BEGIN

@interface InstallBeaconCell : UITableViewCell
{
    
}

@property(nonatomic,strong)UILabel*lblScanDevice;
@property(nonatomic,strong)UILabel*lblBeaconType;
@property(nonatomic,strong)UILabel*lblBeacon;
@property(nonatomic,strong)UILabel*lblLine;
@property(nonatomic,strong)UIImageView*imgArrow;
@property(nonatomic,strong)UIFloatLabelTextField*txtName;

@property(nonatomic,strong)UILabel*lblScanTxt,*lblAsset;
@property(nonatomic,strong)UILabel*lbltxtName;
@property(nonatomic,strong)UILabel*lblBatteryType;
@property(nonatomic,strong)UILabel*lblAssestGroup;
@property(nonatomic,strong)UILabel*lblGroupAsset;
@property(nonatomic,strong)UILabel * lblBecTypeName;
@property(nonatomic,strong)UILabel * lblCellBgColor;
@end

NS_ASSUME_NONNULL_END
