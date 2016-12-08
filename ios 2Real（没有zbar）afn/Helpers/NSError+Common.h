//
//  NSError+Common.h
//  Xieshi
//
//  Created by Tesiro on 16/12/7.
//  Copyright © 2016年 Lessu. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSError (Common)
+(NSString*)getErrorInfoResponseUTF8String:(NSError*)error;
@end
