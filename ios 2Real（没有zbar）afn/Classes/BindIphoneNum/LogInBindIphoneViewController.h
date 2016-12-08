//
//  LogInBindIphoneViewController.h
//  XieshiPrivate
//
//  Created by Tesiro on 16/7/18.
//  Copyright © 2016年 Lessu. All rights reserved.
//

#import "XSViewController.h"

@interface LogInBindIphoneViewController : XSViewController{
    NSMutableArray *arrayUserBuindNumber;//用来保存用户绑定的手机号
}
@property(nonatomic,retain) NSString *userName;
@property(nonatomic,retain) NSString *password;
@property(nonatomic,retain) NSString *deviceId;
@property(nonatomic, retain) NSString *numberPhone;
@property(nonatomic,copy)NSString  *userPowerString;

@end
