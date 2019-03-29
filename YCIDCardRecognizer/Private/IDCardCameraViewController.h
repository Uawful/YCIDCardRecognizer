//
//  IDCardCameraViewController.h
//  IDCardRecognizeDemo
//
//  Created by admin on 2019/3/21.
//  Copyright © 2019年 yc. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol IDCardCameraViewControllerDelegate <NSObject>

- (void)getImageWithCamera:(UIImage *)image;

@end

@interface IDCardCameraViewController : UIViewController

@property (nonatomic ,weak)id<IDCardCameraViewControllerDelegate> delegate;

@end

