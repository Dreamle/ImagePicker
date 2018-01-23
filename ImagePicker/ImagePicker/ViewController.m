//
//  ViewController.m
//  ImagePicker
//
//  Created by limeng on 2018/1/23.
//  Copyright © 2018年 limeng. All rights reserved.
//

#import "ViewController.h"

#import "ImagePickerViewController.h"

@interface ViewController ()
@property (weak, nonatomic) IBOutlet UIImageView *imageView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

}

- (IBAction)gotoCamera:(id)sender {

    [[ImagePickerViewController instaceImagePickerViewController] openCameraWithViewController:self withBlock:^(NSData * _Null_unspecified data, NSString * _Null_unspecified filePathStr) {

        self.imageView.image = [UIImage imageWithData:data];
    }];

}


- (IBAction)gotoAlbum:(id)sender {
    [[ImagePickerViewController instaceImagePickerViewController] openPictureWithViewController:self withBlock:^(NSData * _Null_unspecified data, NSString * _Null_unspecified filePathStr) {
          self.imageView.image = [UIImage imageWithData:data];
    }];
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
