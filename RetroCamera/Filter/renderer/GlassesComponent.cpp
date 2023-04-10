//
// Created by Junsung Park on 2018. 3. 18..
//

#include "GlassesComponent.hpp"


void GlassesComponent::render()
{
    sceneProgram.use();

    bool bFaces = false;

    int i =0;
    for (auto face : faces) {
        bFaces = true;


        float width;
        width= widthRatio*fabs(face[0*3]-face[32*3])/2;

        float height = (float)(imgHeight * width)/ (float)imgWidth;

        float x = face[68*3];
        float y = face[68*3 +1];

        /*

        GLfloat vertex[12] = {
                -width+x, -height+y,face[67*3+2],
                width+x, (-height+y),face[67*3+2],
                -width+x,  height+y,face[67*3+2],
                width+x,  (height+y),face[67*3+2]
        };
    */
        float z0 = face[93 * 3 + 2];;
        float z1 = face[67 * 3 + 2];;
        float z2 = face[105 * 3 + 2];;

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


        //   short order[] = {0,1,2,2,1,3};
        //  int indicedSize =sizeof(order)/sizeof(short);
        short order[] = {0, 1, 2, 2, 3, 1, 1, 3, 4, 4, 5, 3};
        int indicedSize = sizeof(order) / sizeof(short);

        int positionCoordLoc = sceneProgram.getAttributeLocation("position");

        glEnableVertexAttribArray( positionCoordLoc );

        glVertexAttribPointer(positionCoordLoc, 3, GLenum(GL_FLOAT), 0, 0, (void*)vertex);

        int texCoordLoc = sceneProgram.getAttributeLocation("inputTextureCoordinate");
        glEnableVertexAttribArray(texCoordLoc);
        //  glVertexAttribPointer(texCoordLoc, 2, GLenum(GL_FLOAT), 0, 0, textureCoordinates);
        glVertexAttribPointer(texCoordLoc, 2, GLenum(GL_FLOAT), 0, 0, _textureCoordinates);


        glActiveTexture(GLenum(GL_TEXTURE3));
    
        glBindTexture(GLenum(GL_TEXTURE_2D), textures[renderCnt]);

        glUniform1i(sceneProgram.getUniformLocation("inputImageTexture"), 3);


        GLint mvp = sceneProgram.getUniformLocation("mvp");
        glUniformMatrix4fv(mvp, 1, GLboolean(GL_FALSE), matrixs[i].data());

        glDrawElements(GLenum(GL_TRIANGLES),
                       indicedSize,
                       GLenum(GL_UNSIGNED_SHORT),
                       order);



        glBindBuffer(GL_ARRAY_BUFFER, GL_NONE);
        glActiveTexture(GL_TEXTURE3);
        i++;
        renderCnt++;
        if(renderCnt == bound)
            renderCnt = 0;
    }


}
