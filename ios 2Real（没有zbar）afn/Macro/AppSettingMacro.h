//
//  AppSettingMacro.h
//  XieshiPrivate
//
//  Created by Tesiro on 16/9/20.
//  Copyright © 2016年 Lessu. All rights reserved.
//

#ifndef AppSettingMacro_h
#define AppSettingMacro_h

#define Local_File_path [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject]
#define kImagePath  [NSString stringWithFormat:@"%@/Library/Caches/%@",NSHomeDirectory(),@"Images/"]
#define kSaveIphoneNumberPath  [NSString stringWithFormat:@"%@/Documents/%@",NSHomeDirectory(),@"iphoneNumbers/"]
#define AppStoreUrl  @"itms-apps://itunes.apple.com/app/id1166462760"
#endif /* AppSettingMacro_h */
