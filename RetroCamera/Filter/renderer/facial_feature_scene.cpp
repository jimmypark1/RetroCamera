#include "facial_feature_scene.hpp"
#include "binaryface.h"

using namespace Eigen;

FacialFeatureScene::FacialFeatureScene()
{
    FACIAL_FEATURE_FSH =
"varying mediump vec2 textureCoordinate;"
"void main()"
"{"
"    if (length(textureCoordinate - vec2(0.5, 0.5)) <= 0.5)"
"        gl_FragColor = vec4(0.0, 1.0, 0.0, 1.0);"
"    else discard;"
"}";
}

void FacialFeatureScene::release()
{
    BaseFaceScene::release();
    baseProgram.release();
}

void FacialFeatureScene::init(binaryface_session_t session, int numFeaturePoints, char* name, int openEyes)
{
    BaseFaceScene::init(session, numFeaturePoints, name, openEyes);
    faceFeaturePointCoords = std::vector<float>(2 * numFeaturePoints);
    
    binaryface_session_register_tracking_3d_points(session, 0, NULL);
    binaryface_set_session_parameter_int(session, BINARYFACE_CONFIG_MAX_NUM_FACES, 1);

    facialFeatureProgram.init(BASE_VSH, FACIAL_FEATURE_FSH, std::vector<std::string>{}, std::vector<std::string>{"position", "inputTextureCoordinate"});

    for (int i = 0; i < numFeaturePoints; i++)
        for (int j = 0; j < 6; j++)
            triangleIndices.push_back(i * 4 + triangleTemplate[j]);
    for (int i = 0; i < numFeaturePoints; i++)
        for (int j = 0; j < 8; j++)
            textureCoord.push_back(texCoordTemplate[j]);
}

void FacialFeatureScene::setDest(int width, int height, OUTPUT_UP_DIRECTION up, OUTPUT_MIRRORED mirrored)
{
    BaseFaceScene::setDest(width, height, up, mirrored);
    unitWidth  = 4.f / outputWidth;
    unitHeight = 4.f / outputHeight;
}

std::vector<std::vector<float>> FacialFeatureScene::getFacesFromBuffer()
{
    std::vector<std::vector<float>> faces;
    if (binaryFaceSession <= 0) return faces;
    
    int32_t numFaces;
    binaryface_get_num_faces(binaryFaceSession, &numFaces);
    for (int i = 0; i < numFaces; i++) {
        binaryface_face_info_t faceInfo;
        binaryface_get_face_info(binaryFaceSession, i, &faceInfo, &faceFeaturePointCoords[0]);
        std::vector<float> landmark;
        for (int j = 0; j < faceFeaturePointCoords.size(); j+= 2) {
            Vector4f uvPoint(faceFeaturePointCoords[j], faceFeaturePointCoords[j+1], 0.f, 1.f);
            uvPoint = screenToViewport * uvPoint;
            landmark.push_back(uvPoint.x());
            landmark.push_back(uvPoint.y());
        }
        faces.push_back(landmark);
    }
    return faces;
}

void FacialFeatureScene::render()
{
    renderBaseInput();
    auto faces = getFacesFromBuffer();
    if (faces.empty()) return;

    facialFeatureProgram.use();

    std::vector<GLfloat> vertices(numFeaturePoints * 2 * 4);

    int positionLoc = facialFeatureProgram.getAttributeLocation("position");
    glEnableVertexAttribArray(positionLoc);
    glVertexAttribPointer(positionLoc, 2, GLenum(GL_FLOAT), 0, 0, &vertices[0]);

    int texCoordLoc = facialFeatureProgram.getAttributeLocation("inputTextureCoordinate");
    glEnableVertexAttribArray(texCoordLoc);
    glVertexAttribPointer(texCoordLoc, 2, GLenum(GL_FLOAT), 0, 0, &textureCoord[0]);

    for (auto face : faces) {
        int verticesIndex = 0;
        for (int i = 0; i < face.size(); i += 2) {
            for (int j = 0; j < 4; j++) {
                vertices[verticesIndex++] = face[i] + circleBoxTemplate[j][0] * unitWidth;
                vertices[verticesIndex++] = face[i + 1] + circleBoxTemplate[j][1] * unitHeight;
            }
        }
        glDrawElements(GLenum(GL_TRIANGLES),
                       numFeaturePoints * 6,
                       GLenum(GL_UNSIGNED_SHORT),
                       &triangleIndices[0]);
    }
        /*
    glUseProgram(faceShader);
    glEnableVertexAttribArray(filterPositionAttribute);
    glVertexAttribPointer(filterPositionAttribute, 2, GLenum(GL_FLOAT), 0, 0, &vertices[0]);
    glEnableVertexAttribArray(filterTextureCoordinateAttribute);
    glVertexAttribPointer(filterTextureCoordinateAttribute, 2, GLenum(GL_FLOAT), 0, 0, &textureCoord[0]);
    
    for (auto face : faces) {
        int verticesIndex = 0;
        for (int i = 0; i < face.size(); i += 2) {
            for (int j = 0; j < 4; j++) {
                vertices[verticesIndex++] = face[i] + circleBoxTemplate[j][0] * unitWidth;
                vertices[verticesIndex++] = face[i+1] + circleBoxTemplate[j][1] * unitHeight;
            }
        }
        glDrawElements(GLenum(GL_TRIANGLES),
                       numFeaturePoints * 6,
                       GLenum(GL_UNSIGNED_SHORT),
                       &triangleIndices[0]);
    }
    */
}
