//
// Created by Junsung Park on 2018. 3. 18..
//

#ifndef BEAUTYCAMERA_NOSECOMPONENT_HPP
#define BEAUTYCAMERA_NOSECOMPONENT_HPP
#include "Component.hpp"

class NoseComponent : public Component {

public:
    NoseComponent(){
        renderCnt = 0;
    }
public:
    void render();
};


#endif //BEAUTYCAMERA_NOSECOMPONENT_HPP
