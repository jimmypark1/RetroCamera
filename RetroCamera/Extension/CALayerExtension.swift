//
//  CALayerExtension.swift
//  BeautyCamera
//
//  Created by Junsung Park on 2022/01/04.
//

import UIKit

//
//  CALayerExtension.swift
//  Vibr
//
//  Created by Junsung Park on 2021/05/22.
//

import Foundation
import UIKit

extension CALayer {
    func removeBorder() {
        if let subLayers = self.sublayers {
            for sublayer in subLayers {
                if let name = sublayer.name {
                    if name.contains("_borderline_") {
                        sublayer.removeFromSuperlayer()
                    }
                }
            }
        }
    }
    
    func addBorder(edge: UIRectEdge, color: UIColor, thickness: CGFloat, cornerRadius: CGFloat = 0) {
        if let subLayers = self.sublayers {
            for sublayer in subLayers {
                if sublayer.name == "_borderline_\(edge.rawValue)" {
                    sublayer.removeFromSuperlayer()
                }
            }
        }
        
        let border = CALayer()
        switch edge {
        case UIRectEdge.all:
            borderWidth = thickness
            borderColor = color.cgColor
            if cornerRadius > 0 {
                self.cornerRadius = cornerRadius
                self.masksToBounds = true
            }
            break
        case UIRectEdge.top:
            border.frame = CGRect(x: 0, y: 0, width: self.frame.width, height: thickness)
            break
        case UIRectEdge.bottom:
            border.frame = CGRect(x: 0, y: self.frame.height - thickness, width: self.frame.width, height: thickness)
            break
        case UIRectEdge.left:
            border.frame = CGRect(x: 0, y: 0, width: thickness, height: self.frame.height)
            break
        case UIRectEdge.right:
            border.frame = CGRect(x: self.frame.width - thickness, y: 0, width: thickness, height: self.frame.height)
            break
        default:
            break
        }
        
        if edge != .all {
            border.backgroundColor = color.cgColor;
        }
        border.name = "_borderline_\(edge.rawValue)"
        self.addSublayer(border)
    }
    
    func roundedBorder(color: UIColor, thickness: CGFloat, cornerRadius: CGFloat) {
        let innerView = CALayer()
        innerView.frame = CGRect(x: 0, y: 0, width: self.bounds.size.width, height: self.bounds.size.height)
        innerView.cornerRadius = cornerRadius
        innerView.borderWidth = thickness
        innerView.borderColor = color.cgColor
        innerView.masksToBounds = true
        innerView.backgroundColor = UIColor.clear.cgColor
        self.insertSublayer(innerView, at: 0)
    }
    
    func dropShadow(_ color:UIColor, radius: CGFloat, opacity:Float, offset:CGSize, scale: Bool = true) {
        self.masksToBounds = false
        self.shadowColor = color.cgColor
        self.shadowOpacity = opacity
        self.shadowOffset = offset
        self.shadowRadius = radius
        self.shadowPath = UIBezierPath(rect: self.bounds).cgPath
        self.shouldRasterize = true
        self.rasterizationScale = scale ? UIScreen.main.scale : 1
    }
    
    func addShadow(shadowOffset: CGSize, opacity: Float, radius: CGFloat, shadowColor: UIColor) {
        self.shadowOffset = shadowOffset
        self.shadowOpacity = opacity
        self.shadowRadius = radius
        
        self.shadowColor = shadowColor.cgColor
        self.masksToBounds = false
        if cornerRadius != 0 {
            addShadowWithRoundedCorners()
        }
    }
    /*
    func applySketchShadow(
        color: UIColor = .black,
        alpha: Float = 0.5,
        x: CGFloat = 0,
        y: CGFloat = 2,
        blur: CGFloat = 4,
        spread: CGFloat = 0)
    {
        shadowColor = color.cgColor
        shadowOpacity = alpha
        shadowOffset = CGSize(width: x, height: y)
        shadowRadius = blur / 2.0
        if spread == 0 {
            shadowPath = nil
        } else {
            let dx = -spread
            let rect = bounds.insetBy(dx: dx, dy: dx)
            shadowPath = UIBezierPath(rect: rect).cgPath
        }
    }
 */
    func applySketchShadow(
      color: UIColor = .black,
      alpha: Float = 0.5,
      x: CGFloat = 0,
      y: CGFloat = 2,
      blur: CGFloat = 4,
      spread: CGFloat = 0)
    {
      masksToBounds = false
      shadowColor = color.cgColor
      shadowOpacity = alpha
      shadowOffset = CGSize(width: x, height: y)
      shadowRadius = blur / 2.0
      if spread == 0 {
        shadowPath = nil
      } else {
        let dx = -spread
        let rect = bounds.insetBy(dx: dx, dy: dx)
        shadowPath = UIBezierPath(rect: rect).cgPath
      }
    }
    
    func roundCorners(radius: CGFloat) {
        self.cornerRadius = radius
        if shadowOpacity != 0 {
            addShadowWithRoundedCorners()
        }
    }
    
    private func addShadowWithRoundedCorners() {
        if let contents = self.contents {
            masksToBounds = false
            sublayers?.filter{ $0.frame.equalTo(self.bounds) }
                .forEach{ $0.roundCorners(radius: self.cornerRadius) }
            self.contents = nil
            if let sublayer = sublayers?.first,
                sublayer.name == "ShadowWithRoundedCorners" {
                sublayer.removeFromSuperlayer()
            }
            
            let contentLayer = CALayer()
            contentLayer.name = "ShadowWithRoundedCorners"
            contentLayer.contents = contents
            contentLayer.frame = bounds
            contentLayer.cornerRadius = cornerRadius
            contentLayer.masksToBounds = true
            insertSublayer(contentLayer, at: 0)
        }
    }
    
    class func performWithoutAnimation(_ actionsWithoutAnimation: () -> Void){
        CATransaction.begin()
        CATransaction.setValue(true, forKey: kCATransactionDisableActions)
        actionsWithoutAnimation()
        CATransaction.commit()
    }
}
