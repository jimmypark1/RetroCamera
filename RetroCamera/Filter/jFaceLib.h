//
//  jFaceLib.h
//  jFaceLib
//
//  Created by JunSoft on 2018. 3. 26..

#import <Foundation/Foundation.h>
#import <CoreMedia/CoreMedia.h>
//#import "itemType.h"

typedef enum {
    eNetworkResouce = 0,
    eLocalResource  = 1
}eResType;

@interface jFaceLib : NSObject

- (BOOL)initSDKFrameRate:(float)framerate fov:(float)fov;
- (BOOL)initSDKFrameRate:(float)framerate fov:(float)fov size:(CGSize)size;

- (void)processBuffer:(CMSampleBufferRef)sampleBuffer  orientation:(int)deviceOrientation front:(BOOL)bFont;
- (void)processBufferY:(unsigned char*)yBuffer uv:(unsigned char*)uvBuffer  orientation:(int)deviceOrientation front:(BOOL)bFont;
- (void)processBuffer2:(CVPixelBufferRef)pixelBuffer  orientation:(int)deviceOrientation front:(BOOL)bFont;

//- (void)getScene:(NSString* )sceneName fileterName:(NSString *)filterName resType:(int)rType;
- (void)getScene:(NSString* )sceneName fileterName:(NSString *)filterName stickerName:(NSString *)stickerName resType:(int)rType;
- (void)getScene2:(NSString* )sceneName fileterName:(NSString *)filterName stickerName:(NSString *)stickerName resType:(int)rType vline:(BOOL)bVline openEyes:(BOOL)bOpenEyes bigEyes:(BOOL)bBigEyes;

- (void)setSourceY;
- (void)setDestWidthMirrored:(int)mirrored;
- (void)render;
- (void)releaseScene;
- (unsigned char*)getYBuffer;
- (unsigned char*)getUVBuffer;
- (int)getYTextureID;
- (int)getUVTextureID;
- (void)setSourceYBuffer:(unsigned char*)yBuffer uv:(unsigned char*)uvBuffer;
- (void)addSceneTargets:(NSObject*)scene;
- (NSMutableArray*)getSceneTargets;
- (void)close;
- (void)resetBufferSize:(CGSize)size;

@property(nonatomic, assign) NSString* earringName;
@property(nonatomic, assign) NSString* hatName;
@property(nonatomic, assign) NSString* glassesName;
@property(nonatomic, assign) NSString* mustacheName;



@end
