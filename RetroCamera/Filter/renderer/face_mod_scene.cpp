#include "face_mod_scene.hpp"
#include "models.hpp"
#include "binaryface.h"

using namespace Eigen;
using namespace facemod;

static const char *FACE_MOD_VSH =
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

static const char *FACE_MOD_FSH =
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
"  lowp vec4 color = y * vec4(1.0, 1.0, 1.0, 1.0) + "
#if TARGET_OS_IPHONE || TARGET_OS_SIMULATOR
"                    (uv.r - 0.5) * vec4(0.0, -0.337633, 1.732446, 0.0) + "
"                    (uv.a - 0.5) * vec4(1.370705, -0.698001, 0.0, 0.0); "
#elif WIN32 || TARGET_OS_OSX
"                    (uv.g - 0.5) * vec4(0.0, -0.337633, 1.732446, 0.0) + "
"                    (uv.r - 0.5) * vec4(1.370705, -0.698001, 0.0, 0.0); "
#else // Android
"                    (uv.a - 0.5) * vec4(0.0, -0.337633, 1.732446, 0.0) + "
"                    (uv.r - 0.5) * vec4(1.370705, -0.698001, 0.0, 0.0); "
#endif
"  gl_FragColor = color;"
"}";

FaceModScene::FaceModScene(const char *jsonFileName)
: jsonFileName(jsonFileName)
{
    textureOff = GL_NONE;
}

void FaceModScene::release()
{
    BaseFaceScene::release();
    if (textureOff != GL_NONE) {
        GLuint textures[1];
        textures[0] = textureOff; // black.png
        
        glDeleteTextures(1, textures);
        textureOff = GL_NONE;
    }
    faceModProgram.release();
}

void FaceModScene::init(binaryface_session_t session, int numFeaturePoints, char* name, int openEyes)
{
    BaseFaceScene::init(session, numFeaturePoints,name,openEyes);
    
    numTrackingPoints = Models::foreheadPointsSize / 3;
    binaryface_session_register_tracking_3d_points(session, numTrackingPoints, Models::foreheadPoints);
    binaryface_set_session_parameter_int(session, BINARYFACE_CONFIG_MAX_NUM_FACES, 1);
    binaryface_get_session_info(session, &sessionInfo);
    
    faceModProgram.init(FACE_MOD_VSH, FACE_MOD_FSH,
                        std::vector<std::string>{"tex_y", "tex_uv", "off_tex"},
                        std::vector<std::string>{"position", "texcoord", "offcoord", "axes"});
    
    std::string s;
    AssetManager::loadRaw(jsonFileName, "json", s);
    
    faceMod.decode(s.c_str());
    
    //  Load the texture
    
    GLuint textures[1];
    glGenTextures(1, textures);
    
    textureOff = textures[0];
    
    glBindTexture(GL_TEXTURE_2D, textureOff);
    
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_NEAREST);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
    
    glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, FACE_MOD_TEXTURE_SIZE, FACE_MOD_TEXTURE_SIZE, 0, GL_RGBA, GL_UNSIGNED_BYTE, faceMod.getRGBABitmap());
}

std::vector<std::vector<float> > FaceModScene::getFacesFromBuffer()
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

void FaceModScene::render()
{
    renderBaseInput();
    
    std::vector<std::vector<float> > feature_points = getFacesFromBuffer();
    if (feature_points.size() <= 0) return;
    
    for (int i = 0; i < feature_points.size(); i++)
    feature_points[i] = getFace66(feature_points[i], numTrackingPoints);
    
    faceModProgram.use();
    
    float determinantScreenToViewPort = screenToViewport(0, 0) * screenToViewport(1, 1) - screenToViewport(1, 0) * screenToViewport(0, 1);
    bool isCW = determinantScreenToViewPort > 0;
    
    glDisable(GLenum(GL_DEPTH_TEST));
    glDisable(GLenum(GL_CULL_FACE));
    glFrontFace(GLenum(isCW ? GL_CW : GL_CCW));
    
    glEnable(GLenum(GL_SCISSOR_TEST));
    glScissor((int)((std::min(imageVertices[0], imageVertices[6]) + 1.0f) * outputWidth * 0.5f),
              (int)((std::min(imageVertices[1], imageVertices[7]) + 1.0f) * outputHeight * 0.5f),
              (int)(outputWidth * 0.5f * std::abs(imageVertices[0] - imageVertices[6])),
              (int)(outputHeight * 0.5f * std::abs(imageVertices[1] - imageVertices[7])));
    
    MatrixXf landmarks(2, 75);
    MatrixXf axes;
    MatrixXf pos;
    MatrixXf offset;
    
    int N = FACE_MOD_NUM_POLY_VERTICES;
    int T = FACE_MOD_NUM_POLY_TRIANGLES;
    
    Matrix<unsigned short, Dynamic, Dynamic, ColMajor> sh_face_indices(3, T);
    
    for (int i = 0; i < T; i++) {
        for (int j = 0; j < 3; j++) {
            sh_face_indices(j, i)  = FACE_MOD_TRIANGLES[i][j];
        }
    }
    
    Matrix3f imgToScreen;
    Matrix3f imgToTexture;
    Matrix3f screenToTexture;
    
    imgToScreen <<
    screenToViewport(0, 0), screenToViewport(0, 1), screenToViewport(0, 3),
    screenToViewport(1, 0), screenToViewport(1, 1), screenToViewport(1, 3),
    screenToViewport(3, 0), screenToViewport(3, 1), screenToViewport(3, 3);
    
    imgToTexture <<
    1.0f / inputWidth, 0.0f, 0.0f,
    0.0f, 1.0f / inputHeight, 0.0f,
    0.0f, 0.0f, 1.0f;
    
    screenToTexture = imgToTexture * imgToScreen.inverse();
    
    MatrixXf sh_positions(2, N);
    MatrixXf sh_texcoords(2, N);
    MatrixXf sh_offcoords(2, N);
    MatrixXf sh_axes(4, N);
    
    glActiveTexture(GL_TEXTURE0);
    glBindTexture(GL_TEXTURE_2D, textureY);
    glUniform1i(faceModProgram.getUniformLocation("tex_y"), 0);
    
    glActiveTexture(GL_TEXTURE1);
    glBindTexture(GL_TEXTURE_2D, textureUV);
    glUniform1i(faceModProgram.getUniformLocation("tex_uv"), 1);
    
    glActiveTexture(GL_TEXTURE2);
    glBindTexture(GL_TEXTURE_2D, textureOff);
    glUniform1i(faceModProgram.getUniformLocation("off_tex"), 2);
    
    GLint positionLoc = faceModProgram.getAttributeLocation("position");
    glEnableVertexAttribArray(positionLoc);
    
    GLint texcoordLoc = faceModProgram.getAttributeLocation("texcoord");
    glEnableVertexAttribArray(texcoordLoc);
    
    GLint offcoordLoc = faceModProgram.getAttributeLocation("offcoord");
    glEnableVertexAttribArray(offcoordLoc);
    
    GLint axesLoc = faceModProgram.getAttributeLocation("axes");
    glEnableVertexAttribArray(axesLoc);
    
    for (int i = 0; i < (int)feature_points.size(); i++) {
        for (int j = 0; j < feature_points[i].size(); j += 2) {
            landmarks(0, j/2) = feature_points[i][j];
            landmarks(1, j/2) = feature_points[i][j+1];
        }
        
        faceMod.translate(landmarks, axes, pos, offset);
        
        for (int j = 0; j < N; j++) {
            Vector3f o;
            o << pos.col(j), 1.0f;
            
            Vector3f v;
            v << pos.col(j) + offset.col(j), 1.0f;
            
            sh_positions.col(j) = (imgToScreen * v).segment(0, 2);
            sh_texcoords.col(j) = (imgToTexture * o).segment(0, 2);
            sh_offcoords.col(j) <<
            FACE_MOD_POLY_VERTICES[j][0], FACE_MOD_POLY_VERTICES[j][1];
            
            Vector3f axis_x, axis_y;
            
            axis_x << axes.col(j).segment(0, 2), 0.0f;
            axis_y << axes.col(j).segment(2, 2), 0.0f;
            
            sh_axes.col(j).segment(0, 2) = (imgToTexture * axis_x).segment(0, 2);
            sh_axes.col(j).segment(2, 2) = (imgToTexture * axis_y).segment(0, 2);
        }
        fillArrayBuffer("face_mod_pos", 2 * N * sizeof(float), sh_positions.data(), GL_DYNAMIC_DRAW);
        glBindBuffer(GL_ARRAY_BUFFER, getArrayBuffer("face_mod_pos"));
        glVertexAttribPointer(positionLoc, 2, GLenum(GL_FLOAT), 0, 0, 0);
        
        fillArrayBuffer("face_mod_tex", 2 * N * sizeof(float), sh_texcoords.data(), GL_DYNAMIC_DRAW);
        glBindBuffer(GL_ARRAY_BUFFER, getArrayBuffer("face_mod_tex"));
        glVertexAttribPointer(texcoordLoc, 2, GLenum(GL_FLOAT), 0, 0, 0);
        
        fillArrayBuffer("face_mod_off", 2 * N * sizeof(float), sh_offcoords.data(), GL_DYNAMIC_DRAW);
        glBindBuffer(GL_ARRAY_BUFFER, getArrayBuffer("face_mod_off"));
        glVertexAttribPointer(offcoordLoc, 2, GLenum(GL_FLOAT), 0, 0, 0);
        
        fillArrayBuffer("face_mod_axes", 4 * N * sizeof(float), sh_axes.data(), GL_DYNAMIC_DRAW);
        glBindBuffer(GL_ARRAY_BUFFER, getArrayBuffer("face_mod_axes"));
        glVertexAttribPointer(axesLoc, 4, GLenum(GL_FLOAT), 0, 0, 0);
        
        fillElementBuffer("face_mod_indices", sh_face_indices.size() * sizeof(GLushort),
                          sh_face_indices.data(), GL_DYNAMIC_DRAW);
        glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, getElementBuffer("face_mod_indices"));
        glDrawElements(GL_TRIANGLES, T * 3, GL_UNSIGNED_SHORT, 0);
    }
    
    //unbind
    
    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, GL_NONE);
    glBindBuffer(GL_ARRAY_BUFFER, GL_NONE);
    
    glActiveTexture(GLenum(GL_TEXTURE0));
    glBindTexture(GLenum(GL_TEXTURE_2D), GL_NONE);
    
    glActiveTexture(GLenum(GL_TEXTURE1));
    glBindTexture(GLenum(GL_TEXTURE_2D), GL_NONE);
    
    glActiveTexture(GLenum(GL_TEXTURE2));
    glBindTexture(GLenum(GL_TEXTURE_2D), GL_NONE);
    
    glDisable(GLenum(GL_SCISSOR_TEST));
}

