//
//  Extensions.swift
//  socialNetwork
//
//  Created by User on 2021-02-13.
//

import Foundation
import UIKit
import Firebase

extension UIColor{
    static func rgb(red: CGFloat, green: CGFloat, blue: CGFloat) -> UIColor {
        return UIColor (red: red/255, green: green/255, blue: blue/255, alpha: 1)
    }
}

extension UIView {
    func anchors(top: NSLayoutYAxisAnchor?,left: NSLayoutXAxisAnchor?,bottom:NSLayoutYAxisAnchor?,right:NSLayoutXAxisAnchor?,topConstant: CGFloat,leftConstant:CGFloat,bottomConstant:CGFloat,rightConstant:CGFloat, width:CGFloat , height: CGFloat) {
        
        translatesAutoresizingMaskIntoConstraints = false
        
        if let top = top{
       topAnchor.constraint(equalTo: top, constant: topConstant).isActive = true
        }
        if let bottom = bottom{
            bottomAnchor.constraint(equalTo: bottom, constant: -bottomConstant).isActive = true
        }
        if let left = left{
            leftAnchor.constraint(equalTo: left, constant: leftConstant).isActive = true
        }
        if let right = right{
            rightAnchor.constraint(equalTo: right, constant: -rightConstant).isActive = true
        }
        if width != 0{
            widthAnchor.constraint(equalToConstant: width).isActive = true
        }
        if height != 0{
            heightAnchor.constraint(equalToConstant: height).isActive = true
        }
    }
    
    public var width: CGFloat {
        return self.frame.size.width
    }
    public var height: CGFloat {
        return self.frame.size.height
    }
    public var top: CGFloat {
        return self.frame.origin.y
    }
    public var bottom: CGFloat {
        return self.frame.size.height + self.frame.origin.y
    }
    public var left: CGFloat {
        return self.frame.origin.x
    }
    public var right: CGFloat {
        return self.frame.size.width + self.frame.origin.x
    }
    
}



