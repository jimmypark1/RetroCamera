//
// Created by Junsung Park on 2018. 1. 26..
//

#ifndef BEAUTYCAMERA_SNOWFALL_FILTER_HPP
#define BEAUTYCAMERA_SNOWFALL_FILTER_HPP

#include "base_face_scene.hpp"
#include <vector>
#include <Eigen/Dense>
//#include "face_mod.hpp"
#include "Component.hpp"
using namespace Eigen;

//#define NUM_PARTICLES 360
#define NUM_PARTICLES 50
#define PARTICLE_SIZE 12


typedef struct Particle
{
    float       theta;
    float       size;
    float shade[3];
    float       coord[2];
    float       alpha;
} Particle;

typedef struct Emitter
{
    Particle    particles[NUM_PARTICLES];
    int         k;
    float color[3];
} Emitter;
const float ViewMaxX = 1;
const float ViewMaxY = 1;

const int MaxSnowFlakes = 50;

// Each snow flake will wait 3 seconds - then turn or change direction.
const float TimeTillTurn = 2.0f;
const float TimeTillTurnNormalizedUnit = 1.0f / TimeTillTurn;


class SnowFallFilter : public BaseFaceScene {
public:
    SnowFallFilter();
    SnowFallFilter(const char* textureName ,const char* earringName,const char* glassesName,const char* hatName,const char* mustacheName,bool bigEyes, bool vline,int type);
    virtual void init(binaryface_session_t session, int numFeaturePoints, char * name, int openEyes);
    virtual void render();
    virtual void renderPre();
    virtual void release();
    
private:
    void loadParticle();
    void loadEmitter();
    void update();
   
    void renderFace(std::vector<std::vector<float>> faces,std::vector<Matrix4f> matrixs);
    void renderFace2(std::vector<std::vector<float>> faces,std::vector<Matrix4f> matrixs);
    void ApplyRotationX(float degrees);


    std::vector<Matrix4f> getTransformMatrixFromBuffer();

    void setup(float centerX, float centerY, float centerZ);
    float random();
    float random(float min, float max);
    std::vector<std::vector<float>> getFacesFromBuffer();
    std::vector<std::vector<float>> getFacesFromBuffer2();
    std::vector<float> faceFeaturePointCoords;

private:
    void initTextures();
    void initGlassesTextures();
    void initGlasses2Textures();
    void initRoundGlassesTextures();
    void initHat2Textures();
    void initHat3Textures();
    void initHat4Textures();
    void initHat5Textures();
    void initHat6Textures();
    void initHat7Textures();
    void initHat8Textures();
    void initHat9Textures();
    void initBunnyLoveTextures();
    void initFunnyBirdTextures();
    void initAngryFireTextures();
    void initAngelBlingTextures();
    void initDiamondTiaraTextures();
    void initNewYearTiaraTextures();
    void initGoldCrownTextures();
    void initBlueTiaraTextures();
    void initFlowerCrownTextures();
    void initFlyingAngelTextures();
    void initElseTextures();
    void initBigEyeProc();
    void initVlineProc();
    void initAnimFlowerTextures();
    void initPirateTextures();
    void initNewAngelTextures();
    void initCatEar0Textures();
    void initDogEarTextures();
    void initCatEar1Textures();
    void initD2EarTextures();

    /////
    void renderBunnyLove(std::vector<std::vector<float>> faces,std::vector<Matrix4f> matrixs);
    void renderHat2(std::vector<std::vector<float>> faces,std::vector<Matrix4f> matrixs);
    void renderHat3(std::vector<std::vector<float>> faces,std::vector<Matrix4f> matrixs);
    void renderHat4(std::vector<std::vector<float>> faces,std::vector<Matrix4f> matrixs);
    void renderHat5(std::vector<std::vector<float>> faces,std::vector<Matrix4f> matrixs);
    void renderHat6(std::vector<std::vector<float>> faces,std::vector<Matrix4f> matrixs);
    void renderHat7(std::vector<std::vector<float>> faces,std::vector<Matrix4f> matrixs);
    void renderHat8(std::vector<std::vector<float>> faces,std::vector<Matrix4f> matrixs);
    void renderHat9(std::vector<std::vector<float>> faces,std::vector<Matrix4f> matrixs);

    void renderDefaultGlasses(std::vector<std::vector<float>> faces,std::vector<Matrix4f> matrixs);
    void renderDefaultGlasses2(std::vector<std::vector<float>> faces,std::vector<Matrix4f> matrixs);
    void renderDefaultRoundGlasses(std::vector<std::vector<float>> faces,std::vector<Matrix4f> matrixs);
    void renderFunnyBird(std::vector<std::vector<float>> faces,std::vector<Matrix4f> matrixs);
    void renderAngryFire(std::vector<std::vector<float>> faces,std::vector<Matrix4f> matrixs);
    void renderAngelBling(std::vector<std::vector<float>> faces,std::vector<Matrix4f> matrixs);
    void renderDiamondTiara(std::vector<std::vector<float>> faces,std::vector<Matrix4f> matrixs);
    void renderNewYearTiara(std::vector<std::vector<float>> faces,std::vector<Matrix4f> matrixs);
    void renderDefaultCrown(std::vector<std::vector<float>> faces,std::vector<Matrix4f> matrixs);
    void renderFlyingAngel(std::vector<std::vector<float>> faces,std::vector<Matrix4f> matrixs);
    void renderElse(std::vector<std::vector<float>> faces,std::vector<Matrix4f> matrixs);
    void renderAnimFlower(std::vector<std::vector<float>> faces,std::vector<Matrix4f> matrixs);
    void renderCustomNose(std::vector<std::vector<float>> faces,std::vector<Matrix4f> matrixs);
    void renderCustomEar(std::vector<std::vector<float>> faces,std::vector<Matrix4f> matrixs);
    void renderCustomHat(std::vector<std::vector<float>> faces,std::vector<Matrix4f> matrixs, int imgWidth, int imgHeight, float widthRatio,float heightRatio, int bound);
    void renderCustomHat2(std::vector<std::vector<float>> faces,std::vector<Matrix4f> matrixs, int imgWidth, int imgHeight, float widthRatio,float heightRatio, int bound);
    void renderCustomGlasses(std::vector<std::vector<float>> faces,std::vector<Matrix4f> matrixs, int imgWidth, int imgHeight,float widthRatio,float heightRatio,bool bHeight);
    void renderCustomEtc(std::vector<std::vector<float>> faces,std::vector<Matrix4f> matrixs, int imgWidth, int imgHeight, float widthRatio,float heightRatio, int bound, int rule);
    void renderCustomCrown(std::vector<std::vector<float>> faces,std::vector<Matrix4f> matrixs, int imgWidth, int imgHeight, float widthRatio,float heightRatio);
    void renderCustomNose2(std::vector<std::vector<float>> faces,std::vector<Matrix4f> matrixs, int imgWidth, int imgHeight,float widthRatio,float heightRatio);
    
    void renderCustomNose2(std::vector<std::vector<float>> faces,std::vector<Matrix4f> matrixs, int imgWidth, int imgHeight,float widthRatio,float heightRatio,int bound, int rule);
    void renderCustomAnim(std::vector<std::vector<float>> faces,std::vector<Matrix4f> matrixs, int imgWidth, int imgHeight,float widthRatio,float heightRatio,int bound, int rule);
    void renderCustomEar2(std::vector<std::vector<float>> faces,std::vector<Matrix4f> matrixs, int imgWidth, int imgHeight,float widthRatio,float heightRatio, int bound);
    void renderCustomGlasses2(std::vector<std::vector<float>> faces,std::vector<Matrix4f> matrixs, int imgWidth, int imgHeight,float widthRatio,float heightRatio,bool bHeight);

 
    //
private:
    bool getItem(std::string  _name,eItemType type,float *_w_ratio, float *_h_ratio, int *_rule, int *bound);
    void setComponent(Component *_comp, eItemType type);
    
    std::string getName(int type);
    Component *comp;
    std::vector<Component*> compList;
    std::string baseDir;
    GLubyte *rawImagePixels;
    
    
private:
    rapidjson::Document d0;
    int position;
    bool ret0 ;
    
    GLuint depthRenderBuffer;
    double g_nowTime, g_prevTime;

    unsigned char *arrayOfByte;
    u_int *mToneCurveTexture;
    float *fVertices;
    float nTimeCounter;
    GLuint textures[30];
    GLuint g_program;
    GLuint g_a_colorHandle;
    GLuint g_a_pointSizeHandle;
    GLuint g_a_positionHandle;
    GLuint g_u_mvpMatrixHandle;
    GLuint g_u_texture0Handle;
    GLuint g_u_texture0Handle2;
    GLuint g_vertexBufferId;
    GLuint g_colorBufferId;
    GLuint g_pointSizeBufferId;

    std::string typeName;
    std::string TEXTURE_FSH;
    std::string TEXTURE_VSH;
    std::string BACK_FSH;
    std::string BACK_VSH;
    std::string FACE_FSH;
    std::string FACE_VSH;
    
    std::string earName;
    std::string earName2;
    std::string glassName;
    std::string hatName;
    std::string mustacheName;
    
    ShaderProgram faceModProgram;
    facemod::FaceMod faceMod;
    GLuint textureOff;
    GLuint textureOff2;
    bool bBigEyes;
    bool bVline;
    int  resType;
    
 

protected:
    int numTrackingPoints;
    binaryface_session_info_t sessionInfo;
    const char *texFileName;

    ShaderProgram particleProgram;
    ShaderProgram sceneProgram;
    ShaderProgram backProgram;
    std::string SNOW_FSH;
    std::string SNOW_VSH;

};

#endif //BEAUTYCAMERA_SNOWFALL_FILTER_HPP
