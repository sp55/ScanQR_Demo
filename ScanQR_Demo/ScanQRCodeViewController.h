//
//  ScanQRCodeViewController.h
//  ScanQR_Demo
//
//  Created by admin on 16/6/19.
//  Copyright © 2016年 AlezJi. All rights reserved.
//

#import <UIKit/UIKit.h>
#define IOS8_OrLater  ([[[UIDevice currentDevice] systemVersion] intValue] >= 8)
#define kScreenWidth      [[UIScreen mainScreen] bounds].size.width
#define kScreenHeight      [[UIScreen mainScreen] bounds].size.height



@interface ScanQRCodeViewController : UIViewController


typedef void (^ScanQRCodeBlock)(NSString *result);
@property(nonatomic,copy)ScanQRCodeBlock didRecoiveBlock;
-(void)setDidRecoiveBlock:(ScanQRCodeBlock)didRecoiveBlock;


@end
