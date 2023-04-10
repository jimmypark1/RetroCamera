//
// Created by Junsung Park on 2018. 3. 18..
//

#ifndef BEAUTYCAMERA_COMPONENT_HPP
#define BEAUTYCAMERA_COMPONENT_HPP

#include "base_face_scene.hpp"
#include <vector>
#include <Eigen/Dense>
#include "face_mod.hpp"

using namespace Eigen;

typedef enum eComponentType{
    eStatic ,
    eAnimation,
};

class Component {

public:
    Component() ;
   

public:
    eComponentType eType;
    //void Component::CreateComponet();

public:
    virtual void render() {};
    virtual void init() {};
    virtual void setEtcSource(int _w_x0,int _w_x1,int _h_y0,int _h_y1,
                              int _s_x, int _s_y,float _s_x_ratio,
                              float _s_y_ratio, int _z0, int _z1, bool _mirroed)
    {
        w_x0 = _w_x0;
        w_x1 = _w_x1;
        h_y0 = _h_y0;
        h_y1 = _h_y1;
        s_x = _s_x;
        s_y = _s_y;
        s_x_ratio = _s_x_ratio;
        s_y_ratio = _s_y_ratio;
        z0 = _z0;
        z1 = _z1;
        mirrored =_mirroed;

    }
    virtual void setHatRule(int _rule)
    {
        rule = _rule;
    }

    virtual void setSource(std::string _name,std::string _baseDir, int _bound, float _widthRatio, float _heightRatio)
    {
        name = _name;
        baseDir = _baseDir;
        bound = _bound;


        std::string file ;
#if TARGET_OS_IPHONE || TARGET_OS_SIMULATOR
        file = name;
        baseDir = "";

#else // Android
        file = "/" + name;
#endif
        fullPath =  baseDir+file;
        const char *path;
        const char *path2;
        path = fullPath.c_str();
        char numstr[21]; // enough to hold all numbers up to 64-bits

        if(bound>1)
        {
            for(int i=0;i<bound;i++)
            {
                sprintf(numstr, "%d", i);

                //path = path +numstr;
                fullPath2 = fullPath + numstr;
                fullPath3 = fullPath + numstr+"f";
                path = fullPath2.c_str();
                path2 = fullPath3.c_str();
#if TARGET_OS_IPHONE || TARGET_OS_SIMULATOR
                if(type == 0)
                {
                    textures[i] = AssetManager::loadNetworkStickerTexture(fullPath2, "png", imgWidth, imgHeight);
                    if(mirrored == true)
                        textures_f[i] = AssetManager::loadNetworkStickerTexture(fullPath3, "png", imgWidth, imgHeight);

                }
                else
                {
                    textures[i] = AssetManager::loadLocalTexture(fullPath2, "png", imgWidth, imgHeight);
                    if(mirrored == true)
                        textures_f[i] = AssetManager::loadLocalTexture(fullPath3, "png", imgWidth, imgHeight);

                }
     
#else // Android
                if(type == 0)
                {
                    textures[i] = AssetManager::loadNetworkStickerTexture(path, "png", imgWidth, imgHeight);
                    if(mirrored == true)
                    textures_f[i] = AssetManager::loadNetworkStickerTexture(path2, "png", imgWidth, imgHeight);

                }
                else
                {
                    textures[i] = AssetManager::loadLocalTexture(path, "png", imgWidth, imgHeight);
                    if(mirrored == true)
                    textures_f[i] = AssetManager::loadLocalTexture(path2, "png", imgWidth, imgHeight);

                }
#endif
                
         
            }
        } else
        {
#if TARGET_OS_IPHONE || TARGET_OS_SIMULATOR
            if(type == 0)
                textures[0] = AssetManager::loadNetworkStickerTexture(path, "png", imgWidth, imgHeight);
            else
                textures[0] = AssetManager::loadLocalTexture(path, "png", imgWidth, imgHeight);
            

#else // Android
         
            if(type == 0)
                textures[0] = AssetManager::loadNetworkStickerTexture(path, "png", imgWidth, imgHeight);
            else
                textures[0] = AssetManager::loadLocalTexture(path, "png", imgWidth, imgHeight);
            
#endif
            
            
   
        }

        widthRatio = _widthRatio;
        heightRatio = _heightRatio;

    };

    virtual void setDest(std::vector<std::vector<float>> _faces,std::vector<Matrix4f> _matrixs) {
        faces = _faces;
        matrixs = _matrixs;
  //      widthRatio = _widthRatio;
  //      heightRatio = _heightRatio;
    }

public:
    bool bFront;

private:
    std::string TEXTURE_FSH;
    std::string TEXTURE_VSH;

public:
    ShaderProgram sceneProgram;
    std::vector<std::vector<float>> faces;
    std::vector<Matrix4f> matrixs;
    int bound;
    float widthRatio;
    float heightRatio;
    int imgWidth;
    int imgHeight;

    int renderCnt;
    float determinantScreenToViewPort;
    std::string name;
    std::string baseDir;
    int w_x0;
    int w_x1;
    int h_y0;
    int h_y1;
    int s_x;
    int s_y;
    float s_x_ratio;
    float s_y_ratio;
    int z0;
    int z1;
    //std::string rule;
    int rule;
    bool mirrored;
    int type;
    std::string fullPath ;
    std::string fullPath2;
    std::string fullPath3;

    GLuint textures[100];
    GLuint textures_f[100];


};


#endif //BEAUTYCAMERA_COMPONENT_HPP
