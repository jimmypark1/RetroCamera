#pragma once
#include "base_face_scene.hpp"
#include <vector>

class FaceSwapScene : public BaseFaceScene {
public:
    FaceSwapScene();
    virtual void init(binaryface_session_t session, int numFeaturePoints, char *name, int openEyes);
    virtual void render();
    virtual void release();

protected:
    std::vector<std::vector<float>> getFacesFromBuffer();

    ShaderProgram faceSwapProgram;
    GLuint textureAlpha;
    std::string FACESWAP_VSH;
    std::string FACESWAP_FSH;
    int numTrackingPoints;
    binaryface_session_info_t sessionInfo;
};
