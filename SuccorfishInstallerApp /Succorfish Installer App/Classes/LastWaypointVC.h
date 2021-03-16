//
//  LastWaypointVC.h
//  Succorfish Installer App
//
//  Created by stuart watts on 24/04/2018.
//  Copyright © 2018 Kalpesh Panchasara. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LastWaypointVC : UIViewController<UITableViewDelegate,UITableViewDataSource>
{
    UIView * callView, * installView;
    UITableView * tblView;
    NSMutableArray  * detailArr;
    NSArray * lblArr;

}
@property (nonatomic,strong) NSMutableDictionary * detailDict;
@property (nonatomic,strong) NSString * strReasonToCome;
@property (nonatomic,strong) NSString * strReportType;

@property BOOL isfromHistory;

@end
