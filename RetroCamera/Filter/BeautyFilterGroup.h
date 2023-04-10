//
//  BeautyFilterGroup.h
//  iBeautyCameraSwift
//
//  Created by Junsung Park on 2018. 5. 8..
//  Copyright © 2018년 Junsung Park. All rights reserved.
//

#import <GPUImage/GPUImage.h>

@interface BeautyFilterGroup : GPUImageFilterGroup
- (void)process:(NSData*)data;

@end
