//
//  SNHVC.m
//  Succorfish Installer App
//
//  Created by srivatsa s pobbathi on 29/03/19.
//  Copyright © 2019 Kalpesh Panchasara. All rights reserved.
//

#import "SNHVC.h"
#import "InstallGuidePDF.h"
#import "NewInstallVC.h"
#import "UnInstalledVC.h"
#import "InspectionVC.h"
@interface SNHVC ()

@end

@implementation SNHVC
@synthesize strType,detailDict,isFromeEdit;
- (void)viewDidLoad
{
    textSize = 16;
    if (IS_IPHONE_4 || IS_IPHONE_5)
    {
        textSize = 14;
    }
    if (isFromeEdit == true)
    {
        strInstallID = [detailDict valueForKey:@"id"];
    }
    UIImageView * imgBack = [[UIImageView alloc] init];
    imgBack.frame = CGRectMake(0, 0, DEVICE_WIDTH, DEVICE_HEIGHT);
    imgBack.image = [UIImage imageNamed:@"Splash_bg.png"];
    imgBack.userInteractionEnabled = YES;
    [self.view addSubview:imgBack];
    
    arrayHandS = [[NSMutableArray alloc]init];
    for (int i =0; i<=5; i++)
    {
        NSMutableDictionary *tmpDict = [[NSMutableDictionary alloc]initWithObjectsAndKeys:@"NO",@"answer",@"NA",@"reason", nil];
        [arrayHandS addObject:tmpDict];
    }
    [[arrayHandS objectAtIndex:5]setValue:@"NA" forKey:@"answer"];
    
    hazardArray = [[NSArray alloc]initWithObjects:@"None",@"Working at height",@"Poor Lighting",@"Chemicals/Harmful substances(Asbestos)",@"Risk to you from others near",@"Risk to others from you working near",@"Hot work",@"Cold Work",@"Workplace temperature -high/low",@" Housekeeping",@"Secure load",@"Poor access/egress",@"Excessive Vibration form equipment",@" Falling objects",@"Noise",@"Electricity",@"Tripping hazards",@"Contact with stationary objects",@"Moving loads",@"Hand-tools-check",@"Manula handling",@"Machinery in motion",@"Welding in close proximity to task",@"Dangerous liquid,solid or sludge",@"Lifting",@"Entry into confined /restricted spaces",@"Dust",@"Work on or Near Water",@"Expansion /Contraction",@"Fumes",@"Other", nil];
    [self setNavigationViewFrames];
    [self setContentViews];
    
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}
-(void)viewWillAppear:(BOOL)animated
{
    [APP_DELEGATE hideTabBar:self.tabBarController];
    NSNumber *value = [NSNumber numberWithInt:UIInterfaceOrientationPortrait];
    [[UIDevice currentDevice] setValue:value forKey:@"orientation"];

}
#pragma mark - Set Frames
-(void)setNavigationViewFrames
{
    scrllView = [[UIScrollView alloc]initWithFrame:CGRectMake(0, 0, DEVICE_WIDTH, DEVICE_HEIGHT)];
    scrllView.contentSize = CGSizeMake(DEVICE_WIDTH*3, DEVICE_HEIGHT);
    scrllView.backgroundColor = UIColor.clearColor;
    [scrllView setScrollEnabled:false];
    [self.view addSubview:scrllView];
    
    UIView * viewHeader = [[UIView alloc] initWithFrame:CGRectMake(0, 0, DEVICE_WIDTH, 64)];
    [viewHeader setBackgroundColor:[UIColor blackColor]];
    [self.view addSubview:viewHeader];
    
    UILabel * lblTitle = [[UILabel alloc] initWithFrame:CGRectMake(50, 20, DEVICE_WIDTH-100, 44)];
    [lblTitle setBackgroundColor:[UIColor clearColor]];
    [lblTitle setText:@"Health and Safety"];
    [lblTitle setTextAlignment:NSTextAlignmentCenter];
    [lblTitle setFont:[UIFont fontWithName:CGRegular size:textSize+1]];
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
    
    UIImageView * imgBack = [[UIImageView alloc] init];
    imgBack.frame = CGRectMake(0, viewHeader.frame.origin.y+viewHeader.frame.size.height+20, DEVICE_WIDTH, 150);
    imgBack.image = [UIImage imageNamed:@"HNS.png"];
    imgBack.contentMode = UIViewContentModeScaleAspectFit;
    imgBack.userInteractionEnabled = YES;
    [scrllView addSubview:imgBack];
    
    if (IS_IPHONE_4 || IS_IPHONE_5)
    {
        viewHeader.frame = CGRectMake(0, 0, DEVICE_WIDTH, 64);
    }
    else if (IS_IPHONE_X)
    {
        viewHeader.frame = CGRectMake(0, 0, DEVICE_WIDTH, 88);
        lblTitle.frame = CGRectMake(50, 40, DEVICE_WIDTH-100, 44);
        backImg.frame = CGRectMake(10, 12+44, 12, 20);
        btnBack.frame = CGRectMake(0, 0, 70, 88);
    }
}
-(void)setContentViews
{
    intscreen = 0;
    int fontSize = 17;
    int xx = 64;
    if (IS_IPHONE_5 || IS_IPHONE_4)
    {
        xx = 64;
        fontSize = 15;
    }
    if (IS_IPHONE_X)
    {
        xx = 88;
    }
    int yy = xx+170+50;
    if (IS_IPHONE_4)
    {
        yy = xx+170+10;
    }
    btnGo = [UIButton buttonWithType:UIButtonTypeCustom];
    [btnGo setTitle:@"GO" forState:UIControlStateNormal];
    [btnGo setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [btnGo addTarget:self action:@selector(btnGoClick) forControlEvents:UIControlEventTouchUpInside];
    btnGo.frame = CGRectMake((DEVICE_WIDTH/2)-40,yy,80,80);
    btnGo.titleLabel.font =[UIFont fontWithName:CGRegular size:fontSize];
    btnGo.backgroundColor  = [UIColor colorWithRed:48.0/255.0 green:48.0/255.0 blue:48.0/255.0 alpha:1];
    btnGo.layer.masksToBounds = true;
    btnGo.layer.cornerRadius = 40;
    [scrllView addSubview:btnGo];
    
    if (IS_IPHONE_4)
    {
        btnGo.frame = CGRectMake((DEVICE_WIDTH/2)-30,yy,60,60);
        btnGo.layer.cornerRadius = 30;
        yy = yy+60+20;
    }
    else
    {
        yy = yy+80+20;
    }
    
    UILabel * lblOr = [[UILabel alloc] initWithFrame:CGRectMake(0, yy, DEVICE_WIDTH, 30)];
    [lblOr setBackgroundColor:[UIColor clearColor]];
    [lblOr setText:@"OR"];
    [lblOr setTextAlignment:NSTextAlignmentCenter];
    [lblOr setFont:[UIFont fontWithName:CGRegular size:textSize]];
    [lblOr setTextColor:[UIColor whiteColor]];
    [scrllView addSubview:lblOr];
    
    yy = yy+30+20;
    
    UIButton *btnReview = [UIButton buttonWithType:UIButtonTypeCustom];
    [btnReview setTitle:@"REVIEW" forState:UIControlStateNormal];
    [btnReview setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [btnReview addTarget:self action:@selector(btnReviewClick) forControlEvents:UIControlEventTouchUpInside];
    btnReview.frame = CGRectMake((DEVICE_WIDTH/2)-40,yy,80,80);
    btnReview.titleLabel.font =[UIFont fontWithName:CGRegular size:fontSize];
    btnReview.backgroundColor  = [UIColor colorWithRed:48.0/255.0 green:48.0/255.0 blue:48.0/255.0 alpha:1];
    btnReview.layer.masksToBounds = true;
    btnReview.layer.cornerRadius = 40;
    [scrllView addSubview:btnReview];
    
    UILabel * lblRisk = [[UILabel alloc] initWithFrame:CGRectMake(20,yy+80+10,DEVICE_WIDTH-40,25)];
    [lblRisk setBackgroundColor:UIColor.clearColor];
    [lblRisk setText:@"Standard Risk Assessment"];
    [lblRisk setTextAlignment:NSTextAlignmentCenter];
    [lblRisk setFont:[UIFont fontWithName:CGRegular size:textSize]];
    [lblRisk setTextColor:[UIColor whiteColor]];
    lblRisk.userInteractionEnabled = true;
    [scrllView addSubview:lblRisk];
    
    if (IS_IPHONE_4)
    {
        btnReview.frame = CGRectMake((DEVICE_WIDTH/2)-30,yy,60,60);
        btnReview.layer.cornerRadius = 30;
        lblRisk.frame = CGRectMake(20,yy+60+10,DEVICE_WIDTH-40,25);
    }
}
-(void)setUpQuestionView
{
    zz = 64;
    if (IS_IPHONE_X)
    {
        zz = 88;
    }
    
    scrllView1 = [[UIScrollView alloc]initWithFrame:CGRectMake(DEVICE_WIDTH, zz, DEVICE_WIDTH, DEVICE_HEIGHT-zz-(45*approaxSize))];
    scrllView1.contentSize = CGSizeMake(DEVICE_WIDTH, DEVICE_HEIGHT);
    scrllView1.backgroundColor = UIColor.clearColor;
    [scrllView1 setScrollEnabled:true];
    [scrllView addSubview:scrllView1];
    
    if (IS_IPHONE_5)
    {
        scrllView1.contentSize = CGSizeMake(DEVICE_WIDTH, DEVICE_HEIGHT);
    }
    else if (IS_IPHONE_4)
    {
        scrllView1.contentSize = CGSizeMake(DEVICE_WIDTH, DEVICE_HEIGHT+80);
    }
    intscreen = 1;
    int yy = 0;
    int txtFieldHeight = 100*approaxSize;
    
     //q1
    [viewq1 removeFromSuperview];
    viewq1 = [[UIView alloc]initWithFrame:CGRectMake(0, yy, DEVICE_WIDTH, 185*approaxSize)];
    viewq1.backgroundColor = UIColor.clearColor;
    viewq1.userInteractionEnabled = true;
    [scrllView1 addSubview:viewq1];
    
    UILabel *lblNo1 = [[UILabel alloc]init];
    lblNo1.frame =  CGRectMake(10,0, 35*approaxSize, 35*approaxSize);
    [lblNo1 setBackgroundColor:UIColor.clearColor];
    lblNo1.numberOfLines = 0;
    [lblNo1 setText:@"Q1."];
    [lblNo1 setTextAlignment:NSTextAlignmentLeft];
    [lblNo1 setFont:[UIFont fontWithName:CGBold size:textSize+2]];
    [lblNo1 setTextColor:[UIColor whiteColor]];
    [viewq1 addSubview:lblNo1];
   
    UILabel*lblQ1 = [[UILabel alloc]init];
    lblQ1.frame = CGRectMake(45*approaxSize, 6.7*approaxSize, DEVICE_WIDTH-45*approaxSize, 55*approaxSize);
    [lblQ1 setBackgroundColor:UIColor.clearColor];
    lblQ1.numberOfLines = 0;
    [lblQ1 setText:@"Are you wearing the prescirbed PPE (including lifejacket if working near water)?"];
    [lblQ1 setTextAlignment:NSTextAlignmentLeft];
    [lblQ1 setFont:[UIFont fontWithName:CGRegular size:textSize]];
    [lblQ1 setTextColor:[UIColor whiteColor]];
    [viewq1 addSubview:lblQ1];
    
   
    btnRadioView1 = [[customRadioButtonVC alloc]init];
    btnRadioView1.frame = CGRectMake(0, 45*approaxSize, DEVICE_WIDTH, 35*approaxSize);
    btnRadioView1.btnNA.hidden = true;
    btnRadioView1.imgRadioNA.hidden = true;
    [btnRadioView1.btnYes addTarget:self action:@selector(btnYesClick:) forControlEvents:UIControlEventTouchUpInside];
    [btnRadioView1.btnNo addTarget:self action:@selector(btnNoClick:) forControlEvents:UIControlEventTouchUpInside];
    btnRadioView1.btnNo.backgroundColor = UIColor.clearColor;
    btnRadioView1.btnYes.tag = 1;
    btnRadioView1.btnNo.tag = 1;
    [viewq1 addSubview:btnRadioView1];
   
    txtQ1 = [[UITextView alloc]initWithFrame:CGRectMake(10, 85*approaxSize, DEVICE_WIDTH-20, txtFieldHeight)];
    txtQ1.backgroundColor = UIColor.clearColor;
    txtQ1.delegate = self;
    txtQ1.layer.masksToBounds = true;
    txtQ1.layer.borderColor = UIColor.grayColor.CGColor;
    txtQ1.layer.borderWidth = 1;
    txtQ1.layer.cornerRadius = 10;
    txtQ1.autocapitalizationType = UITextAutocapitalizationTypeNone;
    txtQ1.textColor = [UIColor whiteColor];
    txtQ1.hidden = false;
    [txtQ1 setFont:[UIFont fontWithName:CGRegular size:textSize]];
    txtQ1.autocorrectionType = UITextAutocorrectionTypeNo;
    txtQ1.returnKeyType = UIReturnKeyNext;
    [viewq1 addSubview:txtQ1];
    
    UIToolbar* numberToolbar = [[UIToolbar alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 50)];
    numberToolbar.barStyle =  UIBarStyleDefault;
    UIBarButtonItem *space =[[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    UIBarButtonItem *Done = [[UIBarButtonItem alloc]initWithTitle:@"Done" style:UIBarButtonItemStyleDone target:self action:@selector(doneKeyBoarde)];
    Done.tintColor=[APP_DELEGATE colorWithHexString:App_Header_Color];
    
    numberToolbar.items = [NSArray arrayWithObjects:space,Done,
                           nil];
    [numberToolbar sizeToFit];
    txtQ1.inputAccessoryView = numberToolbar;
    
    
    lblQ1PlaceHolder = [[UILabel alloc]init];
    lblQ1PlaceHolder.frame = CGRectMake(10, 85*approaxSize, DEVICE_WIDTH-100, 30*approaxSize);
    [lblQ1PlaceHolder setBackgroundColor:UIColor.clearColor];
    [lblQ1PlaceHolder setText:@"  If no,please explain why."];
    [lblQ1PlaceHolder setTextAlignment:NSTextAlignmentLeft];
    lblQ1PlaceHolder.hidden = false;
    [lblQ1PlaceHolder setFont:[UIFont fontWithName:CGRegular size:textSize]];
    [lblQ1PlaceHolder setTextColor:[UIColor whiteColor]];
    [viewq1 addSubview:lblQ1PlaceHolder];
    
    
    //q2
    yy = yy+(200*approaxSize);
    [viewq2 removeFromSuperview];
    viewq2 = [[UIView alloc]initWithFrame:CGRectMake(0, yy, DEVICE_WIDTH, 170*approaxSize)];
    viewq2.backgroundColor = UIColor.clearColor;
    [scrllView1 addSubview:viewq2];
    
    UILabel *lblNo2 = [[UILabel alloc]init];
    lblNo2.frame =  CGRectMake(10,0, 35*approaxSize, 35*approaxSize);
    [lblNo2 setBackgroundColor:UIColor.clearColor];
    lblNo2.numberOfLines = 0;
    [lblNo2 setText:@"Q2."];
    [lblNo2 setTextAlignment:NSTextAlignmentLeft];
    [lblNo2 setFont:[UIFont fontWithName:CGBold size:textSize+2]];
    [lblNo2 setTextColor:[UIColor whiteColor]];
    [viewq2 addSubview:lblNo2];

    UILabel*lblQ2 = [[UILabel alloc]init];
    lblQ2.frame = CGRectMake(45*approaxSize, 8*approaxSize, DEVICE_WIDTH-45*approaxSize, 35*approaxSize);
    [lblQ2 setBackgroundColor:UIColor.clearColor];
    lblQ2.numberOfLines = 0;
    [lblQ2 setText:@"Have you completed your equipment pre-inspection?"];
    [lblQ2 setTextAlignment:NSTextAlignmentLeft];
    [lblQ2 setFont:[UIFont fontWithName:CGRegular size:textSize]];
    [lblQ2 setTextColor:[UIColor whiteColor]];
    [viewq2 addSubview:lblQ2];
    
    btnRadioView2 = [[customRadioButtonVC alloc]init];
    btnRadioView2.frame = CGRectMake(0, 30*approaxSize, DEVICE_WIDTH, 35*approaxSize);
    btnRadioView2.btnNA.hidden = true;
    btnRadioView2.imgRadioNA.hidden = true;
    [btnRadioView2.btnYes addTarget:self action:@selector(btnYesClick:) forControlEvents:UIControlEventTouchUpInside];
    [btnRadioView2.btnNo addTarget:self action:@selector(btnNoClick:) forControlEvents:UIControlEventTouchUpInside];
    btnRadioView2.btnNo.backgroundColor = UIColor.clearColor;
    btnRadioView2.btnYes.tag = 2;
    btnRadioView2.btnNo.tag = 2;
    [viewq2 addSubview:btnRadioView2];

    txtQ2 = [[UITextView alloc]initWithFrame:CGRectMake(10, 70*approaxSize, DEVICE_WIDTH-20, txtFieldHeight)];
    txtQ2.backgroundColor = UIColor.clearColor;
    txtQ2.delegate = self;
    txtQ2.layer.masksToBounds = true;
    txtQ2.layer.borderColor = UIColor.grayColor.CGColor;
    txtQ2.layer.borderWidth = 1;
    txtQ2.layer.cornerRadius = 10;
    txtQ2.autocapitalizationType = UITextAutocapitalizationTypeNone;
    txtQ2.textColor = [UIColor whiteColor];
    txtQ2.hidden = false;
    [txtQ2 setFont:[UIFont fontWithName:CGRegular size:textSize]];
    txtQ2.autocorrectionType = UITextAutocorrectionTypeNo;
    txtQ2.returnKeyType = UIReturnKeyNext;
    [viewq2 addSubview:txtQ2];
    
    UIToolbar* numberToolbar2 = [[UIToolbar alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 50)];
    numberToolbar2.barStyle =  UIBarStyleDefault;
    UIBarButtonItem *space2 =[[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    UIBarButtonItem *Done2 = [[UIBarButtonItem alloc]initWithTitle:@"Done" style:UIBarButtonItemStyleDone target:self action:@selector(doneKeyBoarde)];
    Done2.tintColor=[APP_DELEGATE colorWithHexString:App_Header_Color];

    numberToolbar2.items = [NSArray arrayWithObjects:space2,Done2,
                           nil];
    [numberToolbar2 sizeToFit];
    txtQ2.inputAccessoryView = numberToolbar2;


    lblQ2PlaceHolder = [[UILabel alloc]init];
    lblQ2PlaceHolder.frame = CGRectMake(10, 70*approaxSize, DEVICE_WIDTH-100, 30);
    [lblQ2PlaceHolder setBackgroundColor:UIColor.clearColor];
    [lblQ2PlaceHolder setText:@"  If no,please explain why."];
    [lblQ2PlaceHolder setTextAlignment:NSTextAlignmentLeft];
    lblQ2PlaceHolder.hidden = false;
    [lblQ2PlaceHolder setFont:[UIFont fontWithName:CGRegular size:textSize]];
    [lblQ2PlaceHolder setTextColor:[UIColor whiteColor]];
    [viewq2 addSubview:lblQ2PlaceHolder];

    
    //q3
    yy = yy+(185*approaxSize);
    [viewq3 removeFromSuperview];
    viewq3 = [[UIView alloc]initWithFrame:CGRectMake(0, yy, DEVICE_WIDTH, 170*approaxSize)];
    viewq3.backgroundColor = UIColor.clearColor;
    [scrllView1 addSubview:viewq3];
    
    
    UILabel *lblNo3 = [[UILabel alloc]init];
    lblNo3.frame =  CGRectMake(10,0, 35*approaxSize, 35*approaxSize);
    [lblNo3 setBackgroundColor:UIColor.clearColor];
    lblNo3.numberOfLines = 0;
    [lblNo3 setText:@"Q3."];
    [lblNo3 setTextAlignment:NSTextAlignmentLeft];
    [lblNo3 setFont:[UIFont fontWithName:CGBold size:textSize+2]];
    [lblNo3 setTextColor:[UIColor whiteColor]];
    [viewq3 addSubview:lblNo3];
    
    UILabel*lblQ3 = [[UILabel alloc]init];
    lblQ3.frame = CGRectMake(45*approaxSize, 8*approaxSize, DEVICE_WIDTH-45*approaxSize, 35*approaxSize);
    [lblQ3 setBackgroundColor:UIColor.clearColor];
    lblQ3.numberOfLines = 0;
    [lblQ3 setText:@"Have you completed your pre-inspection for working at height?"];
    [lblQ3 setTextAlignment:NSTextAlignmentLeft];
    [lblQ3 setFont:[UIFont fontWithName:CGRegular size:textSize]];
    [lblQ3 setTextColor:[UIColor whiteColor]];
    [viewq3 addSubview:lblQ3];
    
    btnRadioView3 = [[customRadioButtonVC alloc]init];
    btnRadioView3.frame = CGRectMake(0, 30*approaxSize, DEVICE_WIDTH, 35*approaxSize);
    [btnRadioView3.btnYes addTarget:self action:@selector(btnYesClick:) forControlEvents:UIControlEventTouchUpInside];
    [btnRadioView3.btnNo addTarget:self action:@selector(btnNoClick:) forControlEvents:UIControlEventTouchUpInside];
    [btnRadioView3.btnNA addTarget:self action:@selector(btnNAClick:) forControlEvents:UIControlEventTouchUpInside];

    btnRadioView3.btnNo.backgroundColor = UIColor.clearColor;
    btnRadioView3.btnYes.tag = 3;
    btnRadioView3.btnNo.tag = 3;
    btnRadioView3.btnNA.tag = 3;
    [viewq3 addSubview:btnRadioView3];
    
    txtQ3 = [[UITextView alloc]initWithFrame:CGRectMake(10, 70*approaxSize, DEVICE_WIDTH-20, txtFieldHeight)];
    txtQ3.backgroundColor = UIColor.clearColor;
    txtQ3.delegate = self;
    txtQ3.layer.masksToBounds = true;
    txtQ3.layer.borderColor = UIColor.grayColor.CGColor;
    txtQ3.layer.borderWidth = 1;
    txtQ3.layer.cornerRadius = 10;
    txtQ3.autocapitalizationType = UITextAutocapitalizationTypeNone;
    txtQ3.textColor = [UIColor whiteColor];
    txtQ3.hidden = false;
    [txtQ3 setFont:[UIFont fontWithName:CGRegular size:textSize]];
    txtQ3.autocorrectionType = UITextAutocorrectionTypeNo;
    txtQ3.returnKeyType = UIReturnKeyNext;
    [viewq3 addSubview:txtQ3];

    UIToolbar* numberToolbar3 = [[UIToolbar alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 50)];
    numberToolbar3.barStyle =  UIBarStyleDefault;
    UIBarButtonItem *space3 =[[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    UIBarButtonItem *Done3 = [[UIBarButtonItem alloc]initWithTitle:@"Done" style:UIBarButtonItemStyleDone target:self action:@selector(doneKeyBoarde)];
    Done3.tintColor=[APP_DELEGATE colorWithHexString:App_Header_Color];

    numberToolbar3.items = [NSArray arrayWithObjects:space3,Done3,
                            nil];
    [numberToolbar3 sizeToFit];
    txtQ3.inputAccessoryView = numberToolbar3;


    lblQ3PlaceHolder = [[UILabel alloc]init];
    lblQ3PlaceHolder.frame = CGRectMake(10, 70*approaxSize, DEVICE_WIDTH-100, 30);
    [lblQ3PlaceHolder setBackgroundColor:UIColor.clearColor];
    [lblQ3PlaceHolder setText:@"  If no,please explain why."];
    [lblQ3PlaceHolder setTextAlignment:NSTextAlignmentLeft];
    lblQ3PlaceHolder.hidden = false;
    [lblQ3PlaceHolder setFont:[UIFont fontWithName:CGRegular size:textSize]];
    [lblQ3PlaceHolder setTextColor:[UIColor whiteColor]];
    [viewq3 addSubview:lblQ3PlaceHolder];

    if (IS_IPHONE_6plus)
    {
        lblNo1.frame =  CGRectMake(10,3, 35*approaxSize, 35*approaxSize);
        lblQ1.frame = CGRectMake(45*approaxSize, 0, DEVICE_WIDTH-45*approaxSize, 55*approaxSize);
        lblNo2.frame =  CGRectMake(10,1, 35*approaxSize, 35*approaxSize);
        lblNo3.frame =  CGRectMake(10,1, 35*approaxSize, 35*approaxSize);
    }
    
    int fontSize = 17;
    if (IS_IPHONE_5 || IS_IPHONE_4)
    {
        fontSize = 15;
    }
    btmView = [[UIImageView alloc] init];
    btmView.frame= CGRectMake(0, DEVICE_HEIGHT-45*approaxSize, DEVICE_WIDTH, 45*approaxSize);
    btmView.userInteractionEnabled = YES;
    btmView.backgroundColor = [UIColor blackColor];
    [self.view addSubview:btmView];
    
    moveFrwdBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [moveFrwdBtn setTitle:@"NEXT   " forState:UIControlStateNormal];
    [moveFrwdBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [moveFrwdBtn addTarget:self action:@selector(moveNextClick) forControlEvents:UIControlEventTouchUpInside];
    moveFrwdBtn.frame = CGRectMake(DEVICE_WIDTH/2-10, DEVICE_HEIGHT-45*approaxSize, DEVICE_WIDTH/2, 45*approaxSize);
    moveFrwdBtn.titleLabel.font =[UIFont fontWithName:CGRegular size:fontSize];
    moveFrwdBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
    [self.view addSubview:moveFrwdBtn];
    
    moveBackBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [moveBackBtn setTitle:@"   BACK" forState:UIControlStateNormal];
    [moveBackBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [moveBackBtn addTarget:self action:@selector(btnBackClick) forControlEvents:UIControlEventTouchUpInside];
    moveBackBtn.frame = CGRectMake(0, DEVICE_HEIGHT-45*approaxSize, DEVICE_WIDTH/2, 45*approaxSize);
    moveBackBtn.titleLabel.font =[UIFont fontWithName:CGRegular size:fontSize];
    moveBackBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    [self.view addSubview:moveBackBtn];
    
    if (IS_IPHONE_4)
    {
        btmView.frame= CGRectMake(0, DEVICE_HEIGHT-45, DEVICE_WIDTH, 45);
        moveBackBtn.frame = CGRectMake(0, DEVICE_HEIGHT-45, DEVICE_WIDTH/2, 45);
        moveFrwdBtn.frame = CGRectMake(DEVICE_WIDTH/2-10, DEVICE_HEIGHT-45, DEVICE_WIDTH/2, 45);
    }
    else if (IS_IPHONE_X)
    {
        btmView.frame= CGRectMake(0, DEVICE_HEIGHT-40-45*approaxSize, DEVICE_WIDTH, 45*approaxSize);
        moveBackBtn.frame = CGRectMake(0, DEVICE_HEIGHT-40-45*approaxSize , DEVICE_WIDTH/2, btmView.frame.size.height);
        moveFrwdBtn.frame = CGRectMake(DEVICE_WIDTH/2-10, DEVICE_HEIGHT-40-45*approaxSize , DEVICE_WIDTH/2, btmView.frame.size.height);
    }
    

    if (isFromeEdit == true)
    {
        NSMutableArray * tmpArr = [[NSMutableArray alloc]init];
        NSString * strCheck1 = [NSString stringWithFormat:@"select * from tbl_question where install_id = '%@' and type = '%@'",[detailDict valueForKey:@"id"],strType];
        [[DataBaseManager dataBaseManager] execute:strCheck1 resultsArray:tmpArr];
        
        arrayHandS = [[NSMutableArray alloc]init];
        for (int i =0; i<6; i++)
        {
            NSMutableDictionary *tmpDict = [[NSMutableDictionary alloc]initWithObjectsAndKeys:@"NO",@"answer",@"NA",@"reason", nil];
            [arrayHandS addObject:tmpDict];
        }
        [[arrayHandS objectAtIndex:5]setValue:@"NA" forKey:@"answer"];
        if (tmpArr.count>0)
        {
            for (int i = 0; i<6; i++)
            {
                NSMutableDictionary * tmpDict = [[NSMutableDictionary alloc]init];
                tmpDict = [tmpArr objectAtIndex:0];
                NSString*strQ = [tmpDict valueForKey:[NSString stringWithFormat:@"q%d",i+1]];
                NSString*strReson = [tmpDict valueForKey:[NSString stringWithFormat:@"q%dans",i+1]];
                [[arrayHandS objectAtIndex:i] setObject:strQ forKey:@"answer"];
                [[arrayHandS objectAtIndex:i] setObject:strReson forKey:@"reason"];
                
            }
        }
       
        [self preFillFirstView];

    }
    else
    {
        if (isNextClikced == true)
        {
            [self preFillFirstView];
        }
//        else
//        {
//            [self btnNoClick:btnRadioView1.btnNo];
//            [self btnNoClick:btnRadioView2.btnNo];
//            [self btnNoClick:btnRadioView3.btnNo];
//        }
    }
    
}
-(void)preFillFirstView
{
    if ([[[arrayHandS objectAtIndex:0] valueForKey:@"answer"]isEqualToString:@"NO"])
    {
        [self btnNoClick:btnRadioView1.btnNo];
        btnRadioView1.imgRadioYes.image = [UIImage imageNamed:@"radiobuttonUnselected.png"];
        btnRadioView1.imgRadioNo.image = [UIImage imageNamed:@"radiobuttonSelected.png"];
        if (![[APP_DELEGATE checkforValidString:[[arrayHandS objectAtIndex:0] valueForKey:@"reason"]] isEqualToString:@"NA"])
        {
            lblQ1PlaceHolder.hidden = true;
            txtQ1.text = [[arrayHandS objectAtIndex:0] valueForKey:@"reason"];
        }
        else
        {
            lblQ1PlaceHolder.hidden = false;
        }
    }
    else if([[[arrayHandS objectAtIndex:0] valueForKey:@"answer"]isEqualToString:@"YES"])
    {
        [self btnYesClick:btnRadioView1.btnYes];
        btnRadioView1.imgRadioYes.image = [UIImage imageNamed:@"radiobuttonSelected.png"];
        btnRadioView1.imgRadioNo.image = [UIImage imageNamed:@"radiobuttonUnselected.png"];
    }
    if ([[[arrayHandS objectAtIndex:1] valueForKey:@"answer"]isEqualToString:@"NO"])
    {
        [self btnNoClick:btnRadioView2.btnNo];
        btnRadioView2.imgRadioYes.image = [UIImage imageNamed:@"radiobuttonUnselected.png"];
        btnRadioView2.imgRadioNo.image = [UIImage imageNamed:@"radiobuttonSelected.png"];
        if (![[APP_DELEGATE checkforValidString:[[arrayHandS objectAtIndex:1] valueForKey:@"reason"]] isEqualToString:@"NA"])
        {
            lblQ2PlaceHolder.hidden = true;
            txtQ2.text = [[arrayHandS objectAtIndex:1] valueForKey:@"reason"];
        }
        else
        {
            lblQ2PlaceHolder.hidden = false;
        }
    }
    else if([[[arrayHandS objectAtIndex:1] valueForKey:@"answer"]isEqualToString:@"YES"])
    {
        [self btnYesClick:btnRadioView2.btnYes];
        btnRadioView2.imgRadioYes.image = [UIImage imageNamed:@"radiobuttonSelected.png"];
        btnRadioView2.imgRadioNo.image = [UIImage imageNamed:@"radiobuttonUnselected.png"];
    }
    if ([[[arrayHandS objectAtIndex:2] valueForKey:@"answer"]isEqualToString:@"NO"])
    {
        [self btnNoClick:btnRadioView3.btnNo];
        btnRadioView3.imgRadioYes.image = [UIImage imageNamed:@"radiobuttonUnselected.png"];
        btnRadioView3.imgRadioNo.image = [UIImage imageNamed:@"radiobuttonSelected.png"];
        btnRadioView3.imgRadioNA.image = [UIImage imageNamed:@"radiobuttonUnselected.png"];
        if (![[APP_DELEGATE checkforValidString:[[arrayHandS objectAtIndex:2] valueForKey:@"reason"]] isEqualToString:@"NA"])
        {
            lblQ3PlaceHolder.hidden = true;
            txtQ3.text = [[arrayHandS objectAtIndex:2] valueForKey:@"reason"];
        }
        else
        {
            lblQ3PlaceHolder.hidden = false;
        }
    }
    else if ([[[arrayHandS objectAtIndex:2] valueForKey:@"answer"]isEqualToString:@"NA"])
    {
        [self btnNAClick:btnRadioView3.btnNA];
        btnRadioView3.imgRadioYes.image = [UIImage imageNamed:@"radiobuttonUnselected.png"];
        btnRadioView3.imgRadioNo.image = [UIImage imageNamed:@"radiobuttonUnselected.png"];
        btnRadioView3.imgRadioNA.image = [UIImage imageNamed:@"radiobuttonSelected.png"];
    }
    else if([[[arrayHandS objectAtIndex:2] valueForKey:@"answer"]isEqualToString:@"YES"])
    {
        [self btnYesClick:btnRadioView3.btnYes];
        btnRadioView3.imgRadioYes.image = [UIImage imageNamed:@"radiobuttonSelected.png"];
        btnRadioView3.imgRadioNo.image = [UIImage imageNamed:@"radiobuttonUnselected.png"];
        btnRadioView3.imgRadioNA.image = [UIImage imageNamed:@"radiobuttonUnselected.png"];
    }
}
-(void)setUpQuestionPart2View
{
    if (isFromeEdit == false)
    {
        if ([[APP_DELEGATE checkforValidString:strInstallID]isEqualToString:@"NA"])
        {
            [[arrayHandS objectAtIndex:3]setValue:@"NO" forKey:@"answer"];
            [[arrayHandS objectAtIndex:4]setValue:@"NO" forKey:@"answer"];
            [[arrayHandS objectAtIndex:5]setValue:@"NO" forKey:@"answer"];
            [[arrayHandS objectAtIndex:5]setValue:@"NA" forKey:@"reason"];
            intSelectedHazrd = 0;
            indexHazard = 0;
        }
        
    }

    scrllView2 = [[UIScrollView alloc]initWithFrame:CGRectMake(DEVICE_WIDTH*2, zz, DEVICE_WIDTH, DEVICE_HEIGHT-zz-(45*approaxSize))];
    scrllView2.contentSize = CGSizeMake(DEVICE_WIDTH, DEVICE_HEIGHT);
    scrllView2.backgroundColor = UIColor.clearColor;
    [scrllView2 setScrollEnabled:true];
    [scrllView addSubview:scrllView2];
    
    if (IS_IPHONE_5)
    {
        scrllView2.contentSize = CGSizeMake(DEVICE_WIDTH, DEVICE_HEIGHT+20);
    }
    else if (IS_IPHONE_4)
    {
        scrllView2.contentSize = CGSizeMake(DEVICE_WIDTH, DEVICE_HEIGHT+100);
    }
    else if (IS_IPHONE_X)
    {
        scrllView2.frame = CGRectMake(DEVICE_WIDTH*2, zz, DEVICE_WIDTH, DEVICE_HEIGHT-zz-(45*approaxSize)-40);
        
    }
    intscreen = 2;
    int yy = 0;
    int txtFieldHeight = 100*approaxSize;

    
    //q4
    [viewq4 removeFromSuperview];
    viewq4 = [[UIView alloc]initWithFrame:CGRectMake(0, yy, DEVICE_WIDTH, 170*approaxSize)];
    viewq4.backgroundColor = UIColor.clearColor;
    [scrllView2 addSubview:viewq4];
    
    UILabel *lblNo4 = [[UILabel alloc]init];
    lblNo4.frame =  CGRectMake(10,0, 35*approaxSize, 35*approaxSize);
    [lblNo4 setBackgroundColor:UIColor.clearColor];
    lblNo4.numberOfLines = 0;
    [lblNo4 setText:@"Q4."];
    [lblNo4 setTextAlignment:NSTextAlignmentLeft];
    [lblNo4 setFont:[UIFont fontWithName:CGBold size:textSize+2]];
    [lblNo4 setTextColor:[UIColor whiteColor]];
    [viewq4 addSubview:lblNo4];
    
    UILabel*lblQ4 = [[UILabel alloc]init];
    lblQ4.frame = CGRectMake(45*approaxSize, 8*approaxSize, DEVICE_WIDTH-45*approaxSize, 35*approaxSize);
    [lblQ4 setBackgroundColor:UIColor.clearColor];
    lblQ4.numberOfLines = 0;
    [lblQ4 setText:@"Have you reviewed the installation for Asbestos risk?"];
    [lblQ4 setTextAlignment:NSTextAlignmentLeft];
    [lblQ4 setFont:[UIFont fontWithName:CGRegular size:textSize]];
    [lblQ4 setTextColor:[UIColor whiteColor]];
    [viewq4 addSubview:lblQ4];
    
    btnRadioView4 = [[customRadioButtonVC alloc]init];
    btnRadioView4.frame = CGRectMake(0, 30*approaxSize, DEVICE_WIDTH, 35*approaxSize);
    [btnRadioView4.btnYes addTarget:self action:@selector(btnYesClick:) forControlEvents:UIControlEventTouchUpInside];
    [btnRadioView4.btnNo addTarget:self action:@selector(btnNoClick:) forControlEvents:UIControlEventTouchUpInside];
    [btnRadioView4.btnNA addTarget:self action:@selector(btnNAClick:) forControlEvents:UIControlEventTouchUpInside];
    btnRadioView4.btnNo.backgroundColor = UIColor.clearColor;
    btnRadioView4.btnYes.tag = 4;
    btnRadioView4.btnNo.tag = 4;
    btnRadioView4.btnNA.tag = 4;
    [viewq4 addSubview:btnRadioView4];
    
    txtQ4 = [[UITextView alloc]initWithFrame:CGRectMake(10, 70*approaxSize, DEVICE_WIDTH-20, txtFieldHeight)];
    txtQ4.backgroundColor = UIColor.clearColor;
    txtQ4.delegate = self;
    txtQ4.layer.masksToBounds = true;
    txtQ4.layer.borderColor = UIColor.grayColor.CGColor;
    txtQ4.layer.borderWidth = 1;
    txtQ4.layer.cornerRadius = 10;
    txtQ4.autocapitalizationType = UITextAutocapitalizationTypeNone;
    txtQ4.textColor = [UIColor whiteColor];
    txtQ4.hidden = false;
    [txtQ4 setFont:[UIFont fontWithName:CGRegular size:textSize]];
    txtQ4.autocorrectionType = UITextAutocorrectionTypeNo;
    txtQ4.returnKeyType = UIReturnKeyNext;
    [viewq4 addSubview:txtQ4];
    
    UIToolbar* numberToolbar = [[UIToolbar alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 50)];
    numberToolbar.barStyle =  UIBarStyleDefault;
    UIBarButtonItem *space =[[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    UIBarButtonItem *Done = [[UIBarButtonItem alloc]initWithTitle:@"Done" style:UIBarButtonItemStyleDone target:self action:@selector(doneKeyBoarde)];
    Done.tintColor=[APP_DELEGATE colorWithHexString:App_Header_Color];
    
    numberToolbar.items = [NSArray arrayWithObjects:space,Done,
                           nil];
    [numberToolbar sizeToFit];
    txtQ4.inputAccessoryView = numberToolbar;
    
    
    lblQ4PlaceHolder = [[UILabel alloc]init];
    lblQ4PlaceHolder.frame = CGRectMake(10, 70*approaxSize, DEVICE_WIDTH-100, 30*approaxSize);
    [lblQ4PlaceHolder setBackgroundColor:UIColor.clearColor];
    [lblQ4PlaceHolder setText:@"  If no,please explain why."];
    [lblQ4PlaceHolder setTextAlignment:NSTextAlignmentLeft];
    lblQ4PlaceHolder.hidden = false;
    [lblQ4PlaceHolder setFont:[UIFont fontWithName:CGRegular size:textSize]];
    [lblQ4PlaceHolder setTextColor:[UIColor whiteColor]];
    [viewq4 addSubview:lblQ4PlaceHolder];
    
    yy = yy+(185*approaxSize);
    //q5
    [viewq5 removeFromSuperview];
    viewq5 = [[UIView alloc]initWithFrame:CGRectMake(0, yy, DEVICE_WIDTH, 155*approaxSize)];
    viewq5.backgroundColor = UIColor.clearColor;
    [scrllView2 addSubview:viewq5];
    
    UILabel *lblNo5 = [[UILabel alloc]init];
    lblNo5.frame =  CGRectMake(10,0, 35*approaxSize, 35*approaxSize);
    [lblNo5 setBackgroundColor:UIColor.clearColor];
    lblNo5.numberOfLines = 0;
    [lblNo5 setText:@"Q5."];
    [lblNo5 setTextAlignment:NSTextAlignmentLeft];
    [lblNo5 setFont:[UIFont fontWithName:CGBold size:textSize+2]];
    [lblNo5 setTextColor:[UIColor whiteColor]];
    [viewq5 addSubview:lblNo5];
    
    UILabel*lblQ5 = [[UILabel alloc]init];
    lblQ5.frame = CGRectMake(44*approaxSize,7*approaxSize, DEVICE_WIDTH-45*approaxSize, 20*approaxSize);
    [lblQ5 setBackgroundColor:UIColor.clearColor];
    lblQ5.numberOfLines = 0;
    [lblQ5 setText:@"Do you require service isolation"];
    [lblQ5 setTextAlignment:NSTextAlignmentLeft];
    [lblQ5 setFont:[UIFont fontWithName:CGRegular size:textSize]];
    [lblQ5 setTextColor:[UIColor whiteColor]];
    [viewq5 addSubview:lblQ5];
    
    btnRadioView5 = [[customRadioButtonVC alloc]init];
    btnRadioView5.frame = CGRectMake(0, 15*approaxSize, DEVICE_WIDTH, 35*approaxSize);
    [btnRadioView5.btnYes addTarget:self action:@selector(btnYesClick:) forControlEvents:UIControlEventTouchUpInside];
    [btnRadioView5.btnNo addTarget:self action:@selector(btnNoClick:) forControlEvents:UIControlEventTouchUpInside];
    [btnRadioView5.btnNA addTarget:self action:@selector(btnNAClick:) forControlEvents:UIControlEventTouchUpInside];
    btnRadioView5.btnNo.backgroundColor = UIColor.clearColor;
    btnRadioView5.btnYes.tag = 5;
    btnRadioView5.btnNo.tag = 5;
    btnRadioView5.btnNA.tag = 5;
    [viewq5 addSubview:btnRadioView5];
    
    txtQ5 = [[UITextView alloc]initWithFrame:CGRectMake(10, 55*approaxSize, DEVICE_WIDTH-20, txtFieldHeight)];
    txtQ5.backgroundColor = UIColor.clearColor;
    txtQ5.delegate = self;
    txtQ5.layer.masksToBounds = true;
    txtQ5.layer.borderColor = UIColor.grayColor.CGColor;
    txtQ5.layer.borderWidth = 1;
    txtQ5.layer.cornerRadius = 10;
    txtQ5.autocapitalizationType = UITextAutocapitalizationTypeNone;
    txtQ5.textColor = [UIColor whiteColor];
    txtQ5.hidden = false;
    [txtQ5 setFont:[UIFont fontWithName:CGRegular size:textSize]];
    txtQ5.autocorrectionType = UITextAutocorrectionTypeNo;
    txtQ5.returnKeyType = UIReturnKeyNext;
    [viewq5 addSubview:txtQ5];
    
    UIToolbar* numberToolbar5 = [[UIToolbar alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 50)];
    numberToolbar5.barStyle =  UIBarStyleDefault;
    UIBarButtonItem *space5 =[[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    UIBarButtonItem *Done5 = [[UIBarButtonItem alloc]initWithTitle:@"Done" style:UIBarButtonItemStyleDone target:self action:@selector(doneKeyBoarde)];
    Done5.tintColor=[APP_DELEGATE colorWithHexString:App_Header_Color];
    
    numberToolbar5.items = [NSArray arrayWithObjects:space5,Done5,
                           nil];
    [numberToolbar5 sizeToFit];
    txtQ5.inputAccessoryView = numberToolbar5;
    
    
    lblQ5PlaceHolder = [[UILabel alloc]init];
    lblQ5PlaceHolder.frame = CGRectMake(10, 55*approaxSize, DEVICE_WIDTH-100, 30);
    [lblQ5PlaceHolder setBackgroundColor:UIColor.clearColor];
    [lblQ5PlaceHolder setText:@"  If no,please explain why."];
    [lblQ5PlaceHolder setTextAlignment:NSTextAlignmentLeft];
    lblQ5PlaceHolder.hidden = false;
    [lblQ5PlaceHolder setFont:[UIFont fontWithName:CGRegular size:textSize]];
    [lblQ5PlaceHolder setTextColor:[UIColor whiteColor]];
    [viewq5 addSubview:lblQ5PlaceHolder];
    
    yy = yy+(170*approaxSize);
    //q6
    [viewq6 removeFromSuperview];
    viewq6 = [[UIView alloc]initWithFrame:CGRectMake(0, yy, DEVICE_WIDTH, 215*approaxSize)];
    viewq6.backgroundColor = UIColor.clearColor;
    [scrllView2 addSubview:viewq6];
    
    UILabel *lblNo6 = [[UILabel alloc]init];
    lblNo6.frame =  CGRectMake(10,0, 35*approaxSize, 35*approaxSize);
    [lblNo6 setBackgroundColor:UIColor.clearColor];
    lblNo6.numberOfLines = 0;
    [lblNo6 setText:@"Q6."];
    [lblNo6 setTextAlignment:NSTextAlignmentLeft];
    [lblNo6 setFont:[UIFont fontWithName:CGBold size:textSize+2]];
    [lblNo6 setTextColor:[UIColor whiteColor]];
    [viewq6 addSubview:lblNo6];
    
    UILabel*lblQ6 = [[UILabel alloc]init];
    lblQ6.frame = CGRectMake(40*approaxSize,8*approaxSize, DEVICE_WIDTH-40*approaxSize, 50*approaxSize);
    [lblQ6 setBackgroundColor:UIColor.clearColor];
    lblQ6.numberOfLines = 0;
    [lblQ6 setText:@"Please select hazard from the list below and describe additional precaution taken not listed in the Succorfish Risk Assessment."];
    [lblQ6 setTextAlignment:NSTextAlignmentLeft];
    [lblQ6 setFont:[UIFont fontWithName:CGRegular size:textSize-0.5]];
    [lblQ6 setTextColor:[UIColor whiteColor]];
    [viewq6 addSubview:lblQ6];
    
    lblHazard = [[UILabel alloc]init];
    lblHazard.frame = CGRectMake(10,65*approaxSize,DEVICE_WIDTH-20,40);
    [lblHazard setBackgroundColor:UIColor.clearColor];
    lblHazard.numberOfLines = 0;
    [lblHazard setText:@"Click to choose hazard"];
    [lblHazard setTextAlignment:NSTextAlignmentCenter];
    [lblHazard setFont:[UIFont fontWithName:CGRegular size:textSize-1]];
    [lblHazard setTextColor:[UIColor whiteColor]];
    lblHazard.userInteractionEnabled = true;
    lblHazard.backgroundColor = [UIColor colorWithRed:48.0/255.0 green:48.0/255.0 blue:48.0/255.0 alpha:1];
    [viewq6 addSubview:lblHazard];
    
    UIImageView * downImg = [[UIImageView alloc] initWithFrame:CGRectMake((DEVICE_WIDTH-26), 82.5*approaxSize, 12, 7)];
    [downImg setImage:[UIImage imageNamed:@"whiteArrow"]];
    [downImg setContentMode:UIViewContentModeScaleAspectFit];
    downImg.userInteractionEnabled = true;
    downImg.backgroundColor = [UIColor colorWithRed:48.0/255.0 green:48.0/255.0 blue:48.0/255.0 alpha:1];
    [viewq6 addSubview:downImg];
    
    UIButton * btnPickerView = [UIButton buttonWithType:UIButtonTypeCustom];
    [btnPickerView addTarget:self action:@selector(btnPickerViewClicked) forControlEvents:UIControlEventTouchUpInside];
    btnPickerView.frame = CGRectMake(10,65*approaxSize,DEVICE_WIDTH-20,40);
    btnPickerView.titleLabel.frame = CGRectMake(10,65,DEVICE_WIDTH-40,50);
    btnPickerView.titleLabel.font =[UIFont fontWithName:CGRegular size:textSize];
    btnPickerView.backgroundColor  = UIColor.clearColor;
    [viewq6 addSubview:btnPickerView];

    txtQ6 = [[UITextView alloc]initWithFrame:CGRectMake(10, 115*approaxSize, DEVICE_WIDTH-20, txtFieldHeight)];
    txtQ6.backgroundColor = UIColor.clearColor;
    txtQ6.delegate = self;
    txtQ6.layer.masksToBounds = true;
    txtQ6.layer.borderColor = UIColor.grayColor.CGColor;
    txtQ6.layer.borderWidth = 1;
    txtQ6.layer.cornerRadius = 10;
    txtQ6.autocapitalizationType = UITextAutocapitalizationTypeNone;
    txtQ6.textColor = [UIColor whiteColor];
    txtQ6.hidden = false;
    [txtQ6 setFont:[UIFont fontWithName:CGRegular size:textSize]];
    txtQ6.autocorrectionType = UITextAutocorrectionTypeNo;
    txtQ6.returnKeyType = UIReturnKeyNext;
    [viewq6 addSubview:txtQ6];
    
    UIToolbar* numberToolbar6 = [[UIToolbar alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 50)];
    numberToolbar6.barStyle =  UIBarStyleDefault;
    UIBarButtonItem *space6 =[[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    UIBarButtonItem *Done6 = [[UIBarButtonItem alloc]initWithTitle:@"Done" style:UIBarButtonItemStyleDone target:self action:@selector(doneKeyBoarde)];
    Done6.tintColor=[APP_DELEGATE colorWithHexString:App_Header_Color];
    
    numberToolbar6.items = [NSArray arrayWithObjects:space6,Done6,
                           nil];
    [numberToolbar6 sizeToFit];
    txtQ6.inputAccessoryView = numberToolbar6;
    
    lblQ6PlaceHolder = [[UILabel alloc]init];
    lblQ6PlaceHolder.frame = CGRectMake(10, 115*approaxSize, DEVICE_WIDTH-40, 30);
    [lblQ6PlaceHolder setBackgroundColor:UIColor.clearColor];
    [lblQ6PlaceHolder setText:@"  Describe additional precautions."];
    [lblQ6PlaceHolder setTextAlignment:NSTextAlignmentLeft];
    lblQ6PlaceHolder.hidden = false;
    [lblQ6PlaceHolder setFont:[UIFont fontWithName:CGRegular size:textSize]];
    [lblQ6PlaceHolder setTextColor:[UIColor whiteColor]];
    [viewq6 addSubview:lblQ6PlaceHolder];
    
    if (IS_IPHONE_6plus)
    {
        lblNo4.frame =  CGRectMake(10,1, 35*approaxSize, 35*approaxSize);
       
    }
    
    if (isFromeEdit == true || ![[APP_DELEGATE checkforValidString:strInstallID] isEqualToString:@"NA"])
    {
        if ([[[arrayHandS objectAtIndex:3] valueForKey:@"answer"]isEqualToString:@"NO"])
        {
            [self btnNoClick:btnRadioView4.btnNo];
            btnRadioView4.imgRadioYes.image = [UIImage imageNamed:@"radiobuttonUnselected.png"];
            btnRadioView4.imgRadioNo.image = [UIImage imageNamed:@"radiobuttonSelected.png"];
            btnRadioView4.imgRadioNA.image = [UIImage imageNamed:@"radiobuttonUnselected.png"];
            txtQ4.text = [[arrayHandS objectAtIndex:3] valueForKey:@"reason"];
            if ([[APP_DELEGATE checkforValidString:[[arrayHandS objectAtIndex:3] valueForKey:@"reason"]]isEqualToString:@"NA"])
            {
                lblQ4PlaceHolder.hidden = false;
            }
            else
            {
                lblQ4PlaceHolder.hidden = true;
            }
        }
        else if ([[[arrayHandS objectAtIndex:3] valueForKey:@"answer"]isEqualToString:@"NA"])
        {
            [self btnNAClick:btnRadioView4.btnNA];
            btnRadioView4.imgRadioYes.image = [UIImage imageNamed:@"radiobuttonUnselected.png"];
            btnRadioView4.imgRadioNo.image = [UIImage imageNamed:@"radiobuttonUnselected.png"];
            btnRadioView4.imgRadioNA.image = [UIImage imageNamed:@"radiobuttonSelected.png"];
        }
        else if([[[arrayHandS objectAtIndex:3] valueForKey:@"answer"]isEqualToString:@"YES"])
        {
            [self btnYesClick:btnRadioView4.btnYes];
            btnRadioView4.imgRadioYes.image = [UIImage imageNamed:@"radiobuttonSelected.png"];
            btnRadioView4.imgRadioNo.image = [UIImage imageNamed:@"radiobuttonUnselected.png"];
            btnRadioView4.imgRadioNA.image = [UIImage imageNamed:@"radiobuttonUnselected.png"];
        }
        if ([[[arrayHandS objectAtIndex:4] valueForKey:@"answer"]isEqualToString:@"NO"])
        {
            [self btnNoClick:btnRadioView5.btnNo];
            btnRadioView5.imgRadioYes.image = [UIImage imageNamed:@"radiobuttonUnselected.png"];
            btnRadioView5.imgRadioNo.image = [UIImage imageNamed:@"radiobuttonSelected.png"];
            btnRadioView5.imgRadioNA.image = [UIImage imageNamed:@"radiobuttonUnselected.png"];
            txtQ5.text = [[arrayHandS objectAtIndex:4] valueForKey:@"reason"];
            if ([[APP_DELEGATE checkforValidString:[[arrayHandS objectAtIndex:4] valueForKey:@"reason"]]isEqualToString:@"NA"])
            {
                lblQ5PlaceHolder.hidden = false;
            }
            else
            {
                lblQ5PlaceHolder.hidden = true;
            }
        }
        else if ([[APP_DELEGATE checkforValidString:[[arrayHandS objectAtIndex:4] valueForKey:@"answer"]]isEqualToString:@"NA"])
        {
            [self btnNAClick:btnRadioView5.btnNA];
            btnRadioView5.imgRadioYes.image = [UIImage imageNamed:@"radiobuttonUnselected.png"];
            btnRadioView5.imgRadioNo.image = [UIImage imageNamed:@"radiobuttonUnselected.png"];
            btnRadioView5.imgRadioNA.image = [UIImage imageNamed:@"radiobuttonSelected.png"];
        }
        else if([[[arrayHandS objectAtIndex:4] valueForKey:@"answer"]isEqualToString:@"YES"])
        {
            [self btnYesClick:btnRadioView5.btnYes];
            btnRadioView5.imgRadioYes.image = [UIImage imageNamed:@"radiobuttonSelected.png"];
            btnRadioView5.imgRadioNo.image = [UIImage imageNamed:@"radiobuttonUnselected.png"];
            btnRadioView5.imgRadioNA.image = [UIImage imageNamed:@"radiobuttonUnselected.png"];
        }

        if (![[APP_DELEGATE checkforValidString:[[arrayHandS objectAtIndex:5]valueForKey:@"reason"]]isEqualToString:@"NA"])
        {
            txtQ6.text = [[arrayHandS objectAtIndex:5]valueForKey:@"reason"];
            lblQ6PlaceHolder.hidden = true;
        }
        else
        {
            lblQ6PlaceHolder.hidden = false;
        }
        lblHazard.text =[[arrayHandS objectAtIndex:5] valueForKey:@"answer"];
        indexHazard = [hazardArray indexOfObject:[[arrayHandS objectAtIndex:5] valueForKey:@"answer"]];
        intSelectedHazrd = indexHazard;
    }
}
-(void)setIphone4FramesForView1
{
    if ([[[arrayHandS objectAtIndex:0]valueForKey:@"answer"]isEqualToString:@"YES"] && [[[arrayHandS objectAtIndex:1]valueForKey:@"answer"]isEqualToString:@"YES"])
    {

        scrllView1.contentSize = CGSizeMake(DEVICE_WIDTH, DEVICE_HEIGHT-zz-(45*approaxSize));
    }
    else if ([[[arrayHandS objectAtIndex:0]valueForKey:@"answer"]isEqualToString:@"YES"] && [[[arrayHandS objectAtIndex:2]valueForKey:@"answer"]isEqualToString:@"YES"])
    {
        scrllView1.contentSize = CGSizeMake(DEVICE_WIDTH, DEVICE_HEIGHT-zz-(45*approaxSize));
    }
    else if (([[[arrayHandS objectAtIndex:1]valueForKey:@"answer"]isEqualToString:@"YES"] && [[[arrayHandS objectAtIndex:2]valueForKey:@"answer"]isEqualToString:@"YES"]))
    {
        scrllView1.contentSize = CGSizeMake(DEVICE_WIDTH, DEVICE_HEIGHT-zz-(45*approaxSize));
    }
    else if (([[[arrayHandS objectAtIndex:0]valueForKey:@"answer"]isEqualToString:@"YES"] && [[[arrayHandS objectAtIndex:2]valueForKey:@"answer"]isEqualToString:@"NA"]))
    {
        scrllView1.contentSize = CGSizeMake(DEVICE_WIDTH, DEVICE_HEIGHT-zz-(45*approaxSize));
    }
    else if (([[[arrayHandS objectAtIndex:1]valueForKey:@"answer"]isEqualToString:@"YES"] && [[[arrayHandS objectAtIndex:2]valueForKey:@"answer"]isEqualToString:@"NA"]))
    {
        scrllView1.contentSize = CGSizeMake(DEVICE_WIDTH, DEVICE_HEIGHT-zz-(45*approaxSize));
    }
    else if ([[[arrayHandS objectAtIndex:0]valueForKey:@"answer"]isEqualToString:@"YES"] && [[[arrayHandS objectAtIndex:1]valueForKey:@"answer"]isEqualToString:@"YES"] && [[[arrayHandS objectAtIndex:2]valueForKey:@"answer"]isEqualToString:@"YES"])
    {
        
        scrllView1.contentSize = CGSizeMake(DEVICE_WIDTH, DEVICE_HEIGHT-zz-(45*approaxSize));
    }
    
    else
    {
        if (IS_IPHONE_4)
        {
            scrllView1.contentSize = CGSizeMake(DEVICE_WIDTH, DEVICE_HEIGHT+80);
        }
        else if (IS_IPHONE_X)
        {
            scrllView1.contentSize = CGSizeMake(DEVICE_WIDTH, DEVICE_HEIGHT);
        }

    }

}


#pragma mark - Button Click Events
-(void)btnBackClick
{
    NSLog(@"%@",arrayHandS);
    [self.view endEditing:true];
        [scrllView setFrame:CGRectMake(0, 0, DEVICE_WIDTH, DEVICE_HEIGHT)];
    if (intscreen == 0)
    {
        arrayHandS = [[NSMutableArray alloc]init];
        for (int i =0; i<=5; i++)
        {
            NSMutableDictionary *tmpDict = [[NSMutableDictionary alloc]initWithObjectsAndKeys:@"NO",@"answer",@"NA",@"reason", nil];
            [arrayHandS addObject:tmpDict];
        }
        [[arrayHandS objectAtIndex:5]setValue:@"NA" forKey:@"answer"];
        
        isNextClikced = false;
        [self.navigationController popViewControllerAnimated:true];
    }
    else if (intscreen == 1)
    {
        intscreen = 0;
        [scrllView setContentOffset:CGPointMake(0, 0) animated:YES];
        moveFrwdBtn.hidden = true;
        moveBackBtn.hidden = true;
        btmView.hidden = true;
    
    }
    else if (intscreen == 2)
    {
        [moveFrwdBtn setTitle:@"NEXT   " forState:UIControlStateNormal];
        intscreen = 1;
        [scrllView setContentOffset:CGPointMake(DEVICE_WIDTH, 0) animated:YES];
//        if (isFromeEdit == false)
//        {
//            [[arrayHandS objectAtIndex:3] setValue:@"YES" forKey:@"answer"];
//            [[arrayHandS objectAtIndex:4] setValue:@"YES" forKey:@"answer"];
//            [[arrayHandS objectAtIndex:3]setValue:@"" forKey:@"reason"];
//            [[arrayHandS objectAtIndex:4]setValue:@"" forKey:@"reason"];
//            [[arrayHandS objectAtIndex:5]setValue:@"" forKey:@"answer"];
//            [[arrayHandS objectAtIndex:5]setValue:@"" forKey:@"reason"];
//            indexHazard = 0;
//            intSelectedHazrd = 0;
//        }
    }
    [self ShowPicker:NO andView:typeBackView];


}
-(void)btnGoClick
{
    if (isNextClikced == false)
    {
        arrayHandS = [[NSMutableArray alloc]init];
        for (int i =0; i<=5; i++)
        {
            NSMutableDictionary *tmpDict = [[NSMutableDictionary alloc]initWithObjectsAndKeys:@"NO",@"answer",@"NA",@"reason", nil];
            [arrayHandS addObject:tmpDict];
        }
        [[arrayHandS objectAtIndex:5]setValue:@"NA" forKey:@"answer"];
    }
    [scrllView setContentOffset:CGPointMake(DEVICE_WIDTH, 0) animated:YES];
    [self setUpQuestionView];
   
}
-(void)moveNextClick
{
    isNextClikced = true;
    [self.view endEditing:true];
    [UIView animateWithDuration:0.4 animations:^{
        [scrllView setFrame:CGRectMake(0, 0, DEVICE_WIDTH, DEVICE_HEIGHT)];
    }];
    if (intscreen == 1)
    {
        if ([[[arrayHandS objectAtIndex:0] valueForKey:@"answer"]isEqualToString:@"NO"])
        {
            if ([[APP_DELEGATE checkforValidString:[[arrayHandS objectAtIndex:0] valueForKey:@"reason"]]isEqualToString:@"NA"])
            {
                URBAlertView *alertView = [[URBAlertView alloc] initWithTitle:ALERT_TITLE message:@"Please explain the reason for QUESTION 1" cancelButtonTitle:OK_BTN otherButtonTitles: nil, nil];
                [alertView setMessageFont:[UIFont fontWithName:CGRegular size:14]];
                [alertView setHandlerBlock:^(NSInteger buttonIndex, URBAlertView *alertView) {
                    [alertView hideWithCompletionBlock:^{
                    }];
                }];
                [alertView showWithAnimation:URBAlertAnimationTopToBottom];
                if (IS_IPHONE_X){[alertView showWithAnimation:URBAlertAnimationDefault];}
                return;
            }
           
        }
         if (([[[arrayHandS objectAtIndex:1] valueForKey:@"answer"]isEqualToString:@"NO"]))
        {
            if ([[APP_DELEGATE checkforValidString:[[arrayHandS objectAtIndex:1] valueForKey:@"reason"]]isEqualToString:@"NA"])
            {
                URBAlertView *alertView = [[URBAlertView alloc] initWithTitle:ALERT_TITLE message:@"Please explain the reason for QUESTION 2" cancelButtonTitle:OK_BTN otherButtonTitles: nil, nil];
                [alertView setMessageFont:[UIFont fontWithName:CGRegular size:14]];
                [alertView setHandlerBlock:^(NSInteger buttonIndex, URBAlertView *alertView) {
                    [alertView hideWithCompletionBlock:^{
                    }];
                }];
                [alertView showWithAnimation:URBAlertAnimationTopToBottom];
                if (IS_IPHONE_X){[alertView showWithAnimation:URBAlertAnimationDefault];}
                return;
            }
            
        }
        if ((([[[arrayHandS objectAtIndex:2] valueForKey:@"answer"]isEqualToString:@"NO"])))
        {
            if ([[APP_DELEGATE checkforValidString:[[arrayHandS objectAtIndex:2] valueForKey:@"reason"]]isEqualToString:@"NA"])
            {
                URBAlertView *alertView = [[URBAlertView alloc] initWithTitle:ALERT_TITLE message:@"Please explain the reason for QUESTION 3" cancelButtonTitle:OK_BTN otherButtonTitles: nil, nil];
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
                [scrllView setContentOffset:CGPointMake(DEVICE_WIDTH*2, 0) animated:YES];
                [self setUpQuestionPart2View];
                [moveFrwdBtn setTitle:@"SAVE   " forState:UIControlStateNormal];
            }
        }
        else
        {
            [scrllView setContentOffset:CGPointMake(DEVICE_WIDTH*2, 0) animated:YES];
            [self setUpQuestionPart2View];
            [moveFrwdBtn setTitle:@"SAVE   " forState:UIControlStateNormal];
        }

    }
    else if (intscreen == 2)
    {
        if ([[[arrayHandS objectAtIndex:3] valueForKey:@"answer"]isEqualToString:@"NO"])
        {
            if ([[APP_DELEGATE checkforValidString:[[arrayHandS objectAtIndex:3] valueForKey:@"reason"]]isEqualToString:@"NA"])
            {
                URBAlertView *alertView = [[URBAlertView alloc] initWithTitle:ALERT_TITLE message:@"Please explain the reason for QUESTION 4" cancelButtonTitle:OK_BTN otherButtonTitles: nil, nil];
                [alertView setMessageFont:[UIFont fontWithName:CGRegular size:14]];
                [alertView setHandlerBlock:^(NSInteger buttonIndex, URBAlertView *alertView) {
                    [alertView hideWithCompletionBlock:^{
                    }];
                }];
                [alertView showWithAnimation:URBAlertAnimationTopToBottom];
                if (IS_IPHONE_X){[alertView showWithAnimation:URBAlertAnimationDefault];}
                return;
            }
        }
        if ([[[arrayHandS objectAtIndex:4] valueForKey:@"answer"]isEqualToString:@"NO"])
        {
            if ([[APP_DELEGATE checkforValidString:[[arrayHandS objectAtIndex:4] valueForKey:@"reason"]]isEqualToString:@"NA"])
            {
                URBAlertView *alertView = [[URBAlertView alloc] initWithTitle:ALERT_TITLE message:@"Please explain the reason for QUESTION 5" cancelButtonTitle:OK_BTN otherButtonTitles: nil, nil];
                [alertView setMessageFont:[UIFont fontWithName:CGRegular size:14]];
                [alertView setHandlerBlock:^(NSInteger buttonIndex, URBAlertView *alertView) {
                    [alertView hideWithCompletionBlock:^{
                    }];
                }];
                [alertView showWithAnimation:URBAlertAnimationTopToBottom];
                if (IS_IPHONE_X){[alertView showWithAnimation:URBAlertAnimationDefault];}
                return;
            }
        }
        if ([[APP_DELEGATE checkforValidString:[[arrayHandS objectAtIndex:5] valueForKey:@"answer"]]isEqualToString:@"NA"] || [[APP_DELEGATE checkforValidString:[[arrayHandS objectAtIndex:5] valueForKey:@"answer"]]isEqualToString:@"NO"])
        {
            URBAlertView *alertView = [[URBAlertView alloc] initWithTitle:ALERT_TITLE message:@"Please Choose your hazard from the list" cancelButtonTitle:OK_BTN otherButtonTitles: nil, nil];
            [alertView setMessageFont:[UIFont fontWithName:CGRegular size:14]];
            [alertView setHandlerBlock:^(NSInteger buttonIndex, URBAlertView *alertView) {
                [alertView hideWithCompletionBlock:^{
                }];
            }];
            [alertView showWithAnimation:URBAlertAnimationTopToBottom];
            if (IS_IPHONE_X){[alertView showWithAnimation:URBAlertAnimationDefault];}
            return;
        }
        if ([[APP_DELEGATE checkforValidString:[[arrayHandS objectAtIndex:5] valueForKey:@"reason"]]isEqualToString:@"NA"])
        {
            URBAlertView *alertView = [[URBAlertView alloc] initWithTitle:ALERT_TITLE message:@"Please describe additional precautions" cancelButtonTitle:OK_BTN otherButtonTitles: nil, nil];
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
            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
            [dateFormatter setDateFormat:@"YYYY-MM-dd HH:mm"];
            NSString *currentTime = [dateFormatter stringFromDate:[NSDate date]];
            NSString * strUserID = [APP_DELEGATE checkforValidString:CURRENT_USER_ID];

            NSString *strQ1 = [[arrayHandS objectAtIndex:0] valueForKey:@"answer"];
            NSString *strQ1ans = [[arrayHandS objectAtIndex:0] valueForKey:@"reason"];
            NSString *strQ2 = [[arrayHandS objectAtIndex:1] valueForKey:@"answer"];
            NSString *strQ2ans = [[arrayHandS objectAtIndex:1] valueForKey:@"reason"];
            NSString *strQ3 = [[arrayHandS objectAtIndex:2] valueForKey:@"answer"];
            NSString *strQ3ans = [[arrayHandS objectAtIndex:2] valueForKey:@"reason"];
            NSString *strQ4 = [[arrayHandS objectAtIndex:3] valueForKey:@"answer"];
            NSString *strQ4ans = [[arrayHandS objectAtIndex:3] valueForKey:@"reason"];
            NSString * strQ5 = [[arrayHandS objectAtIndex:4] valueForKey:@"answer"];
            NSString *strQ5ans = [[arrayHandS objectAtIndex:4] valueForKey:@"reason"];
            NSString *strQ6 = [[arrayHandS objectAtIndex:5] valueForKey:@"answer"];
            NSString *strQ6ans = [[arrayHandS objectAtIndex:5] valueForKey:@"reason"];

            NSLog(@"while clicking next %@",arrayHandS);

            if ([strType  isEqualToString: @"install"])
            {
                if ([[APP_DELEGATE checkforValidString:strInstallID]isEqualToString:@"NA"])
                {
                    NSString * requestStr =[NSString stringWithFormat:@"insert into 'tbl_install'('user_id','created_at','is_sync') values(\"%@\",\"%@\",'0')",strUserID,currentTime];
                    
                    strInstallID = [NSString stringWithFormat:@"%d",[[DataBaseManager dataBaseManager] executeSw:requestStr]];
                }
                
                NewInstallVC *installVC = [[NewInstallVC alloc]init];
                installVC.installID = strInstallID;
                if (isFromeEdit == true)
                {
                    installVC.isFromeEdit = true;
                    installVC.detailDict = detailDict;
                    installVC.installID = strInstallID;
                }
                [self.navigationController pushViewController:installVC animated:true];
            }
            else if ([strType  isEqualToString: @"uninstall"])
            {
                if ([[APP_DELEGATE checkforValidString:strInstallID]isEqualToString:@"NA"])
                {
                    NSString * requestStr =[NSString stringWithFormat:@"insert into 'tbl_uninstall'('user_id','created_at','is_sync') values(\"%@\",\"%@\",'0')",strUserID,currentTime];
                    strInstallID = [NSString stringWithFormat:@"%d",[[DataBaseManager dataBaseManager] executeSw:requestStr]];
                }
                
                UnInstalledVC *installVC = [[UnInstalledVC alloc]init];
                installVC.installID = strInstallID;
                if (isFromeEdit == true)
                {
                    installVC.isFromeEdit = true;
                    installVC.detailDict = detailDict;
                    installVC.installID = strInstallID;
                }
                [self.navigationController pushViewController:installVC animated:true];
            }
            else if ([strType  isEqualToString: @"inspection"])
            {
                if ([[APP_DELEGATE checkforValidString:strInstallID]isEqualToString:@"NA"])
                {
                    NSString * requestStr =[NSString stringWithFormat:@"insert into 'tbl_inspection'('user_id','created_at','is_sync') values(\"%@\",\"%@\",'0')",strUserID,currentTime];
                    strInstallID = [NSString stringWithFormat:@"%d",[[DataBaseManager dataBaseManager] executeSw:requestStr]];
                }
                
                InspectionVC *installVC = [[InspectionVC alloc]init];
                installVC.installID = strInstallID;
                if (isFromeEdit == true)
                {
                    installVC.isFromeEdit = true;
                    installVC.detailDict = detailDict;
                    installVC.installID = strInstallID;
                }
                
                [self.navigationController pushViewController:installVC animated:true];

            }
            
            NSMutableArray * tmpArr = [[NSMutableArray alloc] init];
            NSString* tmpStr = [NSString stringWithFormat:@"select * from tbl_question where install_id='%@' and type = '%@'",strInstallID,strType];
            [[DataBaseManager dataBaseManager] execute:tmpStr resultsArray:tmpArr];

            if ([tmpArr count] == 0)
            {
                NSString *strQue = [NSString stringWithFormat:@"insert into 'tbl_question'('install_id','type','q1','q1ans','q2','q2ans','q3','q3ans','q4','q4ans','q5','q5ans','q6','q6ans') values(\"%@\",\"%@\",\"%@\",\"%@\",\"%@\",\"%@\",\"%@\",\"%@\",\"%@\",\"%@\",\"%@\",\"%@\",\"%@\",\"%@\")",strInstallID,strType,strQ1,strQ1ans,strQ2,strQ2ans,strQ3,strQ3ans,strQ4,strQ4ans,strQ5,strQ5ans,strQ6,strQ6ans];
                [[DataBaseManager dataBaseManager] executeSw:strQue];
            }
            else
            {
                NSString * requestStr =[NSString stringWithFormat:@"update 'tbl_question' set 'q1' = \"%@\",'q1ans' = \"%@\",'q2' = \"%@\",'q2ans' = \"%@\",'q3' = \"%@\",'q3ans' = \"%@\",'q4' = \"%@\",'q4ans' = \"%@\",'q5' = \"%@\",'q5ans' = \"%@\",'q6' = \"%@\",'q6ans' = \"%@\" where install_id ='%@' and type = '%@'",strQ1,strQ1ans,strQ2,strQ2ans,strQ3,strQ3ans,strQ4,strQ4ans,strQ5,strQ5ans,strQ6,strQ6ans,strInstallID,strType];
                [[DataBaseManager dataBaseManager] execute:requestStr];
                
            }
//            [self writeToTextFile];
        }
    }

    
}
-(void)btnReviewClick
{
    isLandscapeRequired = true;
    InstallGuidePDF * guidePdf = [[InstallGuidePDF alloc] init];
    guidePdf.strFrom = @"Health";
    guidePdf.strTitle = @"Health & Safety info.";
//    guidePdf.isfromInstallGuide = isfromInstallGuide;@
    [self.navigationController pushViewController:guidePdf animated:YES];
}
-(void)btnYesClick:(id)sender
{
    [typeBackView removeFromSuperview];
    [UIView animateWithDuration:0.4 animations:^{
        [scrllView1 setFrame:CGRectMake(DEVICE_WIDTH, zz, DEVICE_WIDTH, DEVICE_HEIGHT-zz-(45*approaxSize))];
        [scrllView2 setFrame:CGRectMake(DEVICE_WIDTH*2, zz, DEVICE_WIDTH, DEVICE_HEIGHT-zz-(45*approaxSize))];
        
    }];
    
    [self.view endEditing:true];

    if ([sender tag] == 1)
    {
        [[arrayHandS objectAtIndex:0]setValue:@"YES" forKey:@"answer"];
        [[arrayHandS objectAtIndex:0]setValue:@"NA" forKey:@"reason"];
        txtQ1.text = @"";
        btnRadioView1.imgRadioYes.image = [UIImage imageNamed:@"radiobuttonSelected.png"];
        btnRadioView1.imgRadioNo.image = [UIImage imageNamed:@"radiobuttonUnselected.png"];
        txtQ1.hidden = true;
        lblQ1PlaceHolder.hidden = true;
        viewq2.frame = CGRectMake(0, viewq1.frame.origin.y+(100*approaxSize), DEVICE_WIDTH, 170*approaxSize);
        if ([[[arrayHandS objectAtIndex:1]valueForKey:@"answer"]isEqualToString:@"YES"])
        {
            viewq3.frame = CGRectMake(0, viewq2.frame.origin.y+(85*approaxSize), DEVICE_WIDTH, 170*approaxSize);
        }
        else
        {
            viewq3.frame = CGRectMake(0, viewq2.frame.origin.y+(185*approaxSize), DEVICE_WIDTH, 170*approaxSize);
        }

    }
    else if ([sender tag] == 2)
    {
        [[arrayHandS objectAtIndex:1]setValue:@"YES" forKey:@"answer"];
        [[arrayHandS objectAtIndex:1]setValue:@"NA" forKey:@"reason"];
        txtQ2.text = @"";
        btnRadioView2.imgRadioYes.image = [UIImage imageNamed:@"radiobuttonSelected.png"];
        btnRadioView2.imgRadioNo.image = [UIImage imageNamed:@"radiobuttonUnselected.png"];
        txtQ2.hidden = true;
        lblQ2PlaceHolder.hidden = true;
        viewq3.frame = CGRectMake(0, viewq2.frame.origin.y+(85*approaxSize), DEVICE_WIDTH, 170*approaxSize);
    }
    else if ([sender tag] == 3)
    {
        [[arrayHandS objectAtIndex:2]setValue:@"YES" forKey:@"answer"];
        [[arrayHandS objectAtIndex:2]setValue:@"NA" forKey:@"reason"];
        txtQ3.text = @"";
        btnRadioView3.imgRadioYes.image = [UIImage imageNamed:@"radiobuttonSelected.png"];
        btnRadioView3.imgRadioNo.image = [UIImage imageNamed:@"radiobuttonUnselected.png"];
        btnRadioView3.imgRadioNA.image = [UIImage imageNamed:@"radiobuttonUnselected.png"];
        txtQ3.hidden = true;
        lblQ3PlaceHolder.hidden = true;
    }
    else if ([sender tag] == 4)
    {
        [[arrayHandS objectAtIndex:3]setValue:@"YES" forKey:@"answer"];
        [[arrayHandS objectAtIndex:3]setValue:@"NA" forKey:@"reason"];
        txtQ4.text = @"";
        btnRadioView4.imgRadioYes.image = [UIImage imageNamed:@"radiobuttonSelected.png"];
        btnRadioView4.imgRadioNo.image = [UIImage imageNamed:@"radiobuttonUnselected.png"];
        btnRadioView4.imgRadioNA.image = [UIImage imageNamed:@"radiobuttonUnselected.png"];
        txtQ4.hidden = true;
        lblQ4PlaceHolder.hidden = true;
        viewq5.frame = CGRectMake(0, viewq4.frame.origin.y+(85*approaxSize), DEVICE_WIDTH, 155*approaxSize);
        if ([[[arrayHandS objectAtIndex:4]valueForKey:@"answer"]isEqualToString:@"YES"] || [[[arrayHandS objectAtIndex:4]valueForKey:@"answer"]isEqualToString:@"NA"])
        {
            viewq6.frame = CGRectMake(0, viewq5.frame.origin.y+(70*approaxSize), DEVICE_WIDTH, 215*approaxSize);
        }
        else
        {
            viewq6.frame = CGRectMake(0, viewq5.frame.origin.y+(170*approaxSize), DEVICE_WIDTH, 215*approaxSize);
        }
    }
    else if ([sender tag] == 5)
    {
        [[arrayHandS objectAtIndex:4]setValue:@"YES" forKey:@"answer"];
        [[arrayHandS objectAtIndex:4]setValue:@"NA" forKey:@"reason"];
        txtQ5.text = @"";
        btnRadioView5.imgRadioYes.image = [UIImage imageNamed:@"radiobuttonSelected.png"];
        btnRadioView5.imgRadioNo.image = [UIImage imageNamed:@"radiobuttonUnselected.png"];
        btnRadioView5.imgRadioNA.image = [UIImage imageNamed:@"radiobuttonUnselected.png"];
        txtQ5.hidden = true;
        lblQ5PlaceHolder.hidden = true;
        if ([[[arrayHandS objectAtIndex:4]valueForKey:@"answer"]isEqualToString:@"YES"])
        {
            viewq6.frame = CGRectMake(0, viewq5.frame.origin.y+(70*approaxSize), DEVICE_WIDTH, 215*approaxSize);
        }
        else
        {
            viewq6.frame = CGRectMake(0, viewq5.frame.origin.y+(170*approaxSize), DEVICE_WIDTH, 215*approaxSize);
        }
       
    }
    if (IS_IPHONE_4 || IS_IPHONE_X)
    {
        [self setIphone4FramesForView1];
//        [self setIphone4FramesForView2];
    }

}
-(void)btnNoClick:(id)sender
{
    [typeBackView removeFromSuperview];
    [UIView animateWithDuration:0.4 animations:^{
        [scrllView1 setFrame:CGRectMake(DEVICE_WIDTH, zz, DEVICE_WIDTH, DEVICE_HEIGHT-zz-(45*approaxSize))];
        [scrllView2 setFrame:CGRectMake(DEVICE_WIDTH*2, zz, DEVICE_WIDTH, DEVICE_HEIGHT-zz-(45*approaxSize))];
        
    }];
    
    [self.view endEditing:true];

    if ([sender tag] == 1)
    {
        [[arrayHandS objectAtIndex:0]setValue:@"NO" forKey:@"answer"];
        btnRadioView1.imgRadioYes.image = [UIImage imageNamed:@"radiobuttonUnselected.png"];
        btnRadioView1.imgRadioNo.image = [UIImage imageNamed:@"radiobuttonSelected.png"];
        txtQ1.hidden = false;
        if ([[APP_DELEGATE checkforValidString:[[arrayHandS objectAtIndex:0] valueForKey:@"reason"]]isEqualToString:@"NA"])
        {
            lblQ1PlaceHolder.hidden = false;
        }
        else
        {
            lblQ1PlaceHolder.hidden = true;
        }
        viewq2.frame = CGRectMake(0, viewq1.frame.origin.y+(200*approaxSize), DEVICE_WIDTH, 170*approaxSize);

        if ([[[arrayHandS objectAtIndex:1]valueForKey:@"answer"]isEqualToString:@"YES"])
        {
            viewq3.frame = CGRectMake(0, viewq2.frame.origin.y+(85*approaxSize), DEVICE_WIDTH, 170*approaxSize);
        }
        else
        {
            viewq3.frame = CGRectMake(0, viewq2.frame.origin.y+(185*approaxSize), DEVICE_WIDTH, 170*approaxSize);
        }
        
    }
    else if ([sender tag] == 2)
    {
        [[arrayHandS objectAtIndex:1]setValue:@"NO" forKey:@"answer"];
        btnRadioView2.imgRadioYes.image = [UIImage imageNamed:@"radiobuttonUnselected.png"];
        btnRadioView2.imgRadioNo.image = [UIImage imageNamed:@"radiobuttonSelected.png"];
        txtQ2.hidden = false;
        viewq3.frame = CGRectMake(0, viewq2.frame.origin.y+(185*approaxSize), DEVICE_WIDTH, 170*approaxSize);
        if ([[APP_DELEGATE checkforValidString:[[arrayHandS objectAtIndex:1] valueForKey:@"reason"]]isEqualToString:@"NA"])
        {
            lblQ2PlaceHolder.hidden = false;
        }
        else
        {
            lblQ2PlaceHolder.hidden = true;
        }
    }
    else if ([sender tag] == 3)
    {
        [[arrayHandS objectAtIndex:2]setValue:@"NO" forKey:@"answer"];
        btnRadioView3.imgRadioYes.image = [UIImage imageNamed:@"radiobuttonUnselected.png"];
        btnRadioView3.imgRadioNo.image = [UIImage imageNamed:@"radiobuttonSelected.png"];
        btnRadioView3.imgRadioNA.image = [UIImage imageNamed:@"radiobuttonUnselected.png"];
        txtQ3.hidden = false;
        if ([[APP_DELEGATE checkforValidString:[[arrayHandS objectAtIndex:2] valueForKey:@"reason"]]isEqualToString:@"NA"])
        {
            lblQ3PlaceHolder.hidden = false;
        }
        else
        {
            lblQ3PlaceHolder.hidden = true;
        }
    }
    else if ([sender tag] == 4)
    {
        [[arrayHandS objectAtIndex:3]setValue:@"NO" forKey:@"answer"];
        btnRadioView4.imgRadioYes.image = [UIImage imageNamed:@"radiobuttonUnselected.png"];
        btnRadioView4.imgRadioNo.image = [UIImage imageNamed:@"radiobuttonSelected.png"];
        btnRadioView4.imgRadioNA.image = [UIImage imageNamed:@"radiobuttonUnselected.png"];
        txtQ4.hidden = false;
        viewq5.frame = CGRectMake(0, viewq1.frame.origin.y+(185*approaxSize), DEVICE_WIDTH, 155*approaxSize);
        if ([[APP_DELEGATE checkforValidString:[[arrayHandS objectAtIndex:3] valueForKey:@"reason"]]isEqualToString:@"NA"])
        {
            lblQ4PlaceHolder.hidden = false;
        }
        else
        {
            lblQ4PlaceHolder.hidden = true;
        }
        if ([[[arrayHandS objectAtIndex:4]valueForKey:@"answer"]isEqualToString:@"YES"] || [[[arrayHandS objectAtIndex:4]valueForKey:@"answer"]isEqualToString:@"NA"])
        {
            viewq6.frame = CGRectMake(0, viewq5.frame.origin.y+(70*approaxSize), DEVICE_WIDTH, 215*approaxSize);
        }
        else
        {
            viewq6.frame = CGRectMake(0, viewq5.frame.origin.y+(170*approaxSize), DEVICE_WIDTH, 215*approaxSize);
        }
       
    }
    else if ([sender tag] == 5)
    {
        [[arrayHandS objectAtIndex:4]setValue:@"NO" forKey:@"answer"];
        btnRadioView5.imgRadioYes.image = [UIImage imageNamed:@"radiobuttonUnselected.png"];
        btnRadioView5.imgRadioNo.image = [UIImage imageNamed:@"radiobuttonSelected.png"];
        btnRadioView5.imgRadioNA.image = [UIImage imageNamed:@"radiobuttonUnselected.png"];
        txtQ5.hidden = false;
        if ([[APP_DELEGATE checkforValidString:[[arrayHandS objectAtIndex:4] valueForKey:@"reason"]]isEqualToString:@"NA"])
        {
            lblQ5PlaceHolder.hidden = false;
        }
        else
        {
            lblQ5PlaceHolder.hidden = true;
        }
        if ([[[arrayHandS objectAtIndex:4]valueForKey:@"answer"]isEqualToString:@"YES"])
        {
            viewq6.frame = CGRectMake(0, viewq5.frame.origin.y+(70*approaxSize), DEVICE_WIDTH, 215*approaxSize);
        }
        else
        {
            viewq6.frame = CGRectMake(0, viewq5.frame.origin.y+(170*approaxSize), DEVICE_WIDTH, 215*approaxSize);
        }
    }
    if (IS_IPHONE_4 || IS_IPHONE_X)
    {
        [self setIphone4FramesForView1];
        //        [self setIphone4FramesForView2];
    }

}
-(void)btnNAClick:(id)sender
{
    [typeBackView removeFromSuperview];

    [UIView animateWithDuration:0.4 animations:^{
        [scrllView1 setFrame:CGRectMake(DEVICE_WIDTH, zz, DEVICE_WIDTH, DEVICE_HEIGHT-zz-(45*approaxSize))];
        [scrllView2 setFrame:CGRectMake(DEVICE_WIDTH*2, zz, DEVICE_WIDTH, DEVICE_HEIGHT-zz-(45*approaxSize))];
        
    }];
    [self.view endEditing:true];

    if ([sender tag] == 3)
    {
        [[arrayHandS objectAtIndex:2]setValue:@"NA" forKey:@"answer"];
        [[arrayHandS objectAtIndex:2]setValue:@"NA" forKey:@"reason"];
        txtQ3.text = @"";
        btnRadioView3.imgRadioYes.image = [UIImage imageNamed:@"radiobuttonUnselected.png"];
        btnRadioView3.imgRadioNo.image = [UIImage imageNamed:@"radiobuttonUnselected.png"];
        btnRadioView3.imgRadioNA.image = [UIImage imageNamed:@"radiobuttonSelected.png"];
        txtQ3.hidden = true;
        lblQ3PlaceHolder.hidden = true;
    }
    else if ([sender tag] == 4)
    {
        [[arrayHandS objectAtIndex:3]setValue:@"NA" forKey:@"answer"];
        [[arrayHandS objectAtIndex:3]setValue:@"NA" forKey:@"reason"];
        txtQ4.text = @"";
        btnRadioView4.imgRadioYes.image = [UIImage imageNamed:@"radiobuttonUnselected.png"];
        btnRadioView4.imgRadioNo.image = [UIImage imageNamed:@"radiobuttonUnselected.png"];
        btnRadioView4.imgRadioNA.image = [UIImage imageNamed:@"radiobuttonSelected.png"];
        txtQ4.hidden = true;
        lblQ4PlaceHolder.hidden = true;
        viewq5.frame = CGRectMake(0, viewq4.frame.origin.y+(85*approaxSize), DEVICE_WIDTH, 155*approaxSize);
        if ([[[arrayHandS objectAtIndex:4]valueForKey:@"answer"]isEqualToString:@"YES"] || [[[arrayHandS objectAtIndex:4]valueForKey:@"answer"]isEqualToString:@"NA"])
        {
            viewq6.frame = CGRectMake(0, viewq5.frame.origin.y+(70*approaxSize), DEVICE_WIDTH, 215*approaxSize);
        }
        else
        {
            viewq6.frame = CGRectMake(0, viewq5.frame.origin.y+(170*approaxSize), DEVICE_WIDTH, 215*approaxSize);
        }
    }
    else if ([sender tag] == 5)
    {
        [[arrayHandS objectAtIndex:4]setValue:@"NA" forKey:@"answer"];
        [[arrayHandS objectAtIndex:4]setValue:@"NA" forKey:@"reason"];
        txtQ5.text = @"";
        btnRadioView5.imgRadioYes.image = [UIImage imageNamed:@"radiobuttonUnselected.png"];
        btnRadioView5.imgRadioNo.image = [UIImage imageNamed:@"radiobuttonUnselected.png"];
        btnRadioView5.imgRadioNA.image = [UIImage imageNamed:@"radiobuttonSelected.png"];
        txtQ5.hidden = true;
        lblQ5PlaceHolder.hidden = true;
        viewq6.frame = CGRectMake(0, viewq5.frame.origin.y+(70*approaxSize), DEVICE_WIDTH, 215*approaxSize);

    }
    if (IS_IPHONE_4 || IS_IPHONE_X)
    {
        [self setIphone4FramesForView1];
        //        [self setIphone4FramesForView2];
    }

}
-(void)btnPickerViewClicked
{
    [self.view endEditing:true];
    [typeBackView removeFromSuperview];
    
    typeBackView = [[UIView alloc] initWithFrame:CGRectMake(0, DEVICE_HEIGHT, DEVICE_WIDTH, 250)];
    [typeBackView setBackgroundColor:[UIColor whiteColor]];
    [self.view addSubview:typeBackView];
    
    [hazardTypePicker removeFromSuperview];
    hazardTypePicker = nil;
    hazardTypePicker.delegate=nil;
    hazardTypePicker.dataSource=nil;
    hazardTypePicker = [[UIPickerView alloc] initWithFrame:CGRectMake(0, 34, DEVICE_WIDTH, 216)];
    [hazardTypePicker setBackgroundColor:[UIColor blackColor]];
    hazardTypePicker.tag=123;
    [hazardTypePicker setDelegate:self];
    [hazardTypePicker setDataSource:self];
    [typeBackView addSubview:hazardTypePicker];
    
    if (indexHazard < hazardArray.count)
    {
        [hazardTypePicker selectRow:indexHazard inComponent:0 animated:true];

    }
    

    UIButton * btnDone2 = [UIButton buttonWithType:UIButtonTypeCustom];
    [btnDone2 setFrame:CGRectMake(0 , 0, DEVICE_WIDTH, 44)];
    [btnDone2 setBackgroundImage:[UIImage imageNamed:@"BTN.png"] forState:UIControlStateNormal];
    [btnDone2 setTitle:@"Done" forState:UIControlStateNormal];
    [btnDone2 setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    btnDone2.titleLabel.font = [UIFont fontWithName:CGRegular size:textSize];
    [btnDone2 addTarget:self action:@selector(btnDoneClicked) forControlEvents:UIControlEventTouchUpInside];
    [typeBackView addSubview:btnDone2];
    
    [self ShowPicker:YES andView:typeBackView];
}
-(void)btnDoneClicked
{
    [UIView animateWithDuration:0.4 animations:^{
        [scrllView1 setFrame:CGRectMake(DEVICE_WIDTH, zz, DEVICE_WIDTH, DEVICE_HEIGHT-zz-(45*approaxSize))];
        [scrllView2 setFrame:CGRectMake(DEVICE_WIDTH*2, zz, DEVICE_WIDTH, DEVICE_HEIGHT-zz-(45*approaxSize))];
        
    }];
    [[arrayHandS objectAtIndex:5] setValue:[hazardArray objectAtIndex:intSelectedHazrd] forKey:@"answer"];
    indexHazard = [hazardArray indexOfObject:[hazardArray objectAtIndex:intSelectedHazrd]];
    
    if ([[APP_DELEGATE checkforValidString:[[arrayHandS objectAtIndex:5]valueForKey:@"answer"]]isEqualToString:@"NA"])
    {
        lblHazard.text = @"None";
        [[arrayHandS objectAtIndex:5] setValue:@"None" forKey:@"answer"];
    }
    else
    {
        lblHazard.text = [[arrayHandS objectAtIndex:5]valueForKey:@"answer"];
    }
        [self ShowPicker:NO andView:typeBackView];
}
#pragma mark - PickerView Delegate
-(NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}
-(NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return hazardArray.count;
}
- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view
{
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, pickerView.frame.size.width, 44)];
    label.backgroundColor = [UIColor clearColor];
    label.textAlignment = NSTextAlignmentCenter;
    label.textColor = [UIColor whiteColor];
    label.font = [UIFont fontWithName:CGBold size:14];
    
    label.text = [hazardArray objectAtIndex:row];
    return label;
}
-(void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    intSelectedHazrd = row;
}
#pragma mark - Animations
-(void)ShowPicker:(BOOL)isShow andView:(UIView *)myView
{
    int viewHeight = 250;
    if (IS_IPHONE_4)
    {
        viewHeight = 230;
    }
    if (isShow == YES)
    {
        [UIView transitionWithView:myView duration:0.4
                           options:UIViewAnimationOptionCurveEaseIn
                        animations:^{
                            [myView setFrame:CGRectMake(0, DEVICE_HEIGHT-viewHeight,DEVICE_WIDTH, viewHeight)];
                        }
                        completion:^(BOOL finished)
         {
         }];
    }
    else
    {
        [UIView transitionWithView:myView duration:0.4
                           options:UIViewAnimationOptionTransitionNone
                        animations:^{
                            [myView setFrame:CGRectMake(0, DEVICE_HEIGHT, DEVICE_WIDTH, viewHeight)];
                        }
                        completion:^(BOOL finished)
         {
         }];
    }
}
#pragma mark - UITextField Delegates
-(void)textViewDidBeginEditing:(UITextView *)textView
{
    [typeBackView removeFromSuperview];

    if (textView == txtQ1)
    {
        lblQ1PlaceHolder.hidden = true;
    }
    else if (textView == txtQ2)
    {
       
        if (IS_IPHONE_4)
        {
            [UIView animateWithDuration:0.4 animations:^{
            [scrllView1 setFrame:CGRectMake(DEVICE_WIDTH,-((viewq2.frame.origin.y-70)), DEVICE_WIDTH, DEVICE_HEIGHT+100)];
            }];
        }
        else if (IS_IPHONE_5)
        {
            [UIView animateWithDuration:0.4 animations:^{
                [scrllView1 setFrame:CGRectMake(DEVICE_WIDTH,-((viewq2.frame.origin.y-100)), DEVICE_WIDTH, DEVICE_HEIGHT)];
            }];
        }
        else if (IS_IPHONE_6 || IS_IPHONE_6plus)
        {
            [UIView animateWithDuration:0.4 animations:^{
                [scrllView1 setFrame:CGRectMake(DEVICE_WIDTH,-((viewq2.frame.origin.y-60)), DEVICE_WIDTH, DEVICE_HEIGHT)];
            }];
        }
        lblQ2PlaceHolder.hidden = true;
    }
    else if (textView == txtQ3)
    {
        [UIView animateWithDuration:0.4 animations:^{
            [scrllView1 setFrame:CGRectMake(DEVICE_WIDTH,-((viewq3.frame.origin.y-100)), DEVICE_WIDTH, DEVICE_HEIGHT)];
        }];
        if (IS_IPHONE_4)
        {
            [UIView animateWithDuration:0.4 animations:^{
            [scrllView1 setFrame:CGRectMake(DEVICE_WIDTH,-((viewq3.frame.origin.y-70)), DEVICE_WIDTH, DEVICE_HEIGHT+100)];
            }];
        }
        lblQ3PlaceHolder.hidden = true;
    }
    else if (textView == txtQ4)
    {
        lblQ4PlaceHolder.hidden = true;
    }
    else if (textView == txtQ5)
    {
        
        if (IS_IPHONE_4)
        {
            [UIView animateWithDuration:0.4 animations:^{
            [scrllView2 setFrame:CGRectMake(DEVICE_WIDTH*2,-((viewq5.frame.origin.y-50)), DEVICE_WIDTH, DEVICE_HEIGHT+100)];
            }];
        }
        else if (IS_IPHONE_5)
        {
            [UIView animateWithDuration:0.4 animations:^{
                [scrllView2 setFrame:CGRectMake(DEVICE_WIDTH*2,-((viewq5.frame.origin.y-100)), DEVICE_WIDTH, DEVICE_HEIGHT)];
            }];
        }
        else if (IS_IPHONE_6 || IS_IPHONE_6plus)
        {
            [UIView animateWithDuration:0.4 animations:^{
                [scrllView2 setFrame:CGRectMake(DEVICE_WIDTH*2,-((viewq5.frame.origin.y-60)), DEVICE_WIDTH, DEVICE_HEIGHT)];
            }];
        }
        lblQ5PlaceHolder.hidden = true;
    }
    else if (textView == txtQ6)
    {
        [UIView animateWithDuration:0.4 animations:^{
            [scrllView2 setFrame:CGRectMake(DEVICE_WIDTH*2,-((viewq6.frame.origin.y-100)), DEVICE_WIDTH, DEVICE_HEIGHT)];
        }];
        if (IS_IPHONE_4)
        {
            [UIView animateWithDuration:0.4 animations:^{
            [scrllView2 setFrame:CGRectMake(DEVICE_WIDTH*2,-((viewq6.frame.origin.y-50)), DEVICE_WIDTH, DEVICE_HEIGHT+100)];
            }];
        }
        lblQ6PlaceHolder.hidden = true;
    }
}
-(void)doneKeyBoarde
{
    [txtQ1 resignFirstResponder];
    [txtQ2 resignFirstResponder];
    [txtQ3 resignFirstResponder];
    [txtQ4 resignFirstResponder];
    [txtQ5 resignFirstResponder];
    [txtQ6 resignFirstResponder];
    
    [UIView animateWithDuration:0.4 animations:^{
        [scrllView1 setFrame:CGRectMake(DEVICE_WIDTH, zz, DEVICE_WIDTH, DEVICE_HEIGHT-zz-(45*approaxSize))];
        [scrllView2 setFrame:CGRectMake(DEVICE_WIDTH*2, zz, DEVICE_WIDTH, DEVICE_HEIGHT-zz-(45*approaxSize))];

    }];
  
}
-(void)textViewDidEndEditing:(UITextView *)textView
{
    if (textView == txtQ1)
    {
        if (textView.text.length == 0 || [[APP_DELEGATE checkforValidString:textView.text]isEqualToString:@"NA"])
        {
            lblQ1PlaceHolder.hidden = false;
            txtQ1.text = @"";
        }
        else
        {
            lblQ1PlaceHolder.hidden = true;
        }
        [[arrayHandS objectAtIndex:0] setValue:textView.text forKey:@"reason"];
    }
    else if (textView == txtQ2)
    {
        if (textView.text.length == 0 || [[APP_DELEGATE checkforValidString:textView.text]isEqualToString:@"NA"])
        {
            lblQ2PlaceHolder.hidden = false;
            txtQ2.text = @"";
        }
        else
        {
            lblQ2PlaceHolder.hidden = true;
        }
        [[arrayHandS objectAtIndex:1] setValue:textView.text forKey:@"reason"];
    }
    else if (textView == txtQ3)
    {
        if (textView.text.length == 0 || [[APP_DELEGATE checkforValidString:textView.text]isEqualToString:@"NA"])
        {
            lblQ3PlaceHolder.hidden = false;
            txtQ3.text = @"";
        }
        else
        {
            lblQ3PlaceHolder.hidden = true;
        }
        [[arrayHandS objectAtIndex:2] setValue:textView.text forKey:@"reason"];
    }
    else if (textView == txtQ4)
    {
        if (textView.text.length == 0 || [[APP_DELEGATE checkforValidString:textView.text]isEqualToString:@"NA"])
        {
            lblQ4PlaceHolder.hidden = false;
            txtQ4.text = @"";
        }
        else
        {
            lblQ4PlaceHolder.hidden = true;
        }
        [[arrayHandS objectAtIndex:3] setValue:textView.text forKey:@"reason"];
    }
    else if (textView == txtQ5)
    {
        if (textView.text.length == 0 || [[APP_DELEGATE checkforValidString:textView.text]isEqualToString:@"NA"])
        {
            lblQ5PlaceHolder.hidden = false;
            txtQ5.text = @"";
        }
        else
        {
            lblQ5PlaceHolder.hidden = true;
        }
        [[arrayHandS objectAtIndex:4] setValue:textView.text forKey:@"reason"];
    }
    else if (textView == txtQ6)
    {
        if (textView.text.length == 0 || [[APP_DELEGATE checkforValidString:textView.text]isEqualToString:@"NA"])
        {
            lblQ6PlaceHolder.hidden = false;
            txtQ6.text = @"";
        }
        else
        {
            lblQ6PlaceHolder.hidden = true;
        }
        [[arrayHandS objectAtIndex:5] setValue:textView.text forKey:@"reason"];
    }
    
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
////Method writes a string to a text file
//-(void)writeToTextFile
//{
//    //get the documents directory:
//    NSArray *paths = NSSearchPathForDirectoriesInDomains
//    (NSDocumentDirectory, NSUserDomainMask, YES);
//    NSString *documentsDirectory = [paths objectAtIndex:0];
//
//    //make a file name to write the data to using the documents directory:
//    NSString *fileName = [NSString stringWithFormat:@"%@/HealthNSafety.txt",
//                          documentsDirectory];
//
//    NSString * strTemp;
//    if ([strType isEqualToString:@"install"])
//    {
//        strTemp = @"Installer";
//    }
//    else if([strType isEqualToString:@"uninstall"])
//    {
//        strTemp = @"Uninstaller";
//    }
//    else
//    {
//        strTemp = @"Inspection";
//    }
//
//
//    NSString * content = [NSString stringWithFormat:@"=============================================================================\n%@ Health and Safety Questionnaire\n=============================================================================",strTemp];
////Q1
//    //create content - four lines of text
//    NSString * question1 = @"\n\nQ1: Are you wearing the prescribed PPE (including lifejacket if working near water)?";
//    NSString * answer1 = [NSString stringWithFormat: @"\nANSWER: %@",[[arrayHandS objectAtIndex:0]valueForKey:@"answer"]];
//    NSString * reason1 = [NSString stringWithFormat: @"\nREASON : %@",[[arrayHandS objectAtIndex:0]valueForKey:@"reason"]];
//    answer1 = [question1 stringByAppendingString:answer1];
//    content = [content stringByAppendingString:[answer1 stringByAppendingString:reason1]];
//
//    //save content to the documents directory
//
//
////Q2
//    NSString * question2 = @"\n\nQ2: Have you completed your equipment pre-inspection?";
//    NSString * answer2 = [NSString stringWithFormat: @"\nANSWER: %@",[[arrayHandS objectAtIndex:1]valueForKey:@"answer"]];
//    NSString * reason2 = [NSString stringWithFormat: @"\nREASON : %@",[[arrayHandS objectAtIndex:1]valueForKey:@"reason"]];
//
//    answer2 = [question2 stringByAppendingString:answer2];
//    content = [content stringByAppendingString:[answer2 stringByAppendingString:reason2]];
//
////Q3
//    NSString * question3 = @"\n\nQ3: Have you completed your pre-inspection for working at height?";
//    NSString * answer3 = [NSString stringWithFormat: @"\nANSWER: %@",[[arrayHandS objectAtIndex:2]valueForKey:@"answer"]];
//    NSString * reason3 = [NSString stringWithFormat: @"\nREASON : %@",[[arrayHandS objectAtIndex:2]valueForKey:@"reason"]];
//
//    answer3 = [question3 stringByAppendingString:answer3];
//    content = [content stringByAppendingString:[answer3 stringByAppendingString:reason3]];
//
// //Q4
//    NSString * question4 = @"\n\nQ4: Have you completed your pre-inspection for working at height?";
//    NSString * answer4 = [NSString stringWithFormat: @"\nANSWER: %@",[[arrayHandS objectAtIndex:3]valueForKey:@"answer"]];
//    NSString * reason4 = [NSString stringWithFormat: @"\nREASON : %@",[[arrayHandS objectAtIndex:3]valueForKey:@"reason"]];
//
//    answer4 = [question4 stringByAppendingString:answer4];
//    content = [content stringByAppendingString:[answer4 stringByAppendingString:reason4]];
//
////Q5
//    NSString * question5 = @"\n\nQ5: Have you completed your pre-inspection for working at height?";
//    NSString * answer5 = [NSString stringWithFormat: @"\nANSWER: %@",[[arrayHandS objectAtIndex:4]valueForKey:@"answer"]];
//    NSString * reason5 = [NSString stringWithFormat: @"\nREASON : %@",[[arrayHandS objectAtIndex:4]valueForKey:@"reason"]];
//
//    answer5 = [question5 stringByAppendingString:answer5];
//    content = [content stringByAppendingString:[answer5 stringByAppendingString:reason5]];
//
////Q6
//    NSString * question6 = @"\n\nQ6: Have you completed your pre-inspection for working at height?";
//    NSString * answer6 = [NSString stringWithFormat: @"\nANSWER: %@",[[arrayHandS objectAtIndex:5]valueForKey:@"answer"]];
//    NSString * reason6 = [NSString stringWithFormat: @"\nREASON : %@",[[arrayHandS objectAtIndex:5]valueForKey:@"reason"]];
//
//    answer6 = [question6 stringByAppendingString:answer6];
//    content = [content stringByAppendingString:[answer6 stringByAppendingString:reason6]];
//
//    [content writeToFile:fileName
//              atomically:NO
//                encoding:NSStringEncodingConversionAllowLossy
//                   error:nil];
//}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
