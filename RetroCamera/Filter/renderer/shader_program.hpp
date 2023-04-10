/**************************************************************************************************
BINARYVR, INC. PROPRIETARY INFORMATION
This software is supplied under the terms of a license agreement or nondisclosure
agreement with BinaryVR, Inc. and may not be copied or disclosed except in
accordance with the terms of that agreement
Copyright(c) 2016 BinaryVR, Inc. All Rights Reserved.
**************************************************************************************************/

#pragma once

#include <string>
#include <vector>
#include <map>
#include <cstdlib>

#include "platforms.h"

class ShaderProgram {
public:
  int mProgramHandle;

  ~ShaderProgram();

  void init(const std::string& vsh_code, const std::string& fsh_code, const std::vector<std::string>& uniforms, const std::vector<std::string>& attributes);
  void release();
  static GLuint createShader(GLenum shaderType, const std::string& code);

  int getUniformLocation(const std::string& name) { return mUniformLocations[name]; }
  int getAttributeLocation(const std::string& name) { return mAttributeLocations[name]; }

  void use() { glUseProgram(mProgramHandle); }

  std::map<std::string, int> mUniformLocations;
  std::map<std::string, int> mAttributeLocations;
};
