//
//  ViewPDFVC.h
//  Succorfish Installer App
//
//  Created by stuart watts on 19/03/2018.
//  Copyright © 2018 Kalpesh Panchasara. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ViewPDFVC : UIViewController
{
    
}
@property (nonatomic,strong) NSString * strPdfUrl;
@property (nonatomic,strong) NSString * strReportType;
@property (nonatomic,strong) NSMutableDictionary * detailDict;
@property (nonatomic,strong) NSString * strDate;
@property (nonatomic,strong) NSString * strIMEI;
@property (nonatomic,strong) NSString * strVessel;

@end
