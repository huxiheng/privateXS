//
//  labelSysterm.m
//  XieshiPrivate
//
//  Created by Tesiro on 16/11/12.
//  Copyright © 2016年 Lessu. All rights reserved.
//

#import "labelSysterm.h"

@implementation labelSysterm

-(void)awakeFromNib{
    [super awakeFromNib];
    self.frame= CGRectMake(kscaleDeviceWidth(self.frame.origin.x) , kscaleIphone6DeviceHeight(self.frame.origin.y),kscaleDeviceWidth( self.frame.size.width), kscaleIphone6DeviceHeight(self.frame.size.height));
}

@end
