/**************************************************************************************************
BINARYVR, INC. PROPRIETARY INFORMATION
This software is supplied under the terms of a license agreement or nondisclosure
agreement with BinaryVR, Inc. and may not be copied or disclosed except in
accordance with the terms of that agreement
Copyright(c) 2016 BinaryVR, Inc. All Rights Reserved.
**************************************************************************************************/

#include "scene_list.hpp"

#include "base_face_scene.hpp"
#include "facial_feature_scene.hpp"
#include "models.hpp"
#include "snowfall_filter.hpp"
#include "lookup_filter.hpp"
#include "face_mask_scene.hpp"
#include "face_mod_scene.hpp"

//  TODO: Fixed Model Switcher

BaseFaceScene* generateScene(const std::string& sceneName,const std::string& textureName)
{
  
  return nullptr;
}
BaseFaceScene* generateScene2(const std::string& sceneName,const std::string& textureName,const std::string& stickereName,const std::string& earName,const std::string& glassesName,const std::string& hatName,const std::string& mustacheName,bool openEyes, bool bigEyes,bool vline,int type)
{
   
    if (sceneName == "LiveSticker") {
        const char *name = textureName.c_str();
        const char *e_name = earName.c_str();
        const char *g_name = glassesName.c_str();
     
        const char *h_name = hatName.c_str();
        const char *m_name = mustacheName.c_str();
        
        return new SnowFallFilter(name,e_name,g_name,h_name,m_name, openEyes,vline, (int)type);
    }
    if (sceneName == "Filter") {
        
        const char *e_name = earName.c_str();
        const char *g_name = glassesName.c_str();
        
        const char *h_name = hatName.c_str();
        const char *m_name = mustacheName.c_str();
        
        return new LookupFilter(textureName,stickereName,e_name,g_name,h_name,m_name, true, true,(int)type);
    }
    if (sceneName == "FaceMode") {
        const char *name = textureName.c_str();
        
        return new FaceModScene(name);
    }
    if (sceneName == "FaceMask") {
        // FaceMaskScene(const char *_texFileName, const char* jsonName, int type);
        const char *name = textureName.c_str();
 
        const char *e_name = earName.c_str();
        const char *g_name = glassesName.c_str();
        
        const char *h_name = hatName.c_str();
        const char *m_name = mustacheName.c_str();
        //bool bOpenEyes, bool bVline, bool bBigEyes)
        return new FaceMaskScene(name, e_name,g_name,h_name,m_name,(int)type,openEyes,vline, bigEyes);
    }
    
    return nullptr;
}
