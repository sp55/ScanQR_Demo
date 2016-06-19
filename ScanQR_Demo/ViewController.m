//
//  ViewController.m
//  ScanQR_Demo
//
//  Created by admin on 16/6/19.
//  Copyright © 2016年 AlezJi. All rights reserved.
//
//http://www.jianshu.com/p/4790a1307423
//iOS项目中添加二维码功能(集成二维码功能,即插即用)

#import "ViewController.h"
#import "AppDelegate.h"
#import "ScanQRCodeViewController.h"
#import <AVFoundation/AVFoundation.h>


@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

//按钮
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    [btn setBackgroundColor:[UIColor grayColor]];
    btn.frame = CGRectMake(0, 0, 160, 44);
    btn.center = self.view.center;
    [btn setTitle:@"进入扫码功能" forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(btnClick) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btn];
}
-(void)btnClick
{
    NSString *mediaType = AVMediaTypeVideo;
    AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:mediaType];
    if (authStatus == AVAuthorizationStatusDenied) {//关闭系统权限
        if (IOS8_OrLater) {
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"相机访问受限" message:@"请在IPhone的\"设置->隐私->相机\"选项中,允许\"XMSweep\"访问你的照相机." preferredStyle:UIAlertControllerStyleAlert];
            [alert addAction:[UIAlertAction actionWithTitle:@"好" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            }]];
            [alert addAction:[UIAlertAction actionWithTitle:@"去设置" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                if ([self canOpenSystemSettingView]) {
                    [self systemSettingView];
                }
            }]];
            [self presentViewController:alert animated:YES completion:nil];
        }else {
            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"相机访问受限" message:@"请在IPhone的\"设置->隐私->相机\"选项中,允许\"XMSweep\"访问你的照相机." delegate:nil cancelButtonTitle:@"好的" otherButtonTitles: nil];
            [alert show];
        }
        return;
    }
    
    
    //然后我们就可以自己创建一个控制器来跳转扫描二维码功能,同时我们通过Block回调来得到扫描得到的结果.
    ScanQRCodeViewController *ScanQRVC = [[ScanQRCodeViewController alloc]init];
    ScanQRVC.view.alpha = 0;
    AppDelegate *appdelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    [appdelegate.window.rootViewController addChildViewController:ScanQRVC];
    [appdelegate.window.rootViewController.view addSubview:ScanQRVC.view];//直接添加到跟视图控制器上
    [ScanQRVC setDidRecoiveBlock:^(NSString *result) {
        NSLog(@"%@",result);
    }];
    [UIView animateWithDuration:0.3 animations:^{
        ScanQRVC.view.alpha = 1;
    }];
    
}
//可以打开设置
-(BOOL)canOpenSystemSettingView{
    if (IOS8_OrLater) {
        NSURL *url = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
        if ([[UIApplication sharedApplication]canOpenURL:url]) {
            return YES;
        }else {
            return NO;
        }
    }else{
        return NO;
    }
}
//打开设置
-(void)systemSettingView{
    if (IOS8_OrLater) {
        NSURL *url = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
        if ([[UIApplication sharedApplication]canOpenURL:url]) {
            [[UIApplication sharedApplication]openURL:url];
        }
    }
}


@end
