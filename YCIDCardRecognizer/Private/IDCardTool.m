//
//  IDCardTool.m
//  IDCardRecognizeDemo
//
//  Created by admin on 2019/3/20.
//  Copyright © 2019年 yc. All rights reserved.
//

#import "IDCardTool.h"
#import <UIKit/UIKit.h>
#import <Photos/Photos.h>
#import "RecognizeManager.h"
#import "IDCardCameraViewController.h"
#import "IDCardVerification.h"

@interface IDCardTool()<UINavigationControllerDelegate, UIImagePickerControllerDelegate,IDCardCameraViewControllerDelegate>

@property (nonatomic, strong) UIImagePickerController *imagePickController;
@property (nonatomic, strong) UILabel *textLabel;
@property (nonatomic, strong) UIButton *cameraBtn;
@property (nonatomic, strong) UIButton *albumBtn;
@property (nonatomic, strong) UIImageView *showImg;//展示opencv处理后所得图片
@property (nonatomic, copy) CompletionBlock completionBlock;
@property (nonatomic, strong) IDCardCameraViewController *cameraVC;

@end

@implementation IDCardTool
{
    UIViewController *_currentVC;
}

+(instancetype)sharedInstance {
    
    static IDCardTool *idCardTool = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        idCardTool = [[IDCardTool alloc]init];
    });
    return idCardTool;
    
}

- (void)didClickButtonWithType:(YCButtonClick)type withBlock:(CompletionBlock)block{
    
    _currentVC = [self currentViewController];
    self.completionBlock = block;
    if (!_currentVC) {
        return;
    }
    switch (type) {
        case YCButtonClick_CAMERA:
        {
            [self cameraAction];
        }
            break;
        case YCButtonClick_ALBUM:
        {
            [self albumVisitAction];
        }
            break;
        default:
            break;
    }
    
}

#pragma mark - btnAction

- (void)cameraAction {

    [_currentVC presentViewController:self.cameraVC animated:YES completion:nil];
    
}

- (void)albumVisitAction {
    
    self.imagePickController.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    [_currentVC presentViewController:self.imagePickController animated:YES completion:nil];
    
}

#pragma mark - delegateReference
//从相册
- (void)navigationController:(UINavigationController *)navigationController didShowViewController:(UIViewController *)viewController animated:(BOOL)animated {
    if ([UIDevice currentDevice].systemVersion.floatValue < 11) {
        return;
    }
    if ([viewController isKindOfClass:NSClassFromString(@"PUPhotoPickerHostViewController")]) {
        [viewController.view.subviews enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if (obj.frame.size.width < 42) {
                [viewController.view sendSubviewToBack:obj];
                *stop = YES;
            }
        }];
    }
}

-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<UIImagePickerControllerInfoKey,id> *)info {
    
    NSString *mediaType=[info objectForKey:UIImagePickerControllerMediaType];
    UIImage *srcImage = nil;
    if ([mediaType isEqualToString:@"public.image"]){
         srcImage = info[UIImagePickerControllerEditedImage];
        //识别身份证
        [[RecognizeManager recognizeManager] recognizeIDCardWithImage:srcImage complete:^(NSString *idCardText) {
            if ([IDCardVerification validateIDCardNumber:idCardText]) {
                self.completionBlock(idCardText,srcImage);
            }else{
                self.completionBlock(nil,srcImage);
            }
        }];
    }
    [_currentVC dismissViewControllerAnimated:YES completion:nil];
    
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    
    [_currentVC dismissViewControllerAnimated:YES completion:nil];
    _currentVC = nil;
    
}
//从相机
-(void)getImageWithCamera:(UIImage *)image {
    
    [[RecognizeManager recognizeManager] recognizeIDCardWithImage:image complete:^(NSString *idCardText) {
        if ([IDCardVerification validateIDCardNumber:idCardText]) {
            self.completionBlock(idCardText,image);
        }else{
            self.completionBlock(nil,image);
        }
        NSLog(@"image");
        [[NSNotificationCenter defaultCenter]postNotificationName:@"yc_recImgDown" object:nil];
    }];
    
}

#pragma mark - getCurrentVC
- (UIViewController*)currentViewController{
    
    UIViewController* vc = [UIApplication sharedApplication].keyWindow.rootViewController;
    while (1) {
        if ([vc isKindOfClass:[UITabBarController class]]) {
            vc = ((UITabBarController*)vc).selectedViewController;
        }
        if ([vc isKindOfClass:[UINavigationController class]]) {
            vc = ((UINavigationController*)vc).visibleViewController;
        }
        if (vc.presentedViewController) {
            vc = vc.presentedViewController;
        }else{
            break;
        }
    }
    return vc;
    
}

#pragma mark - setter/getter

-(IDCardCameraViewController *)cameraVC {
    
    if (!_cameraVC) {
        _cameraVC = [[IDCardCameraViewController alloc]init];
        _cameraVC.delegate = self;
    }
    return _cameraVC;
    
}

-(UIImagePickerController *)imagePickController {
    
    if (!_imagePickController) {
        _imagePickController = [[UIImagePickerController alloc] init];
        _imagePickController.delegate = self;
        _imagePickController.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
        _imagePickController.allowsEditing = YES;
    }
    return _imagePickController;
    
}

-(UILabel *)textLabel {
    
    if (!_textLabel) {
        _textLabel = [[UILabel alloc]initWithFrame:CGRectMake(100.f, 200.f, 300.f, 50.f)];
    }
    return _textLabel;
    
}

-(UIButton *)cameraBtn {
    
    if (!_cameraBtn) {
        _cameraBtn = [[UIButton alloc]initWithFrame:CGRectMake(50.f, 70.f, 100.f, 20.f)];
        [_cameraBtn setTitle:@"拍照" forState:UIControlStateNormal];
        [_cameraBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [_cameraBtn addTarget:self action:@selector(cameraAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _cameraBtn;
    
}

-(UIButton *)albumBtn {
    
    if (!_albumBtn) {
        _albumBtn = [[UIButton alloc]initWithFrame:CGRectMake(50.f, 70.f, 200.f, 20.f)];
        [_albumBtn setTitle:@"相册" forState:UIControlStateNormal];
        [_albumBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [_albumBtn addTarget:self action:@selector(albumVisitAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _albumBtn;
    
}

-(UIImageView *)showImg {
    
    if (!_showImg) {
        _showImg = [[UIImageView alloc]initWithFrame:CGRectMake(50, 500, 300, 100)];
        _showImg.contentMode = UIViewContentModeScaleAspectFit;
        _showImg.layer.borderWidth = 1.f;
        _showImg.layer.borderColor = [UIColor blackColor].CGColor;
    }
    return _showImg;
    
}


@end
