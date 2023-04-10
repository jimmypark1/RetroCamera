/**************************************************************************************************
BINARYVR, INC. PROPRIETARY INFORMATION
This software is supplied under the terms of a license agreement or nondisclosure
agreement with BinaryVR, Inc. and may not be copied or disclosed except in
accordance with the terms of that agreement
Copyright(c) 2016 BinaryVR, Inc. All Rights Reserved.
**************************************************************************************************/

#include "shader_program.hpp"

void ShaderProgram::init(
    const std::string& vsh_code,
    const std::string& fsh_code,
    const std::vector<std::string>& uniforms,
    const std::vector<std::string>& attributes)
{
  GLuint vsh = createShader(GL_VERTEX_SHADER, vsh_code);
  GLuint fsh = createShader(GL_FRAGMENT_SHADER, fsh_code);

  mProgramHandle = glCreateProgram();

  glAttachShader(mProgramHandle, vsh);
  glAttachShader(mProgramHandle, fsh);

  glLinkProgram(mProgramHandle);
  int status[1];

  glGetProgramiv(mProgramHandle, GL_LINK_STATUS, status);
  if (status[0] != GL_TRUE) {
    GLint infoLen = 0;
    glGetShaderiv(mProgramHandle, GL_INFO_LOG_LENGTH, &infoLen);

    GLchar *infoLog = (GLchar *) malloc(sizeof(GLchar) * infoLen);
    glGetShaderInfoLog(mProgramHandle, infoLen, NULL, infoLog);
    std::string message = "Link Error:";
    message += (char*)infoLog;
    printf("%s\n", message.c_str());
    return;
  }
  glDetachShader(mProgramHandle, vsh);
  glDetachShader(mProgramHandle, fsh);

  glDeleteShader(vsh);
  glDeleteShader(fsh);

  mUniformLocations.clear();
  mAttributeLocations.clear();

  for (const auto& uniform : uniforms)
    mUniformLocations[uniform] = glGetUniformLocation(mProgramHandle, uniform.c_str());
  for (const auto& attrib : attributes)
    mAttributeLocations[attrib] = glGetAttribLocation(mProgramHandle, attrib.c_str());
}

ShaderProgram::~ShaderProgram()
{
  release();
}

void ShaderProgram::release()
{
  if (mProgramHandle != GL_NONE) {
    glDeleteProgram(mProgramHandle);
    mProgramHandle = GL_NONE;
  }
}

GLuint ShaderProgram::createShader(GLenum shaderType, const std::string& code)
{
  GLuint shader = glCreateShader(shaderType);
  const GLchar *source = code.c_str();
  glShaderSource(shader, 1, &source, NULL);

  glCompileShader(shader);
  int status[1];
  glGetShaderiv(shader, GL_COMPILE_STATUS, status);
  if (status[0] != GL_TRUE)
    return GL_NONE;
  return shader;
}
