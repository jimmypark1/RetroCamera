//
// Created by Junsung Park on 2017. 12. 29..
//

#ifndef BEAUTYCAMERA_LOOKUP_FILTER_H
#define BEAUTYCAMERA_LOOKUP_FILTER_H

#include "base_face_scene.hpp"
#include <vector>
#include "Component.hpp"

class LookupFilter : public BaseFaceScene {
public:
    LookupFilter();
    LookupFilter(std::string textureName,std::string stickerName,const char* earringName,const char* glassesName,const char* hatName,const char* mustacheName, bool openEyes,bool vline, int type);
    virtual void init(binaryface_session_t session, int numFeaturePoints, char* name, int openEyes);

    virtual void render();
    virtual void renderPre();
    virtual void release();
    void renderLookup();
    unsigned char* getYBuffer();
    unsigned char* getUVBuffer();
    void initFrameBuffer();

private:
    bool getItem(std::string  _name,eItemType type,float *_w_ratio, float *_h_ratio, int *_rule, int *bound);
    void setComponent(Component *_comp, eItemType type);
    std::string getName(int type);
    Component *comp;
    std::vector<Component*> compList;
    std::string baseDir;
    std::string TEXTURE_FSH;
    std::string TEXTURE_VSH;
    ShaderProgram sceneProgram;
    int  resType;
    std::string earName;
    std::string earName2;
    std::string glassName;
    std::string hatName;
    std::string mustacheName;
    
private:
    int numTrackingPoints;
    binaryface_session_info_t sessionInfo;
    
    bool bBigEyes;
    bool bVline;
    std::string FACE_VSH;
    std::string FACE_FSH;
    GLuint textureOff;
    GLuint textureOff2;
    std::vector<std::vector<float>> getFacesFromBuffer();
    std::vector<std::vector<float>> getFacesFromBuffer2();
    std::vector<Eigen::Matrix4f> getTransformMatrixFromBuffer();
    std::string textureName;
    std::string typeName;
    std::string stickerName;
    int type;
    rapidjson::Document d0;
    
protected:
    const char *texFileName;

    ShaderProgram lookupProgram;
    ShaderProgram twoInputProgram;
    GLuint textureAlpha;
    std::string LOOKUP_VSH;
    std::string LOOKUP_FSH;

    std::string TWOINPUT_VSH;
    std::string TWOINPUT_FSH;
    GLuint texture[1];
    GLuint input_texture;

    GLuint depthRenderBuffer;

};
#endif //BEAUTYCAMERA_LOOKUP_FILTER_H
