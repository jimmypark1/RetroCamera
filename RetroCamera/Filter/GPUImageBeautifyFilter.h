//
//  GPUImageBeautifyFilter.h
//  BeautifyFaceDemo
//
//  Created by guikz on 16/4/28.
//  Copyright © 2016年 guikz. All rights reserved.
//

#import <GPUImage/GPUImage.h>

@class GPUImageCombinationFilter;

@interface GPUImageBeautifyFilter : GPUImageFilterGroup {
    GPUImageBilateralFilter *bilateralFilter;
    GPUImageCannyEdgeDetectionFilter *cannyEdgeFilter;
    GPUImageCombinationFilter *combinationFilter;
    GPUImageHSBFilter *hsbFilter;
    GPUImageFilter *sceneFilter;
    BOOL takeSnapShot;
}
- (void)setIntensity:(CGFloat)intensity;
- (void)setLastFilter:(GPUImageFilter*)filter;
- (UIImage*)takePicture;
- (void)process;
- (void)process2:(GPUImageFilter*)filter;

@end
