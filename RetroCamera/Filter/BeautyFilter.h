//
//  BeautyFilter.h
//  iBeautyCameraSwift
//
//  Created by Junsung Park on 2018. 5. 8..
//  Copyright © 2018년 Junsung Park. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <GPUImage/GPUImage.h>

@interface BeautyFilter : GPUImageFilter
{
}

- (void)setFrameBuffer;

@property (nonatomic, readwrite)CGFloat brightness;
@property (nonatomic, readwrite)CGFloat beauty;
@property (nonatomic, readwrite)CGFloat tone;
@property (nonatomic, readwrite)CGSize texelSize;

@end
