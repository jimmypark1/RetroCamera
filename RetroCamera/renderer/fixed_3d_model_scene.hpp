#pragma once

#include "base_face_scene.hpp"
#include <vector>
#include <Eigen/Dense>
#include "face_mod.hpp"

using namespace Eigen;

class Fixed3dModelScene : public BaseFaceScene {
public:
    Fixed3dModelScene(
      const char *texFileName,
      const char *earName,
      const char *glassName,const char* _hatName,const char* _mustacheName,
      const float *vertices,
      const float *texCoords,
      const short *faceIndices,
      const int faceIndicesSize,bool openEyes,bool vline);
      
    virtual void init(binaryface_session_t session, int numFeaturePoints, char* name, int openEyes);
    virtual void render();
    virtual void renderFaceDepths(const std::vector<std::vector<float>>& face, const std::vector<Eigen::Matrix4f>& matrixs);
    virtual void renderFixedModels(const std::vector<Eigen::Matrix4f>& matrixs);
    virtual void release();
    virtual void setDest(int width, int height, OUTPUT_UP_DIRECTION up, OUTPUT_MIRRORED mirrored);

    void renderFace(std::vector<std::vector<float>> faces,std::vector<Matrix4f> matrixs);
    void renderFace2(std::vector<std::vector<float>> faces,std::vector<Matrix4f> matrixs);
    std::vector<std::vector<float>> getFacesFromBuffer2();
    void renderEarring(std::vector<std::vector<float>> faces,std::vector<Matrix4f> matrixs);
    void renderEarring2(std::vector<std::vector<float>> faces,std::vector<Matrix4f> matrixs);
    void renderScene(std::vector<std::vector<float>> faces,std::vector<Matrix4f> matrixs);
    void renderMustache(std::vector<std::vector<float>> faces,std::vector<Matrix4f> matrixs);
    void renderCrown3(std::vector<std::vector<float>> faces,std::vector<Matrix4f> matrixs);

private:
    void initTextures();
    std::string FACE_FSH;
    std::string FACE_VSH;
    ShaderProgram faceModProgram;
    facemod::FaceMod faceMod;
    bool bBigEyes;
    bool bVline;
    GLuint textureOff;
    GLuint textureOff2;
    GLuint mustache_textures[30];
    GLuint ear_textures[30];
    GLuint hat_textures[30];
    GLuint glass_textures[30];
    std::string earName;
    int renderGCnt;
    int hatCnt;
    std::string typeName;
    
    std::string glassName;
    std::string hatName;
    std::string mustacheName;
    
protected:
    const char *texFileName;
    const float *vertices;
    const float *texCoords;
    const short *faceIndices;
    const int faceIndicesSize;
    
    std::vector<std::vector<float>> getFacesFromBuffer();
    std::vector<Eigen::Matrix4f> getTransformMatrixFromBuffer();

    ShaderProgram faceDepthProgram;
    ShaderProgram sceneProgram;
    std::string FACEDEPTH_VSH;
    std::string FACEDEPTH_FSH;
    ShaderProgram fixedModelProgram;
    std::string TEXTURE_VSH;
    std::string TEXTURE_FSH;
 
    std::string TEXTURE_VSH2;
    std::string TEXTURE_FSH2;
    
    int numTrackingPoints;
    binaryface_session_info_t sessionInfo;
    GLuint depthRenderBuffer;
    GLuint texture;
};
