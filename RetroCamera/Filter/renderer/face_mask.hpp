/**************************************************************************************************
BINARYVR, INC. PROPRIETARY INFORMATION
This software is supplied under the terms of a license agreement or nondisclosure
agreement with BinaryVR, Inc. and may not be copied or disclosed except in
accordance with the terms of that agreement
Copyright(c) 2016 BinaryVR, Inc. All Rights Reserved.
**************************************************************************************************/

#pragma once

#include "asset_manager.hpp"
#include <Eigen/Dense>

using namespace Eigen;

class FaceMask
{
public:
    void loadMaskImage(const std::string& fileName, const std::string& extension, int openEyes, int type);
    
    std::vector<float> landmarks;
    Vector3f meanColor;
    float alpha;
    GLuint maskImage;
    GLuint alphaImage;
};
