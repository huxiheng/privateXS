//
//  TodayViewController.h
//  XieshiPrivate
//
//  Created by 明溢 李 on 14-12-26.
//  Copyright (c) 2014年 Lessu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LSPagedTableViewController.h"
#import "LSRefreashableViewController.h"

@interface TodayViewController : LSPagedTableViewController
@property (weak, nonatomic) IBOutlet UIView *mapContainview;
@property (nonatomic, strong)NSDictionary  *dicDataForToday;
@property (weak, nonatomic) IBOutlet UIView *GLYTodayBottomView;
@property (weak, nonatomic) IBOutlet UIButton *btnDiTu;
@property (weak, nonatomic) IBOutlet UIButton *btnList;
@property (weak, nonatomic) IBOutlet UIView *viewRefreshPage;
@property (weak, nonatomic) IBOutlet UIButton *btnUpForPage;
@property (weak, nonatomic) IBOutlet UIButton *btnDownForPage;

///加载查询用户位置和周围距离的属性
@property (nonatomic,strong)CLLocation *userLocation;
@property (nonatomic,copy)NSString  *distance;
@property (nonatomic,copy)NSString *userLocationString;
@property (nonatomic,copy)NSString *strProjectName;

///用于进行延迟加载的图标
@property (nonatomic, strong)UIImageView  *loadImageView;

///设置一个属性标记btnSearch的title
@property (nonatomic,copy)NSString *btnSearchTitle;
//@property (nonatomic,copy)NSMutableDictionary *params;//搜索特定条件的参数

///保存当前页面和总页面的数量
@property (nonatomic, copy)NSString *currentPageCount;
@property (nonatomic,copy)NSString *totalPageConunts;
@end
