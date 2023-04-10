//
//  JFaceLookupFilter.h
//  iBeautyCameraSwift
//
//  Created by Junsung Park on 2018. 4. 23..
//  Copyright © 2018년 Junsung Park. All rights reserved.
//

#import <GPUImage/GPUImage.h>
#import "GPUImageBeautifyFilter.h"

@interface JFaceLookupFilter : GPUImageFilterGroup
{
    GPUImageLookupFilter *lookupFilter;
    GPUImageBeautifyFilter *beautyFilter;
    GPUImagePicture *lookupImageSource;
}
- (id)process:(NSString*)name;

@end
