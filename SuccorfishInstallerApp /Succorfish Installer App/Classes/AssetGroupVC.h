//
//  BeconGroupVC.h
//  Succorfish Installer App
//
//  Created by Ashwin on 7/17/20.
//  Copyright © 2020 Kalpesh Panchasara. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface BeconGroupVC : UIViewController
{
    UIButton * btnAsset,* btnAssetGrop;
}

@property BOOL isFromeEdit;
@property (nonatomic,strong) NSMutableDictionary * detailDict;
@property(nonatomic,strong)NSString*installID;

@end

NS_ASSUME_NONNULL_END
