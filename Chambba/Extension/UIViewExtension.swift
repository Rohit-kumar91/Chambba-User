//
//  LanguageSelectionViewController.swift
//  KawafilShipper
//
//  Created by Mayur chaudhary on 08/06/18.
//  Copyright © 2018 Ashish Kumar singh. All rights reserved.
//


import UIKit

extension UIView {
    
    @IBInspectable var corner: CGFloat {
        get {
            return self.layer.cornerRadius
        }
        set {
            
            self.layer.cornerRadius = newValue
            self.clipsToBounds = true
        }
    }
    
    @IBInspectable var borderWidth: CGFloat {
        get {
            return self.layer.borderWidth
        }
        set {
            
            self.layer.borderWidth = newValue
            self.clipsToBounds = true
        }
    }
    
    @IBInspectable var borderColor: UIColor? {
        get {
            return UIColor.clear
        }
        set {
            
            self.layer.borderColor = newValue?.cgColor
            self.layer.borderWidth = 1.0
        }
    }
    
    func cardShape(_ color: UIColor = UIColor.darkGray) {
        
        self.layer.cornerRadius = 2.0
        self.clipsToBounds = true
        self.aroundShadow(color)
    }
    
    func shadow(_ color: UIColor = UIColor.lightGray) {
        self.layer.shadowColor = color.cgColor;
        self.layer.shadowOpacity = 0.3
        self.layer.shadowRadius = 1
        self.layer.masksToBounds = false
        self.layer.shadowOffset = CGSize(width: 1, height: 1)
    }
    
    func shadowWithRadius(_ color: UIColor = UIColor.lightGray, radius : Float) {
        self.layer.shadowColor = color.cgColor;
        self.layer.shadowOpacity = 0.5
        self.layer.shadowRadius = CGFloat(radius)
        self.layer.masksToBounds = false
        self.layer.shadowOffset = CGSize.zero
        self.layer.cornerRadius = 3.0
    }

    func shadowAtBottom(){
        self.layer.shadowOffset = CGSize(width: 0, height: 3)
        self.layer.shadowOpacity = 0.6
        self.layer.shadowRadius = 3.0
        self.layer.shadowColor = UIColor.darkGray.cgColor
    }
    
    func shadowAtBottom(red : CGFloat,green: CGFloat,blue: CGFloat){
        self.layer.shadowOffset = CGSize(width: 0, height: 3)
        self.layer.shadowOpacity = 0.6
        self.layer.shadowRadius = 3.0
        self.layer.masksToBounds = true
        self.layer.shadowColor = UIColor.init(red: red/255, green: green/255, blue: blue/255, alpha: 1.0).cgColor
    }
    
    func aroundShadow(_ color: UIColor = UIColor.darkGray) {
        self.layer.shadowColor = color.cgColor
        self.layer.shadowOpacity = 0.3
        self.layer.shadowRadius = 3
        self.layer.cornerRadius = 10
        self.layer.masksToBounds = true
        self.layer.shadowOffset = CGSize(width: 0.3, height: 0.3)
    }
    
    func setBorder(_ color: UIColor, borderWidth: CGFloat) {
        self.layer.borderColor = color.cgColor
        self.layer.borderWidth = borderWidth
        self.clipsToBounds = true
    }
    
    func addShadowAtEitherEnd(top: Bool,
                   left: Bool,
                   bottom: Bool,
                   right: Bool,
                   shadowRadius: CGFloat = 2.0) {
        self.layer.shadowColor = UIColor.gray.cgColor
        self.layer.masksToBounds = false
        self.layer.shadowOffset = CGSize(width: 0.0, height: 0.0)
        self.layer.shadowRadius = shadowRadius
        self.layer.shadowOpacity = 1.0
        
        let path = UIBezierPath()
        var x: CGFloat = 0
        var y: CGFloat = 0
        var viewWidth = self.frame.width
        var viewHeight = self.frame.height
        
        // here x, y, viewWidth, and viewHeight can be changed in
        // order to play around with the shadow paths.
        if (!top) {
            y+=(shadowRadius+1)
        }
        if (!bottom) {
            viewHeight-=(shadowRadius+1)
        }
        if (!left) {
            x+=(shadowRadius+1)
        }
        if (!right) {
            viewWidth-=(shadowRadius+1)
        }
        // selecting top most point
        path.move(to: CGPoint(x: x, y: y))
        // Move to the Bottom Left Corner, this will cover left edges

        path.addLine(to: CGPoint(x: x, y: viewHeight))
        // Move to the Bottom Right Corner, this will cover bottom edge
      
        path.addLine(to: CGPoint(x: viewWidth, y: viewHeight))
        // Move to the Top Right Corner, this will cover right edge
        path.addLine(to: CGPoint(x: viewWidth, y: y))
        // Move back to the initial point, this will cover the top edge
        path.close()
        self.layer.shadowPath = path.cgPath
    }
   
    
    
}
