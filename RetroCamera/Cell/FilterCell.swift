//
//  FilterCell.swift
//  RetroCamera
//
//  Created by Junsung Park on 2022/04/19.
//

import UIKit
import SnapKit

class FilterCell: UICollectionViewCell {
    
    
    var img:UIImageView!
    var indicator:UIActivityIndicatorView?
   
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        // Set up background image view
        img = UIImageView(frame: self.bounds)
        img.contentMode = .scaleAspectFill
        img.layer.cornerRadius
        img.clipsToBounds = true
        contentView.addSubview(img)
        img.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.width.height.equalTo(120)
        }
     
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
