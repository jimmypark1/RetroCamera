//
//  Scene.h
//  JFace
//
//  Created by Junsung Park on 2018. 3. 26..
//  Copyright © 2018년 Junsung Park. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GPUImage/GPUImage.h>
#import "jFaceLib.h"

@interface Scene : GPUImageFilter
{
    
}
@property (nonatomic, retain)  jFaceLib *lib;

@property (nonatomic, retain)  NSString *earringName;
@property (nonatomic, retain)  NSString *glassesName;
@property (nonatomic, retain)  NSString *hatName;
@property (nonatomic, retain)  NSString *mustacheName;


- (BOOL)initSDKFrameRate:(double)framerate fov:(double)fov;
- (BOOL)initSDKFrameRate:(float)framerate fov:(float)fov size:(CGSize)size;

- (void)initWithScene:(NSString*)sceneName filterName:(NSString*)name mirroed:(BOOL)mirroed resType:(int)rType;
//- (void)initWithScene2:(NSString*)sceneName filterName:(NSString*)name mirroed:(BOOL)mirroed resType:(int)rType vline:(BOOL)bVline openEye:(BOOL)bOpenEyes;
- (void)initWithScene2:(NSString*)sceneName filterName:(NSString*)name mirroed:(BOOL)mirroed resType:(int)rType vline:(BOOL)bVline openEye:(BOOL)bOpenEyes bigEye:(BOOL)bBigEyes;

- (void)processBuffer:(CMSampleBufferRef)sampleBuffer  orientation:(int)deviceOrientation front:(BOOL)bFont;
- (void)processBuffer2:(CVPixelBufferRef)pixelBuffer  orientation:(int)deviceOrientation front:(BOOL)bFont;
- (void)setSourceY;
- (void)setDestWidthMirrored:(int)mirrored;
- (void)releaseScene;
- (void)takePicture;
- (void)close;

- (void)resetBufferSize:(CGSize)size;

@end
