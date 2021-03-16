//
//  BarcodeScanVC.m
//  Succorfish Installer App
//
//  Created by stuart watts on 22/02/2018.
//  Copyright © 2018 Kalpesh Panchasara. All rights reserved.
//

#import "BarcodeScanVC.h"
#import "ZBarImageScanner.h"
#import "TestDeviceVC.h"
#import "LastWaypointVC.h"


@interface BarcodeScanVC ()<URLManagerDelegate>
{
    NSString *websrviceName;
    UILabel * lblTitle;
    ZBarReaderView * reader;
    BOOL isScanOn;
    UIView *laserView;
    RMOutlineBox *boundingBox;
    BOOL animateScanner;
    NSString * strLocalIMIE;
}
@end

@implementation BarcodeScanVC
@synthesize isFromInstall;
- (void)viewDidLoad
{
    int yy = 64;
    int zz = 0;
    if (IS_IPHONE_X)
    {
        yy = 88;
        zz = 40;
    }
    self.view.backgroundColor = [UIColor blackColor];
    UIView *backView = [[UIView alloc]init];
    backView.frame = CGRectMake(0, yy, DEVICE_WIDTH, DEVICE_HEIGHT-yy-zz);
    backView.backgroundColor = UIColor.whiteColor;
    [self.view addSubview:backView];
    
    [self setNavigationViewFrames];
    [self init_camera];

//    [self setBarcodescannerView];
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}
- (void) readerView:(ZBarReaderView *)readerView didReadSymbols: (ZBarSymbolSet *)symbols fromImage:(UIImage *)image
{
    // Remove the line
    [UIView animateWithDuration:0.2 animations:^{
        laserView.alpha = 0.0;
    }];

    [reader stop];
    isScanOn = NO;
    ZBarSymbol * s = nil;
    for (s in symbols)
    {
        NSString * scanedTxt = s.data;
        [btnStart setTitle:@"Start" forState:UIControlStateNormal];
        NSString * msg = @"NA";
        
        if ([scanedTxt length] == 0 || scanedTxt == nil || [scanedTxt isEqualToString:@" "])
        {
            msg = @"This is not valid IMEI code.";
        }
        else if ([scanedTxt length] <15)
        {
            msg=@"This IMEI code is invalid. It should be 15 digits.";
        }
        else if ([scanedTxt length] >15)
        {
            msg=@"This IMEI code is invalid. It should be 15 digits.";
        }
        else
        {
            txtEmi.text = scanedTxt;
            installScanID = scanedTxt;
            strLocalIMIE = scanedTxt;
            if ([APP_DELEGATE isNetworkreachable])
            {
                //Call Service to get Device details
                [self getDeviceIDfromIMEIRomanAPI];
            }
            else
            {
                [self.navigationController popViewControllerAnimated:YES];
            }
        }
        if ([msg isEqualToString:@"NA"])
        {
            
        }
        else
        {
            URBAlertView *alertView = [[URBAlertView alloc] initWithTitle:scanedTxt message:msg cancelButtonTitle:OK_BTN otherButtonTitles: nil, nil];
            [alertView setMessageFont:[UIFont fontWithName:CGRegular size:14]];
            [alertView setHandlerBlock:^(NSInteger buttonIndex, URBAlertView *alertView) {
                [alertView hideWithCompletionBlock:^{
                }];
            }];
            [alertView showWithAnimation:URBAlertAnimationTopToBottom];
    if (IS_IPHONE_X){[alertView showWithAnimation:URBAlertAnimationDefault];}
        }

    }
}
- (void) init_camera
{
    isScanOn = YES;
     reader = [ZBarReaderView new];
    ZBarImageScanner * scanner = [ZBarImageScanner new];
//    [scanner setSymbology:ZBAR_PARTIAL config:0 to:0];
    [scanner setSymbology:ZBAR_DATABAR config:0 to:0];

    
   reader =  [reader initWithImageScanner:scanner];
    reader.readerDelegate = self;
    
    const float h = [UIScreen mainScreen].bounds.size.height;
    const float w = [UIScreen mainScreen].bounds.size.width;
    const float h_padding = w / 10.0;
    const float v_padding = h / 10.0;
    CGRect reader_rect = CGRectMake(h_padding, v_padding,
                                    w - h_padding * 2.0, h / 3.0);
    reader.frame = reader_rect;
    reader.frame = CGRectMake(0, 64, DEVICE_WIDTH, DEVICE_HEIGHT-64-64);
    reader.backgroundColor = [UIColor clearColor];
    [reader start];
    
    [self.view addSubview: reader];
    
    [self starAnimatedLine];

    UIButton * btnManually = [UIButton buttonWithType:UIButtonTypeCustom];
    [btnManually addTarget:self action:@selector(openManualView) forControlEvents:UIControlEventTouchUpInside];
    btnManually.frame = CGRectMake(0, DEVICE_HEIGHT-64, DEVICE_WIDTH, 64);
    [btnManually setTitle:@"Enter Manually" forState:UIControlStateNormal];
    [btnManually setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    btnManually.backgroundColor = [UIColor blackColor];
    [self.view addSubview:btnManually];
    
    if (IS_IPHONE_X)
    {
        btnManually.frame = CGRectMake(0, DEVICE_HEIGHT-64-40 , DEVICE_WIDTH,64);
        reader.frame = CGRectMake(0, 88, DEVICE_WIDTH, DEVICE_HEIGHT-88-64-40);
    }
}
-(void)starAnimatedLine
{
    // Add the view to draw the bounding box for the UIView
    
    int yy = 64;
    if (IS_IPHONE_X)
    {
        yy = 88;
    }
    
    [boundingBox removeFromSuperview];
    boundingBox = [[RMOutlineBox alloc] initWithFrame:CGRectMake(0, yy, DEVICE_WIDTH, DEVICE_HEIGHT-yy-64)];
    boundingBox.alpha = 0.0;
    [self.view addSubview:boundingBox];
    
    [laserView removeFromSuperview];
    if (!laserView) laserView = [[UIView alloc] initWithFrame:CGRectMake(0, yy, self.view.frame.size.width, 2)];
    laserView.backgroundColor = [UIColor greenColor];
    laserView.layer.shadowColor = [UIColor greenColor].CGColor;
    laserView.layer.shadowOffset = CGSizeMake(0.5, 0.5);
    laserView.layer.shadowOpacity = 0.6;
    laserView.layer.shadowRadius = 1.5;
    laserView.alpha = 0.0;
    if (![[self.view subviews] containsObject:laserView]) [self.view addSubview:laserView];
    
    // Add the line
    [UIView animateWithDuration:0.2 animations:^{
        laserView.alpha = 1.0;
    }];
    
    [UIView animateWithDuration:3.0 delay:0.0 options:UIViewAnimationOptionAutoreverse | UIViewAnimationOptionRepeat | UIViewAnimationOptionCurveEaseInOut animations:^{
        
        laserView.frame = CGRectMake(0, self.view.frame.size.height-yy, self.view.frame.size.width, 2);
    } completion:nil];
}
#pragma mark - Set Frames
-(void)setNavigationViewFrames
{
    UIView * viewHeader = [[UIView alloc] initWithFrame:CGRectMake(0, 0, DEVICE_WIDTH, 64)];
    [viewHeader setBackgroundColor:[UIColor blackColor]];
    [self.view addSubview:viewHeader];
    
     lblTitle = [[UILabel alloc] initWithFrame:CGRectMake(50, 20, DEVICE_WIDTH-100, 44)];
    [lblTitle setBackgroundColor:[UIColor clearColor]];
    [lblTitle setText:@"Scan Barcode"];
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
    
    btnStart = [UIButton buttonWithType:UIButtonTypeCustom];
    [btnStart addTarget:self action:@selector(btnStartClick) forControlEvents:UIControlEventTouchUpInside];
    btnStart.frame = CGRectMake(DEVICE_WIDTH-60, 20, 60, 44);
    [btnStart setTitle:@"Stop" forState:UIControlStateNormal];
    btnStart.backgroundColor = [UIColor clearColor];
    btnStart.titleLabel.font = [UIFont fontWithName:CGRegular size:14];
    [viewHeader addSubview:btnStart];
    
    if (IS_IPHONE_X)
    {
        viewHeader.frame = CGRectMake(0, 0, DEVICE_WIDTH, 88);
        lblTitle.frame = CGRectMake(50, 40, DEVICE_WIDTH-100, 44);
        backImg.frame = CGRectMake(10, 12+44, 12, 20);
        btnBack.frame = CGRectMake(0, 0, 70, 88);
        btnStart.frame = CGRectMake(DEVICE_WIDTH-60, 40, 60, 44);
    }
}


#pragma mark - Button Clicks
-(void)btnBackClick
{
    [self.navigationController popViewControllerAnimated:YES];
}
-(void)btnStartClick
{
    if (isScanOn)
    {
        // Remove the line
        [UIView animateWithDuration:0.2 animations:^{
            laserView.alpha = 0.0;
        }];
        isScanOn  = NO;
        [reader stop];
        [btnStart setTitle:@"Start" forState:UIControlStateNormal];
    }
    else
    {
        isScanOn  = YES;
        [reader start];
        [self starAnimatedLine];
        [btnStart setTitle:@"Stop" forState:UIControlStateNormal];
    }
}

- (BOOL)shouldEndSessionAfterFirstSuccessfulScan {
    // Return YES to only scan one barcode, and then finish - return NO to continually scan.
    // If you plan to test the return NO functionality, it is recommended that you remove the alert view from the "didScanCode:" delegate method implementation
    // The Display Code Outline only works if this method returns NO
    return YES;
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == 111)
    {
        [self.navigationController popViewControllerAnimated:YES];
    }
    else
    {
        if ([[alertView buttonTitleAtIndex:buttonIndex] isEqualToString:@"New Session"])
        {
            [scannerView startScanSession];
            [btnStart setTitle:@"Stop" forState:UIControlStateNormal];
        }
        else if ([[alertView buttonTitleAtIndex:buttonIndex] isEqualToString:@"Okay"])
        {
            [btnStart setTitle:@"Start" forState:UIControlStateNormal];
        }
    }
}

- (UIBarPosition)positionForBar:(id <UIBarPositioning>)bar {
    return UIBarPositionTopAttached;
}


#pragma mark - Set UI frames
-(void)setManualView
{
    // Remove the line
    [UIView animateWithDuration:0.2 animations:^{
        laserView.alpha = 0.0;
    }];
    [btnStart setTitle:@"Start" forState:UIControlStateNormal];
    [reader stop];
    isScanOn = NO;

    [viewOverLay removeFromSuperview];
    viewOverLay = [[UIView alloc] initWithFrame:CGRectMake(0, 0, DEVICE_WIDTH, DEVICE_HEIGHT)];
    //    [viewOverLay setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"actionsheet_overlay.png"]]];
    [self.view addSubview:viewOverLay];
    
    backView = [[UIView alloc] init];
    backView.frame = CGRectMake(0, 0, DEVICE_WIDTH, DEVICE_HEIGHT);
    backView.backgroundColor = [UIColor blackColor];
    [backView setAlpha:0.7];
    [viewOverLay addSubview:backView];
    
    [viewMore removeFromSuperview];
    viewMore = [[UIView alloc] initWithFrame:CGRectMake(20, DEVICE_HEIGHT, self.view.frame.size.width-40, 180+20)];
    [viewMore setBackgroundColor:[UIColor blackColor]];
    viewMore.layer.shadowColor = [UIColor darkGrayColor].CGColor;
    viewMore.layer.shadowOffset = CGSizeMake(0.1, 0.1);
    viewMore.layer.shadowRadius = 3;
    viewMore.layer.shadowOpacity = 0.5;
    [viewOverLay addSubview:viewMore];
    
    int yy = 10;
    
    UILabel *lblTitle =[[UILabel alloc]initWithFrame:CGRectMake(0, 10, viewMore.frame.size.width, 20)];
    lblTitle.text= @"IMEI Code";
    lblTitle.textColor=[UIColor whiteColor];
    lblTitle.textAlignment=NSTextAlignmentCenter;
    lblTitle.clipsToBounds=NO;
    lblTitle.shadowOffset= CGSizeMake(0.0, -1.0);
    lblTitle.shadowColor=[UIColor clearColor];
    [lblTitle setFont:[UIFont fontWithName:CGBold size:14]];
    [viewMore addSubview:lblTitle];
    
    yy = yy+25+5;
    
    UILabel *lblmessage =[[UILabel alloc]initWithFrame:CGRectMake(5, yy, viewMore.frame.size.width-10, 50)];
    if (isManual)
    {
        lblmessage.text= @"Please enter device IMEI code manually";
    }
    else
    {
        lblmessage.text= @"Your device does not support Camera for barcode scan. Please enter device IMEI code manually";
    }
    lblmessage.textColor=[UIColor whiteColor];
    lblmessage.textAlignment=NSTextAlignmentCenter;
    lblmessage.clipsToBounds=NO;
    lblmessage.shadowOffset= CGSizeMake(0.0, -1.0);
    lblmessage.shadowColor=[UIColor clearColor];
    lblmessage.font=[UIFont fontWithName:CGRegular size:14];
    lblmessage.numberOfLines=0;
    [viewMore addSubview:lblmessage];
    
    yy = yy+50;
    
    
    txtEmi = [[UITextField alloc] initWithFrame:CGRectMake(20, yy, viewMore.frame.size.width-40, 35)];
    txtEmi.placeholder = @"Enter IMEI Code";
    txtEmi.autocapitalizationType = UITextAutocapitalizationTypeNone;
    txtEmi.delegate = self;
    txtEmi.autocorrectionType = UITextAutocorrectionTypeNo;
    txtEmi.keyboardType = UIKeyboardTypeNumberPad;
    txtEmi.textColor = [UIColor whiteColor];
    [txtEmi setFont:[UIFont fontWithName:CGRegular size:14]];
    [APP_DELEGATE getPlaceholderText:txtEmi andColor:UIColor.whiteColor];
    [viewMore addSubview:txtEmi];
    
    UILabel * lblEmailLine = [[UILabel alloc] initWithFrame:CGRectMake(0, txtEmi.frame.size.height-2, txtEmi.frame.size.width, 1)];
    [lblEmailLine setBackgroundColor:[UIColor lightGrayColor]];
    [txtEmi addSubview:lblEmailLine];
    
    
    yy = yy+40;
    
    lblerror =[[UILabel alloc]initWithFrame:CGRectMake(20, yy, viewMore.frame.size.width-50, 20)];
    lblerror.textAlignment=NSTextAlignmentLeft;
    lblerror.font=[UIFont fontWithName:CGRegular size:10];
    lblerror.textColor=[UIColor redColor];
    [viewMore addSubview:lblerror];
    
    btncancel =[UIButton buttonWithType:UIButtonTypeSystem];
    [btncancel setFrame:CGRectMake(0, viewMore.frame.size.height-40, (viewMore.frame.size.width/2)+10, 40)];
    [btncancel setTitle:ALERT_CANCEL forState:UIControlStateNormal];
    [btncancel setBackgroundColor:[UIColor blackColor]];
    [btncancel setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    btncancel.layer.borderWidth=0.5;
    btncancel.layer.borderColor=[UIColor darkGrayColor].CGColor;
    btncancel.titleLabel.font = [UIFont fontWithName:CGRegular size:14];
    [btncancel addTarget:self action:@selector(AlertCancleClicked) forControlEvents:UIControlEventTouchUpInside];
    [viewMore addSubview:btncancel];
    
    
    btnOk =[UIButton buttonWithType:UIButtonTypeSystem];
    [btnOk setFrame:CGRectMake((viewMore.frame.size.width/2)-1, viewMore.frame.size.height-40, (viewMore.frame.size.width/2)+1, 40)];
    [btnOk setTitle:@"Save" forState:UIControlStateNormal];
    [btnOk setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [btnOk setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    btnOk.layer.borderWidth=0.5;
    btnOk.backgroundColor = [UIColor blackColor];
    btnOk.layer.borderColor=[UIColor darkGrayColor].CGColor;
    btnOk.titleLabel.font = [UIFont fontWithName:CGRegular size:14];
    [btnOk addTarget:self action:@selector(AlertOKClicked) forControlEvents:UIControlEventTouchUpInside];
    [viewMore addSubview:btnOk];
    
    [viewMore setFrame:CGRectMake(20, DEVICE_HEIGHT, self.view.frame.size.width-40, 200)];
    [self hideMorePopUpView:NO];
    
}
-(void)openManualView
{
    isManual = YES;
    [self setManualView];
}
-(void)hideMorePopUpView:(BOOL)isHide
{
    [txtEmi resignFirstResponder];
    
    if (isHide == YES)
    {
        [UIView animateWithDuration:0.4
                              delay:0.0
                            options: UIViewAnimationOptionOverrideInheritedCurve
                         animations:^{
                             viewMore.frame = CGRectMake(20, DEVICE_HEIGHT , DEVICE_WIDTH-40, viewMore.frame.size.height);
                         }
                         completion:^(BOOL finished){
                             [viewMore removeFromSuperview];
                             [viewOverLay removeFromSuperview];
                         }];
    }
    else
    {
        [UIView animateWithDuration:0.5 delay:0.0 options: UIViewAnimationOptionOverrideInheritedCurve
                         animations:^{
                             viewMore.frame = CGRectMake(20, (DEVICE_HEIGHT-(viewMore.frame.size.height))/2 , DEVICE_WIDTH-40, viewMore.frame.size.height);
                         }
                         completion:^(BOOL finished)
         {
             
         }];
    }
}
-(void)AlertCancleClicked
{
    if (isManual)
    {
        NSLog(@"AlertCancleClicked");
        [self hideMorePopUpView:YES];
    }
    else
    {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

-(void)AlertOKClicked
{

    [txtEmi resignFirstResponder];
    if ([txtEmi.text length] == 0 || txtEmi.text == nil || [txtEmi.text isEqualToString:@" "])
    {
        lblerror.text=@"Please enter IMEI code";
        lblerror.hidden=NO;
    }
    else if ([txtEmi.text length] <15)
    {
        lblerror.text=@"Please enter 15 digit IMEI code";
        lblerror.hidden=NO;
    }
    else if ([txtEmi.text length] >16)
    {
        lblerror.text=@"IMEI code should not be greater than 15 digits";
        lblerror.hidden=NO;
    }
    else if ([txtEmi.text rangeOfString:@" "].location != NSNotFound)
    {
        lblerror.text=@"Please remove white space from IMEI code";
        lblerror.hidden=NO;
    }
    else if ([txtEmi.text rangeOfString:@"%"].location != NSNotFound)
    {
        lblerror.text=@"Please remove % from IMEI code";
        lblerror.hidden=NO;
    }
    else
    {
        [self hideMorePopUpView:YES];

        viewMore.hidden = YES;
        lblerror.hidden=YES;
        installScanID = txtEmi.text;
        strLocalIMIE = txtEmi.text;
        //Call Service to get Device details

        if ([APP_DELEGATE isNetworkreachable])
        {
            //Call Service to get Device details
//            [self getDeviceDetailService];
            [self getDeviceIDfromIMEIRomanAPI];
        }
        else
        {
            [self.navigationController popViewControllerAnimated:YES];
        }
    }
}

#pragma mark - Textfield Delegates
-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}
-(void)textFieldDidBeginEditing:(UITextField *)textField
{
    [UIView animateWithDuration:0.3 animations:^{
        if (IS_IPHONE_X)
        {
        }
        else
        {
            if (IS_IPHONE_4)
            {
                [viewMore setFrame:CGRectMake(20, (DEVICE_HEIGHT-(viewMore.frame.size.height))/2 -140, DEVICE_WIDTH-40, viewMore.frame.size.height)];
            }
            else
            {
                [viewMore setFrame:CGRectMake(20, (DEVICE_HEIGHT-(viewMore.frame.size.height))/2- 100 , DEVICE_WIDTH-40, viewMore.frame.size.height)];
            }
        }
      
    }];

    UIToolbar* numberToolbar = [[UIToolbar alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 50)];
    numberToolbar.barStyle =  UIBarStyleDefault;
    UIBarButtonItem *space =[[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    UIBarButtonItem *Done = [[UIBarButtonItem alloc]initWithTitle:@"Done" style:UIBarButtonItemStyleDone target:self action:@selector(doneKeyBoarde)];
    Done.tintColor=[APP_DELEGATE colorWithHexString:App_Header_Color];
    numberToolbar.items = [NSArray arrayWithObjects:space,Done,
                           nil];
    [numberToolbar sizeToFit];
    textField.inputAccessoryView = numberToolbar;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string;   // return NO to not change text
{
    if (textField == txtEmi)
    {
        if ([string rangeOfCharacterFromSet:[NSCharacterSet decimalDigitCharacterSet].invertedSet].location != NSNotFound)
        {
            // BasicAlert(@"", @"This field accepts only numeric entries.");
            return NO;
        }
    }
    
    if(range.length + range.location > textField.text.length)
    {
        return NO;
    }
    
    NSUInteger newLength = [textField.text length] + [string length] - range.length;
    return newLength <= 16;
}
-(void)doneKeyBoarde
{
    if (IS_IPHONE_X)
    {
        
    }
    else
    {
        [viewMore setFrame:CGRectMake(20, (DEVICE_HEIGHT-(viewMore.frame.size.height))/2 , DEVICE_WIDTH-40, viewMore.frame.size.height)];
    }
    [txtEmi resignFirstResponder];
}
-(void)textFieldDidEndEditing:(UITextField *)textField
{
    [UIView animateWithDuration:0.3 animations:^{
        [viewMore setFrame:CGRectMake(20, (DEVICE_HEIGHT-(viewMore.frame.size.height))/2 , DEVICE_WIDTH-40, viewMore.frame.size.height)];
    }];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Web Service Call
-(void)getDeviceIDfromIMEIRomanAPI
{
    if ([APP_DELEGATE isNetworkreachable])
    {
        [APP_DELEGATE endHudProcess];
        [APP_DELEGATE startHudProcess:@"Getting details..."];
    }
    
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0ul);
    dispatch_async(queue, ^{
        {
            NSMutableDictionary *args = [[NSMutableDictionary alloc] init];
            NSString * strUrl = [NSString stringWithFormat:@"https://ws.scstg.net/basic/v2/device/getForImei/%@",strLocalIMIE];
            
            NSString * strbasicAuthToken;
            NSString * strUserName = [NSString stringWithFormat:@"%@",CURRENT_USER_EMAIL];
            NSString * strPassword = [NSString stringWithFormat:@"%@",CURRENT_USER_PASS];
            NSString * str = [NSString stringWithFormat:@"%@:%@",strUserName,strPassword];
            NSString * simpleStr = [APP_DELEGATE base64String:str];
            strbasicAuthToken = simpleStr;
            
            AFHTTPRequestOperationManager *manager1 = [[AFHTTPRequestOperationManager alloc] initWithBaseURL:[NSURL URLWithString:@"http://server.url"]];
            NSString *authorization = [NSString stringWithFormat: @"Basic %@",strbasicAuthToken];
            [manager1.requestSerializer setValue:authorization forHTTPHeaderField:@"Authorization"];
            
            AFHTTPRequestOperation *op = [manager1 GET:strUrl parameters:args success:^(AFHTTPRequestOperation *operation, id responseObject){
                NSLog(@"Success Response with Result=%@",responseObject);
                
                [APP_DELEGATE endHudProcess];

                NSMutableDictionary * dictID = [[NSMutableDictionary alloc] init];
                dictID = [responseObject mutableCopy];
                if ([[self checkforValidString:[dictID valueForKey:@"id"]] isEqualToString:@"NA"])
                {
                    [self ErrorMessagePopup];
                }
                else
                {
                    if ([dictID count]>=10)
                    {
                        globalDeviceType =@"SC2";
                        globalWarrantyStatus =@"";
                        globalDeviceType =[dictID valueForKey:@"type"];
                        NSString * strTimeStampWarranty = [NSString stringWithFormat:@"%@",[dictID valueForKey:@"warrantyExpires"]];
                        globalWarrantyStatus =[APP_DELEGATE GetRealDatefromTimeStamp:strTimeStampWarranty];
                        
                        if ([installScanID  isEqualToString:@"357152070984180"])
                        {
                            globalDeviceType =@"SC3";
                        }
                        if ([isFromInstall isEqualToString:@"UnInstall"])
                        {
                            [self CheckValidationforUinstallAndInspection:dictID];
                        }
                        else if([isFromInstall isEqualToString:@"Inspection"])
                        {
                            [self CheckValidationforUinstallAndInspection:dictID];
                        }
                        else if([isFromInstall isEqualToString:@"NewInstall"])
                        {
                            [self CheckValidationforInstallation:dictID];
                        }
                        else
                        {
                            [self CheckValidationforInstallation:dictID];
                        }
                    }
                    else
                    {
                        [self ErrorMessagePopup];
                    }
                }
            }
                                               failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                                   if (error) {
                                                       [APP_DELEGATE endHudProcess];
                                                       NSLog(@"Servicer error = %@", error);
                                                       [self ErrorMessagePopup];
                                                   }
                                               }];
            [op start];
        }
        // Perform async operation
        // Call your method/function here
        // Example:
        dispatch_sync(dispatch_get_main_queue(), ^{
            //Method call finish here
        });
    });
}
-(void)TestDeviceRomanAPI
{
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0ul);
    dispatch_async(queue, ^{
        {
            NSMutableDictionary *args = [[NSMutableDictionary alloc] init];
            
            NSString * strUrl = [NSString stringWithFormat:@"https://ws.scstg.net/basic/v2/device-history/getLatestInstallFor/%@",strSuccorfishDeviceID];
            
            NSString * strbasicAuthToken;
            NSString * strUserName = [NSString stringWithFormat:@"%@",CURRENT_USER_EMAIL];
            NSString * strPassword = [NSString stringWithFormat:@"%@",CURRENT_USER_PASS];
            NSString * str = [NSString stringWithFormat:@"%@:%@",strUserName,strPassword];
            NSString * simpleStr = [APP_DELEGATE base64String:str];
            strbasicAuthToken = simpleStr;
            
            AFHTTPRequestOperationManager *manager1 = [[AFHTTPRequestOperationManager alloc] initWithBaseURL:[NSURL URLWithString:@"http://server.url"]];
            //[manager1.requestSerializer setValue:@"multipart/form-data" forHTTPHeaderField:@"Content-Type"];
            NSString *authorization = [NSString stringWithFormat: @"Basic %@",strbasicAuthToken];
            [manager1.requestSerializer setValue:authorization forHTTPHeaderField:@"Authorization"];
            //[manager1.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Accept"];
            //manager1.responseSerializer = [AFHTTPResponseSerializer serializer];
            
            AFHTTPRequestOperation *op = [manager1 GET:strUrl parameters:args success:^(AFHTTPRequestOperation *operation, id responseObject){
                NSLog(@"Success Response with Result=%@",responseObject);
                
                [APP_DELEGATE endHudProcess];
                
                if ([responseObject isKindOfClass:[NSDictionary class]])
                {
                    NSMutableDictionary * dictID = [[NSMutableDictionary alloc] init];
                    dictID = [responseObject mutableCopy];
                    NSString * strGeneratDate = [NSString stringWithFormat:@"%@",[dictID valueForKey:@"created"]];

                    NSString *_date= [APP_DELEGATE GetRealDatefromTimeStamp:strGeneratDate];
                    
                    
                    NSMutableDictionary * dtaliDict = [[NSMutableDictionary alloc] init];
                    [dtaliDict setObject:_date forKey:@"date"];
                    [dtaliDict setObject:strLocalIMIE forKey:@"imei"];
                    [dtaliDict setObject:_date forKey:@"date"];
                    [dtaliDict setObject:[dictID valueForKey:@"installationPlace"] forKey:@"location"];
                    [dtaliDict setObject:[dictID valueForKey:@"realAssetName"] forKey:@"vessel"];
                    [dtaliDict setObject:[self checkforValidString:[dictID valueForKey:@"realAssetRegNo"]] forKey:@"regino"];

                    LastWaypointVC * lastVC = [[LastWaypointVC alloc] init];
                    lastVC.detailDict = dtaliDict;
                    lastVC.isfromHistory = YES;
                    [self.navigationController pushViewController:lastVC animated:YES];
                }
                else
                {
                    [self ErrorMessagePopup];
                }
                
            }
                                               failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                                   if (error) {
                                                       [APP_DELEGATE endHudProcess];
                                                       
                                                       NSLog(@"Servicer error = %@", error);
                                                       [self ErrorMessagePopup];
                                                       
                                                   }
                                               }];
            [op start];
        }
        // Perform async operation
        // Call your method/function here
        // Example:
        dispatch_sync(dispatch_get_main_queue(), ^{
            //Method call finish here
        });
    });
}
//-(void)getDeviceDetailService
//{
//    [APP_DELEGATE endHudProcess];
//    [APP_DELEGATE startHudProcess:@"Getting details..."];
//
//    websrviceName=@"checkdevice";
//
//    if ([isFromInstall isEqualToString:@"NewInstall"])
//    {
//        websrviceName=@"checkdevice";
//    }
//    else
//    {
//        websrviceName=@"testdevice";
//    }
//    NSMutableDictionary * dict = [[NSMutableDictionary alloc]init];
//    [dict setValue:installScanID forKey:@"imei"];
//    [dict setValue:CURRENT_USER_ID forKey:@"user_id"];
//
//    URLManager *manager = [[URLManager alloc] init];
//    manager.commandName = websrviceName;
//    manager.delegate = self;
//    NSString *strServerUrl = @"http://succorfish.in/mobile/";
//    [manager postUrlCall:[NSString stringWithFormat:@"%@%@",strServerUrl,websrviceName] withParameters:dict];
//}
-(void)fetchInstalledInformationfromServer
{
    if ([APP_DELEGATE isNetworkreachable])
    {
        [APP_DELEGATE endHudProcess];
        [APP_DELEGATE startHudProcess:@"Fetching device details..."];
    }
    
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0ul);
    dispatch_async(queue, ^{
        {
            NSMutableDictionary *args = [[NSMutableDictionary alloc] init];
            
            NSString * strUrl = [NSString stringWithFormat:@"https://ws.scstg.net/basic/v2/device-history/getLatestInstallFor/%@",strSuccorfishDeviceID];
            
            NSString * strbasicAuthToken;
            NSString * strUserName = [NSString stringWithFormat:@"%@",CURRENT_USER_EMAIL];
            NSString * strPassword = [NSString stringWithFormat:@"%@",CURRENT_USER_PASS];
            NSString * str = [NSString stringWithFormat:@"%@:%@",strUserName,strPassword];
            NSString * simpleStr = [APP_DELEGATE base64String:str];
            strbasicAuthToken = simpleStr;
            
            AFHTTPRequestOperationManager *manager1 = [[AFHTTPRequestOperationManager alloc] initWithBaseURL:[NSURL URLWithString:@"http://server.url"]];
            NSString *authorization = [NSString stringWithFormat: @"Basic %@",strbasicAuthToken];
            [manager1.requestSerializer setValue:authorization forHTTPHeaderField:@"Authorization"];
            
            AFHTTPRequestOperation *op = [manager1 GET:strUrl parameters:args success:^(AFHTTPRequestOperation *operation, id responseObject){
                NSLog(@"Success Response with Result=%@",responseObject);
                
                [APP_DELEGATE endHudProcess];
                
                NSMutableDictionary * dictID = [[NSMutableDictionary alloc] init];
                dictID = [responseObject mutableCopy];
                
                [self fillDictionaryforDeviceDetails:dictID];
                
//                globalDeviceType =[dictID valueForKey:@"deviceType"];
                [dictID setValue:@"Yes" forKey:@"DataAvail"];
                
                if ([isFromInstall isEqualToString:@"UnInstall"])
                {
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"DeviceInfoForUninstall" object:gotDeviceDetailDict];
                    
                }
                else
                {
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"DeviceInfoForInspection" object:gotDeviceDetailDict];
                }
                [self.navigationController popViewControllerAnimated:YES];
            }
                                               failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                                   if (error) {
                                                       [APP_DELEGATE endHudProcess];
                                                       
                                                       NSLog(@"Servicer error = %@", error);
                                                       [self ErrorMessagePopup];
                                                       
                                                   }
                                               }];
            [op start];
        }
        // Perform async operation
        // Call your method/function here
        // Example:
        dispatch_sync(dispatch_get_main_queue(), ^{
            //Method call finish here
        });
    });
}
#pragma mark - UrlManager Delegate
- (void)onResult:(NSDictionary *)result
{
    [APP_DELEGATE endHudProcess];
    NSLog(@"The result is...%@", result);
    
    if ([[result valueForKey:@"commandName"] isEqualToString:@"checkdevice"])
    {
        if ([[[result valueForKey:@"result"] valueForKey:@"response"] isEqualToString:@"true"])
        {
            if ([[[result valueForKey:@"result"] valueForKey:@"message"] isEqualToString:@"Device not found with this IMEI!"])
            {
                NSString * strMessage = [NSString stringWithFormat:@"This IMEI code doesn't exist with us. Please check IMEI code."];
                globalDeviceType =@"";

                URBAlertView *alertView = [[URBAlertView alloc] initWithTitle:ALERT_TITLE message:strMessage cancelButtonTitle:OK_BTN otherButtonTitles: nil, nil];
                [alertView setMessageFont:[UIFont fontWithName:CGRegular size:12]];
                [alertView setHandlerBlock:^(NSInteger buttonIndex, URBAlertView *alertView) {
                    [alertView hideWithCompletionBlock:^{
                        installScanID = @"";
                        globalDeviceType =@"";
                        installVesselName = @"";
                        installRegi = @"";
                    
                        [self.navigationController popViewControllerAnimated:YES];
                    }];
                }];
                  [alertView showWithAnimation:Alert_Animation_Type];
        if (IS_IPHONE_X) {[alertView showWithAnimation:URBAlertAnimationDefault];}
            }
            else if ([[[result valueForKey:@"result"] valueForKey:@"message"] isEqualToString:@"New fresh device found successfully."])
            {
                NSMutableDictionary * tmpDict = [[NSMutableDictionary alloc] init];
                tmpDict = [[result valueForKey:@"result"] valueForKey:@"data"];

                /*globalDeviceType =@"SC2";
                globalWarrantyStatus =@"";
                
                if ([installScanID  isEqualToString:@"357152070984180"])
                {
                    globalDeviceType =@"SC3";
                }
                if (tmpDict == [NSNull null] || tmpDict == nil)
                {
                }
                else
                {
                    globalDeviceType =[tmpDict valueForKey:@"device_type"];
                    globalWarrantyStatus =[tmpDict valueForKey:@"warranty"];
                }*/
                [self.navigationController popViewControllerAnimated:YES];
            }
            else
            {
                NSMutableDictionary * tmpDict = [[NSMutableDictionary alloc] init];
                tmpDict = [[result valueForKey:@"result"] valueForKey:@"data"];

                if (tmpDict == [NSNull null] || tmpDict == nil)
                {
                }
                else
                {
                    if ([[tmpDict valueForKey:@"status"] isEqualToString:@"1"])
                    {
                        NSString * strMessage = [NSString stringWithFormat:@"This device %@ is already installed somewhere. Please uninstall first and then try again to Install it.",strLocalIMIE];
                        URBAlertView *alertView = [[URBAlertView alloc] initWithTitle:ALERT_TITLE message:strMessage cancelButtonTitle:@"OK" otherButtonTitles: @"View last Installation", nil];
                        [alertView setMessageFont:[UIFont fontWithName:CGRegular size:12]];
                        [alertView setHandlerBlock:^(NSInteger buttonIndex, URBAlertView *alertView) {
                            [alertView hideWithCompletionBlock:^{
                                
                                if (buttonIndex==0)
                                {
                                    globalDeviceType = @"";
                                    globalWarrantyStatus =@"";
                                    installScanID = @"";
                                    installVesselName = @"";
                                    installRegi = @"";
                                    [self.navigationController popViewControllerAnimated:YES];
                                }
                                else
                                {
                                    globalDeviceType = @"";
                                    globalWarrantyStatus =@"";
                                    installScanID = @"";
                                    installVesselName = @"";
                                    installRegi = @"";

                                    TestDeviceVC * testVC = [[TestDeviceVC alloc] init];
                                    testVC.detailDict =tmpDict;
                                    testVC.strReasonToCome = @"View last Installation";
                                    testVC.strReportType = isFromInstall;
                                    [self.navigationController pushViewController:testVC animated:YES];
                                }
                            }];
                        }];
                          [alertView showWithAnimation:Alert_Animation_Type];
        if (IS_IPHONE_X) {[alertView showWithAnimation:URBAlertAnimationDefault];}
                    }
                    else if ([[tmpDict valueForKey:@"status"] isEqualToString:@"2"] || [[tmpDict valueForKey:@"status"] isEqualToString:@"0"])
                    {
                        installVesselName = @"";
                        installRegi = @"";

                        NSString * strMessage = [NSString stringWithFormat:@"This device %@ is ready to use.",strLocalIMIE];
                        URBAlertView *alertView = [[URBAlertView alloc] initWithTitle:ALERT_TITLE message:strMessage cancelButtonTitle:OK_BTN otherButtonTitles: @"View last Installation", nil];
                        [alertView setMessageFont:[UIFont fontWithName:CGRegular size:12]];
                        [alertView setHandlerBlock:^(NSInteger buttonIndex, URBAlertView *alertView) {
                            [alertView hideWithCompletionBlock:^{
                                if (buttonIndex==0)
                                {
//                                    globalDeviceType =[tmpDict valueForKey:@"device_type"];
//                                    globalWarrantyStatus =[tmpDict valueForKey:@"warranty"];

                                    [self.navigationController popViewControllerAnimated:YES];
                                }
                                else
                                {
//                                    globalDeviceType =[tmpDict valueForKey:@"device_type"];
//                                    globalWarrantyStatus =[tmpDict valueForKey:@"warranty"];

                                    TestDeviceVC * testVC = [[TestDeviceVC alloc] init];
                                    testVC.detailDict =tmpDict;
                                    testVC.strReportType = isFromInstall;
                                    testVC.strReasonToCome = @"View last Installation";
                                    [self.navigationController pushViewController:testVC animated:YES];
                                }
                            }];
                        }];
                          [alertView showWithAnimation:Alert_Animation_Type];
        if (IS_IPHONE_X) {[alertView showWithAnimation:URBAlertAnimationDefault];}
                    }
                }
            }
        }
        else
        {
            if ([[[result valueForKey:@"result"] valueForKey:@"message"] isEqualToString:@"Invalid Token"])
            {
                [APP_DELEGATE showSessionExpirePopup];
            }
            else if ([[[result valueForKey:@"result"] valueForKey:@"message"] isEqualToString:@"Device not found with this IMEI!"])
            {
                NSString * strMessage = [NSString stringWithFormat:@"This IMEI code doesn't exist with us. Please check IMEI code."];
                
                URBAlertView *alertView = [[URBAlertView alloc] initWithTitle:ALERT_TITLE message:strMessage cancelButtonTitle:OK_BTN otherButtonTitles: nil, nil];
                [alertView setMessageFont:[UIFont fontWithName:CGRegular size:12]];
                [alertView setHandlerBlock:^(NSInteger buttonIndex, URBAlertView *alertView) {
                    [alertView hideWithCompletionBlock:^{
                        globalDeviceType = @"";
                        globalWarrantyStatus =@"";
                        installScanID = @"";
                        installVesselName = @"";
                        installRegi = @"";
                        [self.navigationController popViewControllerAnimated:YES];
                    }];
                }];
                  [alertView showWithAnimation:Alert_Animation_Type];
        if (IS_IPHONE_X) {[alertView showWithAnimation:URBAlertAnimationDefault];}
            }
        }
    }
    else if ([[result valueForKey:@"commandName"] isEqualToString:@"testdevice"])
    {
        if ([[[result valueForKey:@"result"] valueForKey:@"response"] isEqualToString:@"true"])
        {
            if ([[[result valueForKey:@"result"] valueForKey:@"message"] isEqualToString:@"Device not exists with this IMEI!"])
            {
                NSMutableDictionary * tmpDict = [[NSMutableDictionary alloc] init];
                tmpDict = [[result valueForKey:@"result"] valueForKey:@"data"];
                [tmpDict setValue:@"No" forKey:@"DataAvail"];

                NSString * strMessage = [NSString stringWithFormat:@"This device %@ can't be uninstalled as its not installed anywhere.",strLocalIMIE];
                if ([isFromInstall isEqualToString:@"Inspection"])
                {
                    strMessage = [NSString stringWithFormat:@"This device %@ can't be inspected as its not installed anywhere.",strLocalIMIE];
                }
                URBAlertView *alertView = [[URBAlertView alloc] initWithTitle:ALERT_TITLE message:strMessage cancelButtonTitle:OK_BTN otherButtonTitles:@"View last Installation", nil];
                [alertView setMessageFont:[UIFont fontWithName:CGRegular size:12]];
                [alertView setHandlerBlock:^(NSInteger buttonIndex, URBAlertView *alertView) {
                    [alertView hideWithCompletionBlock:^{
                        if (buttonIndex==0)
                        {
                            installScanID = @"";
                            [self.navigationController popViewControllerAnimated:YES];
                        }
                        else
                        {
                            TestDeviceVC * testVC = [[TestDeviceVC alloc] init];
                            testVC.detailDict =tmpDict;
                            testVC.strReasonToCome = @"View last Installation";
                            testVC.strReportType = isFromInstall;
                            [self.navigationController pushViewController:testVC animated:YES];
                        }
                    }];
                }];
                  [alertView showWithAnimation:Alert_Animation_Type];
        if (IS_IPHONE_X) {[alertView showWithAnimation:URBAlertAnimationDefault];}
            }
            else
            {
                NSMutableDictionary * tmpDict = [[NSMutableDictionary alloc] init];
                tmpDict = [[result valueForKey:@"result"] valueForKey:@"data"];
//                globalDeviceType =[tmpDict valueForKey:@"device_type"];
//                globalWarrantyStatus =[tmpDict valueForKey:@"warranty"];
                [tmpDict setValue:@"Yes" forKey:@"DataAvail"];
                if ([isFromInstall isEqualToString:@"UnInstall"])
                {
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"DeviceInfoForUninstall" object:tmpDict];
                }
                else
                {
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"DeviceInfoForInspection" object:tmpDict];
                }
                
                NSString * strMessage = [NSString stringWithFormat:@"This device %@ is ready to Uninstall.",installScanID];
                if ([isFromInstall isEqualToString:@"Inspection"])
                {
                    strMessage = [NSString stringWithFormat:@"This device %@ is ready to Inspect.",installScanID];
                }
                URBAlertView *alertView = [[URBAlertView alloc] initWithTitle:ALERT_TITLE message:strMessage cancelButtonTitle:OK_BTN otherButtonTitles: @"View last Installation", nil];
                [alertView setMessageFont:[UIFont fontWithName:CGRegular size:12]];
                [alertView setHandlerBlock:^(NSInteger buttonIndex, URBAlertView *alertView) {
                    [alertView hideWithCompletionBlock:^{
                        if (buttonIndex==0)
                        {
                            [self.navigationController popViewControllerAnimated:YES];
                        }
                        else
                        {
                            TestDeviceVC * testVC = [[TestDeviceVC alloc] init];
                            testVC.detailDict =tmpDict;
                            testVC.strReasonToCome = @"View last Installation";
                            testVC.strReportType = isFromInstall;
                            [self.navigationController pushViewController:testVC animated:YES];
                        }
                    }];
                }];
                  [alertView showWithAnimation:Alert_Animation_Type];
        if (IS_IPHONE_X) {[alertView showWithAnimation:URBAlertAnimationDefault];}
//                [self.navigationController popViewControllerAnimated:YES];
            }
        }
        else
        {
            if ([[[result valueForKey:@"result"] valueForKey:@"message"] isEqualToString:@"Invalid Token"])
            {
                [APP_DELEGATE showSessionExpirePopup];
            }
            else if([[[result valueForKey:@"result"] valueForKey:@"message"] isEqualToString:@"Device not exists with this IMEI!"])
            {
                NSString * strMessage = [[result valueForKey:@"result"] valueForKey:@"message"];
                URBAlertView *alertView = [[URBAlertView alloc] initWithTitle:ALERT_TITLE message:strMessage cancelButtonTitle:OK_BTN otherButtonTitles: nil, nil];
                [alertView setMessageFont:[UIFont fontWithName:CGRegular size:12]];
                [alertView setHandlerBlock:^(NSInteger buttonIndex, URBAlertView *alertView) {
                    [alertView hideWithCompletionBlock:^{
                        installScanID = @"";
                        [self.navigationController popViewControllerAnimated:YES];
                    }];
                }];
                  [alertView showWithAnimation:Alert_Animation_Type];
        if (IS_IPHONE_X) {[alertView showWithAnimation:URBAlertAnimationDefault];}
            }
        }
    }
}

- (void)onError:(NSError *)error
{
    [APP_DELEGATE endHudProcess];
    
    NSLog(@"The error is...%@", error);
    
    [btnOk setTitle:OK_BTN forState:UIControlStateNormal];
    [btncancel setEnabled:YES];
    [btncancel setTitle:ALERT_CANCEL forState:UIControlStateNormal];
    
    NSInteger ancode = [error code];
    
    NSMutableDictionary * errorDict = [error.userInfo mutableCopy];
    NSLog(@"errorDict===%@",errorDict);
    
    if (ancode == -1001 || ancode == -1004 || ancode == -1005 || ancode == -1009)
    {
        [APP_DELEGATE ShowErrorPopUpWithErrorCode:ancode andMessage:@""];
    }
    else
    {
        [APP_DELEGATE ShowErrorPopUpWithErrorCode:customErrorCodeForMessage andMessage:@"Please try again later"];
    }
    
    
    NSString * strLoginUrl = [NSString stringWithFormat:@"%@%@",WEB_SERVICE_URL,@"token.json"];
    if ([[errorDict valueForKey:@"NSErrorFailingURLStringKey"] isEqualToString:strLoginUrl])
    {
        NSLog(@"NSErrorFailingURLStringKey===%@",[errorDict valueForKey:@"NSErrorFailingURLStringKey"]);
    }
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
-(void)ErrorMessagePopup
{
    globalDeviceType = @"";
    globalWarrantyStatus =@"";
    installScanID = @"";
    installVesselName = @"";
    installRegi = @"";

    
    [APP_DELEGATE endHudProcess];
    
    URBAlertView *alertView = [[URBAlertView alloc] initWithTitle:ALERT_TITLE message:@"Something went wrong. Please try again." cancelButtonTitle:OK_BTN otherButtonTitles: nil, nil];
    
    [alertView setMessageFont:[UIFont fontWithName:CGRegular size:14]];
    [alertView setHandlerBlock:^(NSInteger buttonIndex, URBAlertView *alertView) {
        [alertView hideWithCompletionBlock:^{
            [self.navigationController popViewControllerAnimated:YES];
        }];
    }];
    [alertView showWithAnimation:URBAlertAnimationTopToBottom];
    if (IS_IPHONE_X){[alertView showWithAnimation:URBAlertAnimationDefault];}
}
-(void)CheckValidationforUinstallAndInspection:(NSMutableDictionary *)dictID
{
    strSuccorfishDeviceID = [self checkforValidString:[dictID valueForKey:@"id"]];
    strAccountID = [self checkforValidString:[dictID valueForKey:@"accountId"]];

    NSString * strStatus = [self checkforValidString:[dictID valueForKey:@"status"]];
    if ([strStatus isEqualToString:@"UNINSTALLED"])
    {
        NSString * strMessage = [NSString stringWithFormat:@"This device %@ can't be uninstalled as its not installed anywhere.",installScanID];
        if ([isFromInstall isEqualToString:@"Inspection"])
        {
            strMessage = [NSString stringWithFormat:@"This device %@ can't be inspected as its not installed anywhere.",installScanID];
        }
        URBAlertView *alertView = [[URBAlertView alloc] initWithTitle:ALERT_TITLE message:strMessage cancelButtonTitle:OK_BTN otherButtonTitles:@"View last Installation", nil];
        [alertView setMessageFont:[UIFont fontWithName:CGRegular size:12]];
        [alertView setHandlerBlock:^(NSInteger buttonIndex, URBAlertView *alertView) {
            [alertView hideWithCompletionBlock:^{
                if (buttonIndex==0)
                {
                    installScanID = @"";
                    
                    [self.navigationController popViewControllerAnimated:YES];
                }
                else
                {
                    globalDeviceType = @"";
                    globalWarrantyStatus =@"";
                    installScanID = @"";
                    installVesselName = @"";
                    installRegi = @"";
                    [self TestDeviceRomanAPI];
                }
            }];
        }];
          [alertView showWithAnimation:Alert_Animation_Type];
        if (IS_IPHONE_X) {[alertView showWithAnimation:URBAlertAnimationDefault];}
    }
    else if ([strStatus isEqualToString:@"INSTALLED"])
    {
        /*globalDeviceType =@"SC2";
        globalWarrantyStatus =@"";
        globalDeviceType =[dictID valueForKey:@"type"];
        
        NSString * strTimeStampWarranty = [NSString stringWithFormat:@"%@",[dictID valueForKey:@"warrantyExpires"]];
        globalWarrantyStatus =[APP_DELEGATE GetRealDatefromTimeStamp:strTimeStampWarranty];
        if ([installScanID  isEqualToString:@"357152070984180"])
        {
            globalDeviceType =@"SC3";
        }*/
        [self fetchInstalledInformationfromServer];
//        [self.navigationController popViewControllerAnimated:YES];

    }
    else if ([strStatus isEqualToString:@"IN_STOCK"])
    {
        NSString * strMessage = [NSString stringWithFormat:@"This device %@ can't be uninstalled as its not installed anywhere.",installScanID];
        if ([isFromInstall isEqualToString:@"Inspection"])
        {
            strMessage = [NSString stringWithFormat:@"This device %@ can't be inspected as its not installed anywhere.",installScanID];
        }
        URBAlertView *alertView = [[URBAlertView alloc] initWithTitle:ALERT_TITLE message:strMessage cancelButtonTitle:OK_BTN otherButtonTitles: nil, nil];
        [alertView setMessageFont:[UIFont fontWithName:CGRegular size:12]];
        [alertView setHandlerBlock:^(NSInteger buttonIndex, URBAlertView *alertView) {
            [alertView hideWithCompletionBlock:^{
                installScanID = @"";
                globalDeviceType = @"";
                globalWarrantyStatus =@"";
                installScanID = @"";
                installVesselName = @"";
                installRegi = @"";
                [self.navigationController popViewControllerAnimated:YES];
            }];
        }];
          [alertView showWithAnimation:Alert_Animation_Type];
        if (IS_IPHONE_X) {[alertView showWithAnimation:URBAlertAnimationDefault];}
    }
    else if ([strStatus isEqualToString:@"DELIVERED"])
    {
        NSString * strMessage = [NSString stringWithFormat:@"This device %@ can't be uninstalled as its not installed anywhere.",installScanID];
        if ([isFromInstall isEqualToString:@"Inspection"])
        {
            strMessage = [NSString stringWithFormat:@"This device %@ can't be inspected as its not installed anywhere.",installScanID];
        }
        URBAlertView *alertView = [[URBAlertView alloc] initWithTitle:ALERT_TITLE message:strMessage cancelButtonTitle:OK_BTN otherButtonTitles: nil, nil];
        [alertView setMessageFont:[UIFont fontWithName:CGRegular size:12]];
        [alertView setHandlerBlock:^(NSInteger buttonIndex, URBAlertView *alertView) {
            [alertView hideWithCompletionBlock:^{
                installScanID = @"";
                globalDeviceType = @"";
                globalWarrantyStatus =@"";
                installScanID = @"";
                installVesselName = @"";
                installRegi = @"";
                [self.navigationController popViewControllerAnimated:YES];
            }];
        }];
          [alertView showWithAnimation:Alert_Animation_Type];
        if (IS_IPHONE_X) {[alertView showWithAnimation:URBAlertAnimationDefault];}
    }
    else
    {
        NSString * strMessage = [NSString stringWithFormat:@"This device %@ can't be uninstalled as its not installed anywhere.",installScanID];
        if ([isFromInstall isEqualToString:@"Inspection"])
        {
            strMessage = [NSString stringWithFormat:@"This device %@ can't be inspected as its not installed anywhere.",installScanID];
        }
        URBAlertView *alertView = [[URBAlertView alloc] initWithTitle:ALERT_TITLE message:strMessage cancelButtonTitle:OK_BTN otherButtonTitles: nil, nil];
        [alertView setMessageFont:[UIFont fontWithName:CGRegular size:12]];
        [alertView setHandlerBlock:^(NSInteger buttonIndex, URBAlertView *alertView) {
            [alertView hideWithCompletionBlock:^{
                installScanID = @"";
                globalDeviceType = @"";
                globalWarrantyStatus =@"";
                installScanID = @"";
                installVesselName = @"";
                installRegi = @"";
                [self.navigationController popViewControllerAnimated:YES];
            }];
        }];
          [alertView showWithAnimation:Alert_Animation_Type];
        if (IS_IPHONE_X) {[alertView showWithAnimation:URBAlertAnimationDefault];}
    }
}
-(void)CheckValidationforInstallation:(NSMutableDictionary *)dictID
{
    strSuccorfishDeviceID = [self checkforValidString:[dictID valueForKey:@"id"]];
    strAccountID = [self checkforValidString:[dictID valueForKey:@"accountId"]];

    NSString * strStatus = [self checkforValidString:[dictID valueForKey:@"status"]];
    if ([strStatus isEqualToString:@"UNINSTALLED"])
    {
        /*globalDeviceType =@"SC2";
        globalWarrantyStatus =@"";
        globalDeviceType =[dictID valueForKey:@"type"];
        NSString * strTimeStampWarranty = [NSString stringWithFormat:@"%@",[dictID valueForKey:@"warrantyExpires"]];
        globalWarrantyStatus =[APP_DELEGATE GetRealDatefromTimeStamp:strTimeStampWarranty];

        if ([installScanID  isEqualToString:@"357152070984180"])
        {
            globalDeviceType =@"SC3";
        }*/
        [self.navigationController popViewControllerAnimated:YES];
    }
    else if ([strStatus isEqualToString:@"INSTALLED"])
    {
        NSString * strMessage = [NSString stringWithFormat:@"This device %@ is already installed somewhere. Please uninstall first and then try again to Install it.",installScanID];
        URBAlertView *alertView = [[URBAlertView alloc] initWithTitle:ALERT_TITLE message:strMessage cancelButtonTitle:@"OK" otherButtonTitles: @"View last Installation", nil];
        [alertView setMessageFont:[UIFont fontWithName:CGRegular size:12]];
        [alertView setHandlerBlock:^(NSInteger buttonIndex, URBAlertView *alertView) {
            [alertView hideWithCompletionBlock:^{
                
                if (buttonIndex==0)
                {
                    globalDeviceType = @"";
                    globalWarrantyStatus =@"";
                    installScanID = @"";
                    installVesselName = @"";
                    installRegi = @"";
                    [self.navigationController popViewControllerAnimated:YES];
                }
                else
                {
                    globalDeviceType = @"";
                    globalWarrantyStatus =@"";
                    installScanID = @"";
                    installVesselName = @"";
                    installRegi = @"";
                    [self TestDeviceRomanAPI];
                }
            }];
        }];
          [alertView showWithAnimation:Alert_Animation_Type];
        if (IS_IPHONE_X) {[alertView showWithAnimation:URBAlertAnimationDefault];}
    }
    else if ([strStatus isEqualToString:@"IN_STOCK"])
    {
        NSString * strMessage = @"This device is not ready to install now. Its in \"IN STOCK\" status.";
        URBAlertView *alertView = [[URBAlertView alloc] initWithTitle:ALERT_TITLE message:strMessage cancelButtonTitle:OK_BTN otherButtonTitles: nil, nil];
        [alertView setMessageFont:[UIFont fontWithName:CGRegular size:12]];
        [alertView setHandlerBlock:^(NSInteger buttonIndex, URBAlertView *alertView) {
            [alertView hideWithCompletionBlock:^{
                installScanID = @"";
                [self.navigationController popViewControllerAnimated:YES];
            }];
        }];
          [alertView showWithAnimation:Alert_Animation_Type];
        if (IS_IPHONE_X) {[alertView showWithAnimation:URBAlertAnimationDefault];}
    }
    else if ([strStatus isEqualToString:@"RETURNED"])
    {
        NSString * strMessage = @"This device is not ready to install now.";
        URBAlertView *alertView = [[URBAlertView alloc] initWithTitle:ALERT_TITLE message:strMessage cancelButtonTitle:OK_BTN otherButtonTitles: nil, nil];
        [alertView setMessageFont:[UIFont fontWithName:CGRegular size:12]];
        [alertView setHandlerBlock:^(NSInteger buttonIndex, URBAlertView *alertView) {
            [alertView hideWithCompletionBlock:^{
                installScanID = @"";
                [self.navigationController popViewControllerAnimated:YES];
            }];
        }];
          [alertView showWithAnimation:Alert_Animation_Type];
        if (IS_IPHONE_X) {[alertView showWithAnimation:URBAlertAnimationDefault];}
    }
    else if ([strStatus isEqualToString:@"DELIVERED"])
    {
        globalDeviceType =@"SC2";
        globalWarrantyStatus =@"";
        globalDeviceType =[dictID valueForKey:@"type"];
//        NSString * strTimeStampWarranty = [NSString stringWithFormat:@"%@",[dictID valueForKey:@"warrantyExpires"]];
//        globalWarrantyStatus =[APP_DELEGATE GetRealDatefromTimeStamp:strTimeStampWarranty];
//
        if ([installScanID  isEqualToString:@"357152070984180"])
        {
            globalDeviceType =@"SC3";
        }
        [self.navigationController popViewControllerAnimated:YES];
    }
    else
    {
        NSString * strMessage = @"This device is not ready to install now.";
        URBAlertView *alertView = [[URBAlertView alloc] initWithTitle:ALERT_TITLE message:strMessage cancelButtonTitle:OK_BTN otherButtonTitles: nil, nil];
        [alertView setMessageFont:[UIFont fontWithName:CGRegular size:12]];
        [alertView setHandlerBlock:^(NSInteger buttonIndex, URBAlertView *alertView) {
            [alertView hideWithCompletionBlock:^{
                installScanID = @"";
                [self.navigationController popViewControllerAnimated:YES];
            }];
        }];
          [alertView showWithAnimation:Alert_Animation_Type];
        if (IS_IPHONE_X) {[alertView showWithAnimation:URBAlertAnimationDefault];}
        /*globalDeviceType =@"SC2";
        globalWarrantyStatus =@"";
        globalDeviceType =[dictID valueForKey:@"type"];
        NSString * strTimeStampWarranty = [NSString stringWithFormat:@"%@",[dictID valueForKey:@"warrantyExpires"]];
        globalWarrantyStatus =[APP_DELEGATE GetRealDatefromTimeStamp:strTimeStampWarranty];

        if ([installScanID  isEqualToString:@"357152070984180"])
        {
            globalDeviceType =@"SC3";
        }
        [self.navigationController popViewControllerAnimated:YES];*/
    }
}
-(void)fillDictionaryforDeviceDetails:(NSMutableDictionary *)tmpDicts
{
    gotDeviceDetailDict = [[NSMutableDictionary alloc] init];
    [gotDeviceDetailDict setValue:@"Yes" forKey:@"DataAvail"];
    [gotDeviceDetailDict setObject:[tmpDicts valueForKey:@"realAssetName"] forKey:@"vesselname"];
    [gotDeviceDetailDict setObject:[tmpDicts valueForKey:@"realAssetRegNo"] forKey:@"portno"];
    [gotDeviceDetailDict setObject:[tmpDicts valueForKey:@"realAssetId"] forKey:@"vessel_id"];
    [gotDeviceDetailDict setObject:[tmpDicts valueForKey:@"deviceImei"] forKey:@"imei"];
    [gotDeviceDetailDict setObject:[tmpDicts valueForKey:@"deviceType"] forKey:@"device_type"];
    [gotDeviceDetailDict setObject:[NSString stringWithFormat:@"%@",globalWarrantyStatus] forKey:@"warranty"];

    NSMutableDictionary * dictContact = [[NSMutableDictionary alloc] init];
    dictContact = [tmpDicts valueForKey:@"contactInfo"];
    if (dictContact == [NSNull null] || dictContact == nil)
    {
    }
    else
    {
        [gotDeviceDetailDict setObject:[dictContact valueForKey:@"name"] forKey:@"owner_name"];
        [gotDeviceDetailDict setObject:[dictContact valueForKey:@"email"] forKey:@"owner_email"];
        [gotDeviceDetailDict setObject:[dictContact valueForKey:@"address"] forKey:@"owner_address"];
        [gotDeviceDetailDict setObject:[dictContact valueForKey:@"city"] forKey:@"owner_city"];
        [gotDeviceDetailDict setObject:[dictContact valueForKey:@"state"] forKey:@"owner_state"];
        [gotDeviceDetailDict setObject:[dictContact valueForKey:@"zipCode"] forKey:@"owner_zipcode"];
        [gotDeviceDetailDict setObject:[dictContact valueForKey:@"telephone"] forKey:@"owner_phone_no"];
    }
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
