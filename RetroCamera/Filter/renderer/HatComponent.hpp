//
// Created by Junsung Park on 2018. 3. 18..
//

#ifndef BEAUTYCAMERA_HATCOMPONENT_HPP
#define BEAUTYCAMERA_HATCOMPONENT_HPP

#include "Component.hpp"

class HatComponent : public Component
{
public:
    HatComponent(){
        renderCnt = 0;
    }

public:
    void render();
private:
    void renderRule0();
    void renderRule1();

};


#endif //BEAUTYCAMERA_HATCOMPONENT_HPP
