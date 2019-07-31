//
//  MASliderSpringAnimator.swift
//  CarTrade
//
//  Created by Acesoft on 09/10/15.
//  Copyright (c) 2015 Acesoft. All rights reserved.
//

import UIKit

open class MASliderSpringAnimator: NSObject {
    
    let kMACenterViewDestinationScale:CGFloat = 1.0//0.9
    
    open var animationDelay: TimeInterval        = 0.0
    open var animationDuration: TimeInterval     = 0.4//0.7
    open var initialSpringVelocity: CGFloat        = 9.8 // 9.1 m/s == earth gravity accel.
    open var springDamping: CGFloat                = 1.0//0.8
    
    // TODO: can swift have private functions in a protocol?
    fileprivate func applyTransforms(_ side: MASliderSide, sliderView: UIView, centerView: UIView) {
        
        let direction = side.rawValue
        let sideWidth = sliderView.bounds.width
        let centerWidth = centerView.bounds.width
        let centerHorizontalOffset = direction * sideWidth
        let scaledCenterViewHorizontalOffset = direction * (sideWidth - (centerWidth - kMACenterViewDestinationScale * centerWidth) / 2.0)
        
        let sideTransform = CGAffineTransform(translationX: centerHorizontalOffset, y: 0.0)
        sliderView.transform = sideTransform
        
        let centerTranslate = CGAffineTransform(translationX: scaledCenterViewHorizontalOffset, y: 0.0)
        let centerScale = CGAffineTransform(scaleX: kMACenterViewDestinationScale, y: kMACenterViewDestinationScale)
        centerView.transform = centerScale.concatenating(centerTranslate)
        
    }
    
    fileprivate func resetTransforms(_ views: [UIView]) {
        for view in views {
            view.transform = CGAffineTransform.identity
        }
    }
}

extension MASliderSpringAnimator: MASliderAnimating {
    
    public func openSlider(_ side: MASliderSide, sliderView: UIView, centerView: UIView, animated: Bool, complete: @escaping (_ finished: Bool) -> Void) {
        if (animated) {
            
            UIView.animate(withDuration: animationDuration,
                delay: animationDelay,
                usingSpringWithDamping: springDamping,
                initialSpringVelocity: initialSpringVelocity,
                options: UIViewAnimationOptions.curveLinear,
                animations: {
                    self.applyTransforms(side, sliderView: sliderView, centerView: centerView)
                    
                }, completion: complete)
        } else {
            self.applyTransforms(side, sliderView: sliderView, centerView: centerView)
        }
    }
    
    public func dismissSlider(_ side: MASliderSide, sliderView: UIView, centerView: UIView, animated: Bool, complete: @escaping (_ finished: Bool) -> Void) {
        if (animated) {
            UIView.animate(withDuration: animationDuration,
                delay: animationDelay,
                usingSpringWithDamping: springDamping,
                initialSpringVelocity: initialSpringVelocity,
                options: UIViewAnimationOptions.curveLinear,
                animations: {
                    self.resetTransforms([sliderView, centerView])
            }, completion: complete)
        } else {
            self.resetTransforms([sliderView, centerView])
        }
    }
    
    public func willRotateWithSliderOpen(_ side: MASliderSide, sliderView: UIView, centerView: UIView) {
        
    }
    
    public func didRotateWithSliderOpen(_ side: MASliderSide, sliderView: UIView, centerView: UIView) {
        UIView.animate(withDuration: animationDuration,
            delay: animationDelay,
            usingSpringWithDamping: springDamping,
            initialSpringVelocity: initialSpringVelocity,
            options: UIViewAnimationOptions.curveLinear,
            animations: {}, completion: nil )
    }
    
}
