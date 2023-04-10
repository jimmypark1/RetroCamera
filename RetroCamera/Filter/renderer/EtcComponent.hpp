//
// Created by Junsung Park on 2018. 3. 19..
//

#ifndef BEAUTYCAMERA_ETCCOMPONENT_HPP
#define BEAUTYCAMERA_ETCCOMPONENT_HPP

#include "Component.hpp"

class EtcComponent : public Component {

public:
    EtcComponent(){
        renderCnt = 0;
    }
public:
    void render();

};


#endif //BEAUTYCAMERA_ETCCOMPONENT_HPP
