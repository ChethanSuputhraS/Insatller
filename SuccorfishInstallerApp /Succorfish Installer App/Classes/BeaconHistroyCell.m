//
//  BeaconHistroyCell.m
//  Succorfish Installer App
//
//  Created by Ashwin on 8/4/20.
//  Copyright © 2020 Kalpesh Panchasara. All rights reserved.
//

#import "BeaconHistroyCell.h"

@implementation BeaconHistroyCell
@synthesize lblbeaconNum,lblCellBgColor,lblDate,lblAsset,lblName,lblBeconType,lblBatteryType,lblStatus,lblCellBgLine;


- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self)
    {
    
        int textSize = 16;

        lblCellBgColor = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, DEVICE_WIDTH, 75)];
        [lblCellBgColor setBackgroundColor:[UIColor blackColor]];
        lblCellBgColor.alpha = 0.5;
        lblCellBgColor.hidden = false;
        [self.contentView addSubview:lblCellBgColor];
        
        lblCellBgLine = [[UILabel alloc] initWithFrame:CGRectMake(0, 74.5, DEVICE_WIDTH, 0.5)];
        [lblCellBgLine setBackgroundColor:[UIColor lightGrayColor]];
        [self.contentView addSubview:lblCellBgLine];
        
         lblbeaconNum = [[UILabel alloc] init];
         lblbeaconNum.frame = CGRectMake(5,0, DEVICE_WIDTH, 30);
         lblbeaconNum.backgroundColor = [UIColor clearColor];
         lblbeaconNum.textAlignment = NSTextAlignmentLeft;
         lblbeaconNum.font = [UIFont fontWithName:CGRegular size:textSize];
         lblbeaconNum.text = @"";
         lblbeaconNum.textColor = [UIColor whiteColor];
         lblbeaconNum.hidden = false;
         [self.contentView addSubview:lblbeaconNum];

        
        lblDate = [[UILabel alloc] init];
        lblDate.frame = CGRectMake(0,0, DEVICE_WIDTH-5, 30);
        lblDate.backgroundColor = [UIColor clearColor];
        lblDate.textAlignment = NSTextAlignmentRight;
        lblDate.font = [UIFont fontWithName:CGRegular size:textSize];
        lblDate.text = @"";
        lblDate.textColor = [UIColor lightGrayColor];
        lblDate.hidden = false;
        [self.contentView addSubview:lblDate];
            int yy = 25;

        lblName = [[UILabel alloc] init];
        lblName.frame = CGRectMake(5,yy, DEVICE_WIDTH/1.5, 30);
        lblName.backgroundColor = [UIColor clearColor];
        lblName.textAlignment = NSTextAlignmentLeft;
        lblName.font = [UIFont fontWithName:CGRegular size:textSize-2];
        lblName.text = @"";
        lblName.textColor = [UIColor lightGrayColor];
        lblName.hidden = false;
        [self.contentView addSubview:lblName];
        
        lblStatus = [[UILabel alloc] init];
        lblStatus.frame = CGRectMake(5,yy, DEVICE_WIDTH-10, 30);
        lblStatus.backgroundColor = [UIColor clearColor];
        lblStatus.textAlignment = NSTextAlignmentRight;
        lblStatus.font = [UIFont fontWithName:CGRegular size:textSize-2];
        lblStatus.text = @"";
        lblStatus.textColor = [UIColor lightGrayColor];
        lblStatus.hidden = false;
        [self.contentView addSubview:lblStatus];
        
      
        lblAsset = [[UILabel alloc] init];
        lblAsset.frame = CGRectMake(5,yy+25, DEVICE_WIDTH, 30);
        lblAsset.backgroundColor = [UIColor clearColor];
        lblAsset.textAlignment = NSTextAlignmentLeft;
        lblAsset.font = [UIFont fontWithName:CGRegular size:textSize-2];
        lblAsset.text = @"";
        lblAsset.textColor = [UIColor lightGrayColor];
        lblAsset.hidden = true;
        [self.contentView addSubview:lblAsset];
        
        lblBatteryType = [[UILabel alloc] init];
        lblBatteryType.frame = CGRectMake(5,yy+23, DEVICE_WIDTH-5, 30);
        lblBatteryType.backgroundColor = [UIColor clearColor];
        lblBatteryType.textAlignment = NSTextAlignmentLeft;
        lblBatteryType.font = [UIFont fontWithName:CGRegular size:textSize-2];
        lblBatteryType.text = @"";
        lblBatteryType.textColor = [UIColor lightGrayColor];
        lblBatteryType.hidden = false;
        [self.contentView addSubview:lblBatteryType];
        
        yy=yy+23;
        lblBeconType = [[UILabel alloc] init];
        lblBeconType.frame = CGRectMake(0,yy, DEVICE_WIDTH-5, 30);
        lblBeconType.backgroundColor = [UIColor clearColor];
        lblBeconType.textAlignment = NSTextAlignmentRight;
        lblBeconType.font = [UIFont fontWithName:CGRegular size:textSize-2];
        lblBeconType.text = @"";
        lblBeconType.textColor = [UIColor lightGrayColor];
        lblBeconType.hidden = false;
        [self.contentView addSubview:lblBeconType];
        


    }
    return self;
}
@end
