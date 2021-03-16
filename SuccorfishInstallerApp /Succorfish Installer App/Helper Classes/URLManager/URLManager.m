//
//  URLManager.m
//  MRService
//
//  Created by Oneclick IT Solution on 5/21/14.
//  Copyright (c) 2014 One Click IT Consultancy. All rights reserved.
//

#import "URLManager.h"

@implementation URLManager
@synthesize delegate;
@synthesize commandName;
@synthesize isString;

#pragma mark -
#pragma mark Network Call Methods
#pragma mark -

-(id)init
{
    if(self = [super init]){
        _weak = self;
    }
    return self;
}

+ (instancetype)sharedInstance
{
	static id instance_ = nil;
	static dispatch_once_t onceToken;
	
	dispatch_once(&onceToken, ^{
		instance_ = [[self alloc] init];
	});
	
	return instance_;
}

- (void)urlCall:(NSString*)path withParameters:(NSMutableDictionary*)argments callBack:(URLManagerCallBack)callBack forCommandName:(NSString*)command
{
    _weak.callBackResult = callBack;
    _weak.commandName = command;
    [self urlCall:path withParameters:argments];
}

- (void)urlCall:(NSString*)path withParameters:(NSMutableDictionary*)dictionary
{
    NSString * urlStr = [NSString stringWithFormat:@"%@",path];
	NSMutableURLRequest *theRequest = [[NSMutableURLRequest alloc] init] ;
    NSURL *url=[NSURL URLWithString:urlStr];
	[theRequest setURL:url];//KALPESH
    
    NSLog(@"urlStr========%@",urlStr);
    
//    NSURL *url=[NSURL URLWithString:urlStr];
//    NSMutableURLRequest *theRequest = [[NSMutableURLRequest alloc] initWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:120];

	if (dictionary!=nil)
    {
//		NSString * requestStr = [self postStringFromDictionary:dictionary];
        NSString * requestStr = [dictionary JSONRepresentation];
        
        NSLog(@"requestStr====%@",requestStr);

		NSData *requestData = [requestStr dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES];
		NSString *postLength = [NSString stringWithFormat:@"%lu", (unsigned long)[requestData length]];
		[theRequest setValue:postLength forHTTPHeaderField:@"Content-Length"];
		[theRequest setHTTPBody:requestData];
	}
	[theRequest setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
//    [theRequest setValue:@"json/application" forHTTPHeaderField:@"Content-Type"];
//    [theRequest setValue:@"application/json; charset=UTF-8;" forHTTPHeaderField:@"Content-Type"];
    
    
	[theRequest setHTTPMethod:@"POST"];
	[theRequest setHTTPShouldHandleCookies:NO];
//	[theRequest setTimeoutInterval:30];
    [theRequest setTimeoutInterval:120];
    
    NSURLConnection *theConnection=[[NSURLConnection alloc] initWithRequest:theRequest delegate:_weak];
    
	if (theConnection)
		receivedData = [NSMutableData data];
}
- (void)GetDataUrl:(NSString*)path withParameters:(NSMutableDictionary*)dictionary
{
    NSString * urlStr = [NSString stringWithFormat:@"%@",path];
    NSURL *url=[NSURL URLWithString:urlStr];
    NSMutableURLRequest *theRequest = [[NSMutableURLRequest alloc] initWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:120];
    
    if (dictionary!=nil)
    {
        NSString * requestStr = [dictionary JSONRepresentation];
        NSData *requestData = [requestStr dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES];
        NSString *postLength = [NSString stringWithFormat:@"%lu", (unsigned long)[requestData length]];
        [theRequest setValue:postLength forHTTPHeaderField:@"Content-Length"];
        [theRequest setHTTPBody:requestData];
    }
    [theRequest setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    NSString * authToken = [[NSUserDefaults standardUserDefaults] valueForKey:@"BasicAuthToken"];
    [theRequest setValue:[NSString stringWithFormat:@"Basic %@",authToken] forHTTPHeaderField:@"Authorization"];
    [theRequest setHTTPMethod:@"GET"];
    [theRequest setHTTPShouldHandleCookies:NO];
    [theRequest setTimeoutInterval:120];
    NSURLConnection *theConnection=[[NSURLConnection alloc] initWithRequest:theRequest delegate:_weak];
    if (theConnection)
        receivedData = [NSMutableData data];
}
- (void)postUrlCall:(NSString*)path withParameters:(NSMutableDictionary*)dictionary
{
    NSString * urlStr = [NSString stringWithFormat:@"%@",path];
    
    NSLog(@"urlStr========%@",urlStr);
    
    NSURL *url=[NSURL URLWithString:urlStr];
    NSMutableURLRequest *theRequest = [[NSMutableURLRequest alloc] initWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:120];
    
    if (dictionary!=nil)
    {
//        NSString * requestStr = [self postStringFromDictionary:dictionary];
        NSString * requestStr = [dictionary JSONRepresentation];
        
        NSLog(@"requestStr====%@",requestStr);
        
        NSData *requestData = [requestStr dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES];
        NSString *postLength = [NSString stringWithFormat:@"%lu", (unsigned long)[requestData length]];
        [theRequest setValue:postLength forHTTPHeaderField:@"Content-Length"];
        [theRequest setHTTPBody:requestData];
    }
//        [theRequest setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    [theRequest setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
//        [theRequest setValue:@"application/json; charset=UTF-8;" forHTTPHeaderField:@"Content-Type"];
    NSString * authToken = [[NSUserDefaults standardUserDefaults] valueForKey:@"BasicAuthToken"];
    [theRequest setValue:[NSString stringWithFormat:@"Basic %@",authToken] forHTTPHeaderField:@"Authorization"];

    NSLog(@"Authtoken====%@",authToken);

    [theRequest setHTTPMethod:@"POST"];
    [theRequest setHTTPShouldHandleCookies:NO];
    //	[theRequest setTimeoutInterval:30];
    [theRequest setTimeoutInterval:120];
    
    NSURLConnection *theConnection=[[NSURLConnection alloc] initWithRequest:theRequest delegate:_weak];
    
    if (theConnection)
        receivedData = [NSMutableData data];
}
- (void)postUrlCall:(NSString*)path withParameters:(NSMutableDictionary*)dictionary andDocumentsData:(NSData*)mediaData andDataParameterName:(NSString*)dataParameterName andFileName:(NSString*)fileName
{
    NSString *BoundaryConstant = @"---------------------------14737809831466499882746641449";
    
    // the boundary string : a random string, that will not repeat in post data, to separate post data fields.
    //    NSString *BoundaryConstant = [NSString stringWithString:@"----------V2ymHFg03ehbqgZCaKO6jy"];
    
    // the server url to which the image (or the media) is uploaded. Use your server url here
    NSURL* requestURL = [NSURL URLWithString:[NSString stringWithFormat:@"%@",path]];
    
    // create request
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setCachePolicy:NSURLRequestReloadIgnoringLocalCacheData];
    [request setHTTPShouldHandleCookies:NO];
    [request setTimeoutInterval:120];
    [request setHTTPMethod:@"POST"];
    
    // set Content-Type in HTTP header
    NSString *contentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@", BoundaryConstant];
    [request setValue:contentType forHTTPHeaderField: @"Content-Type"];
    
    // post body
    NSMutableData *body = [NSMutableData data];
    
    // add params (all params are strings)
    for (NSString *param in dictionary) {
        [body appendData:[[NSString stringWithFormat:@"--%@\r\n", BoundaryConstant] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"\r\n\r\n", param] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[[NSString stringWithFormat:@"%@\r\n", [dictionary objectForKey:param]] dataUsingEncoding:NSUTF8StringEncoding]];
    }
    
    // add image data
    if (mediaData)
    {
        [body appendData:[[NSString stringWithFormat:@"--%@\r\n", BoundaryConstant] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"; filename=\"%@\"\r\n", dataParameterName,fileName] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[@"Content-Type:multipart/form-data\r\n\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
        //        [body appendData:[[NSString stringWithFormat:@"content_type:audio/mp3" ]dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:mediaData];
        [body appendData:[[NSString stringWithFormat:@"\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
    }
    
    [body appendData:[[NSString stringWithFormat:@"--%@--\r\n", BoundaryConstant] dataUsingEncoding:NSUTF8StringEncoding]];
    
    // setting the body of the post to the reqeust
    [request setHTTPBody:body];
    
    // set the content-length
    //    NSString *postLength = [NSString stringWithFormat:@"%d", [body length]];
    NSString *postLength = [NSString stringWithFormat:@"%lu", (unsigned long)[body length]];
    [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
    // set URL
    [request setURL:requestURL];
    
    
    NSURLConnection *theConnection=[[NSURLConnection alloc] initWithRequest:request delegate:_weak];
    if (theConnection)
        receivedData = [NSMutableData data];
}
- (void)postUrlCall:(NSString*)path withParameters:(NSMutableDictionary*)dictionary andMediaData:(NSData*)mediaData andDataParameterName:(NSString*)dataParameterName andFileName:(NSString*)fileName
{
    NSString *BoundaryConstant = @"---------------------------14737809831466499882746641449";
    
    // the boundary string : a random string, that will not repeat in post data, to separate post data fields.
//    NSString *BoundaryConstant = [NSString stringWithString:@"----------V2ymHFg03ehbqgZCaKO6jy"];
    
    // the server url to which the image (or the media) is uploaded. Use your server url here
    NSURL* requestURL = [NSURL URLWithString:[NSString stringWithFormat:@"%@",path]];
    
    // create request
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setCachePolicy:NSURLRequestReloadIgnoringLocalCacheData];
    [request setHTTPShouldHandleCookies:NO];
    [request setTimeoutInterval:120];
    [request setHTTPMethod:@"POST"];
    
    // set Content-Type in HTTP header
    NSString *contentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@", BoundaryConstant];
    [request setValue:contentType forHTTPHeaderField: @"Content-Type"];
    
    // post body
    NSMutableData *body = [NSMutableData data];
    
    // add params (all params are strings)
    for (NSString *param in dictionary) {
        [body appendData:[[NSString stringWithFormat:@"--%@\r\n", BoundaryConstant] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"\r\n\r\n", param] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[[NSString stringWithFormat:@"%@\r\n", [dictionary objectForKey:param]] dataUsingEncoding:NSUTF8StringEncoding]];
    }
    
    // add image data
    if (mediaData)
    {
        [body appendData:[[NSString stringWithFormat:@"--%@\r\n", BoundaryConstant] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"; filename=\"%@\"\r\n", dataParameterName,fileName] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[@"Content-Type: image/jpeg\r\n\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
//        [body appendData:[[NSString stringWithFormat:@"content_type:audio/mp3" ]dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:mediaData];
        [body appendData:[[NSString stringWithFormat:@"\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
    }
    
    [body appendData:[[NSString stringWithFormat:@"--%@--\r\n", BoundaryConstant] dataUsingEncoding:NSUTF8StringEncoding]];
    
    // setting the body of the post to the reqeust
    [request setHTTPBody:body];
    
    // set the content-length
//    NSString *postLength = [NSString stringWithFormat:@"%d", [body length]];
    NSString *postLength = [NSString stringWithFormat:@"%lu", (unsigned long)[body length]];
    [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
    // set URL
    [request setURL:requestURL];
    
    
    NSURLConnection *theConnection=[[NSURLConnection alloc] initWithRequest:request delegate:_weak];
    if (theConnection)
        receivedData = [NSMutableData data];
}
- (void)postUrlCallForMultipleImage:(NSString*)path withParameters:(NSMutableDictionary*)dictionary andMediaData:(NSMutableArray *)ArrMediaData andDataParameterName:(NSMutableArray *)ArrDataParameterName andFileName:(NSMutableArray *)ArrFileName;
{
    NSString *BoundaryConstant = @"---------------------------14737809831466499882746641449";
    // the boundary string : a random string, that will not repeat in post data, to separate post data fields.
    //    NSString *BoundaryConstant = [NSString stringWithString:@"----------V2ymHFg03ehbqgZCaKO6jy"];
    
    // the server url to which the image (or the media) is uploaded. Use your server url here
    NSURL* requestURL = [NSURL URLWithString:[NSString stringWithFormat:@"%@",path]];
    
    // create request
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setCachePolicy:NSURLRequestReloadIgnoringLocalCacheData];
    [request setHTTPShouldHandleCookies:NO];
    [request setTimeoutInterval:120];
    [request setHTTPMethod:@"POST"];
    
    // set Content-Type in HTTP header
    NSString *contentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@", BoundaryConstant];
    [request setValue:contentType forHTTPHeaderField: @"Content-Type"];
    NSString * authToken = [[NSUserDefaults standardUserDefaults] valueForKey:@"BasicAuthToken"];
    [request setValue:[NSString stringWithFormat:@"Basic %@",authToken] forHTTPHeaderField:@"Authorization"];

    // post body
    NSMutableData *body = [NSMutableData data];
    
    // add params (all params are strings)
    for (NSString *param in dictionary) {
        [body appendData:[[NSString stringWithFormat:@"--%@\r\n", BoundaryConstant] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"\r\n\r\n", param] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[[NSString stringWithFormat:@"%@\r\n", [dictionary objectForKey:param]] dataUsingEncoding:NSUTF8StringEncoding]];
    }
    
    // add image data
    if (ArrMediaData)
    {
        for (int i =0; i< ArrMediaData.count; i++)
        {
            [body appendData:[[NSString stringWithFormat:@"--%@\r\n", BoundaryConstant] dataUsingEncoding:NSUTF8StringEncoding]];
            [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"; filename=\"%@\"\r\n", [ArrDataParameterName objectAtIndex:i],[ArrFileName objectAtIndex:i]] dataUsingEncoding:NSUTF8StringEncoding]];
            [body appendData:[@"Content-Type: image/jpeg\r\n\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
            [body appendData:[ArrMediaData objectAtIndex:i]];
            [body appendData:[[NSString stringWithFormat:@"\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
        }
    }
    
    [body appendData:[[NSString stringWithFormat:@"--%@--\r\n", BoundaryConstant] dataUsingEncoding:NSUTF8StringEncoding]];
    
    // setting the body of the post to the reqeust
    [request setHTTPBody:body];
    
//    NSString * authToken = [[NSUserDefaults standardUserDefaults] valueForKey:@"auth_token"];
//    [request setValue:authToken forHTTPHeaderField:@"token"];

    // set the content-length
    //    NSString *postLength = [NSString stringWithFormat:@"%d", [body length]];
    NSString *postLength = [NSString stringWithFormat:@"%lu", (unsigned long)[body length]];
    [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
    // set URL
    [request setURL:requestURL];
    
    
    NSURLConnection *theConnection=[[NSURLConnection alloc] initWithRequest:request delegate:_weak];
    if (theConnection)
        receivedData = [NSMutableData data];
}

- (void)putUrlCallForMultipleImage:(NSString*)path withParameters:(NSMutableDictionary*)dictionary andMediaData:(NSMutableArray *)ArrMediaData andDataParameterName:(NSMutableArray *)ArrDataParameterName andFileName:(NSMutableArray *)ArrFileName;
{
    NSString *BoundaryConstant = @"---------------------------14737809831466499882746641449";
    
    // the boundary string : a random string, that will not repeat in post data, to separate post data fields.
    //    NSString *BoundaryConstant = [NSString stringWithString:@"----------V2ymHFg03ehbqgZCaKO6jy"];
    
    // the server url to which the image (or the media) is uploaded. Use your server url here
    NSURL* requestURL = [NSURL URLWithString:[NSString stringWithFormat:@"%@",path]];
    
    // create request
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setCachePolicy:NSURLRequestReloadIgnoringLocalCacheData];
    [request setHTTPShouldHandleCookies:NO];
    [request setTimeoutInterval:120];
    [request setHTTPMethod:@"PUT"];
    
    // set Content-Type in HTTP header
    NSString *contentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@", BoundaryConstant];
    [request setValue:contentType forHTTPHeaderField: @"Content-Type"];
    
    // post body
    NSMutableData *body = [NSMutableData data];
    
    // add params (all params are strings)
    for (NSString *param in dictionary) {
        [body appendData:[[NSString stringWithFormat:@"--%@\r\n", BoundaryConstant] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"\r\n\r\n", param] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[[NSString stringWithFormat:@"%@\r\n", [dictionary objectForKey:param]] dataUsingEncoding:NSUTF8StringEncoding]];
    }
    
    // add image data
    if (ArrMediaData)
    {
        for (int i =0; i< ArrMediaData.count; i++)
        {
            [body appendData:[[NSString stringWithFormat:@"--%@\r\n", BoundaryConstant] dataUsingEncoding:NSUTF8StringEncoding]];
            [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"; filename=\"%@\"\r\n", [ArrDataParameterName objectAtIndex:i],[ArrFileName objectAtIndex:i]] dataUsingEncoding:NSUTF8StringEncoding]];
            [body appendData:[@"Content-Type: image/jpeg\r\n\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
            [body appendData:[ArrMediaData objectAtIndex:i]];
            [body appendData:[[NSString stringWithFormat:@"\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
        }
        
    }
    
    [body appendData:[[NSString stringWithFormat:@"--%@--\r\n", BoundaryConstant] dataUsingEncoding:NSUTF8StringEncoding]];
    
    // setting the body of the post to the reqeust
    [request setHTTPBody:body];
    
    // set the content-length
    //    NSString *postLength = [NSString stringWithFormat:@"%d", [body length]];
    NSString *postLength = [NSString stringWithFormat:@"%lu", (unsigned long)[body length]];
    [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
    // set URL
    [request setURL:requestURL];
    
    NSLog(@"request==%@",request);
    
    
    NSURLConnection *theConnection=[[NSURLConnection alloc] initWithRequest:request delegate:_weak];
    if (theConnection)
        receivedData = [NSMutableData data];
}

- (void)postUrlCall:(NSString*)path withParameters:(NSMutableDictionary*)dictionary andAudioData:(NSData*)mediaData andDataParameterName:(NSString*)dataParameterName andFileName:(NSString*)fileName
{
    NSString *BoundaryConstant = @"---------------------------14737809831466499882746641449";
    
    // the boundary string : a random string, that will not repeat in post data, to separate post data fields.
    //    NSString *BoundaryConstant = [NSString stringWithString:@"----------V2ymHFg03ehbqgZCaKO6jy"];
    
    // the server url to which the image (or the media) is uploaded. Use your server url here
    NSURL* requestURL = [NSURL URLWithString:[NSString stringWithFormat:@"%@",path]];
    
    // create request
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setCachePolicy:NSURLRequestReloadIgnoringLocalCacheData];
    [request setHTTPShouldHandleCookies:NO];
    [request setTimeoutInterval:120];
    [request setHTTPMethod:@"POST"];
    
    // set Content-Type in HTTP header
    NSString *contentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@", BoundaryConstant];
    [request setValue:contentType forHTTPHeaderField: @"Content-Type"];
    
    // post body
    NSMutableData *body = [NSMutableData data];
    
    // add params (all params are strings)
    for (NSString *param in dictionary) {
        [body appendData:[[NSString stringWithFormat:@"--%@\r\n", BoundaryConstant] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"\r\n\r\n", param] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[[NSString stringWithFormat:@"%@\r\n", [dictionary objectForKey:param]] dataUsingEncoding:NSUTF8StringEncoding]];
    }
    
    // add image data
    if (mediaData)
    {
        [body appendData:[[NSString stringWithFormat:@"--%@\r\n", BoundaryConstant] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"; filename=\"%@\"\r\n", dataParameterName,fileName] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[@"Content-Type: audio/mp3\r\n\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
        //        [body appendData:[[NSString stringWithFormat:@"content_type:audio/mp3" ]dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:mediaData];
        [body appendData:[[NSString stringWithFormat:@"\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
    }
    
    [body appendData:[[NSString stringWithFormat:@"--%@--\r\n", BoundaryConstant] dataUsingEncoding:NSUTF8StringEncoding]];
    [request setHTTPBody:body];
    
    NSString *postLength = [NSString stringWithFormat:@"%lu", (unsigned long)[body length]];
    [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
    // set URL
    [request setURL:requestURL];
    
    
    NSURLConnection *theConnection=[[NSURLConnection alloc] initWithRequest:request delegate:_weak];
    if (theConnection)
        receivedData = [NSMutableData data];
}

- (void)getUrlCall:(NSString*)path withParameters:(NSMutableDictionary*)dictionary
{
	NSString * urlStr = [NSString stringWithFormat:@"%@",path];
	NSMutableURLRequest *theRequest = [[NSMutableURLRequest alloc] init];
	
	if (dictionary!=nil) {
        
		NSString *requestStr = [self getStringFromDictionary:dictionary];
        urlStr = [NSString stringWithFormat:@"%@?%@",path,requestStr];
        urlStr = [urlStr stringByReplacingOccurrencesOfString:@" " withString:@"%20"];
	}
    
    NSLog(@"urlStr===%@",urlStr);
	[theRequest setURL:[NSURL URLWithString:urlStr]];
	[theRequest setHTTPMethod:@"GET"];
	[theRequest setHTTPShouldHandleCookies:NO];
//	[theRequest setTimeoutInterval:30];
    [theRequest setTimeoutInterval:120];
    NSString * authToken = [[NSUserDefaults standardUserDefaults] valueForKey:@"BasicAuthToken"];
    [theRequest setValue:[NSString stringWithFormat:@"Basic %@",authToken] forHTTPHeaderField:@"Authorization"];

    
	NSURLConnection *theConnection=[[NSURLConnection alloc] initWithRequest:theRequest delegate:_weak];
	if (theConnection)
		receivedData = [NSMutableData data];
}

- (void)PutUrlCall:(NSString*)path withParameters:(NSMutableDictionary*)dictionary
{
    NSString * urlStr = [NSString stringWithFormat:@"%@",path];

    NSLog(@"urlStr========%@",urlStr);
    
    NSURL *url=[NSURL URLWithString:urlStr];
    NSMutableURLRequest *theRequest = [[NSMutableURLRequest alloc] initWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:120];
    
    if (dictionary!=nil)
    {
        NSString * requestStr = [self postStringFromDictionary:dictionary];
        
        NSLog(@"requestStr====%@",requestStr);
        
        NSData *requestData = [requestStr dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES];
        NSString *postLength = [NSString stringWithFormat:@"%lu", (unsigned long)[requestData length]];
        [theRequest setValue:postLength forHTTPHeaderField:@"Content-Length"];
        [theRequest setHTTPBody:requestData];
    }
    [theRequest setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];

    
    [theRequest setHTTPMethod:@"PUT"];
    [theRequest setHTTPShouldHandleCookies:NO];
    //	[theRequest setTimeoutInterval:30];
    [theRequest setTimeoutInterval:120];
    
    NSURLConnection *theConnection=[[NSURLConnection alloc] initWithRequest:theRequest delegate:_weak];
    
    if (theConnection)
        receivedData = [NSMutableData data];
}

- (void)DeleteUrlCall:(NSString*)path withParameters:(NSMutableDictionary*)dictionary
{
    NSString * urlStr = [NSString stringWithFormat:@"%@",path];
    NSMutableURLRequest *theRequest = [[NSMutableURLRequest alloc] init];
    
    if (dictionary!=nil) {
        
        NSString *requestStr = [self getStringFromDictionary:dictionary];
        urlStr = [NSString stringWithFormat:@"%@?%@",path,requestStr];
        urlStr = [urlStr stringByReplacingOccurrencesOfString:@" " withString:@"%20"];
    }
    
    NSLog(@"urlStr===%@",urlStr);
    [theRequest setURL:[NSURL URLWithString:urlStr]];
    [theRequest setHTTPMethod:@"DELETE"];
    [theRequest setHTTPShouldHandleCookies:NO];
    //	[theRequest setTimeoutInterval:30];
    [theRequest setTimeoutInterval:120];
    
    NSURLConnection *theConnection=[[NSURLConnection alloc] initWithRequest:theRequest delegate:_weak];
    if (theConnection)
        receivedData = [NSMutableData data];
}

#pragma mark - Helper function
- (NSString *)getStringFromDictionary:(NSMutableDictionary*)dictionary
{
	NSString *argumentStr = @"";
	
	NSArray *myKeys = [dictionary allKeys];
	NSArray *sortedKeys = [myKeys sortedArrayUsingSelector:@selector(caseInsensitiveCompare:)];
	
	for (int i=0 ; i<[sortedKeys count]; i++)  {
		if ( i != 0)
			argumentStr = [argumentStr stringByAppendingString:@"&"];
        
		NSString *key = [sortedKeys objectAtIndex:i];
		NSString *value = [dictionary objectForKey:key];
		
		NSString *formateStr = [NSString stringWithFormat:@"%@=%@",key,value];
		argumentStr = [argumentStr stringByAppendingString:formateStr];
	}
	return argumentStr;
}

- (NSString *)postStringFromDictionary:(NSMutableDictionary*)dictionary
{
	NSString *argumentStr = @"";
	
	NSArray *myKeys = [dictionary allKeys];
	NSArray *sortedKeys = [myKeys sortedArrayUsingSelector:@selector(caseInsensitiveCompare:)];
	
	for (int i=0 ; i<[sortedKeys count]; i++)  {
		if ( i != 0)
			argumentStr = [argumentStr stringByAppendingString:@"&"];
        
		NSString *key = [sortedKeys objectAtIndex:i];
		NSString *value = [dictionary objectForKey:key];
		
		if ([value isKindOfClass:[NSString class]]) {
			value = [value stringByReplacingOccurrencesOfString:@"$" withString:@"%24"];
			value = [value stringByReplacingOccurrencesOfString:@"&" withString:@"%26"];
			value = [value stringByReplacingOccurrencesOfString:@"+" withString:@"%2B"];
			value = [value stringByReplacingOccurrencesOfString:@"," withString:@"%2C"];
			value = [value stringByReplacingOccurrencesOfString:@"/" withString:@"%2F"];
			value = [value stringByReplacingOccurrencesOfString:@":" withString:@"%3A"];
			value = [value stringByReplacingOccurrencesOfString:@";" withString:@"%3B"];
			value = [value stringByReplacingOccurrencesOfString:@"=" withString:@"%3D"];
			value = [value stringByReplacingOccurrencesOfString:@"?" withString:@"%3F"];
			value = [value stringByReplacingOccurrencesOfString:@"@" withString:@"%40"];
		}
		
		NSString *formateStr = [NSString stringWithFormat:@"%@=%@",key,value];
		argumentStr = [argumentStr stringByAppendingString:formateStr];
      //  NSLog(@"argumentStr===%@",argumentStr);
	}
	return argumentStr;
}

#pragma mark -
#pragma mark NSURLConnection Methods
#pragma mark -

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    [receivedData setLength:0];
    NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *) response;
    NSLog(@"response status code: %ld", (long)[httpResponse statusCode]);

    if ([httpResponse statusCode] == 200)
    {
        if ([_weak.commandName isEqualToString:@"SavePhotos"] || [_weak.commandName isEqualToString:@"SaveOwnerSign"] || [_weak.commandName isEqualToString:@"SaveInstallSign"])
        {
            isStatus200 = @"200";
        }
    }
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    kpsData = [[NSData alloc] init];
    [receivedData appendData:data];
    kpsData = receivedData;

//     [webview loadData:PdfContent MIMEType:@"application/pdf" textEncodingName:@"utf-8" baseURL:nil];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
	[delegate onError:error];
    
//    NSInteger ancode = [error code];
//    [APP_DELEGATE ShowNoNetworkConnectionPopUpWithErrorCode:ancode];

//    if (_weak.callBackResult) {
//        _weak.callBackResult(nil,error,_weak.commandName);
//    }
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
	NSString *responseString = [[NSString alloc] initWithData:receivedData encoding:NSUTF8StringEncoding];
//    NSLog(@"responseString====%@",responseString);
    if ([isStatus200 isEqualToString:@"200"])
    {
        if (_weak.commandName!=nil && _weak.commandName!=NULL)
        {
            NSMutableDictionary *result = [[NSMutableDictionary alloc] init];
            [result setObject:responseString forKey:@"result"];
            [result setObject:_weak.commandName forKey:@"commandName"];
            
            if (delegate)
                [_weak.delegate onResult:result];
        }
    }
    else
    {
        if (self.isString)
        {
            if (_weak.commandName!=nil && _weak.commandName!=NULL) {
                NSMutableDictionary *result = [[NSMutableDictionary alloc] init];
                [result setObject:responseString forKey:@"result"];
                [result setObject:_weak.commandName forKey:@"commandName"];
                
                if (delegate)
                    [_weak.delegate onResult:result];
                //            if (_weak.callBackResult) {
                //                _weak.callBackResult(result,nil,_weak.commandName);
                //            }
            }
            else {
                if (delegate)
                    [_weak.delegate onResult:(NSDictionary*)responseString];
                //            if (_weak.callBackResult) {
                //                _weak.callBackResult((NSDictionary*)responseString,nil,nil);
                //            }
            }
        }
        else
        {
            NSError *error;
            NSData *data= [responseString dataUsingEncoding:NSUTF8StringEncoding];//KALPESH
            id response=[NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];//KALPESH
            
            
            if (response == nil )
            {
                NSLog(@"response is nil");
                
                [delegate onError:error];
                NSLog(@"error==%@",error);
                
                //            NSInteger ancode = [error code];
                //            [APP_DELEGATE ShowNoNetworkConnectionPopUpWithErrorCode:ancode];
            }
            else
            {
                if (_weak.commandName!=nil && _weak.commandName!=NULL) {
                    NSMutableDictionary *result = [[NSMutableDictionary alloc] init];
                    [result setObject:response forKey:@"result"];
                    [result setObject:_weak.commandName forKey:@"commandName"];
                    if (delegate)
                        [_weak.delegate onResult:result];
                    //                if (_weak.callBackResult) {
                    //                    _weak.callBackResult((NSDictionary*)result,nil,_weak.commandName);
                    //                }
                }
                else {
                    if (delegate)
                        [_weak.delegate onResult:response];
                    //                if (_weak.callBackResult) {
                    //                    _weak.callBackResult(response,nil,nil);
                    //                }
                }
            }
        }
    }
	
}

@end

