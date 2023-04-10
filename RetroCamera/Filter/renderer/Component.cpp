//
// Created by Junsung Park on 2018. 3. 18..
//

#include "Component.hpp"

Component::Component()
{

    TEXTURE_VSH =
            "attribute  vec3 position;"
                    "attribute vec2 inputTextureCoordinate;"
                    "varying  vec2 textureCoordinate;"
                    "uniform  mat4 mvp;"
                    "void main()"
                    "{"
                    "  mediump vec4 p = mvp* vec4(position,  1.0);"
                    "  gl_Position = p/p.w ;"

                    "  textureCoordinate = inputTextureCoordinate;"
                    "}";

    TEXTURE_FSH =
            "uniform sampler2D inputImageTexture;"
                    "varying mediump vec2 textureCoordinate;"
                    "void main()"
                    "{"
                    "  gl_FragColor = texture2D(inputImageTexture, textureCoordinate);"
                    "}";


    sceneProgram.init(TEXTURE_VSH, TEXTURE_FSH, std::vector<std::string>{"inputImageTexture","mvp"}, std::vector<std::string>{"inputTextureCoordinate","position"});
/*
    for(int i=0;i<100;i++)
    {
        textures[i] = GL_NONE;
        textures_f[i] = GL_NONE;
    }
*/
}
