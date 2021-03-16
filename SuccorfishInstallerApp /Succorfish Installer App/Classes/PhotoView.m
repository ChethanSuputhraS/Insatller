//
//  PhotoView.m
//  Succorfish Installer App
//
//  Created by stuart watts on 27/02/2018.
//  Copyright © 2018 Kalpesh Panchasara. All rights reserved.
//

#import "PhotoView.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import <Photos/Photos.h>
#import "ALAssetsLibrary+CustomPhotoAlbum.h"
#import "TGRImageViewController.h"
#import "TGRImageZoomAnimationController.h"

@interface PhotoView ()<UIImagePickerControllerDelegate,UIActionSheetDelegate,UINavigationControllerDelegate,UIViewControllerTransitioningDelegate>
{
    int selectedTag, deleteIndex;
    NSMutableArray * imgsArr, * dbImgArr;
    AsyncImageView * photo1, * photo2, * photo3, * photo4;
    
    UIButton * btnDel1, * btnDel2, * btnDel3, * btnDel4;
    UIButton * btnPhoto1, * btnPhoto2, * btnPhoto3, * btnPhoto4;
    UIImageView * selectedIMg;
    BOOL isEdited;
    int textSize;
}
@property (strong, atomic) ALAssetsLibrary* library;

@end

@implementation PhotoView
@synthesize installId,isfromInspection;

- (void)viewDidLoad
{
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

    imgsArr = [[NSMutableArray alloc] init];
    dbImgArr = [[NSMutableArray alloc] init];
    
    if ([installId isEqualToString:@"NA"])
    {
        
    }
    else
    {
        if (isfromInspection)
        {
            NSString * strQuery = [NSString stringWithFormat:@"select * from tbl_inspection_photo where insp_local_id = '%@' and insp_photo_user_id = '%@'",installId,CURRENT_USER_ID];
            [[DataBaseManager dataBaseManager] execute:strQuery resultsArray:dbImgArr];
        }
        else
        {
            NSString * strQuery = [NSString stringWithFormat:@"select * from tbl_installer_photo where inst_local_id = '%@' and inst_photo_user_id = '%@'",installId,CURRENT_USER_ID];
            [[DataBaseManager dataBaseManager] execute:strQuery resultsArray:dbImgArr];
        }
        if ([dbImgArr count]>0)
        {
            isEdited = YES;
        }
    }

    [self setNavigationViewFrames];
    [self setMainViewContent];
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

#pragma mark - Set Frames
-(void)setNavigationViewFrames
{
    UIView * viewHeader = [[UIView alloc] initWithFrame:CGRectMake(0, 0, DEVICE_WIDTH, 64)];
    [viewHeader setBackgroundColor:[UIColor blackColor]];
    [self.view addSubview:viewHeader];
    
    UILabel * lblTitle = [[UILabel alloc] initWithFrame:CGRectMake(50, 20, DEVICE_WIDTH-100, 44)];
    [lblTitle setBackgroundColor:[UIColor clearColor]];
    [lblTitle setText:@"Installation Photos"];
    [lblTitle setTextAlignment:NSTextAlignmentCenter];
    [lblTitle setFont:[UIFont fontWithName:CGRegular size:textSize]];
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
        btnBack.frame = CGRectMake(0, 20, 70, 84);
        btnSave.frame = CGRectMake(DEVICE_WIDTH-50, 40, 50, 44);
    }
    
    if (isfromInspection)
    {
        [lblTitle setText:@"Inspection Photos"];
    }
}
-(void)setMainViewContent
{
    UILabel * lblTitle = [[UILabel alloc] initWithFrame:CGRectMake(15, 64, DEVICE_WIDTH-15, 60)];
    [lblTitle setBackgroundColor:[UIColor clearColor]];
    [lblTitle setText:@"Please add photos of your installed devices.  \nMaximum upload limit is 4."];
    lblTitle.numberOfLines = 0;
    [lblTitle setFont:[UIFont fontWithName:CGRegular size:textSize-1]];
    [lblTitle setTextColor:[UIColor whiteColor]];
    [self.view addSubview:lblTitle];
    
    if (isfromInspection)
    {
        [lblTitle setText:@"Please add photos of your inspected devices.  \nMaximum upload limit is 4."];
    }
    UILabel * lblLine = [[UILabel alloc] initWithFrame:CGRectMake(15, 65+64, DEVICE_WIDTH-15, 1)];
    lblLine.backgroundColor = [UIColor lightGrayColor];
    [self.view addSubview:lblLine];

    UIView * backView = [[UIView alloc] init];
    backView.frame = CGRectMake(15, 160, DEVICE_WIDTH-30, DEVICE_HEIGHT-160);
    [self.view addSubview:backView];
    
    if (IS_IPHONE_X)
    {
        lblTitle.frame = CGRectMake(15, 88, DEVICE_WIDTH-15, 60);
        lblLine.frame = CGRectMake(15, 65+88, DEVICE_WIDTH-15, 1);
        backView.frame = CGRectMake(15, 160+24, DEVICE_WIDTH-30, DEVICE_HEIGHT-160-24);
    }
    else if (IS_IPHONE_4)
    {
        lblTitle.backgroundColor = [UIColor clearColor];
        lblTitle.frame = CGRectMake(15, 64, DEVICE_WIDTH-15, 40);
        lblLine.frame = CGRectMake(15, 103, DEVICE_WIDTH-15, 1);
        backView.frame = CGRectMake(15, 120, DEVICE_WIDTH-30, DEVICE_HEIGHT-120);
    }
    
    int xx = 15;
    int yy = 0;
    int cnt = 0;
    int vWidth = (DEVICE_WIDTH/2)-30;
    int vHeighth = (DEVICE_WIDTH/2)-30;

    for (int i=0; i<2; i++)
    {
        xx=0;
        for (int j=0; j<2; j++)
        {
            if (cnt==0)
            {
                UILabel * lblTitle = [[UILabel alloc] initWithFrame:CGRectMake(xx+5, yy, vWidth-10, 30)];
                [lblTitle setBackgroundColor:[UIColor clearColor]];
                [lblTitle setText:@"Device Image"];
                [lblTitle setFont:[UIFont fontWithName:CGRegular size:textSize-1]];
                [lblTitle setTextColor:[UIColor whiteColor]];
                lblTitle.textAlignment = NSTextAlignmentCenter;
                [backView addSubview:lblTitle];

                photo1 = [[AsyncImageView alloc] init];
                photo1.frame =CGRectMake(xx + 0, yy+30, vWidth, vHeighth);
                [self setImageProperties:photo1 withtag:cnt];
                [backView addSubview:photo1];

                btnPhoto1 = [UIButton buttonWithType:UIButtonTypeCustom];
                [self setPhotoButtonProperties:btnPhoto1 withtag:cnt withFrame:CGRectMake(xx + 0, yy+30, vWidth, vHeighth)];
                [backView addSubview:btnPhoto1];
                
                btnDel1 = [UIButton buttonWithType:UIButtonTypeCustom];
                [self setDeleteButtonProperties:btnDel1 withtag:cnt withFrame:CGRectMake(xx+vWidth-60, yy+30, 60, 60)];
                [backView addSubview:btnDel1];
            }
            else if (cnt==1)
            {
                UILabel * lblTitle = [[UILabel alloc] initWithFrame:CGRectMake(xx+5, yy, vWidth-10, 30)];
                [lblTitle setBackgroundColor:[UIColor clearColor]];
                [lblTitle setText:@"Device location"];
                [lblTitle setFont:[UIFont fontWithName:CGRegular size:textSize-1]];
                [lblTitle setTextColor:[UIColor whiteColor]];
                lblTitle.textAlignment = NSTextAlignmentCenter;
                [backView addSubview:lblTitle];
                
                photo2 = [[AsyncImageView alloc] init];
                photo2.frame =CGRectMake(xx + 0, yy+30, vWidth, vHeighth);
                [self setImageProperties:photo2 withtag:cnt];
                [backView addSubview:photo2];
                
                btnPhoto2 = [UIButton buttonWithType:UIButtonTypeCustom];
                [self setPhotoButtonProperties:btnPhoto2 withtag:cnt withFrame:CGRectMake(xx + 0, yy+30, vWidth, vHeighth)];
                [backView addSubview:btnPhoto2];
                
                btnDel2 = [UIButton buttonWithType:UIButtonTypeCustom];
                [self setDeleteButtonProperties:btnDel2 withtag:cnt withFrame:CGRectMake(xx+vWidth-60, yy+30, 60, 60)];
                [backView addSubview:btnDel2];

            }
            else if (cnt==2)
            {
                UILabel * lblTitle = [[UILabel alloc] initWithFrame:CGRectMake(xx+5, yy, vWidth-10, 30)];
                [lblTitle setBackgroundColor:[UIColor clearColor]];
                [lblTitle setText:@"Power connection"];
                [lblTitle setFont:[UIFont fontWithName:CGRegular size:textSize-2]];
                [lblTitle setTextColor:[UIColor whiteColor]];
                lblTitle.textAlignment = NSTextAlignmentCenter;
                lblTitle.numberOfLines = 0;
                [backView addSubview:lblTitle];
                
                photo3 = [[AsyncImageView alloc] init];
                photo3.frame =CGRectMake(xx + 0, 30+yy, vWidth, vHeighth);
                [self setImageProperties:photo3 withtag:cnt];
                [backView addSubview:photo3];
                
                btnPhoto3 = [UIButton buttonWithType:UIButtonTypeCustom];
                [self setPhotoButtonProperties:btnPhoto3 withtag:cnt withFrame:CGRectMake(xx + 0, 30+yy, vWidth, vHeighth)];
                [backView addSubview:btnPhoto3];
                
                btnDel3 = [UIButton buttonWithType:UIButtonTypeCustom];
                [self setDeleteButtonProperties:btnDel3 withtag:cnt withFrame:CGRectMake(xx+vWidth-60, 30+yy, 60, 60)];
                [backView addSubview:btnDel3];
            }
            else if (cnt==3)
            {
                UILabel * lblTitle = [[UILabel alloc] initWithFrame:CGRectMake(xx+5, yy, vWidth-10, 30)];
                [lblTitle setBackgroundColor:[UIColor clearColor]];
                [lblTitle setText:@"Asset Image"];
                [lblTitle setFont:[UIFont fontWithName:CGRegular size:textSize-1]];
                [lblTitle setTextColor:[UIColor whiteColor]];
                lblTitle.textAlignment = NSTextAlignmentCenter;
                [backView addSubview:lblTitle];
                
                photo4 = [[AsyncImageView alloc] init];
                photo4.frame =CGRectMake(xx + 0, 30+yy, vWidth, vHeighth);
                [self setImageProperties:photo4 withtag:cnt];
                [backView addSubview:photo4];
                
                btnPhoto4 = [UIButton buttonWithType:UIButtonTypeCustom];
                [self setPhotoButtonProperties:btnPhoto4 withtag:cnt withFrame:CGRectMake(xx + 0, 30+yy, vWidth, vHeighth)];
                [backView addSubview:btnPhoto4];
                
                btnDel4 = [UIButton buttonWithType:UIButtonTypeCustom];
                [self setDeleteButtonProperties:btnDel4 withtag:cnt withFrame:CGRectMake(xx+vWidth-60, 30+yy, 60, 60)];
                [backView addSubview:btnDel4];
            }

            xx = vWidth + xx + 30;
            cnt = cnt +1;
        }
        yy = yy + vHeighth + 30 + 30 ;
    }
    
    for (int k=0; k<[dbImgArr count]; k++)
    {
        NSString * filePath = [self documentsPathForFileName:[NSString stringWithFormat:@"InstallPhotos/%@",[[dbImgArr objectAtIndex:k] valueForKey:@"inst_photo_local_url"]]];
        if (isfromInspection)
        {
             filePath = [self documentsPathForFileName:[NSString stringWithFormat:@"InspectionPhotos/%@",[[dbImgArr objectAtIndex:k] valueForKey:@"insp_photo_local_url"]]];
        }
        NSData *pngData = [NSData dataWithContentsOfFile:filePath];
        UIImage * mainImage = [UIImage imageWithData:pngData];

        UIImage * image = [self scaleMyImage:mainImage];

        if ([[[dbImgArr objectAtIndex:k] valueForKey:@"photo_type"] isEqualToString:@"1"])
        {
            photo1.image = nil;
            photo1.contentMode = UIViewContentModeScaleAspectFit;
            [AsyncImageLoader sharedLoader].cache = nil;
            photo1.image = image;
            btnDel1.hidden = NO;
            [imgsArr addObject:@"22"];
        }
        else if ([[[dbImgArr objectAtIndex:k] valueForKey:@"photo_type"] isEqualToString:@"2"])
        {
            photo2.image = nil;
            photo2.contentMode = UIViewContentModeScaleAspectFit;
            [AsyncImageLoader sharedLoader].cache = nil;
            photo2.image = image;
            btnDel2.hidden = NO;
            [imgsArr addObject:@"23"];
        }
        else if ([[[dbImgArr objectAtIndex:k] valueForKey:@"photo_type"] isEqualToString:@"3"])
        {
            photo3.image = nil;
            photo3.contentMode = UIViewContentModeScaleAspectFit;
            [AsyncImageLoader sharedLoader].cache = nil;
            photo3.image = image;
            btnDel3.hidden = NO;
            [imgsArr addObject:@"24"];
        }
        else if ([[[dbImgArr objectAtIndex:k] valueForKey:@"photo_type"] isEqualToString:@"4"])
        {
            photo4.image = nil;
            photo4.contentMode = UIViewContentModeScaleAspectFit;
            [AsyncImageLoader sharedLoader].cache = nil;
            photo4.image = image;
            btnDel4.hidden = NO;
            [imgsArr addObject:@"25"];
        }
    }
}
- (NSString *)documentsPathForFileName:(NSString *)name
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask, YES);
    NSString *documentsPath = [paths objectAtIndex:0];
    
    return [documentsPath stringByAppendingPathComponent:name];
}
-(void)btnBackClick
{
    [self.navigationController popViewControllerAnimated:YES];
}
-(void)btnSaveClick
{
    if ([imgsArr count]>=4)
    {
        if (isfromInspection)
        {
            [self deleteImagesForInspections];
        }
        else
        {
            [self deleteImagesForInstall];
        }
        installPhotoCounts = [NSString stringWithFormat:@"%lu",(unsigned long)[imgsArr count]];
        
        if (isfromInspection)
        {
            [self saveImagetoDocumentDirectoryforInspection];
        }
        else
        {
            [self saveImagetoDocumentDirectoryforInstalls];
        }
        
       
    }
    else
    {
        URBAlertView *alertView = [[URBAlertView alloc] initWithTitle:ALERT_TITLE message:@"Please add all 4 photos." cancelButtonTitle:@"OK" otherButtonTitles: nil, nil];
        [alertView setMessageFont:[UIFont fontWithName:CGRegular size:12]];
        [alertView setHandlerBlock:^(NSInteger buttonIndex, URBAlertView *alertView) {
            [alertView hideWithCompletionBlock:^{
                
            }];
        }];
          [alertView showWithAnimation:Alert_Animation_Type];
        if (IS_IPHONE_X) {[alertView showWithAnimation:URBAlertAnimationDefault];}
    }
}

-(void)setImageProperties:(AsyncImageView *)imgView withtag:(int)tagValue
{
    imgView.contentMode = UIViewContentModeScaleToFill;
    imgView.tag = 22+tagValue;
    imgView.image = [UIImage imageNamed:@"addphotos.png"];
    imgView.backgroundColor = [UIColor blackColor];
    imgView.layer.cornerRadius = 12;
    imgView.layer.masksToBounds = YES;
    
    UIBezierPath *shadowPath = [UIBezierPath bezierPathWithRect:imgView.bounds];
    imgView.layer.masksToBounds = NO;
    imgView.layer.shadowColor = [UIColor whiteColor].CGColor;
    imgView.layer.shadowOffset = CGSizeMake(0.0f, 1.0f);
    imgView.layer.shadowOpacity = 0.5f;
    imgView.layer.shadowPath = shadowPath.CGPath;
}

-(void)setPhotoButtonProperties:(UIButton *)btnPhoto withtag:(int)tagValue withFrame:(CGRect)btnFrame
{
    [btnPhoto addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
    btnPhoto.tag = tagValue;
    btnPhoto.frame = btnFrame;
    btnPhoto.backgroundColor = [UIColor clearColor];
}

-(void)setDeleteButtonProperties:(UIButton *)btndelete withtag:(int)tagValue withFrame:(CGRect)btnFrame
{
    [btndelete addTarget:self action:@selector(btnDelteClick:) forControlEvents:UIControlEventTouchUpInside];
    btndelete.tag = 100+tagValue;
    [btndelete setImage:[UIImage imageNamed:@"deleteP.png"] forState:UIControlStateNormal];
    btndelete.backgroundColor = [UIColor clearColor];
    btndelete.hidden = YES;
    btndelete.frame = btnFrame;
    btndelete.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
    btndelete.contentVerticalAlignment = UIControlContentVerticalAlignmentTop;
}
-(void)btnClick:(id)sender
{
    selectedTag = [sender tag];
    if (selectedTag==0)
    {
        selectedIMg = photo1;
    }
    else if (selectedTag ==1)
    {
        selectedIMg = photo2;
    }
    else if (selectedTag ==2)
    {
        selectedIMg = photo3;
    }
    else if (selectedTag ==3)
    {
        selectedIMg = photo4;
    }
    
    selectedIMg.contentMode = UIViewContentModeScaleAspectFit;
    
    UIImagePickerController *imagePicker =[[UIImagePickerController alloc] init];
    imagePicker.delegate = self;
    
    NSString * strMsg = [NSString stringWithFormat:@"Set Installation Photo"];
    if (isfromInspection)
    {
        strMsg = [NSString stringWithFormat:@"Set Inspection Photo"];
    }
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Installer App" message:strMsg preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:ACTION_TAKE_PHOTO style:UIAlertActionStyleDefault handler:^(UIAlertAction * action){
        // Ok action example
        if ([UIImagePickerController isSourceTypeAvailable: UIImagePickerControllerSourceTypeCamera])
        {
            imagePicker.sourceType=UIImagePickerControllerSourceTypeCamera;
            [self presentViewController:imagePicker animated:YES completion:nil];
        }
        else
        {
            imagePicker.sourceType=UIImagePickerControllerSourceTypePhotoLibrary;
            [self presentViewController:imagePicker animated:YES completion:nil];
        }
    }];
    UIAlertAction *otherAction = [UIAlertAction actionWithTitle:ACTION_LIBRARY_PHOTO style:UIAlertActionStyleDefault handler:^(UIAlertAction * action){
        // Other action
        imagePicker.sourceType=UIImagePickerControllerSourceTypePhotoLibrary;
        [self presentViewController:imagePicker animated:YES completion:nil];
    }];
    UIAlertAction *viwePhotoAction = [UIAlertAction actionWithTitle:@"View Photo" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action){
        // Other action
        TGRImageViewController *viewController = [[TGRImageViewController alloc] initWithImage:selectedIMg.image];
        viewController.transitioningDelegate = self;
        [self presentViewController:viewController animated:YES completion:nil];
        [self presentViewController:imagePicker animated:YES completion:nil];
    }];
    
    [alert addAction:okAction];
    [alert addAction:otherAction];
    if ([imgsArr containsObject:[NSString stringWithFormat:@"%d",selectedTag+22]])
    {
        [alert addAction:viwePhotoAction];
    }
    UIAlertAction * cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction * action){
        // Other action
        [self dismissViewControllerAnimated:YES completion:nil];
    }];
    [alert addAction:cancelAction];

    [self presentViewController:alert animated:YES completion:nil];
//    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(100.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//        [alert dismissViewControllerAnimated:YES completion:^{
//            // do something ?
//        }];
//    });
    
    
}
-(void)btnDelteClick:(id)sender
{
    deleteIndex = [sender tag];
    
    URBAlertView *alertView = [[URBAlertView alloc] initWithTitle:ALERT_TITLE message:@"Are you sure want to delete this photo?" cancelButtonTitle:@"Yes" otherButtonTitles: @"No", nil];
    [alertView setMessageFont:[UIFont fontWithName:CGRegular size:12]];
    [alertView setHandlerBlock:^(NSInteger buttonIndex, URBAlertView *alertView) {
        [alertView hideWithCompletionBlock:^{
            if (buttonIndex==0)
            {
                if ([imgsArr containsObject:[NSString stringWithFormat:@"%d",deleteIndex+22-100]])
                {
                    [imgsArr removeObject:[NSString stringWithFormat:@"%d",deleteIndex+22-100]];
                }
                AsyncImageView * syncImg = (AsyncImageView *)[self.view viewWithTag:22+deleteIndex-100];
                syncImg.image = [UIImage imageNamed:@"addphotos.png"];
                UIButton * btnDlt = (UIButton *)[self.view viewWithTag:deleteIndex];
                btnDlt.hidden = YES;
            }
        }];
    }];
      [alertView showWithAnimation:Alert_Animation_Type];
        if (IS_IPHONE_X) {[alertView showWithAnimation:URBAlertAnimationDefault];}
}


-(UIImage *)scaleMyImage:(UIImage *)newImg
{
    UIGraphicsBeginImageContext(CGSizeMake(newImg.size.width/2,newImg.size.height/2));
    
    [newImg drawInRect: CGRectMake(0, 0, newImg.size.width/2, newImg.size.height/2)];
    
    UIImage        *smallImage = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return smallImage;
}
#pragma mark - imagepickerdelegates
- (void)imagePickerController:(UIImagePickerController*)picker didFinishPickingMediaWithInfo:(NSDictionary*)info
{
    UIImage  * getedMg = [info objectForKey:UIImagePickerControllerOriginalImage];
    self.library = [[ALAssetsLibrary alloc] init];
    
    UIImage * Pickrimage = [self scaleMyImage:getedMg];

    if(Pickrimage != nil)
    {
        if (selectedTag==0)
        {
            photo1.image = nil;
            photo1.contentMode = UIViewContentModeScaleAspectFit;
            [AsyncImageLoader sharedLoader].cache = nil;
            photo1.image = Pickrimage;
            btnDel1.hidden = NO;
        }
        else if (selectedTag==1)
        {
            photo2.image = nil;
            photo2.contentMode = UIViewContentModeScaleAspectFit;
            [AsyncImageLoader sharedLoader].cache = nil;
            photo2.image = Pickrimage;
            btnDel2.hidden = NO;
        }
        else if (selectedTag==2)
        {
            photo3.image = nil;
            photo3.contentMode = UIViewContentModeScaleAspectFit;
            [AsyncImageLoader sharedLoader].cache = nil;
            photo3.image = Pickrimage;
            btnDel3.hidden = NO;
        }
        else if (selectedTag==3)
        {
            photo4.image = nil;
            photo4.contentMode = UIViewContentModeScaleAspectFit;
            [AsyncImageLoader sharedLoader].cache = nil;
            photo4.image = Pickrimage;
            btnDel4.hidden = NO;
        }
        
//        AsyncImageView *syncimg = (AsyncImageView *)[self.view viewWithTag:selectedTag+22];
//        syncimg.image = nil;
//        syncimg.contentMode = UIViewContentModeScaleAspectFit;
//        [AsyncImageLoader sharedLoader].cache = nil;
//        syncimg.image = Pickrimage;
    }
    [self dismissViewControllerAnimated:YES completion:nil];

    if (![imgsArr containsObject:[NSString stringWithFormat:@"%d",selectedTag+22]])
    {
        [imgsArr addObject:[NSString stringWithFormat:@"%d",selectedTag+22]];
    }
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - UIViewControllerTransitioningDelegate methods

- (id<UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented presentingController:(UIViewController *)presenting sourceController:(UIViewController *)source {
    if ([presented isKindOfClass:TGRImageViewController.class])
    {
        return [[TGRImageZoomAnimationController alloc] initWithReferenceImageView:selectedIMg];
    }
    return nil;
}

- (id<UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed
{
    if ([dismissed isKindOfClass:TGRImageViewController.class])
    {
        return [[TGRImageZoomAnimationController alloc] initWithReferenceImageView:selectedIMg];
    }
    
    return nil;
}

-(void)saveImagetoDocumentDirectoryforInstalls
{
    UIImageView * saveImage;
    if ([imgsArr count]==0)
    {
        [self.navigationController popViewControllerAnimated:YES];
    }
    else
    {
        if ([imgsArr count]>0)
        {
            int nmbr = [[imgsArr objectAtIndex:0] intValue];
            NSString * strPhotoType;
            NSString * strTypeName;

            if (nmbr == 22)
            {
                saveImage = photo1;
                strPhotoType= @"1";
                strTypeName = @"device";
            }
            else if (nmbr == 23)
            {
                saveImage = photo2;
                strPhotoType= @"2";
                strTypeName = @"location";
            }
            else if (nmbr == 24)
            {
                saveImage = photo3;
                strPhotoType= @"3";
                strTypeName = @"power";
            }
            else if (nmbr == 25)
            {
                saveImage = photo4;
                strPhotoType= @"4";
                strTypeName = @"asset";
            }
            
            NSString * imageName;

            {
                NSTimeInterval timeStamp = [[NSDate date] timeIntervalSince1970];
                NSNumber *timeStampObj = [NSNumber numberWithInteger: timeStamp];
                
                int randomID = arc4random() % 9000 + 1000;
                imageName = [NSString stringWithFormat:@"/install-%@-%d%@.jpg", strTypeName,randomID,timeStampObj];
                if (isfromInspection)
                {
                    imageName = [NSString stringWithFormat:@"/inspection-%@-%d%@.jpg", strTypeName,randomID,timeStampObj];
                }
                imageName = [imageName stringByReplacingOccurrencesOfString:@" " withString:@""];
                
                NSString * requestStr =[NSString stringWithFormat:@"insert into 'tbl_installer_photo'('inst_photo_local_url','inst_local_id','photo_type','is_sync','inst_photo_user_id') values(\"%@\",\"%@\",\"%@\",'0',\"%@\")",imageName,installId,strPhotoType,CURRENT_USER_ID];
                [[DataBaseManager dataBaseManager] execute:requestStr];
            }
        
            NSString * stringPath = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)objectAtIndex:0]stringByAppendingPathComponent:@"InstallPhotos"]; // New Folder is your folder name
            NSError *error = nil;
            
            if (![[NSFileManager defaultManager] fileExistsAtPath:stringPath])        [[NSFileManager defaultManager] createDirectoryAtPath:stringPath withIntermediateDirectories:NO attributes:nil error:&error];
            NSString *fileName = [stringPath stringByAppendingString:imageName];
            NSData *data = UIImageJPEGRepresentation(saveImage.image, 0.2);
            [data writeToFile:fileName atomically:YES];
            UIImage * mainImage = [UIImage imageWithData:data];
            UIImageWriteToSavedPhotosAlbum(mainImage, nil, nil, nil);

            NSMutableDictionary * dict = [[NSMutableDictionary alloc] init];
            [dict setObject:strPhotoType forKey:@"type"];
            [dict setObject:imageName forKey:@"localUrl"];

            if ([installImgArr count]==0 || installImgArr == nil)
            {
                installImgArr = [[NSMutableArray alloc] init];
            }
            [installImgArr addObject:dict];
            [imgsArr removeObjectAtIndex:0];
            

            [self saveImagetoDocumentDirectoryforInstalls];
        }
    }
}

-(void)saveImagetoDocumentDirectoryforInspection
{
//    NSLog(@"Img Count=%d",[imgsArr count]);
    UIImageView * saveImage;
    if ([imgsArr count]==0)
    {
        [self.navigationController popViewControllerAnimated:YES];
    }
    else
    {
        if ([imgsArr count]>0)
        {
            int nmbr = [[imgsArr objectAtIndex:0] intValue];
            NSString * strPhotoType;
            NSString * strTypeName;
            
            if (nmbr == 22)
            {
                saveImage = photo1;
                strPhotoType= @"1";
                strTypeName = @"device";
            }
            else if (nmbr == 23)
            {
                saveImage = photo2;
                strPhotoType= @"2";
                strTypeName = @"location";
            }
            else if (nmbr == 24)
            {
                saveImage = photo3;
                strPhotoType= @"3";
                strTypeName = @"power";
            }
            else if (nmbr == 25)
            {
                saveImage = photo4;
                strPhotoType= @"4";
                strTypeName = @"asset";
            }
            
            NSString * imageName;
      
            {
                NSTimeInterval timeStamp = [[NSDate date] timeIntervalSince1970];
                NSNumber *timeStampObj = [NSNumber numberWithInteger: timeStamp];
                
                int randomID = arc4random() % 9000 + 1000;
                imageName = [NSString stringWithFormat:@"/Inspection-%@-%d%@.jpg", strTypeName,randomID,timeStampObj];
                imageName = [imageName stringByReplacingOccurrencesOfString:@" " withString:@""];
                
                NSString * requestStr =[NSString stringWithFormat:@"insert into 'tbl_inspection_photo'('insp_photo_local_url','insp_local_id','photo_type','is_sync','insp_photo_user_id') values(\"%@\",\"%@\",\"%@\",'0',\"%@\")",imageName,installId,strPhotoType,CURRENT_USER_ID];
                [[DataBaseManager dataBaseManager] execute:requestStr];
            }
            
            NSString * stringPath = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)objectAtIndex:0]stringByAppendingPathComponent:@"InspectionPhotos"]; // New Folder is your folder name
            NSError *error = nil;
            
            if (![[NSFileManager defaultManager] fileExistsAtPath:stringPath])        [[NSFileManager defaultManager] createDirectoryAtPath:stringPath withIntermediateDirectories:NO attributes:nil error:&error];
            NSString *fileName = [stringPath stringByAppendingString:imageName];
            NSData *data = UIImageJPEGRepresentation(saveImage.image, 0.2);
            [data writeToFile:fileName atomically:YES];
            
            NSMutableDictionary * dict = [[NSMutableDictionary alloc] init];
            [dict setObject:strPhotoType forKey:@"type"];
            [dict setObject:imageName forKey:@"localUrl"];
            
            if ([installImgArr count]==0 || installImgArr == nil)
            {
                installImgArr = [[NSMutableArray alloc] init];
            }
            [installImgArr addObject:dict];
            [imgsArr removeObjectAtIndex:0];
            
            
            [self saveImagetoDocumentDirectoryforInspection];
        }
    }
}
-(void)deleteImagesForInstall
{
    for (int i =0; i<[dbImgArr count]; i++)
    {
        NSFileManager *fileManager = [NSFileManager defaultManager];
        NSString *filePath = [self documentsPathForFileName:[NSString stringWithFormat:@"InstallPhotos/%@",[[dbImgArr objectAtIndex:i] valueForKey:@"inst_photo_local_url"]]];
        NSError *error;
       [fileManager removeItemAtPath:filePath error:&error];
    }
    NSString * strDelete = [NSString stringWithFormat:@"delete from tbl_installer_photo where inst_local_id = %@ and inst_photo_user_id = '%@'",installId,CURRENT_USER_ID];
    [[DataBaseManager dataBaseManager] execute:strDelete];
}
-(void)deleteImagesForInspections
{
    for (int i =0; i<[dbImgArr count]; i++)
    {
        NSFileManager *fileManager = [NSFileManager defaultManager];
        NSString *filePath = [self documentsPathForFileName:[NSString stringWithFormat:@"InspectionPhotos/%@",[[dbImgArr objectAtIndex:i] valueForKey:@"insp_photo_local_url"]]];
        NSError *error;
        [fileManager removeItemAtPath:filePath error:&error];
    }
    NSString * strDelete = [NSString stringWithFormat:@"delete from tbl_inspection_photo where insp_local_id = %@ and insp_photo_user_id = '%@'",installId,CURRENT_USER_ID];
    [[DataBaseManager dataBaseManager] execute:strDelete];
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
