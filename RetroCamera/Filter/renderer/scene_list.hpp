/**************************************************************************************************
BINARYVR, INC. PROPRIETARY INFORMATION
This software is supplied under the terms of a license agreement or nondisclosure
agreement with BinaryVR, Inc. and may not be copied or disclosed except in
accordance with the terms of that agreement
Copyright(c) 2016 BinaryVR, Inc. All Rights Reserved.
**************************************************************************************************/

#pragma once

#include <string>
#include "base_face_scene.hpp"

//BaseFaceScene* generateScene(const std::string& sceneName);
BaseFaceScene* generateScene(const std::string& sceneName,const std::string& textureName);
BaseFaceScene* generateScene2(const std::string& sceneName,const std::string& textureName,const std::string& stickereName,const std::string& earName,const std::string& glassesName,const std::string& hatName,const std::string& mustacheName,bool openEyes,  bool bigEyes,bool vline,int type);

