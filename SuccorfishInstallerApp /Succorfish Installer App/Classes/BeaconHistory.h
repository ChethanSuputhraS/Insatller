//
//  BeaconHistory.h
//  Succorfish Installer App
//
//  Created by Ashwin on 7/30/20.
//  Copyright © 2020 Kalpesh Panchasara. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface BeaconHistory : UIViewController
{
    UITableView * tblBeaconHistroy;
}
@property(nonatomic, strong)NSMutableDictionary * dictData;
@end

NS_ASSUME_NONNULL_END
