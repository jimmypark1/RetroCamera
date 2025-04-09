//
//  Utility.swift
//  RetroCamera
//
//  Created by N4225 on 2/12/25.
//

import UIKit

class Utility: NSObject {

    static func createPlanButton(title: String, titleColor:UIColor = .white) -> UIButton {
        let button = GradientButton()
        button.setTitle(title, for: .normal)
        button.setTitleColor(titleColor, for: .normal)
        button.backgroundColor = .systemBlue//UIColor(red: 255/255, green: 182/255, blue: 193/255, alpha: 1.0)
        button.layer.cornerRadius = 12
        button.layer.shadowColor = UIColor.lightGray.cgColor//UIColor.black.cgColor
        button.layer.shadowOpacity = 0.2
        button.layer.shadowOffset = CGSize(width: 0, height: 4)
        button.layer.shadowRadius = 8
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 18)
        return button
    }
}
