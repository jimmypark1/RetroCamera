#pragma once
#include "base_face_scene.hpp"
#include "face_mask.hpp"
#include <vector>
#include <algorithm>
#include "face_mod.hpp"
#include "Component.hpp"

using namespace Eigen;

class FaceMaskScene : public BaseFaceScene {
public:
    //FaceMaskScene();
    FaceMaskScene(const char *maskName);
    FaceMaskScene(const char *_texFileName,const char* earringName ,const char* _glassesName,const char* _hatName,const char* _mustacheName, int type, bool bOpenEyes, bool bVline, bool bBigEyes);
    FaceMaskScene(){};

    virtual void init(binaryface_session_t session, int numFeaturePoints, char* name, int openEyes);
    virtual void render();
    virtual void release();
    const char *jsonFileName2;
    const char *texFileName2;
    std::string texN;
    int type;
    void renderBeauty();
private:
    bool bBigEyes;
    bool bVline;
    bool bOpenEyes;
    bool ret0;
    int position;
    rapidjson::Document d0;
    
    bool getItem(std::string  _name,eItemType type,float *_w_ratio, float *_h_ratio, int *_rule, int *bound);
    void setComponent(Component *_comp, eItemType type);
    
    std::string getName(int type);
    Component *comp;
    std::vector<Component*> compList;
    std::string baseDir;
    std::string earName;
    std::string glassName;
    std::string hatName;
    std::string mustacheName;
    std::vector<std::vector<float>> getFacesFromBuffer3();
    
protected:
    ShaderProgram faceMaskProgram;
    ShaderProgram faceMaskBeautyProgram;
    ShaderProgram faceModProgram;
    static const std::string FACEMASK_VSH;
    static const std::string FACEMASK_FSH;

    static const std::string FACEMASK_BEAUTY_VSH;
    static const std::string FACEMASK_BEAUTY_FSH;

    binaryface_session_info_t sessionInfo;
    int numTrackingPoints;
    FaceMask maskImg;
    GLuint textureOff;
    std::string FACE_FSH;
    std::string FACE_VSH;
    
    facemod::FaceMod faceMod;
    std::string jsonFileName;
    std::string maskName;
    GLuint textureOff2;
    
    std::vector<std::vector<float>> getFacesFromBuffer();
    Vector3f calculateMeanColor(const std::vector<float>& face);
    Vector3f sampleColor(const Vector2f& v);
    void initBigEyeProc();
    void initVlineProc();
    void renderFace(std::vector<std::vector<float>> faces,std::vector<Matrix4f> matrixs);
    void renderFace2(std::vector<std::vector<float>> faces,std::vector<Matrix4f> matrixs);
    std::vector<std::vector<float>> getFacesFromBuffer2();
    std::vector<Matrix4f> getTransformMatrixFromBuffer();

};
