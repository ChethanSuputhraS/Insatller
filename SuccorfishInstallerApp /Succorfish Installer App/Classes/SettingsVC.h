//
//  SettingsVC.h
//  Succorfish Installer App
//
//  Created by stuart watts on 21/02/2018.
//  Copyright © 2018 Kalpesh Panchasara. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MoreOptionCell.h"

@interface SettingsVC : UIViewController<UITableViewDelegate,UITableViewDataSource>
{
    UITableView * tblContent;
}
@end
