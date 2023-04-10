/**************************************************************************************************
BINARYVR, INC. PROPRIETARY INFORMATION
This software is supplied under the terms of a license agreement or nondisclosure
agreement with BinaryVR, Inc. and may not be copied or disclosed except in
accordance with the terms of that agreement
Copyright(c) 2016 BinaryVR, Inc. All Rights Reserved.
**************************************************************************************************/

#include "face_mask.hpp"
#include "rapidjson/document.h"

void FaceMask::loadMaskImage(const std::string& fileName, const std::string& extension, int openEyes, int type)
{
    rapidjson::Document d;
    int width, height;
    
    if(type == 1)
        maskImage = AssetManager::loadLocalTexture(fileName, extension, width, height);
    else
        maskImage = AssetManager::loadNetworkStickerTexture(fileName, extension, width, height);
    
   // AssetManager::loadJson(fileName + "." + extension, "json", d);
    
    if(type == 1)
        AssetManager::loadJson3(fileName + "." + extension, "json", d);
    else
        //AssetManager::loadJsonSticker(fileName + "." + extension, "json", d);
        AssetManager::loadJsonSticker(fileName , "json", d);
    
    
    if (d.HasMember("landmarks")) {
        landmarks.clear();
        for (int i = 0; i < d["landmarks"].Size(); i++) {
            landmarks.push_back(d["landmarks"][i]["x"].GetDouble() / width);
            landmarks.push_back(d["landmarks"][i]["y"].GetDouble() / height);
        }
    }
    if (d.HasMember("alpha"))
        alpha = d["alpha"].GetDouble();
    if (d.HasMember("mean_color")) {
        meanColor(0) = d["mean_color"]["r"].GetDouble();
        meanColor(1) = d["mean_color"]["g"].GetDouble();
        meanColor(2) = d["mean_color"]["b"].GetDouble();
    }
    /*
    if (d.HasMember("openEyes") && d["openEyes"].GetInt() != 0)
        alphaImage = AssetManager::loadTexture("alpha_eye", "png");
    else
        alphaImage = AssetManager::loadTexture("alpha", "png");
    */
    if(openEyes)
    {
        /*
        if(type == 1)
            alphaImage = AssetManager::loadLocalTexture("alpha_eye", "png", width, height);
        else
            alphaImage = AssetManager::loadNetworkStickerTexture("alpha_eye", "png", width, height);
        */
        alphaImage = AssetManager::loadLocalTexture("alpha_eye", "png", width, height);
        
    }
    else
    {
        /*
        if(type == 1)
            alphaImage = AssetManager::loadLocalTexture("alpha", "png", width, height);
        else
            alphaImage = AssetManager::loadNetworkStickerTexture("alpha", "png", width, height);
        */
        alphaImage = AssetManager::loadLocalTexture("alpha", "png", width, height);
        
    }
        
    
}
