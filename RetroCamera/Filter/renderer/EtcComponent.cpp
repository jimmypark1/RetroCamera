//
// Created by Junsung Park on 2018. 3. 19..
//

#include "EtcComponent.hpp"

void EtcComponent::render()
{
    sceneProgram.use();

    bool bFaces = false;

    int i=0;
    for (auto face : faces) {
        bFaces = true;

        float width = widthRatio*fabs(face[w_x0*3]-face[w_x1*3])/2;;

        float height = (float)(imgHeight*width)/(float)imgWidth;
        float height2 = heightRatio* fabs(face[h_y0*3+1]-face[h_y1*3+1]);

        float x = face[s_x*3]-s_x_ratio*width;
        float y = face[s_y*3 +1]- (s_y_ratio*height2);
        float _z0= face[z0*3+2];
        float _z1= face[z1*3+2];


        GLfloat vertex[] = {
                -width+x, -height+y,_z0,
                width+x, (-height+y),_z1,
                -width+x,  height+y,_z0,
                width+x,  (height+y),_z1
        };

        const GLfloat textureCoordinates[8] = {
                0.0f, 0.0f,
                1.0f, 0.0f,
                0.0f, 1.0f,
                1.0f, 1.0f,
        };


        short order[] = {0,1,2,2,1,3};//, 3,1,4,4,5,3};
        int indicedSize =sizeof(order)/sizeof(short);

        int positionCoordLoc = sceneProgram.getAttributeLocation("position");

        glEnableVertexAttribArray( positionCoordLoc );

        glVertexAttribPointer(positionCoordLoc, 3, GLenum(GL_FLOAT), 0, 0, (void*)vertex);

        int texCoordLoc = sceneProgram.getAttributeLocation("inputTextureCoordinate");
        glEnableVertexAttribArray(texCoordLoc);
        glVertexAttribPointer(texCoordLoc, 2, GLenum(GL_FLOAT), 0, 0, textureCoordinates);


        glActiveTexture(GLenum(GL_TEXTURE2));
        if(mirrored == false)
            glBindTexture(GLenum(GL_TEXTURE_2D), textures[renderCnt]);
        else if(mirrored == true && bFront)
            glBindTexture(GLenum(GL_TEXTURE_2D), textures_f[renderCnt]);
        else
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
