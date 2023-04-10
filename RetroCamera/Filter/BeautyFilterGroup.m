//
//  BeautyFilterGroup.m
//  iBeautyCameraSwift
//
//  Created by Junsung Park on 2018. 5. 8..
//  Copyright © 2018년 Junsung Park. All rights reserved.
//

#import "BeautyFilterGroup.h"
#import "BeautyFilter.h"

@interface BeautyFilterGroup()
{
    GPUImageSharpenFilter *sharpenFilter;
    BeautyFilter *beautyFilter;
    GPUImageToneCurveFilter *toneFilter;
    GPUImageMedianFilter  *medianFilter;
    
}
@end


@implementation BeautyFilterGroup

- (void)process:(NSData*)data
{
    beautyFilter = [[BeautyFilter alloc] init];
    [self addFilter:beautyFilter];
    
    toneFilter = [[GPUImageToneCurveFilter alloc] initWithACVData:data];
    [self addFilter:toneFilter];
    [beautyFilter addTarget:toneFilter];
    
    medianFilter = [[GPUImageMedianFilter alloc] init];
    [self addFilter:medianFilter];

    sharpenFilter = [[GPUImageSharpenFilter alloc] init];
    sharpenFilter.sharpness = 0.8;
    [self addFilter:sharpenFilter];

    
    [toneFilter addTarget:sharpenFilter];
    
    
    self.initialFilters = [NSArray arrayWithObjects:beautyFilter,nil];
    self.terminalFilter = sharpenFilter;
}




@end
