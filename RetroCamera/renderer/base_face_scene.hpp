#pragma once
#include "asset_manager.hpp"
#include "shader_program.hpp"
#include "binaryface.h"
#include <Eigen/Geometry>

#define MAX_TEXTURES 4
typedef enum
{
    eNone = -1,
    eGlasses = 0,
    eHat = 1,
    eEarring = 2,
    eMustache = 3,
    
} eItemType;
class BaseFaceScene {
public:
    enum INPUT_ORIENTATION {
        FIRST_ROW_UP = 0,
        FIRST_COLUMN_UP,
        LAST_ROW_UP,
        LAST_COLUMN_UP,
    };
    
    enum OUTPUT_MIRRORED {
        DEFAULT_P_TO_P = 0,
        MIRRORED_P_TO_Q
    };
    
    enum OUTPUT_UP_DIRECTION {
        POSITION_PLUS_Y_UP = 0,
        POSITION_MINUS_Y_UP
    };
    
    BaseFaceScene();
    virtual ~BaseFaceScene();
    
    virtual void init(binaryface_session_t session, int numFeaturePoints, char* name, int openEyes);
    virtual void processVideoFrame();
    virtual void release();
    virtual void render();
    virtual void renderPre(){};
    unsigned char* getYBuffer();
    unsigned char* getUVBuffer();
    int getYTexture();
    int getUVTexture();



    virtual void setSource(unsigned char* yBuffer, unsigned char* uvBuffer, int width, int height, INPUT_ORIENTATION orientation);
    virtual void setDest(int width, int height, OUTPUT_UP_DIRECTION upDirection, OUTPUT_MIRRORED mirrored);
    void initCoordinate();
    bool isInitCoordination() { return !screenToViewport.isZero(); }
    void renderClear();
    void renderBaseInput();
    //  renderBaseInputColorMulti: Colorize the background
    void renderBaseInputColorMulti(float red, float green, float blue, float alpha);
    static GLuint compileShader(const std::string& shaderSrc, GLenum type);
    
protected:
    void initializeYUVTexture();
    void fillArrayBuffer(const std::string& name, GLsizeiptr size, const void* data, GLenum usage);
    GLuint getArrayBuffer(const std::string& name);
    void fillElementBuffer(const std::string& name, GLsizeiptr size, const void* data, GLenum usage);
    GLuint getElementBuffer(const std::string& name);
    std::vector<float> getFace66(const std::vector<float>& face189, int numTrackingPoints);
    
  
    ShaderProgram baseProgram;
    ShaderProgram noProgram;
    GLuint textureY;
    GLuint textureUV;
    Eigen::MatrixXf screenToViewport;
    Eigen::MatrixXf viewportToScreen;
    GLsizei inputWidth, inputHeight;
    GLsizei outputWidth, outputHeight;
    GLfloat imageVertices[8];
    unsigned char* yBuffer;
    unsigned char* uvBuffer;
    INPUT_ORIENTATION orientation;
    OUTPUT_MIRRORED outputMirrored;
    OUTPUT_UP_DIRECTION outputUpDirection;
    binaryface_session_t binaryFaceSession;
    int numFeaturePoints;
    std::map<std::string, GLuint> arrayBuffers;
    std::map<std::string, GLuint> elementBuffers;
    
    static const std::string BASE_VSH;
    static const std::string BASE_FSH;
  
    static const std::string NO_VSH;
    static const std::string NO_FSH;
    
    int previousTexture;
    GLuint frameBuffers;
    GLuint frameTextures;
   
    GLuint frameBuffersY;
    GLuint frameYTextures;
    
    GLuint frameBuffersUV;
    GLuint frameUVTextures;
    
    const GLfloat textureCoordinates[8] = {
        0.0f, 0.0f,
        1.0f, 0.0f,
        0.0f, 1.0f,
        1.0f, 1.0f,
    };
    
    const GLfloat imageVerticesTemplate[8] = {
        -1.0f, -1.0f,
        1.0f, -1.0f,
        -1.0f,  1.0f,
        1.0f,  1.0f,
    };
    
    static const std::vector<int> conv189to66;
};

