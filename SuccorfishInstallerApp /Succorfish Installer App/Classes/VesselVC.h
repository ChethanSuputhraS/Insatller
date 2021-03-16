//
//  VesselVC.h
//  Succorfish Installer App
//
//  Created by stuart watts on 27/02/2018.
//  Copyright © 2018 Kalpesh Panchasara. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface VesselVC : UIViewController<UISearchBarDelegate,UITableViewDelegate,UITableViewDataSource>
{
    UISearchBar * txtVessels, * txtRegisterNo;
    UIView * mainView;
    NSMutableArray * vesselArr, * regiNoArr, * arrSearchedResults;
    BOOL isVesselSearch, isSearching;
    UITableView * tblView;
}
@end
