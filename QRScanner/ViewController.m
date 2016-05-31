//
//  ViewController.m
//  QRScanner
//
//  Created by Audient Xie on 16/5/31.
//  Copyright © 2016年 xjk. All rights reserved.
//

#import <AVFoundation/AVFoundation.h>
#import "ViewController.h"
#import "WebViewController.h"

@interface ViewController ()<AVCaptureMetadataOutputObjectsDelegate>
@property (strong, nonatomic) AVCaptureSession * session;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    [self initSession];
}

-(void)initSession {
    AVCaptureDevice * device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    AVCaptureDeviceInput * input = [AVCaptureDeviceInput deviceInputWithDevice:device error:nil];
    if (!input)
        return;

    AVCaptureMetadataOutput * output = [[AVCaptureMetadataOutput alloc]init];
    [output setMetadataObjectsDelegate:self queue:dispatch_get_main_queue()];
    
    self.session = [[AVCaptureSession alloc]init];
    [self.session setSessionPreset:AVCaptureSessionPresetMedium];
    [self.session addInput:input];
    [self.session addOutput:output];
    output.metadataObjectTypes=@[AVMetadataObjectTypeQRCode,
                                 AVMetadataObjectTypeEAN13Code,
                                 AVMetadataObjectTypeEAN8Code,
                                 AVMetadataObjectTypeCode128Code];
    
    AVCaptureVideoPreviewLayer * layer = [AVCaptureVideoPreviewLayer layerWithSession:self.session];
    layer.videoGravity=AVLayerVideoGravityResizeAspectFill;
    layer.frame=self.view.layer.bounds;
    [self.view.layer insertSublayer:layer atIndex:0];
    //开始捕获
}

-(void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self.session startRunning];
}

- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects fromConnection:(AVCaptureConnection *)connection {
    AVMetadataMachineReadableCodeObject *metadataObject = metadataObjects.firstObject;
    if ([metadataObject.type isEqualToString:AVMetadataObjectTypeQRCode] ) { // 成功后系统不会停止扫描，可以用一个变量来控制。
        [self.session stopRunning];
        NSURL *url = [NSURL URLWithString:metadataObject.stringValue];
        if ( [url isKindOfClass:[NSURL class]] && url.scheme && url.host ) {
            WebViewController *vc = [[WebViewController alloc] initWithNibName:@"WebViewController" bundle:nil];
            vc.url = url;
            [self.navigationController pushViewController:vc animated:YES];
        }
        else {
            UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:@"字符如下"
                                                                             message:metadataObject.stringValue
                                                                      preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *confirmAction = [UIAlertAction actionWithTitle:@"确定"
                                                                    style:UIAlertActionStyleDefault
                                                                  handler:^(UIAlertAction * _Nonnull action) {
                                                                      [self.session startRunning];
                                                                  }];
            [alertVC addAction:confirmAction];
            [self presentViewController:alertVC animated:YES completion:nil];

        }
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
