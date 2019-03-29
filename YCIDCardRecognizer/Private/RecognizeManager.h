//
//  RecognizeManager.h
//  IDCardRecognition
//
//  Created by admin on 2019/3/18.
//  Copyright © 2019年 yc. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^CompleteBlock)(NSString *idCardText);

@class UIImage;
@interface RecognizeManager : NSObject

@property (nonatomic ,strong ,readonly)UIImage *img;

+ (instancetype)recognizeManager;

- (void)recognizeIDCardWithImage:(UIImage *)cardImage complete:(CompleteBlock)complete;

@end

