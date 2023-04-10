//
// Created by Junsung Park on 2018. 3. 18..
//

#ifndef BEAUTYCAMERA_MUSTACHECOMPONENT_HPP
#define BEAUTYCAMERA_MUSTACHECOMPONENT_HPP

#include "Component.hpp"

class MustacheComponent : public Component {

public:
    MustacheComponent(){
        renderCnt = 0;
    }

public:
    void render();
};


#endif //BEAUTYCAMERA_MUSTACHECOMPONENT_HPP
