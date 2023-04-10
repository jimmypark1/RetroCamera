//
// Created by Junsung Park on 2018. 3. 18..
//

#ifndef BEAUTYCAMERA_EARRINGCOMPONENT_HPP
#define BEAUTYCAMERA_EARRINGCOMPONENT_HPP

#include "Component.hpp"

class EarringComponent : public Component{

public:
    EarringComponent(){
        renderCnt = 0;
    }
public:
    void render();

private:
    void renderEarring();
    void renderEarring2();

};


#endif //BEAUTYCAMERA_EARRINGCOMPONENT_HPP
