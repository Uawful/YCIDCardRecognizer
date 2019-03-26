//
//  IDCardTool.h
//  IDCardRecognizeDemo
//
//  Created by admin on 2019/3/20.
//  Copyright © 2019年 yc. All rights reserved.
//

#import <Foundation/Foundation.h>
typedef NS_ENUM(NSInteger, YCButtonClick) {
    YCButtonClick_CAMERA,
    YCButtonClick_ALBUM
};

@class UIImage;

typedef void (^CompletionBlock)(NSString *idCardText,UIImage *image);

@interface IDCardTool : NSObject

+ (instancetype)sharedInstance;

- (void)didClickButtonWithType:(YCButtonClick)type withBlock:(CompletionBlock)block;

@end

