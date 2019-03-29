//
//  IDCardCameraViewController.m
//  IDCardRecognizeDemo
//
//  Created by admin on 2019/3/21.
//  Copyright © 2019年 yc. All rights reserved.
//

#import "IDCardCameraViewController.h"
#import "IDCardCamera.h"
#import "RecognizeManager.h"

@interface IDCardCameraViewController ()

@property (strong, nonatomic) IDCardCamera *camera;

@end

@implementation IDCardCameraViewController
{
    UIButton *_cameraBtn;
}
#define SelfWidth [UIScreen mainScreen].bounds.size.width
#define SelfHeight  [UIScreen mainScreen].bounds.size.height

-(void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    [self.camera restart];
    
}

- (void)viewDidLoad {
    
    [super viewDidLoad];
    self.camera = [[IDCardCamera alloc] initWithFrame:self.view.bounds];
    //拍摄有效区域（可不设置，不设置则不显示遮罩层和边框）
    self.camera.effectiveRect = CGRectMake(20, 200, self.view.frame.size.width - 40, 280);
    [self.view insertSubview:self.camera atIndex:0];
    
    UIView *bottomView = [[UIView alloc]initWithFrame:CGRectMake(0, SelfHeight - 100, SelfWidth, 100)];
    bottomView.backgroundColor = [UIColor blackColor];
    [self.view addSubview:bottomView];
    
    UILabel *tipLabel = [[UILabel alloc]initWithFrame:CGRectMake(20, 485, SelfWidth - 40, 25)];
    tipLabel.text = @"请将身份证正对框内拍摄，对焦保证照片信息清晰明了";
    tipLabel.textAlignment = NSTextAlignmentCenter;
    tipLabel.textColor = [UIColor greenColor];
    tipLabel.font = [UIFont systemFontOfSize:12];
    tipLabel.numberOfLines = 0;
    [self.view addSubview:tipLabel];
    
    UIButton *takeButton = [UIButton buttonWithType:UIButtonTypeCustom];
    takeButton.frame = CGRectMake((SelfWidth - 70)/2, 10, 70, 70);
    takeButton.layer.masksToBounds = YES;
    takeButton.layer.cornerRadius = takeButton.frame.size.height/2;
    takeButton.backgroundColor = [UIColor colorWithWhite:1 alpha:0.7];
    [takeButton setTitle:@"拍照" forState:UIControlStateNormal];
    takeButton.titleLabel.font = [UIFont systemFontOfSize:16];
    takeButton.titleLabel.numberOfLines = 0;
    [takeButton setTitleColor:[UIColor colorWithRed:40.2f/255 green:180.2f/255 blue:247.2f/255 alpha:0.9] forState:UIControlStateNormal];
    [takeButton addTarget:self action:@selector(btnAction:) forControlEvents:UIControlEventTouchUpInside];
    [bottomView addSubview:takeButton];
    
    UIButton *cancelBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    cancelBtn.frame = CGRectMake(30, 17, 70, 50);
    [cancelBtn setTitle:@"取消" forState:UIControlStateNormal];
    cancelBtn.titleLabel.font = [UIFont systemFontOfSize:16];
    [cancelBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [cancelBtn addTarget:self action:@selector(dismissAction) forControlEvents:UIControlEventTouchUpInside];
    [bottomView addSubview:cancelBtn];
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(dismissAction) name:@"yc_recImgDown" object:nil];
    
}

-(BOOL)shouldAutorotate {
    
    return NO;
}

- (void)btnAction:(UIButton *)sender {
    
    __weak typeof(self) weakSelf = self;
    [self.camera takePhoto:^(UIImage *img) {
        __strong typeof(self) strongSelf = weakSelf;
        if ([strongSelf.delegate respondsToSelector:@selector(getImageWithCamera:)]) {
            [strongSelf.delegate getImageWithCamera:img];
            NSLog(@"img - %@",img);
        }
    }];
    
}

- (void)dismissAction {
    
    [self dismissViewControllerAnimated:YES completion:nil];
    
}

-(void)dealloc {
    
    [[NSNotificationCenter defaultCenter]removeObserver:self name:@"yc_recImgDown" object:nil];
    
}

@end
