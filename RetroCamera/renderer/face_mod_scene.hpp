#pragma once

#include "base_face_scene.hpp"
#include <vector>
#include "face_mod.hpp"

class FaceModScene : public BaseFaceScene {
    public:
    FaceModScene(const char *jsonFileName);
    
    virtual void init(binaryface_session_t session, int numFeaturePoints, char* name, int openEyes);
    virtual void render();
    virtual void release();
    
    protected:
    facemod::FaceMod faceMod;
    ShaderProgram faceModProgram;
    GLuint textureOff;
    binaryface_session_info_t sessionInfo;
    int numTrackingPoints;
    
    std::string jsonFileName;
    
    std::vector<std::vector<float> > getFacesFromBuffer();
};

