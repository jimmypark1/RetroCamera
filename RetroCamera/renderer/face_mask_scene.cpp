#include "face_mask_scene.hpp"
#include "models.hpp"
#include "binaryface.h"
#include "HatComponent.hpp"
#include "GlassesComponent.hpp"
#include "EarComponent.hpp"
#include "EarringComponent.hpp"
#include "MustacheComponent.hpp"
#include "NoseComponent.hpp"
#include "EtcComponent.hpp"

const std::string FaceMaskScene::FACEMASK_VSH =
"#version 100\n"
"attribute mediump vec4 position;"
"attribute mediump vec4 inputTextureCoordinate;"
"attribute mediump vec2 inputAlphaCoordinate;"
"varying mediump vec2 textureCoordinate;"
"varying mediump vec2 alphaCoordinate;"
"void main()"
"{"
"  gl_Position = position;"
"  textureCoordinate = inputTextureCoordinate.xy;"
"  alphaCoordinate = inputAlphaCoordinate;"
"}";

const std::string FaceMaskScene::FACEMASK_FSH =
"#version 100\n"
"varying mediump vec2 textureCoordinate;"
"varying mediump vec2 alphaCoordinate;"
"uniform sampler2D inputImageTexture0;"
"uniform sampler2D inputImageTexture1;"
"uniform lowp vec4 colorMulti;"
"void main()"
"{"
"  gl_FragColor = vec4(texture2D(inputImageTexture0, textureCoordinate).rgb,"
"                      texture2D(inputImageTexture1, alphaCoordinate).r) * "
"                 colorMulti;"
"}";

const std::string FaceMaskScene::FACEMASK_BEAUTY_VSH =
"#version 100\n"
"attribute mediump vec4 position;"
"attribute mediump vec4 inputTextureCoordinate;"
"attribute mediump vec2 inputAlphaCoordinate;"
"uniform float texelWidthOffset;"
"uniform float texelHeightOffset;"
"varying mediump vec2 centerTextureCoordinate;"
"varying mediump vec2 oneStepLeftTextureCoordinate;"
"varying mediump vec2 twoStepsLeftTextureCoordinate;"
"varying mediump vec2 oneStepRightTextureCoordinate;"
"varying mediump vec2 twoStepsRightTextureCoordinate;"
"varying mediump vec2 textureCoordinate;"
"varying mediump vec2 alphaCoordinate;"
"void main()"
"{"
"  gl_Position = position;"
"  textureCoordinate = inputTextureCoordinate.xy;"
"  alphaCoordinate = inputAlphaCoordinate;"
"vec2 firstOffset = vec2(1.5 * texelWidthOffset, 1.5 * texelHeightOffset);"
"vec2 secondOffset = vec2(3.5 * texelWidthOffset, 3.5 * texelHeightOffset);"
"centerTextureCoordinate = textureCoordinate;"
"oneStepLeftTextureCoordinate = textureCoordinate - firstOffset;"
"twoStepsLeftTextureCoordinate = textureCoordinate - secondOffset;"
"oneStepRightTextureCoordinate = textureCoordinate + firstOffset;"
"twoStepsRightTextureCoordinate = textureCoordinate + secondOffset;"
"}";

const std::string FaceMaskScene::FACEMASK_BEAUTY_FSH =
"#version 100\n"
"varying mediump vec2 centerTextureCoordinate;"
"varying mediump vec2 oneStepLeftTextureCoordinate;"
"varying mediump vec2 twoStepsLeftTextureCoordinate;"
"varying mediump vec2 oneStepRightTextureCoordinate;"
"varying mediump vec2 twoStepsRightTextureCoordinate;"
"varying mediump vec2 textureCoordinate;"
"varying mediump vec2 alphaCoordinate;"
"uniform sampler2D inputImageTexture0;"
"uniform sampler2D inputImageTexture1;"
"uniform sampler2D inputImageTexture2;"
"uniform lowp vec4 colorMulti;"

"void main()"
"{"
"  lowp float y = texture2D(inputImageTexture0, centerTextureCoordinate).r;"
"  lowp vec4 uv = texture2D(inputImageTexture1, centerTextureCoordinate);"
"  mediump vec4 color = y * vec4(1.0, 1.0, 1.0, 1.0) + "
#if TARGET_OS_IPHONE || TARGET_OS_SIMULATOR
"                       (uv.r - 0.5) * vec4(0.0, -0.337633, 1.732446, 0.0) + "
"                       (uv.a - 0.5) * vec4(1.370705, -0.698001, 0.0, 0.0); "
#elif WIN32 || TARGET_OS_OSX
"                       (uv.g - 0.5) * vec4(0.0, -0.337633, 1.732446, 0.0) + "
"                       (uv.r - 0.5) * vec4(1.370705, -0.698001, 0.0, 0.0); "
#else // Android
"                       (uv.a - 0.5) * vec4(0.0, -0.337633, 1.732446, 0.0) + "
"                       (uv.r - 0.5) * vec4(1.370705, -0.698001, 0.0, 0.0); "
#endif
"lowp vec4 fragmentColor = color * 0.2;"
"  lowp float y2 = texture2D(inputImageTexture0, oneStepLeftTextureCoordinate).r;"
"  lowp vec4 uv2 = texture2D(inputImageTexture1, oneStepLeftTextureCoordinate);"
"  mediump vec4 color2 = y2 * vec4(1.0, 1.0, 1.0, 1.0) + "
#if TARGET_OS_IPHONE || TARGET_OS_SIMULATOR
"                       (uv2.r - 0.5) * vec4(0.0, -0.337633, 1.732446, 0.0) + "
"                       (uv2.a - 0.5) * vec4(1.370705, -0.698001, 0.0, 0.0); "
#elif WIN32 || TARGET_OS_OSX
"                       (uv2.g - 0.5) * vec4(0.0, -0.337633, 1.732446, 0.0) + "
"                       (uv2.r - 0.5) * vec4(1.370705, -0.698001, 0.0, 0.0); "
#else // Android
"                       (uv2.a - 0.5) * vec4(0.0, -0.337633, 1.732446, 0.0) + "
"                       (uv2.r - 0.5) * vec4(1.370705, -0.698001, 0.0, 0.0); "
#endif
"fragmentColor += color2 * 0.2;"
"  lowp float y3 = texture2D(inputImageTexture0, oneStepRightTextureCoordinate).r;"
"  lowp vec4 uv3 = texture2D(inputImageTexture1, oneStepRightTextureCoordinate);"
"  mediump vec4 color3 = y3 * vec4(1.0, 1.0, 1.0, 1.0) + "
#if TARGET_OS_IPHONE || TARGET_OS_SIMULATOR
"                       (uv3.r - 0.5) * vec4(0.0, -0.337633, 1.732446, 0.0) + "
"                       (uv3.a - 0.5) * vec4(1.370705, -0.698001, 0.0, 0.0); "
#elif WIN32 || TARGET_OS_OSX
"                       (uv3.g - 0.5) * vec4(0.0, -0.337633, 1.732446, 0.0) + "
"                       (uv3.r - 0.5) * vec4(1.370705, -0.698001, 0.0, 0.0); "
#else // Android
"                       (uv3.a - 0.5) * vec4(0.0, -0.337633, 1.732446, 0.0) + "
"                       (uv3.r - 0.5) * vec4(1.370705, -0.698001, 0.0, 0.0); "
#endif
"fragmentColor += color3 * 0.2;"
"  lowp float y4 = texture2D(inputImageTexture0, oneStepRightTextureCoordinate).r;"
"  lowp vec4 uv4 = texture2D(inputImageTexture1, oneStepRightTextureCoordinate);"
"  mediump vec4 color4 = y4 * vec4(1.0, 1.0, 1.0, 1.0) + "
#if TARGET_OS_IPHONE || TARGET_OS_SIMULATOR
"                       (uv4.r - 0.5) * vec4(0.0, -0.337633, 1.732446, 0.0) + "
"                       (uv4.a - 0.5) * vec4(1.370705, -0.698001, 0.0, 0.0); "
#elif WIN32 || TARGET_OS_OSX
"                       (uv4.g - 0.5) * vec4(0.0, -0.337633, 1.732446, 0.0) + "
"                       (uv4.r - 0.5) * vec4(1.370705, -0.698001, 0.0, 0.0); "
#else // Android
"                       (uv4.a - 0.5) * vec4(0.0, -0.337633, 1.732446, 0.0) + "
"                       (uv4.r - 0.5) * vec4(1.370705, -0.698001, 0.0, 0.0); "
#endif
"fragmentColor += color4 * 0.2;"
"  lowp float y5 = texture2D(inputImageTexture0, twoStepsRightTextureCoordinate).r;"
"  lowp vec4 uv5 = texture2D(inputImageTexture1, twoStepsRightTextureCoordinate);"
"  mediump vec4 color5 = y5 * vec4(1.0, 1.0, 1.0, 1.0) + "
#if TARGET_OS_IPHONE || TARGET_OS_SIMULATOR
"                       (uv5.r - 0.5) * vec4(0.0, -0.337633, 1.732446, 0.0) + "
"                       (uv5.a - 0.5) * vec4(1.370705, -0.698001, 0.0, 0.0); "
#elif WIN32 || TARGET_OS_OSX
"                       (uv5.g - 0.5) * vec4(0.0, -0.337633, 1.732446, 0.0) + "
"                       (uv5.r - 0.5) * vec4(1.370705, -0.698001, 0.0, 0.0); "
#else // Android
"                       (uv5.a - 0.5) * vec4(0.0, -0.337633, 1.732446, 0.0) + "
"                       (uv5.r - 0.5) * vec4(1.370705, -0.698001, 0.0, 0.0); "
#endif
"fragmentColor += color5 * 0.2;"
"  lowp vec4 test = texture2D(inputImageTexture0,textureCoordinate);"
"  gl_FragColor = vec4(fragmentColor.rgb,"
"                      texture2D(inputImageTexture2, alphaCoordinate).r) * "
"                 colorMulti;"
"}";


FaceMaskScene::FaceMaskScene(const char *maskName)
: maskName(maskName)
{
}

FaceMaskScene::FaceMaskScene(const char *_texFileName,const char* earringName ,const char* _glassesName,const char* _hatName,const char* _mustacheName,int _type, bool OpenEyes, bool Vline, bool BigEyes)
{
    //  texFileName2 = _texFileName;
    //  jsonFileName2 = jsonName;
    bOpenEyes = OpenEyes;
    
    bVline = Vline;
    bBigEyes = BigEyes;
    
    texN =  std::string( _texFileName );
  //  jsonN =  std::string( jsonName );
    type = _type;
    
    earName = std::string( earringName) ;
    glassName = std::string( _glassesName) ;
    
    hatName = std::string( _hatName) ;
    mustacheName = std::string( _mustacheName) ;
    
    //bBigEyes = bigEyes;
   // bVline = vline;
    

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
    
    textureOff = GL_NONE;
    textureOff2 = GL_NONE;
}


void FaceMaskScene::release()
{
    BaseFaceScene::release();
    faceMaskProgram.release();
    if (maskImg.maskImage != GL_NONE) {
        GLuint textures[2];
        textures[0] = maskImg.maskImage;
        textures[1] = maskImg.alphaImage;
        
        glDeleteTextures(2, textures);
        
        maskImg.maskImage = GL_NONE;
        maskImg.alphaImage = GL_NONE;
    }
}

void FaceMaskScene::initBigEyeProc()
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
    
    
    glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, facemod::FACE_MOD_TEXTURE_SIZE, facemod::FACE_MOD_TEXTURE_SIZE, 0, GL_RGBA, GL_UNSIGNED_BYTE, faceMod.getRGBABitmap());
    
    
}
void FaceMaskScene::initVlineProc()
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
    
    
    glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, facemod::FACE_MOD_TEXTURE_SIZE, facemod::FACE_MOD_TEXTURE_SIZE, 0, GL_RGBA, GL_UNSIGNED_BYTE, faceMod.getRGBABitmap());
    
    
    
}

std::string FaceMaskScene::getName(int type)
{
    std::string name = "";
    switch(type)
    {
        case 0:
            name = glassName;
            break;
        case 1:
            name = hatName;
            break;
        case 2:
            name = earName;
            break;
        case 3:
            name = mustacheName;
            
            break;
    }
    return name;
}

bool FaceMaskScene::getItem(std::string  _name, eItemType type, float *_w_ratio, float *_h_ratio, int *_rule, int *_bound)
{
    float w_ratio = -1;
    float h_ratio = -1;
    int bound = 1;
    
    int size =  d0["item"][type]["sub"].Size();
    
    for(int i=0;i<size;i++)
    {
        std::string  name = d0["item"][type]["sub"][i]["name"].GetString();
        if(name == _name)
        {
            w_ratio = d0["item"][type]["sub"][i]["w_ratio"].GetFloat();
            h_ratio = d0["item"][type]["sub"][i]["h_ratio"].GetFloat();
            
            bound = 1;//d0["item"][type]["sub"][i]["bound"].GetInt();
            
            int temp = 0;
            if( type == eHat)
            {
                temp = d0["item"][type]["sub"][i]["rule"].GetInt();
            }
            *_bound = bound;
            *_rule = temp;
            
            *_w_ratio = w_ratio;
            *_h_ratio = h_ratio;
            
            ;
            return true;
        }
    }
    return false;
}

void FaceMaskScene::setComponent(Component *_comp, eItemType type)
{
    int bound = 1;
    float w_ratio,h_ratio;
    std::string itemName = getName(type);
    int rule;
    if( ret0 != false)
    {
        getItem( itemName, type, &w_ratio, &h_ratio,&rule,&bound);
        
    }
    //
    if(type == eHat)
        _comp->setHatRule(rule);
    
    _comp->setSource(itemName,baseDir,bound,w_ratio,h_ratio);
    compList.push_back(_comp);
    
}
void FaceMaskScene::renderFace(std::vector<std::vector<float>> faces,std::vector<Matrix4f> matrixs)
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
    
    int N = facemod::FACE_MOD_NUM_POLY_VERTICES;
    int T = facemod::FACE_MOD_NUM_POLY_TRIANGLES;
    
    Matrix<unsigned short, Dynamic, Dynamic, ColMajor> sh_face_indices(3, T);
    
    for (int i = 0; i < T; i++) {
        for (int j = 0; j < 3; j++) {
            sh_face_indices(j, i)  = facemod::FACE_MOD_TRIANGLES[i][j];
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
            facemod::FACE_MOD_POLY_VERTICES[j][0], facemod::FACE_MOD_POLY_VERTICES[j][1];
            
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

void FaceMaskScene::renderFace2(std::vector<std::vector<float>> faces,std::vector<Matrix4f> matrixs)
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
    
    int N = facemod::FACE_MOD_NUM_POLY_VERTICES;
    int T = facemod::FACE_MOD_NUM_POLY_TRIANGLES;
    
    Matrix<unsigned short, Dynamic, Dynamic, ColMajor> sh_face_indices(3, T);
    
    for (int i = 0; i < T; i++) {
        for (int j = 0; j < 3; j++) {
            sh_face_indices(j, i)  = facemod::FACE_MOD_TRIANGLES[i][j];
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
            facemod::FACE_MOD_POLY_VERTICES[j][0], facemod::FACE_MOD_POLY_VERTICES[j][1];
            
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

std::vector<std::vector<float> > FaceMaskScene::getFacesFromBuffer2()
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
void FaceMaskScene::init(binaryface_session_t session, int numFeaturePoints, char* name, int openEyes)
{
    BaseFaceScene::init(session, numFeaturePoints,name,openEyes);
    
    // maskImg.loadMaskImage(maskName.c_str(), "jpg");
    if(texN.compare ("none")!=0)
    {
        maskImg.loadMaskImage(texN, "png", bOpenEyes,type);
        
    }
    

    numTrackingPoints = Models::foreheadPointsSize / 3;
    binaryface_session_register_tracking_3d_points(session, numTrackingPoints, Models::foreheadPoints);
    
    //  Panda example: Multi-face mask enabled
    binaryface_set_session_parameter_int(session, BINARYFACE_CONFIG_MAX_NUM_FACES, (maskName == "panda") ? 20 : 1);
    binaryface_get_session_info(session, &sessionInfo);
    
    faceMaskProgram.init(FACEMASK_VSH, FACEMASK_FSH, std::vector<std::string>{"inputImageTexture0", "inputImageTexture1", "colorMulti"}, std::vector<std::string>{"position", "inputTextureCoordinate", "inputAlphaCoordinate"});
 
  //  faceMaskBeautyProgram.init(FACEMASK_BEAUTY_VSH, FACEMASK_BEAUTY_FSH, std::vector<std::string>{"inputImageTexture0", "inputImageTexture1","inputImageTexture2", "colorMulti"}, std::vector<std::string>{"position", "inputTextureCoordinate", "inputAlphaCoordinate","texelWidthOffset","texelHeightOffset"});
    
    fillArrayBuffer("face_mask_vertices", Models::facialMaskVerticesSize * sizeof(float),
                    Models::facialMaskVertices, GL_STATIC_DRAW);
    fillArrayBuffer("face_mask_texture", maskImg.landmarks.size() * sizeof(GLfloat),
                    maskImg.landmarks.data(), GL_STATIC_DRAW);
    fillElementBuffer("face_mask_mask_indices", Models::facialMaskNumTriangles * 3 * sizeof(GLushort),
                      Models::facialMaskTriangleIndices, GL_STATIC_DRAW);
    
    
    faceModProgram.init(FACE_VSH, FACE_FSH,
                        std::vector<std::string>{"tex_y", "tex_uv", "off_tex"},
                        std::vector<std::string>{"position", "texcoord", "offcoord", "axes"});
    
    
    initBigEyeProc();
    initVlineProc();
    
    rapidjson::Document d;
    std::string fullPath0 ;
    std::string fullPath ;
#if TARGET_OS_IPHONE || TARGET_OS_SIMULATOR
    fullPath =  "live_sticker";
#else
    fullPath =  baseDir + "/live_sticker";
    
#endif
    ret0 = false;
    bool ret = false;
    ///////
#if TARGET_OS_IPHONE || TARGET_OS_SIMULATOR
    fullPath0 =  "item";
#else
    fullPath0 =  baseDir + "/item";
    
#endif
    glEnable(GL_TEXTURE_2D);

    ret0 = AssetManager::loadJsonSticker(fullPath0, "json", d0);

    //////
    ret = AssetManager::loadJsonSticker(fullPath, "json", d);

    if(ret == false)
        return;
    
    Component *_comp = nullptr;
    position = -1;
    
    int size =  d["item"].Size();
    /*
    for(int i=0;i<size;i++)
    {
        std::string  name = d["item"][i]["name"].GetString();
        if(name.compare(typeName) == 0)
        {
            position = i;
            break;
        }
    }
     */
    compList.clear();
    
    if(position>=0  )
    {
        
        rapidjson::Document::MemberIterator itr;
        const rapidjson::Value& a = d["item"][position]["accesory"];
        
        for (rapidjson::Value::ConstMemberIterator itr = a.MemberBegin(); itr != a.MemberEnd(); ++itr) {
            
            std::string key = itr->name.GetString();
            
            const char *_key = key.c_str();
            std::string name = d["item"][position]["accesory"][_key]["name"].GetString();
            
            bool ret = false;
            
            eItemType type = eNone;
            float _w_ratio;
            float _h_ratio;
            int _bound = 1;
            
            if( key == "glass")
                type = eGlasses;
            else if( key == "hat")
                type = eHat;
            else if( key == "earring")
                type = eEarring;
            else if( key == "mustache")
                type = eMustache;
            
            std::string itemName = "none";
            if(type >=0 )
                itemName = getName(type);
            
            if(name == "none" && itemName == "none")
                continue;
            
            
            
            int _rule;
            
            if(ret0 != false)
            {
                if(type!= eNone) {
                    
                    ret = getItem( itemName, type, &_w_ratio, &_h_ratio,&_rule,&_bound);
                }
            }
            int bound = d["item"][position]["accesory"][_key]["bound"].GetInt();
            
            float w_ratio = d["item"][position]["accesory"][_key]["w_ratio"].GetFloat();
            float h_ratio = d["item"][position]["accesory"][_key]["h_ratio"].GetFloat();
            
            std::string temp;
            if( key== "glass" ) {
                _comp = new GlassesComponent();
                temp = glassName;
                
                
            }
            else if(key == "hat") {
                int rule = d["item"][position]["accesory"][_key]["rule"].GetInt();
                
                _comp = new HatComponent();
                if(ret0 == true)
                {
                    if(ret == true)
                        rule = _rule;
                    
                }
                
                _comp->setHatRule(rule);
                temp = hatName;
                
            }
            else if(key== "ear" )
            {
                _comp = new EarComponent();
            }
            else if(key == "earring") {
                _comp = new EarringComponent();
                temp = earName;
                
                
            }
            else if(key == "nose" )
                _comp = new NoseComponent();
            else if(key.compare("mustache")== 0 ) {
                _comp = new MustacheComponent();
                temp = mustacheName;
            }
            else if(key == "etc" || key == "etc2" || key == "etc3" || key == "etc4" )
            {
                _comp = new EtcComponent();
                
                int w_x0 = d["item"][position]["accesory"][_key]["w_x0"].GetInt();
                int w_x1 = d["item"][position]["accesory"][_key]["w_x1"].GetInt();
                
                int h_y0 = d["item"][position]["accesory"][_key]["h_y0"].GetInt();
                int h_y1 = d["item"][position]["accesory"][_key]["h_y1"].GetInt();
                
                int s_x = d["item"][position]["accesory"][_key]["s_x"].GetInt();
                int s_y = d["item"][position]["accesory"][_key]["s_y"].GetInt();
                
                float s_x_ratio = d["item"][position]["accesory"][_key]["s_x_ratio"].GetFloat();
                float s_y_ratio = d["item"][position]["accesory"][_key]["s_y_ratio"].GetFloat();
                
                int z0 = d["item"][position]["accesory"][_key]["z0"].GetInt();
                int z1 = d["item"][position]["accesory"][_key]["z1"].GetInt();
                bool mirrored = d["item"][position]["accesory"][_key]["mirrored"].GetBool();
                
                _comp->setEtcSource(w_x0,w_x1,h_y0,h_y1, s_x, s_y,s_x_ratio, s_y_ratio, z0,z1,mirrored);
                
                
            }
            if(ret0 == true)
            {
                if(ret == true) {
                    name = temp;
                    w_ratio = _w_ratio;
                    h_ratio = _h_ratio;
                    bound = _bound;
                }
            }
            
            _comp->type = 0;
            _comp->setSource(name,baseDir,bound,w_ratio,h_ratio);
            compList.push_back(_comp);
            
        }
        
    } else {
        
        Component *_comp = nullptr;
        
        if( glassName != "none")
        {
            _comp = new GlassesComponent();
            _comp->type = 0;
            setComponent(_comp,eGlasses);
        }
        if( hatName != "none")
        {
            
            _comp = new HatComponent();
            _comp->type = 0;
            
            setComponent(_comp,eHat);
        }
        if( earName != "none")
        {
            _comp = new EarringComponent();
            _comp->type = 0;
            setComponent(_comp,eEarring);
        }
        if( mustacheName != "none")
        {
            _comp = new MustacheComponent();
            _comp->type = 0;
            setComponent(_comp,eMustache);
        }
        
    }
    glEnable(GL_TEXTURE_2D);

}

std::vector<std::vector<float>> FaceMaskScene::getFacesFromBuffer()
{
    std::vector<std::vector<float>> faces;
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
        float Z_FAR = -2000.f;
        cameraMatrixOpenGL(2, 2) = (-(Z_FAR + Z_NEAR) / (Z_FAR - Z_NEAR));
        cameraMatrixOpenGL(2, 3) = (-2.0 * Z_FAR * Z_NEAR / (Z_FAR - Z_NEAR));
        
        for (int j = 0; j < numFeaturePoints; j++) {
            Vector4f feature(featurePoints[j*3], featurePoints[j*3+1], featurePoints[j*3+2], 1.f);
            Vector4f result = cameraMatrixOpenGL * rigidMotionMatrix * feature;
            Vector4f uvPoint(result / result(3));
            uvPoint = screenToViewport * uvPoint;
            landmark.push_back(uvPoint.x());
            landmark.push_back(uvPoint.y());
        }
        
        for (int j = 0; j < numTrackingPoints; j++) {
            Vector4f feature(trackingPoints[j*3], trackingPoints[j*3+1], trackingPoints[j*3+2], 1.f);
            Vector4f result = cameraMatrixOpenGL * rigidMotionMatrix * feature;
            Vector4f uvPoint(result / result(3));
            uvPoint = screenToViewport * uvPoint;
            landmark.push_back(uvPoint.x());
            landmark.push_back(uvPoint.y());
        }
        
        faces.push_back(landmark);
    }
    return faces;
}

std::vector<std::vector<float>> FaceMaskScene::getFacesFromBuffer3()
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
Vector3f FaceMaskScene::sampleColor(const Vector2f& v)
{
    Vector4f screenPt = viewportToScreen * Vector4f(v.x(), v.y(), 0.f, 1.f);
    int x = screenPt.x() + 0.5f;
    int y = screenPt.y() + 0.5f;
    
    x = std::min(std::max(0, x), sessionInfo.image_width - 1);
    y = std::min(std::max(0, y), sessionInfo.image_height - 1);
    
    float yValue = (float)yBuffer[x + y * sessionInfo.image_width];
    
    int uvPos = x & (~1);
    uvPos += (y >> 1) * sessionInfo.image_width;
    
    float uValue, vValue;
#if TARGET_OS_IPHONE || TARGET_OS_SIMULATOR
    uValue = (float)uvBuffer[uvPos];
    vValue = (float)uvBuffer[uvPos + 1];
#else
    uValue = (float)uvBuffer[uvPos + 1];
    vValue = (float)uvBuffer[uvPos];
#endif
    float R = std::min(std::max(0.0, yValue + (1.370705 * (vValue - 128.0))), 255.0);
    float G = std::min(std::max(0.0, yValue - (0.698001 * (vValue - 128.0)) - (0.337633 * (uValue - 128.0))), 255.0);
    float B = std::min(std::max(0.0, yValue + (1.732446 * (uValue - 128.0))), 255.0);
    
    return Vector3f(R, G, B);
}

Vector3f FaceMaskScene::calculateMeanColor(const std::vector<float>& face)
{
    int sampler = 30;
    Vector3f sum(0, 0, 0);
    int count = 0;
    for (int index = 0; index < 2; index++) {
        int faceNo = Models::cheekFaces[index];
        Vector3i indices(Models::facialMaskTriangleIndices[faceNo * 3 + 0],
                         Models::facialMaskTriangleIndices[faceNo * 3 + 1],
                         Models::facialMaskTriangleIndices[faceNo * 3 + 2]);
        Vector2f vertices[3];
        vertices[0] << face[indices(0) * 2 + 0], face[indices(0) * 2 + 1];
        vertices[1] << face[indices(1) * 2 + 0], face[indices(1) * 2 + 1];
        vertices[2] << face[indices(2) * 2 + 0], face[indices(2) * 2 + 1];
        
        for (int i = 1; i <= sampler - 2; i++) {
            for (int j = 1; j <= sampler - 1 - i; j++) {
                int k = sampler - (i + j);
                Vector2f v(0, 0);
                v += vertices[0] * i;
                v += vertices[1] * j;
                v += vertices[2] * k;
                v *= (1.0 / sampler);
                sum += sampleColor(v);
                count += 1;
            }
        }
    }
    return sum * (1.0 / count);
}
std::vector<Matrix4f> FaceMaskScene::getTransformMatrixFromBuffer()
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
void FaceMaskScene::render()
{
    
    
    renderBaseInput();
    auto faces = getFacesFromBuffer();
    auto faces2 = getFacesFromBuffer3();
    if (faces.empty()) return;
    
    auto matrixs = getTransformMatrixFromBuffer();

    //  Get the face coordinates
    /*
    if(bVline)
        renderFace2(faces2,matrixs);
    
    if(bBigEyes)
        renderFace(faces2,matrixs);
    
    */
    std::vector<std::vector<float> > face3dCoords;
    std::vector<Vector3f> meanColors;
    
    Vector3f meanColorAverage = Vector3f::Zero();
    
    for (int i = 0; i < faces.size(); i++) {
        std::vector<float> face = getFace66(faces[i], numTrackingPoints);
        
        Vector3f meanColor = calculateMeanColor(face);
        
        face3dCoords.push_back(face);
        meanColors.push_back(meanColor);
        
        meanColorAverage += meanColor;
    }
    
    meanColorAverage /= faces.size();
    
    Vector3f backgroundCompensation = (maskImg.meanColor.array() / (meanColorAverage.array() + 1e-5f)).pow(0.6f);
    
    renderBaseInputColorMulti(backgroundCompensation(0), backgroundCompensation(1), backgroundCompensation(2), 1.0f);
    
    for (int i = 0; i < faces.size(); i++) {
        meanColors[i] = meanColors[i].array() * backgroundCompensation.array();
    }
    
    faceMaskProgram.use();
    
    glEnable(GLenum(GL_BLEND));
    glDepthMask(GL_FALSE);
    glBlendFunc(GLenum(GL_SRC_ALPHA), GLenum(GL_ONE_MINUS_SRC_ALPHA));
    
    glDisable(GLenum(GL_DEPTH_TEST));
    glColorMask(GLboolean(GL_TRUE), GLboolean(GL_TRUE), GLboolean(GL_TRUE), GLboolean(GL_FALSE));
    
    glFrontFace(GLenum(GL_CW));
    
    std::vector<GLfloat> vertices(faces[0].size());
    
    GLint facePosition = faceMaskProgram.getAttributeLocation("position");
    GLint textureCoord = faceMaskProgram.getAttributeLocation("inputTextureCoordinate");
    glEnableVertexAttribArray(textureCoord);
    glBindBuffer(GL_ARRAY_BUFFER, getArrayBuffer("face_mask_texture"));
    glVertexAttribPointer(textureCoord, 2, GLenum(GL_FLOAT), 0, 0, 0);
    
    GLint alphaCoord = faceMaskProgram.getAttributeLocation("inputAlphaCoordinate");
    glEnableVertexAttribArray(alphaCoord);
    glBindBuffer(GL_ARRAY_BUFFER, getArrayBuffer("face_mask_vertices"));
    glVertexAttribPointer(alphaCoord, 2, GLenum(GL_FLOAT), 0, 0, 0);
    
    glActiveTexture(GL_TEXTURE0);
    glBindTexture(GL_TEXTURE_2D, maskImg.maskImage);
    glUniform1i(faceMaskProgram.getUniformLocation("inputImageTexture0"), 0);
    
    glActiveTexture(GL_TEXTURE1);
    glBindTexture(GL_TEXTURE_2D, maskImg.alphaImage);
    glUniform1i(faceMaskProgram.getUniformLocation("inputImageTexture1"), 1);
    
    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, getElementBuffer("face_mask_mask_indices"));
    
    for (int i = 0; i < faces.size(); i++) {
        const auto& face = face3dCoords[i];
        Vector3f faceMeanColor = meanColors[i];
        GLint colorMultiIndex = faceMaskProgram.getUniformLocation("colorMulti");
        glUniform4f(colorMultiIndex,
                    faceMeanColor(0) / maskImg.meanColor(0),
                    faceMeanColor(1) / maskImg.meanColor(1),
                    faceMeanColor(2) / maskImg.meanColor(2),
                    maskImg.alpha);
        
        for (int i = 0; i < face.size(); i++)
            vertices[i] = GLfloat(face[i]);
        
        glEnableVertexAttribArray(facePosition);
        fillArrayBuffer("face_mask_position", vertices.size() * sizeof(GLfloat),
                        &vertices[0], GL_DYNAMIC_DRAW);
        glBindBuffer(GL_ARRAY_BUFFER, getArrayBuffer("face_mask_position"));
        glVertexAttribPointer(facePosition, 2, GLenum(GL_FLOAT), 0, 0, 0);
        
        //draw
        glDrawElements(GLenum(GL_TRIANGLES), Models::facialMaskNumTriangles * 3, GLenum(GL_UNSIGNED_SHORT), 0);
    }
    
    glBindBuffer(GL_ARRAY_BUFFER, GL_NONE);
    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, GL_NONE);
    glActiveTexture(GL_TEXTURE0);
    glBindTexture(GL_TEXTURE_2D, GL_NONE);
    glActiveTexture(GL_TEXTURE1);
    glBindTexture(GL_TEXTURE_2D, GL_NONE);
    
    glColorMask(true, true, true, true);
    
    for(int i=0;i< compList.size();i++)
    {
        comp = compList[i];
        if(outputMirrored)
            comp->bFront = true;
        else
            comp->bFront = false;
        
        if(comp->name.compare ("none")!=0)
        {
            comp->setDest(faces2, matrixs);
            comp->render();
            
        }
    }
    
    glDepthMask(GL_FALSE);
    
    glDisable(GL_BLEND);
    
    ///
    
    
    
    
    
    
}

void FaceMaskScene::renderBeauty()
{
    renderBaseInput();
   // processVideoFrame();
    auto faces = getFacesFromBuffer();
    if (faces.empty()) return;
    
    auto matrixs = getTransformMatrixFromBuffer();
    
    renderFace(faces,matrixs);
    
    glEnable(GL_BLEND);
    glDepthMask(GL_FALSE);
    glBlendFunc(GL_SRC_ALPHA,GL_ONE_MINUS_SRC_ALPHA);
    
    std::vector<std::vector<float> > face3dCoords;
    std::vector<Vector3f> meanColors;
    
    Vector3f meanColorAverage = Vector3f::Zero();
    
    for (int i = 0; i < faces.size(); i++) {
        std::vector<float> face = getFace66(faces[i], numTrackingPoints);
        
        Vector3f meanColor = calculateMeanColor(face);
        
        face3dCoords.push_back(face);
        meanColors.push_back(meanColor);
        
        meanColorAverage += meanColor;
    }
    
    meanColorAverage /= faces.size();
    
    Vector3f backgroundCompensation = (maskImg.meanColor.array() / (meanColorAverage.array() + 1e-5f)).pow(0.6f);
    
    renderBaseInputColorMulti(backgroundCompensation(0), backgroundCompensation(1), backgroundCompensation(2), 1.0f);
    
    for (int i = 0; i < faces.size(); i++) {
        meanColors[i] = meanColors[i].array() * backgroundCompensation.array();
    }
    
    faceMaskBeautyProgram.use();
    
    glEnable(GLenum(GL_BLEND));
    glBlendFunc(GLenum(GL_SRC_ALPHA), GLenum(GL_ONE_MINUS_SRC_ALPHA));
    
    glDisable(GLenum(GL_DEPTH_TEST));
    glColorMask(GLboolean(GL_TRUE), GLboolean(GL_TRUE), GLboolean(GL_TRUE), GLboolean(GL_FALSE));
    
    glFrontFace(GLenum(GL_CW));
    
    std::vector<GLfloat> vertices(faces[0].size());
    
    GLint facePosition = faceMaskBeautyProgram.getAttributeLocation("position");
    GLint textureCoord = faceMaskBeautyProgram.getAttributeLocation("inputTextureCoordinate");
    glEnableVertexAttribArray(textureCoord);
    glBindBuffer(GL_ARRAY_BUFFER, getArrayBuffer("face_mask_texture"));
    glVertexAttribPointer(textureCoord, 2, GLenum(GL_FLOAT), 0, 0, 0);
    
    GLint alphaCoord = faceMaskBeautyProgram.getAttributeLocation("inputAlphaCoordinate");
    glEnableVertexAttribArray(alphaCoord);
    glBindBuffer(GL_ARRAY_BUFFER, getArrayBuffer("face_mask_vertices"));
    glVertexAttribPointer(alphaCoord, 2, GLenum(GL_FLOAT), 0, 0, 0);
    //////
    glActiveTexture(GL_TEXTURE0);
    glBindTexture(GL_TEXTURE_2D, maskImg.maskImage);
    glUniform1i(faceMaskBeautyProgram.getUniformLocation("inputImageTexture0"), 0);
    
    glActiveTexture(GL_TEXTURE1);
    glBindTexture(GL_TEXTURE_2D, textureUV);
    glUniform1i(faceMaskBeautyProgram.getUniformLocation("inputImageTexture1"), 1);
    
    
    glActiveTexture(GL_TEXTURE2);
    glBindTexture(GL_TEXTURE_2D, maskImg.alphaImage);
    glUniform1i(faceMaskBeautyProgram.getUniformLocation("inputImageTexture2"), 2);
    
    glUniform1f(faceMaskBeautyProgram.getUniformLocation("texelWidthOffset"), 1.0f/outputWidth);
    glUniform1f(faceMaskBeautyProgram.getUniformLocation("texelHeightOffset"), 1.0f/outputHeight);
    
    
    ///////////////
    
    //////////////
    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, getElementBuffer("face_mask_mask_indices"));
    
    for (int i = 0; i < faces.size(); i++) {
        const auto& face = face3dCoords[i];
        Vector3f faceMeanColor = meanColors[i];
        GLint colorMultiIndex = faceMaskBeautyProgram.getUniformLocation("colorMulti");
        glUniform4f(colorMultiIndex,
                    faceMeanColor(0) / maskImg.meanColor(0),
                    faceMeanColor(1) / maskImg.meanColor(1),
                    faceMeanColor(2) / maskImg.meanColor(2),
                    maskImg.alpha);
        
        for (int i = 0; i < face.size(); i++)
            vertices[i] = GLfloat(face[i]);
        
        glEnableVertexAttribArray(facePosition);
        fillArrayBuffer("face_mask_position", vertices.size() * sizeof(GLfloat),
                        &vertices[0], GL_DYNAMIC_DRAW);
        glBindBuffer(GL_ARRAY_BUFFER, getArrayBuffer("face_mask_position"));
        glVertexAttribPointer(facePosition, 2, GLenum(GL_FLOAT), 0, 0, 0);
        
        //draw
        glDrawElements(GLenum(GL_TRIANGLES), Models::facialMaskNumTriangles * 3, GLenum(GL_UNSIGNED_SHORT), 0);
    }
    
    glBindBuffer(GL_ARRAY_BUFFER, GL_NONE);
    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, GL_NONE);
    glActiveTexture(GL_TEXTURE0);
    glBindTexture(GL_TEXTURE_2D, GL_NONE);
    glActiveTexture(GL_TEXTURE1);
    glBindTexture(GL_TEXTURE_2D, GL_NONE);
    glActiveTexture(GL_TEXTURE2);
    glBindTexture(GL_TEXTURE_2D, GL_NONE);
    
    glColorMask(true, true, true, true);
    glDisable(GL_BLEND);
    
    glDepthMask(GL_TRUE);
    
}




