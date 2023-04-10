//
// Created by Junsung Park on 2018. 3. 18..
//

#ifndef BEAUTYCAMERA_EARCOMPONENT_HPP
#define BEAUTYCAMERA_EARCOMPONENT_HPP

#include "Component.hpp"
class EarComponent : public Component {

public:
    EarComponent(){
        renderCnt = 0;
    }

public:
    void render();
};


#endif //BEAUTYCAMERA_EARCOMPONENT_HPP
