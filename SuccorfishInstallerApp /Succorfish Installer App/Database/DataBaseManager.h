//
//  DataBaseManager.h
//  Secure Windows App
//
//  Created by i-MaC on 10/15/16.
//  Copyright © 2016 Oneclick. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AppDelegate.h"
#import <sqlite3.h>
@interface DataBaseManager : NSObject
{
    NSString *path;
	NSString* _dataBasePath;
	sqlite3 *_database;
	BOOL copyDb;
    BOOL ret;
    BOOL status;
    BOOL querystatus;
}
+(DataBaseManager*)dataBaseManager;
-(NSString*) getDBPath;
-(void)openDatabase;
-(BOOL)execute:(NSString*)sqlQuery resultsArray:(NSMutableArray*)dataTable;
-(BOOL)execute:(NSString*)sqlStatement;
-(int)executeSw:(NSString*)sqlStatement;


#pragma mark- ***************
-(NSInteger)getScalar:(NSString*)sqlStatement;
-(NSString*)getValue1:(NSString*)sqlStatement;

-(BOOL)updateMessage:(NSDictionary *)dictInfo with:(NSString *)user_id;
- (NSMutableArray *)getHistoryData;
-(BOOL)executeAddress:(NSString*)sqlQuery resultsArray:(NSMutableArray*)dataTable;
-(BOOL)updateQuery:(NSDictionary *)dictInfo with:(NSString *)user_id;

-(BOOL)Create_Device_Table;
-(BOOL)Create_Inspection_Table;
-(BOOL)Create_Inspection_Photos_Table;
-(BOOL)Create_Install_Table;
-(BOOL)Create_Install_Photo_Table;
-(BOOL)Create_Uninstall_Table;
-(BOOL)Create_Question_Table;
-(BOOL)Create_Beacon_Install_Table;
-(void)addcolumnsToInstallationTable;
-(BOOL)Create_Asset_Group_Table;

-(void)saveVesselsintoDatabase:(NSMutableArray *)arrVessels;
-(void)addDeviceIdcolumnstoUnInstall;
-(void)addDeviceIdcolumnstoUnInspection;
-(void)addDeviceIdcolumnstoInstalls;
-(void)addPowerValuecolumnstoInstalls;
-(void)addActionValuescolumnstoInspection;
-(BOOL)Create_Extra_Vessel_Table;
-(void)SaveVesselinExtraTable:(NSMutableArray *)arrVessels;

-(void)addlocalOwnerSignscolumnstoInspection;
-(void)addServerOwnerSignscolumnstoInspection;

@end







