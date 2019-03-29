//
//  IDCardVerification.h
//  IDCardRecognizeDemo
//
//  Created by admin on 2019/3/21.
//  Copyright © 2019年 yc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface IDCardVerification : NSObject

+ (BOOL)validateIDCardNumber:(NSString *)value;

@end

