/**************************************************************************************************
BINARYVR, INC. PROPRIETARY INFORMATION
This software is supplied under the terms of a license agreement or nondisclosure
agreement with BinaryVR, Inc. and may not be copied or disclosed except in
accordance with the terms of that agreement
Copyright(c) 2016 BinaryVR, Inc. All Rights Reserved.
**************************************************************************************************/

#pragma once

#include "platforms.h"

#include <rapidjson/rapidjson.h>
#include <rapidjson/document.h>
#include <rapidjson/filereadstream.h>

#include <cstdlib>
#include <cmath>
#include <string>
#include <vector>

/**
 *  Cross-platform resource loader
 */
class AssetManager
{
public:
  
    static GLuint loadLocalTexture(const std::string& fileName, const std::string& extension, int& width, int& height);

    static GLuint loadNetworkFilterTexture(const std::string& fileName, const std::string& extension, int& width, int& height);
    static GLuint loadNetworkStickerTexture(const std::string& fileName, const std::string& extension, int& width, int& height);


    static void loadJson(
      const std::string& fileName, const std::string& extension, rapidjson::Document& d);
    static void loadJson2(
                         const std::string& fileName, const std::string& extension, rapidjson::Document& d);
    static bool loadJson3(
                                 const std::string& fileName, const std::string& extension, rapidjson::Document& d);

    static void loadRaw(
      const std::string& fileName, const std::string& extension, std::string& s);
    static bool loadJsonSticker(
                                const std::string& fileName, const std::string& extension, rapidjson::Document& d);

#ifdef __ANDROID__
  static void setAssetManager(AAssetManager* assetManager) {
    AssetManager::assetManager = assetManager;
  }
protected:
  static AAssetManager *assetManager;
#endif
};
