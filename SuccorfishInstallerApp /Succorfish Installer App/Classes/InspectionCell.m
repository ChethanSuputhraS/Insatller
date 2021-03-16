//
//  InspectionCell.m
//  Succorfish Installer App
//
//  Created by srivatsa s pobbathi on 15/03/19.
//  Copyright © 2019 Kalpesh Panchasara. All rights reserved.
//

#import "InspectionCell.h"

@implementation InspectionCell
@synthesize lblName,lblValue,lblLine,imgArrow,txtName,txtZip,lblZipLine,lblLastReport,lblPositionMsg;
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
        int textHeight = 54;
        
        if (IS_IPHONE_4 || IS_IPHONE_5)
        {
            textSize = 14;
            textHeight = 49;
            
        }
        
        lblName = [[UILabel alloc] init];
        lblName.frame = CGRectMake(10,20, (DEVICE_WIDTH/2)-10, 30);
        lblName.backgroundColor = [UIColor clearColor];
        lblName.textAlignment = NSTextAlignmentLeft;
        lblName.textColor = [UIColor lightGrayColor];
        lblName.font = [UIFont fontWithName:CGRegular size:textSize];
        [self.contentView addSubview:lblName];
        
        lblValue = [[UILabel alloc] init];
        lblValue.frame = CGRectMake((DEVICE_WIDTH/2)-15,20, (DEVICE_WIDTH/2)-10, 30);
        lblValue.backgroundColor = [UIColor clearColor];
        lblValue.textAlignment = NSTextAlignmentRight;
        lblValue.textColor = [UIColor whiteColor];
        lblValue.font = [UIFont fontWithName:CGBold size:textSize];
        [self.contentView addSubview:lblValue];
        
        lblLine = [[UILabel alloc] init];
        lblLine.frame = CGRectMake(5,54, DEVICE_WIDTH-5, 1);
        lblLine.backgroundColor = [UIColor lightGrayColor];
        [self.contentView addSubview:lblLine];
        
        imgArrow = [[UIImageView alloc]init];
        imgArrow.frame = CGRectMake(DEVICE_WIDTH-15, 27.5, 9, 15);
        imgArrow.image = [UIImage imageNamed:@"arrow.png"];
        [self.contentView addSubview:imgArrow];
        
        txtName = [[UIFloatLabelTextField alloc]init];
        txtName.textAlignment = NSTextAlignmentLeft;
        txtName.backgroundColor = UIColor.clearColor;
        //        txtName.frame = CGRectMake(10, 10, DEVICE_WIDTH-20, textHeight-5);
        [txtName setTranslatesAutoresizingMaskIntoConstraints:NO];
        txtName.autocorrectionType = UITextAutocorrectionTypeNo;
        txtName.floatLabelPassiveColor = [UIColor lightGrayColor];
        txtName.floatLabelActiveColor = [UIColor lightGrayColor];
        txtName.textColor = UIColor.whiteColor;
        txtName.font = [UIFont fontWithName:CGRegular size:textSize];
        txtName.delegate = self;
        txtName.returnKeyType = UIReturnKeyNext;
        [self.contentView addSubview:txtName];
        
        
        txtZip = [[UIFloatLabelTextField alloc]init];
        txtZip.textAlignment = NSTextAlignmentLeft;
        txtZip.backgroundColor = UIColor.clearColor;
        //        txtZip.frame = CGRectMake((DEVICE_WIDTH/2)+10, 10, (DEVICE_WIDTH/2)-20, textHeight-5);
        [txtZip setTranslatesAutoresizingMaskIntoConstraints:NO];
        txtZip.autocorrectionType = UITextAutocorrectionTypeNo;
        txtZip.floatLabelPassiveColor = [UIColor lightGrayColor];
        txtZip.floatLabelActiveColor = [UIColor lightGrayColor];
        txtZip.font = [UIFont fontWithName:CGRegular size:textSize];
        txtZip.textColor = UIColor.whiteColor;
        txtZip.delegate = self;
        txtZip.placeholder = @"ZipCode";
        txtZip.returnKeyType = UIReturnKeyNext;
        [self.contentView addSubview:txtZip];
        
        lblZipLine = [[UILabel alloc] init];
        //        lblZipLine.frame = CGRectMake((DEVICE_WIDTH/2)+10,textHeight, (DEVICE_WIDTH/2)-20, 1);
        lblZipLine.backgroundColor = [UIColor lightGrayColor];
        [self.contentView addSubview:lblZipLine];
        
        lblPositionMsg = [[UILabel alloc] init];
        lblPositionMsg.frame = CGRectMake(110, 0, DEVICE_WIDTH-20-110, textHeight-15);
        lblPositionMsg.backgroundColor = [UIColor clearColor];
        lblPositionMsg.numberOfLines = 2;
        lblPositionMsg.font = [UIFont fontWithName:CGRegular size:textSize-2];
        lblPositionMsg.textColor = [UIColor whiteColor];
        lblPositionMsg.userInteractionEnabled = YES;
        lblPositionMsg.textAlignment = NSTextAlignmentCenter;
        lblPositionMsg.text = @"Waiting for status";
        lblPositionMsg.hidden = true;
        [self.contentView addSubview:lblPositionMsg];
        
        
        lblLastReport = [[UILabel alloc] init];
        lblLastReport.frame = CGRectMake(110, textHeight-17, DEVICE_WIDTH-20-110, 15);
        lblLastReport.backgroundColor = [UIColor clearColor];
        lblLastReport.numberOfLines = 1;
        lblLastReport.font = [UIFont fontWithName:CGRegular size:textSize-3];
        lblLastReport.textColor = [UIColor whiteColor];
        lblLastReport.userInteractionEnabled = true;
        lblLastReport.textAlignment = NSTextAlignmentCenter;
        lblLastReport.hidden = true;
        lblLastReport.text = @"Last Report : NA";
        [self.contentView addSubview:lblLastReport];
    }
    return self;
}
@end
