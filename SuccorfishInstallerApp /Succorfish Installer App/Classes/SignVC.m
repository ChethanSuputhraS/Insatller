//
//  SignVC.m
//  Succorfish Installer App
//
//  Created by stuart watts on 24/03/2018.
//  Copyright © 2018 Kalpesh Panchasara. All rights reserved.
//

#import "SignVC.h"

@interface SignVC ()
{
    int textSize;
    UIImageView * imgCheckOwner, * imgCheckInstaller;
    BOOL isOwnerAgreed, isInstallerAgreed;
}
@end

@implementation SignVC
@synthesize strFromView,isFromEdit,strInstallId,detailDict;
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    textSize = 16;
    if (IS_IPHONE_4 || IS_IPHONE_5)
    {
        textSize = 15;
    }
    
    UIImageView * imgBack = [[UIImageView alloc] init];
    imgBack.frame = CGRectMake(0, 0, DEVICE_WIDTH, DEVICE_HEIGHT);
    imgBack.image = [UIImage imageNamed:@"Splash_bg.png"];
    imgBack.userInteractionEnabled = YES;
    [self.view addSubview:imgBack];
    
    [self setNavigationViewFrames];

    // Do any additional setup after loading the view.
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
    [lblTitle setText:@"Signatures"];
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
    
    UIButton * btnSave = [UIButton buttonWithType:UIButtonTypeCustom];
    [btnSave addTarget:self action:@selector(btnSaveClick) forControlEvents:UIControlEventTouchUpInside];
    btnSave.frame = CGRectMake(DEVICE_WIDTH-50, 20, 50, 44);
    btnSave.backgroundColor = [UIColor clearColor];
    [btnSave setTitle:@"Save" forState:UIControlStateNormal];
    [btnSave setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [btnSave.titleLabel setFont:[UIFont fontWithName:CGRegular size:textSize]];
    [viewHeader addSubview:btnSave];
    
    if (IS_IPHONE_X)
    {
        viewHeader.frame = CGRectMake(0, 0, DEVICE_WIDTH, 88);
        lblTitle.frame = CGRectMake(50, 40, DEVICE_WIDTH-100, 44);
        backImg.frame = CGRectMake(10, 12+44, 12, 20);
        btnBack.frame = CGRectMake(0, 0, 70, 88);
        btnSave.frame = CGRectMake(DEVICE_WIDTH-50, 40, 50, 44);
        [self setMainViewContent:88 + 20];
    }
    else
    {
        [self setMainViewContent:64 + 10];
    }
}

-(void)setMainViewContent:(int)yAxis
{
    ownerSignImgView = [[UIImageView alloc] init];
    ownerSignImgView.frame = CGRectMake(15, yAxis, self.view.frame.size.width-30, 130);
    ownerSignImgView.backgroundColor = [UIColor whiteColor];
    ownerSignImgView.contentMode = UIViewContentModeScaleAspectFit;
    ownerSignImgView.layer.cornerRadius = 10;
    ownerSignImgView.layer.masksToBounds = YES;
    [self.view addSubview:ownerSignImgView];
    
    btnOwner = [UIButton buttonWithType:UIButtonTypeCustom];
    btnOwner.frame = CGRectMake(30, yAxis, self.view.frame.size.width-60, 130);
    btnOwner.backgroundColor = [UIColor clearColor];
    btnOwner.tag = 1;
    [btnOwner addTarget:self action:@selector(signatureBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btnOwner];
    
    UILabel * lblTitle4 = [[UILabel alloc] init];
    lblTitle4.frame = CGRectMake(0, 0, DEVICE_WIDTH-10, 25);
    lblTitle4.backgroundColor = [UIColor clearColor];
    lblTitle4.text = @" Tap here for owner sign";
    lblTitle4.font = [UIFont fontWithName:CGRegular size:textSize-1];
    lblTitle4.textColor = [UIColor blackColor];
    [btnOwner addSubview:lblTitle4];
    
    [self setTermsConditions:yAxis+130+10 forOwner:YES];
    
    yAxis = yAxis + 130 + 20 + 30 + 40;
    installerSignImgView = [[UIImageView alloc] init];
    installerSignImgView.frame = CGRectMake(15, yAxis, self.view.frame.size.width-30, 130);
    installerSignImgView.backgroundColor = [UIColor whiteColor];
    installerSignImgView.contentMode = UIViewContentModeScaleAspectFit;
    installerSignImgView.layer.cornerRadius = 10;
    installerSignImgView.layer.masksToBounds = YES;
    [self.view addSubview:installerSignImgView];
    
    btnInstaller = [UIButton buttonWithType:UIButtonTypeCustom];
    btnInstaller.frame = CGRectMake(30, yAxis, self.view.frame.size.width-60, 130);
    btnInstaller.backgroundColor = [UIColor clearColor];
    btnInstaller.tag = 2;
    [btnInstaller addTarget:self action:@selector(signatureBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btnInstaller];
    
    UILabel * lblInstaller = [[UILabel alloc] init];
    lblInstaller.frame = CGRectMake(0, 0, DEVICE_WIDTH-10, 25);
    lblInstaller.backgroundColor = [UIColor clearColor];
    lblInstaller.text = @" Tap here for Installer sign";
    lblInstaller.font = [UIFont fontWithName:CGRegular size:textSize-1];
    lblInstaller.textColor = [UIColor blackColor];
    [btnInstaller addSubview:lblInstaller];
    
    [self setTermsConditions:yAxis+130+10 forOwner:NO];
    
    if (isFromEdit)
    {
        NSString * folderName;
        if ([strFromView isEqualToString:@"Install"])
        {
            folderName = @"InstallSigns";
        }
        else if ([strFromView isEqualToString:@"Inspection"])
        {
            folderName = @"Inspection";
        }
        else
        {
            folderName = @"UnInstallSigns";
        }
        
        NSString * filePathOwner = [self documentsPathForFileName:[NSString stringWithFormat:@"%@/%@",folderName,[detailDict valueForKey:@"local_owner_sign"]]];
        NSData *pngData = [NSData dataWithContentsOfFile:filePathOwner];
        UIImage *image = [UIImage imageWithData:pngData];
        ownerSignImgView.image = image;
        if (ownerSignImgView.image != nil)
        {
            imgCheckOwner.image = [UIImage imageNamed:@"checked.png"];
            isOwnerAgreed = YES;
        }
        
        NSString * fileInstaller = [self documentsPathForFileName:[NSString stringWithFormat:@"%@/%@",folderName,[detailDict valueForKey:@"local_installer_sign"]]];
        pngData = [NSData dataWithContentsOfFile:fileInstaller];
        image = [UIImage imageWithData:pngData];
        installerSignImgView.image = image;
        if (installerSignImgView.image != nil)
        {
            imgCheckInstaller.image = [UIImage imageNamed:@"checked.png"];
            isInstallerAgreed = YES;
        }

    }
}
-(void)setTermsConditions:(int)withY forOwner:(BOOL)isOwner
{
    if (isOwner)
    {
        imgCheckOwner = [[UIImageView alloc] init];
        imgCheckOwner.image = [UIImage imageNamed:@"checkEmpty.png"];
        imgCheckOwner.frame = CGRectMake(5, withY+8, 20, 20);
        [self.view addSubview:imgCheckOwner];
    }
    else
    {
        imgCheckInstaller = [[UIImageView alloc] init];
        imgCheckInstaller.image = [UIImage imageNamed:@"checkEmpty.png"];
        imgCheckInstaller.frame = CGRectMake(5, withY+8, 20, 20);
        [self.view addSubview:imgCheckInstaller];
    }
    
  
    
    UILabel * lblTerms =[[UILabel alloc] initWithFrame:CGRectMake(35, withY, DEVICE_WIDTH-35, 40)];
    lblTerms.font=[UIFont fontWithName:CGRegular size:textSize-3];
    lblTerms.textColor=[UIColor whiteColor];
    lblTerms.numberOfLines = 0;
    [self.view addSubview:lblTerms];
    
    UIButton * btnAgree = [UIButton buttonWithType:UIButtonTypeCustom];
    [btnAgree setFrame:CGRectMake(0, withY, 50, 30)];
    [btnAgree addTarget:self action:@selector(agreeClick:) forControlEvents:UIControlEventTouchUpInside];
    btnAgree.backgroundColor = [UIColor clearColor];
    if (isOwner)
    {
        btnAgree.tag = 1;
    }
    else
    {
        btnAgree.tag = 2;
    }
    [self.view addSubview:btnAgree];
    
    NSString * msgStr = @"I am satisfied with installation and accept Succorfish T&C's";
    if (isOwner)
    {
        msgStr = @"I am satisfied with installation and accept Succorfish T&C's";
    }
    else
    {
        msgStr = @"The details entered are correct and Succorfish procedures were followed.";
    }
    NSMutableAttributedString *hintText = [[NSMutableAttributedString alloc] initWithString:msgStr];
    UIFontDescriptor *fontDescriptor = [UIFontDescriptor fontDescriptorWithName:CGBold size:textSize-2];
    UIFontDescriptor *fontDescriptor1 = [UIFontDescriptor fontDescriptorWithName:CGRegular size:textSize-2];
    UIFontDescriptor *symbolicFontDescriptor = [fontDescriptor fontDescriptorWithSymbolicTraits:UIFontDescriptorTraitTightLeading];
    
    if (isOwner)
    {
        UIFontDescriptor *symbolicFontDescriptor1 = [fontDescriptor1 fontDescriptorWithSymbolicTraits:UIFontDescriptorTraitBold];
        UIFont *fontWithDescriptor = [UIFont fontWithDescriptor:symbolicFontDescriptor size:textSize-2];
        UIFont *fontWithDescriptor1 = [UIFont fontWithDescriptor:symbolicFontDescriptor1 size:textSize-2];
        
        //Red and large
        [hintText setAttributes:@{NSFontAttributeName:fontWithDescriptor, NSForegroundColorAttributeName:[UIColor grayColor]} range:NSMakeRange(0, 45)];
        
        //Rest of text -- just futura
        [hintText setAttributes:@{NSFontAttributeName:fontWithDescriptor1, NSForegroundColorAttributeName:[UIColor whiteColor]} range:NSMakeRange(44, hintText.length -44)];
        
        UIButton * TCBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        TCBtn.frame = CGRectMake(0, withY, DEVICE_WIDTH, 35);
        [TCBtn addTarget:self action:@selector(btnConditions) forControlEvents:UIControlEventTouchUpInside];
//        [self.view addSubview:TCBtn];
    }
    lblTerms.textColor=[UIColor whiteColor];
    [lblTerms setAttributedText:hintText];
}

#pragma mark - Button Click events
-(void)btnBackClick
{
    [self.navigationController popViewControllerAnimated:YES];
}
-(void)btnSaveClick
{
    if ([self validationforThirdVieww])
    {
        NSString * strOwnerLocalUrl=@"NA";
        NSString * strInstallerLocalUrl=@"NA";
        NSString * folderName = @"InstallSigns";
        NSString * serverType = @"install";

        if ([strFromView isEqualToString:@"Install"])
        {
            folderName = @"InstallSigns";
            serverType = @"install";
        }
        else if ([strFromView isEqualToString:@"Inspection"])
        {
            folderName = @"Inspection";
            serverType = @"inspect";
        }
        else
        {
            folderName = @"UnInstallSigns";
            serverType = @"uninstall";
        }
        if (isFromEdit)
        {
            strOwnerLocalUrl = [self.detailDict valueForKey:@"local_owner_sign"];
            int randomID = arc4random() % 9000 + 1000;

            if([[self checkforValidString:strOwnerLocalUrl] isEqualToString:@"NA"])
            {
                NSTimeInterval timeStamp = [[NSDate date] timeIntervalSince1970];
                NSNumber *timeStampObj = [NSNumber numberWithInteger: timeStamp];
                NSString * imageName = [NSString stringWithFormat:@"/%@-instsign-%@%d.jpg",serverType,timeStampObj,randomID];
                strOwnerLocalUrl = imageName;
            }
            strOwnerLocalUrl = [strOwnerLocalUrl stringByReplacingOccurrencesOfString:@" " withString:@""];
            strOwnerLocalUrl = [self SaveSigntoDoc:strOwnerLocalUrl withFolder:folderName :ownerSignImgView];

            strInstallerLocalUrl = [self.detailDict valueForKey:@"local_installer_sign"];
            
            if([[self checkforValidString:strInstallerLocalUrl] isEqualToString:@"NA"])
            {
                NSTimeInterval timeStamp = [[NSDate date] timeIntervalSince1970];
                NSNumber *timeStampObj = [NSNumber numberWithInteger: timeStamp];
                NSString * imageNameInstaller = [NSString stringWithFormat:@"/%@-ownsign-%@%d.jpg",serverType,timeStampObj,randomID];
                strInstallerLocalUrl = imageNameInstaller;
            }
            strInstallerLocalUrl = [strInstallerLocalUrl stringByReplacingOccurrencesOfString:@" " withString:@""];
            strInstallerLocalUrl = [self SaveSigntoDoc:strInstallerLocalUrl withFolder:folderName :installerSignImgView];
            
            if ([strFromView isEqualToString:@"Install"])
            {
                NSString * requestStr =[NSString stringWithFormat:@"Update 'tbl_install'  set 'local_owner_sign' =\"%@\", 'local_installer_sign' = \"%@\" where id ='%@'",strOwnerLocalUrl,strInstallerLocalUrl,strInstallId];
                [[DataBaseManager dataBaseManager] execute:requestStr];

                NSMutableDictionary * dict = [[NSMutableDictionary alloc] init];
                [dict setObject:strInstallerLocalUrl forKey:@"local_installer_sign"];
                [dict setObject:strOwnerLocalUrl forKey:@"local_owner_sign"];
                [[NSNotificationCenter defaultCenter] postNotificationName:@"setSignaturePathsforInstalls" object:dict];
            }
            else if ([strFromView isEqualToString:@"Inspection"])
            {
                NSString * requestStr =[NSString stringWithFormat:@"Update 'tbl_inspection'  set 'local_owner_sign' =\"%@\", 'local_installer_sign' = \"%@\" where id ='%@'",strOwnerLocalUrl,strInstallerLocalUrl,strInstallId];
                [[DataBaseManager dataBaseManager] execute:requestStr];
                
                NSMutableDictionary * dict = [[NSMutableDictionary alloc] init];
                [dict setObject:strInstallerLocalUrl forKey:@"local_installer_sign"];
                [dict setObject:strOwnerLocalUrl forKey:@"local_owner_sign"];
                [[NSNotificationCenter defaultCenter] postNotificationName:@"setSignaturePathsforInspections" object:dict];
            }
            else
            {
                NSString * requestStr =[NSString stringWithFormat:@"Update 'tbl_uninstall'  set 'local_owner_sign' =\"%@\", 'local_installer_sign' = \"%@\" where id ='%@'",strOwnerLocalUrl,strInstallerLocalUrl,strInstallId];
                [[DataBaseManager dataBaseManager] execute:requestStr];

                NSMutableDictionary * dict = [[NSMutableDictionary alloc] init];
                [dict setObject:strInstallerLocalUrl forKey:@"local_installer_sign"];
                [dict setObject:strOwnerLocalUrl forKey:@"local_owner_sign"];
                [[NSNotificationCenter defaultCenter] postNotificationName:@"setSignaturePathsforUNInstalls" object:dict];
            }
        }
        else
        {
            NSTimeInterval timeStamp = [[NSDate date] timeIntervalSince1970];
            NSNumber *timeStampObj = [NSNumber numberWithInteger: timeStamp];
            int randomID = arc4random() % 9000 + 1000;

            NSString * imageName = [NSString stringWithFormat:@"/%@-ownsign-%@%d.jpg",serverType,timeStampObj,randomID];
            strOwnerLocalUrl = [self SaveSigntoDoc:imageName withFolder:folderName :ownerSignImgView];
            
            NSString * imageNameInstaller = [NSString stringWithFormat:@"/%@-instsign-%@%d.jpg",serverType,timeStampObj,randomID];
            strInstallerLocalUrl = [self SaveSigntoDoc:imageNameInstaller withFolder:folderName :installerSignImgView];
            
            if ([strFromView isEqualToString:@"Install"])
            {
                NSString * requestStr =[NSString stringWithFormat:@"Update 'tbl_install'  set 'local_owner_sign' =\"%@\", 'local_installer_sign' = \"%@\" where id ='%@'",strOwnerLocalUrl,strInstallerLocalUrl,strInstallId];
                [[DataBaseManager dataBaseManager] execute:requestStr];
                
                NSMutableDictionary * dict = [[NSMutableDictionary alloc] init];
                [dict setObject:strInstallerLocalUrl forKey:@"local_installer_sign"];
                [dict setObject:strOwnerLocalUrl forKey:@"local_owner_sign"];
                [[NSNotificationCenter defaultCenter] postNotificationName:@"setSignaturePathsforInstalls" object:dict];
            }
            else if ([strFromView isEqualToString:@"Inspection"])
            {
                NSString * requestStr =[NSString stringWithFormat:@"Update 'tbl_inspection'  set 'local_owner_sign' =\"%@\", 'local_installer_sign' = \"%@\" where id ='%@'",strOwnerLocalUrl,strInstallerLocalUrl,strInstallId];
                [[DataBaseManager dataBaseManager] execute:requestStr];
                
                NSMutableDictionary * dict = [[NSMutableDictionary alloc] init];
                [dict setObject:strInstallerLocalUrl forKey:@"local_installer_sign"];
                [dict setObject:strOwnerLocalUrl forKey:@"local_owner_sign"];
                [[NSNotificationCenter defaultCenter] postNotificationName:@"setSignaturePathsforInspections" object:dict];
            }
            else
            {
                NSString * requestStr =[NSString stringWithFormat:@"Update 'tbl_uninstall'  set 'local_owner_sign' =\"%@\", 'local_installer_sign' = \"%@\" where id ='%@'",strOwnerLocalUrl,strInstallerLocalUrl,strInstallId];
                [[DataBaseManager dataBaseManager] execute:requestStr];
                
                NSMutableDictionary * dict = [[NSMutableDictionary alloc] init];
                [dict setObject:strInstallerLocalUrl forKey:@"local_installer_sign"];
                [dict setObject:strOwnerLocalUrl forKey:@"local_owner_sign"];
                [[NSNotificationCenter defaultCenter] postNotificationName:@"setSignaturePathsforUNInstalls" object:dict];
            }            
        }
        [self.navigationController popViewControllerAnimated:YES];
    }
}
-(NSString *)SaveSigntoDoc:(NSString *)strPath withFolder:(NSString *)folderName :(UIImageView *)imgView
{
    NSString * imageName = strPath;
    imageName = [imageName stringByReplacingOccurrencesOfString:@" " withString:@""];
    
    NSString * stringPath = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)objectAtIndex:0]stringByAppendingPathComponent:folderName]; // New Folder is your folder name
    NSError *error = nil;
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:stringPath])        [[NSFileManager defaultManager] createDirectoryAtPath:stringPath withIntermediateDirectories:NO attributes:nil error:&error];
    NSString *fileName = [stringPath stringByAppendingString:imageName];
    NSData *data = UIImageJPEGRepresentation(imgView.image, 0.2);
    [data writeToFile:fileName atomically:YES];
    
    return imageName;
}

-(void)btnConditions
{
    
}
-(void)signatureBtnClick:(id)sender
{
    [signbkView removeFromSuperview];
    signbkView = [[UIView alloc] init];
    signbkView.frame=CGRectMake(0, 0, DEVICE_WIDTH, DEVICE_HEIGHT);
    signbkView.backgroundColor = [UIColor blackColor];
    signbkView.alpha = 0.5l;
    signbkView.hidden = YES;
    [self.view addSubview:signbkView];
    
    [PJSignbckView removeFromSuperview];
    PJSignbckView = [[UIView alloc] init];
    PJSignbckView.frame= CGRectMake(10, DEVICE_HEIGHT, DEVICE_WIDTH-20, 288);
    PJSignbckView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:PJSignbckView];
    
    [signatureView removeFromSuperview];
    signatureView= [[PJRSignatureView alloc] initWithFrame:CGRectMake(0,0,DEVICE_WIDTH-0,288)];
    signatureView.tag = [sender tag];
    signatureView.backgroundColor = [UIColor whiteColor];
    [PJSignbckView addSubview:signatureView];
    
    UIImageView * backLbl = [[UIImageView alloc] init];
    backLbl.frame = CGRectMake(0, 0, DEVICE_WIDTH, 44);
    backLbl.backgroundColor = [UIColor clearColor];
    backLbl.image = [UIImage imageNamed:@"BTN.png"];
    [PJSignbckView addSubview:backLbl];
    
    UIButton * clearBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    clearBtn.frame = CGRectMake(0, 0, 100, 44);
    [clearBtn setTitle:@"Clear" forState:UIControlStateNormal];
    clearBtn.titleLabel.font = [UIFont fontWithName:CGRegular size:textSize];
    [clearBtn addTarget:self action:@selector(btnSignClearClick) forControlEvents:UIControlEventTouchUpInside];
    [PJSignbckView addSubview:clearBtn];
    
    UIButton * cancelBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    cancelBtn.frame = CGRectMake(signatureView.frame.size.width-110, 0, 100, 44);
    [cancelBtn setTitle:@"Cancel" forState:UIControlStateNormal];
    cancelBtn.titleLabel.font = [UIFont fontWithName:CGRegular size:textSize];
    [cancelBtn addTarget:self action:@selector(btnSignCancelClick) forControlEvents:UIControlEventTouchUpInside];
    [PJSignbckView addSubview:cancelBtn];
    
    UIButton * doneBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    doneBtn.frame = CGRectMake(0, 244, DEVICE_WIDTH, 44);
    [doneBtn setTitle:@"Save" forState:UIControlStateNormal];
    doneBtn.tag = [sender tag];
    [doneBtn addTarget:self action:@selector(btnSignSaveClick:) forControlEvents:UIControlEventTouchUpInside];
    doneBtn.backgroundColor = globalAppColor;
    [doneBtn setBackgroundImage:[UIImage imageNamed:@"BTN.png"] forState:UIControlStateNormal];
    [PJSignbckView addSubview:doneBtn];
    
    [signatureView clearSignature];
    
    [UIView transitionWithView:PJSignbckView duration:0.4
                       options:UIViewAnimationOptionCurveEaseIn
                    animations:^{
                        [PJSignbckView setFrame:CGRectMake(0, (DEVICE_HEIGHT-288)/2, DEVICE_WIDTH, 288)];
                    }
                    completion:^(BOOL finished) {
                    }];
}
-(void)btnSignSaveClick:(id)sender
{
    if ([sender tag]==1)
    {
        imgSign = [signatureView getSignatureImage];
        if (imgSign)
        {
            signbkView.hidden = YES;
            ownerSignImgView.image = imgSign;
            [btnOwner setTitle:@"" forState:UIControlStateNormal];
            [self ShowPicker:NO andView:PJSignbckView];
        }
        else
        {
            [btnOwner setImage:nil forState:UIControlStateNormal];
            URBAlertView * alert =[[URBAlertView alloc] initWithTitle:ALERT_TITLE message:@"Please get Owner's sign." cancelButtonTitle:OK_BTN otherButtonTitles:nil, nil];
            [alert showWithAnimation:URBAlertAnimationTopToBottom];
        }
    }
    else
    {
        imgSign = [signatureView getSignatureImage];
        if (imgSign)
        {
            signbkView.hidden = YES;
            installerSignImgView.image = imgSign;
            [btnInstaller setTitle:@"" forState:UIControlStateNormal];
            [self ShowPicker:NO andView:PJSignbckView];
        }
        else
        {
            [btnOwner setImage:nil forState:UIControlStateNormal];
            URBAlertView * alert =[[URBAlertView alloc] initWithTitle:ALERT_TITLE message:@"Please make Installer's sign." cancelButtonTitle:OK_BTN otherButtonTitles:nil, nil];
            [alert showWithAnimation:URBAlertAnimationTopToBottom];
        }
    }
}
-(void)btnSignClearClick
{
    [signatureView clearSignature];
}
-(void)btnSignCancelClick
{
    signbkView.hidden = YES;
    [self ShowPicker:NO andView:PJSignbckView];
}
-(void)agreeClick:(id)sender
{
    if ([sender tag]==1)
    {
        if (isOwnerAgreed)
        {
            imgCheckOwner.image = [UIImage imageNamed:@"checkEmpty.png"];
            isOwnerAgreed = NO;
        }
        else
        {
            imgCheckOwner.image = [UIImage imageNamed:@"checked.png"];
            isOwnerAgreed = YES;
        }
    }
    else
    {
        if (isInstallerAgreed)
        {
            imgCheckInstaller.image = [UIImage imageNamed:@"checkEmpty.png"];
            isInstallerAgreed = NO;
        }
        else
        {
            imgCheckInstaller.image = [UIImage imageNamed:@"checked.png"];
            isInstallerAgreed = YES;
        }
    }
    
}
-(void)ownerSignClick
{
    
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
-(BOOL)validationforThirdVieww
{
    BOOL isAvail = NO;
    
    if (ownerSignImgView.image == nil)
    {
        [self showMessagewithText:@"Please get Owner's sign."];
    }
    else if (isOwnerAgreed == NO)
    {
        [self showMessagewithText:@"Please agree to Succorfish T&C's"];
    }
    else if (installerSignImgView.image == nil)
    {
        [self showMessagewithText:@"Please make Installer's sign."];
    }
    else if (isInstallerAgreed == NO)
    {
        if ([strFromView isEqualToString:@"Install"])
        {
            [self showMessagewithText:@"Installer must confirm that the Install has been completed as per Succorfish instructions."];
        }
        else
        {
            [self showMessagewithText:@"Installer must confirm that the Uninstall has been completed as per Succorfish instructions."];
        }
    }
    else
    {
        isAvail = YES;
    }
    return isAvail;
}
-(void)showMessagewithText:(NSString *)strText
{
    URBAlertView *alertView = [[URBAlertView alloc] initWithTitle:ALERT_TITLE message:strText cancelButtonTitle:OK_BTN otherButtonTitles: nil, nil];
    
    [alertView setMessageFont:[UIFont fontWithName:CGRegular size:14]];
    [alertView setHandlerBlock:^(NSInteger buttonIndex, URBAlertView *alertView) {
        [alertView hideWithCompletionBlock:^{
        }];
    }];
    [alertView showWithAnimation:URBAlertAnimationTopToBottom];
    if (IS_IPHONE_X){[alertView showWithAnimation:URBAlertAnimationDefault];}
}
- (NSString *)documentsPathForFileName:(NSString *)name
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask, YES);
    NSString *documentsPath = [paths objectAtIndex:0];
    return [documentsPath stringByAppendingPathComponent:name];
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
