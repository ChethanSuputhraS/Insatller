//
//  GuideInstallVC.h
//  Succorfish Installer App
//
//  Created by stuart watts on 12/03/2018.
//  Copyright © 2018 Kalpesh Panchasara. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GuideInstallVC : UIViewController<UITableViewDelegate,UITableViewDataSource>
{
    UITableView * tblContent;
}
@property BOOL isfromInstallGuide;
@end
