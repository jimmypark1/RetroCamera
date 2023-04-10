//
// Created by Junsung Park on 2018. 3. 18..
//

#ifndef BEAUTYCAMERA_GLASSESCOMPONENT_HPP
#define BEAUTYCAMERA_GLASSESCOMPONENT_HPP

#include "Component.hpp"

class GlassesComponent : public Component{
public:
    GlassesComponent(){
        renderCnt = 0;

    }

public:
    void render();
};


#endif //BEAUTYCAMERA_GLASSESCOMPONENT_HPP
