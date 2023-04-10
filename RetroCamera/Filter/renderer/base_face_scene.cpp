#include "base_face_scene.hpp"

using namespace Eigen;

const std::vector<int> BaseFaceScene::conv189to66 {
    0, 2, 4, 6, 8, 10, 12, 14, 16, 18, 20, 22, 24, 26, 28, 30, 32,
    33, 35, 37, 39, 41,
    58, 56, 54, 52, 50,
    67, 69, 71, 73,
    81, 82, 83, 84, 85,
    93, 95, 97, 99, 101, 103,
    111, 109, 107, 105, 115, 113,
    117, 119, 121, 123, 125, 127, 129,
    131, 133, 135, 137, 139,
    142, 144, 146, 149, 151, 153
};

const std::string BaseFaceScene::BASE_VSH =
"#version 100\n"
"attribute vec4 position;"
"attribute vec2 inputTextureCoordinate;"
"varying vec2 textureCoordinate;"
"void main()"
"{"
"  gl_Position = position;"
"  textureCoordinate = inputTextureCoordinate;"
"}";

const std::string BaseFaceScene::BASE_FSH =
"#version 100\n"
"varying mediump vec2 textureCoordinate;"
"uniform sampler2D inputImageTexture0;"
"uniform sampler2D inputImageTexture1;"
"uniform mediump vec4 colorMulti;"
"void main() {"
"  lowp float y = texture2D(inputImageTexture0, textureCoordinate).r;"
"  lowp vec4 uv = texture2D(inputImageTexture1, textureCoordinate);"
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
"  gl_FragColor = color * colorMulti;"
"}";

const std::string BaseFaceScene::NO_VSH =
"#version 100\n"
"attribute vec4 position;"
"attribute vec2 inputTextureCoordinate;"
"varying vec2 textureCoordinate;"
"void main()"
"{"
"  gl_Position = position;"
"  textureCoordinate = inputTextureCoordinate;"
"}";

const std::string BaseFaceScene::NO_FSH =
"#version 100\n"
"varying mediump vec2 textureCoordinate;"
"uniform sampler2D inputImageTexture;"
"void main() {"
"  gl_FragColor = texture2D(inputImageTexture, textureCoordinate);"
"}";

BaseFaceScene::BaseFaceScene()
{
    screenToViewport = Matrix4f::Zero();
    viewportToScreen = Matrix4f::Zero();
    textureY = GL_NONE;
    textureUV = GL_NONE;
}

BaseFaceScene::~BaseFaceScene()
{
    release();
}

void BaseFaceScene::init(binaryface_session_t session, int numFeaturePoints, char* name, int openEyes)
{    binaryFaceSession = session;
    this->numFeaturePoints = numFeaturePoints;
    
    baseProgram.init(BASE_VSH, BASE_FSH, std::vector<std::string>{"inputImageTexture0", "inputImageTexture1", "colorMulti"}, std::vector<std::string>{"position", "inputTextureCoordinate"});
   
    
    noProgram.init(BASE_VSH, BASE_FSH, std::vector<std::string>{"inputImageTexture"}, std::vector<std::string>{"position", "inputTextureCoordinate"});
    
    inputWidth = 0;
    inputHeight = 0;
    outputWidth = 0;
    outputHeight = 0;
    
      
}

void BaseFaceScene::initializeYUVTexture()
{
    GLuint textures[2];
    glGenTextures(2, textures);
    textureY = textures[0];
    textureUV = textures[1];
    
    glActiveTexture(GL_TEXTURE0);
    
    glBindTexture(GL_TEXTURE_2D, textureY);
    
    glTexImage2D(
                 GL_TEXTURE_2D,
                 0,
                 GL_LUMINANCE,
                 inputWidth,
                 inputHeight,
                 0,
                 GL_LUMINANCE,
                 GL_UNSIGNED_BYTE,
                 NULL
                 );
    glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_NEAREST);
    glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
    
    glBindTexture(GL_TEXTURE_2D, textureUV);
    
    glTexImage2D(
                 GL_TEXTURE_2D,
                 0,
                 GL_LUMINANCE_ALPHA,
                 inputWidth / 2,
                 inputHeight / 2,
                 0,
                 GL_LUMINANCE_ALPHA,
                 GL_UNSIGNED_BYTE,
                 NULL
                 );
    glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_NEAREST);
    glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
    
    glBindTexture(GL_TEXTURE_2D, GL_NONE);
}

void BaseFaceScene::fillArrayBuffer(const std::string& name, GLsizeiptr size, const void* data, GLenum usage)
{
    GLuint buffer;
    if (arrayBuffers.count(name) == 0) {
        glGenBuffers(1, &buffer);
        arrayBuffers[name] = buffer;
    }
    else {
        buffer = arrayBuffers[name];
        assert(usage != GL_STATIC_DRAW); // gl_static_draw buffer can't be changed
    }
    
    glBindBuffer(GL_ARRAY_BUFFER, buffer);
    glBufferData(GL_ARRAY_BUFFER, size, data, usage);
    glBindBuffer(GL_ARRAY_BUFFER, GL_NONE);
}

GLuint BaseFaceScene::getArrayBuffer(const std::string& name)
{
    assert(arrayBuffers.count(name) > 0);
    return arrayBuffers[name];
}

void BaseFaceScene::fillElementBuffer(const std::string& name, GLsizeiptr size, const void* data, GLenum usage)
{
    GLuint buffer;
    if (elementBuffers.count(name) == 0) {
        glGenBuffers(1, &buffer);
        elementBuffers[name] = buffer;
    }
    else {
        buffer = elementBuffers[name];
        assert(usage != GL_STATIC_DRAW); // gl_static_draw buffer can't be changed
    }
    
    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, buffer);
    glBufferData(GL_ELEMENT_ARRAY_BUFFER, size, data, usage);
    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, GL_NONE);
}

GLuint BaseFaceScene::getElementBuffer(const std::string& name)
{
    assert(elementBuffers.count(name) > 0);
    return elementBuffers[name];
}

void BaseFaceScene::release()
{
    baseProgram.release();
    if (textureY != GL_NONE) {
        GLuint textures[2];
        textures[0] = textureY;
        textures[1] = textureUV;
        
        glDeleteTextures(2, textures);
        textureY = GL_NONE;
        textureUV = GL_NONE;
    }
    if (arrayBuffers.size() > 0) {
        std::vector<GLuint> bufs;
        for (auto const& buf : arrayBuffers)
            bufs.push_back(buf.second);
        glDeleteBuffers(bufs.size(), bufs.data());
        arrayBuffers.clear();
    }
    if (elementBuffers.size() > 0) {
        std::vector<GLuint> bufs;
        for (auto const& buf : elementBuffers)
            bufs.push_back(buf.second);
        glDeleteBuffers(bufs.size(), bufs.data());
        elementBuffers.clear();
    }
}

void BaseFaceScene::setSource(unsigned char* yBuffer, unsigned char* uvBuffer, int width, int height, INPUT_ORIENTATION orientation)
{
    this->inputWidth = width;
    this->inputHeight = height;
    
    this->yBuffer = yBuffer;
    this->uvBuffer = uvBuffer;
    this->orientation = orientation;
    
    if (this->outputWidth > 0 && this->outputHeight > 0)
        initCoordinate();
    if (textureY == GL_NONE && textureUV == GL_NONE)
        initializeYUVTexture();
}

void BaseFaceScene::setDest(int width, int height, OUTPUT_UP_DIRECTION upDirection, OUTPUT_MIRRORED mirrored)
{
    this->outputWidth = width;
    this->outputHeight = height;
    this->outputUpDirection = upDirection;
    this->outputMirrored = mirrored;
    glViewport(0, 0, width, height);
    
    if (this->inputWidth > 0 && this->inputHeight > 0)
        initCoordinate();
}

void BaseFaceScene::initCoordinate()
{
    float mCameraOrientation;
    if (orientation == FIRST_ROW_UP)
        mCameraOrientation = 0.f;
    else if (orientation == FIRST_COLUMN_UP)
        mCameraOrientation = 90.f;
    else if (orientation == LAST_ROW_UP)
        mCameraOrientation = 180.f;
    else if (orientation == LAST_COLUMN_UP)
        mCameraOrientation = 270.f;
    
    float cosf = cos(mCameraOrientation * M_PI / 180.f);
    float sinf = sin(mCameraOrientation * M_PI / 180.f);
    
    Matrix3f texRotation;
    texRotation.row(0) << 1.0f, 0.0f, 0.0f;
    texRotation.row(1) << 0.0f, 1.0f, 0.0f,
    texRotation.row(2) << 0.5f, 0.5f, 1.0f;
    Matrix3f rotation;
    rotation.row(0) <<  cosf, -sinf, 0.0f;
    rotation.row(1) <<  sinf,  cosf, 0.0f;
    rotation.row(2) <<  0.0f,  0.0f, 1.0f;
    texRotation = rotation * texRotation;
    
    Matrix3f transform;
    transform.row(0) <<  1.0f,  0.0f, 0.0f;
    transform.row(1) <<  0.0f,  1.0f, 0.0f;
    transform.row(2) << -0.5f, -0.5f, 1.0f;
    texRotation = transform * texRotation;
    
    if (outputMirrored == MIRRORED_P_TO_Q) {
        Matrix3f front;
        front.row(0) << -1.0f, 0.0f, 0.0f;
        front.row(1) <<  0.0f, 1.0f, 0.0f;
        front.row(2) <<  1.0f, 0.0f, 1.0f;
        texRotation = front * texRotation;
    }
    if (outputUpDirection == POSITION_MINUS_Y_UP) {
        Matrix3f front;
        front.row(0) <<  1.0f,  0.0f, 0.0f;
        front.row(1) <<  0.0f, -1.0f, 0.0f;
        front.row(2) <<  0.0f,  1.0f, 1.0f;
        texRotation = front * texRotation;
    }
    
    int previewWidthOnScreen = inputWidth;
    int previewHeightOnScreen = inputHeight;
    
    if (mCameraOrientation == 90 || mCameraOrientation == 270)
        std::swap(previewWidthOnScreen, previewHeightOnScreen);
    
    float xAspect = 1.0f * previewWidthOnScreen / outputWidth;
    float yAspect = 1.0f * previewHeightOnScreen / outputHeight;
    
    if (xAspect < yAspect) {
        xAspect /= yAspect;
        yAspect = 1.0f;
    }
    else {
        yAspect /= xAspect;
        xAspect = 1.0f;
    }
    
    for (int i = 0; i < 4; i++) {
        Vector3f pos(imageVerticesTemplate[i * 2 + 0], imageVerticesTemplate[i * 2 + 1], 1.f);
        pos = rotation * pos;
        imageVertices[i * 2 + 0] = pos.x() * xAspect * (outputMirrored == MIRRORED_P_TO_Q ? -1.f : 1.f);
        imageVertices[i * 2 + 1] = pos.y() * yAspect * (outputUpDirection == POSITION_PLUS_Y_UP ? -1.f : 1.f);
#if WIN32 || TARGET_OS_OSX
        imageVertices[i * 2 + 0] *= -1.f;
        imageVertices[i * 2 + 1] *= -1.f;
#endif
    }
    fillArrayBuffer("base_face_pos", sizeof(imageVertices), imageVertices, GL_DYNAMIC_DRAW);
    fillArrayBuffer("base_face_tex_uv", sizeof(textureCoordinates), textureCoordinates, GL_DYNAMIC_DRAW);
    
    Matrix3f texRotationInv(texRotation);
    texRotationInv = texRotation.inverse();
    
    Matrix3f screenToViewport2D;
    screenToViewport2D.row(0) << 2.0f * xAspect, 0.0f, 0.0f;
    screenToViewport2D.row(1) << 0.0f, 2.0f * yAspect, 0.0f;
    screenToViewport2D.row(2) << -xAspect, -yAspect, 1.0f;
    
    screenToViewport2D = texRotationInv * screenToViewport2D;
    
    Matrix3f temp;
    temp.row(0) << -1.f / inputWidth, 0.f, 0.f;
    temp.row(1) <<  0.f, 1.f / inputHeight, 0.f;
    temp.row(2) <<  1.f, 0.f, 1.f;
    screenToViewport2D = temp * screenToViewport2D;
    
    screenToViewport.col(0) << screenToViewport2D(0, 0), screenToViewport2D(0, 1), 0, screenToViewport2D(0, 2);
    screenToViewport.col(1) << screenToViewport2D(1, 0), screenToViewport2D(1, 1), 0, screenToViewport2D(1, 2);
    screenToViewport.col(2) << 0, 0, 1, 0;
    screenToViewport.col(3) << screenToViewport2D(2, 0), screenToViewport2D(2, 1), 0,  screenToViewport2D(2, 2);
    
    viewportToScreen = screenToViewport.inverse();
}

void BaseFaceScene::renderClear()
{
    glClearColor(0.0f, 0.0f, 0.0f, 1.f);
    glClearDepthf(1.0f);
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
}

void BaseFaceScene::processVideoFrame()
{
    glActiveTexture(GL_TEXTURE0);
    glBindTexture(GL_TEXTURE_2D, textureY);
    glTexSubImage2D(GL_TEXTURE_2D, 0, 0, 0, inputWidth, inputHeight,
                    GL_LUMINANCE, GL_UNSIGNED_BYTE, yBuffer);
    
    glBindTexture(GL_TEXTURE_2D, textureUV);
    glTexSubImage2D(GL_TEXTURE_2D, 0, 0, 0, inputWidth / 2, inputHeight / 2,
                    GL_LUMINANCE_ALPHA, GL_UNSIGNED_BYTE, uvBuffer);
    
    glBindTexture(GL_TEXTURE_2D, GL_NONE);
}

std::vector<float> BaseFaceScene::getFace66(const std::vector<float>& face189, int numTrackingPoints)
{
    assert(face189.size() == (189 + numTrackingPoints) * 2 ||
           face189.size() == (189 + numTrackingPoints) * 3);
    
    int dim = (int)face189.size() / (189 + numTrackingPoints);
    std::vector<float> face((conv189to66.size() + numTrackingPoints) * dim);
    
    assert(conv189to66.size() == 66);
    int idx_66 = 0;
    for (auto idx_189 : conv189to66) {
        for (int i = 0; i < dim; i++)
            face[idx_66 * dim + i] = face189[idx_189 * dim + i];
        idx_66++;
    }
    for (int j = 0; j < numTrackingPoints; j++) {
        for (int i = 0; i < dim; i++)
            face[idx_66 * dim + i] = face189[(189 + j) * dim + i];
        idx_66++;
    }
    return face;
}

void BaseFaceScene::renderBaseInput()
{
    renderBaseInputColorMulti(1.0f, 1.0f, 1.0f, 1.0f);
}

void BaseFaceScene::renderBaseInputColorMulti(float red, float green, float blue, float alpha)
{
   
    processVideoFrame();
    renderClear();
    
    baseProgram.use();
    
    glActiveTexture(GL_TEXTURE0);
    glBindTexture(GL_TEXTURE_2D, textureY);
    glUniform1i(baseProgram.getUniformLocation("inputImageTexture0"), 0);
    
    glActiveTexture(GL_TEXTURE1);
    glBindTexture(GL_TEXTURE_2D, textureUV);
    glUniform1i(baseProgram.getUniformLocation("inputImageTexture1"), 1);
    
    int positionLoc = baseProgram.getAttributeLocation("position");
    glEnableVertexAttribArray(positionLoc);
    glBindBuffer(GL_ARRAY_BUFFER, getArrayBuffer("base_face_pos"));
    glVertexAttribPointer(positionLoc, 2, GL_FLOAT, 0, 0, 0);
    
    int texCoordLoc = baseProgram.getAttributeLocation("inputTextureCoordinate");
    glEnableVertexAttribArray(texCoordLoc);
    glBindBuffer(GL_ARRAY_BUFFER, getArrayBuffer("base_face_tex_uv"));
    glVertexAttribPointer(texCoordLoc, 2, GL_FLOAT, 0, 0, 0);
    
    glUniform4f(baseProgram.getUniformLocation("colorMulti"),
                red, green, blue, alpha);
    
    renderPre();

    glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
    glBindBuffer(GL_ARRAY_BUFFER, GL_NONE);
    glActiveTexture(GL_TEXTURE0);
    glBindTexture(GL_TEXTURE_2D, GL_NONE);
    glActiveTexture(GL_TEXTURE1);
    glBindTexture(GL_TEXTURE_2D, GL_NONE);
    
}

unsigned char* BaseFaceScene::getYBuffer()
{
    return yBuffer;
}

unsigned char* BaseFaceScene::getUVBuffer()
{
    return uvBuffer;
}

int BaseFaceScene::getYTexture()
{
    return textureY;
}
int BaseFaceScene::getUVTexture()
{
    return textureUV;
}

void BaseFaceScene::render()
{
    renderBaseInput();
}

