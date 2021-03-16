//
//  DetailCell.m
//  Succorfish Installer App
//
//  Created by stuart watts on 10/03/2018.
//  Copyright © 2018 Kalpesh Panchasara. All rights reserved.
//

#import "DetailCell.h"

@implementation DetailCell
@synthesize lblBack,lblHeader,lblValue,lblLine;

- (void)awakeFromNib {
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
        
        lblBack = [[UILabel alloc] initWithFrame:CGRectMake(0, 0,DEVICE_WIDTH,55)];
        lblBack.backgroundColor = [UIColor blackColor];
        lblBack.alpha = 0.7;
        [self.contentView addSubview:lblBack];
        
        lblHeader = [[UILabel alloc] initWithFrame:CGRectMake(10, 5,DEVICE_WIDTH,20)];
        [lblHeader setTextColor:[UIColor lightGrayColor]];
        [lblHeader setBackgroundColor:[UIColor clearColor]];
        [lblHeader setTextAlignment:NSTextAlignmentLeft];
        [lblHeader setFont:[UIFont fontWithName:CGRegular size:textSize-2]];
        [self.contentView addSubview:lblHeader];
        
        lblValue = [[UILabel alloc] initWithFrame:CGRectMake(10, 25,DEVICE_WIDTH,25)];
        [lblValue setTextColor:[UIColor whiteColor]];
        [lblValue setBackgroundColor:[UIColor clearColor]];
        [lblValue setTextAlignment:NSTextAlignmentLeft];
        [lblValue setFont:[UIFont fontWithName:CGRegular size:textSize]];
        [self.contentView addSubview:lblValue];
        
        lblLine = [[UILabel alloc] initWithFrame:CGRectMake(0,54, DEVICE_WIDTH, 1)];
        [lblLine setBackgroundColor:[UIColor grayColor]];
        [self.contentView addSubview:lblLine];

        lblHeader.text= @"1234567887654321";
        lblValue.text = @"Asset Name ";
    }
    return self;
    
}
- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
