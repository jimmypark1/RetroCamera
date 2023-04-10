//
//  jFrameBuffer.h
//  iBeautyCameraSwift
//
//  Created by Junsung Park on 2018. 4. 26..
//  Copyright © 2018년 Junsung Park. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface jFrameBuffer : NSObject
- (unsigned char*)getFrameDataWidth:(int)width height:(int)height;

@end
