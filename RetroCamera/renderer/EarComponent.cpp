//
// Created by Junsung Park on 2018. 3. 18..
//

#include "EarComponent.hpp"

void EarComponent::render()
{
    sceneProgram.use();

    bool bFaces = false;

    int i=0;
    for (auto face : faces) {
        bFaces = true;

        float width = widthRatio*fabs(face[0*3]-face[32*3])/2;

        float height = (float)(imgHeight*width)/(float)imgWidth;

        float height2 = heightRatio* fabs(face[67*3+1]-face[16*3+1]);

        float x = face[67*3];
        float y = face[67*3 +1]+1.5*height2;
/*
        GLfloat vertex[] = {
                -width+x, -height+y,face[0*3+2],
                width+x, (-height+y),face[32*3+2],
                -width+x,  height+y,face[0*3+2],
                width+x,  (height+y),face[32*3+2]
        };
*/

        float z0 = face[0 * 3 + 2];
        float z1 = face[32 * 3 + 2];
        float z2 = face[32 * 3 + 2];

        // if(rule == 1)
        {
            z0 = face[0 * 3 + 2];;
            z1 = face[67 * 3 + 2];;
            z2 = face[32 * 3 + 2];;
        }

        GLfloat vertex[] = {
                -width + x, -height + y, z0,
                x, (-height + y), z1,
                -width + x, height + y, z0,
                x, (height + y), z1,

                width + x, (-height + y), z2,
                width + x, (height + y), z2,


        };

        const GLfloat _textureCoordinates[] = {
                0.0f, 0.0f,
                0.5f, 0.0f,
                0.0f, 1.0f,
                0.5f, 1.0f,
                1.0f, 0.0f,
                1.0f, 1.0f,
        };

        //   short order[] = {0,1,2,2,1,3};//, 3,1,4,4,5,3};
        //   int indicedSize =sizeof(order)/sizeof(short);
        short order[] = {0, 1, 2, 2, 3, 1, 1, 3, 4, 4, 5, 3};
        int indicedSize = sizeof(order) / sizeof(short);

        int positionCoordLoc = sceneProgram.getAttributeLocation("position");

        glEnableVertexAttribArray( positionCoordLoc );

        glVertexAttribPointer(positionCoordLoc, 3, GLenum(GL_FLOAT), 0, 0, (void*)vertex);

        int texCoordLoc = sceneProgram.getAttributeLocation("inputTextureCoordinate");
        glEnableVertexAttribArray(texCoordLoc);
        glVertexAttribPointer(texCoordLoc, 2, GLenum(GL_FLOAT), 0, 0, _textureCoordinates);


        glActiveTexture(GLenum(GL_TEXTURE2));

        glBindTexture(GLenum(GL_TEXTURE_2D), textures[renderCnt]);

        glUniform1i(sceneProgram.getUniformLocation("inputImageTexture"), 2);


        GLint mvp = sceneProgram.getUniformLocation("mvp");
        glUniformMatrix4fv(mvp, 1, GLboolean(GL_FALSE), matrixs[i].data());


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
