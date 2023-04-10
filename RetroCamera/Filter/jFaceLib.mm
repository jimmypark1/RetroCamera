//
//  jFaceLib.m
//  jFaceLib
//
//  Created by Junsung Park on 2018. 3. 26..
//  Copyright © 2018년 Junsung Park. All rights reserved.
//

#import "jFaceLib.h"
#include "binaryface.h"
#import <Foundation/Foundation.h>
#import <CoreMedia/CoreMedia.h>
#include "base_face_scene.hpp"
#import <UIKit/UIKit.h>
#include "scene_list.hpp"
#import "itemType.h"


typedef struct  {
    binaryface_context_t context;
    binaryface_context_info_t contextInfo;
    binaryface_session_config_t session_config;
    binaryface_session_t session;
    binaryface_session_info_t session_info;
    NSMutableData *yBuffer;
    NSMutableData *uvBuffer;
} BinaryFaceStruct;

typedef enum Orientation {
    DeviceOrientationUnknown,
    DeviceOrientationPortrait,            // Device oriented vertically, home button on the bottom
    DeviceOrientationPortraitUpsideDown,  // Device oriented vertically, home button on the top
    DeviceOrientationLandscapeLeft,       // Device oriented horizontally, home button on the right
    DeviceOrientationLandscapeRight,      // Device oriented horizontally, home button on the left
    DeviceOrientationFaceUp,              // Device oriented flat, face up
    eviceOrientationFaceDown             // Device oriented flat, face down
};

@interface jFaceLib()
{
    BinaryFaceStruct binaryFace;
    Size renderViewSize;
    bool isAlerted;
    int frameCount;
    
    BaseFaceScene *faceScene;
    
    //NSMutableArray *targets;
    std::vector<BaseFaceScene*> targets;

}

@end


@implementation jFaceLib

- (void)initBinaryFaceStruct {
    
    binaryFace.context = 0;
    binaryFace.session = 0;
  //  renderViewSize = CGSizeMake(1280, 720);
    isAlerted = false;
  //  idleMode = false;
   // checkActionTrigger = false;
   // actionTriggerMessage = @"";
    //actionTriggerDisappearTime = [[NSDate date] timeIntervalSince1970];
}

- (BOOL)initSDKFrameRate:(float)framerate fov:(float)fov
{
    [self initBinaryFaceStruct];
    NSString *API_KEY = @"junsoft-beautycamera-74cd92";
    
    NSString *sourcePath = [[NSBundle mainBundle] pathForResource:@"model" ofType:@"bf2"];
    
    binaryface_set_log_level(BINARYFACE_LOG_LEVEL_OFF);
    
    BOOL ret0 = binaryface_open_context(
                            [sourcePath UTF8String],
                            [API_KEY UTF8String],
                            BINARYFACE_SDK_VERSION,
                            &binaryFace.context,
                            &binaryFace.contextInfo);
    
    //  Lists all action triggers
    
    int num_action_triggers;
   // float frameRate = ((AVFrameRateRange *)[camera.inputCamera.activeFormat.videoSupportedFrameRateRanges objectAtIndex:0]).maxFrameRate;
    
    
    binaryface_get_num_action_triggers(binaryFace.context, &num_action_triggers);
    
    NSMutableArray *allActionTriggers = [NSMutableArray new];
    
    float width =1280.0f;
    float height =720.0f;
    
    
    memset(&binaryFace.session_config, 0, sizeof(binaryFace.session_config));
    
    binaryFace.session_config.image_width = 1280;
    binaryFace.session_config.image_height = 720;
    binaryFace.session_config.async_face_detection = 1;
    binaryFace.session_config.frame_per_second = framerate;
    binaryFace.session_config.max_num_faces = 1;
    binaryFace.session_config.horizontal_fov = fov;//camera.inputCamera.activeFormat.videoFieldOfView;
    binaryFace.session_config.detection_fps = 0.0f;
    
    BOOL ret = binaryface_open_session(binaryFace.context,
                            &binaryFace.session_config,
                            &binaryFace.session,
                            &binaryFace.session_info);
    
    //  Data buffer for color queries
    binaryFace.yBuffer = [[NSMutableData alloc] initWithLength:(unsigned int)(width) * (unsigned int)(height)];
    binaryFace.uvBuffer = [[NSMutableData alloc] initWithLength:(unsigned int)(width) * (unsigned int)(height) / 2];

    
    NSLog(@"binaryface_open_session: %d",ret);
    
    return ret;
}

- (void)resetBufferSize:(CGSize)size
{
    binaryFace.session_config.image_width = size.width;
    binaryFace.session_config.image_height = size.height;
    
    BOOL ret = binaryface_open_session(binaryFace.context,
                                       &binaryFace.session_config,
                                       &binaryFace.session,
                                       &binaryFace.session_info);
    
    binaryFace.yBuffer = [[NSMutableData alloc] initWithLength:(unsigned int)(size.width) * (unsigned int)(size.height)];
    binaryFace.uvBuffer = [[NSMutableData alloc] initWithLength:(unsigned int)(size.width) * (unsigned int)(size.height) / 2];
    
    

}
- (void)close
{
    if (binaryFace.session) {
        binaryface_close_session(binaryFace.session);
        binaryFace.session = 0;
    }
    
    if (binaryFace.context) {
        binaryface_close_context(binaryFace.context);
        binaryFace.context = 0;
    }
}

- (BOOL)initSDKFrameRate:(float)framerate fov:(float)fov size:(CGSize)size
{
    [self initBinaryFaceStruct];
    NSString *API_KEY = @"junsoft-beautycamera-74cd92";
    
    NSString *sourcePath = [[NSBundle mainBundle] pathForResource:@"model" ofType:@"bf2"];
    
    binaryface_set_log_level(BINARYFACE_LOG_LEVEL_OFF);
    
    BOOL ret0 = binaryface_open_context(
                                        [sourcePath UTF8String],
                                        [API_KEY UTF8String],
                                        BINARYFACE_SDK_VERSION,
                                        &binaryFace.context,
                                        &binaryFace.contextInfo);
    
    //  Lists all action triggers
    
    int num_action_triggers;
    // float frameRate = ((AVFrameRateRange *)[camera.inputCamera.activeFormat.videoSupportedFrameRateRanges objectAtIndex:0]).maxFrameRate;
    
    
    binaryface_get_num_action_triggers(binaryFace.context, &num_action_triggers);
    
    NSMutableArray *allActionTriggers = [NSMutableArray new];
    
    float width = size.width;
    float height = size.height;
    
    
    memset(&binaryFace.session_config, 0, sizeof(binaryFace.session_config));
    
    binaryFace.session_config.image_width = width;
    binaryFace.session_config.image_height = height;
    binaryFace.session_config.async_face_detection = 1;
    binaryFace.session_config.frame_per_second = framerate;
    binaryFace.session_config.max_num_faces = 1;
    binaryFace.session_config.horizontal_fov = fov;//camera.inputCamera.activeFormat.videoFieldOfView;
    binaryFace.session_config.detection_fps = 0.0f;
    
    BOOL ret = binaryface_open_session(binaryFace.context,
                                       &binaryFace.session_config,
                                       &binaryFace.session,
                                       &binaryFace.session_info);
    
    //  Data buffer for color queries
    binaryFace.yBuffer = [[NSMutableData alloc] initWithLength:(unsigned int)(width) * (unsigned int)(height)];
    binaryFace.uvBuffer = [[NSMutableData alloc] initWithLength:(unsigned int)(width) * (unsigned int)(height) / 2];
    
    
    NSLog(@"binaryface_open_session: %d",ret);
    
    return ret;
}

- (void)processBuffer:(CMSampleBufferRef)sampleBuffer  orientation:(int)deviceOrientation front:(BOOL)bFont
{
    int imageOrientation = BINARYFACE_IMAGE_ORIENTATION_FIRST_COLUMN_UP;
    
    if (bFont) {
        switch(deviceOrientation) {
            case DeviceOrientationPortrait:
                imageOrientation = BINARYFACE_IMAGE_ORIENTATION_FIRST_COLUMN_UP;
                break;
            case DeviceOrientationPortraitUpsideDown:
                imageOrientation = BINARYFACE_IMAGE_ORIENTATION_LAST_COLUMN_UP;
                break;
            case DeviceOrientationLandscapeLeft:
                imageOrientation = BINARYFACE_IMAGE_ORIENTATION_LAST_ROW_UP;
                break;
            case DeviceOrientationLandscapeRight:
                imageOrientation = BINARYFACE_IMAGE_ORIENTATION_FIRST_ROW_UP;
                break;
            default:
                ;
        }
    }
    else {
        switch(deviceOrientation) {
            case DeviceOrientationPortrait:
                imageOrientation = BINARYFACE_IMAGE_ORIENTATION_FIRST_COLUMN_UP;
                break;
            case DeviceOrientationPortraitUpsideDown:
                imageOrientation = BINARYFACE_IMAGE_ORIENTATION_LAST_COLUMN_UP;
                break;
            case DeviceOrientationLandscapeLeft:
                imageOrientation = BINARYFACE_IMAGE_ORIENTATION_FIRST_ROW_UP;
                break;
            case DeviceOrientationLandscapeRight:
                imageOrientation = BINARYFACE_IMAGE_ORIENTATION_LAST_ROW_UP;
                break;
            default:
                ;
        }
    }
    
    CFAbsoluteTime startTime = CFAbsoluteTimeGetCurrent();
    CVImageBufferRef pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
    CVPixelBufferLockBaseAddress(pixelBuffer, 0);
    void *baseAddressY = CVPixelBufferGetBaseAddressOfPlane(pixelBuffer, 0);
    void *baseAddressUV = CVPixelBufferGetBaseAddressOfPlane(pixelBuffer, 1);
    [binaryFace.yBuffer replaceBytesInRange:NSMakeRange(0, binaryFace.yBuffer.length) withBytes:baseAddressY length:binaryFace.yBuffer.length];
    [binaryFace.uvBuffer replaceBytesInRange:NSMakeRange(0, binaryFace.uvBuffer.length) withBytes:baseAddressUV length:binaryFace.uvBuffer.length];
    CVPixelBufferUnlockBaseAddress(pixelBuffer, 0);
    
    int ret = BINARYFACE_OK;
    
    if (binaryFace.session) {
        ret = binaryface_run_tracking(binaryFace.session,
                                      (const uint8_t *)[binaryFace.yBuffer mutableBytes],
                                      0,
                                      BINARYFACE_PIXEL_FORMAT_GRAY,
                                      imageOrientation);
      //  NSLog(@"binaryFace.session: %d",ret);
        
        
      
    }
    
    CFTimeInterval elapsedTimeInMs = 1000.0 * (CFAbsoluteTimeGetCurrent() - startTime);
    int numFaces = 0;
    binaryface_get_num_faces(binaryFace.session, &numFaces);
    
   // NSLog(@"numface: %d ret:%d",numFaces, ret);
    
   
}

- (void)processBuffer2:(CVPixelBufferRef)pixelBuffer  orientation:(int)deviceOrientation front:(BOOL)bFont
{
    int imageOrientation = BINARYFACE_IMAGE_ORIENTATION_FIRST_COLUMN_UP;
    
    if (bFont) {
        switch(deviceOrientation) {
            case DeviceOrientationPortrait:
                imageOrientation = BINARYFACE_IMAGE_ORIENTATION_FIRST_COLUMN_UP;
                break;
            case DeviceOrientationPortraitUpsideDown:
                imageOrientation = BINARYFACE_IMAGE_ORIENTATION_LAST_COLUMN_UP;
                break;
            case DeviceOrientationLandscapeLeft:
                imageOrientation = BINARYFACE_IMAGE_ORIENTATION_LAST_ROW_UP;
                break;
            case DeviceOrientationLandscapeRight:
                imageOrientation = BINARYFACE_IMAGE_ORIENTATION_FIRST_ROW_UP;
                break;
            default:
                ;
        }
    }
    else {
        switch(deviceOrientation) {
            case DeviceOrientationPortrait:
                imageOrientation = BINARYFACE_IMAGE_ORIENTATION_FIRST_COLUMN_UP;
                break;
            case DeviceOrientationPortraitUpsideDown:
                imageOrientation = BINARYFACE_IMAGE_ORIENTATION_LAST_COLUMN_UP;
                break;
            case DeviceOrientationLandscapeLeft:
                imageOrientation = BINARYFACE_IMAGE_ORIENTATION_FIRST_ROW_UP;
                break;
            case DeviceOrientationLandscapeRight:
                imageOrientation = BINARYFACE_IMAGE_ORIENTATION_LAST_ROW_UP;
                break;
            default:
                ;
        }
    }
    
    CFAbsoluteTime startTime = CFAbsoluteTimeGetCurrent();
    //CVImageBufferRef pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
    CVPixelBufferLockBaseAddress(pixelBuffer, 0);
    void *baseAddressY = CVPixelBufferGetBaseAddressOfPlane(pixelBuffer, 0);
    void *baseAddressUV = CVPixelBufferGetBaseAddressOfPlane(pixelBuffer, 1);
    [binaryFace.yBuffer replaceBytesInRange:NSMakeRange(0, binaryFace.yBuffer.length) withBytes:baseAddressY length:binaryFace.yBuffer.length];
    [binaryFace.uvBuffer replaceBytesInRange:NSMakeRange(0, binaryFace.uvBuffer.length) withBytes:baseAddressUV length:binaryFace.uvBuffer.length];
    CVPixelBufferUnlockBaseAddress(pixelBuffer, 0);
    
    int ret = BINARYFACE_OK;
    
    if (binaryFace.session) {
        ret = binaryface_run_tracking(binaryFace.session,
                                      (const uint8_t *)[binaryFace.yBuffer mutableBytes],
                                      0,
                                      BINARYFACE_PIXEL_FORMAT_GRAY,
                                      imageOrientation);
        //  NSLog(@"binaryFace.session: %d",ret);
        
        
        
    }
    
    CFTimeInterval elapsedTimeInMs = 1000.0 * (CFAbsoluteTimeGetCurrent() - startTime);
    int numFaces = 0;
    binaryface_get_num_faces(binaryFace.session, &numFaces);
    
    // NSLog(@"numface: %d ret:%d",numFaces, ret);
    
    
}
- (void)processBufferY:(unsigned char*)yBuffer uv:(unsigned char*)uvBuffer  orientation:(int)deviceOrientation front:(BOOL)bFont
{
    int imageOrientation = BINARYFACE_IMAGE_ORIENTATION_FIRST_COLUMN_UP;
    
    if (bFont) {
        switch(deviceOrientation) {
            case DeviceOrientationPortrait:
                imageOrientation = BINARYFACE_IMAGE_ORIENTATION_FIRST_COLUMN_UP;
                break;
            case DeviceOrientationPortraitUpsideDown:
                imageOrientation = BINARYFACE_IMAGE_ORIENTATION_LAST_COLUMN_UP;
                break;
            case DeviceOrientationLandscapeLeft:
                imageOrientation = BINARYFACE_IMAGE_ORIENTATION_LAST_ROW_UP;
                break;
            case DeviceOrientationLandscapeRight:
                imageOrientation = BINARYFACE_IMAGE_ORIENTATION_FIRST_ROW_UP;
                break;
            default:
                ;
        }
    }
    else {
        switch(deviceOrientation) {
            case DeviceOrientationPortrait:
                imageOrientation = BINARYFACE_IMAGE_ORIENTATION_FIRST_COLUMN_UP;
                break;
            case DeviceOrientationPortraitUpsideDown:
                imageOrientation = BINARYFACE_IMAGE_ORIENTATION_LAST_COLUMN_UP;
                break;
            case DeviceOrientationLandscapeLeft:
                imageOrientation = BINARYFACE_IMAGE_ORIENTATION_FIRST_ROW_UP;
                break;
            case DeviceOrientationLandscapeRight:
                imageOrientation = BINARYFACE_IMAGE_ORIENTATION_LAST_ROW_UP;
                break;
            default:
                ;
        }
    }
    /*
    CFAbsoluteTime startTime = CFAbsoluteTimeGetCurrent();
    CVImageBufferRef pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
    CVPixelBufferLockBaseAddress(pixelBuffer, 0);
    void *baseAddressY = CVPixelBufferGetBaseAddressOfPlane(pixelBuffer, 0);
    void *baseAddressUV = CVPixelBufferGetBaseAddressOfPlane(pixelBuffer, 1);
     */
    [binaryFace.yBuffer replaceBytesInRange:NSMakeRange(0, binaryFace.yBuffer.length) withBytes:yBuffer length:binaryFace.yBuffer.length];
    [binaryFace.uvBuffer replaceBytesInRange:NSMakeRange(0, binaryFace.uvBuffer.length) withBytes:uvBuffer length:binaryFace.uvBuffer.length];
    //CVPixelBufferUnlockBaseAddress(pixelBuffer, 0);
    
    int ret = BINARYFACE_OK;
    
    if (binaryFace.session) {
        ret = binaryface_run_tracking(binaryFace.session,
                                      (const uint8_t *)[binaryFace.yBuffer mutableBytes],
                                      0,
                                      BINARYFACE_PIXEL_FORMAT_GRAY,
                                      imageOrientation);
        //  NSLog(@"binaryFace.session: %d",ret);
        
        
        
    }
    
    int numFaces = 0;
    binaryface_get_num_faces(binaryFace.session, &numFaces);
    
    // NSLog(@"numface: %d ret:%d",numFaces, ret);
    
    
}

- (void)selectScene:(int)index {
  
}


- (void)getScene:(NSString* )sceneName fileterName:(NSString *)filterName stickerName:(NSString *)stickerName resType:(int)rType
{
    faceScene =  generateScene2([sceneName UTF8String],[filterName UTF8String],[stickerName UTF8String],",","","","",false,false,false,rType);
    faceScene->init(binaryFace.session, binaryFace.contextInfo.num_feature_points,"",true);
    targets.push_back(faceScene);
}

- (void)getScene2:(NSString* )sceneName fileterName:(NSString *)filterName stickerName:(NSString *)stickerName resType:(int)rType vline:(BOOL)bVline openEyes:(BOOL)bOpenEyes bigEyes:(BOOL)bBigEyes
{
    faceScene =  generateScene2([sceneName UTF8String],[filterName UTF8String],[stickerName UTF8String],[self.earringName UTF8String],[self.glassesName UTF8String],[self.hatName UTF8String],[self.mustacheName UTF8String],bOpenEyes,bVline,bBigEyes,rType);
    faceScene->init(binaryFace.session, binaryFace.contextInfo.num_feature_points,"",true);
    targets.push_back(faceScene);
}



- (NSMutableArray*)getSceneTargets
{
    return nil;
}
- (void)addSceneTargets:(NSObject*)scene
{
  
    
    //[targets addObject:scene];
}

- (void)renderTagets
{
    std::vector<BaseFaceScene*> scens = targets;

    for(int i=0;i<scens.size();i++)
    {
        BaseFaceScene* scene = scens[i];
        scene->render();
        unsigned char *yBuffer = [self getYBuffer];
        unsigned char *uvBuffer = [self getUVBuffer];
        [self setSourceYBuffer:yBuffer uv:uvBuffer];
    }
}
- (void)render
{
    if(faceScene)
        faceScene->render();
}

- (void)renderToTextureWithVertices:(const GLfloat *)vertices textureCoordinates:(const GLfloat *)textureCoordinates;
{
    /*
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
    faceScene->render();
    
    [firstInputFramebuffer unlock];
    
    if (usingNextFrameForImageCapture)
    {
        dispatch_semaphore_signal(imageCaptureSemaphore);
    }
     */
}

- (void)setSourceY
{
    faceScene->setSource((unsigned char*)binaryFace.yBuffer.mutableBytes , (unsigned char*)binaryFace.uvBuffer.mutableBytes, binaryFace.session_config.image_width, binaryFace.session_config.image_height, BaseFaceScene::FIRST_COLUMN_UP);
  
}
- (void)setSourceYBuffer:(unsigned char*)yBuffer uv:(unsigned char*)uvBuffer
{
    faceScene->setSource(yBuffer , uvBuffer, binaryFace.session_config.image_width, binaryFace.session_config.image_height, BaseFaceScene::FIRST_COLUMN_UP);
    
}


- (void)setDestWidthMirrored:(int)mirrored
{
    BaseFaceScene::OUTPUT_MIRRORED scene_mirrored = (BaseFaceScene::OUTPUT_MIRRORED)mirrored;
    faceScene->setDest(binaryFace.session_config.image_height, binaryFace.session_config.image_width, BaseFaceScene::POSITION_MINUS_Y_UP, scene_mirrored);
}

- (void)releaseScene {
    if (faceScene != nil) {
        faceScene->release();
        delete faceScene;
        faceScene = nullptr;
    }
}
//textureY,textureUV
- (unsigned char*)getYBuffer
{
    return faceScene->getYBuffer();
}

- (unsigned char*)getUVBuffer
{
    return faceScene->getUVBuffer();
}
- (int)getYTextureID
{
    return faceScene->getYTexture();
}
- (int)getUVTextureID
{
    return faceScene->getUVTexture();
}


@end
