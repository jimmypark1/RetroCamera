//
// Created by Junsung Park on 2018. 3. 18..
//

#include "HatComponent.hpp"


void HatComponent::render()
{
    //bool isCW = determinantScreenToViewPort > 0;
    //glDisable(GLenum(GL_CULL_FACE));
    //glFrontFace(GLenum(isCW ? GL_CW : GL_CCW));
    
    
    sceneProgram.use();
    
    bool bFaces = false;
    
    if (rule == 0)
        renderRule0();
    else
        renderRule1();
    
}

void HatComponent::renderRule0()
{
    //bool isCW = determinantScreenToViewPort > 0;
    //glDisable(GLenum(GL_CULL_FACE));
    //glFrontFace(GLenum(isCW ? GL_CW : GL_CCW));
    
    
    sceneProgram.use();
    
    bool bFaces = false;
    
    int i=0;
    for (auto face : faces) {
        bFaces = true;
        
        float width = widthRatio * fabs(face[0 * 3] - face[32 * 3]) / 2;
        
        float height = (float) (imgHeight * width) / (float) imgWidth;
        
        float height2 = heightRatio * fabs(face[67 * 3 + 1] - face[16 * 3 + 1]);
        
        float x = face[67 * 3];
        float y = face[67 * 3 + 1] + 1.5 * height2;
        
        float z0,z1,z2,z3,z4;
        
        z0 = face[0 * 3 + 2];
        z1 = face[32 * 3 + 2];
        z2 = face[32 * 3 + 2];
        
        
        int positionCoordLoc = sceneProgram.getAttributeLocation("position");
        
        glEnableVertexAttribArray(positionCoordLoc);
        
        const GLfloat _textureCoordinates[] = {
            0.0f, 0.0f,
            0.5f, 0.0f,
            0.0f, 1.0f,
            0.5f, 1.0f,
            1.0f, 0.0f,
            1.0f, 1.0f,
        };
        
        GLfloat vertex[] = {
            -width + x, -height + y, z0,
            x, (-height + y), z1,
            -width + x, height + y, z0,
            x, (height + y), z1,
            
            width + x, (-height + y), z2,
            width + x, (height + y), z2,
            
            
        };
        
        glVertexAttribPointer(positionCoordLoc, 3, GLenum(GL_FLOAT), 0, 0, (void *) vertex);
        int texCoordLoc = sceneProgram.getAttributeLocation("inputTextureCoordinate");
        glEnableVertexAttribArray(texCoordLoc);
        glVertexAttribPointer(texCoordLoc, 2, GLenum(GL_FLOAT), 0, 0, _textureCoordinates);
        
        glActiveTexture(GLenum(GL_TEXTURE2));
        
        glBindTexture(GLenum(GL_TEXTURE_2D), textures[renderCnt]);
        
        glUniform1i(sceneProgram.getUniformLocation("inputImageTexture"), 2);
        
        
        GLint mvp = sceneProgram.getUniformLocation("mvp");
        glUniformMatrix4fv(mvp, 1, GLboolean(GL_FALSE), matrixs[i].data());
        
        
        //short order[] = {0,1,2,  2,1,3,  3,1,4,  4,5,3, 5,4,6, 6,7,5,  7,6,8,  8,9,7};
        short order[] = {0, 1, 2, 2, 3, 1,  3,1,4,  4,5,3};
        int indicedSize = sizeof(order) / sizeof(short);
        
        glDrawElements(GLenum(GL_TRIANGLES),
                       indicedSize,
                       GLenum(GL_UNSIGNED_SHORT),
                       order);
        
        
        glActiveTexture(GL_TEXTURE2);
        glBindTexture(GL_TEXTURE_2D, GL_NONE);
        i++;
        renderCnt++;
        if(renderCnt == bound)
            renderCnt = 0;
        
    }
    
}

void HatComponent::renderRule1()
{
    //bool isCW = determinantScreenToViewPort > 0;
    //glDisable(GLenum(GL_CULL_FACE));
    //glFrontFace(GLenum(isCW ? GL_CW : GL_CCW));
    
    
    sceneProgram.use();
    
    bool bFaces = false;
    
    int i=0;
    for (auto face : faces) {
        bFaces = true;
        
        float width = widthRatio * fabs(face[0 * 3] - face[32 * 3]) / 2;
        
        float height = (float) (imgHeight * width) / (float) imgWidth;
        
        float height2 = heightRatio * fabs(face[67 * 3 + 1] - face[16 * 3 + 1]);
        
        float x = face[67 * 3];
        float y = face[67 * 3 + 1] + 1.5 * height2;
        
        float z0,z1,z2,z3,z4;
        
        z0 = face[8 * 3 + 2];
        z1 = face[12 * 3 + 2];
        z2 = face[16 * 3 + 2];
        z3 = face[20 * 3 + 2];
        z4 = face[24 * 3 + 2];;
        
        int positionCoordLoc = sceneProgram.getAttributeLocation("position");
        
        glEnableVertexAttribArray(positionCoordLoc);
        const GLfloat _textureCoordinates[] = {
            0.0f, 0.0f,     //0
            0.25f, 0.0f,    //1
            0.0f, 1.0f,     //2
            0.25f, 1.0f,    //3
            0.5f, 0.0f,     //4
            0.5f, 1.0f,     //5
            0.75f, 0.0f,    //6
            0.75f, 1.0f,    //7
            1.0f, 0.0f,     //8
            1.0f, 1.0f,     //9
            
        };
        
        GLfloat vertex[] = {
            -width + x,    -height + y,    z0,  //0
            -width/2.0f + x,         -height + y,    z1,  //1
            -width + x,    height + y,     z0,  //2
            -width/2.0f + x,         height + y,     z1,  //3
            x,                  -height + y,    z2,  //4
            x,                  height + y,     z2,  //5
            width/2.0f + x,     -height + y,    z3,  //6
            width/2.0f + x,     height + y,     z3,  //7
            width + x,          -height + y,    z4,  //8
            width + x,          height + y,     z4,  //9
        };
        
        
        
        glVertexAttribPointer(positionCoordLoc, 3, GLenum(GL_FLOAT), 0, 0, (void *) vertex);
        int texCoordLoc = sceneProgram.getAttributeLocation("inputTextureCoordinate");
        glEnableVertexAttribArray(texCoordLoc);
        glVertexAttribPointer(texCoordLoc, 2, GLenum(GL_FLOAT), 0, 0, _textureCoordinates);
        
        
        
        glActiveTexture(GLenum(GL_TEXTURE2));
        
        glBindTexture(GLenum(GL_TEXTURE_2D), textures[renderCnt]);
        
        glUniform1i(sceneProgram.getUniformLocation("inputImageTexture"), 2);
        
        
        GLint mvp = sceneProgram.getUniformLocation("mvp");
        glUniformMatrix4fv(mvp, 1, GLboolean(GL_FALSE), matrixs[i].data());
        
        short order[] = {0,1,2,  2,1,3,  3,1,4,  4,5,3, 5,4,6, 6,7,5,  7,6,8,  8,9,7};
        //  short order[] = {0, 1, 2, 2, 3, 1, 1, 3, 4, 4, 5, 3};
        int indicedSize = sizeof(order) / sizeof(short);
        
        glDrawElements(GLenum(GL_TRIANGLES),
                       indicedSize,
                       GLenum(GL_UNSIGNED_SHORT),
                       order);
        
        
        
        glActiveTexture(GL_TEXTURE2);
        glBindTexture(GL_TEXTURE_2D, GL_NONE);
        i++;
        renderCnt++;
        if(renderCnt == bound)
            renderCnt = 0;
        
    }
    
}

