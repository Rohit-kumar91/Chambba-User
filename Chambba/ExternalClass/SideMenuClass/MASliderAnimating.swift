//
//  MASliderAnimating.swift
//  CarTrade
//
//  Created by Acesoft on 09/10/15.
//  Copyright (c) 2015 Acesoft. All rights reserved.
//

//import Foundation
import UIKit

public protocol MASliderAnimating {
    
    func openSlider(_ side: MASliderSide, sliderView: UIView, centerView: UIView, animated: Bool, complete: @escaping (_ finished: Bool) -> Void)
    
    func dismissSlider(_ side: MASliderSide, sliderView: UIView, centerView: UIView, animated: Bool, complete: @escaping (_ finished: Bool) -> Void)
    
    
    /**
    *  Called prior to a rotation event, while a slider view is being shown.
    *
    *  @param side The currently open slider side
    *  @param the containing side view that is shown.
    *  @param the containing centre view.
    */
    func willRotateWithSliderOpen(_ side: MASliderSide, sliderView: UIView, centerView: UIView)
    
    /**
    *  Called following a rotation event, while a slider view is being shown.
    *
    *  @param side The currently open slider side
    *  @param the containing side view that is shown.
    *  @param the containing centre view.
    *  @param a complete block handler to handle cleanup.
    */
    func didRotateWithSliderOpen(_ side: MASliderSide, sliderView: UIView, centerView: UIView)
    
}
