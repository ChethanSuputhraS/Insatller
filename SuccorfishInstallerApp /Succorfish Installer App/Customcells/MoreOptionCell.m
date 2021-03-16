//
//  MoreOptionCell.m
//  AdvisorTLC
//
//  Created by Kalpesh Panchasara on 8/8/16.
//  Copyright © 2016 Kalpesh Panchasara. All rights reserved.
//

#import "MoreOptionCell.h"


@implementation MoreOptionCell

@synthesize imgIcon,imgCellBG,imgArrow,lblName,lblLineUpper,lblLineLower,lblEmail;

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self)
    {
        self.backgroundColor = [UIColor clearColor];
        
        imgCellBG = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.contentView.frame.size.width, 44)];
        [imgCellBG setBackgroundColor:[UIColor clearColor]];
//        [imgCellBG setAlpha:0.8];
        [self.contentView addSubview:imgCellBG];
        
        imgIcon = [[AsyncImageView alloc] initWithFrame:CGRectMake(10, 15, 20, 20)];
        [imgIcon setImage:[UIImage imageNamed:@"profile_1.jpg"]];
        [imgIcon setContentMode:UIViewContentModeScaleAspectFit];
        [self.contentView addSubview:imgIcon];
        
        
        lblName = [[UILabel alloc] initWithFrame:CGRectMake(50, 10,DEVICE_WIDTH-60,24)];
        [lblName setTextColor:[UIColor darkGrayColor]];
        [lblName setBackgroundColor:[UIColor clearColor]];
        [lblName setTextAlignment:NSTextAlignmentLeft];
        [lblName setFont:[UIFont systemFontOfSize:15 weight:UIFontWeightRegular]];
        [self.contentView addSubview:lblName];
        
        lblEmail = [[UILabel alloc] initWithFrame:CGRectMake(60, 34,DEVICE_WIDTH-60,24)];
        [lblEmail setTextColor:[UIColor darkGrayColor]];
        [lblEmail setBackgroundColor:[UIColor clearColor]];
        [lblEmail setTextAlignment:NSTextAlignmentLeft];
        [lblEmail setFont:[UIFont systemFontOfSize:13 weight:UIFontWeightLight]];
        [self.contentView addSubview:lblEmail];
        [lblEmail setHidden:YES];
        
        
        imgArrow = [[UIImageView alloc] initWithFrame:CGRectMake(DEVICE_WIDTH-30, 12, 20, 20)];
        [imgArrow setImage:[UIImage imageNamed:@"right_gray_arrow.png"]];
        [imgArrow setContentMode:UIViewContentModeScaleAspectFit];
        [self.contentView addSubview:imgArrow];
        
        lblLineUpper = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, DEVICE_WIDTH, 0.5)];
        [lblLineUpper setBackgroundColor:[UIColor lightGrayColor]];
//        [self.contentView addSubview:lblLineUpper];

        lblLineLower = [[UILabel alloc] initWithFrame:CGRectMake(15, 43, DEVICE_WIDTH-15, 0.5)];
        [lblLineLower setBackgroundColor:[UIColor lightGrayColor]];
//        [self.contentView addSubview:lblLineLower];
    }
    return self;
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
