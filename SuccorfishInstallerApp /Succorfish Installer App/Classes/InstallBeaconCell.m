//
//  InstallBeaconCell.m
//  Succorfish Installer App
//
//  Created by Ashwin on 7/16/20.
//  Copyright © 2020 Kalpesh Panchasara. All rights reserved.
//

#import "InstallBeaconCell.h"

@implementation InstallBeaconCell
@synthesize lblScanDevice,lblBeaconType,lblLine,imgArrow,txtName,lblBeacon,lblScanTxt,lblAssestGroup,lblBatteryType,lbltxtName,lblGroupAsset,lblBecTypeName,lblCellBgColor,lblAsset;
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
        int textHeight = 49;
        
        if (IS_IPHONE_4 || IS_IPHONE_5)
        {
            textSize = 14;
            textHeight = 44;
            
        }
        
        lblCellBgColor = [[UILabel alloc] initWithFrame:CGRectMake(0, 5, DEVICE_WIDTH, 45)];
        [lblCellBgColor setBackgroundColor:[UIColor blackColor]];
        lblCellBgColor.alpha = 0.5;
        lblCellBgColor.hidden = true;
        [self.contentView addSubview:lblCellBgColor];
        
         lblScanDevice = [[UILabel alloc] init];
         lblScanDevice.frame = CGRectMake(10,0, DEVICE_WIDTH, 45);
         lblScanDevice.backgroundColor = [UIColor clearColor];
         lblScanDevice.textAlignment = NSTextAlignmentLeft;
         lblScanDevice.textColor = [UIColor lightGrayColor];
         lblScanDevice.font = [UIFont fontWithName:CGRegular size:textSize];
         lblScanDevice.text = @"Becon Device ID";
         lblScanDevice.textColor = [UIColor lightGrayColor];
         lblScanDevice.hidden = true;
         [self.contentView addSubview:lblScanDevice];
         
         lblLine = [[UILabel alloc] init];
         lblLine.frame = CGRectMake(5,45, DEVICE_WIDTH-10, 0.5);
         lblLine.backgroundColor = [UIColor lightGrayColor];
         lblLine.hidden = true;
         [self.contentView addSubview:lblLine];
         
         imgArrow = [[UIImageView alloc]init];
         imgArrow.frame = CGRectMake(DEVICE_WIDTH-15, 18, 9, 15);
         imgArrow.image = [UIImage imageNamed:@"arrow.png"];
         imgArrow.hidden = TRUE; 
         [self.contentView addSubview:imgArrow];
         
         txtName = [[UIFloatLabelTextField alloc] initWithFrame:CGRectMake(5, 0, DEVICE_WIDTH, 50)];
         txtName.placeholder = @"Beacon Name";
         txtName.autocapitalizationType = UITextAutocapitalizationTypeNone;
         txtName.autocorrectionType = UITextAutocorrectionTypeNo;
         txtName.textColor = [UIColor whiteColor];
         [txtName setFont:[UIFont fontWithName:CGRegular size:textSize]];
         [APP_DELEGATE getPlaceholderText:txtName andColor:UIColor.lightGrayColor];
         txtName.hidden = TRUE;
         txtName.returnKeyType  = UIReturnKeyDone;
         [self.contentView addSubview:txtName];
        
        lbltxtName = [[UILabel alloc] init];
        lbltxtName.frame = CGRectMake(10,0, DEVICE_WIDTH-20, 50);
        lbltxtName.backgroundColor = [UIColor clearColor];
        lbltxtName.textAlignment = NSTextAlignmentRight;
        lbltxtName.font = [UIFont fontWithName:CGBold size:textSize];
        lbltxtName.hidden = true;
        lbltxtName.text = @"";
        lbltxtName.textColor = [UIColor lightGrayColor];
        [self.contentView addSubview:lbltxtName];

        
        lblBeaconType = [[UILabel alloc] init];
        lblBeaconType.frame = CGRectMake(10,0, DEVICE_WIDTH-20, 50);
        lblBeaconType.backgroundColor = [UIColor clearColor];
        lblBeaconType.textAlignment = NSTextAlignmentLeft;
        lblBeaconType.textColor = [UIColor lightGrayColor];
        lblBeaconType.font = [UIFont fontWithName:CGRegular size:textSize];
        lblBeaconType.text = @"Beacon Type";
        lblBeaconType.textColor = [UIColor lightGrayColor];
        lblBeaconType.hidden = true;
        [self.contentView addSubview:lblBeaconType];
        
        lblAsset = [[UILabel alloc] init];
        lblAsset.frame = CGRectMake(10,0, DEVICE_WIDTH-35, 50);
        lblAsset.backgroundColor = [UIColor clearColor];
        lblAsset.textAlignment = NSTextAlignmentLeft;
        lblAsset.textColor = [UIColor lightGrayColor];
        lblAsset.font = [UIFont fontWithName:CGRegular size:textSize];
        lblAsset.textColor = [UIColor lightGrayColor];
        lblAsset.hidden = true;
        [self.contentView addSubview:lblAsset];
        
        
        lblBecTypeName = [[UILabel alloc] init];
        lblBecTypeName.frame = CGRectMake(5,0, DEVICE_WIDTH-20, 50);
        lblBecTypeName.backgroundColor = [UIColor clearColor];
        lblBecTypeName.textAlignment = NSTextAlignmentRight;
        lblBecTypeName.font = [UIFont fontWithName:CGBold size:textSize-1];
        lblBecTypeName.text = @"";
        lblBecTypeName.textColor = [UIColor whiteColor];
        lblBecTypeName.hidden = true;
        [self.contentView addSubview:lblBecTypeName];
        
        lblBeacon = [[UILabel alloc] init]; //it is cahnge to Battery Type
        lblBeacon.frame = CGRectMake(10,0, DEVICE_WIDTH, 50);
        lblBeacon.backgroundColor = [UIColor clearColor];
        lblBeacon.textAlignment = NSTextAlignmentLeft;
        lblBeacon.font = [UIFont fontWithName:CGRegular size:textSize];
        lblBeacon.hidden = true;
        lblBeacon.text = @"Battery Type";
        lblBeacon.textColor = [UIColor lightGrayColor];
        [self.contentView addSubview:lblBeacon];
        
        lblScanTxt = [[UILabel alloc] init];
        lblScanTxt.frame = CGRectMake(5,5, DEVICE_WIDTH-20, 45);
        lblScanTxt.backgroundColor = [UIColor clearColor];
        lblScanTxt.textAlignment = NSTextAlignmentRight;
        lblScanTxt.font = [UIFont fontWithName:CGBoldItalic size:textSize];
        lblScanTxt.hidden = true;
        lblScanTxt.text = @"";
        lblScanTxt.textColor = [UIColor whiteColor];
        [self.contentView addSubview:lblScanTxt];
        

        lblAssestGroup = [[UILabel alloc] init]; //
        lblAssestGroup.frame = CGRectMake(DEVICE_WIDTH/2.4,0, DEVICE_WIDTH/1.9, 50);
        lblAssestGroup.backgroundColor = [UIColor clearColor];
        lblAssestGroup.textAlignment = NSTextAlignmentRight;
        lblAssestGroup.font = [UIFont fontWithName:CGBold size:textSize];
        lblAssestGroup.hidden = true;
        lblAssestGroup.text = @"";
        lblAssestGroup.textColor = [UIColor whiteColor];
        [self.contentView addSubview:lblAssestGroup];
        
        lblBatteryType = [[UILabel alloc] init];
        lblBatteryType.frame = CGRectMake(0,0, DEVICE_WIDTH-20, 50);
        lblBatteryType.backgroundColor = [UIColor clearColor];
        lblBatteryType.textAlignment = NSTextAlignmentRight;
        lblBatteryType.font = [UIFont fontWithName:CGBold size:textSize];
        lblBatteryType.hidden = true;
        lblBatteryType.text = @"Group Count";
        lblBatteryType.textColor = [UIColor whiteColor];
        [self.contentView addSubview:lblBatteryType];
        
        lblGroupAsset = [[UILabel alloc] init];
        lblGroupAsset.frame = CGRectMake(10,0, DEVICE_WIDTH, 50);
        lblGroupAsset.backgroundColor = [UIColor clearColor];
        lblGroupAsset.textAlignment = NSTextAlignmentLeft;
        lblGroupAsset.font = [UIFont fontWithName:CGRegular size:textSize];
        lblGroupAsset.hidden = true;
        lblGroupAsset.text = @"Asset/Asset Group";
        lblGroupAsset.textColor = [UIColor lightGrayColor];
        [self.contentView addSubview:lblGroupAsset];
        


            }
            return self;
        }
@end
