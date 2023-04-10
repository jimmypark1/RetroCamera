//
//  Scene.m
//  JFace
//
//  Created by Junsung Park on 2018. 3. 26..
//  Copyright © 2018년 Junsung Park. All rights reserved.
//

#import "Scene.h"
#import "jFaceLib.h"

@interface Scene()
{
  //  BOOL takeSnapShot;
}
@end

@implementation Scene

- (instancetype)init
{
    if (!(self = [super init]))
    {
        return nil;
    }
   // [self setSourceY];
   // [self setDestWidthMirrored:mirroed];
   // takeSnapShot = NO;
    [self useNextFrameForImageCapture];
    
    
    return self;
}

- (void)takePicture
{
  //  self.takeSnapShot = YES;
}
- (void)resetBufferSize:(CGSize)size
{
    [self.lib resetBufferSize:size];
}
- (void)initWithScene:(NSString*)sceneName filterName:(NSString*)name mirroed:(BOOL)mirroed resType:(int)rType
{
    [self.lib getScene:sceneName fileterName:name stickerName:@"none" resType:(int)rType];
    
    [self setSourceY];
    [self setDestWidthMirrored:mirroed];
    [self useNextFrameForImageCapture];
    
}
- (void)initWithScene2:(NSString*)sceneName filterName:(NSString*)name mirroed:(BOOL)mirroed resType:(int)rType vline:(BOOL)bVline openEye:(BOOL)bOpenEyes bigEye:(BOOL)bBigEyes
{
    //- (void)getScene2:(NSString* )sceneName fileterName:(NSString *)filterName stickerName:(NSString *)stickerName resType:(int)rType vline:(BOOL)bVline openEyes:(BOOL)bOpenEyes bigEyes:(BOOL)bBigEyes;

    self.lib.earringName =  self.earringName;
    self.lib.glassesName = self.glassesName;
    self.lib.hatName = self.hatName;
    self.lib.mustacheName = self.mustacheName;
    
    [self.lib getScene2:sceneName fileterName:name stickerName:@"none" resType:(int)rType vline:bVline openEyes:bOpenEyes bigEyes:bBigEyes];
    
    [self setSourceY];
    [self setDestWidthMirrored:mirroed];
    [self useNextFrameForImageCapture];
    
}


- (void)renderToTextureWithVertices:(const GLfloat *)vertices textureCoordinates:(const GLfloat *)textureCoordinates;
{
  //  [super renderToTextureWithVertices:vertices textureCoordinates:textureCoordinates];
    if (self.preventRendering)
    {
        [firstInputFramebuffer unlock];
        return;
    }
    
    outputFramebuffer = [[GPUImageContext sharedFramebufferCache] fetchFramebufferForSize:[self sizeOfFBO] textureOptions:self.outputTextureOptions onlyTexture:NO];
    [outputFramebuffer activateFramebuffer];
    if (usingNextFrameForImageCapture)
    {
        [outputFramebuffer lock];
    }
    
    [self setUniformsForProgramAtIndex:0];
    [self.lib render];
    
    [firstInputFramebuffer unlock];
    
    if (usingNextFrameForImageCapture)
    {
        dispatch_semaphore_signal(imageCaptureSemaphore);
    }
}
/*
- (void)setInputFramebuffer:(GPUImageFramebuffer *)newInputFramebuffer atIndex:(NSInteger)textureIndex;
{
    [self setInputFramebuffer:newInputFramebuffer atIndex:4];
    
}
 */

- (BOOL)initSDKFrameRate:(double)framerate fov:(double)fov
{
    self.lib = [[jFaceLib alloc] init];
    BOOL ret =  [self.lib initSDKFrameRate:framerate fov:fov];
    
    return ret;
}
- (BOOL)initSDKFrameRate:(float)framerate fov:(float)fov size:(CGSize)size
{
    self.lib = [[jFaceLib alloc] init];
    BOOL ret =  [self.lib initSDKFrameRate:framerate fov:fov size:size];
    
    return ret;

}

- (void)processBuffer:(CMSampleBufferRef)sampleBuffer  orientation:(int)deviceOrientation front:(BOOL)bFont
{
    [self.lib processBuffer:sampleBuffer orientation:(int)deviceOrientation front:bFont];
}
- (void)processBuffer2:(CVPixelBufferRef)pixelBuffer  orientation:(int)deviceOrientation front:(BOOL)bFont
{
    [self.lib processBuffer2:pixelBuffer orientation:(int)deviceOrientation front:bFont];

}
- (void)setSourceY
{
     [self.lib setSourceY];
    
}

- (void)setDestWidthMirrored:(int)mirrored;
{
    [self.lib setDestWidthMirrored:mirrored];
    
}
- (void)close
{
    [self.lib close];
}

- (void)releaseScene
{
    [self.lib releaseScene];
}
@end
