//
//  NSError+Common.m
//  Xieshi
//
//  Created by Tesiro on 16/12/7.
//  Copyright © 2016年 Lessu. All rights reserved.
//

#import "NSError+Common.h"

@implementation NSError (Common)
+(NSString*)getErrorInfoResponseUTF8String:(NSError*)error{
    NSLog(@"%@",[error localizedDescription]);
    NSData *errorData = [error.userInfo objectForKey:@"com.alamofire.serialization.response.error.data"] ;
    NSString *errorInfo = [[NSString alloc] initWithData:errorData encoding:NSUTF8StringEncoding];
    return errorInfo;
}
@end
