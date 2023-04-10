//
//  FilterData.swift
//  RetroCamera
//
//  Created by Junsung Park on 2022/04/21.
//

import UIKit

class FilterData: NSObject {
    var name:String = ""
    var filterName:String = ""
    var thumb:String = ""
    var type:String = ""
    var category:String = ""
    
    init(name:String,filterName:String, thumb:String, type:String, category:String) {
        
        self.name = name
        self.thumb = thumb
        self.type = type
        self.filterName = filterName
        self.category = category
        
        super.init()
    }
}
