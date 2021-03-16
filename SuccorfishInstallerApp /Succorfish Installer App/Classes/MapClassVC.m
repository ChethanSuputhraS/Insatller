//
//  MapClassVC.m
//  Succorfish Installer App
//
//  Created by stuart watts on 14/03/2018.
//  Copyright © 2018 Kalpesh Panchasara. All rights reserved.
//

#import "MapClassVC.h"
#define span1 5000

@interface MapClassVC ()

@end

@implementation MapClassVC
@synthesize detailsDict,isfromLastWayPOint;
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
    [lblTitle setText:@"Location on Map"];
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
    
    if (IS_IPHONE_X)
    {
        viewHeader.frame = CGRectMake(0, 0, DEVICE_WIDTH, 88);
        lblTitle.frame = CGRectMake(50, 40, DEVICE_WIDTH-100, 44);
        backImg.frame = CGRectMake(10, 12+44, 12, 20);
        btnBack.frame = CGRectMake(0, 0, 70, 88);
        [self setMainViewContent:88];
    }
    else
    {
        [self setMainViewContent:64];
    }
}

-(void)btnBackClick
{
    [self.navigationController popViewControllerAnimated:YES];
}
-(void)setMainViewContent:(int)yyHeight
{
    detailsMap = [[MKMapView alloc] initWithFrame:CGRectMake(0, yyHeight, DEVICE_WIDTH, DEVICE_HEIGHT-yyHeight)];
    [detailsMap setMapType:MKMapTypeStandard];
    detailsMap.delegate = self;
    detailsMap.showsUserLocation = YES;
    [self.view addSubview:detailsMap];
    
     if (IS_IPHONE_X)
     {
         detailsMap.frame = CGRectMake(0, yyHeight, DEVICE_WIDTH, DEVICE_HEIGHT-yyHeight-45);
     }
    
    CLLocationCoordinate2D coordinate1;
    coordinate1.latitude = [[detailsDict valueForKey:@"latitude"] floatValue];
    coordinate1.longitude =  [[detailsDict valueForKey:@"longitude"] doubleValue];
    
    
    CLLocationCoordinate2D location=CLLocationCoordinate2DMake(coordinate1.latitude, coordinate1.longitude);
    
    MKCoordinateRegion region=MKCoordinateRegionMakeWithDistance(location,span1 ,span1);
    MKCoordinateRegion adjustedRegion = [detailsMap regionThatFits:region];
    [detailsMap setRegion:adjustedRegion animated:YES];
    
    
    MKPlacemark *mPlacemark = [[MKPlacemark alloc] initWithCoordinate:coordinate1 addressDictionary:nil];
    CustomAnnotation *annotation = [[CustomAnnotation alloc] initWithPlacemark:mPlacemark];
    [detailsMap addAnnotation:annotation];
}
- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>)annotation
{
    if ([annotation isKindOfClass:[MKUserLocation class]])
    {
        return nil;
    }
    else if ([annotation isKindOfClass:[CustomAnnotation class]]) // use whatever annotation class you used when creating the annotation
    {
        static NSString * const identifier = @"CustomAnnotation";
        
        MKAnnotationView* annotationView = [mapView dequeueReusableAnnotationViewWithIdentifier:identifier];
        if (annotationView) {
            annotationView.annotation = annotation;
        }else        {
            annotationView = [[MKAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:identifier];
        }
        annotationView.canShowCallout = NO;
        annotationView.image = [UIImage imageNamed:@"map_pin.png"];
        
        return annotationView;
    }
    return nil;
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
