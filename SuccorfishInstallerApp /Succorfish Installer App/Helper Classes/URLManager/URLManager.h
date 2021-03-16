
//  URLManager.h
//  MRService
//
//  Created by Oneclick IT Solution on 5/21/14.
//  Copyright (c) 2014 One Click IT Consultancy. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JSON1.h"

//NSString *responseString;

typedef void(^URLManagerCallBack)(NSDictionary *result, NSError *error, NSString *commandName);

//delegate protocol
@protocol URLManagerDelegate
- (void)onResult:(NSDictionary *)result;
- (void)onError:(NSError *)error ;
@end


@interface URLManager : NSObject
{
    //object for saving receiving data
	NSMutableData *receivedData;
    
    //delegate object
	//id<URLManagerDelegate> delegate;
    
    //to know from which web service call
	NSString *commandName;
    
    //to know response
	BOOL isString;
    
    //to know progress
    float expectedBytes;
    
    //to assign self object as weak
    __weak URLManager *_weak;
    
    NSString * isStatus200;
}

//delegate property
@property (nonatomic, weak) id<URLManagerDelegate> delegate;

//to know from which web service call
@property (nonatomic, retain) NSString *commandName;

//to know response
@property (nonatomic, assign) BOOL isString;

//declering call back
@property (nonatomic, strong) URLManagerCallBack callBackResult;

//shared instance
+ (instancetype)sharedInstance;

//for POST method
- (void)urlCall:(NSString*)path withParameters:(NSMutableDictionary*)dictionary;
- (void)urlCall:(NSString*)path withParameters:(NSMutableDictionary*)argments callBack:(URLManagerCallBack)callBack forCommandName:(NSString*)command;

- (void)postUrlCall:(NSString*)path withParameters:(NSMutableDictionary*)dictionary;
- (void)postUrlCall:(NSString*)path withParameters:(NSMutableDictionary*)dictionary andMediaData:(NSData*)mediaData andDataParameterName:(NSString*)dataParameterName andFileName:(NSString*)fileName;

- (void)postUrlCall:(NSString*)path withParameters:(NSMutableDictionary*)dictionary andDocumentsData:(NSData*)mediaData andDataParameterName:(NSString*)dataParameterName andFileName:(NSString*)fileName;

- (void)postUrlCall:(NSString*)path withParameters:(NSMutableDictionary*)dictionary andAudioData:(NSData*)mediaData andDataParameterName:(NSString*)dataParameterName andFileName:(NSString*)fileName;

- (void)postUrlCallForMultipleImage:(NSString*)path withParameters:(NSMutableDictionary*)dictionary andMediaData:(NSMutableArray *)ArrMediaData andDataParameterName:(NSMutableArray *)ArrDataParameterName andFileName:(NSMutableArray *)ArrFileName;

- (void)putUrlCallForMultipleImage:(NSString*)path withParameters:(NSMutableDictionary*)dictionary andMediaData:(NSMutableArray *)ArrMediaData andDataParameterName:(NSMutableArray *)ArrDataParameterName andFileName:(NSMutableArray *)ArrFileName;

//putUrlCallForMultipleImage


//for GET method
- (void)getUrlCall:(NSString*)path withParameters:(NSMutableDictionary*)dictionary;

// for Delete methods
- (void)DeleteUrlCall:(NSString*)path withParameters:(NSMutableDictionary*)dictionary;

//for PUT method
- (void)PutUrlCall:(NSString*)path withParameters:(NSMutableDictionary*)dictionary;

//helper methods
- (NSString *)getStringFromDictionary:(NSMutableDictionary*)dictionary;
- (NSString *)postStringFromDictionary:(NSMutableDictionary*)dictionary;
- (void)GetDataUrl:(NSString*)path withParameters:(NSMutableDictionary*)dictionary;

@end
