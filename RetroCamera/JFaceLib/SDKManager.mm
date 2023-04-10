//
//  SDKManager.m
//  iBeautyCameraSwift
//
//  Created by Junsung Park on 2018. 4. 19..
//  Copyright © 2018년 Junsung Park. All rights reserved.
//

#import "SDKManager.h"
#import <GPUImage/GPUImage.h>

@implementation SDKManager

+ (id)sharedManager
{
    static SDKManager *sharedMyManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedMyManager = [[self alloc] init];
    });
    return sharedMyManager;
}

- (void)processStillImage:(UIImage*)inputImage filter:(GPUImageOutput*)stillImageFilter
{
    
    GPUImagePicture *stillImageSource = [[GPUImagePicture alloc] initWithImage:inputImage];
    
    [stillImageSource addTarget:stillImageFilter];
    
    [stillImageFilter useNextFrameForImageCapture];
    [stillImageSource processImage];
    
    UIImage *currentFilteredVideoFrame = [stillImageFilter imageFromCurrentFramebuffer];
    
    self.image = [[UIImage alloc]initWithCGImage:currentFilteredVideoFrame.CGImage scale:1.0 orientation:UIImageOrientationUp];
    
   // return currentFilteredVideoFrame;
}

- (NSString*)getVersion
{
    NSString * version = [[NSBundle mainBundle] objectForInfoDictionaryKey: @"CFBundleShortVersionString"];

    return version;
}

- (UIImage*)takePicture:(GPUImageStillCamera*)camera
{
    
    GPUImageFramebuffer *outputFramebuffer =  [[GPUImageContext sharedFramebufferCache] fetchFramebufferForSize:CGSizeMake(480, 640) textureOptions:camera.outputTextureOptions onlyTexture:NO];
    [outputFramebuffer activateFramebuffer];
    UIDeviceOrientation deviceOrientation = [[UIDevice currentDevice] orientation];
    UIImageOrientation imageOrientation = UIImageOrientationLeft;
    switch (deviceOrientation)
    {
        case UIDeviceOrientationPortrait:
            imageOrientation = UIImageOrientationUp;
            break;
        case UIDeviceOrientationPortraitUpsideDown:
            imageOrientation = UIImageOrientationDown;
            break;
        case UIDeviceOrientationLandscapeLeft:
            imageOrientation = UIImageOrientationLeft;
            break;
        case UIDeviceOrientationLandscapeRight:
            imageOrientation = UIImageOrientationRight;
            break;
        default:
            imageOrientation = UIImageOrientationUp;
            break;
    }
    
    CGImageRef image = [outputFramebuffer newCGImageFromFramebufferContents];
    
    UIImage *finalImage = [UIImage imageWithCGImage:image scale:1.0 orientation:imageOrientation];
    CGImageRelease(image);
    
    NSLog(@"test");
    return finalImage;
    
}
- (UIImage*)takePicture2:(GPUImageFilter*)filter
{
    
    GPUImageFramebuffer *outputFramebuffer =  [[GPUImageContext sharedFramebufferCache] fetchFramebufferForSize:CGSizeMake(480, 640) textureOptions:filter.outputTextureOptions onlyTexture:NO];
    [outputFramebuffer activateFramebuffer];
    UIDeviceOrientation deviceOrientation = [[UIDevice currentDevice] orientation];
    UIImageOrientation imageOrientation = UIImageOrientationLeft;
    switch (deviceOrientation)
    {
        case UIDeviceOrientationPortrait:
            imageOrientation = UIImageOrientationUp;
            break;
        case UIDeviceOrientationPortraitUpsideDown:
            imageOrientation = UIImageOrientationDown;
            break;
        case UIDeviceOrientationLandscapeLeft:
            imageOrientation = UIImageOrientationLeft;
            break;
        case UIDeviceOrientationLandscapeRight:
            imageOrientation = UIImageOrientationRight;
            break;
        default:
            imageOrientation = UIImageOrientationUp;
            break;
    }
    
    CGImageRef image = [outputFramebuffer newCGImageFromFramebufferContents];
    
    UIImage *finalImage = [UIImage imageWithCGImage:image scale:1.0 orientation:imageOrientation];
    CGImageRelease(image);
    
    NSLog(@"test");
    return finalImage;
    
}


@end
