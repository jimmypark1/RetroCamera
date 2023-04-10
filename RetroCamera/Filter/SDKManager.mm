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
-(CVPixelBufferRef)imageToYUVPixelBuffer:(UIImage *)image
{
    // convert to CGImage & dump to bitmapData
    
    CGImageRef imageRef = [image CGImage];
    int width  = (int)CGImageGetWidth(imageRef);
    int height = (int)CGImageGetHeight(imageRef);
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    NSUInteger bytesPerPixel = 4;
    NSUInteger bytesPerRow = ((bytesPerPixel*width+255)/256)*256;
    NSUInteger bitsPerComponent = 8;
    GLubyte* bitmapData = (GLubyte *)malloc(bytesPerRow*height); // if 4 components per pixel (RGBA)
    CGContextRef context = CGBitmapContextCreate(bitmapData, width, height,
                                                 bitsPerComponent, bytesPerRow, colorSpace,
                                                 kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big);
    CGColorSpaceRelease(colorSpace);
    
    CGContextDrawImage(context, CGRectMake(0, 0, width, height), imageRef);
    CGContextRelease(context);
    
    // 创建YUV pixelbuffer
    
    CVPixelBufferRef yuvPixelBuffer;
    CFMutableDictionaryRef attrs = CFDictionaryCreateMutable(kCFAllocatorDefault, 1, &kCFTypeDictionaryKeyCallBacks, &kCFTypeDictionaryValueCallBacks);
    CFDictionarySetValue(attrs, kCVPixelBufferIOSurfacePropertiesKey, (void*)[NSDictionary dictionary]);
    CFDictionarySetValue(attrs, kCVPixelBufferOpenGLESCompatibilityKey, (void*)[NSNumber numberWithBool:YES]);
    
    ////420YpCbCr8BiPlanar是半 plannar
    CVReturn err = CVPixelBufferCreate(kCFAllocatorDefault, (int)image.size.width, (int)image.size.height, kCVPixelFormatType_420YpCbCr8BiPlanarVideoRange, attrs, &yuvPixelBuffer);
    if (err) {
        return NULL;
    }
    CFRelease(attrs);
    
    CVPixelBufferLockBaseAddress(yuvPixelBuffer, 0);
    
    uint8_t * yPtr = (uint8_t *)CVPixelBufferGetBaseAddressOfPlane(yuvPixelBuffer, 0);
    size_t strideY = CVPixelBufferGetBytesPerRowOfPlane(yuvPixelBuffer, 0);
    
    uint8_t * uvPtr = (uint8_t *)CVPixelBufferGetBaseAddressOfPlane(yuvPixelBuffer, 1);
    size_t strideUV = CVPixelBufferGetBytesPerRowOfPlane(yuvPixelBuffer, 1);
    
    for (int j = 0; j < image.size.height; j++) {
        for (int i = 0; i < image.size.width; i++) {
            float r  = bitmapData[j*bytesPerRow + i*4 + 0];
            float g  = bitmapData[j*bytesPerRow + i*4 + 1];
            float b  = bitmapData[j*bytesPerRow + i*4 + 2];
            
            int16_t y = (0.257*r + 0.504*g + 0.098*b) + 16;
            if (y > 255) {
                y = 255;
            } else if (y < 0) {
                y = 0;
            }
            
            yPtr[j*strideY + i] = (uint8_t)y;
        }
    }
    
    for (int j = 0; j < image.size.height/2; j++) {
        for (int i = 0; i < image.size.width/2; i++) {
            float r  = bitmapData[j*2*bytesPerRow + i*2*4 + 0];
            float g  = bitmapData[j*2*bytesPerRow + i*2*4 + 1];
            float b  = bitmapData[j*2*bytesPerRow + i*2*4 + 2];
            
            int16_t u = (-0.148*r - 0.291*g + 0.439*b) + 128;
            int16_t v = (0.439*r - 0.368*g - 0.071*b) + 128;
            
            if (u > 255) {
                u = 255;
            } else if (u < 0) {
                u = 0;
            }
            
            if (v > 255) {
                v = 255;
            } else if (v < 0) {
                v = 0;
            }
            
            uvPtr[j*strideUV + i*2 + 0] = (uint8_t)u;
            uvPtr[j*strideUV + i*2 + 1] = (uint8_t)v;
        }
    }
    
    free(bitmapData);
    CVPixelBufferUnlockBaseAddress(yuvPixelBuffer, 0);
    
    return yuvPixelBuffer;
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
