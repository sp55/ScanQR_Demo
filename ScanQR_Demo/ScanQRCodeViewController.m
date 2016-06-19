//
//  ScanQRCodeViewController.m
//  ScanQR_Demo
//
//  Created by admin on 16/6/19.
//  Copyright © 2016年 AlezJi. All rights reserved.
//

#import "ScanQRCodeViewController.h"
#import <AVFoundation/AVFoundation.h>

@interface ScanQRCodeViewController ()<AVCaptureMetadataOutputObjectsDelegate,UINavigationControllerDelegate,UIImagePickerControllerDelegate>
{
    AVCaptureSession *session; //输入输出的中间桥梁
    int line_tag;
    UIView *highlightView;
    
}

@end

@implementation ScanQRCodeViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    
    [self initUI];


}
//布局UI
-(void)initUI
{
    [[UIApplication sharedApplication]setStatusBarStyle:UIStatusBarStyleLightContent animated:YES];
   
    line_tag = 18;
    
    //获取摄像设备
    AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    //创建输入流
    AVCaptureDeviceInput *input = [AVCaptureDeviceInput deviceInputWithDevice:device error:nil];
    //创建输出流
    AVCaptureMetadataOutput *output = [[AVCaptureMetadataOutput alloc]init];
    //设置代理,在主线程刷新
    [output setMetadataObjectsDelegate:self queue:dispatch_get_main_queue()];
    //初始化连接对象
    session = [[AVCaptureSession alloc]init];
    //高质量采集率
    [session setSessionPreset:AVCaptureSessionPresetHigh];
    if (input) {
        [session addInput:input];
    }
    if (output) {
        [session addOutput:output];
        //设置扫码的编码格式
        NSMutableArray *a = [[NSMutableArray alloc]init];
        if ([output.availableMetadataObjectTypes containsObject:AVMetadataObjectTypeQRCode]) {
            [a addObject:AVMetadataObjectTypeQRCode];
        }
        if ([output.availableMetadataObjectTypes containsObject:AVMetadataObjectTypeEAN13Code]) {
            [a addObject:AVMetadataObjectTypeEAN13Code];
        }
        if ([output.availableMetadataObjectTypes containsObject:AVMetadataObjectTypeEAN8Code]) {
            [a addObject:AVMetadataObjectTypeEAN8Code];
        }
        if ([output.availableMetadataObjectTypes containsObject:AVMetadataObjectTypeCode128Code]) {
            [a addObject:AVMetadataObjectTypeCode128Code];
        }
        output.metadataObjectTypes = a;
    }
    AVCaptureVideoPreviewLayer *layer = [AVCaptureVideoPreviewLayer layerWithSession:session];
    layer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    layer.frame = self.view.bounds;
    [self.view.layer insertSublayer:layer atIndex:0];
    //创建扫码页面
    [self creatPickerView];
    [session addObserver:self forKeyPath:@"running" options:NSKeyValueObservingOptionNew context:nil];
    //开始捕获
    [session startRunning];
}

//创建扫码界面
-(void)creatPickerView
{
    //左侧View
    UIImageView *leftView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 30, self.view.frame.size.height)];
    leftView.alpha = 0.5;
    leftView.backgroundColor = [UIColor blackColor];
    [self.view addSubview:leftView];
    //右侧View
    UIImageView *rightView = [[UIImageView alloc]initWithFrame:CGRectMake(self.view.frame.size.width - 30, 0, 30, self.view.frame.size.height)];
    rightView.alpha = 0.5;
    rightView.backgroundColor = [UIColor blackColor];
    [self.view addSubview:rightView];
    //上部View
    UIImageView *topView = [[UIImageView alloc]initWithFrame:CGRectMake(30, 0, self.view.frame.size.width - 60, (self.view.center.y - (self.view.frame.size.width - 60) / 2))];
    topView.alpha = 0.5;
    topView.backgroundColor = [UIColor blackColor];
    [self.view addSubview:topView];
    //底部View
    UIImageView *bottomView = [[UIImageView alloc]initWithFrame:CGRectMake(30, self.view.center.y + (self.view.frame.size.width - 60)/2, self.view.frame.size.width - 60, self.view.frame.size.height - ((self.view.center.y - (self.view.frame.size.width - 60)/2)))];
    bottomView.backgroundColor = [UIColor blackColor];
    bottomView.alpha = 0.5;
    [self.view addSubview:bottomView];
    //扫描框
    UIImageView *centerView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width - 60, self.view.frame.size.width)];
    centerView.center = self.view.center;
    centerView.backgroundColor = [UIColor clearColor];
    centerView.image = [UIImage imageNamed:@"扫描框"];
    centerView.contentMode = UIViewContentModeScaleAspectFit;
    [self.view addSubview:centerView];
    //扫描线
    UIImageView *lineView = [[UIImageView alloc]initWithFrame:CGRectMake(30, CGRectGetMaxY(topView.frame), self.view.frame.size.width - 60, 2)];
    lineView.tag = line_tag;
    lineView.image = [UIImage imageNamed:@"扫描线"];
    lineView.backgroundColor = [UIColor clearColor];
    lineView.contentMode = UIViewContentModeScaleAspectFill;
    [self.view addSubview:lineView];
    //文字
    UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(30, CGRectGetMinY(bottomView.frame), self.view.frame.size.width - 60, 60)];
    label.textAlignment = NSTextAlignmentCenter;
    label.font = [UIFont systemFontOfSize:16];
    label.textColor = [UIColor whiteColor];
    label.text = @"将二维码放入框内,即可自动扫描";
    label.backgroundColor = [UIColor clearColor];
    [self.view addSubview:label];
    //返回按钮
    UIButton *backBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    backBtn.frame = CGRectMake(-2, 10, 60, 64);
    [backBtn addTarget:self action:@selector(backToView:) forControlEvents:UIControlEventTouchUpInside];
    [backBtn setImage:[UIImage imageNamed:@"白色返回_想去"] forState:UIControlStateNormal];
    [self.view addSubview:backBtn];
    //选取本地照片
    UIImageView *imageV = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"erweima@3x"]];
    imageV.userInteractionEnabled = YES;
    imageV.frame = CGRectMake(kScreenWidth-50, 35, 35, 35);

    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(chooseImage)];
    [imageV addGestureRecognizer:tap];
    [self.view addSubview:imageV];

    
}
-(void)backToView:(UIButton *)sender
{
    [self removeFromSuperview];
    
}

//获取到扫码结果
-(void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects fromConnection:(AVCaptureConnection *)connection
{
    if (metadataObjects.count > 0) {
        [session stopRunning];
        AVMetadataMachineReadableCodeObject *metadataObject = [metadataObjects objectAtIndex:0];
        //输出扫描字符串
        NSString *data = metadataObject.stringValue;
//        NSLog(@"我想要得到的数据是%@",data);
        if (_didRecoiveBlock) {
            _didRecoiveBlock(data);
            [self removeFromSuperview];
        }
    }
}

//从父视图移除
-(void)removeFromSuperview
{
    [session removeObserver:self forKeyPath:@"running" context:nil];
    [UIView animateWithDuration:0.3 animations:^{
        self.view.alpha = 0;
    } completion:^(BOOL finished) {
        [self.view removeFromSuperview];
        [self removeFromParentViewController];
    }];
    [[UIApplication sharedApplication]setStatusBarStyle:UIStatusBarStyleDefault animated:YES];
    
}

//监听扫码状态,添加扫码动画
-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context
{
    if ([object isKindOfClass:[AVCaptureSession class]]) {
        BOOL isRunning = ((AVCaptureSession *)object).isRunning;
        if (isRunning) {
            //添加动画
            [self addAnimation];
        }else{
            //移除动画
            [self removeAnimation];
        }
    }
}
//添加扫码动画
-(void)addAnimation{
    UIView *line = [self.view viewWithTag:line_tag];
    line.hidden = NO;
    CABasicAnimation *animation = [self moveTime:2 fromY:[NSNumber numberWithFloat:0] toY:[NSNumber numberWithFloat:self.view.frame.size.width - 60 -2] rep:OPEN_MAX];
    [line.layer addAnimation:animation forKey:@"lineAnimation"];
    
}
//移除扫码动画
-(void)removeAnimation{
    UIView *line = [self.view viewWithTag:line_tag];
    [line.layer removeAnimationForKey:@"lineAnimation"];
    line.hidden = YES;
}
-(CABasicAnimation *)moveTime:(float)time fromY:(NSNumber *)fromY toY:(NSNumber *)toY rep:(int)rep
{
    CABasicAnimation *anima = [CABasicAnimation animationWithKeyPath:@"transform.translation.y"];
    [anima setFromValue:fromY];
    [anima setToValue:toY];
    anima.duration = time;
    anima.delegate = self;
    anima.repeatCount = rep;
    //动画结束的时候,保持动画的最后状态
    anima.fillMode = kCAFillModeForwards;
    anima.removedOnCompletion = NO;
    //控制动画的速度
    anima.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    return anima;
}
-(void)setDidRecoiveBlock:(ScanQRCodeBlock)didRecoiveBlock
{
    _didRecoiveBlock = [didRecoiveBlock copy];
    
}

-(void)chooseImage
{
    UIImagePickerController *picker = [[UIImagePickerController alloc]init];
    picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    picker.delegate = self;
    picker.allowsEditing = YES;
    [self presentViewController:picker animated:YES completion:nil];
}
//选中单张照片
-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info
{
    [picker dismissViewControllerAnimated:YES completion:nil];
    __block UIImage *image = [info objectForKey:UIImagePickerControllerEditedImage];
    if (!image) {
        image = [info objectForKey:UIImagePickerControllerOriginalImage];
    }
    //系统自带的识别方法
    CIDetector *detector = [CIDetector detectorOfType:CIDetectorTypeQRCode context:nil options:@{ CIDetectorAccuracy : CIDetectorAccuracyHigh }];
    CGImageRef ref = (CGImageRef)image.CGImage;
    CIImage *cii = [CIImage imageWithCGImage:ref];
    NSArray *feacture = [detector featuresInImage:cii];
    if (feacture.count >= 1) {
        CIQRCodeFeature *feature = [feacture objectAtIndex:0];
        NSString *scanResult = feature.messageString;
        if (_didRecoiveBlock) {
            self.didRecoiveBlock(scanResult);
            
            [self selfRemoveFromSuperview];
        } else {
            if (IOS8_OrLater) {
                UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"扫码" message:scanResult preferredStyle:UIAlertControllerStyleAlert];
                [alert addAction:[UIAlertAction actionWithTitle:@"好" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
                    [session startRunning];
                }]];
                [self presentViewController:alert animated:YES completion:nil];
            } else {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"扫码" message:scanResult delegate:self cancelButtonTitle:@"好" otherButtonTitles:nil];
                [alert show];
            }
        }
    }
}
- (void)selfRemoveFromSuperview{
    [session removeObserver:self forKeyPath:@"running" context:nil];
    [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        self.view.alpha = 0;
    } completion:^(BOOL finished) {
        [self.view removeFromSuperview];
        [self removeFromParentViewController];
    }];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault animated:YES];
}



@end
