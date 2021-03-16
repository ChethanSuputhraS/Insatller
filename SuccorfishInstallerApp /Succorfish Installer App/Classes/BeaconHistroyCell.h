//
//  BeaconHistroyCell.h
//  Succorfish Installer App
//
//  Created by Ashwin on 8/4/20.
//  Copyright © 2020 Kalpesh Panchasara. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface BeaconHistroyCell : UITableViewCell
{
    
}
@property(nonatomic,strong)UILabel*lblbeaconNum,*lblDate,*lblAsset,*lblName,*lblBeconType,*lblBatteryType,*lblStatus,*lblCellBgLine;
@property(nonatomic,strong)UILabel * lblCellBgColor;

@end

NS_ASSUME_NONNULL_END
