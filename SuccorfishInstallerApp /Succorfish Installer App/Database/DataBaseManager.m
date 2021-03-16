//
//  DataBaseManager.m
//  Secure Windows App
//
//  Created by i-MaC on 10/15/16.
//  Copyright © 2016 Oneclick. All rights reserved.
//

#import "DataBaseManager.h"
static DataBaseManager * dataBaseManager = nil;

@implementation DataBaseManager
#pragma mark - DataBaseManager initialization
-(id) init
{
    self = [super init];
	if (self)
    {
		// get full path of database in documents directory
		NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
		path = [paths objectAtIndex:0];
		_dataBasePath = [path stringByAppendingPathComponent:@"InstallerApp.sqlite"];
        
    NSLog(@"data base path:%@",_dataBasePath);
		[self openDatabase];
    }
	return self;
}
+(DataBaseManager*)dataBaseManager
{
    static dispatch_once_t _singletonPredicate;
    dispatch_once(&_singletonPredicate, ^{
        if (!dataBaseManager)
        {
            dataBaseManager = [[super alloc]init];
        }
    });
	return dataBaseManager;
}
-(void)checkDatabasetoCreate
{
    
}
- (NSString *) getDBPath
{
	
	//Search for standard documents using NSSearchPathForDirectoriesInDomains
	//First Param = Searching the documents directory
	//Second Param = Searching the Users directory and not the System
	//Expand any tildes and identify home directories.
    
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory , NSUserDomainMask, YES);
	NSString *documentsDir = [paths objectAtIndex:0];
	return [documentsDir stringByAppendingPathComponent:@"InstallerApp.sqlite"];
    
}
-(void)openDatabase
{
	BOOL ok;
	NSError *error;
	
	/*
	 * determine if database exists.
	 * create a file manager object to test existence
	 *
	 */
	NSFileManager *fm = [NSFileManager defaultManager]; // file manager
	ok = [fm fileExistsAtPath:_dataBasePath];
	
	// if database not there, copy from resource to path
	if (!ok)
    {
        // location in resource bundle
        NSString *appPath = [[[NSBundle mainBundle] resourcePath]
                             stringByAppendingPathComponent:@"InstallerApp.sqlite"];
        if ([fm fileExistsAtPath:appPath])
        {
            // copy from resource to where it should be
            copyDb = [fm copyItemAtPath:appPath toPath:_dataBasePath error:&error];
            
            if (error!=nil)
            {
                copyDb = FALSE;
            }
            ok = copyDb;
        }
    }
    
    
    // open database
    if (sqlite3_open([_dataBasePath UTF8String], &_database) != SQLITE_OK)
    {
        sqlite3_close(_database); // in case partially opened
        _database = nil; // signal open error
    }
    
    if (!copyDb && !ok)
    { // first time and database not copied
        ok = [self Create_Device_Table]; // create empty database
        if (ok)
        {
            // Populating Table first time from the keys.plist
            /*	NSString *pListPath = [[NSBundle mainBundle] pathForResource:@"ads" ofType:@"plist"];
             NSArray *contents = [NSArray arrayWithContentsOfFile:pListPath];
             for (NSDictionary* dictionary in contents) {
             
             NSArray* keys = [dictionary allKeys];
             [self execute:[NSString stringWithFormat:@"insert into ads values('%@','%@','%@')",[dictionary objectForKey:[keys objectAtIndex:0]], [dictionary objectForKey:[keys objectAtIndex:1]],[dictionary objectForKey:[keys objectAtIndex:2]]]];
             }*/
        }
    }
    
    if (!ok)
    {
        // problems creating database
        NSAssert1(0, @"Problem creating database [%@]",
                  [error localizedDescription]);
    }
    
}

#pragma mark - Create Installer Table
-(BOOL)Create_Device_Table
{
    int rc;
    
//
	// SQL to create new database
    NSArray* queries = [NSArray arrayWithObjects:@"CREATE TABLE 'tbl_device_type' ( 'device_type_local_id' INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT UNIQUE, 'device_type_server_id' INTEGER, 'device_type_name' VARCHAR(255), 'device_type_iemi_no' VARCHAR(255), 'device_type_created_date' VARCHAR(255), 'device_type_update_date' VARCHAR(255), 'is_sync' INTEGER DEFAULT 0 )",nil];
    
    if(queries != nil)
    {
        for (NSString* sql in queries)
        {
            sqlite3_stmt *stmt;
            rc = sqlite3_prepare_v2(_database, [sql UTF8String], -1, &stmt, NULL);
            ret = (rc == SQLITE_OK);
            if (ret)
            {
                // statement built, execute
                rc = sqlite3_step(stmt);
                ret = (rc == SQLITE_DONE);
                sqlite3_finalize(stmt); // free statement
                //sqlite3_reset(stmt);
            }
        }
    }
    return ret;
}

#pragma mark - Create Inspection Table
-(BOOL)Create_Inspection_Table;
{
    int rc;
    
    // SQL to create new database
    NSArray* queries = [NSArray arrayWithObjects:
                        @"CREATE TABLE 'tbl_inspection' ( 'id' INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT UNIQUE, 'server_id' INTEGER, 'user_id' INTEGER, 'imei' VARCHAR(255), 'insp_device_type_local_id' INTEGER, 'insp_device_type_server_id' INTEGER, 'device_type' VARCHAR(255), 'warranty' VARCHAR(255), 'insp_vessel_local_id' INTEGER, 'vessel_id' INTEGER, 'vesselname' VARCHAR(255), 'portno' VARCHAR(255), 'owner_name' VARCHAR(255), 'owner_address' VARCHAR(255), 'owner_email' VARCHAR(255), 'owner_phone_no' VARCHAR(255), 'insp_result' VARCHAR(255), 'insp_action_taken' VARCHAR(255), 'insp_warranty_return' VARCHAR(255), 'created_at' VARCHAR(255), 'updated_at' VARCHAR(255), 'is_sync' INTEGER DEFAULT 0 )",nil];
    
    if(queries != nil)
    {
        for (NSString * sql in queries)
        {
            
            sqlite3_stmt *stmt;
            rc = sqlite3_prepare_v2(_database, [sql UTF8String], -1, &stmt, NULL);
            ret = (rc == SQLITE_OK);
            if (ret)
            {
                // statement built, execute
                rc = sqlite3_step(stmt);
                ret = (rc == SQLITE_DONE);
                sqlite3_finalize(stmt); // free statement
                //sqlite3_reset(stmt);
            }
        }
    }
    return ret;
}
#pragma mark - Create Inspection Photos Table
-(BOOL)Create_Inspection_Photos_Table;
{
    int rc;
    
    // SQL to create new database
    NSArray* queries = [NSArray arrayWithObjects:
                        @"CREATE TABLE 'tbl_inspection_photo' ( 'insp_photo_local_id' INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT UNIQUE, 'insp_photo_server_id' INTEGER, 'insp_photo_local_url' VARCHAR(255), 'insp_photo_server_url' VARCHAR(255), 'insp_local_id' INTEGER, 'insp_server_id' INTEGER, 'insp_photo_user_id' INTEGER, 'insp_photo_created_date' VARCHAR(255), 'insp_photo_update_date' VARCHAR(255), 'is_sync' INTEGER DEFAULT 0 )",nil];
    
    if(queries != nil)
    {
        for (NSString * sql in queries)
        {
            
            sqlite3_stmt *stmt;
            rc = sqlite3_prepare_v2(_database, [sql UTF8String], -1, &stmt, NULL);
            ret = (rc == SQLITE_OK);
            if (ret)
            {
                // statement built, execute
                rc = sqlite3_step(stmt);
                ret = (rc == SQLITE_DONE);
                sqlite3_finalize(stmt); // free statement
                //sqlite3_reset(stmt);
            }
        }
    }
    return ret;
}

#pragma mark - Create Installation Table
-(BOOL)Create_Install_Table;
{
    int rc;
    
    // SQL to create new database
    NSArray* queries = [NSArray arrayWithObjects:
                        @"CREATE TABLE 'tbl_install' ( 'id' INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT UNIQUE, 'server_id' INTEGER, 'user_id' INTEGER, 'imei' INTEGER, 'device_type_id' INTEGER, 'device_type_server_id' INTEGER, 'device_type' VARCHAR ( 255 ), 'date' VARCHAR ( 255 ), 'latitude' VARCHAR ( 255 ), 'longitude' VARCHAR ( 255 ), 'country_code' VARCHAR ( 255 ), 'installation_county' VARCHAR ( 255 ), 'vessel_local_id' INTEGER, 'vessel_id' INTEGER, 'vesselname' VARCHAR ( 255 ), 'portno' VARCHAR ( 255 ), 'warranty' VARCHAR ( 255 ), 'power' VARCHAR ( 255 ), 'device_install_location' TEXT, 'owner_name' VARCHAR ( 255 ), 'owner_address' TEXT,'owner_city' TEXT,'owner_state' TEXT,'owner_zipcode' TEXT, 'owner_email' VARCHAR ( 255 ), 'owner_phone_no' VARCHAR ( 255 ), 'local_sign_url' VARCHAR ( 255 ), 'server_sign_url' VARCHAR ( 255 ), 'pdf_url' VARCHAR ( 255 ), 'created_at' VARCHAR ( 255 ), 'updated_at' VARCHAR ( 255 ), 'is_sync' INTEGER DEFAULT 0, 'is_install' INTEGER DEFAULT 0 )",nil];
    
    if(queries != nil)
    {
        for (NSString * sql in queries)
        {
            
            sqlite3_stmt *stmt;
            rc = sqlite3_prepare_v2(_database, [sql UTF8String], -1, &stmt, NULL);
            ret = (rc == SQLITE_OK);
            if (ret)
            {
                // statement built, execute
                rc = sqlite3_step(stmt);
                ret = (rc == SQLITE_DONE);
                sqlite3_finalize(stmt); // free statement
                //sqlite3_reset(stmt);
            }
        }
    }
    return ret;
}
#pragma mark - Create Install Photos Table
-(BOOL)Create_Install_Photo_Table;
{
    int rc;
    
    // SQL to create new database
    NSArray* queries = [NSArray arrayWithObjects:
                        @"CREATE TABLE 'tbl_installer_photo' ( 'inst_photo_local_id' INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT UNIQUE, 'inst_photo_server_id' INTEGER, 'inst_photo_local_url' VARCHAR(255), 'inst_photo_server_url' VARCHAR(255), 'inst_local_id' INTEGER, 'inst_server_id' INTEGER, 'inst_photo_user_id' INTEGER, 'insp_photo_created_date' VACHAR(255), 'insp_photo_update_date' VACHAR(255),'photo_type' VACHAR(255), 'is_sync' INTEGER DEFAULT 0 )",nil];
    
    if(queries != nil)
    {
        for (NSString * sql in queries)
        {
            
            sqlite3_stmt *stmt;
            rc = sqlite3_prepare_v2(_database, [sql UTF8String], -1, &stmt, NULL);
            ret = (rc == SQLITE_OK);
            if (ret)
            {
                // statement built, execute
                rc = sqlite3_step(stmt);
                ret = (rc == SQLITE_DONE);
                sqlite3_finalize(stmt); // free statement
                //sqlite3_reset(stmt);
            }
        }
    }
    return ret;
}

#pragma mark - Create UnInstall Table
-(BOOL)Create_Uninstall_Table;
{
    int rc;
    
    // SQL to create new database
    NSArray* queries = [NSArray arrayWithObjects:
                        @"CREATE TABLE 'tbl_uninstall' ( 'id' INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT UNIQUE, 'server_id' INTEGER, 'user_id' INTEGER, 'imei' VARCHAR ( 255 ), 'device_type' VARCHAR ( 255 ), 'unvessel_local_id' INTEGER, 'vessel_id' INTEGER, 'vesselname' VARCHAR ( 255 ), 'portno' VARCHAR ( 255 ), 'warranty' VARCHAR ( 255 ), 'owner_name' VARCHAR ( 255 ), 'owner_address' TEXT, 'owner_email' VARCHAR ( 255 ), 'owner_phone_no' VARCHAR ( 255 ), 'local_sign_url' VARCHAR ( 255 ), 'server_sign_url' VARCHAR ( 255 ), 'created_at' VARCHAR ( 255 ), 'updated_at' VARCHAR ( 255 ), 'is_sync' INTEGER DEFAULT 0 )",nil];
    
    if(queries != nil)
    {
        for (NSString * sql in queries)
        {
            
            sqlite3_stmt *stmt;
            rc = sqlite3_prepare_v2(_database, [sql UTF8String], -1, &stmt, NULL);
            ret = (rc == SQLITE_OK);
            if (ret)
            {
                // statement built, execute
                rc = sqlite3_step(stmt);
                ret = (rc == SQLITE_DONE);
                sqlite3_finalize(stmt); // free statement
                //sqlite3_reset(stmt);
            }
        }
    }
    return ret;
}

#pragma mark - Create Question Table
-(BOOL)Create_Question_Table;
{
    int rc;
    
    // SQL to create new database
    NSArray* queries = [NSArray arrayWithObjects:
                        @"CREATE TABLE 'tbl_question' ( 'id' INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT UNIQUE,'install_id' VARCHAR ( 255 ),'type' VARCHAR ( 255 ),'q1' VARCHAR ( 255 ),'q1ans' VARCHAR ( 255 ) ,'q2' VARCHAR ( 255 ),'q2ans' VARCHAR ( 255 ),'q3' VARCHAR ( 255 ),'q3ans' VARCHAR ( 255 ),'q4' VARCHAR ( 255 ),'q4ans' VARCHAR ( 255 ),'q5' VARCHAR ( 255 ),'q5ans' VARCHAR ( 255 ),'q6' VARCHAR ( 255 ),'q6ans' VARCHAR ( 255 ))",nil];
    
    if(queries != nil)
    {
        for (NSString * sql in queries)
        {
            
            sqlite3_stmt *stmt;
            rc = sqlite3_prepare_v2(_database, [sql UTF8String], -1, &stmt, NULL);
            ret = (rc == SQLITE_OK);
            if (ret)
            {
                // statement built, execute
                rc = sqlite3_step(stmt);
                ret = (rc == SQLITE_DONE);
                sqlite3_finalize(stmt); // free statement
                //sqlite3_reset(stmt);
            }
        }
    }
    return ret;
}

#pragma mark - Create Vessels Table
-(BOOL)Create_Vessels_Table;
{
    int rc;
    
    // SQL to create new database
    NSArray* queries = [NSArray arrayWithObjects:
                        @"CREATE TABLE 'tbl_vessel_asset' ( 'vessel_local_id' INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT UNIQUE, 'vessel_server_id' INTEGER, 'vessel_name' VARCHAR(255), 'vessel_regi_no' VARCHAR(255), 'vessel_created_date' VARCHAR(255), 'vessel_update_date' VARCHAR(255), 'is_sync' INTEGER DEFAULT 0 )",nil];
    
    if(queries != nil)
    {
        for (NSString * sql in queries)
        {
            
            sqlite3_stmt *stmt;
            rc = sqlite3_prepare_v2(_database, [sql UTF8String], -1, &stmt, NULL);
            ret = (rc == SQLITE_OK);
            if (ret)
            {
                // statement built, execute
                rc = sqlite3_step(stmt);
                ret = (rc == SQLITE_DONE);
                sqlite3_finalize(stmt); // free statement
                //sqlite3_reset(stmt);
            }
        }
    }
    return ret;
}

-(BOOL)Create_Extra_Vessel_Table
{
    int rc;
    
    // SQL to create new database
    NSArray* queries = [NSArray arrayWithObjects:
                        @"CREATE TABLE 'tbl_vessel_extra' ( 'vessel_local_id' INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT, 'vessel_succorfish_id' TEXT, 'vessel_account_id' TEXT, 'vessel_name' TEXT, 'vessel_regi_no' TEXT )",nil];
    
    if(queries != nil)
    {
        for (NSString * sql in queries)
        {
            
            sqlite3_stmt *stmt;
            rc = sqlite3_prepare_v2(_database, [sql UTF8String], -1, &stmt, NULL);
            ret = (rc == SQLITE_OK);
            if (ret)
            {
                // statement built, execute
                rc = sqlite3_step(stmt);
                ret = (rc == SQLITE_DONE);
                sqlite3_finalize(stmt); // free statement
                //sqlite3_reset(stmt);
            }
        }
    }
    return ret;
}
-(BOOL)Create_Beacon_Install_Table
{
    int rc;
    
    // SQL to create new database
    NSArray* queries = [NSArray arrayWithObjects:
                        @"CREATE TABLE 'tbl_Beacon_install' ( 'id' INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT, 'server_id' VARCHAR(255), 'user_id' VARCHAR(255), 'beacon_number' VARCHAR(255), 'asset_id' VARCHAR(255), 'asset_group_id' VARCHAR(255), 'beacon_type' VARCHAR(255), 'name' VARCHAR(255),'battery_type' VARCHAR(255), 'date' VARCHAR(255), 'latitude' VARCHAR(255), 'longitude' VARCHAR(255), 'is_sync' VARCHAR(255), 'pdf_url' VARCHAR(255), 'created_at' VARCHAR(255), 'compleate_status' VARCHAR(255), 'is_active' VARCHAR(255) )",nil];
    
    if(queries != nil)
    {
        for (NSString * sql in queries)
        {
            
            sqlite3_stmt *stmt;
            rc = sqlite3_prepare_v2(_database, [sql UTF8String], -1, &stmt, NULL);
            ret = (rc == SQLITE_OK);
            if (ret)
            {
                // statement built, execute
                rc = sqlite3_step(stmt);
                ret = (rc == SQLITE_DONE);
                sqlite3_finalize(stmt); // free statement
                //sqlite3_reset(stmt);
            }
        }
    }
    return ret;
}
-(BOOL)Create_Asset_Group_Table
{
    int rc;
    
    // SQL to create new database
    NSArray* queries = [NSArray arrayWithObjects:
                        @"CREATE TABLE 'tbl_Asset_Group' ( 'id' INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT, 'account_id' VARCHAR(255), 'group_id' VARCHAR(255), 'name' VARCHAR(255), 'discription' VARCHAR(255))",nil];
    
    if(queries != nil)
    {
        for (NSString * sql in queries)
        {
            
            sqlite3_stmt *stmt;
            rc = sqlite3_prepare_v2(_database, [sql UTF8String], -1, &stmt, NULL);
            ret = (rc == SQLITE_OK);
            if (ret)
            {
                // statement built, execute
                rc = sqlite3_step(stmt);
                ret = (rc == SQLITE_DONE);
                sqlite3_finalize(stmt); // free statement
                //sqlite3_reset(stmt);
            }
        }
    }
    return ret;
}
-(void)addDeviceIdcolumnstoUnInstall
{
    sqlite3_stmt *createStmt = nil;
    
    NSString *query = [NSString stringWithFormat:@"ALTER TABLE tbl_uninstall ADD COLUMN succor_device_id TEXT"];
    
    if (sqlite3_prepare_v2(_database, [query UTF8String], -1, &createStmt, NULL) == SQLITE_OK)
    {
        sqlite3_exec(_database, [query UTF8String], NULL, NULL, NULL);
    }
    else
    {
        NSLog(@"The succor_device_id table already exist in tbl_uninstall");
    }
    
    sqlite3_finalize(createStmt);
}
-(void)addDeviceIdcolumnstoUnInspection
{
    sqlite3_stmt *createStmt = nil;
    
    NSString *query = [NSString stringWithFormat:@"ALTER TABLE tbl_inspection ADD COLUMN succor_device_id TEXT"];
    
    if (sqlite3_prepare_v2(_database, [query UTF8String], -1, &createStmt, NULL) == SQLITE_OK)
    {
        sqlite3_exec(_database, [query UTF8String], NULL, NULL, NULL);
    }
    else
    {
        NSLog(@"The succor_device_id table already exist in tbl_inspection");
    }
    
    sqlite3_finalize(createStmt);
}
-(void)addDeviceIdcolumnstoInstalls
{
    sqlite3_stmt *createStmt = nil;
    
    NSString *query = [NSString stringWithFormat:@"ALTER TABLE tbl_install ADD COLUMN succor_device_id TEXT"];
    
    if (sqlite3_prepare_v2(_database, [query UTF8String], -1, &createStmt, NULL) == SQLITE_OK)
    {
        sqlite3_exec(_database, [query UTF8String], NULL, NULL, NULL);
    }
    else
    {
        NSLog(@"The succor_device_id table already exist in tbl_install");
    }
    
    sqlite3_finalize(createStmt);
}
-(void)addPowerValuecolumnstoInstalls
{
    sqlite3_stmt *createStmt = nil;
    
    NSString *query = [NSString stringWithFormat:@"ALTER TABLE tbl_install ADD COLUMN powervalue TEXT"];
    
    if (sqlite3_prepare_v2(_database, [query UTF8String], -1, &createStmt, NULL) == SQLITE_OK)
    {
        sqlite3_exec(_database, [query UTF8String], NULL, NULL, NULL);
    }
    else
    {
        NSLog(@"The powervalue table already exist in tbl_install");
    }
    
    sqlite3_finalize(createStmt);
}
-(void)addActionValuescolumnstoInspection
{
    sqlite3_stmt *createStmt = nil;
    
    NSString *query = [NSString stringWithFormat:@"ALTER TABLE tbl_inspection ADD COLUMN actionvalue TEXT"];
    
    if (sqlite3_prepare_v2(_database, [query UTF8String], -1, &createStmt, NULL) == SQLITE_OK)
    {
        sqlite3_exec(_database, [query UTF8String], NULL, NULL, NULL);
    }
    else
    {
        NSLog(@"The actionvalue table already exist in tbl_inspection");
    }
    
    sqlite3_finalize(createStmt);
}
-(void)addlocalOwnerSignscolumnstoInspection
{
    sqlite3_stmt *createStmt = nil;
    
    NSString *query = [NSString stringWithFormat:@"ALTER TABLE tbl_inspection ADD COLUMN local_owner_sign TEXT"];
    
    if (sqlite3_prepare_v2(_database, [query UTF8String], -1, &createStmt, NULL) == SQLITE_OK)
    {
        sqlite3_exec(_database, [query UTF8String], NULL, NULL, NULL);
    }
    else
    {
        NSLog(@"The actionvalue table already exist in tbl_inspection");
    }
    
    sqlite3_finalize(createStmt);
}
-(void)addServerOwnerSignscolumnstoInspection
{
    sqlite3_stmt *createStmt = nil;
    
    NSString *query = [NSString stringWithFormat:@"ALTER TABLE tbl_inspection ADD COLUMN server_owner_sign TEXT"];
    
    if (sqlite3_prepare_v2(_database, [query UTF8String], -1, &createStmt, NULL) == SQLITE_OK)
    {
        sqlite3_exec(_database, [query UTF8String], NULL, NULL, NULL);
    }
    else
    {
        NSLog(@"The actionvalue table already exist in tbl_inspection");
    }
    
    sqlite3_finalize(createStmt);
}

#pragma mark - Insert Query
/*
 * Method to execute the simple queries
 */
-(BOOL)execute:(NSString*)sqlStatement
{
	sqlite3_stmt *statement = nil;
    status = FALSE;
	//NSLog(@"%@",sqlStatement);
	const char *sql = (const char*)[sqlStatement UTF8String];
    
	
	if(sqlite3_prepare_v2(_database, sql, -1, &statement, NULL) != SQLITE_OK)
    {
       NSAssert1(0, @"Error while preparing  statement. '%s'", sqlite3_errmsg(_database));
       status = FALSE;
    }
    else
    {
        status = TRUE;
    }
	if (sqlite3_step(statement)!=SQLITE_DONE)
    {
        NSAssert1(0, @"Error while deleting. '%s'", sqlite3_errmsg(_database));
        status = FALSE;
	}
    else
    {
        status = TRUE;
	}
	
	sqlite3_finalize(statement);
    return status;
}
-(int)executeSw:(NSString*)sqlStatement
{
    sqlite3_stmt *statement = nil;
    status = FALSE;
    //NSLog(@"%@",sqlStatement);
    const char *sql = (const char*)[sqlStatement UTF8String];
    
    
    if(sqlite3_prepare_v2(_database, sql, -1, &statement, NULL) != SQLITE_OK) {
        NSAssert1(0, @"Error while preparing  statement. '%s'", sqlite3_errmsg(_database));
        status = FALSE;
    } else {
        status = TRUE;
    }
    if (sqlite3_step(statement)!=SQLITE_DONE) {
        NSAssert1(0, @"Error while deleting. '%s'", sqlite3_errmsg(_database));
        status = FALSE;
    } else {
        status = TRUE;
    }
    
    sqlite3_finalize(statement);
    NSInteger  returnValue = sqlite3_last_insert_rowid(_database);
    
    return returnValue;
}

#pragma mark - SQL query methods
/*
 * Method to get the data table from the database
 */
-(BOOL) execute:(NSString*)sqlQuery resultsArray:(NSMutableArray*)dataTable
{
    
    char** azResult = NULL;
    int nRows = 0;
    int nColumns = 0;
    querystatus = FALSE;
    char* errorMsg; //= malloc(255); // this is not required as sqlite do it itself
    const char* sql = [sqlQuery UTF8String];
    sqlite3_get_table(
                      _database,  /* An open database */
                      sql,     /* SQL to be evaluated */
                      &azResult,          /* Results of the query */
                      &nRows,                 /* Number of result rows written here */
                      &nColumns,              /* Number of result columns written here */
                      &errorMsg      /* Error msg written here */
                      );
	
    if(azResult != NULL)
    {
        nRows++; //because the header row is not account for in nRows
		
        for (int i = 1; i < nRows; i++)
        {
            NSMutableDictionary* row = [[NSMutableDictionary alloc]initWithCapacity:nColumns];
            for(int j = 0; j < nColumns; j++)
            {
                NSString*  value = nil;
                NSString* key = [NSString stringWithUTF8String:azResult[j]];
                if (azResult[(i*nColumns)+j]==NULL)
                {
                    value = [NSString stringWithUTF8String:[[NSString string] UTF8String]];
                }
                else
                {
                    value = [NSString stringWithUTF8String:azResult[(i*nColumns)+j]];
                }
				
                [row setValue:value forKey:key];
            }
            [dataTable addObject:row];
        }
        querystatus = TRUE;
        sqlite3_free_table(azResult);
    }
    else
    {
        NSAssert1(0,@"Failed to execute query with message '%s'.",errorMsg);
        querystatus = FALSE;
    }
    
    return 0;
}
-(NSInteger)getScalar:(NSString*)sqlStatement
{
	NSInteger count = -1;
	
	const char* sql= (const char *)[sqlStatement UTF8String];
	sqlite3_stmt *selectstmt;
	if(sqlite3_prepare_v2(_database, sql, -1, &selectstmt, NULL) == SQLITE_OK)
    {
		while(sqlite3_step(selectstmt) == SQLITE_ROW)
        {
			count = sqlite3_column_int(selectstmt, 0);
		}
	}
	sqlite3_finalize(selectstmt);
	
	return count;
}

-(NSString*)getValue1:(NSString*)sqlStatement
{
	
	NSString* value = nil;
	const char* sql= (const char *)[sqlStatement UTF8String];
	sqlite3_stmt *selectstmt;
	if(sqlite3_prepare_v2(_database, sql, -1, &selectstmt, NULL) == SQLITE_OK)
    {
		while(sqlite3_step(selectstmt) == SQLITE_ROW)
        {
			if ((char *)sqlite3_column_text(selectstmt, 0)!=nil)
            {
				value = [NSString stringWithUTF8String:(char *)sqlite3_column_text(selectstmt, 0)];
			}
		}
	}
	return value;
}

-(void)saveVesselsintoDatabase:(NSMutableArray *)arrVessels
{
   /* const char* query= (const char *)[@"INSERT INTO 'tbl_vessel_asset' ('vessel_succorfish_id','vessel_account_id','vessel_name','vessel_regi_no') VALUES (?, ?, ?, ?)" UTF8String];
    sqlite3_stmt *compiledStatement;

    
    sqlite3_exec(_database, "BEGIN EXCLUSIVE TRANSACTION", 0, 0, 0);
    if(sqlite3_prepare(_database, query, -1, &compiledStatement, NULL) == SQLITE_OK)
    {
        for (NSMutableDictionary *obj in arrVessels)
        {
            sqlite3_bind_text(compiledStatement, 1, [[obj valueForKey:@"id"] UTF8String], -1, NULL);
            sqlite3_bind_text(compiledStatement, 2, [[obj valueForKey:@"accountId"] UTF8String], -1, NULL);
            sqlite3_bind_text(compiledStatement, 3, [[obj valueForKey:@"name"] UTF8String], -1, NULL);
            sqlite3_bind_text(compiledStatement, 4, [[obj valueForKey:@"regNo"] UTF8String], -1, NULL);

            if (sqlite3_step(compiledStatement) != SQLITE_DONE) NSLog(@"DB not updated. Error: %s",sqlite3_errmsg(_database));
            if (sqlite3_reset(compiledStatement) != SQLITE_OK) NSLog(@"SQL Error: %s",sqlite3_errmsg(_database));
        }
    }
    if (sqlite3_finalize(compiledStatement) != SQLITE_OK) NSLog(@"SQL Error: %s",sqlite3_errmsg(_database));
    if (sqlite3_exec(_database, "COMMIT TRANSACTION", 0, 0, 0) != SQLITE_OK) NSLog(@"SQL Error: %s",sqlite3_errmsg(_database));
    sqlite3_close(_database); */
    
//    sqlite3_exec(_database, "BEGIN EXCLUSIVE TRANSACTION", 0, 0, 0);
//    sqlite3_stmt *compiledStatement;
//    NSString * strQuery;
//    const char* sql= (const char *)[strQuery UTF8String];
//
//    if(sqlite3_prepare(_database, sql, -1, &compiledStatement, NULL) == SQLITE_OK)
//    {
//        for (NSDictionary *obj in arrVessels)
//        {
//            sqlite3_bind_text(compiledStatement, 1, [obj valueForKey:@"accountId"]);
//            sqlite3_bind_text(compiledStatement, 2, [obj valueForKey:@"accountId"]);
//            sqlite3_bind_text(compiledStatement, 2, [obj valueForKey:@"accountId"]);
//
//            if (sqlite3_step(compiledStatement) != SQLITE_DONE) NSLog(@"DB not updated. Error: %s",sqlite3_errmsg(_database));
//            if (sqlite3_reset(compiledStatement) != SQLITE_OK) NSLog(@"SQL Error: %s",sqlite3_errmsg(_database));
//        }
//    }
//    if (sqlite3_finalize(compiledStatement) != SQLITE_OK) NSLog(@"SQL Error: %s",sqlite3_errmsg(_database));
//    if (sqlite3_exec(db, "COMMIT TRANSACTION", 0, 0, 0) != SQLITE_OK) NSLog(@"SQL Error: %s",sqlite3_errmsg(_database));
//    sqlite3_close(_database);
    
   
    sqlite3_stmt *compiledStatement = NULL;
    char* errorMessage;
    sqlite3_exec(_database, "BEGIN TRANSACTION", NULL, NULL, &errorMessage);
    char buffer[] = "INSERT INTO 'tbl_vessel_asset' ('vessel_succorfish_id','vessel_account_id','vessel_name','vessel_regi_no') VALUES (?, ?, ?, ?)";
    sqlite3_stmt* stmt;
    sqlite3_prepare_v2(_database, buffer, strlen(buffer), &stmt, NULL);
    for (NSMutableDictionary *obj in arrVessels)
    {
        NSString * strIds = [self checkforValidString:[obj valueForKey:@"id"]];
        NSString * strAccountId = [self checkforValidString:[obj valueForKey:@"accountId"]];
        NSString * strName = [self checkforValidString:[obj valueForKey:@"name"]];
        NSString * strReg = [self checkforValidString:[obj valueForKey:@"regNo"]];

        sqlite3_bind_text(stmt, 1, [strIds UTF8String], -1, NULL);
        sqlite3_bind_text(stmt, 2, [strAccountId UTF8String], -1, NULL);
        sqlite3_bind_text(stmt, 3, [strName UTF8String], -1, NULL);
        sqlite3_bind_text(stmt, 4, [strReg UTF8String], -1, NULL);

        if (sqlite3_step(stmt) != SQLITE_DONE)
        {
            printf("Commit Failed!\n");
        }
        sqlite3_reset(stmt);
    }
    sqlite3_exec(_database, "COMMIT TRANSACTION", NULL, NULL, &errorMessage);
    sqlite3_finalize(stmt);
}
-(void)SaveVesselinExtraTable:(NSMutableArray *)arrVessels
{
    char* errorMessage;
    sqlite3_exec(_database, "BEGIN TRANSACTION", NULL, NULL, &errorMessage);
    char buffer[] = "INSERT INTO 'tbl_vessel_extra' ('vessel_succorfish_id','vessel_account_id','vessel_name','vessel_regi_no') VALUES (?, ?, ?, ?)";
    sqlite3_stmt* stmt;
    sqlite3_prepare_v2(_database, buffer, strlen(buffer), &stmt, NULL);
    for (NSMutableDictionary *obj in arrVessels)
    {
        NSString * strIds = [self checkforValidString:[obj valueForKey:@"id"]];
        NSString * strAccountId = [self checkforValidString:[obj valueForKey:@"accountId"]];
        NSString * strName = [self checkforValidString:[obj valueForKey:@"name"]];
        NSString * strReg = [self checkforValidString:[obj valueForKey:@"regNo"]];
        
        sqlite3_bind_text(stmt, 1, [strIds UTF8String], -1, NULL);
        sqlite3_bind_text(stmt, 2, [strAccountId UTF8String], -1, NULL);
        sqlite3_bind_text(stmt, 3, [strName UTF8String], -1, NULL);
        sqlite3_bind_text(stmt, 4, [strReg UTF8String], -1, NULL);
        
        if (sqlite3_step(stmt) != SQLITE_DONE)
        {
            printf("Commit Failed!\n");
        }
        sqlite3_reset(stmt);
    }
    sqlite3_exec(_database, "COMMIT TRANSACTION", NULL, NULL, &errorMessage);
    sqlite3_finalize(stmt);
}
-(NSString *)checkforValidString:(NSString *)strRequest
{
    NSString * strValid;
    if (![strRequest isEqual:[NSNull null]])
    {
        if (strRequest != nil && strRequest != NULL && ![strRequest isEqualToString:@""])
        {
            strValid = strRequest;
        }
        else
        {
            strValid = @"NA";
        }
    }
    else
    {
        strValid = @"NA";
    }
    strValid = [strValid stringByReplacingOccurrencesOfString:@"\"" withString:@""];

    return strValid;
}


@end
