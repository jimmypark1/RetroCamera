#include "face_swap_scene.hpp"
#include "models.hpp"
#include "binaryface.h"

using namespace Eigen;

FaceSwapScene::FaceSwapScene()
{
    FACESWAP_VSH =
"attribute vec4 position;"
"attribute vec4 inputTextureCoordinate;"
"attribute vec2 inputTextureCoordinate2;"
"varying mediump vec2 textureCoordinate;"
"varying mediump vec2 textureCoordinate2;"
"void main()"
"{"
"     gl_Position = position;"
"     textureCoordinate = inputTextureCoordinate.xy;"
"     textureCoordinate2 = inputTextureCoordinate2;"
"}";

    FACESWAP_FSH =
"uniform sampler2D inputImageTexture0;"
"uniform sampler2D inputImageTexture1;"
"uniform sampler2D inputImageTexture2;"
"varying mediump vec2 textureCoordinate;"
"varying mediump vec2 textureCoordinate2;"
"void main()"
"{"
"  lowp float y = texture2D(inputImageTexture0, textureCoordinate).r;"
"  lowp vec4 uv = texture2D(inputImageTexture1, textureCoordinate);"
"  lowp vec4 color = y * vec4(1.0, 1.0, 1.0, 1.0) + "
#ifdef __APPLE__
"                  (uv.r - 0.5) * vec4(0.0, -0.337633, 1.732446, 0.0) + "
"                  (uv.a - 0.5) * vec4(1.370705, -0.698001, 0.0, 0.0); "
#else
"                  (uv.a - 0.5) * vec4(0.0, -0.337633, 1.732446, 0.0) + "
"                  (uv.r - 0.5) * vec4(1.370705, -0.698001, 0.0, 0.0); "
#endif
"  gl_FragColor = vec4(color.rgb, texture2D(inputImageTexture2, textureCoordinate2).r);"
"}";
    textureAlpha = 0;
}

void FaceSwapScene::release()
{
    BaseFaceScene::release();
    faceSwapProgram.release();

    if (textureAlpha != GL_NONE) { // alpha_eye
        GLuint textures[2];
        textures[0] = textureAlpha;

        glDeleteTextures(1, textures);
        textureAlpha = GL_NONE;
    }
}

void FaceSwapScene::init(binaryface_session_t session, int numFeaturePoints, char* name, int openEyes)
{
    BaseFaceScene::init(session, numFeaturePoints, name, openEyes);
    
    numTrackingPoints = Models::foreheadPointsSize / 3;
    binaryface_session_register_tracking_3d_points(session, numTrackingPoints, Models::foreheadPoints);
    binaryface_set_session_parameter_int(session, BINARYFACE_CONFIG_MAX_NUM_FACES, 2);
    binaryface_get_session_info(session, &sessionInfo);

    faceSwapProgram.init(FACESWAP_VSH, FACESWAP_FSH, std::vector<std::string>{"inputImageTexture0", "inputImageTexture1", "inputImageTexture2"}, std::vector<std::string>{"position", "inputTextureCoordinate", "inputTextureCoordinate2"});
    textureAlpha = AssetManager::loadTexture("alpha_eye", "png");
}

std::vector<std::vector<float>> FaceSwapScene::getFacesFromBuffer()
{
    std::vector<std::vector<float>> faces;
    if (binaryFaceSession <= 0) return faces;
    
    int32_t numFaces;
    binaryface_get_num_faces(binaryFaceSession, &numFaces);
    for (int i = 0; i < numFaces; i++) {
        std::vector<float> landmark;
        
        binaryface_face_3d_info_t face3dInfo;
        std::vector<float> featurePoints(numFeaturePoints * 3);
        std::vector<float> trackingPoints(numTrackingPoints * 3);
        binaryface_get_face_3d_info(binaryFaceSession, i, &face3dInfo, &featurePoints[0], &trackingPoints[0]);

        Matrix4f rigidMotionMatrix, cameraMatrixOpenGL;
        for (int row = 0; row < 4; row++)
            for (int col = 0; col < 4; col++) {
                rigidMotionMatrix(row, col) = face3dInfo.rigid_motion_matrix[row][col];
                cameraMatrixOpenGL(row, col) = sessionInfo.camera_matrix[row][col];
            }
        float Z_NEAR = -50.f;
        float Z_FAR = -2000.f;
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

void FaceSwapScene::render()
{
    renderBaseInput();
    auto faces = getFacesFromBuffer();
    if (faces.size() <= 1) return;

    faceSwapProgram.use();

    glEnable(GLenum(GL_BLEND));
    glBlendFunc(GLenum(GL_SRC_ALPHA), GLenum(GL_ONE_MINUS_SRC_ALPHA));

    glDisable(GLenum(GL_DEPTH_TEST));
    glColorMask(GLboolean(GL_TRUE), GLboolean(GL_TRUE), GLboolean(GL_TRUE), GLboolean(GL_FALSE));

    std::vector<GLfloat> vertices0(faces[0].size());
    std::vector<GLfloat> vertices1(faces[0].size());

    GLint facePosition = faceSwapProgram.getAttributeLocation("position");
    glEnableVertexAttribArray(facePosition);
    glVertexAttribPointer(facePosition, 2, GLenum(GL_FLOAT), 0, 0, &vertices1[0]);

    GLint textureCoord = faceSwapProgram.getAttributeLocation("inputTextureCoordinate");
    glEnableVertexAttribArray(textureCoord);
    glVertexAttribPointer(textureCoord, 2, GLenum(GL_FLOAT), 0, 0, &vertices0[0]);

    GLint textureCoord2 = faceSwapProgram.getAttributeLocation("inputTextureCoordinate2");
    glEnableVertexAttribArray(textureCoord2);
    glVertexAttribPointer(textureCoord2, 2, GLenum(GL_FLOAT), 0, 0, Models::facialMaskVertices);

    glActiveTexture(GL_TEXTURE0);
    glBindTexture(GL_TEXTURE_2D, textureY);
    glUniform1i(faceSwapProgram.getUniformLocation("inputImageTexture0"), 0);
    glActiveTexture(GL_TEXTURE1);
    glBindTexture(GL_TEXTURE_2D, textureUV);
    glUniform1i(faceSwapProgram.getUniformLocation("inputImageTexture1"), 1);
    glActiveTexture(GL_TEXTURE2);
    glBindTexture(GL_TEXTURE_2D, textureAlpha);
    glUniform1i(faceSwapProgram.getUniformLocation("inputImageTexture2"), 2);

    for (int faceId = 0; faceId < 2; faceId++) {
        int originFaceIndex = faceId, targetFaceIndex = 1 - faceId;
        for (int i = 0; i < faces[0].size(); i += 2) {
            Vector4f tex(faces[originFaceIndex][i], faces[originFaceIndex][i+1], faces[originFaceIndex][i+2], 1.f);
            tex(0) /= inputWidth;
            tex(1) /= inputHeight;

            Vector4f pos(faces[targetFaceIndex][i], faces[targetFaceIndex][i+1], faces[originFaceIndex][i+2], 1.f);
            pos = screenToViewport * pos;

            vertices0[i] = tex.x();
            vertices0[i+1] = tex.y();

            vertices1[i] = GLfloat(pos.x());
            vertices1[i+1] = GLfloat(pos.y());
        }
        //draw
        glDrawElements(GLenum(GL_TRIANGLES), Models::facialMaskNumTriangles * 3, GLenum(GL_UNSIGNED_SHORT), Models::facialMaskTriangleIndices);
    }

    glActiveTexture(GL_TEXTURE0);
    glBindTexture(GL_TEXTURE_2D, GL_NONE);
    glActiveTexture(GL_TEXTURE1);
    glBindTexture(GL_TEXTURE_2D, GL_NONE);
    glActiveTexture(GL_TEXTURE2);
    glBindTexture(GL_TEXTURE_2D, GL_NONE);
    glColorMask(true, true, true, true);
    glDisable(GL_BLEND);
}
