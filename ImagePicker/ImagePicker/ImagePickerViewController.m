//
//  ImagePickerViewController.m
//  
//
//  Created by limeng on 16/7/25.
//  Copyright © 2016年 limeng. All rights reserved.
//

#import "ImagePickerViewController.h"
#import <AVFoundation/AVCaptureDevice.h>
#import <AVFoundation/AVMediaFormat.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import <Photos/Photos.h>
#import <CoreLocation/CLLocationManager.h>

typedef void(^ImageDataBlock)(NSData * data,NSString *filePathStr);
@interface ImagePickerViewController ()
{
    ImageDataBlock _imageDataBlock;
}


@property (nonatomic, strong) UIViewController *currentVC;
@end

@implementation ImagePickerViewController
- (void)viewDidLoad {
    [super viewDidLoad];

}

+ (nonnull ImagePickerViewController *)instaceImagePickerViewController
{
    static ImagePickerViewController *sharedInstace = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstace = [[ImagePickerViewController alloc] init];
    });
    return sharedInstace;
}


// 打开相机
- (void)openCameraWithViewController:(UIViewController*)controller
                           withBlock:(void(^)(NSData * data,NSString *filePathStr))cameraBlock
{
    _currentVC = controller;
    AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    if(authStatus == AVAuthorizationStatusRestricted || authStatus ==AVAuthorizationStatusDenied) {
        [self showWithTitle:@"未开启权限,现在去设置吗？" isJustWarnign:NO];
        return;
    }
    
    BOOL isCamera = [UIImagePickerController isCameraDeviceAvailable:UIImagePickerControllerCameraDeviceRear];
    if (!isCamera) {
        [self showWithTitle:@"没有摄像头" isJustWarnign:YES];
        return ;
    }
    

    [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
       
        if (granted) {

            dispatch_after(0.5, dispatch_get_main_queue(), ^{
                UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
                imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
                imagePicker.delegate = self;
                // 编辑模式
                imagePicker.allowsEditing = YES;

                _imageDataBlock = [cameraBlock copy];
                [controller  presentViewController:imagePicker animated:YES completion:nil];
            });

        } else { NSLog(@"Denied or Restricted"); }
        
    }];
}

// 打开相册
- (void)openPictureWithViewController:(UIViewController *)controller
                         withBlock:(void(^)(NSData * data,NSString *filePathStr))picsBlock
{
    _currentVC = controller;

    ALAuthorizationStatus author = [ALAssetsLibrary authorizationStatus];
    if (author == kCLAuthorizationStatusRestricted || author ==kCLAuthorizationStatusDenied) {

        [self showWithTitle:@"请在iPhone的“设置-隐私-相机”选项中，允许本应用程序访问你的相册。" isJustWarnign:NO];
        return;
    }
    
    [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
        if (status == PHAuthorizationStatusAuthorized) {
            NSLog(@"Authorized");

             dispatch_after(0.5, dispatch_get_main_queue(), ^{
                UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
                imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
                imagePicker.delegate = self;
                imagePicker.allowsEditing = YES;
                _imageDataBlock = [picsBlock copy];
                [controller  presentViewController:imagePicker animated:YES completion:nil];
            });
        }
        else{
            NSLog(@"Denied or Restricted");
        }}];

}



// 选中照片
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    //初始化imageNew为从相机中获得的--
    UIImage *imageNew = [info objectForKey:@"UIImagePickerControllerEditedImage"];
    //设置image的尺寸
    CGSize imagesize = imageNew.size;

    //对图片大小进行压缩--
//    imageNew = [self imageWithImage:imageNew scaledToSize:imagesize];
    NSData *imageData = UIImagePNGRepresentation(imageNew);

    //保存图片到沙盒
    [self saveImage:imageData];
    
    picker.delegate = nil;
    [picker dismissViewControllerAnimated:YES completion:nil];
    
}

// 取消相册
- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [picker dismissViewControllerAnimated:YES completion:NULL];
}

#pragma mark -
#pragma mark - Others
//对图片尺寸进行压缩--
-(UIImage*)imageWithImage:(UIImage*)image scaledToSize:(CGSize)newSize
{
    // Create a graphics image context
    UIGraphicsBeginImageContext(newSize);
    
    // Tell the old image to draw in this new context, with the desired
    // new size
    [image drawInRect:CGRectMake(0,0,newSize.width,newSize.height)];
    
    // Get the new image from the context
    UIImage* newImage = UIGraphicsGetImageFromCurrentImageContext();
    
    // End the context
    UIGraphicsEndImageContext();
    
    // Return the new image.
    return newImage;
}

- (void)saveImage:(NSData *)imageData
{
    NSArray* paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString* documentsDirectory = [paths objectAtIndex:0];
    NSString* fullPathToFile = [documentsDirectory stringByAppendingPathComponent:@"fileName.png"];
    BOOL  suces = [imageData writeToFile:fullPathToFile atomically:NO];
    if (suces)
    {
        if (_imageDataBlock)
        {
            _imageDataBlock(imageData,fullPathToFile);
            _imageDataBlock = nil;
        }
    }
}


- (void)showWithTitle:(NSString *)titleStr isJustWarnign:(BOOL)isWarning {
    
    UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:titleStr message:nil preferredStyle:UIAlertControllerStyleAlert];

    if (isWarning) {
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:nil];
        [alertVC addAction:cancelAction];

    } else {

        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"否" style:UIAlertActionStyleDefault handler:nil];

        UIAlertAction *sureAction = [UIAlertAction actionWithTitle:@"是" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {

            NSURL * url = [NSURL URLWithString: UIApplicationOpenSettingsURLString];
            if ([[UIApplication sharedApplication] canOpenURL:url] ) {

                NSURL*url = [NSURL URLWithString:UIApplicationOpenSettingsURLString];

                dispatch_after(0.2, dispatch_get_main_queue(), ^{
                     [[UIApplication sharedApplication] openURL:url];
                });
            }
        }];

        [alertVC addAction:cancelAction];
        [alertVC addAction:sureAction];
    }

    [_currentVC presentViewController:alertVC animated:YES completion:nil];
}



@end
