//
//  TodayViewController.m
//  XieshiPrivate
//
//  Created by 明溢 李 on 14-12-26.
//  Copyright (c) 2014年 Lessu. All rights reserved.
//

#import "TodayViewController.h"
#import "TodayTableViewCell.h"
#import "TodayAdminTableViewCell.h"
#import "TodaySearchViewController.h"
#import "AppDelegate.h"
#import "TodayAdminDetailViewController.h"
#import "TodaySearchDayView.h"
#import "TodayStatisticsNewXHHeaderview.h"
#import "TodayStatisticsNewXHCell.h"
#import "TodayStatisticsMapVC.h"

#import "TodayUpAndDownPageView.h"


#define isManageUnit ([APP_DELEGATE.rootMainViewController.userPowerString characterAtIndex:0] == '1')
#define isAdmin isManageUnit
@interface TodayViewController ()<TodayAdminTableViewCellDelegate,TodayStatisticsStandardTimeDelegate,GetSearchDistanceAndUserLocationDelegate,todayUpAndDownPageViewDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property(nonatomic,retain) NSArray *list;
@property(nonatomic,retain) NSString* projectName;
@property(nonatomic,retain) NSString* projectArea;
@property (nonatomic, copy)NSString *strTimeToServer;
@property (nonatomic, assign)BOOL   isNotFirstIntoStatistics;
@property (nonatomic, strong)TodayStatisticsMapVC *todayStatisticsVC;

@property (nonatomic,strong)TodayUpAndDownPageView  *childUpAndDownPageView;

@end

@implementation TodayViewController
- (void)setdataForNav {
    self.titleForNav = @"统计详情";
}

- (void)viewDidLayoutSubviews{
    if (!isAdmin) {
        self.tableView.frame = CGRectMake(0, kscaleDeviceHeight(40), DeviceWidth, DeviceHeight-kscaleDeviceHeight(40)-kscaleDeviceHeight(64));
        
    }else{
         self.tableView.frame = CGRectMake(0, 0, DeviceWidth, DeviceHeight-64-kscaleIphone6DeviceHeight(50)-kscaleIphone6DeviceHeight(70));
        self.tableView.tableHeaderView.frame = CGRectZero;
        self.childUpAndDownPageView.frame = CGRectMake(0, 0, DeviceWidth, kscaleIphone6DeviceHeight(70));
        
    }
    
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [_todayStatisticsVC.mapView viewWillAppear];
    _todayStatisticsVC.mapView.delegate = _todayStatisticsVC;
    
    [self resetTodayStatisticsMapVCsearchBtnTitle:_btnSearchTitle];

}
-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
     [_todayStatisticsVC.mapView viewWillDisappear];
    _todayStatisticsVC.mapView.delegate = nil;
}

- (void)viewDidLoad {
    
    [super viewDidLoad];
    self.loadOnlyOnce = true;
    self.pageController.pageName = @"CurrentPageNo";
    self.pageController.stepName = @"PageSize";
    
    if (isAdmin) {
        self.tableView.allowsSelection = true;
    }

    UIBarButtonItem *barButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"icon_navigation_menu"] style:UIBarButtonItemStylePlain target:self action:@selector(leftBarButtonDidPress:)];
    self.navigationItem.leftBarButtonItem = barButton;  
    
    if (isAdmin) {
        UIBarButtonItem *barButton = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"GLYStatisticShuaXin"] style:UIBarButtonItemStylePlain target:self action:@selector(rightBarButtonDidPress:)];
        self.navigationItem.rightBarButtonItem = barButton;
        
        _todayStatisticsVC= [[TodayStatisticsMapVC alloc] init];
        _tableView.hidden = YES;
        _todayStatisticsVC.delegate = self;
        double longTitude = _todayStatisticsVC.locationUser.coordinate.longitude;
        double latitude = _todayStatisticsVC.locationUser.coordinate.latitude;
        self.userLocationString = [NSString stringWithFormat:@"%f,%f",longTitude,latitude];
        [_mapContainview addSubview: _todayStatisticsVC.view];
        APP_DELEGATE.rootMainViewController.enableGesture = false;
        _GLYTodayBottomView.frame = CGRectMake(0, DeviceHeight-kscaleIphone6DeviceHeight(50)-64, DeviceWidth, kscaleIphone6DeviceHeight(50));
        _viewRefreshPage.frame = CGRectMake(0, DeviceHeight-kscaleIphone6DeviceHeight(50)-64-kscaleIphone6DeviceHeight(70), DeviceWidth, kscaleIphone6DeviceHeight(70));
        self.childUpAndDownPageView = [TodayUpAndDownPageView getUpAndDownView];
        [_viewRefreshPage addSubview:self.childUpAndDownPageView];
        self.childUpAndDownPageView.delegate = self;
        _viewRefreshPage.hidden = YES;
    }

    if (!isAdmin) {
        TodaySearchDayView *todaySearchDayView = [[TodaySearchDayView alloc] initWithFrame:CGRectMake(0, -1, DeviceWidth, kscaleDeviceHeight(40))];
        [self.view addSubview:todaySearchDayView];
        todaySearchDayView.todaySearchDayDelegate = self;
        self.strTimeToServer = todaySearchDayView.strTimeToServer;
        
        [self.tableView registerClass:[TodayStatisticsNewXHHeaderview class] forHeaderFooterViewReuseIdentifier:[TodayStatisticsNewXHHeaderview viewIdentifier]];
        [self.tableView registerNib:[UINib nibWithNibName:@"TodayStatisticsNewXHHeaderview" bundle:nil] forHeaderFooterViewReuseIdentifier:[TodayStatisticsNewXHHeaderview viewIdentifier]];
        [self.tableView registerNib:[UINib nibWithNibName:@"TodayStatisticsNewXHCell" bundle:nil] forCellReuseIdentifier:[TodayStatisticsNewXHCell cellIdentifier]];
    }
}

- (void)leftBarButtonDidPress:(UIBarButtonItem *)sender{
    [APP_DELEGATE.rootMainViewController showLeft];
}

- (void)rightBarButtonDidPress:(UIBarButtonItem *)sender{
    if ([self.currentPageCount isEqualToString:self.totalPageConunts]) {
        [self.pageController refreshNoMerge];
        return;
    }
    [self.pageController nextPage];
}
#pragma mark ---- //网络请求参数----
- (void)toInitPageControllerWith:(NSString **) apiName params:(NSDictionary **)params{
    if(isManageUnit){
        *apiName = AFNETMETHOD_TS_TODAY_MANAGE_UNIT;
        *params  =  @{                             
                      @"Token" : [LoginUtil token],
                      @"Type"  : @(1),

                      @"CurrentLocation":self.userLocationString!=nil?self.userLocationString:@"",
                      @"DistanceRange":self.distance!=nil?self.distance:@"3",
                      @"ProjectName"	:self.projectName!=nil?self.projectName: @"",
//                      @"ProjectArea"	:@""
        };
    }else{
        *apiName = AFNETMETHOD_TS_TODAY;
        *params  =  @{                             
                      @"Token" : [LoginUtil token],
                      @"Type"  : @(0),
                      @"SummDate" : self.strTimeToServer != nil ?self.strTimeToServer:[self FirstIntTimeValueToServer]
                      };        
    }

}
- (void)afterInitPageController:(LSPageController *)pageController{
    pageController.apiClass = @"TSAFNet";
    dpBlockSelf;
    [pageController setPageinfoAdapter:^(NSDictionary *input, BOOL *success, NSArray *__autoreleasing * list, int *totalCount, NSString *__autoreleasing *errorMessage) {
        
        *success = [input[kAFNETConnectionStandartSuccessKey] boolValue];
        if (success) {
            if (isAdmin) {
               _self.pageController.isOnlyTenDataShow = YES;
                *list = input[kAFNETConnectionStandartDataKey][@"ListContent"];
                *totalCount = [input[kAFNETConnectionStandartDataKey][@"PageCount"] integerValue];
                _self.todayStatisticsVC.arrayDataForAnotation=*list;
                if ([_self respondsToSelector:@selector(startLoading)]) {
                    [_self endLoading];
                }
                _self.currentPageCount =input[kAFNETConnectionStandartDataKey][@"CurrentPageNo"];
                _self.totalPageConunts =input[kAFNETConnectionStandartDataKey][@"PageCount"];
                _self.childUpAndDownPageView.textLabel = [NSString stringWithFormat:@"%@/%@",_self.currentPageCount,_self.totalPageConunts];
                
            }else{
                *list = input[kAFNETConnectionStandartDataKey][@"JsonContent"][@"ItemList"];
                self.dicDataForToday =input[kAFNETConnectionStandartDataKey][@"JsonContent"];
//                *totalCount = [input[kAPIConnectionStandartDataKey][@"JsonContent"][@"ItemList"] integerValue];
            }
            
        }else{
            *errorMessage = input[kAFNETConnectionStandartMessageKey];
        } 
    }];
}

- (void)        simpleTableView:(UITableView *)tableView fillCell:(TodayTableViewCell *)cell withData:(NSDictionary *)item andIndexPath:(NSIndexPath *)indexPath{
    cell.data = item;
    if (isAdmin) {
        ((TodayAdminTableViewCell*)cell).deleagte = self;
    }
}
- (NSString *)  simpleTableViewCellNibName:(UITableView *)tableView{
    if (isAdmin) {
        return @"TodayAdminTableViewCell";
    }else{
        return @"TodayStatisticsNewXHCell";
    }
}
- (CGFloat)     simpleTableView:(UITableView *)tableView cellHeightForData:(NSDictionary *)item andIndexPath:(NSIndexPath *)indexPath;{
    if (isAdmin) {
        return 60;
    }else{
        return kscaleDeviceHeight(27);
    }
}
- (void)        simpleTableView:(UITableView *)tableView didSelectedWithData:(NSDictionary *)item andIndexPath:(NSIndexPath *)indexPath{
    if (isAdmin) {
        TodayAdminDetailViewController *controller = [[TodayAdminDetailViewController alloc]init];
        controller.projectId = item[@"ProjectId"];
        [self.navigationController pushViewController:controller animated:YES];
    }

    
}

#pragma mark ------UITableViewDelegate------
-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    if (!isAdmin&&self.dicDataForToday !=nil) {
        TodayStatisticsNewXHHeaderview *view = [tableView dequeueReusableHeaderFooterViewWithIdentifier:[TodayStatisticsNewXHHeaderview viewIdentifier]];
        [view reloadDataForView:self.dicDataForToday];
        return view;
    }else{
        UIView *viewBG = [[UIView alloc] initWithFrame:CGRectMake(0, 0, DeviceWidth, 1)];
//        viewBG.backgroundColor = [UIColor redColor];
       return viewBG;
    }
    
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    if (!isAdmin) {
        return kscaleDeviceHeight(120);
    }
    return 0.01;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 0.01;
}
#pragma mark -----TodayStatisticsStandardTimeDelegate-----
- (void)todaySearchDayView:(TodaySearchDayView *)todaySearchDayView standardTimeValue:(NSString *)standardTime{
    self.dicDataForToday  = nil;
    self.strTimeToServer = standardTime;
    [self setUpPageController];
    [self refreshNoMerge];
}

- (NSString *)FirstIntTimeValueToServer{
    NSDateFormatter *dateFormatter =[[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyyMMdd"];
    NSString *returnStr =[dateFormatter stringFromDate:[NSDate date]];
    return returnStr;
}

- (void)todayAdminTableViewCellTitleDidPress:(TodayAdminTableViewCell *) cell{
    if (isAdmin) {
        [LSDialog showDialogWithTitle:cell.data[@"ProjectName"] message:nil confirmText:@"查看" confirmCallback:^{
            TodayAdminDetailViewController *controller = [[TodayAdminDetailViewController alloc]init];
            controller.projectId = cell.data[@"ProjectId"];
            [self.navigationController pushViewController:controller animated:YES];
        } cancelText:@"关闭" cancelCallback:^{
        }];
    }
}

#pragma marks ---todayUpAndDownPageViewDelegate----

-(void)TodayUpAndDownPageView:(TodayUpAndDownPageView *)upAndDownView clickUpBtn:(id)sender{
     [self.pageController UpPage];
}
-(void)TodayUpAndDownPageView:(TodayUpAndDownPageView *)upAndDownView clickDownBtn:(id)sender{
     [self.pageController nextPage];
}

#pragma mark -----GetSearchDistanceAndUserLocationDelegate--

-(void)todayStatistics:(TodayStatisticsMapVC *)todayStatisticsMapVC textProject:(NSString *)searchProjectName distance:(NSString *)distance clocation:(CLLocation *)location{
    self.projectName = searchProjectName;
    self.distance = distance;
    
    if (location!=nil) {
        self.userLocation = location;
        double longTitude = self.userLocation.coordinate.longitude;
        double latitude = self.userLocation.coordinate.latitude;
        self.userLocationString = [NSString stringWithFormat:@"%f,%f",longTitude,latitude];
    }
    
//    [self setUpPageController];
    self.pageController.pageName = @"CurrentPageNo";
    self.pageController.stepName = @"PageSize";
    NSMutableDictionary *params = [self.pageController.apiParams mutableCopy];
    if (STRING_NOT_EMPTY(_userLocationString)) {
        params[@"CurrentLocation"] = _userLocationString;
    }
    if (STRING_NOT_EMPTY(distance)) {
        params[@"DistanceRange"] = distance;
    }

    if ([distance isEqualToString:@"0"]) {
        [params removeObjectForKey:@"DistanceRange"];
        [params removeObjectForKey:@"CurrentLocation"];
    }
   self.pageController.apiParams = params;
    [self.pageController refreshNoMerge];
    
}

-(void)todayStatistics:(TodayStatisticsMapVC *)todayStatisticsMapVC didClickSearchButton:(id)model{
    [self gotoTodaySearchViewController];
}

#pragma mark ----搜索界面TodaySearchViewController----
-(void)gotoTodaySearchViewController{
    TodaySearchViewController *controller=[[TodaySearchViewController alloc]init];
    [self.navigationController pushViewController:controller animated:YES];
    dpBlockSelf;
    [controller setOnComplete:^(NSString *name, NSString *area,NSString * BuildingReportNumber,NSString* BuildUnitName,NSString * ConstructUnitName,NSString* SuperviseUnitName,NSString * DetectionUnitName) {
        _self.btnSearchTitle = name;
        [_self resetTodayStatisticsMapVCsearchBtnTitle:name];
        NSMutableDictionary *params = [self.pageController.apiParams mutableCopy];
        [params removeObjectsForKeys:@[@"ProjectName",@"ProjectArea",@"BuildingReportNumber",@"BuildUnitName",@"ConstructUnitName",@"SuperviseUnitName",@"DetectionUnitName"]];
        if (STRING_NOT_EMPTY(name)) {
            params[@"ProjectName"] = name;
        }
        if (STRING_NOT_EMPTY(area)) {
            params[@"ProjectArea"] = area;
        }
        if (STRING_NOT_EMPTY(BuildingReportNumber)) {
            params[@"BuildingReportNumber"] = BuildingReportNumber;
        }
        if (STRING_NOT_EMPTY(BuildUnitName)) {
            params[@"BuildUnitName"] = BuildUnitName;
        }
        if (STRING_NOT_EMPTY(ConstructUnitName)) {
            params[@"ConstructUnitName"] = ConstructUnitName;
        }
        if (STRING_NOT_EMPTY(SuperviseUnitName)) {
            params[@"SuperviseUnitName"] = SuperviseUnitName;
        }
        if (STRING_NOT_EMPTY(DetectionUnitName)) {
            params[@"DetectionUnitName"] = DetectionUnitName;
        }
        
        if (STRING_NOT_EMPTY(_userLocationString)) {
            params[@"CurrentLocation"] = _userLocationString;
        }
        if (STRING_NOT_EMPTY(self.distance)) {
            params[@"DistanceRange"] = self.distance!=nil?self.distance:@"3";
        }
        if ([self.distance isEqualToString:@"0"]) {
            [params removeObjectForKey:@"DistanceRange"];
            [params removeObjectForKey:@"CurrentLocation"];
        }
        self.pageController.apiParams = params;
        [self.pageController refreshNoMerge];
        
        [self.navigationController popViewControllerAnimated:YES];
    }];
}

-(void)resetTodayStatisticsMapVCsearchBtnTitle:(NSString *)name{
    if (![name isEqualToString:@""]&&name!=nil) {
        [_todayStatisticsVC.btnSearch setTitle:name forState:UIControlStateNormal];
    }else{
        [_todayStatisticsVC.btnSearch setTitle:@"搜索工地名称" forState:UIControlStateNormal];
    }
    dpBlockSelf;
    if (!self.isFirstLoad) {
        self.pageController.onSupplementRefreshFailedBlock=^(){
            
            _self.todayStatisticsVC.arrayDataForAnotation=nil;
        };
    }
}

#pragma mark----事件点击－－－－
- (IBAction)btnClickDiTu:(UIButton *)sender {
    APP_DELEGATE.rootMainViewController.enableGesture = false;
    _btnDiTu.selected = YES;
    _btnList.selected = NO;
    _mapContainview.hidden =NO;
    _tableView.hidden =YES;
    _viewRefreshPage.hidden = YES;
}
- (IBAction)btnClickList:(UIButton *)sender {
    APP_DELEGATE.rootMainViewController.enableGesture = true;
    _btnList.selected = YES;
    _btnDiTu.selected = NO;
    _tableView.hidden =NO;
    _mapContainview.hidden = YES;
    _viewRefreshPage.hidden = NO;
}


#pragma mark----用于延迟加载----
//用于延迟加载
-(void)startLoading
{
    self.view.userInteractionEnabled =NO;
    if (!self.loadImageView) {
        UIImage *image = [UIImage imageNamed:@"pay_loading"];
        self.loadImageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 100, image.size.width, image.size.height)];
        self.loadImageView.bounds = CGRectMake(0, 0, image.size.width, image.size.height);
        if (self.navigationController&&(self.navigationController.viewControllers.count >1)) {
            self.loadImageView.center = CGPointMake(DeviceWidth/2.0f, (DeviceHeight -64)/2.0f);
        }
        else {
            self.loadImageView.center = CGPointMake(DeviceWidth/2.0f, (DeviceHeight -64-49)/2.0f);
        }
        [self.loadImageView setImage:image];
        [self.view addSubview:self.loadImageView];
        [self.loadImageView bringSubviewToFront:_viewRefreshPage];
    }
    self.loadImageView.hidden = NO;
    if (self.loadImageView && !self.loadImageView.hidden) {
        CABasicAnimation* rotationAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
        rotationAnimation.toValue = [NSNumber numberWithFloat:((360.0f * M_PI) / 180.0f)];
        rotationAnimation.duration = 2.0;
        rotationAnimation.repeatCount = 999999;
        rotationAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
        [self.loadImageView.layer addAnimation:rotationAnimation forKey:@"revItUpAnimation"];
    }
}
-(void)endLoading
{
    self.view.userInteractionEnabled =YES;
    [self.loadImageView.layer removeAnimationForKey:@"revItUpAnimation"];
    self.loadImageView.hidden = YES;
}
@end
