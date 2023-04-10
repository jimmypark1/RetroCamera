/**************************************************************************************************
BINARYVR, INC. PROPRIETARY INFORMATION
This software is supplied under the terms of a license agreement or nondisclosure
agreement with BinaryVR, Inc. and may not be copied or disclosed except in
accordance with the terms of that agreement
Copyright(c) 2016 BinaryVR, Inc. All Rights Reserved.
**************************************************************************************************/


/**
 *  asset_manager.cpp
 *
 *  Loads various assets (i.e. textures, json files and so on)
 *  In Xcode, set type to 'Objective-C++ source' on 'Identity and Type' of the right bar.
 */

#include "asset_manager.hpp"

#include <cassert>

#define STB_IMAGE_IMPLEMENTATION
#include <stb_image.h>

#ifdef __APPLE__
#include <Foundation/Foundation.h>
#endif  // __APPLE__

#ifdef __ANDROID__
AAssetManager *AssetManager::assetManager = nullptr;
#endif  // __ANDROID__

using namespace std;

GLuint AssetManager::loadLocalTexture(const string& fileName, const string& extension, int& width, int& height)
{
    int comp;
    unsigned char* image;
    
#ifdef __APPLE__
    NSString* fileNameStr = [NSString  stringWithUTF8String:fileName.c_str() ];
    
    NSString *path =  [[NSBundle mainBundle] pathForResource:fileNameStr ofType:@""] ;
    
    if(!path)
    return 0;
    
    std::string filepath = [path UTF8String];
    
    stbi_convert_iphone_png_to_rgb(true);
    image = stbi_load(filepath.c_str(), &width, &height, &comp, 0);
#elif __ANDROID__
    std::string fullFileName = fileName + "." + extension;
    AAsset *asset =
    AAssetManager_open(AssetManager::assetManager, fullFileName.c_str(), AASSET_MODE_UNKNOWN);
    if (!asset) {
        return 0;
    }
    
    int fileSize = AAsset_getLength(asset);
    if (fileSize == 0) {
        return 0;
    }
    
    std::vector<unsigned char> buf(fileSize);
    AAsset_read(asset, &buf[0], fileSize);
    AAsset_close(asset);
    asset = nullptr;
    image = stbi_load_from_memory(&buf[0], fileSize, &width, &height, &comp, 0);
#else
    //  TODO: Win32?
    assert(false);
#endif
    
    if(image == nullptr) {
        return 0;
    }
    
    GLuint textures[1];
    glGenTextures(1, textures);
    GLuint texture = textures[0];
    
    glBindTexture(GL_TEXTURE_2D, texture);
    
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_NEAREST);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
    
    if(comp == 1)
    glTexImage2D(GL_TEXTURE_2D, 0, GL_LUMINANCE, width, height, 0, GL_LUMINANCE, GL_UNSIGNED_BYTE, image);
    else if(comp == 3)
    glTexImage2D(GL_TEXTURE_2D, 0, GL_RGB, width, height, 0, GL_RGB, GL_UNSIGNED_BYTE, image);
    else if(comp == 4)
    glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, width, height, 0, GL_RGBA, GL_UNSIGNED_BYTE, image);
    else {
        assert(false);
    }
    
    glBindTexture(GL_TEXTURE_2D, 0);
    
    stbi_image_free(image);
    return texture;
}

GLuint AssetManager::loadNetworkFilterTexture(const string& fileName, const string& extension, int& width, int& height)
{
    int comp;
    unsigned char* image;
    
#ifdef __APPLE__
    
    
    NSString* fileNameStr = [NSString stringWithUTF8String:fileName.c_str()];
    NSArray       *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString  *documentsDirectory = [paths objectAtIndex:0];
    std::string filepath = [[NSString stringWithFormat:@"%@/filter/%@", documentsDirectory,fileNameStr] UTF8String];
    
    stbi_convert_iphone_png_to_rgb(true);
    image = stbi_load(filepath.c_str(), &width, &height, &comp, 0);
#elif __ANDROID__
    std::string filepath = fileName;
    stbi_convert_iphone_png_to_rgb(true);
    image = stbi_load(filepath.c_str(), &width, &height, &comp, 0);
#else
    //  TODO: Win32?
    assert(false);
#endif
    
    if(image == nullptr) {
        return 0;
    }
    
    GLuint textures[1];
    glGenTextures(1, textures);
    GLuint texture = textures[0];
    
    glBindTexture(GL_TEXTURE_2D, texture);
    
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_NEAREST);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
    
    if(comp == 1)
    glTexImage2D(GL_TEXTURE_2D, 0, GL_LUMINANCE, width, height, 0, GL_LUMINANCE, GL_UNSIGNED_BYTE, image);
    else if(comp == 3)
    glTexImage2D(GL_TEXTURE_2D, 0, GL_RGB, width, height, 0, GL_RGB, GL_UNSIGNED_BYTE, image);
    else if(comp == 4)
    glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, width, height, 0, GL_RGBA, GL_UNSIGNED_BYTE, image);
    else {
        assert(false);
    }
    
    glBindTexture(GL_TEXTURE_2D, 0);
    
    stbi_image_free(image);
    return texture;
}
GLuint AssetManager::loadNetworkStickerTexture(const string& fileName, const string& extension, int& width, int& height)
{
    int comp;
    unsigned char* image;
    
#ifdef __APPLE__
    
    NSString* fileNameStr = [NSString stringWithUTF8String:fileName.c_str()];
    NSArray       *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString  *documentsDirectory = [paths objectAtIndex:0];
    std::string filepath = [[NSString stringWithFormat:@"%@/sticker/%@", documentsDirectory,fileNameStr] UTF8String];
    
    
    stbi_convert_iphone_png_to_rgb(true);
    image = stbi_load(filepath.c_str(), &width, &height, &comp, 0);
    
#elif __ANDROID__
    std::string filepath = fileName;
    stbi_convert_iphone_png_to_rgb(true);
    image = stbi_load(filepath.c_str(), &width, &height, &comp, 0);

#else
    //  TODO: Win32?
    assert(false);
#endif
    
    if(image == nullptr) {
        return 0;
    }
    
    GLuint textures[1];
    glGenTextures(1, textures);
    GLuint texture = textures[0];
    
    glBindTexture(GL_TEXTURE_2D, texture);
    
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_NEAREST);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
    
    if(comp == 1)
        glTexImage2D(GL_TEXTURE_2D, 0, GL_LUMINANCE, width, height, 0, GL_LUMINANCE, GL_UNSIGNED_BYTE, image);
    else if(comp == 3)
        glTexImage2D(GL_TEXTURE_2D, 0, GL_RGB, width, height, 0, GL_RGB, GL_UNSIGNED_BYTE, image);
    else if(comp == 4)
        glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, width, height, 0, GL_RGBA, GL_UNSIGNED_BYTE, image);
    else {
        assert(false);
    }
    
    glBindTexture(GL_TEXTURE_2D, 0);
    
    stbi_image_free(image);
    return texture;
}
void AssetManager::loadJson(
    const std::string& fileName, const std::string& extension, rapidjson::Document& d)
{
#ifdef __APPLE__
  
    /*
    
  NSString* fileNameStr = [NSString stringWithUTF8String:fileName.c_str()];
  NSString* extensionStr = [NSString stringWithUTF8String:extension.c_str()];
  std::string filepath = [[[NSBundle mainBundle] pathForResource:fileNameStr ofType:extensionStr] UTF8String];
*/
    
    NSString* fileNameStr = [NSString stringWithUTF8String:fileName.c_str()];
    NSString* extensionStr = [NSString stringWithUTF8String:extension.c_str()];
    
    NSArray       *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString  *documentsDirectory = [paths objectAtIndex:0];
    std::string filepath  = [[NSString stringWithFormat:@"%@/mask/%@.json", documentsDirectory,fileNameStr] UTF8String];
    
    
    
  FILE *fp = fopen(filepath.c_str(), "rb");
  if (fp == NULL)
    return;

  fseek(fp, 0L, SEEK_END);
  long file_size = ftell(fp);
  fseek(fp, 0L, SEEK_SET);
  std::vector<char> readBuffer(file_size * 2);
  rapidjson::FileReadStream is(fp, &readBuffer[0], file_size * 2);
  d.ParseStream(is);
  fclose(fp);
#elif __ANDROID__
  std::string fullFileName = fileName + "." + extension;
  AAsset* asset = AAssetManager_open(AssetManager::assetManager, fullFileName.c_str(), AASSET_MODE_UNKNOWN);
  if (asset == NULL)
    return;

  int fileSize = AAsset_getLength(asset);
  if (fileSize == 0)
    return;

  std::vector<char> buf(fileSize + 1);
  AAsset_read(asset, &buf[0], fileSize);
  AAsset_close(asset);
  buf[fileSize] = 0;
  rapidjson::StringStream is(&buf[0]);
  d.ParseStream(is);
#else
  //  TODO: Win32?
  assert(false);
#endif

}

void AssetManager::loadJson2(
                            const std::string& fileName, const std::string& extension, rapidjson::Document& d)
{
#ifdef __APPLE__
    
    /*
     
     NSString* fileNameStr = [NSString stringWithUTF8String:fileName.c_str()];
     NSString* extensionStr = [NSString stringWithUTF8String:extension.c_str()];
     std::string filepath = [[[NSBundle mainBundle] pathForResource:fileNameStr ofType:extensionStr] UTF8String];
     */
    
    NSString* fileNameStr = [NSString stringWithUTF8String:fileName.c_str()];
    NSString* extensionStr = [NSString stringWithUTF8String:extension.c_str()];
    
    NSArray       *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString  *documentsDirectory = [paths objectAtIndex:0];
    std::string filepath  = [[NSString stringWithFormat:@"%@/sticker/%@.json", documentsDirectory,fileNameStr] UTF8String];
    
    
    
    FILE *fp = fopen(filepath.c_str(), "rb");
    if (fp == NULL)
        return;
    
    fseek(fp, 0L, SEEK_END);
    long file_size = ftell(fp);
    fseek(fp, 0L, SEEK_SET);
    std::vector<char> readBuffer(file_size * 2);
    rapidjson::FileReadStream is(fp, &readBuffer[0], file_size * 2);
    d.ParseStream(is);
    fclose(fp);
#elif __ANDROID__
    std::string fullFileName = fileName + "." + extension;
    AAsset* asset = AAssetManager_open(AssetManager::assetManager, fullFileName.c_str(), AASSET_MODE_UNKNOWN);
    if (asset == NULL)
        return;
    
    int fileSize = AAsset_getLength(asset);
    if (fileSize == 0)
        return;
    
    std::vector<char> buf(fileSize + 1);
    AAsset_read(asset, &buf[0], fileSize);
    AAsset_close(asset);
    buf[fileSize] = 0;
    rapidjson::StringStream is(&buf[0]);
    d.ParseStream(is);
#else
    //  TODO: Win32?
    assert(false);
#endif
    
}

bool AssetManager::loadJsonSticker(
                                   const std::string& fileName, const std::string& extension, rapidjson::Document& d)
{
#if TARGET_OS_SIMULATOR || TARGET_OS_IPHONE
    NSString* fileNameStr = [NSString stringWithUTF8String:fileName.c_str()];
    NSString* extensionStr = [NSString stringWithUTF8String:extension.c_str()];
  //  std::string filepath = [[[NSBundle mainBundle] pathForResource:fileNameStr ofType:extensionStr] UTF8String];
    NSArray       *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString  *documentsDirectory = [paths objectAtIndex:0];
    
    std::string filepath  = [[NSString stringWithFormat:@"%@/sticker/%@.json", documentsDirectory,fileNameStr] UTF8String];
    
    FILE *fp = fopen(filepath.c_str(), "rb");
    if (fp == NULL)
        return false;
    
    fseek(fp, 0L, SEEK_END);
    long file_size = ftell(fp);
    fseek(fp, 0L, SEEK_SET);
    std::vector<char> readBuffer(file_size * 2);
    rapidjson::FileReadStream is(fp, &readBuffer[0], file_size * 2);
    d.ParseStream(is);
    fclose(fp);
    
    return true;
    
#elif __ANDROID__
    std::string fullFileName = fileName + "." + extension;
    
    FILE* fp = NULL;
    fp = fopen(fullFileName.c_str(),"r");
    
    if(!fp)
        return false;
    long fileSize = FileSize(fullFileName);
    // AAsset* asset = AAssetManager_open(AssetManager::assetManager, fullFileName.c_str(), AASSET_MODE_UNKNOWN);
    // if (asset == NULL)
    //   return;
    if (fileSize == 0)
        return;
    
    std::vector<char> readBuffer(fileSize * 2);
    rapidjson::FileReadStream is(fp, &readBuffer[0], fileSize * 2);
    
    d.ParseStream(is);
    fclose(fp);
    return true;
    //  delete (buf1);
#elif WIN32 || TARGET_OS_OSX
    std::string fullFileName = fileName + "." + extension;
    FILE *fp = fopen(fullFileName.c_str(), "rb");
    
    if (fp == NULL)
        return;
    
    fseek(fp, 0L, SEEK_END);
    long file_size = ftell(fp);
    fseek(fp, 0L, SEEK_SET);
    std::vector<char> readBuffer(file_size * 2);
    rapidjson::FileReadStream is(fp, &readBuffer[0], file_size * 2);
    d.ParseStream(is);
    fclose(fp);
#else
    //  TODO: Linux?
    assert(false);
#endif
    
}
bool AssetManager::loadJson3(
                             const std::string& fileName, const std::string& extension, rapidjson::Document& d)
{
#ifdef __APPLE__
    
    
    
     NSString* fileNameStr = [NSString stringWithUTF8String:fileName.c_str()];
     NSString* extensionStr = [NSString stringWithUTF8String:extension.c_str()];
     std::string filepath = [[[NSBundle mainBundle] pathForResource:fileNameStr ofType:extensionStr] UTF8String];
    
    
    FILE *fp = fopen(filepath.c_str(), "rb");
    if (fp == NULL)
        return false;
    
    fseek(fp, 0L, SEEK_END);
    long file_size = ftell(fp);
    fseek(fp, 0L, SEEK_SET);
    std::vector<char> readBuffer(file_size * 2);
    rapidjson::FileReadStream is(fp, &readBuffer[0], file_size * 2);
    d.ParseStream(is);
    fclose(fp);
    
    return true;
#elif __ANDROID__
    std::string fullFileName = fileName + "." + extension;
    AAsset* asset = AAssetManager_open(AssetManager::assetManager, fullFileName.c_str(), AASSET_MODE_UNKNOWN);
    if (asset == NULL)
        return;
    
    int fileSize = AAsset_getLength(asset);
    if (fileSize == 0)
        return false;
    
    std::vector<char> buf(fileSize + 1);
    AAsset_read(asset, &buf[0], fileSize);
    AAsset_close(asset);
    buf[fileSize] = 0;
    rapidjson::StringStream is(&buf[0]);
    d.ParseStream(is);
    
    return true;
#else
    //  TODO: Win32?
    assert(false);
#endif
    
}

void AssetManager::loadRaw(
    const std::string& fileName, const std::string& extension, std::string& s)
{
#ifdef __APPLE__
  NSString* fileNameStr = [NSString stringWithUTF8String:fileName.c_str()];
  NSString* extensionStr = [NSString stringWithUTF8String:extension.c_str()];
  std::string filepath = [[[NSBundle mainBundle] pathForResource:fileNameStr ofType:extensionStr] UTF8String];

  FILE *fp = fopen(filepath.c_str(), "rb");
  if (fp == NULL)
    return;

  fseek(fp, 0L, SEEK_END);
  long file_size = ftell(fp);
  fseek(fp, 0L, SEEK_SET);

  s.resize(file_size);

  fread((void *)s.data(), file_size, 1, fp);
  fclose(fp);
#elif __ANDROID__
  std::string fullFileName = fileName + "." + extension;
  AAsset* asset = AAssetManager_open(AssetManager::assetManager, fullFileName.c_str(), AASSET_MODE_UNKNOWN);
  if (asset == NULL)
    return;

  int fileSize = AAsset_getLength(asset);
  if (fileSize == 0)
    return;

  s.resize(fileSize);
  AAsset_read(asset, &s[0], fileSize);
  AAsset_close(asset);
#else
  //  TODO: Win32?
  assert(false);
#endif
}
