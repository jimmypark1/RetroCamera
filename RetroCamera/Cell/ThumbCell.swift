//
//  ThumbCell.swift
//  RetroCamera
//
//  Created by Junsung Park on 2022/04/19.
//

import UIKit

import UIKit

class ThumbCell: UICollectionViewCell {
    @IBOutlet weak var imgView:UIImageView?
    @IBOutlet weak var indicator:UIActivityIndicatorView?
    @IBOutlet weak var name:UILabel?
    @IBOutlet weak var vip:UIImageView?
   
    var index:Int!
}
