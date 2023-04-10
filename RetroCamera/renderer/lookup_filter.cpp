#include "lookup_filter.hpp"
#include "models.hpp"
#include "Component.hpp"
#include "HatComponent.hpp"
#include "GlassesComponent.hpp"
#include "EarComponent.hpp"
#include "EarringComponent.hpp"
#include "MustacheComponent.hpp"
#include "NoseComponent.hpp"
#include "EtcComponent.hpp"

using namespace Eigen;
//using namespace facemod;

LookupFilter::LookupFilter()
{

}

LookupFilter::LookupFilter(std::string _textureName,std::string _stickerName ,const char* earringName ,const char* _glassesName,const char* _hatName,const char* _mustacheName, bool openEyes,bool vline, int _type)
{
//    type = _type;
    resType = _type;
    stickerName = _stickerName;
    typeName =  std::string( _textureName );
    
    
    bBigEyes = openEyes;
    bVline = vline;

    earName = std::string( earringName) ;
    glassName = std::string( _glassesName) ;
    
    hatName = std::string( _hatName) ;
    mustacheName = std::string( _mustacheName) ;

    
    textureName = _textureName;
    LOOKUP_FSH =
            "mediump vec3 yuv;"
            "lowp vec3 rgb;"
            "varying highp vec2 textureCoordinate;"
            " varying highp vec2 textureCoordinate2;"
            " uniform sampler2D inputImageTexture;"
            " uniform sampler2D inputImageTexture0;"
            " uniform sampler2D inputImageTexture1;"
            " uniform sampler2D inputImageTexture2;"
            " uniform lowp float intensity;"
            "uniform mediump vec4 colorMulti;"
            " void main()"
            " {"
                    "   highp float y = texture2D(inputImageTexture0, textureCoordinate).r;"
                    "   highp vec4 uv = texture2D(inputImageTexture1, textureCoordinate);"
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
            "     highp vec4 textureColor = color * colorMulti;"
            "textureColor = clamp(textureColor, 0.0, 1.0);"

            "     highp float blueColor = textureColor.b * 63.0;"
            "     highp vec2 quad1;"
            "     quad1.y = floor(floor(blueColor) / 8.0);"
            "     quad1.x = floor(blueColor) - (quad1.y * 8.0);"
            "     highp vec2 quad2;"
            "     quad2.y = floor(ceil(blueColor) / 8.0);"
            "     quad2.x = ceil(blueColor) - (quad2.y * 8.0);"
            "     highp vec2 texPos1;"
            "     texPos1.x = (quad1.x * 0.125) + 0.5/512.0 + ((0.125 - 1.0/512.0) * textureColor.r);"
            "     texPos1.y = (quad1.y * 0.125) + 0.5/512.0 + ((0.125 - 1.0/512.0) * textureColor.g);"
           // "     texPos1.y = 1.0-texPos1.y;"
            "     highp vec2 texPos2;"
            "     texPos2.x = (quad2.x * 0.125) + 0.5/512.0 + ((0.125 - 1.0/512.0) * textureColor.r);"
            "     texPos2.y = (quad2.y * 0.125) + 0.5/512.0 + ((0.125 - 1.0/512.0) * textureColor.g);"
            //"     texPos2.y = 1.0-texPos1.y;"
            "     lowp vec4 newColor1 = texture2D(inputImageTexture2, texPos1);"
            "     lowp vec4 newColor2 = texture2D(inputImageTexture2, texPos2);"
            "     lowp vec4 newColor = mix(newColor1, newColor2, fract(blueColor));"
            "     gl_FragColor = mix(textureColor, vec4(newColor.rgb, textureColor.w), intensity);"
            " }";


    TWOINPUT_VSH =
            "attribute vec4 position;"
            "attribute vec4 inputTextureCoordinate;"
            "attribute vec4 inputTextureCoordinate2;"
            "varying vec2 textureCoordinate;"
            "varying vec2 textureCoordinate2;"
            "void main()"
            "{"
            "    gl_Position = position;"
            "    textureCoordinate = inputTextureCoordinate.xy;"
            "    textureCoordinate2 = inputTextureCoordinate2.xy;"
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
#endif                    "  gl_FragColor = color;"
                    "}";

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
    
    textureOff = GL_NONE;
    textureOff2 = GL_NONE;

#if TARGET_OS_IPHONE || TARGET_OS_SIMULATOR
    baseDir = "";
    
#else // Android
#endif
}

void LookupFilter::initFrameBuffer()
{
    
    
   
}
std::string LookupFilter::getName(int type)
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

bool LookupFilter::getItem(std::string  _name, eItemType type, float *_w_ratio, float *_h_ratio, int *_rule, int *_bound)
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

void LookupFilter::setComponent(Component *_comp, eItemType type)
{
    int bound = 1;
    float w_ratio,h_ratio;
    std::string itemName = getName(type);
    int rule;
    // getItem( itemName, type, &w_ratio, &h_ratio,&rule,&bound);
    
    if(type == eHat)
        _comp->setHatRule(rule);
    
    _comp->setSource(itemName,baseDir,bound,w_ratio,h_ratio);
    compList.push_back(_comp);
    
}
void LookupFilter::init(binaryface_session_t session, int numFeaturePoints, char* name, int openEyes)
{
    int width,height;
    if(type == 1)
        texture[0] = AssetManager::loadLocalTexture(textureName, "png",width,height);
    else
        texture[0] = AssetManager::loadNetworkFilterTexture(textureName, "png",width,height);
    

    BaseFaceScene::init(session, numFeaturePoints,name,openEyes);

  
    numTrackingPoints = Models::foreheadPointsSize / 3;
    binaryface_session_register_tracking_3d_points(session, numTrackingPoints, Models::foreheadPoints);
    binaryface_set_session_parameter_int(session, BINARYFACE_CONFIG_MAX_NUM_FACES, 100);
    binaryface_get_session_info(session, &sessionInfo);

    
    
    lookupProgram.init(TWOINPUT_VSH, LOOKUP_FSH, std::vector<std::string>{"inputImageTexture0","inputImageTexture1","inputImageTexture2","intensity","colorMulti"}, std::vector<std::string>{"position", "inputTextureCoordinate", "inputTextureCoordinate2"});
   

    sceneProgram.init(TEXTURE_VSH, TEXTURE_FSH, std::vector<std::string>{"inputImageTexture","mvp"}, std::vector<std::string>{"inputTextureCoordinate","position"});


    ///
    rapidjson::Document d;
    std::string fullPath ;
#if TARGET_OS_IPHONE || TARGET_OS_SIMULATOR
    fullPath =  "live_sticker";
#else
    fullPath =  baseDir + "/live_sticker";
    
#endif
    if(stickerName.compare("none") != 0)
    {
        if(resType == 1)
            AssetManager::loadJson3("live_sticker", "json", d);
        else
            AssetManager::loadJsonSticker(fullPath, "json", d);
        
        
        Component *_comp = nullptr;
        int position = -1;
        
        int size =  d["item"].Size();
        
        for(int i=0;i<size;i++)
        {
            std::string  name = d["item"][i]["name"].GetString();
            if(name.compare(stickerName) == 0)
            {
                position = i;
                break;
            }
        }
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
                /*
                 if(type!= eNone) {
                 
                 ret = getItem( itemName, type, &_w_ratio, &_h_ratio,&_rule,&_bound);
                 }
                 */
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
                    //if(ret == true)
                    //    rule = _rule;
                    
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
                
                _comp->type = resType;
                _comp->setSource(name,baseDir,bound,w_ratio,h_ratio);
                compList.push_back(_comp);
                
            }
            
        } else {
            
            Component *_comp = nullptr;
            
            if( glassName != "none")
            {
                _comp = new GlassesComponent();
                setComponent(_comp,eGlasses);
            }
            if( hatName != "none")
            {
                
                _comp = new HatComponent();
                
                setComponent(_comp,eHat);
            }
            if( earName != "none")
            {
                _comp = new EarringComponent();
                setComponent(_comp,eEarring);
            }
            if( mustacheName != "none")
            {
                _comp = new MustacheComponent();
                setComponent(_comp,eMustache);
            }
            
        }
    }
    
    initFrameBuffer();

}



void LookupFilter::renderLookup()
{


/*

*/
}

std::vector<std::vector<float>> LookupFilter::getFacesFromBuffer()
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

std::vector<std::vector<float> > LookupFilter::getFacesFromBuffer2()
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

std::vector<Matrix4f> LookupFilter::getTransformMatrixFromBuffer()
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


void LookupFilter::renderPre()
{
    if(typeName.compare("none") == 0)
        return;
    
    static  float tVertices[] = {
            0.0f, 0.0f,
            1.0f, 0.0f,
            0.0f, 1.0f,
            1.0f, 1.0f,
    };
    lookupProgram.use();

    int mFilterSecondTextureCoordinateAttribute = lookupProgram.getAttributeLocation( "inputTextureCoordinate2");
    int mFilterInputTextureUniform2 = lookupProgram.getUniformLocation( "inputImageTexture2");
    int mIntensityLocation = lookupProgram.getUniformLocation( "intensity");

    int positionLoc = lookupProgram.getAttributeLocation("position");
    int texCoordLoc = lookupProgram.getAttributeLocation("inputTextureCoordinate");

    // renderClear();
    glActiveTexture(GL_TEXTURE0);
    glBindTexture(GL_TEXTURE_2D, textureY);
    glUniform1i(lookupProgram.getUniformLocation("inputImageTexture0"), 0);

    glActiveTexture(GL_TEXTURE1);
    glBindTexture(GL_TEXTURE_2D, textureUV);
    glUniform1i(lookupProgram.getUniformLocation("inputImageTexture1"), 1);

    glEnableVertexAttribArray(positionLoc);
    glBindBuffer(GL_ARRAY_BUFFER, getArrayBuffer("base_face_pos"));
    glVertexAttribPointer(positionLoc, 2, GL_FLOAT, 0, 0, 0);

    glEnableVertexAttribArray(texCoordLoc);
    glBindBuffer(GL_ARRAY_BUFFER, getArrayBuffer("base_face_tex_uv"));
    glVertexAttribPointer(texCoordLoc, 2, GL_FLOAT, 0, 0, 0);

    glUniform4f(lookupProgram.getUniformLocation("colorMulti"),
                1, 1, 1, 1);


    glActiveTexture(GL_TEXTURE2);
    glBindTexture(GL_TEXTURE_2D, texture[0]);
    glUniform1i(mFilterInputTextureUniform2, 2);
    glUniform1f(mIntensityLocation, 1.0);

    glEnableVertexAttribArray(mFilterSecondTextureCoordinateAttribute);
    glVertexAttribPointer(mFilterSecondTextureCoordinateAttribute, 2, GL_FLOAT, false, 0, tVertices);

    

}


void LookupFilter::render()
{
   //   GLES20.glBindFramebuffer(GLES20.GL_FRAMEBUFFER, mFrameBuffers[i]);
    
    renderBaseInput();
    if(stickerName.compare("none") == 0)
    {
       // GLES20.glBindFramebuffer(GLES20.GL_FRAMEBUFFER, 0);
       // previousTexture = mFrameBufferTextures[i];
       // previousTexture = frameBuffers;
        return;
    
    }
    
    
    glEnable(GL_BLEND);
    glDepthMask(GL_FALSE);
    glBlendFunc(GL_SRC_ALPHA,GL_ONE_MINUS_SRC_ALPHA);
    
    auto faces = getFacesFromBuffer();
    auto matrixs = getTransformMatrixFromBuffer();
    
    for(int i=0;i< compList.size();i++)
    {
        comp = compList[i];
        if(outputMirrored)
            comp->bFront = true;
        else
            comp->bFront = false;
        
        if(comp->name.compare ("none")!=0)
        {
            comp->setDest(faces, matrixs);
            comp->render();
            
        }
    }
    
    
    glDepthMask(GL_TRUE);
    glDisable(GL_BLEND);
    glBindFramebuffer(GL_FRAMEBUFFER,0);
    
   
  //  glBindFramebuffer(GL_FRAMEBUFFER,0);

    previousTexture = frameBuffers;
    
    
 
}

void LookupFilter::release()
{
    BaseFaceScene::release();
    lookupProgram.release();
    
    glDeleteTextures(1, texture);
    texture[0] = 0;
    
}
