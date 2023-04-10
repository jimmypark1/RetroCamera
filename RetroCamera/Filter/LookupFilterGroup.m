//
//  LookupFilterGroup.m
//  iBeautyCameraSwift
//
//  Created by Junsung Park on 2018. 5. 9..
//  Copyright © 2018년 Junsung Park. All rights reserved.
//

#import "LookupFilterGroup.h"
#import "JFaceLookupFilter.h"
#import "BeautyFilter.h"
#import "Scene.h"

@interface LookupFilterGroup()
{
    BeautyFilter            *beautyFilter;
    GPUImageLookupFilter    *lookupFilter;
    GPUImagePicture         *lookupImageSource;
    GPUImageSharpenFilter   *sharpenFilter;
    GPUImageToneCurveFilter *toneFilter;
    GPUImageCropFilter      *cropFilter;
    GPUImageContrastFilter  *contrastFilter;
    
    GPUImageFilter *sceneFilter;
    
}
@end

@implementation LookupFilterGroup


- (void)process:(NSString*)name
{
    
    beautyFilter = [[BeautyFilter alloc] init];
    
    NSArray       *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString  *documentsDirectory = [paths objectAtIndex:0];
    
    NSString  *filePath = [NSString stringWithFormat:@"%@/filter/%@", documentsDirectory,name];
    
    
    NSData * data = [[NSFileManager defaultManager] contentsAtPath:filePath];
    UIImage *image = [UIImage imageWithData:data];
    if(!image)
        return ;
    
    lookupImageSource = [[GPUImagePicture alloc] initWithImage:image];
    lookupFilter = [[GPUImageLookupFilter alloc] init];
    [self addFilter:lookupFilter];
    
    [lookupImageSource addTarget:lookupFilter atTextureLocation:1];
    [lookupImageSource processImage];
    
  
    [beautyFilter addTarget:lookupFilter];
    sharpenFilter = [[GPUImageSharpenFilter alloc] init];
    sharpenFilter.sharpness = 0.8;
    [self addFilter:sharpenFilter];
    [lookupFilter addTarget:sharpenFilter];
    
    self.initialFilters = [NSArray arrayWithObjects:beautyFilter,nil];
    self.terminalFilter = sharpenFilter;
    
   
}

- (void)removeAll
{
    [sceneFilter removeAllTargets];
    
    [beautyFilter removeAllTargets];
    [cropFilter removeAllTargets];
    [toneFilter removeAllTargets];
    [sharpenFilter removeAllTargets];
    [lookupFilter removeAllTargets];

}

- (void)processFilter:(NSString*)name scene:(Scene*)scene data:(NSData*)data beauty:(BOOL)bBeauty square:(int)bSqare
{
 
 //   if(sceneFilter)
    {
        
  
    }
    sceneFilter = (GPUImageFilter*)scene;
    beautyFilter = [[BeautyFilter alloc] init];
    
    
    if(![name isEqualToString:@"none"] && name.length && data.length == 0)
    {
        NSArray       *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString  *documentsDirectory = [paths objectAtIndex:0];
        
        NSString  *filePath = [NSString stringWithFormat:@"%@/sticker/%@", documentsDirectory,name];
        
        
        NSData * data = [[NSFileManager defaultManager] contentsAtPath:filePath];
        UIImage *image = [UIImage imageWithData:data];
        if(!image)
            return ;
       
        
        ////
       
        lookupImageSource = [[GPUImagePicture alloc] initWithImage:image];
        lookupFilter = [[GPUImageLookupFilter alloc] init];
        [self addFilter:lookupFilter];
        
        [lookupImageSource addTarget:lookupFilter atTextureLocation:1];
        [lookupImageSource processImage];
        
        [self addFilter:sceneFilter];
       
        
        sharpenFilter = [[GPUImageSharpenFilter alloc] init];
        sharpenFilter.sharpness = 0.8;
        [self addFilter:sharpenFilter];
      
        if(bBeauty)
        {
            
            [sceneFilter addTarget:beautyFilter];
            [beautyFilter addTarget:lookupFilter];
            
            
        
            
        }
        else
        {
            [sceneFilter addTarget:lookupFilter];
            
            
        }
        [lookupFilter addTarget:sharpenFilter];
        if(bSqare == 2)
        {
            cropFilter = [[GPUImageCropFilter alloc] initWithCropRegion:CGRectMake(0, 0, 1, 0.75)];
            [cropFilter forceProcessingAtSizeRespectingAspectRatio:CGSizeMake(480, 480)];
        }
        else if(bSqare == 0)
        {
            cropFilter = [[GPUImageCropFilter alloc] initWithCropRegion:CGRectMake(0, 0, 1, 1.0)];
        }
        else if(bSqare == 1)
        {
            cropFilter = [[GPUImageCropFilter alloc] initWithCropRegion:CGRectMake(0, 0, 1, 1.0)];
            [cropFilter forceProcessingAtSizeRespectingAspectRatio:CGSizeMake(640, 480)];
        }
        
        
        [lookupFilter addTarget:cropFilter];
        self.finalFilter = cropFilter;

        
        
        
        self.initialFilters = [NSArray arrayWithObjects:sceneFilter,nil];
        self.terminalFilter = cropFilter;

    }
    else if(data.length)
    {
        
        
        
        toneFilter = [[GPUImageToneCurveFilter alloc] initWithACVData:data];
        [self addFilter:toneFilter];
        [self addFilter:sceneFilter];
        
        sharpenFilter = [[GPUImageSharpenFilter alloc] init];
        sharpenFilter.sharpness = 0.8;
        [self addFilter:sharpenFilter];
     //   contrastFilter = [[GPUImageContrastFilter alloc] init];

        if(bBeauty)
        {
            [sceneFilter addTarget:beautyFilter];
            [beautyFilter addTarget:toneFilter];
            
        }
        else
        {
            [sceneFilter addTarget:toneFilter];
            
        }
        [toneFilter addTarget:sharpenFilter];
      //  [toneFilter addTarget:contrastFilter];
        
        if(bSqare == 2)
        {
            cropFilter = [[GPUImageCropFilter alloc] initWithCropRegion:CGRectMake(0, 0, 1, 0.75)];
            [cropFilter forceProcessingAtSizeRespectingAspectRatio:CGSizeMake(480, 480)];
        }
        else if(bSqare == 0)
        {
            cropFilter = [[GPUImageCropFilter alloc] initWithCropRegion:CGRectMake(0, 0, 1, 1.0)];
        }
        else if(bSqare == 1)
        {
            cropFilter = [[GPUImageCropFilter alloc] initWithCropRegion:CGRectMake(0, 0, 1, 1.0)];
        }
        [self addFilter:cropFilter];
        
        [toneFilter addTarget:cropFilter];
        self.finalFilter = cropFilter;

        self.initialFilters = [NSArray arrayWithObjects:sceneFilter,nil];
        self.terminalFilter = cropFilter;

    }
    else
    {
        [self addFilter:sceneFilter];
        
        
        sharpenFilter = [[GPUImageSharpenFilter alloc] init];
        sharpenFilter.sharpness = 0.8;
        [self addFilter:sharpenFilter];
      
        bBeauty = TRUE;
        if(bBeauty)
        {
            [sceneFilter addTarget:beautyFilter];
            [beautyFilter addTarget:sharpenFilter];
            
            if(bSqare == 2)
            {
                cropFilter = [[GPUImageCropFilter alloc] initWithCropRegion:CGRectMake(0, 0, 1, 0.75)];
                [cropFilter forceProcessingAtSizeRespectingAspectRatio:CGSizeMake(480, 480)];
            }
            else if(bSqare == 0)
            {
                cropFilter = [[GPUImageCropFilter alloc] initWithCropRegion:CGRectMake(0, 0, 1, 1.0)];
            }
            else if(bSqare == 1)
            {
                cropFilter = [[GPUImageCropFilter alloc] initWithCropRegion:CGRectMake(0, 0, 1, 1.0)];
                [cropFilter forceProcessingAtSizeRespectingAspectRatio:CGSizeMake(640, 480)];
            }
            [beautyFilter addTarget:cropFilter];
            self.finalFilter = cropFilter;

        }
        else
        {
            [sceneFilter addTarget:sharpenFilter];
            if(bSqare == 2)
            {
                cropFilter = [[GPUImageCropFilter alloc] initWithCropRegion:CGRectMake(0, 0, 1, 0.75)];
                [cropFilter forceProcessingAtSizeRespectingAspectRatio:CGSizeMake(480, 480)];
            }
            else if(bSqare == 0)
            {
                cropFilter = [[GPUImageCropFilter alloc] initWithCropRegion:CGRectMake(0, 0, 1, 1.0)];
            }
            else if(bSqare == 1)
            {
                cropFilter = [[GPUImageCropFilter alloc] initWithCropRegion:CGRectMake(0, 0, 1, 1.0)];
                [cropFilter forceProcessingAtSizeRespectingAspectRatio:CGSizeMake(640, 480)];
            }
            [sceneFilter addTarget:cropFilter];
            self.finalFilter = cropFilter;
      }
        
    
        
        self.initialFilters = [NSArray arrayWithObjects:sceneFilter,nil];
        self.terminalFilter = cropFilter;
        
      //  [self forceProcessingAtSize:CGSizeMake(480,480)];

    }
    
}

- (void)processThumbFilter:(NSString*)name  data:(NSData*)data
{
    
    //   if(sceneFilter)
    {
        
        
    }
    beautyFilter = [[BeautyFilter alloc] init];
    
    
    if(![name isEqualToString:@"none"] && name.length && data.length == 0)
    {
        NSArray       *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString  *documentsDirectory = [paths objectAtIndex:0];
        
        NSString  *filePath = [NSString stringWithFormat:@"%@/filter/%@", documentsDirectory,name];
        
        
        NSData * data = [[NSFileManager defaultManager] contentsAtPath:filePath];
        UIImage *image = [UIImage imageWithData:data];
        if(!image)
            return ;
        
        
        lookupImageSource = [[GPUImagePicture alloc] initWithImage:image];
        lookupFilter = [[GPUImageLookupFilter alloc] init];
        [self addFilter:lookupFilter];
        
        [lookupImageSource addTarget:lookupFilter atTextureLocation:1];
        [lookupImageSource processImage];
        
        
     //   [lookupFilter addTarget:cropFilter];
     //   self.finalFilter = cropFilter;
        
        self.initialFilters = [NSArray arrayWithObjects:lookupFilter,nil];
        self.terminalFilter = lookupFilter;
        
    }
    else if(data.length)
    {
        
        toneFilter = [[GPUImageToneCurveFilter alloc] initWithACVData:data];
        [self addFilter:toneFilter];
        
        
        self.initialFilters = [NSArray arrayWithObjects:toneFilter,nil];
        self.terminalFilter = toneFilter;
        
    }
    else
    {
        //  [self forceProcessingAtSize:CGSizeMake(480,480)];
        
    }
    
}

- (void)setFrameBuffer:(GPUImageStillCamera*)camera
{
    
    
}

- (UIImage*)takePicture
{
    UIImage *filteredPhoto = [self imageFromCurrentFramebuffer];
    NSLog(@"test");
    return filteredPhoto;
    
}

- (UIImage*)takePicture:(GPUImageStillCamera*)camera
{
    
   GPUImageFramebuffer *outputFramebuffer =  [[GPUImageContext sharedFramebufferCache] fetchFramebufferForSize:[sharpenFilter sizeOfFBO] textureOptions:camera.outputTextureOptions onlyTexture:NO];
    [outputFramebuffer activateFramebuffer];
    UIDeviceOrientation deviceOrientation = [[UIDevice currentDevice] orientation];
    UIImageOrientation imageOrientation = UIImageOrientationLeft;
    switch (deviceOrientation)
    {
        case UIDeviceOrientationPortrait:
            imageOrientation = UIImageOrientationUp;
            break;
        case UIDeviceOrientationPortraitUpsideDown:
            imageOrientation = UIImageOrientationDown;
            break;
        case UIDeviceOrientationLandscapeLeft:
            imageOrientation = UIImageOrientationLeft;
            break;
        case UIDeviceOrientationLandscapeRight:
            imageOrientation = UIImageOrientationRight;
            break;
        default:
            imageOrientation = UIImageOrientationUp;
            break;
    }
    
    CGImageRef image = [outputFramebuffer newCGImageFromFramebufferContents];

    UIImage *finalImage = [UIImage imageWithCGImage:image scale:1.0 orientation:imageOrientation];
    CGImageRelease(image);
    
    NSLog(@"test");
    return finalImage;
    
}


@end
