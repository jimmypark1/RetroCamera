//
// Created by Junsung Park on 2018. 3. 18..
//

#include "MustacheComponent.hpp"

void MustacheComponent::render()
{
    sceneProgram.use();

    bool bFaces = false;

    int i=0;
    for (auto face : faces) {
        int verticesIndex = 0;
        bFaces = true;


        float width = widthRatio*fabs(face[117*3]-face[129*3]);
        //46,70
        float height = imgHeight*width/imgWidth;

        float x = face[73*3];
        float y = face[73*3 +1]-heightRatio*height;


        GLfloat vertex[12] = {
                -width+x, -height+y,face[123*3+2],
                width+x, (-height+y),face[123*3+2],
                -width+x,  height+y,face[123*3+2],
                width+x,  (height+y),face[123*3+2]
        };


        GLfloat _textureCoordinates[8] = {
                0.0f, 0.0f,
                1.0f, 0.0f,
                0.0f, 1.0f,
                1.0f, 1.0f,
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


        glActiveTexture(GLenum(GL_TEXTURE2));
        glBindTexture(GLenum(GL_TEXTURE_2D), textures[0]);
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

    }
}
