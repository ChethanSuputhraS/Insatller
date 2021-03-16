//
//  InstallGuidePDF.m
//  Succorfish Installer App
//
//  Created by stuart watts on 10/04/2018.
//  Copyright © 2018 Kalpesh Panchasara. All rights reserved.
//

#import "InstallGuidePDF.h"

@interface InstallGuidePDF ()
{
    UIWebView * webView;
    UIDeviceOrientation  orinetationCount;
    UIInterfaceOrientation lastOrients;

}
@end

@implementation InstallGuidePDF
@synthesize strFrom,isfromInstallGuide,strTitle;

- (void)viewDidLoad
{
    UIImageView * imgBack = [[UIImageView alloc] init];
    imgBack.frame = CGRectMake(0, 0, DEVICE_WIDTH, DEVICE_HEIGHT);
    imgBack.image = [UIImage imageNamed:@"Splash_bg.png"];
    imgBack.userInteractionEnabled = YES;
    [self.view addSubview:imgBack];
    
    [self setNavigationViewFrames];
    
    if([[UIApplication sharedApplication] statusBarOrientation]==UIDeviceOrientationLandscapeLeft || [[UIApplication sharedApplication] statusBarOrientation]==UIDeviceOrientationLandscapeRight  )
    {
        NSLog(@"Landscape");
        orinetationCount = [[UIDevice currentDevice]orientation];
//        [self setLandscapeFrames];
    }
    NSLog(@"%ld",(long)[[UIDevice currentDevice]orientation]);
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIDeviceOrientationDidChangeNotification object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(OrientationDidChange:) name:UIDeviceOrientationDidChangeNotification object:nil];
    
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}
-(void)viewWillAppear:(BOOL)animated
{
    [APP_DELEGATE hideTabBar:self.tabBarController];
}
-(void)viewWillDisappear:(BOOL)animated {
    NSNumber *value = [NSNumber numberWithInt:UIInterfaceOrientationPortrait];
    [[UIDevice currentDevice] setValue:value forKey:@"orientation"];
    [super viewWillDisappear:animated];
}
#pragma mark - Set Frames
-(void)setNavigationViewFrames
{
    viewHeader = [[UIView alloc] initWithFrame:CGRectMake(0, 0, DEVICE_WIDTH, 64)];
    [viewHeader setBackgroundColor:[UIColor blackColor]];
    [self.view addSubview:viewHeader];
    
    NSString * strtitle = [NSString stringWithFormat:@"%@",strTitle];
    lblTitle = [[UILabel alloc] initWithFrame:CGRectMake(50, 20, DEVICE_WIDTH-100, 44)];
    [lblTitle setBackgroundColor:[UIColor clearColor]];
    [lblTitle setText:strtitle];
    [lblTitle setTextAlignment:NSTextAlignmentCenter];
    [lblTitle setFont:[UIFont fontWithName:CGRegular size:13]];
    [lblTitle setTextColor:[UIColor whiteColor]];
    [viewHeader addSubview:lblTitle];
    
    backImg = [[UIImageView alloc] initWithFrame:CGRectMake(10, 12+20, 12, 20)];
    [backImg setImage:[UIImage imageNamed:@"back_icon.png"]];
    [backImg setContentMode:UIViewContentModeScaleAspectFit];
    backImg.backgroundColor = [UIColor clearColor];
    [viewHeader addSubview:backImg];
    
    btnBack = [UIButton buttonWithType:UIButtonTypeCustom];
    [btnBack addTarget:self action:@selector(btnBackClick) forControlEvents:UIControlEventTouchUpInside];
    btnBack.frame = CGRectMake(0, 0, 70, 64);
    btnBack.backgroundColor = [UIColor clearColor];
    [viewHeader addSubview:btnBack];

    if (IS_IPHONE_X)
    {
        viewHeader.frame = CGRectMake(0, 0, DEVICE_WIDTH, 88);
        lblTitle.frame = CGRectMake(50, 40, DEVICE_WIDTH-100, 44);
        backImg.frame = CGRectMake(10, 8+44, 12, 20);
        btnBack.frame = CGRectMake(0, 0, 70, 88);
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
    
    
    NSString *path = [[NSBundle mainBundle] pathForResource:strFrom ofType:@"pdf"];
    NSURL *targetURL = [NSURL fileURLWithPath:path];
    NSURLRequest *request = [NSURLRequest requestWithURL:targetURL];
    [webView loadRequest:request];
   
    if (IS_IPHONE_X)
    {
        webView.frame = CGRectMake(0, yAxis, DEVICE_WIDTH, DEVICE_HEIGHT-44);
    }
}
-(void)setLandscapeFrames
{
    int yAxis = 64;
    if (isLandscapeRequired == true)
    {
        if (isInLandscapeMode == true)
        {
            viewHeader.frame = CGRectMake(0, 0, DEVICE_WIDTH, 64);
            lblTitle.frame = CGRectMake(50, 20, DEVICE_WIDTH-100, 44);
            webView.frame = CGRectMake(0, yAxis, DEVICE_WIDTH, DEVICE_HEIGHT-yAxis);

            
            if (DEVICE_HEIGHT == 375 || DEVICE_WIDTH == 812)
            {
                yAxis = 88;
                viewHeader.frame = CGRectMake(0, 0, DEVICE_WIDTH-40, 88);
                lblTitle.frame = CGRectMake(50, 40, DEVICE_WIDTH-100, 44);
                backImg.frame = CGRectMake(45, 8+44, 12, 20);
                btnBack.frame = CGRectMake(40, 0, 70, 88);
                webView.frame = CGRectMake(40, yAxis, DEVICE_WIDTH-80, DEVICE_HEIGHT-44);
            }
            
        }
    }
}
-(void)setUpPortraintFrames
{
    int yAxis = 64;
    if (isLandscapeRequired == true)
    {
        if (isInLandscapeMode == false)
        {
            viewHeader.frame = CGRectMake(0, 0, DEVICE_WIDTH, 64);
            lblTitle.frame = CGRectMake(50, 20, DEVICE_WIDTH-100, 44);
            webView.frame = CGRectMake(0, yAxis, DEVICE_WIDTH, DEVICE_HEIGHT-yAxis);
    
            if (DEVICE_HEIGHT == 812 || DEVICE_WIDTH == 375)
            {
                yAxis = 88;
                viewHeader.frame = CGRectMake(0, 0, DEVICE_WIDTH, 88);
                lblTitle.frame = CGRectMake(50, 40, DEVICE_WIDTH-100, 44);
                backImg.frame = CGRectMake(10, 8+44, 12, 20);
                btnBack.frame = CGRectMake(0, 0, 70, 88);
                webView.frame = CGRectMake(0, yAxis, DEVICE_WIDTH, DEVICE_HEIGHT-44);
            }
            
        }
    }
}
-(void)OrientationDidChange:(NSNotification*)notification
{
    lastOrients = [[UIApplication sharedApplication] statusBarOrientation];
    
    if([[UIApplication sharedApplication] statusBarOrientation]==UIDeviceOrientationLandscapeLeft || [[UIApplication sharedApplication] statusBarOrientation]==UIDeviceOrientationLandscapeRight)
    {
//        NSLog(@"Landscape");
//        [self setLandscapeFrames];
        isInLandscapeMode = true;
        [self setLandscapeFrames];
    }
    else if([[UIApplication sharedApplication] statusBarOrientation]==UIDeviceOrientationPortrait)
    {
//        NSLog(@"Potrait Mode");
//        [self setUpPortraintFrames];
        isInLandscapeMode = false;
        [self setUpPortraintFrames];
    }
}
#pragma mark - Button Click events
-(void)btnBackClick
{
    isLandscapeRequired = false;
    [self.navigationController popViewControllerAnimated:YES];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
