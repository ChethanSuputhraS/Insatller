//
//  HistoryVC.h
//  Succorfish Installer App
//
//  Created by stuart watts on 21/02/2018.
//  Copyright © 2018 Kalpesh Panchasara. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NYSegmentedControl.h"
#import "HistoryCustomCell.h"
#import "NewInstallVC.h"
#import "UnInstalledVC.h"
#import "InspectionVC.h"
#import "SSSearchBar.h"

@interface HistoryVC : UIViewController<UISearchBarDelegate,SSSearchBarDelegate>
{
    NYSegmentedControl *blueSegmentedControl;
    NSMutableArray * installArr, * inspectionArr, * unInstallArr, * arrSearchedResults;
    NSString * typeSelected;
    UITableView * tblContent;
    UILabel * lblNoData;
    SSSearchBar * histSeachbar;
    UIImageView * searchImgGlass;
    
    NSMutableArray * vesselArr, * regiNoArr;
    BOOL isVesselSearch, isSearching;
}
@end
