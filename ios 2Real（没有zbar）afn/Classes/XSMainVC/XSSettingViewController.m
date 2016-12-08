//
//  XSSettingViewController.m
//  XieshiPrivate
//
//  Created by Tesiro on 16/7/26.
//  Copyright © 2016年 Lessu. All rights reserved.
//

#import "XSSettingViewController.h"
#import "XSSettingViewCell.h"
//#import "ModifyPasswordViewController.h"
//#import "ServerSelectViewController.h"
#import "ServerSelectSecondViewController.h"
#import "ModifyPasswordViewSecondController.h"
#import "NSString+SBJSON.h"

#import "XSActionSheet.h"
#import "XSVersionUpdateView.h"
#import "XSRemoveCountBindView.h"

#import "LogInViewController.h"
#import "AppDelegate.h"

@interface XSSettingViewController ()
@property (nonatomic, strong)XSActionSheet     *actionSheet;


@end

@implementation XSSettingViewController

- (void)setData {
    self.titleForNav = @"设置";
    
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    NSString *server = [LoginUtil valueForKey:@"server_select"];
    if ([server isEqualToString:@"cnnet"]) {
       arrayContent = @[@"",@"中国电信",@"",@""];
//        _serverNameLabel.text = @"中国电信";
    }
    if ([server isEqualToString:@"union"]) {
        arrayContent = @[@"",@"中国联通",@"",@""];
//        _serverNameLabel.text = @"中国联通";
    }
    
     [self setdataArray];
}

- (void)viewDidLoad {
    [super viewDidLoad];
   
    [self setdataArray];
    self.table = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, DeviceWidth, DeviceHeight) style:UITableViewStylePlain];
    self.table.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.table.delegate = self;
    self.table.dataSource = self;
    self.table.rowHeight = 50;
    [self.view addSubview:self.table];
    
    self.table.contentInset = UIEdgeInsetsMake(40, 0, 0, 0);
    
    [self.table registerClass:[XSSettingViewCell class] forCellReuseIdentifier:[XSSettingViewCell cellIdentifier]];
    
    self.actionSheet = [[XSActionSheet alloc] initWithFrame:CGRectMake(0, 0, DeviceWidth, DeviceHeight)];
    
    
}

- (void)setdataArray{
    self.arrayData = [[NSMutableArray alloc] initWithCapacity:0];
    NSString*updateShow = [[XSShareObject sharedInstance] isCompanyCount]?@"跳转到AppStore":@"检查更新";
    NSArray *arrayTitle = @[@"修改密码",@"选择服务器",updateShow,@"解除帐号绑定"];
    NSArray *arrayImage = @[[UIImage imageNamed:@"xiugaimima"],[UIImage imageNamed:@"fuwuqi"],[UIImage imageNamed:@"gengxin"],[UIImage imageNamed:@"jiechubangding"]];
    
    for (int i=0; i<arrayTitle.count; i++) {
        XSCellModel *cellmodel = [[XSCellModel alloc] init];
        cellmodel.title = arrayTitle[i];
        cellmodel.content = arrayContent[i];
        cellmodel.images = arrayImage[i];
        [self.arrayData addObject:cellmodel];
    }
    [self.table reloadData];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.arrayData.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    XSSettingViewCell *cell = [tableView dequeueReusableCellWithIdentifier:[XSSettingViewCell cellIdentifier]];
    id model = [self.arrayData objectAtIndex:indexPath.row];
    [cell reloadDataForCell:model];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    if (indexPath.row == 0 ) {
        ModifyPasswordViewSecondController *controller = [[ModifyPasswordViewSecondController alloc]init];
        controller.userName = [LoginUtil loginUserName];
        [self.navigationController pushViewController:controller animated:YES];
    }
    if (indexPath.row ==1 ) {
        ServerSelectSecondViewController *controller = [[ServerSelectSecondViewController alloc]init];
        controller.isFirst = YES;
        [self.navigationController pushViewController:controller animated:YES];
    }
    if (indexPath.row ==2) {
        if ( [[XSShareObject sharedInstance] isCompanyCount]) {
             [[UIApplication sharedApplication]openURL:[NSURL URLWithString:AppStoreUrl]];
        }else{
            [self updateVersion];
        };
        
        
    }
    if (indexPath.row == 3) {
        
        NSString*userNum=[[NSUserDefaults standardUserDefaults] valueForKey:@"getPhoneNumber"];
        if ([userNum isEqualToString:@""]||userNum==nil) {
            NSString *userNumberFromPlist = [self getUserBuindingPhoneNumber];
            if ([userNumberFromPlist isEqualToString:@""]||userNumberFromPlist==nil) {
                userNum = @"请重新登录，在操作此功能";
            }else{
                userNum =userNumberFromPlist;
            }
            
        }

        XSRemoveCountBindView *unbindView = [[XSRemoveCountBindView alloc] initWithIphoneNum:userNum countName:[LoginUtil loginUserName]];
        dpBlockSelf;
        unbindView.blockClickBtn = ^(NSInteger index){
            if (index == 11) {
                [_self.actionSheet hiddenSelf];
                
            }
            if (index == 10) {
                [_self dataQequestForUnbind:userNum];
            }
            
        };
        
        self.actionSheet.viewRemoveCountBind = unbindView;
        self.actionSheet.navVC = (XSNavigationViewController *)self.navigationController;
        [self.actionSheet showInView:self.navigationController.view];
       }
}

-(void)updateVersion{
    @try {
        
        NSDictionary *params = @{
                                 @"PlatformType" : @"2",
                                 @"SystemType"   : @"2"
                                 };
        AFNetConnection *connection = [[USTAFNet sharedInstance]connectionWithApiName:AFNETMETHOD_UST_GetUpdateVersion params:params];
        [connection setOnSuccess:^(id result) {
            result = result[@"Data"][0];
            if (versionNameBiggerThan(result[@"Version"], [NSBundle mainBundle].infoDictionary[@"CFBundleShortVersionString"])){
                if ([result[@"Update_Flag"] integerValue] == 1){
                    [LSDialog showDialogWithTitle:@"发现新版本" message:result[@"Description"]confirmText:@"升级" confirmCallback:^{
                        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:result[@"Update_Url"]]];
                    } cancelText:@"取消" cancelCallback:^{
                        
                    }];
                }else{
                    [LSDialog showAlertWithTitle:@"发现新版本" message:result[@"Description"] callBack:^{
                        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:result[@"Update_Url"]]];
                    }];
                }
            }else{
                //                    [LSDialog showAlertWithTitle:@"提示" message:@"已经是最新版了" callBack:0];
                XSVersionUpdateView * updateView = [[XSVersionUpdateView alloc] initWithImageName:@"selectduihao" title:@"当前已经是最新版本"];
                self.isNewVersion = YES;
                
                self.actionSheet.viewUpdateVersion = updateView;
                self.actionSheet.navVC = (XSNavigationViewController *)self.navigationController;
                [self.actionSheet showInView:self.navigationController.view];
                
                
            }
        }];
        [connection setOnFailed:^(NSError *error) {
            NSString *errorDescription = [error localizedDescription];
            [SVProgressHUD dismissWithError:STRING_FORMAT(@"%@",errorDescription) afterDelay:2.5f];
        }];
        [connection startAsynchronous];
    }
    @catch (NSException *exception) {
        [LSDialog showAlertWithTitle:@"提示" message:@"升级出现错误" callBack:0];
        
    }
    @finally {
        
    }
}

- (void)dataQequestForUnbind:(NSString*)userNum{
    NSLog(@"%@", [LoginUtil loginUserName]);
    NSLog(@"%@", [LoginUtil loginPassword]);
    NSLog(@"%@", [LoginUtil numberPhone]);
//    NSString *phoneNumber = (([LoginUtil numberPhone] == NULL) ? @"":[[NSUserDefaults standardUserDefaults] objectForKey:@"IphoneNumberForCode"]);
    NSLog(@"%@",[LoginUtil numberPhone]);
    NSLog(@"%@",[[NSUserDefaults standardUserDefaults] objectForKey:@"IphoneNumberForCode"]);
    NSDictionary *params = @{
                             @"UserName" : [LoginUtil loginUserName],
                             @"PassWord" : [LoginUtil loginPassword],
                             @"PhoneNumber": userNum,
                             @"Deviceid"    :[[XSConnectPool shareInstance] getUuid]
                             };
    
    AFNetConnection *connection = [[USTAFNet sharedInstance]connectionWithApiName:AFNETMETHOD_UST_UnBind params:params];
    [connection setOnSuccess:^(id result) {
        
        LogInViewController *loginViewController= [[LogInViewController alloc]init];
        
        APP_DELEGATE.rootNavigationController = [[XSNavigationViewController alloc] initWithRootViewController:loginViewController];
        APP_DELEGATE.window.rootViewController = APP_DELEGATE.rootNavigationController;
        [[NSUserDefaults standardUserDefaults] setValue:@"1" forKey:@"isFirstLogInto"];
    }];
    [connection setOnFailed:^(NSError *error) {
        NSString *errorDescription = [error localizedDescription];
        [SVProgressHUD dismissWithError:STRING_FORMAT(@"%@",errorDescription) afterDelay:2.5f];
    }];
    //    [SVProgressHUD show];
    [connection startAsynchronous];


}

#pragma marks ----获取用户绑定的手机号----
-(NSString *)getUserBuindingPhoneNumber{
    NSString *path = [NSString returnBuindingIphoneNumber];
        NSArray *arrayUserImages = [NSArray arrayWithContentsOfFile:path];
        for (int i=0; i<arrayUserImages.count; i++) {
            NSDictionary *dic = arrayUserImages[i];
            if ([[LoginUtil loginUserName] isEqualToString:dic[@"userName"]]) {
                
                return dic[@"numberdata"];
            }
        }
    return nil;
}



@end
