//
//  jFrameBuffer.m
//  iBeautyCameraSwift
//
//  Created by Junsung Park on 2018. 4. 26..
//  Copyright © 2018년 Junsung Park. All rights reserved.
//

#import "jFrameBuffer.h"
#import <OpenGLES/ES2/gl.h>


@implementation jFrameBuffer
- (unsigned char**)getFrameDataWidth:(int)width height:(int)height
{
    GLuint resultFBO;// FBO
    GLuint rboId;  //render buffer id
    glGenRenderbuffers(1, &rboId);
    glBindRenderbuffer(GL_RENDERBUFFER, rboId);
    glRenderbufferStorage(GL_RENDERBUFFER, GL_DEPTH_COMPONENT16, width, height);
    glBindRenderbuffer(GL_RENDERBUFFER, 0);
    
    glGenFramebuffers(1, &resultFBO);
    glBindFramebuffer(GL_FRAMEBUFFER, resultFBO);
    glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_DEPTH_ATTACHMENT,
                              GL_RENDERBUFFER, rboId);
    glBindFramebuffer(GL_FRAMEBUFFER, 0);
    
    GLenum status = glCheckFramebufferStatus(GL_FRAMEBUFFER);
    if (status == GL_FRAMEBUFFER_COMPLETE) {
        //LOGH("Single FBO setup successfully.");
    } else {
    }
    GLubyte* pixels = (GLubyte*) malloc(width * height * sizeof(GLubyte) * 4);

    //After render to the FBO
    glBindFramebuffer(GL_FRAMEBUFFER, resultFBO);
    glReadPixels(0, 0, width, height, GL_DEPTH_COMPONENT, GL_UNSIGNED_BYTE, pixels);
    return pixels;
    
}
@end
