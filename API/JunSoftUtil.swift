//
//  File.swift
//  BeautyCamera
//
//  Created by Junsung Park on 2022/01/04.
//

import Foundation
import Hue


class JunSoftUtil{
    static let shared = JunSoftUtil()

    private init(){}
    var baseurl = "http://www.junsoft.org:8001"
    
    let primaryColor = UIColor(hex:"ffc72c")
 
    var isUpdate:Bool = false
    var isUpload:Bool = false
    var isCreate:Bool = false
    var isBuy:Bool = false
    var isDetail:Bool = false

    var type:Int = 1
}
