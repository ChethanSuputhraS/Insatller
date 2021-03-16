//
//  ViewPDFVC.m
//  Succorfish Installer App
//
//  Created by stuart watts on 19/03/2018.
//  Copyright © 2018 Kalpesh Panchasara. All rights reserved.
//

#import "ViewPDFVC.h"
#import <MessageUI/MessageUI.h>
#import "NSMutableURLRequest+BasicAuth.h"

@interface ViewPDFVC ()<UIWebViewDelegate,MFMailComposeViewControllerDelegate,NSURLConnectionDelegate,URLManagerDelegate>
{
    UIWebView * webView;
}
@end

@implementation ViewPDFVC
@synthesize strPdfUrl,strReportType,detailDict,strDate,strVessel,strIMEI;
- (void)viewDidLoad
{
    UIImageView * imgBack = [[UIImageView alloc] init];
    imgBack.frame = CGRectMake(0, 0, DEVICE_WIDTH, DEVICE_HEIGHT);
    imgBack.image = [UIImage imageNamed:@"Splash_bg.png"];
    imgBack.userInteractionEnabled = YES;
    [self.view addSubview:imgBack];
    
    [self setNavigationViewFrames];
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(gotPDFDATA:) name:@"GotPDFData" object:nil];
}
-(void)gotPDFDATA:(NSNotification *)notify
{
    
}
-(void)viewWillAppear:(BOOL)animated
{
    [APP_DELEGATE hideTabBar:self.tabBarController];
    [super viewWillAppear:YES];
}
#pragma mark - Set Frames
-(void)setNavigationViewFrames
{
    UIView * viewHeader = [[UIView alloc] initWithFrame:CGRectMake(0, 0, DEVICE_WIDTH, 64)];
    [viewHeader setBackgroundColor:[UIColor blackColor]];
    [self.view addSubview:viewHeader];
    
    UILabel * lblTitle = [[UILabel alloc] initWithFrame:CGRectMake(50, 20, DEVICE_WIDTH-100, 44)];
    [lblTitle setBackgroundColor:[UIColor clearColor]];
    [lblTitle setText:@"View PDF"];
    [lblTitle setTextAlignment:NSTextAlignmentCenter];
    [lblTitle setFont:[UIFont fontWithName:CGRegular size:17]];
    [lblTitle setTextColor:[UIColor whiteColor]];
    [viewHeader addSubview:lblTitle];
    
    UIImageView * backImg = [[UIImageView alloc] initWithFrame:CGRectMake(10, 12+20, 12, 20)];
    [backImg setImage:[UIImage imageNamed:@"back_icon.png"]];
    [backImg setContentMode:UIViewContentModeScaleAspectFit];
    backImg.backgroundColor = [UIColor clearColor];
    [viewHeader addSubview:backImg];
    
    UIButton * btnBack = [UIButton buttonWithType:UIButtonTypeCustom];
    [btnBack addTarget:self action:@selector(btnBackClick) forControlEvents:UIControlEventTouchUpInside];
    btnBack.frame = CGRectMake(0, 0, 70, 64);
    btnBack.backgroundColor = [UIColor clearColor];
    [viewHeader addSubview:btnBack];
    
    UIImageView * mailImg = [[UIImageView alloc] initWithFrame:CGRectMake(DEVICE_WIDTH-24-10, 10+20+6, 20, 15)];
    [mailImg setImage:[UIImage imageNamed:@"email.png"]];
//    [mailImg setContentMode:UIViewContentModeScaleAspectFit];
    mailImg.backgroundColor = [UIColor clearColor];
    [viewHeader addSubview:mailImg];
    
    UIButton * btnMail = [UIButton buttonWithType:UIButtonTypeCustom];
    [btnMail addTarget:self action:@selector(btnMailClick) forControlEvents:UIControlEventTouchUpInside];
    btnMail.frame = CGRectMake(DEVICE_WIDTH-70, 0, 70, 64);
    btnMail.backgroundColor = [UIColor clearColor];
    [viewHeader addSubview:btnMail];
    
    if (IS_IPHONE_X)
    {
        viewHeader.frame = CGRectMake(0, 0, DEVICE_WIDTH, 88);
        lblTitle.frame = CGRectMake(50, 40, DEVICE_WIDTH-100, 44);
        backImg.frame = CGRectMake(10, 12+44, 12, 20);
        btnBack.frame = CGRectMake(0, 0, 70, 88);
        mailImg.frame = CGRectMake(DEVICE_WIDTH-24-10, 10+44, 24, 24);
        btnMail.frame = CGRectMake(DEVICE_WIDTH-70, 0, 70, 88);
        [self setMainViewContent:88];
    }
    else
    {
        [self setMainViewContent:64];
    }
}

-(void)setMainViewContent:(int)yAxis
{
    [webView removeFromSuperview];
    webView = [[UIWebView alloc] init];
    webView.frame = CGRectMake(0, yAxis, DEVICE_WIDTH, DEVICE_HEIGHT-yAxis);
    webView.userInteractionEnabled = YES;
    webView.scalesPageToFit = YES;
    [self.view addSubview:webView];
    
    if (IS_IPHONE_X)
    {
        webView.frame = CGRectMake(0, yAxis, DEVICE_WIDTH, DEVICE_HEIGHT-yAxis-44);
    }
    NSString * strPdfUrl = [detailDict valueForKey:@"pdf_url"];
    NSString * strSeverID = [detailDict valueForKey:@"server_id"];
    NSString * stringPath = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)objectAtIndex:0]stringByAppendingPathComponent:@"InstallPDFs"]; // New Folder is your folder name
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:stringPath])
    {
        NSError *error = nil;
        [[NSFileManager defaultManager] createDirectoryAtPath:stringPath withIntermediateDirectories:NO attributes:nil error:&error];
    }
    NSString *filePath = [stringPath stringByAppendingString:[NSString stringWithFormat:@"/%@.pdf",strPdfUrl]];
    
    BOOL fileExists = [[NSFileManager defaultManager] fileExistsAtPath:filePath];
    if (fileExists == NO)
    {
        NSString * strMainUrl = [NSString stringWithFormat:@"https://ws.scstg.net/basic/v2/file/download/installation-report.pdf?id=%@&oid=%@",strPdfUrl,strSeverID];
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:strMainUrl]];
        NSString * authToken = [[NSUserDefaults standardUserDefaults] valueForKey:@"BasicAuthToken"];
        [request setValue:[NSString stringWithFormat:@"Basic %@",authToken] forHTTPHeaderField:@"Authorization"];
        [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue currentQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
            if (error)
            {
                NSLog(@"Download Error:%@",error.description);
            }
            if (data)
            {
                [webView loadData:data MIMEType:@"application/pdf" textEncodingName:@"" baseURL:[NSURL URLWithString:@"https://www.google.com"]];
                [data writeToFile:filePath atomically:YES];
                NSLog(@"File is saved to %@",filePath);
            }
        }];
    }
    else
    {
        NSURL *pdfUrl = [NSURL fileURLWithPath:filePath];
        NSURLRequest *request = [NSURLRequest requestWithURL:pdfUrl];
        [webView loadRequest:request];
    }
}
#pragma mark - Button Click events
-(void)btnBackClick
{
    [self.navigationController popViewControllerAnimated:YES];
}
-(void)btnMailClick
{
    // Email Subject
    NSString * emailTitle = @"Installation Report";
    if ([strReportType isEqualToString:@"Install"])
    {
        emailTitle = @"Installation Report";
    }
    else if ([strReportType isEqualToString:@"UnInstall"])
    {
        emailTitle = @"Uninstallation Report";
    }
    else
    {
        emailTitle = @"Inspection Report";
    }
    
    NSString * strMsg = [NSString stringWithFormat:@"Hello, \n %@ of %@ for %@ has been completed successfully on %@.\n Please see the certificate from attachment.",emailTitle,strIMEI,strVessel,strDate];
    
    // To address
    MFMailComposeViewController *mc = [[MFMailComposeViewController alloc] init];
    mc.mailComposeDelegate = self;
    [mc setSubject:emailTitle];
    [mc setMessageBody:strMsg isHTML:NO];
    [mc setToRecipients:nil];
    
    if (mc == nil)
    {
        URBAlertView *alertView = [[URBAlertView alloc] initWithTitle:ALERT_TITLE message:@"Please set up a Mail account in order to send email." cancelButtonTitle:OK_BTN otherButtonTitles: nil, nil];
        
        [alertView setMessageFont:[UIFont fontWithName:CGRegular size:14]];
        [alertView setHandlerBlock:^(NSInteger buttonIndex, URBAlertView *alertView) {
            [alertView hideWithCompletionBlock:^{
            }];
        }];
        [alertView showWithAnimation:URBAlertAnimationTopToBottom];
    if (IS_IPHONE_X){[alertView showWithAnimation:URBAlertAnimationDefault];}
    }
    else
    {
        NSString * stringPath = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)objectAtIndex:0]stringByAppendingPathComponent:@"InstallPDFs"]; // New Folder is your folder name
        NSString *filePath = [stringPath stringByAppendingString:[NSString stringWithFormat:@"/%@.pdf",strPdfUrl]];
        
        
        NSURL* outputURL = [[NSURL alloc] initFileURLWithPath:filePath];
        NSData *data=[[NSData alloc]initWithContentsOfURL:outputURL];
        [mc addAttachmentData:data mimeType:@"application/pdf" fileName:[NSString stringWithFormat:@"/%@.pdf",strPdfUrl]];
        
        [self.navigationController presentViewController:mc animated:YES completion:nil];
    }
}

- (void) mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
    switch (result)
    {
        case MFMailComposeResultCancelled:
            NSLog(@"Mail cancelled");
            break;
        case MFMailComposeResultSaved:
            NSLog(@"Mail saved");
            break;
        case MFMailComposeResultSent:
            NSLog(@"Mail sent");
            break;
        case MFMailComposeResultFailed:
            NSLog(@"Mail sent failure: %@", [error localizedDescription]);
            break;
        default:
            break;
    }
    
    // Close the Mail Interface
    [self dismissViewControllerAnimated:YES completion:NULL];
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
//- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType;
//{
//    
//    [[NSURLConnection alloc] initWithRequest:request delegate:self];
//    return YES;
//}
//- (void)connection:(NSURLConnection *)connection didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge;
//{
//    NSURLCredential * cred = [NSURLCredential credentialWithUser:@"kalpesh"
//                                                        password:@"Changeme1"
//                                                     persistence:NSURLCredentialPersistenceForSession];
//    [[NSURLCredentialStorage sharedCredentialStorage]setCredential:cred forProtectionSpace:[challenge protectionSpace]];
//
//}
//- (BOOL)connectionShouldUseCredentialStorage:(NSURLConnection *)connection;
//{
//    return YES;
//}
//// if the authentication is successfully handled than you will get data in this method in which you can reload web view with same request again.
//
//- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response;
//{
//    NSLog(@"received response via nsurlconnection");
//    
////    NSURLRequest *urlRequest = [NSURLRequest requestWithURL:[NSURL   URLWithString:@"https://ws.scstg.net/file/downloadAttachment/99e9daeb-23bd-4814-88b3-e317f7a05414/ec4790a0-bd70-11e8-bd1c-90b8d0f72797"]];
////
////    [webView loadRequest:urlRequest];
////
////    NSURLProtectionSpace *loginProtectionSpace = [[NSURLProtectionSpace alloc]
////                                                  initWithHost:@"https://ws.scstg.net/"
////                                                  port: 443
////                                                  protocol:NSURLProtectionSpaceHTTP
////                                                  realm:nil
////                                                  authenticationMethod:NSURLAuthenticationMethodDefault];
////
////    NSURLCredential * cred = [NSURLCredential credentialWithUser:@"kalpesh"
////                                                        password:@"Changeme1"
////                                                     persistence:NSURLCredentialPersistenceForSession];
////
////
//////    [[NSURLCredentialStorage sharedCredentialStorage] setCredential:cred forProtectionSpace:[challenge protectionSpace]];
////    [[NSURLCredentialStorage sharedCredentialStorage] setCredential:cred forProtectionSpace:loginProtectionSpace];
//}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void)onResult:(NSDictionary *)result
{
//    NSString *str = [[result valueForKey:@"result"] valueForKey:@"contentBytes"];
//    NSData *data = [str dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:NO];
//    
//    NSData *dataTake2 =
//    [str dataUsingEncoding:NSUTF8StringEncoding];
//    
//    // Convert to Base64 data
//    NSData *base64Data = [dataTake2 base64EncodedDataWithOptions:0];
//    
//    NSLog(@"The result is...%@", result);
//    [webView loadData:base64Data MIMEType:@"application/pdf" textEncodingName:@"" baseURL:[NSURL URLWithString:@"https://www.google.com"]];
////    [webView load];
//    NSString  *filePath;
//  
//    if ( kpsData )
//    {
//        NSArray       *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
//        NSString  *documentsDirectory = [paths objectAtIndex:0];
//        
//        filePath = [NSString stringWithFormat:@"%@/%@", documentsDirectory,@"installation-report.pdf"];
//        [kpsData writeToFile:filePath atomically:YES];
//    }
//
//    // Now create Request for the file that was saved in your documents folder
//    NSURL *url = [NSURL fileURLWithPath:filePath];
//    NSURLRequest *requestObj = [NSURLRequest requestWithURL:url];
    
//    [webView setUserInteractionEnabled:YES];
//    [webView setDelegate:self];
//    [webView loadRequest:requestObj];

}
- (void)onError:(NSError *)error
{
    NSLog(@"The error is...%@", error);
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
