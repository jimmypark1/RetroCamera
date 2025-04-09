//
//  ItemCell.swift
//  RetroCamera
//
//  Created by Junsung Park on 2022/04/20.
//

import UIKit

class ItemCell: UICollectionViewCell {
    var img:UIImageView!
    
    var indicator:UIActivityIndicatorView!
   
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        // Set up background image view
        img = UIImageView(frame: self.bounds)
        img.contentMode = .scaleAspectFill
        img.layer.cornerRadius = 5
        img.clipsToBounds = true
        contentView.addSubview(img)
        img.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.width.height.equalTo(60)
        }
        indicator = UIActivityIndicatorView(style: .white)
        indicator.frame = self.bounds
        indicator.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        contentView.addSubview(indicator)
        
        indicator.snp.makeConstraints { make in
            make.centerX.centerY.equalToSuperview()
            make.width.height.equalTo(20)
        }
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
}
