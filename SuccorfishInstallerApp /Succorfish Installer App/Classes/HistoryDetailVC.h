//
//  HistoryDetailVC.h
//  Succorfish Installer App
//
//  Created by stuart watts on 10/03/2018.
//  Copyright © 2018 Kalpesh Panchasara. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HistoryDetailVC : UIViewController<UITableViewDelegate,UITableViewDataSource>
{
    UITableView * tblContent;
    NSArray * lblArr;
}
@property(nonatomic,strong) NSMutableDictionary * detailDict;
@property (nonatomic,strong) NSString * strType;
@property BOOL isFromSearch;
@end
