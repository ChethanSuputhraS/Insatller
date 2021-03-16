//
//  HistoryCustomCell.m
//  Succorfish Installer App
//
//  Created by stuart watts on 09/03/2018.
//  Copyright © 2018 Kalpesh Panchasara. All rights reserved.
//

#import "HistoryCustomCell.h"

@implementation HistoryCustomCell
@synthesize lblEMI,lblDate,lblVessel,lblDeviceType,lblRegi,lblBack,lblStatus,lblLine;
- (void)awakeFromNib
{
    [super awakeFromNib];
    // Initialization code
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self)
    {
        int textSize = 16;
        if (IS_IPHONE_4 || IS_IPHONE_5)
        {
            textSize = 14;
        }
        
        lblBack = [[UILabel alloc] initWithFrame:CGRectMake(0, 0,DEVICE_WIDTH,85)];
        lblBack.backgroundColor = [UIColor blackColor];
        lblBack.alpha = 0.7;
        [self.contentView addSubview:lblBack];
        
        
        lblStatus = [[UILabel alloc] initWithFrame:CGRectMake(DEVICE_WIDTH/2,5,DEVICE_WIDTH/2-5,25)];
        [lblStatus setTextColor:[UIColor redColor]];
        [lblStatus setBackgroundColor:[UIColor clearColor]];
        [lblStatus setTextAlignment:NSTextAlignmentRight];
        [lblStatus setFont:[UIFont fontWithName:CGBold size:textSize-1]];
        lblStatus.text = @"INCOMPLETE";
        [self.contentView addSubview:lblStatus];
        
        lblEMI = [[UILabel alloc] initWithFrame:CGRectMake(10, 5,DEVICE_WIDTH/2-10,25)];
        [lblEMI setTextColor:[UIColor whiteColor]];
        [lblEMI setBackgroundColor:[UIColor clearColor]];
        [lblEMI setTextAlignment:NSTextAlignmentLeft];
        [lblEMI setFont:[UIFont fontWithName:CGRegular size:textSize]];
        [self.contentView addSubview:lblEMI];
        
        lblVessel = [[UILabel alloc] initWithFrame:CGRectMake(10, 30,DEVICE_WIDTH/2-10,25)];
        [lblVessel setTextColor:[UIColor lightGrayColor]];
        [lblVessel setBackgroundColor:[UIColor clearColor]];
        [lblVessel setTextAlignment:NSTextAlignmentLeft];
        [lblVessel setFont:[UIFont fontWithName:CGRegular size:textSize-1]];
        [self.contentView addSubview:lblVessel];
        
        lblRegi = [[UILabel alloc] initWithFrame:CGRectMake(10, 55,DEVICE_WIDTH/2-10,25)];
        [lblRegi setTextColor:[UIColor lightGrayColor]];
        [lblRegi setBackgroundColor:[UIColor clearColor]];
        [lblRegi setTextAlignment:NSTextAlignmentLeft];
        [lblRegi setFont:[UIFont fontWithName:CGRegular size:textSize-1]];
        [self.contentView addSubview:lblRegi];
        
        lblDate = [[UILabel alloc] initWithFrame:CGRectMake(DEVICE_WIDTH/2, 30,DEVICE_WIDTH/2-5,50)];
        [lblDate setTextColor:[UIColor lightGrayColor]];
        [lblDate setBackgroundColor:[UIColor clearColor]];
        [lblDate setTextAlignment:NSTextAlignmentRight];
        lblDate.numberOfLines = 0;
        [lblDate setFont:[UIFont fontWithName:CGRegular size:textSize-1]];
        [self.contentView addSubview:lblDate];
        
        lblDeviceType = [[UILabel alloc] initWithFrame:CGRectMake(DEVICE_WIDTH/2, 5,DEVICE_WIDTH/2-5,25)];
        [lblDeviceType setTextColor:[UIColor lightGrayColor]];
        [lblDeviceType setBackgroundColor:[UIColor clearColor]];
        [lblDeviceType setTextAlignment:NSTextAlignmentRight];
        [lblDeviceType setFont:[UIFont fontWithName:CGRegular size:textSize-1]];
        [self.contentView addSubview:lblDeviceType];
        
        lblLine = [[UILabel alloc] initWithFrame:CGRectMake(0,84, DEVICE_WIDTH, 1)];
        [lblLine setBackgroundColor:[UIColor grayColor]];
        [self.contentView addSubview:lblLine];

//        lblEMI.text= @"1234567887654321";
//        lblVessel.text = @"Vessel Name ";
//        lblRegi.text = @"RAKL900 ";
//        lblDate.text = @"2018-08-09 10:00 AM";
//        lblDeviceType.text = @"SC2";
    }
    return self;

}
- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
