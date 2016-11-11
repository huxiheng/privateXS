//
//  TodayUpAndDownPageView.m
//  XieshiPrivate
//
//  Created by Tesiro on 16/11/11.
//  Copyright © 2016年 Lessu. All rights reserved.
//

#import "TodayUpAndDownPageView.h"

@implementation TodayUpAndDownPageView

-(void)setTextLabel:(NSString *)textLabel{
    self.labelText.text = textLabel;
}

+ (instancetype)getUpAndDownView
{
    return [[[NSBundle mainBundle] loadNibNamed:NSStringFromClass(self) owner:nil options:nil] firstObject];
}
- (IBAction)getUPPageData:(id)sender {
    if ([self.delegate respondsToSelector:@selector(TodayUpAndDownPageView:clickUpBtn:)]) {
        [self.delegate TodayUpAndDownPageView:self clickUpBtn:nil];
    }
}
- (IBAction)getDownPageData:(id)sender {
    if ([self.delegate respondsToSelector:@selector(TodayUpAndDownPageView:clickDownBtn:)]) {
        [self.delegate TodayUpAndDownPageView:self clickDownBtn:nil];
    }
}

@end
