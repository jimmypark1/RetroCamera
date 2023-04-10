//
//  CropFilter.m
//  iBeautyCameraSwift
//
//  Created by Junsung Park on 2018. 5. 14..
//  Copyright © 2018년 Junsung Park. All rights reserved.
//

#import "CropFilter.h"

@implementation CropFilter
- (void)setFrameBuffer
{
    outputFramebuffer = [[GPUImageContext sharedFramebufferCache] fetchFramebufferForSize:CGSizeMake(480,480) textureOptions:self.outputTextureOptions onlyTexture:NO];
    [outputFramebuffer activateFramebuffer];
    
}

- (UIImage*)getFrameBuffer:(GPUImageFilter*)filter size:(CGSize)size
{
    GPUImageFramebuffer *_outputFramebuffer = [[GPUImageContext sharedFramebufferCache] fetchFramebufferForSize:size textureOptions:filter.outputTextureOptions onlyTexture:NO];
    [_outputFramebuffer activateFramebuffer];
    
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
    
    CGImageRef image = [_outputFramebuffer newCGImageFromFramebufferContents];
    
    UIImage *finalImage = [UIImage imageWithCGImage:image scale:1.0 orientation:imageOrientation];
    CGImageRelease(image);
    
    return finalImage;
}
@end
