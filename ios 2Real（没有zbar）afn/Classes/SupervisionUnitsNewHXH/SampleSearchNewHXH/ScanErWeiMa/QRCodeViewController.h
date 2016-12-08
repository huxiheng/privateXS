//
//  QRCodeViewController.h
//  XieshiPrivate
//
//  Created by Tesiro on 16/10/25.
//  Copyright © 2016年 Lessu. All rights reserved.
//

#import "XSViewController.h"
#import "ZBarSDK.h"


@interface QRCodeViewController : XSViewController<ZBarReaderViewDelegate>{
    void (^_onRecognized)(NSString *data);
}
@property (strong, nonatomic)  ZBarReaderView *reader;

@property (nonatomic, copy)NSString *titleBackBtn;

@property(nonatomic,copy) void (^onRecognized)(NSString *data);

@end
