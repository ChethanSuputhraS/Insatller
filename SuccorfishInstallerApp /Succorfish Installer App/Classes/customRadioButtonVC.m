//
//  customRadioButtonVC.m
//  Succorfish Installer App
//
//  Created by srivatsa s pobbathi on 01/04/19.
//  Copyright © 2019 Kalpesh Panchasara. All rights reserved.
//

#import "customRadioButtonVC.h"

@interface customRadioButtonVC ()

@end

@implementation customRadioButtonVC
@synthesize btnYes,btnNo,btnNA,viewRadio,imgRadioYes,imgRadioNA,imgRadioNo;

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    
    if (self) {
        [self setUpRadioView:frame];
    }
    
    return self;
}
#pragma mark - Set Up radio View
-(void)setUpRadioView:(CGRect)intFrame
{
    viewRadio = [[UIView alloc]initWithFrame:CGRectMake(0, 0, DEVICE_WIDTH, 40)];
    viewRadio.backgroundColor = UIColor.clearColor;
    viewRadio.userInteractionEnabled = true;
    [self addSubview:viewRadio];
    
    imgRadioYes = [[UIImageView alloc]init];
    imgRadioYes.image = [UIImage imageNamed:@"radiobuttonUnselected.png"];
    imgRadioYes.frame = CGRectMake(5, 15, 20, 20);
    [viewRadio addSubview:imgRadioYes];
    
    btnYes = [UIButton buttonWithType:UIButtonTypeCustom];
    [btnYes setTitle:@"       YES" forState:UIControlStateNormal];
    [btnYes setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    btnYes.frame = CGRectMake(0,0,DEVICE_WIDTH/3,50);
    btnYes.titleLabel.font =[UIFont fontWithName:CGRegular size:16];
    btnYes.backgroundColor = UIColor.clearColor;
    btnYes.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    [viewRadio addSubview:btnYes];
    
    imgRadioNo = [[UIImageView alloc]init];
    imgRadioNo.image = [UIImage imageNamed:@"radiobuttonSelected.png"];
    imgRadioNo.frame = CGRectMake(DEVICE_WIDTH/3, 15, 20, 20);
    [viewRadio addSubview:imgRadioNo];
    
    btnNo = [UIButton buttonWithType:UIButtonTypeCustom];
    [btnNo setTitle:@"      NO" forState:UIControlStateNormal];
    [btnNo setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    btnNo.frame = CGRectMake(DEVICE_WIDTH/3,0,DEVICE_WIDTH/3,50);
    btnNo.titleLabel.font =[UIFont fontWithName:CGRegular size:16];
    btnNo.backgroundColor = UIColor.clearColor;
    btnNo.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    [viewRadio addSubview:btnNo];
    
    imgRadioNA = [[UIImageView alloc]init];
    imgRadioNA.image = [UIImage imageNamed:@"radiobuttonUnselected.png"];
    imgRadioNA.frame = CGRectMake((DEVICE_WIDTH/3)*2, 15, 20, 20);
    [viewRadio addSubview:imgRadioNA];
    
    btnNA = [UIButton buttonWithType:UIButtonTypeCustom];
    [btnNA setTitle:@"      NA" forState:UIControlStateNormal];
    [btnNA setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    btnNA.frame = CGRectMake((DEVICE_WIDTH/3)*2,0,DEVICE_WIDTH/3,50);
    btnNA.titleLabel.font =[UIFont fontWithName:CGRegular size:16];
    btnNA.backgroundColor = UIColor.clearColor;
    btnNA.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    [viewRadio addSubview:btnNA];
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
