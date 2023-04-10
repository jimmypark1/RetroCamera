//
// Created by Junsung Park on 2018. 3. 18..
//

#include "EarringComponent.hpp"

void EarringComponent::render()
{
    renderEarring();
    renderEarring2();
}

void EarringComponent::renderEarring()
{
    sceneProgram.use();

    bool bFaces = false;


    int i =0;
    for (auto face : faces) {
        int verticesIndex = 0;
        bFaces = true;

        //124,213
        float width = fabs(face[93*3]-face[96*3])/2;
        //46,70
        float height = imgHeight*width/imgWidth;


        float height2 = fabs(face[70*3+1]-face[16*3+1])/2;

        float x = face[27*3];
        float y = face[27*3 +1];


        GLfloat vertex[12] = {
                -width+x, -height+y,face[27*3+2],
                width+x, (-height+y),face[27*3+2],
                -width+x,  height+y,face[27*3+2],
                width+x,  (height+y),face[27*3+2]
        };


        const GLfloat textureCoordinates[8] = {
                0.0f, 0.0f,
                1.0f, 0.0f,
                0.0f, 1.0f,
                1.0f, 1.0f,
        };

        short order[] = {0,1,2,2,1,3};
        //      short order[] = {0,1,2,2,1,3};
        int indicedSize =sizeof(order)/sizeof(short);


        int positionCoordLoc = sceneProgram.getAttributeLocation("position");

        glEnableVertexAttribArray( positionCoordLoc );

        glVertexAttribPointer(positionCoordLoc, 3, GLenum(GL_FLOAT), 0, 0, (void*)vertex);

        int texCoordLoc = sceneProgram.getAttributeLocation("inputTextureCoordinate");
        glEnableVertexAttribArray(texCoordLoc);
        glVertexAttribPointer(texCoordLoc, 2, GLenum(GL_FLOAT), 0, 0, textureCoordinates);
        glActiveTexture(GLenum(GL_TEXTURE3));
     
        glBindTexture(GLenum(GL_TEXTURE_2D), textures[0]);
        glUniform1i(sceneProgram.getUniformLocation("inputImageTexture"), 3);



        GLint mvp = sceneProgram.getUniformLocation("mvp");
        glUniformMatrix4fv(mvp, 1, GLboolean(GL_FALSE), matrixs[i].data());

        glDrawElements(GLenum(GL_TRIANGLES),
                       indicedSize,
                       GLenum(GL_UNSIGNED_SHORT),
                       order);



        glActiveTexture(GL_TEXTURE3);
        glBindTexture(GL_TEXTURE_2D, GL_NONE);
        i++;

    }
}

void EarringComponent::renderEarring2()
{
    sceneProgram.use();

    bool bFaces = false;


    int i =0;
    for (auto face : faces) {
        int verticesIndex = 0;
        bFaces = true;

        //124,213
        float width = fabs(face[93*3]-face[96*3])/2;
        //72,204
        float height = imgHeight*width/imgWidth;

        float height2 = fabs(face[70*3+1]-face[16*3+1])/2;

        float x = 1.05*face[5*3];
        float y = face[5*3 +1];


        GLfloat vertex[12] = {
                -width+x, -height+y,face[5*3+2],
                width+x, (-height+y),face[5*3+2],
                -width+x,  height+y,face[5*3+2],
                width+x,  (height+y),face[5*3+2]
        };


        const GLfloat textureCoordinates[8] = {
                0.0f, 0.0f,
                1.0f, 0.0f,
                0.0f, 1.0f,
                1.0f, 1.0f,
        };

        short order[] = {0,1,2,2,1,3};
        //      short order[] = {0,1,2,2,1,3};
        int indicedSize =sizeof(order)/sizeof(short);



        int positionCoordLoc = sceneProgram.getAttributeLocation("position");

        glEnableVertexAttribArray( positionCoordLoc );

        glVertexAttribPointer(positionCoordLoc, 3, GLenum(GL_FLOAT), 0, 0, (void*)vertex);

        int texCoordLoc = sceneProgram.getAttributeLocation("inputTextureCoordinate");
        glEnableVertexAttribArray(texCoordLoc);
        glVertexAttribPointer(texCoordLoc, 2, GLenum(GL_FLOAT), 0, 0, textureCoordinates);
        glActiveTexture(GLenum(GL_TEXTURE3));
        glBindTexture(GLenum(GL_TEXTURE_2D), textures[0]);
        glUniform1i(sceneProgram.getUniformLocation("inputImageTexture"), 3);



        GLint mvp = sceneProgram.getUniformLocation("mvp");
        glUniformMatrix4fv(mvp, 1, GLboolean(GL_FALSE), matrixs[i].data());

        glDrawElements(GLenum(GL_TRIANGLES),
                       indicedSize,
                       GLenum(GL_UNSIGNED_SHORT),
                       order);



        glActiveTexture(GL_TEXTURE3);
        glBindTexture(GL_TEXTURE_2D, GL_NONE);
        i++;

    }
}
