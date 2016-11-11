//
//  TodayUpAndDownPageView.h
//  XieshiPrivate
//
//  Created by Tesiro on 16/11/11.
//  Copyright © 2016年 Lessu. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol todayUpAndDownPageViewDelegate;
@interface TodayUpAndDownPageView : UIView
@property (weak, nonatomic) IBOutlet UILabel *labelText;
@property (nonatomic,assign)id <todayUpAndDownPageViewDelegate> delegate;

@property (nonatomic,copy)NSString *textLabel;
+ (instancetype)getUpAndDownView;
@end

@protocol todayUpAndDownPageViewDelegate <NSObject>

-(void)TodayUpAndDownPageView:(TodayUpAndDownPageView*)upAndDownView clickUpBtn:(id)sender;
-(void)TodayUpAndDownPageView:(TodayUpAndDownPageView*)upAndDownView clickDownBtn:(id)sender;

@end
