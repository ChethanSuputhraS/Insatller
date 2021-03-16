//
//  SSCheckMark.h
//  AdvisorTLC
//
//  Created by Oneclick IT on 9/2/16.
//  Copyright © 2016 One Click IT Consultancy Pvt Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM( NSUInteger, SSCheckMarkStyle )
{
    SSCheckMarkStyleOpenCircle,
    SSCheckMarkStyleGrayedOut
};


@interface SSCheckMark : UIView


@property (readwrite) bool checked;
@property (readwrite) SSCheckMarkStyle checkMarkStyle;
@end
