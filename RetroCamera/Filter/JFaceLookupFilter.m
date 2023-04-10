//
//  JFaceLookupFilter.m
//  iBeautyCameraSwift
//
//  Created by Junsung Park on 2018. 4. 23..
//  Copyright © 2018년 Junsung Park. All rights reserved.
//

#import "JFaceLookupFilter.h"
#import "GPUImageBeautifyFilter.h"

@implementation JFaceLookupFilter
- (id)process:(NSString*)name
{
    NSArray       *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString  *documentsDirectory = [paths objectAtIndex:0];
    
    NSString  *filePath = [NSString stringWithFormat:@"%@/filter/%@", documentsDirectory,name];
    
    
    NSData * data = [[NSFileManager defaultManager] contentsAtPath:filePath];
    UIImage *image = [UIImage imageWithData:data];
    if(!image)
        return nil;

    lookupImageSource = [[GPUImagePicture alloc] initWithImage:image];
    lookupFilter = [[GPUImageLookupFilter alloc] init];
    [self addFilter:lookupFilter];
    
    [lookupImageSource addTarget:lookupFilter atTextureLocation:1];
    [lookupImageSource processImage];
    
    beautyFilter = [[GPUImageBeautifyFilter alloc] init];
    [lookupFilter addTarget:beautyFilter];
    [self addFilter:beautyFilter];
    
    self.initialFilters = [NSArray arrayWithObjects:lookupFilter, nil];
    self.terminalFilter = beautyFilter;
    
    return self;
}
@end
