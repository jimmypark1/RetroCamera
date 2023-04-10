//
//  CropFilter.h
//  iBeautyCameraSwift
//
//  Created by Junsung Park on 2018. 5. 14..
//  Copyright © 2018년 Junsung Park. All rights reserved.
//

#import <GPUImage/GPUImage.h>

@interface CropFilter : GPUImageCropFilter
- (void)setFrameBuffer;
- (UIImage*)getFrameBuffer:(GPUImageFilter*)filter size:(CGSize)size;

@end
