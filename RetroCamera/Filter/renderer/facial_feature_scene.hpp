#pragma once
#include "base_face_scene.hpp"
#include <vector>

class FacialFeatureScene : public BaseFaceScene {
public:
    FacialFeatureScene();
    virtual void init(binaryface_session_t session, int numFeaturePoints, char* name, int openEyes);
    virtual void render();
    virtual void release();
    virtual void setDest(int width, int height, OUTPUT_UP_DIRECTION up, OUTPUT_MIRRORED mirrored);

protected:
    std::vector<std::vector<float>> getFacesFromBuffer();
    std::vector<float> faceFeaturePointCoords;
    float unitWidth;
    float unitHeight;
    ShaderProgram facialFeatureProgram;
    std::vector<GLushort> triangleIndices;
    std::vector<GLfloat> textureCoord;

    std::string FACIAL_FEATURE_FSH;

    const float circleBoxTemplate[4][2] = {{-1.f, -1.f}, {+1.f, -1.f}, {+1.f, +1.f}, {-1.f, +1.f}};
    const short triangleTemplate[6] = {0, 1, 2, 2, 3, 0};
    const float texCoordTemplate[8] = {0.f, 0.f, 1.f, 0.f, 1.f, 1.f, 0.f, 1.f};
};
