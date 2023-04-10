//
//  LookupFilterGroup.h
//  iBeautyCameraSwift
//
//  Created by Junsung Park on 2018. 5. 9..
//  Copyright © 2018년 Junsung Park. All rights reserved.
//

#import <GPUImage/GPUImage.h>
#import "Scene.h"

@interface LookupFilterGroup : GPUImageFilterGroup
- (void)process:(NSString*)name;
- (void)processFilter:(NSString*)name scene:(Scene*)scene data:(NSData*)data beauty:(BOOL)bBeauty square:(int)bSqare;
- (UIImage*)takePicture;
- (UIImage*)takePicture:(GPUImageStillCamera*)camera;
- (void)removeAll;
- (void)processThumbFilter:(NSString*)name  data:(NSData*)data;

@property(readwrite, nonatomic, strong) GPUImageFilter *finalFilter;

@end
