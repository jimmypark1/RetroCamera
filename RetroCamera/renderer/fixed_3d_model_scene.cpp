#include "fixed_3d_model_scene.hpp"
#include "models.hpp"
#include "binaryface.h"

using namespace Eigen;
using namespace facemod;

Fixed3dModelScene::Fixed3dModelScene(
      const char *texFileName,const char *earringName,const char *_glassesName,const char* _hatName,const char* _mustacheName,
      const float *vertices,
      const float *texCoords,
      const short *faceIndices,
      const int faceIndicesSize, bool bigEyes, bool vline)
: texFileName(texFileName),
  vertices(vertices),
  texCoords(texCoords),
  faceIndices(faceIndices),
  faceIndicesSize(faceIndicesSize)
{
    
//    const int Models::facialMaskVerticesSize = sizeof(Models::facialMaskVertices) / sizeof(float);

    
    int verticeSize = sizeof(*vertices)/sizeof(float);
    earName = std::string( earringName) ;
    glassName = std::string( _glassesName) ;

    hatName = std::string( _hatName) ;
    mustacheName = std::string( _mustacheName) ;

    bBigEyes = bigEyes;
    bVline = vline;
    
    FACEDEPTH_VSH =
    "attribute mediump vec3 position;"
    "uniform mediump mat4 mvp;"
    "void main()"
    "{"
    "  mediump vec4 p = mvp * vec4(position, 1.0);"
    "  gl_Position = p / p.w;"
    "}";

    FACEDEPTH_FSH =
    "void main()"
    "{"
    "  gl_FragColor = vec4(1.0, 1.0, 1.0, 0.0);" // you can check the face if alpha > 0.0
    "}";

    TEXTURE_VSH =
    "attribute mediump vec3 position;"
    "attribute mediump vec2 inputTextureCoordinate;"
    "varying mediump vec2 textureCoordinate;"
    "uniform mediump mat4 mvp;"
    "void main()"
    "{"
    "  mediump vec4 p = mvp * vec4(position, 1.0);"
    "  gl_Position = p / p.w;"
    "  textureCoordinate = inputTextureCoordinate;"
    "}";
    
    TEXTURE_FSH =
    "uniform sampler2D inputImageTexture;"
    "varying mediump vec2 textureCoordinate;"
    "void main()"
    "{"
    "  if (!gl_FrontFacing) discard;"
    "  gl_FragColor = texture2D(inputImageTexture, textureCoordinate);"
    "}";
    
    TEXTURE_VSH2 =
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
    
    TEXTURE_FSH2 =
    "uniform sampler2D inputImageTexture;"
    "varying mediump vec2 textureCoordinate;"
    "void main()"
    "{"
    "  gl_FragColor = texture2D(inputImageTexture, textureCoordinate);"
    "}";

    
    FACE_VSH =
    "#version 100\n"
    "attribute mediump vec2 position;"
    "attribute mediump vec2 texcoord;"
    "attribute mediump vec2 offcoord;"
    "attribute mediump vec4 axes;"
    "varying mediump vec2 texcoordi;"
    "varying mediump vec2 offcoordi;"
    "varying mediump vec4 axesi;"
    "void main()"
    "{"
    "  gl_Position = vec4(position, 0.0, 1.0);"
    "  texcoordi = texcoord;"
    "  offcoordi = offcoord;"
    "  axesi = axes;"
    "}";
    
    FACE_FSH =
    "#version 100\n"
    "uniform sampler2D tex_y;"
    "uniform sampler2D tex_uv;"
    "uniform sampler2D off_tex;"
    "varying mediump vec2 texcoordi;"
    "varying mediump vec2 offcoordi;"
    "varying mediump vec4 axesi;"
    "void main()"
    "{"
    "  mediump vec4 disp = texture2D(off_tex, offcoordi);"
    "  mediump vec2 offs = axesi.rg * (disp.r - 0.5) + axesi.ba * (disp.g - 0.5);"
    "  mediump vec2 pt = texcoordi - offs * 0.125;"
    "  lowp float y = texture2D(tex_y, pt).r;"
    "  lowp vec4 uv = texture2D(tex_uv, pt);"
    "  lowp vec4 color = y * vec4(1.0, 1.0, 1.0, 1.0) + "
#ifdef __APPLE__
    "                  (uv.r - 0.5) * vec4(0.0, -0.337633, 1.732446, 0.0) + "
    "                  (uv.a - 0.5) * vec4(1.370705, -0.698001, 0.0, 0.0); "
#else
    "                  (uv.a - 0.5) * vec4(0.0, -0.337633, 1.732446, 0.0) + "
    "                  (uv.r - 0.5) * vec4(1.370705, -0.698001, 0.0, 0.0); "
#endif
    "  gl_FragColor = color;"
    "}";
    texture = 0;
    renderGCnt = 0;
    
    textureOff = GL_NONE;
    textureOff2 = GL_NONE;
    initTextures();

}

void Fixed3dModelScene::release()
{
    BaseFaceScene::release();
    faceDepthProgram.release();
    fixedModelProgram.release();
    sceneProgram.release();
    faceModProgram.release();
    
    if (texture != GL_NONE) {
        GLuint textures[2];
        textures[0] = texture;
        
        glDeleteTextures(1, textures);
        texture = GL_NONE;
    }
    if(ear_textures[0] != GL_NONE)
        glDeleteTextures(30, ear_textures);
  
    if (mustache_textures[0] != GL_NONE)
        glDeleteTextures(30, mustache_textures);
    
    if(hat_textures[0] != GL_NONE)
        glDeleteTextures(30, hat_textures);
    if(glass_textures[0] != GL_NONE)
        glDeleteTextures(30, glass_textures);

    
    if (depthRenderBuffer) {
        glDeleteRenderbuffers(1, &depthRenderBuffer);
        depthRenderBuffer = 0;
    }
}
void Fixed3dModelScene::initTextures()
{
    for(int i=0;i<30;i++)
    {
        ear_textures[i] = GL_NONE;
        hat_textures[i] = GL_NONE;
        glass_textures[i] = GL_NONE;
        mustache_textures[i]= GL_NONE;
    }
    hatCnt = 0;
}
void Fixed3dModelScene::init(binaryface_session_t session, int numFeaturePoints, char* name, int openEyes)
{
    BaseFaceScene::init(session, numFeaturePoints, name, openEyes);
    
    numTrackingPoints = Models::foreheadPointsSize / 3;
    binaryface_session_register_tracking_3d_points(session, numTrackingPoints, Models::foreheadPoints);
    binaryface_set_session_parameter_int(session, BINARYFACE_CONFIG_MAX_NUM_FACES, 100);
    binaryface_get_session_info(session, &sessionInfo);
    
    faceDepthProgram.init(FACEDEPTH_VSH, FACEDEPTH_FSH,
                          std::vector<std::string>{"mvp"},
                          std::vector<std::string>{"position"});
    fixedModelProgram.init(TEXTURE_VSH, TEXTURE_FSH, std::vector<std::string>{"inputImageTexture", "mvp"}, std::vector<std::string>{"position", "inputTextureCoordinate"});
    
    sceneProgram.init(TEXTURE_VSH2, TEXTURE_FSH2, std::vector<std::string>{"inputImageTexture","mvp"}, std::vector<std::string>{"inputTextureCoordinate","position"});

    texture = AssetManager::loadTexture2(texFileName, "png");

    renderGCnt = 0;
    faceModProgram.init(FACE_VSH, FACE_FSH,
                        std::vector<std::string>{"tex_y", "tex_uv", "off_tex"},
                        std::vector<std::string>{"position", "texcoord", "offcoord", "axes"});
    
    const char *e_name = earName.c_str();
    
    if(earName.compare("none")!=0)
        ear_textures[0] = AssetManager::loadTexture2(e_name, "png");
    
    if(glassName.compare("none")!=0)
    {
        const char *g_name = glassName.c_str();
        glass_textures[0] = AssetManager::loadTexture2(g_name, "png");
    }
    
    if(mustacheName.compare("none")!=0)
    {
        const char *m_name = mustacheName.c_str();
        mustache_textures[0]= AssetManager::loadTexture2(m_name, "png");
    }
    if(hatName.compare("none")!=0)
    {
        const char *h_name = hatName.c_str();
        hat_textures[0] = AssetManager::loadTexture2(h_name, "png");
    }
    
    //  Load the texture
    if(bBigEyes)
    {
        std::string s;
        AssetManager::loadRaw("bigeyes", "json", s);
        
        faceMod.decode(s.c_str());
        GLuint textures1[1];
        glGenTextures(1, textures1);
        
        textureOff = textures1[0];
        
        glBindTexture(GL_TEXTURE_2D, textureOff);
        
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_NEAREST);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
        
        
        glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, FACE_MOD_TEXTURE_SIZE, FACE_MOD_TEXTURE_SIZE, 0, GL_RGBA, GL_UNSIGNED_BYTE, faceMod.getRGBABitmap());
        
    }
    if(bVline)
    {
        std::string s2;
        AssetManager::loadRaw("vline", "json", s2);
        
        faceMod.decode(s2.c_str());
        
        //  Load the texture
        
        GLuint textures2[1];
        glGenTextures(1, textures2);
        
        textureOff2 = textures2[0];
        
        glBindTexture(GL_TEXTURE_2D, textureOff2);
        
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_NEAREST);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
        
        
        glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, FACE_MOD_TEXTURE_SIZE, FACE_MOD_TEXTURE_SIZE, 0, GL_RGBA, GL_UNSIGNED_BYTE, faceMod.getRGBABitmap());
        
        
    }
    depthRenderBuffer = 0;
    
    
}

void Fixed3dModelScene::renderCrown3(std::vector<std::vector<float>> faces,std::vector<Matrix4f> matrixs)
{
    
    float determinantScreenToViewPort = screenToViewport(0, 0) * screenToViewport(1, 1) - screenToViewport(1, 0) * screenToViewport(0, 1);
    bool isCW = determinantScreenToViewPort > 0;
    glDisable(GLenum(GL_CULL_FACE));
    glFrontFace(GLenum(isCW ? GL_CW : GL_CCW));
    
    
    sceneProgram.use();
    
    bool bFaces = false;
    
    int i=0;
    for (auto face : faces) {
        int verticesIndex = 0;
        bFaces = true;
        
        
        //234,181
        float width = 1.35*fabs(face[0*3]-face[32*3])/2;
        if(typeName.compare("hat2")==0)
            width = 1.25*fabs(face[0*3]-face[32*3])/2;
        if(typeName.compare("hat3")==0)
            width = 2.6*fabs(face[0*3]-face[32*3])/2;
        if(typeName.compare("hat4")==0)
            width = 1.56*fabs(face[0*3]-face[32*3])/2;
        if(typeName.compare("hat5")==0)
            width = 1.56*fabs(face[0*3]-face[32*3])/2;
        if(typeName.compare("hat6")==0)
            width = 1.3*fabs(face[0*3]-face[32*3])/2;
        if(typeName.compare("hat7")==0)
            width = 1.3*fabs(face[0*3]-face[32*3])/2;
        if(typeName.compare("hat8")==0)
            width = 1.35*fabs(face[0*3]-face[32*3])/2;
        if(typeName.compare("hat9")==0)
            width = 1.25*fabs(face[0*3]-face[32*3])/2;
        
        float height;
        if(typeName.compare("crown")==0)
            height = 141.0f*width/177.0f;
        else if(typeName.compare("crown2")==0)
            height = 236.0f*width/266.0f;
        else if(typeName.compare("crown3")==0)
            height = 136.0f*width/280.0f;
        else if(typeName.compare("crown4")==0)
            height = 136.0f*width/280.0f;
        else if(typeName.compare("glasses2")==0)
            //296x297
            height = 297.0f*width/296.0f;
        else if(typeName.compare("hat2")==0)
            //296x297
            height = 284.0f*width/361.0f;
        else if(typeName.compare("hat3")==0)
            //296x297
            height = 236.0f*width/413.0f;
        else if(typeName.compare("hat4")==0)
            //296x297
            height = 241.0f*width/373.0f;
        else if(typeName.compare("hat5")==0)
            //296x297
            height = 0.8*261.0f*width/281.0f;
        else if(typeName.compare("hat6")==0)
            height = 380.0f*width/329.0f;
        else if(typeName.compare("hat7")==0)
            height = 428.0f*width/334.0f;
        else if(typeName.compare("hat8")==0)
            height = 408.0f*width/310.0f;
        else if(typeName.compare("hat9")==0)
            height = 224.0f*width/263.0f;
        
        //   float width = height*174.0f/272.0f;
        float height2 = fabs(face[67*3+1]-face[16*3+1]);
        
        float x;
        
        x= face[67*3];
        if(typeName.compare("crown")==0)
        {
            x = face[39*3];
        }
        
        float y;
        y = face[67*3 +1]+1.5*height2;
        if(typeName.compare("crown3")==0)
        {
            y = face[67*3 +1]+height2/2.0f;
            
        }
        if(typeName.compare("hat2")==0)
        {
            y = face[67*3 +1]+height2;
            
        }
        if(typeName.compare("hat3")==0)
        {
            y = face[67*3 +1]+0.75*height2;
            
        }
        if(typeName.compare("hat4")==0)
        {
            y = face[67*3 +1]+0.8*height2;
            
        }
        if(typeName.compare("hat5")==0)
        {
            y = face[67*3 +1]+0.85*height2;
            
        }
        if(typeName.compare("hat6")==0)
        {
            y = face[67*3 +1]+1.2*height2;
            
        }
        if(typeName.compare("hat7")==0)
        {
            y = face[67*3 +1]+1.2*height2;
            
        }
        if(typeName.compare("hat8")==0)
        {
            y = face[67*3 +1]+1.4*height2;
            
        }
        if(typeName.compare("hat9")==0)
        {
            y = face[67*3 +1]+1.3*height2;
            
        }
        if(typeName.compare("glasses2")==0)
        {
            y = face[67*3 +1]+1.1*height2;
            
        }
        
        if(hatName.compare("none")!=0)
        {
            //  y = face[67*3 +1]+1.1*height2;
            x= face[67*3];
            width = 1.85*fabs(face[0*3]-face[32*3])/2;
            if(hatName.compare("hat_santa")==0)
            {
                y = face[67*3 +1]+1.15*height2;
                
                height = 196.0f*width/320.0f;
            }
            if(hatName.compare("hat_witch")==0)
            {
                //   y = face[67*3 +1]+1.2*height2;
                y = face[67*3 +1]+1.5*height2;
                height = 176.0f*width/256.0f;
            }
            if(hatName.compare("hat_chef")==0)
            {
                y = face[67*3 +1]+1.55*height2;
                height = 173.0f*width/256.0f;
            }
            if(hatName.compare("hat_cowboy")==0 )
            {
                // y = face[67*3 +1]+1.5*height2;
                y = face[67*3 +1]+1.1*height2;
                height = 127.0f*width/256.0f;
            }
            if(hatName.compare("hat_cowboy2")==0 )
            {
                y = face[67*3 +1]+1.1*height2;
                height = 159.0f*width/256.0f;
            }
            if(hatName.compare("hat_baseball")==0)
            {
                y = face[67*3 +1]+0.8*height2;
                x= face[67*3];
                width = 1.2*fabs(face[0*3]-face[32*3])/2;
                
                height = 254.0f*width/256.0f;
                
            }
            if(hatName.compare("hat_baseball2")==0)
            {
                y = face[67*3 +1]+0.8*height2;
                x= face[67*3];
                width = 1.2*fabs(face[0*3]-face[32*3])/2;
                
                height = 235.0f*width/256.0f;
                
            }
            if(hatName.compare("hat_pilot")==0)
            {
                y = face[67*3 +1]+0.8*height2;
                x= face[67*3];
                width = 1.35*fabs(face[0*3]-face[32*3])/2;
                
                height = 183.0f*width/256.0f;
                
                
            }
            if(hatName.compare("hat_pilot2")==0)
            {
                y = face[67*3 +1]+1.1*height2;
                x= face[67*3];
                width = 1.85*fabs(face[0*3]-face[32*3])/2;
                
                height = 91.0f*width/256.0f;
                
            }
            if(hatName.compare("hat_indian")==0)
            {
                y = face[67*3 +1]+0.7*height2;
                x= face[67*3];
                width = 2.8*fabs(face[0*3]-face[32*3])/2;
                
                height = 245.0f*width/256.0f;
                
            }
            if(hatName.compare("hat_party")==0||hatName.compare("hat_party2")==0)
            {
                y = face[67*3 +1]+1.8*height2;
                x= face[67*3];
                width = 0.9*fabs(face[0*3]-face[32*3])/2;
                
                height = 256.0f*width/155.0f;
                
            }
            if(hatName.compare("hat_detective")==0)
            {
                y = face[67*3 +1]+height2;
                x= face[67*3];
                width = 1.3*fabs(face[0*3]-face[32*3])/2;
                
                height = 202.0f*width/256.0f;
                
            }
            if(hatName.compare("hat_summer")==0)
            {
                y = face[67*3 +1]+height2;
                x= face[67*3];
                width = 1.8*fabs(face[0*3]-face[32*3])/2;
                
                height = 146.0f*width/256.0f;
                
            }
            if(hatName.compare("hat_summer2")==0)
            {
                y = face[67*3 +1]+height2;
                x= face[67*3];
                width = 1.8*fabs(face[0*3]-face[32*3])/2;
                
                height = 133.0f*width/256.0f;
                
            }
            if(hatName.compare("hat_elegant")==0)
            {
                y = face[67*3 +1]+height2;
                x= face[67*3];
                width = 2.2*fabs(face[0*3]-face[32*3])/2;
                
                height = 122.0f*width/256.0f;
                
            }
            if(hatName.compare("hat_sea")==0)
            {
                y = face[67*3 +1]+height2;
                x= face[67*3];
                width = 1.3*fabs(face[0*3]-face[32*3])/2;
                
                height = 154.0f*width/256.0f;
                
            }
            if(hatName.compare("hat_party3")==0)
            {
                y = face[67*3 +1]+0.95*height2;
                x= face[67*3];
                width = 1.3*fabs(face[0*3]-face[32*3])/2;
                
                height = 178.0f*width/256.0f;
                
            }
            if(hatName.compare("hat_party4")==0)
            {
                y = face[67*3 +1]+0.95*height2;
                x= face[67*3];
                width = 1.45*fabs(face[0*3]-face[32*3])/2;
                
                height = 140.0f*width/256.0f;
                
            }
        }
        GLfloat vertex[12] = {
            -width+x, -height+y,0,
            width+x, (-height+y),0,
            -width+x,  height+y,0,
            width+x,  (height+y),0
        };
        
        
        
        
        GLfloat _textureCoordinates[8] = {
            0.0f, 0.0f,
            1.0f, 0.0f,
            0.0f, 1.0f,
            1.0f, 1.0f,
        };
        
        
        short order[] = {0,1,2,2,1,3};
        //      short order[] = {0,1,2,2,1,3};
        int indicedSize =sizeof(order)/sizeof(short);
        
        
        //  int index = (int)RandomFloat(0.0f,23.0f);
        
        int positionCoordLoc = sceneProgram.getAttributeLocation("position");
        
        glEnableVertexAttribArray( positionCoordLoc );
        
        glVertexAttribPointer(positionCoordLoc, 3, GLenum(GL_FLOAT), 0, 0, (void*)vertex);
        
        int texCoordLoc = sceneProgram.getAttributeLocation("inputTextureCoordinate");
        glEnableVertexAttribArray(texCoordLoc);
        glVertexAttribPointer(texCoordLoc, 2, GLenum(GL_FLOAT), 0, 0, textureCoordinates);
        
        
        glActiveTexture(GLenum(GL_TEXTURE2));
        if(typeName.compare("hat2")==0)
        {
            if(outputMirrored)
                glBindTexture(GLenum(GL_TEXTURE_2D), hat_textures[hatCnt+3]);
            else
                glBindTexture(GLenum(GL_TEXTURE_2D), hat_textures[hatCnt]);
            
        }
        else
            glBindTexture(GLenum(GL_TEXTURE_2D), hat_textures[hatCnt]);
        
        
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
    hatCnt++;
    if(typeName.compare("crown")==0 ||typeName.compare("crown3")==0||
       typeName.compare("hat2")==0 )
    {
        if(hatCnt==3)
            hatCnt = 0;
        
    } else if(typeName.compare("crown2")==0||
              typeName.compare("hat3")==0||
              typeName.compare("hat4")==0||
              typeName.compare("hat5")==0||
              typeName.compare("hat6")==0||
              typeName.compare("hat7")==0||
              typeName.compare("hat8")==0||
              typeName.compare("hat9")==0)
    {
        if(hatCnt==6)
            hatCnt = 0;
        
    } else if(typeName.compare("glasses2")==0)
    {
        if(hatCnt==15)
            hatCnt = 0;
        
    }
    if(hatName.compare("none")!=0)
    {
        hatCnt = 0;
    }
    
    
    
}

void Fixed3dModelScene::renderEarring(std::vector<std::vector<float>> faces,std::vector<Matrix4f> matrixs)
{
    
    float determinantScreenToViewPort = screenToViewport(0, 0) * screenToViewport(1, 1) - screenToViewport(1, 0) * screenToViewport(0, 1);
    bool isCW = determinantScreenToViewPort > 0;
    glDisable(GLenum(GL_CULL_FACE));
    glFrontFace(GLenum(isCW ? GL_CW : GL_CCW));
    
    sceneProgram.use();
    
    bool bFaces = false;
    
    
    int i =0;
    for (auto face : faces) {
        int verticesIndex = 0;
        bFaces = true;
        
        //124,213
        float width = fabs(face[93*3]-face[96*3])/2;
        //46,70
        float height = 204.0f*width/72.0f;
        if(earName.compare("a10_earing")==0)
            height= 159.0f*width/122.0f;
        
        float height2 = fabs(face[70*3+1]-face[16*3+1])/2;
        
        float x = face[27*3];
        float y = face[27*3 +1];
        
        
        GLfloat vertex[12] = {
            -width+x, -height+y,face[27*3+2],
            width+x, (-height+y),face[27*3+2],
            -width+x,  height+y,face[27*3+2],
            width+x,  (height+y),face[27*3+2]
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
        glBindTexture(GLenum(GL_TEXTURE_2D), ear_textures[0]);
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
    //renderCnt5++;
    //if(renderCnt5==3)
    //    renderCnt5 = 0;
    
    
}

void Fixed3dModelScene::renderEarring2(std::vector<std::vector<float>> faces,std::vector<Matrix4f> matrixs)
{
    
    float determinantScreenToViewPort = screenToViewport(0, 0) * screenToViewport(1, 1) - screenToViewport(1, 0) * screenToViewport(0, 1);
    bool isCW = determinantScreenToViewPort > 0;
    glDisable(GLenum(GL_CULL_FACE));
    glFrontFace(GLenum(isCW ? GL_CW : GL_CCW));
    
    sceneProgram.use();
    
    bool bFaces = false;
    
    
    int i =0;
    for (auto face : faces) {
        int verticesIndex = 0;
        bFaces = true;
        
        //124,213
        float width = fabs(face[93*3]-face[96*3])/2;
        //72,204
        float height = 204.0f*width/72.0f;
        if(earName.compare("a10_earing")==0)
            height= 159.0f*width/122.0f;
        
        float height2 = fabs(face[70*3+1]-face[16*3+1])/2;
        
        float x = 1.05*face[5*3];
        float y = face[5*3 +1];
        
        
        GLfloat vertex[12] = {
            -width+x, -height+y,face[5*3+2],
            width+x, (-height+y),face[5*3+2],
            -width+x,  height+y,face[5*3+2],
            width+x,  (height+y),face[5*3+2]
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
        glBindTexture(GLenum(GL_TEXTURE_2D), ear_textures[0]);
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
    // renderCnt4++;
    // if(renderCnt4==3)
    //     renderCnt4 = 0;
    
    
}

void Fixed3dModelScene::setDest(int width, int height, OUTPUT_UP_DIRECTION upDirection, OUTPUT_MIRRORED mirrored)
{
    BaseFaceScene::setDest(width, height, upDirection, mirrored);
    if (depthRenderBuffer == 0) {
        glGenRenderbuffers(1, &depthRenderBuffer);
        glBindRenderbuffer(GL_RENDERBUFFER, depthRenderBuffer);
        glRenderbufferStorage(GL_RENDERBUFFER, GL_DEPTH_COMPONENT16, outputWidth, outputHeight);
    }
}

std::vector<std::vector<float>> Fixed3dModelScene::getFacesFromBuffer()
{
    std::vector<std::vector<float>> faces;
    if (binaryFaceSession <= 0) return faces;
    
    int32_t numFaces;
    binaryface_get_num_faces(binaryFaceSession, &numFaces);
    for (int i = 0; i < numFaces; i++) {
        std::vector<float> landmark(numFeaturePoints * 3 + numTrackingPoints * 3);
        
        binaryface_face_3d_info_t face3dInfo;
        binaryface_get_face_3d_info(binaryFaceSession, i, &face3dInfo, &landmark[0], &landmark[numFeaturePoints * 3]);
        
        faces.push_back(landmark);
    }
    return faces;
}

std::vector<Matrix4f> Fixed3dModelScene::getTransformMatrixFromBuffer()
{
    std::vector<Matrix4f> transformMatrixs;
    if (binaryFaceSession <= 0) return transformMatrixs;
    
    int32_t numFaces;
    binaryface_get_num_faces(binaryFaceSession, &numFaces);
    for (int i = 0; i < numFaces; i++) {
        binaryface_face_3d_info_t face3dInfo;
        binaryface_get_face_3d_info(binaryFaceSession, i, &face3dInfo, NULL, NULL);
        Matrix4f rigidMotionMatrix, cameraMatrixOpenGL;
        for (int row = 0; row < 4; row++)
            for (int col = 0; col < 4; col++) {
                rigidMotionMatrix(row, col) = face3dInfo.rigid_motion_matrix[row][col];
                cameraMatrixOpenGL(row, col) = sessionInfo.camera_matrix[row][col];
            }
        float Z_NEAR = -50.f;
        float Z_FAR = -3000.f;
        cameraMatrixOpenGL(2, 2) = (-(Z_FAR + Z_NEAR) / (Z_FAR - Z_NEAR));
        cameraMatrixOpenGL(2, 3) = (-2.0 * Z_FAR * Z_NEAR / (Z_FAR - Z_NEAR));
        
        transformMatrixs.push_back((screenToViewport * cameraMatrixOpenGL * rigidMotionMatrix));
    }
    return transformMatrixs;
}
void Fixed3dModelScene::renderMustache(std::vector<std::vector<float>> faces,std::vector<Matrix4f> matrixs)
{
    
    float determinantScreenToViewPort = screenToViewport(0, 0) * screenToViewport(1, 1) - screenToViewport(1, 0) * screenToViewport(0, 1);
    bool isCW = determinantScreenToViewPort > 0;
    glDisable(GLenum(GL_CULL_FACE));
    glFrontFace(GLenum(isCW ? GL_CW : GL_CCW));
    
    
    sceneProgram.use();
    
    bool bFaces = false;
    
    int i=0;
    for (auto face : faces) {
        int verticesIndex = 0;
        bFaces = true;
        
        
        float width = fabs(face[117*3]-face[129*3]);
        //46,70
        float height = 79.0f*width/256.0f;//fabs(face[67*3+1]-face[123*3+1])/2;
        
        float x = face[73*3];
        float y = face[73*3 +1];
        
        if(mustacheName.compare("m_gold") == 0)
        {
            height = 79.0f*width/256.0f;
            x = face[123*3];
            y = 0.85*face[123*3 +1];
            
        }
        if(mustacheName.compare("m_red") == 0)
        {
            height = 81.0f*width/256.0f;
            x = face[123*3];
            y = 0.85*face[123*3 +1];
            
        }
        if(mustacheName.compare("m_black") == 0)
        {
            height = 69.0f*width/256.0f;
            x = face[123*3];
            y = 0.85*face[123*3 +1];
            
        }
        if(mustacheName.compare("m_black2") == 0)
        {
            height = 85.0f*width/256.0f;
            x = face[123*3];
            y = 0.85*face[83*3 +1];
            
        }
        if(mustacheName.compare("m_black3") == 0)
        {
            //   width = fabs(face[93*3]-face[105*3])/2.0;
            height = 85.0f*width/256.0f;
            x = face[123*3];
            y = 1.5*face[83*3 +1];
            
        }
        
        GLfloat vertex[12] = {
            -width+x, -height+y,face[123*3+2],
            width+x, (-height+y),face[123*3+2],
            -width+x,  height+y,face[123*3+2],
            width+x,  (height+y),face[123*3+2]
        };
        
        
        /*
         GLfloat vertex[12] = {
         -width+x, -height+y,face[10*3+2],
         width+x, (-height+y),face[22*3+2],
         -width+x,  height+y,face[10*3+2],
         width+x,  (height+y),face[22*3+2]
         };
         */
        
        GLfloat _textureCoordinates[8] = {
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
        glBindTexture(GLenum(GL_TEXTURE_2D), mustache_textures[0]);
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
    /*
     mustacheCnt++;
     if(mustacheCnt==24)
     mustacheCnt = 0;
     */
    
}
void Fixed3dModelScene::render()
{
    auto faces = getFacesFromBuffer();
    auto matrixs = getTransformMatrixFromBuffer();
    if (!faces.empty())
        glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_DEPTH_ATTACHMENT, GL_RENDERBUFFER,
                                  depthRenderBuffer);
    
    renderBaseInput();
    if (faces.empty())
        return;

    if(bVline)
        renderFace2(faces,matrixs);
    
    if(bBigEyes)
        renderFace(faces,matrixs);
    
    const char *e_name = earName.c_str();
    
    glEnable(GL_BLEND);
    glDepthMask(GL_FALSE);
    glBlendFunc(GL_SRC_ALPHA,GL_ONE_MINUS_SRC_ALPHA);

    if(earName.compare("none")!=0)
    {
 
        renderEarring(faces,matrixs);
        renderEarring2(faces,matrixs);
        
    }

    if(glassName.compare("none")!=0)
    {
        renderScene(faces,matrixs);
        
    }
    if(mustacheName.compare("none")!=0)
        renderMustache(faces,matrixs);
    
    if(hatName.compare("none")!=0)
        renderCrown3(faces,matrixs);
    
    
    glEnable(GLenum(GL_DEPTH_TEST));

    glClearDepthf(1.0f);
    glClear(GL_DEPTH_BUFFER_BIT);

    glDepthFunc(GL_LEQUAL);
    glDepthMask(GL_TRUE);
    glDepthRangef(0.0f, 1.0f);

    renderFaceDepths(faces, matrixs);
    renderFixedModels(matrixs);

    glDisable(GLenum(GL_DEPTH_TEST));
}
std::vector<std::vector<float> > Fixed3dModelScene::getFacesFromBuffer2()
{
    std::vector<std::vector<float> > faces;
    if (binaryFaceSession <= 0) return faces;
    
    int32_t numFaces;
    binaryface_get_num_faces(binaryFaceSession, &numFaces);
    for (int i = 0; i < numFaces; i++) {
        std::vector<float> landmark;
        binaryface_face_3d_info_t face3dInfo;
        std::vector<float> featurePoints(numFeaturePoints * 3);
        std::vector<float> trackingPoints(numTrackingPoints * 3);
        binaryface_get_face_3d_info(binaryFaceSession, i, &face3dInfo, featurePoints.data(), trackingPoints.data());
        
        Matrix4f rigidMotionMatrix, cameraMatrixOpenGL;
        for (int row = 0; row < 4; row++)
            for (int col = 0; col < 4; col++) {
                rigidMotionMatrix(row, col) = face3dInfo.rigid_motion_matrix[row][col];
                cameraMatrixOpenGL(row, col) = sessionInfo.camera_matrix[row][col];
            }
        float Z_NEAR = -50.f;
        float Z_FAR = -3000.f;
        cameraMatrixOpenGL(2, 2) = (-(Z_FAR + Z_NEAR) / (Z_FAR - Z_NEAR));
        cameraMatrixOpenGL(2, 3) = (-2.0 * Z_FAR * Z_NEAR / (Z_FAR - Z_NEAR));
        
        for (int j = 0; j < numFeaturePoints; j++) {
            Vector4f feature(featurePoints[j*3], featurePoints[j*3+1], featurePoints[j*3+2], 1.f);
            Vector4f result = cameraMatrixOpenGL * rigidMotionMatrix * feature;
            Vector3f uvPoint(result(0) / result(3), result(1) / result(3), 1.f);
            landmark.push_back(uvPoint.x());
            landmark.push_back(uvPoint.y());
        }
        
        for (int j = 0; j < numTrackingPoints; j++) {
            Vector4f feature(trackingPoints[j*3], trackingPoints[j*3+1], trackingPoints[j*3+2], 1.f);
            Vector4f result = cameraMatrixOpenGL * rigidMotionMatrix * feature;
            Vector3f uvPoint(result(0) / result(3), result(1) / result(3), 1.f);
            landmark.push_back(uvPoint.x());
            landmark.push_back(uvPoint.y());
        }
        faces.push_back(landmark);
    }
    return faces;
}

void Fixed3dModelScene::renderScene(std::vector<std::vector<float>> faces,std::vector<Matrix4f> matrixs)
{
    
    float determinantScreenToViewPort = screenToViewport(0, 0) * screenToViewport(1, 1) - screenToViewport(1, 0) * screenToViewport(0, 1);
    bool isCW = determinantScreenToViewPort > 0;
    glDisable(GLenum(GL_CULL_FACE));
    glFrontFace(GLenum(isCW ? GL_CW : GL_CCW));
    
    
    sceneProgram.use();
    
    bool bFaces = false;
    
    
    int i =0;
    for (auto face : faces) {
        int verticesIndex = 0;
        bFaces = true;
        
        
        float width;
        if(typeName.compare("round_glasses")==0)
        {
            width= fabs(face[33*3]-face[50*3])/2;
            
        }
        else if(typeName.compare("glasses2")==0)
        {
            width= fabs(face[0]-face[32*3])/2;
            
        }
        else if(typeName.compare("hat8")==0)
        {
            width= fabs(face[0]-face[32*3])/2;
            
        }
        else
        {
            width= fabs(face[0]-face[32*3])/2;
            
        }
        //46,70
        float height = fabs(face[46*3+1]-face[76*3+1])/2;
        if(glassName.compare("n_g0")==0)
            height= 98.0f*width/264.0f;
        
        else if(glassName.compare("n_g1")==0)
            height= 100.0f*width/282.0f;
        else if(glassName.compare("n_g2")==0)
            height= 86.0f*width/256.0f;
        else if(glassName.compare("n_g3")==0||
                glassName.compare("n_g4")==0||
                glassName.compare("n_g5")==0||
                glassName.compare("n_g6")==0||
                glassName.compare("n_g7")==0||
                glassName.compare("n_g8")==0)
            height= 80.0f*width/256.0f;
        else if(glassName.compare("n_g9")==0)
            height= 94.0f*width/256.0f;
        else if(glassName.compare("n_g10")==0)
            height= 67.0f*width/256.0f;
        else if(glassName.compare("n_g11")==0)
            height= 88.0f*width/256.0f;
        else if(glassName.compare("n_g12")==0)
            height= 81.0f*width/256.0f;
        else if(glassName.compare("n_g13")==0)
            height= 105.0f*width/256.0f;
        
        float x = face[68*3];
        float y = face[68*3 +1];
        float z = face[68*3 +2];
        
        
        GLfloat vertex[12] = {
            -width+x, -height+y,face[67*3+2],
            width+x, (-height+y),face[67*3+2],
            -width+x,  height+y,face[67*3+2],
            width+x,  (height+y),face[67*3+2]
        };
        
        
        
        
        GLfloat _textureCoordinates[8] = {
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
        glBindTexture(GLenum(GL_TEXTURE_2D), glass_textures[renderGCnt]);
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
    }
    
    if(typeName.compare("round_glasses")==0 &&(glassName.compare("none")==0))
    {
        renderGCnt++;
        if(renderGCnt==5)
            renderGCnt = 0;
        
    }
    else if(typeName.compare("glasses2")==0 || typeName.compare("hat3")==0
            || typeName.compare("hat4")==0|| typeName.compare("hat5")==0
            || typeName.compare("hat6")==0
            || typeName.compare("hat8")==0|| typeName.compare("hat9")==0)
    {
        //renderGCnt++;
        //if(renderGCnt==6)
        renderGCnt = 0;
        
    }
    else  if(typeName.compare("glasses")==0&&(glassName.compare("none")==0))
    {
        renderGCnt++;
        if(renderGCnt==16)
            renderGCnt = 0;
        
    }
    else
    {
        renderGCnt = 0;
        
    }
    
}
void Fixed3dModelScene::renderFace(std::vector<std::vector<float>> faces,std::vector<Matrix4f> matrixs)
{
    // renderBaseInput();
    
    std::vector<std::vector<float> > feature_points = getFacesFromBuffer2();
    if (feature_points.size() <= 0) return;
    
    for (int i = 0; i < feature_points.size(); i++)
        feature_points[i] = getFace66(feature_points[i], numTrackingPoints);
    
    faceModProgram.use();
    
    float determinantScreenToViewPort = screenToViewport(0, 0) * screenToViewport(1, 1) - screenToViewport(1, 0) * screenToViewport(0, 1);
    bool isCW = determinantScreenToViewPort > 0;
    
    glDisable(GLenum(GL_DEPTH_TEST));
    glDisable(GLenum(GL_CULL_FACE));
    glFrontFace(GLenum(isCW ? GL_CW : GL_CCW));
    
    glEnable(GLenum(GL_SCISSOR_TEST));
    glScissor((int)((std::min(imageVertices[0], imageVertices[6]) + 1.0f) * outputWidth * 0.5f),
              (int)((std::min(imageVertices[1], imageVertices[7]) + 1.0f) * outputHeight * 0.5f),
              (int)(outputWidth * 0.5f * std::abs(imageVertices[0] - imageVertices[6])),
              (int)(outputHeight * 0.5f * std::abs(imageVertices[1] - imageVertices[7])));
    
    MatrixXf landmarks(2, 75);
    MatrixXf axes;
    MatrixXf pos;
    MatrixXf offset;
    
    int N = FACE_MOD_NUM_POLY_VERTICES;
    int T = FACE_MOD_NUM_POLY_TRIANGLES;
    
    Matrix<unsigned short, Dynamic, Dynamic, ColMajor> sh_face_indices(3, T);
    
    for (int i = 0; i < T; i++) {
        for (int j = 0; j < 3; j++) {
            sh_face_indices(j, i)  = FACE_MOD_TRIANGLES[i][j];
        }
    }
    
    Matrix3f imgToScreen;
    Matrix3f imgToTexture;
    Matrix3f screenToTexture;
    
    imgToScreen <<
    screenToViewport(0, 0), screenToViewport(0, 1), screenToViewport(0, 3),
    screenToViewport(1, 0), screenToViewport(1, 1), screenToViewport(1, 3),
    screenToViewport(3, 0), screenToViewport(3, 1), screenToViewport(3, 3);
    
    imgToTexture <<
    1.0f / inputWidth, 0.0f, 0.0f,
    0.0f, 1.0f / inputHeight, 0.0f,
    0.0f, 0.0f, 1.0f;
    
    screenToTexture = imgToTexture * imgToScreen.inverse();
    
    MatrixXf sh_positions(2, N);
    MatrixXf sh_texcoords(2, N);
    MatrixXf sh_offcoords(2, N);
    MatrixXf sh_axes(4, N);
    
    glActiveTexture(GL_TEXTURE0);
    glBindTexture(GL_TEXTURE_2D, textureY);
    glUniform1i(faceModProgram.getUniformLocation("tex_y"), 0);
    
    glActiveTexture(GL_TEXTURE1);
    glBindTexture(GL_TEXTURE_2D, textureUV);
    glUniform1i(faceModProgram.getUniformLocation("tex_uv"), 1);
    
    glActiveTexture(GL_TEXTURE2);
    glBindTexture(GL_TEXTURE_2D, textureOff);
    glUniform1i(faceModProgram.getUniformLocation("off_tex"), 2);
    
    GLint positionLoc = faceModProgram.getAttributeLocation("position");
    glEnableVertexAttribArray(positionLoc);
    
    GLint texcoordLoc = faceModProgram.getAttributeLocation("texcoord");
    glEnableVertexAttribArray(texcoordLoc);
    
    GLint offcoordLoc = faceModProgram.getAttributeLocation("offcoord");
    glEnableVertexAttribArray(offcoordLoc);
    
    GLint axesLoc = faceModProgram.getAttributeLocation("axes");
    glEnableVertexAttribArray(axesLoc);
    
    for (int i = 0; i < (int)feature_points.size(); i++) {
        for (int j = 0; j < feature_points[i].size(); j += 2) {
            landmarks(0, j/2) = feature_points[i][j];
            landmarks(1, j/2) = feature_points[i][j+1];
        }
        
        faceMod.translate(landmarks, axes, pos, offset);
        
        for (int j = 0; j < N; j++) {
            Vector3f o;
            o << pos.col(j), 1.0f;
            
            Vector3f v;
            v << pos.col(j) + offset.col(j), 1.0f;
            
            sh_positions.col(j) = (imgToScreen * v).segment(0, 2);
            sh_texcoords.col(j) = (imgToTexture * o).segment(0, 2);
            sh_offcoords.col(j) <<
            FACE_MOD_POLY_VERTICES[j][0], FACE_MOD_POLY_VERTICES[j][1];
            
            Vector3f axis_x, axis_y;
            
            axis_x << axes.col(j).segment(0, 2), 0.0f;
            axis_y << axes.col(j).segment(2, 2), 0.0f;
            
            sh_axes.col(j).segment(0, 2) = (imgToTexture * axis_x).segment(0, 2);
            sh_axes.col(j).segment(2, 2) = (imgToTexture * axis_y).segment(0, 2);
        }
        fillArrayBuffer("face_mod_pos", 2 * N * sizeof(float), sh_positions.data(), GL_DYNAMIC_DRAW);
        glBindBuffer(GL_ARRAY_BUFFER, getArrayBuffer("face_mod_pos"));
        glVertexAttribPointer(positionLoc, 2, GLenum(GL_FLOAT), 0, 0, 0);
        
        fillArrayBuffer("face_mod_tex", 2 * N * sizeof(float), sh_texcoords.data(), GL_DYNAMIC_DRAW);
        glBindBuffer(GL_ARRAY_BUFFER, getArrayBuffer("face_mod_tex"));
        glVertexAttribPointer(texcoordLoc, 2, GLenum(GL_FLOAT), 0, 0, 0);
        
        fillArrayBuffer("face_mod_off", 2 * N * sizeof(float), sh_offcoords.data(), GL_DYNAMIC_DRAW);
        glBindBuffer(GL_ARRAY_BUFFER, getArrayBuffer("face_mod_off"));
        glVertexAttribPointer(offcoordLoc, 2, GLenum(GL_FLOAT), 0, 0, 0);
        
        fillArrayBuffer("face_mod_axes", 4 * N * sizeof(float), sh_axes.data(), GL_DYNAMIC_DRAW);
        glBindBuffer(GL_ARRAY_BUFFER, getArrayBuffer("face_mod_axes"));
        glVertexAttribPointer(axesLoc, 4, GLenum(GL_FLOAT), 0, 0, 0);
        
        fillElementBuffer("face_mod_indices", sh_face_indices.size() * sizeof(GLushort),
                          sh_face_indices.data(), GL_DYNAMIC_DRAW);
        glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, getElementBuffer("face_mod_indices"));
        glDrawElements(GL_TRIANGLES, T * 3, GL_UNSIGNED_SHORT, 0);
    }
    
    //unbind
    
    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, GL_NONE);
    glBindBuffer(GL_ARRAY_BUFFER, GL_NONE);
    
    glActiveTexture(GLenum(GL_TEXTURE0));
    glBindTexture(GLenum(GL_TEXTURE_2D), GL_NONE);
    
    glActiveTexture(GLenum(GL_TEXTURE1));
    glBindTexture(GLenum(GL_TEXTURE_2D), GL_NONE);
    
    glActiveTexture(GLenum(GL_TEXTURE2));
    glBindTexture(GLenum(GL_TEXTURE_2D), GL_NONE);
    
    glDisable(GLenum(GL_SCISSOR_TEST));
}
void Fixed3dModelScene::renderFace2(std::vector<std::vector<float>> faces,std::vector<Matrix4f> matrixs)
{
    // renderBaseInput();
    
    std::vector<std::vector<float> > feature_points = getFacesFromBuffer2();
    if (feature_points.size() <= 0) return;
    
    for (int i = 0; i < feature_points.size(); i++)
        feature_points[i] = getFace66(feature_points[i], numTrackingPoints);
    
    faceModProgram.use();
    
    float determinantScreenToViewPort = screenToViewport(0, 0) * screenToViewport(1, 1) - screenToViewport(1, 0) * screenToViewport(0, 1);
    bool isCW = determinantScreenToViewPort > 0;
    
    glDisable(GLenum(GL_DEPTH_TEST));
    glDisable(GLenum(GL_CULL_FACE));
    glFrontFace(GLenum(isCW ? GL_CW : GL_CCW));
    
    glEnable(GLenum(GL_SCISSOR_TEST));
    glScissor((int)((std::min(imageVertices[0], imageVertices[6]) + 1.0f) * outputWidth * 0.5f),
              (int)((std::min(imageVertices[1], imageVertices[7]) + 1.0f) * outputHeight * 0.5f),
              (int)(outputWidth * 0.5f * std::abs(imageVertices[0] - imageVertices[6])),
              (int)(outputHeight * 0.5f * std::abs(imageVertices[1] - imageVertices[7])));
    
    MatrixXf landmarks(2, 75);
    MatrixXf axes;
    MatrixXf pos;
    MatrixXf offset;
    
    int N = FACE_MOD_NUM_POLY_VERTICES;
    int T = FACE_MOD_NUM_POLY_TRIANGLES;
    
    Matrix<unsigned short, Dynamic, Dynamic, ColMajor> sh_face_indices(3, T);
    
    for (int i = 0; i < T; i++) {
        for (int j = 0; j < 3; j++) {
            sh_face_indices(j, i)  = FACE_MOD_TRIANGLES[i][j];
        }
    }
    
    Matrix3f imgToScreen;
    Matrix3f imgToTexture;
    Matrix3f screenToTexture;
    
    imgToScreen <<
    screenToViewport(0, 0), screenToViewport(0, 1), screenToViewport(0, 3),
    screenToViewport(1, 0), screenToViewport(1, 1), screenToViewport(1, 3),
    screenToViewport(3, 0), screenToViewport(3, 1), screenToViewport(3, 3);
    
    imgToTexture <<
    1.0f / inputWidth, 0.0f, 0.0f,
    0.0f, 1.0f / inputHeight, 0.0f,
    0.0f, 0.0f, 1.0f;
    
    screenToTexture = imgToTexture * imgToScreen.inverse();
    
    MatrixXf sh_positions(2, N);
    MatrixXf sh_texcoords(2, N);
    MatrixXf sh_offcoords(2, N);
    MatrixXf sh_axes(4, N);
    
    glActiveTexture(GL_TEXTURE0);
    glBindTexture(GL_TEXTURE_2D, textureY);
    glUniform1i(faceModProgram.getUniformLocation("tex_y"), 0);
    
    glActiveTexture(GL_TEXTURE1);
    glBindTexture(GL_TEXTURE_2D, textureUV);
    glUniform1i(faceModProgram.getUniformLocation("tex_uv"), 1);
    
    glActiveTexture(GL_TEXTURE2);
    glBindTexture(GL_TEXTURE_2D, textureOff2);
    glUniform1i(faceModProgram.getUniformLocation("off_tex"), 2);
    
    GLint positionLoc = faceModProgram.getAttributeLocation("position");
    glEnableVertexAttribArray(positionLoc);
    
    GLint texcoordLoc = faceModProgram.getAttributeLocation("texcoord");
    glEnableVertexAttribArray(texcoordLoc);
    
    GLint offcoordLoc = faceModProgram.getAttributeLocation("offcoord");
    glEnableVertexAttribArray(offcoordLoc);
    
    GLint axesLoc = faceModProgram.getAttributeLocation("axes");
    glEnableVertexAttribArray(axesLoc);
    
    for (int i = 0; i < (int)feature_points.size(); i++) {
        for (int j = 0; j < feature_points[i].size(); j += 2) {
            landmarks(0, j/2) = feature_points[i][j];
            landmarks(1, j/2) = feature_points[i][j+1];
        }
        
        faceMod.translate(landmarks, axes, pos, offset);
        
        for (int j = 0; j < N; j++) {
            Vector3f o;
            o << pos.col(j), 1.0f;
            
            Vector3f v;
            v << pos.col(j) + offset.col(j), 1.0f;
            
            sh_positions.col(j) = (imgToScreen * v).segment(0, 2);
            sh_texcoords.col(j) = (imgToTexture * o).segment(0, 2);
            sh_offcoords.col(j) <<
            FACE_MOD_POLY_VERTICES[j][0], FACE_MOD_POLY_VERTICES[j][1];
            
            Vector3f axis_x, axis_y;
            
            axis_x << axes.col(j).segment(0, 2), 0.0f;
            axis_y << axes.col(j).segment(2, 2), 0.0f;
            
            sh_axes.col(j).segment(0, 2) = (imgToTexture * axis_x).segment(0, 2);
            sh_axes.col(j).segment(2, 2) = (imgToTexture * axis_y).segment(0, 2);
        }
        fillArrayBuffer("face_mod_pos", 2 * N * sizeof(float), sh_positions.data(), GL_DYNAMIC_DRAW);
        glBindBuffer(GL_ARRAY_BUFFER, getArrayBuffer("face_mod_pos"));
        glVertexAttribPointer(positionLoc, 2, GLenum(GL_FLOAT), 0, 0, 0);
        
        fillArrayBuffer("face_mod_tex", 2 * N * sizeof(float), sh_texcoords.data(), GL_DYNAMIC_DRAW);
        glBindBuffer(GL_ARRAY_BUFFER, getArrayBuffer("face_mod_tex"));
        glVertexAttribPointer(texcoordLoc, 2, GLenum(GL_FLOAT), 0, 0, 0);
        
        fillArrayBuffer("face_mod_off", 2 * N * sizeof(float), sh_offcoords.data(), GL_DYNAMIC_DRAW);
        glBindBuffer(GL_ARRAY_BUFFER, getArrayBuffer("face_mod_off"));
        glVertexAttribPointer(offcoordLoc, 2, GLenum(GL_FLOAT), 0, 0, 0);
        
        fillArrayBuffer("face_mod_axes", 4 * N * sizeof(float), sh_axes.data(), GL_DYNAMIC_DRAW);
        glBindBuffer(GL_ARRAY_BUFFER, getArrayBuffer("face_mod_axes"));
        glVertexAttribPointer(axesLoc, 4, GLenum(GL_FLOAT), 0, 0, 0);
        
        fillElementBuffer("face_mod_indices", sh_face_indices.size() * sizeof(GLushort),
                          sh_face_indices.data(), GL_DYNAMIC_DRAW);
        glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, getElementBuffer("face_mod_indices"));
        glDrawElements(GL_TRIANGLES, T * 3, GL_UNSIGNED_SHORT, 0);
    }
    
    //unbind
    
    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, GL_NONE);
    glBindBuffer(GL_ARRAY_BUFFER, GL_NONE);
    
    glActiveTexture(GLenum(GL_TEXTURE0));
    glBindTexture(GLenum(GL_TEXTURE_2D), GL_NONE);
    
    glActiveTexture(GLenum(GL_TEXTURE1));
    glBindTexture(GLenum(GL_TEXTURE_2D), GL_NONE);
    
    glActiveTexture(GLenum(GL_TEXTURE2));
    glBindTexture(GLenum(GL_TEXTURE_2D), GL_NONE);
    
    glDisable(GLenum(GL_SCISSOR_TEST));
}

void Fixed3dModelScene::renderFaceDepths(const std::vector<std::vector<float>>& faces, const std::vector<Matrix4f>& matrixs)
{
    faceDepthProgram.use();

    glEnable(GLenum(GL_BLEND));
    glBlendFunc(GLenum(GL_SRC_ALPHA), GLenum(GL_ONE_MINUS_SRC_ALPHA));
    glColorMask(GLboolean(GL_TRUE), GLboolean(GL_TRUE), GLboolean(GL_TRUE), GLboolean(GL_FALSE));

    for (int i = 0; i < faces.size(); i++) {
        GLint mvp = faceDepthProgram.getUniformLocation("mvp");
        glUniformMatrix4fv(mvp, 1, GLboolean(GL_FALSE), matrixs[i].data());
        
        GLint facePosition = faceDepthProgram.getAttributeLocation("position");
        glEnableVertexAttribArray(facePosition);
        glVertexAttribPointer(facePosition, 3, GLenum(GL_FLOAT), 0, 0, &faces[i][0]);
        //draw
        glDrawElements(GLenum(GL_TRIANGLES), Models::facialMaskNumTriangles * 3, GLenum(GL_UNSIGNED_SHORT), Models::facialMaskTriangleIndices);
    }


    glDisable(GLenum(GL_BLEND));
    glActiveTexture(GL_TEXTURE0);
    glBindTexture(GL_TEXTURE_2D, GL_NONE);
    glColorMask(GL_TRUE, GL_TRUE, GL_TRUE, GL_TRUE);
}

void Fixed3dModelScene::renderFixedModels(const std::vector<Matrix4f>& matrixs)
{
    fixedModelProgram.use();
    
    float determinantScreenToViewPort = screenToViewport(0, 0) * screenToViewport(1, 1) - screenToViewport(1, 0) * screenToViewport(0, 1);
    bool isCW = determinantScreenToViewPort > 0;
    glDisable(GLenum(GL_CULL_FACE));
    glFrontFace(GLenum(isCW ? GL_CW : GL_CCW));
    
    glActiveTexture(GLenum(GL_TEXTURE0));
    glBindTexture(GLenum(GL_TEXTURE_2D), texture);
    glUniform1i(fixedModelProgram.getUniformLocation("inputImageTexture"), 0);;
    
    int positionLoc = fixedModelProgram.getAttributeLocation("position");
    glEnableVertexAttribArray(positionLoc);
    glVertexAttribPointer(positionLoc, 3, GLenum(GL_FLOAT), 0, 0, vertices);
    
    int texCoordLoc = fixedModelProgram.getAttributeLocation("inputTextureCoordinate");
    glEnableVertexAttribArray(texCoordLoc);
    glVertexAttribPointer(texCoordLoc, 2, GLenum(GL_FLOAT), 0, 0, texCoords);
    
    for (auto matrix : matrixs) {
        GLint mvp = fixedModelProgram.getUniformLocation("mvp");
        glUniformMatrix4fv(mvp, 1, GLboolean(GL_FALSE), matrix.data());
        /*
        glDrawElements(GLenum(GL_TRIANGLES),
                       faceIndicesSize,
                       GLenum(GL_UNSIGNED_SHORT),
                       faceIndices);
         */
        glDrawArrays(GL_TRIANGLES, 0, faceIndicesSize);

    }
    
    //unbind
    glActiveTexture(GLenum(GL_TEXTURE0));
    glBindTexture(GLenum(GL_TEXTURE_2D), GL_NONE);
}
