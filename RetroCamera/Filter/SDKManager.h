//
//  SDKManager.h
//  iBeautyCameraSwift
//
//  Created by Junsung Park on 2018. 4. 19..
//  Copyright © 2018년 Junsung Park. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <GPUImage/GPUImage.h>
@interface SDKManager : NSObject
{
    
}
@property (nonatomic, assign) BOOL snapShot;
@property (nonatomic, retain) UIImage *image;
- (void)processStillImage:(UIImage*)inputImage filter:(GPUImageOutput*)stillImageFilter;
- (NSString*)getVersion;
+ (id)sharedManager;
- (UIImage*)takePicture:(GPUImageStillCamera*)camera;
- (UIImage*)takePicture2:(GPUImageFilter*)filter;
-(CVPixelBufferRef)imageToYUVPixelBuffer:(UIImage *)image;


@end
