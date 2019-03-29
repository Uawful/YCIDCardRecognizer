//
//  RecognizeManager.m
//  IDCardRecognition
//
//  Created by admin on 2019/3/18.
//  Copyright © 2019年 yc. All rights reserved.
//

#import "RecognizeManager.h"
#import <opencv2/opencv.hpp>
#import <opencv2/imgproc/types_c.h>
#import <opencv2/imgcodecs/ios.h>
#import <TesseractOCR/TesseractOCR.h>

@implementation RecognizeManager

+(instancetype)recognizeManager {
    
    static RecognizeManager *recognizeManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        recognizeManager = [[RecognizeManager alloc]init];
    });
    return recognizeManager;
    
}

- (void)recognizeIDCardWithImage:(id)cardImage complete:(CompleteBlock)complete {

    UIImage *numberImage = [self opencvScanCard:cardImage];
    if (!numberImage) {
        dispatch_async(dispatch_get_main_queue(), ^{
            //opencv失败回调
            complete(nil);
        });
    }
    _img = numberImage;
    [self tesseractRecognizeImage:numberImage complete:^(NSString *idCardText) {
        complete(idCardText);
    }];
    
}

//图片二值处理，获取号码所在rect
- (UIImage *)opencvScanCard:(UIImage *)image {
    
    //UIImage --> Mat
    cv::Mat resultImage;
    UIImageToMat(image, resultImage);
    //灰度转化
    cvtColor(resultImage, resultImage, cv::COLOR_BGR2GRAY);
    //二值化
    cv::threshold(resultImage, resultImage, 100, 255, CV_THRESH_BINARY);
    //腐蚀填充 扩大黑色范围
    cv::Mat erodeElement = getStructuringElement(cv::MORPH_RECT, cv::Size(26,26));
    cv::erode(resultImage, resultImage, erodeElement);
    //轮廓检测
    std::vector<std::vector<cv::Point>> contours;//定义一个容器来储存所有检测到的轮廓
    cv::findContours(resultImage, contours, CV_RETR_TREE, CV_CHAIN_APPROX_SIMPLE, cvPoint(0, 0));
    //取出生份证号码区域
    std::vector<cv::Rect> rects;
    cv::Rect numberRect = cv::Rect(0,0,0,0);
    std::vector<std::vector<cv::Point>>::const_iterator itContours = contours.begin();
    for ( ; itContours != contours.end(); ++itContours) {
        cv::Rect rect = cv::boundingRect(*itContours);
        rects.push_back(rect);
        //算法原理 get到符合宽高比例的contours
        if (rect.width > numberRect.width && rect.width > rect.height * 5) {
            numberRect = rect;
        }
    }
    //身份证号码定位失败
    if (numberRect.width == 0 || numberRect.height == 0) {
        return nil;
    }
    //定位成功，去原图截出身份证号码区域，并转换成灰度图、进行二值处理
    cv::Mat matImage;
    UIImageToMat(image, matImage);
    resultImage = matImage(numberRect);
    cvtColor(resultImage, resultImage, cv::COLOR_BGR2GRAY);
    cv::threshold(resultImage, resultImage, 80, 255, CV_THRESH_BINARY);
    //将Mat转换成UIImage
    UIImage *numberImage = MatToUIImage(resultImage);
    return numberImage;

}

//利用TesseractOCR识别相应图片文字
- (void)tesseractRecognizeImage:(UIImage *)image complete:(CompleteBlock)complete {
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        //语言包添加
        G8Tesseract *tesseract = [[G8Tesseract alloc]initWithLanguage:@"eng"];
        tesseract.image = [image g8_blackAndWhite];
        tesseract.image = image;
        //开始识别
        [tesseract recognize];
        //回调
        dispatch_async(dispatch_get_main_queue(), ^{
            complete(tesseract.recognizedText);
        });
    });
    
}

@end
