//
//  ImagePickerViewController.h
//  
//
//  Created by limeng on 16/7/25.
//  Copyright © 2016年 limeng. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ImagePickerViewController : UIViewController
<
UINavigationControllerDelegate,
UIImagePickerControllerDelegate
>

+(nonnull ImagePickerViewController *)instaceImagePickerViewController;

// 打开相机
- (void)openCameraWithViewController:(nonnull UIViewController*)viewCtrl
                           withBlock:(void(^_Null_unspecified)(NSData * _Null_unspecified data,NSString * _Null_unspecified filePathStr))cameraBlock;

// 打开相册
- (void)openPictureWithViewController:(nonnull UIViewController*)viewCtrl
                         withBlock:(void(^_Null_unspecified)(NSData * _Null_unspecified  data, NSString * _Null_unspecified filePathStr))picsBlock;
@end
