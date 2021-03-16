//
//  InstallBeconVC.h
//  Succorfish Installer App
//
//  Created by Ashwin on 7/16/20.
//  Copyright © 2020 Kalpesh Panchasara. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AssetGroupVC.h"

NS_ASSUME_NONNULL_BEGIN

@interface InstallBeconVC : UIViewController
{
    UITableView * tblBeacon;
    UIButton * moveBackBtn;
    UIView * viewBGPicker,*viewListBattry ;
    NSString *strName;
}

@property(nonatomic,strong)NSMutableDictionary * DataDict;
@property(nonatomic,strong)NSString * strBLeID;

-(void)GetAssetSelected:(NSMutableDictionary *)dataDict isAssetGroup:(BOOL)isAssetGroup;
-(void)GetBeaconNumber:(NSMutableDictionary *)dataDictFromClass;

@end

NS_ASSUME_NONNULL_END
