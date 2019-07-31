//
//  MASliderViewController.swift
//  CarTrade
//
//  Created by Acesoft on 09/10/15.
//  Copyright (c) 2015 Acesoft. All rights reserved.
//

import UIKit

public enum MASliderSide: CGFloat {
    case none  = 0
    case left  = 1
    case right = -1
}

open class MASliderViewController: UIViewController {
    
    let defaultDuration:TimeInterval = 0.3
    
    // MARK: Initialization
    
    override public init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }

    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override open func loadView() {
        view = sliderView
    }
    
    
    fileprivate var _sliderView: MASliderView?
    var sliderView: MASliderView {
        get {
            if let retVal = _sliderView {
                return retVal
            }
            let rect = UIScreen.main.bounds
            let retVal = MASliderView(frame: rect)
            _sliderView = retVal
            return retVal
        }
    }
    
    // TODO: Add ability to supply custom animator.
    
    fileprivate var _animator: MASliderSpringAnimator?
    open var animator: MASliderSpringAnimator {
        get {
            if let retVal = _animator {
                return retVal
            }
            let retVal = MASliderSpringAnimator()
            _animator = retVal
            return retVal
        }
    }
    
    // MARK: Interaction
    
    open func openSlider(_ side: MASliderSide, animated:Bool, complete: @escaping (_ finished: Bool) -> Void) {
        if currentlyOpenedSide != side {
            if let sideView = sliderView.viewContainerForSliderSide(side) {
                let centerView = sliderView.centerViewContainer
                if currentlyOpenedSide != .none {
                    closeSlider(side, animated: animated) { finished in
                            self.animator.openSlider(side, sliderView: sideView, centerView: centerView, animated: animated, complete: complete)
                    }
                } else {
                    self.animator.openSlider(side, sliderView: sideView, centerView: centerView, animated: animated, complete: complete)
                }
                
                addSliderGestures()
                sliderView.willOpenSlider(self)
            }
        }
        
        currentlyOpenedSide = side
    }
    
    open func closeSlider(_ side: MASliderSide, animated: Bool, complete: @escaping (_ finished: Bool) -> Void) {
        if (currentlyOpenedSide == side && currentlyOpenedSide != .none) {
            if let sideView = sliderView.viewContainerForSliderSide(side) {
                let centerView = sliderView.centerViewContainer
                animator.dismissSlider(side, sliderView: sideView, centerView: centerView, animated: animated, complete: complete)
                currentlyOpenedSide = .none
                restoreGestures()
                sliderView.willCloseSlider(self)
            }
        }
    }
    
    open func toggleSlider(_ side: MASliderSide, animated: Bool, complete: @escaping (_ finished: Bool) -> Void) {
        if side != .none {
            if side == currentlyOpenedSide {
                closeSlider(side, animated: animated, complete: complete)
            } else {
                openSlider(side, animated: animated, complete: complete)
            }
        }
    }
    
    // MARK: Gestures
    
    func addSliderGestures() {
        centerViewController?.view.isUserInteractionEnabled = false
        sliderView.centerViewContainer.addGestureRecognizer(toggleDrawerTapGestureRecognizer)
    }
    
    func restoreGestures() {
        sliderView.centerViewContainer.removeGestureRecognizer(toggleDrawerTapGestureRecognizer)
        centerViewController?.view.isUserInteractionEnabled = true
    }
    
    @objc func centerViewContainerTapped(_ sender: AnyObject) {
        closeSlider(currentlyOpenedSide, animated: true) { (finished) -> Void in
            // Do nothing
        }
    }
    
    // MARK: Helpers
    
    func viewContainer(_ side: MASliderSide) -> UIViewController? {
        switch side {
        case .left:
            return self.leftViewController
        case .right:
            return self.rightViewController
        case .none:
            return nil
        }
    }
    
    func replaceViewController(_ sourceViewController: UIViewController?, destinationViewController: UIViewController, container: UIView) {
        
        sourceViewController?.willMove(toParentViewController: nil)
        sourceViewController?.view.removeFromSuperview()
        sourceViewController?.removeFromParentViewController()
        
        self.addChildViewController(destinationViewController)
        container.addSubview(destinationViewController.view)
        
        let destinationView = destinationViewController.view
        destinationView?.translatesAutoresizingMaskIntoConstraints = false
        
        container.removeConstraints(container.constraints)
        
        let views: [String:UIView] = ["v1" : destinationView!]
        container.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[v1]|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: views))
        container.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[v1]|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: views))
        
        destinationViewController.didMove(toParentViewController: self)
    }
    
    // MARK: Private computed properties
    
    open var currentlyOpenedSide: MASliderSide = .none
    
    // MARK: Accessors
    fileprivate var _leftViewController: UIViewController?
    open var leftViewController: UIViewController? {
        get {
            return _leftViewController
        }
        set {
            self.replaceViewController(self.leftViewController, destinationViewController: newValue!, container: self.sliderView.leftViewContainer)
            _leftViewController = newValue!
        }
    }
    
    fileprivate var _rightViewController: UIViewController?
    open var rightViewController: UIViewController? {
        get {
            return _rightViewController
        }
        set {
            self.replaceViewController(self.rightViewController, destinationViewController: newValue!, container: self.sliderView.rightViewContainer)
            _rightViewController = newValue
        }
    }
    
    fileprivate var _centerViewController: UIViewController?
    open var centerViewController: UIViewController? {
        get {
            return _centerViewController
        }
        set {
            self.replaceViewController(self.centerViewController, destinationViewController: newValue!, container: self.sliderView.centerViewContainer)
            _centerViewController = newValue
        }
    }
    
    fileprivate lazy var toggleDrawerTapGestureRecognizer: UITapGestureRecognizer = {
        [unowned self] in
        let gesture = UITapGestureRecognizer(target: self, action: #selector(MASliderViewController.centerViewContainerTapped(_:)))
        return gesture
    }()
    
    open var leftDrawerWidth: CGFloat {
        get  {
            return sliderView.leftViewContainerWidth
        }
        set {
            sliderView.leftViewContainerWidth = newValue
        }
    }
    
    open var rightDrawerWidth: CGFloat {
        get {
            return sliderView.rightViewContainerWidth
        }
        set {
            sliderView.rightViewContainerWidth = newValue
        }
    }
    
    open var leftDrawerRevealWidth: CGFloat {
        get {
            return sliderView.leftViewContainerWidth
        }
    }
    
    open var rightDrawerRevealWidth: CGFloat {
        get {
            return sliderView.rightViewContainerWidth
        }
    }
    
    open var backgroundImage: UIImage? {
        get {
            return sliderView.backgroundImageView.image
        }
        set {
            sliderView.backgroundImageView.image = newValue
        }
    }
    
    // MARK: Status Bar
    
    override open var childViewControllerForStatusBarHidden : UIViewController? {
        return centerViewController
    }
    
    override open var childViewControllerForStatusBarStyle : UIViewController? {
        return centerViewController
    }
    
    // MARK: Memory Management
    
    override open func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
}


extension UIViewController {
    func toggleSlider() {
        
        APPDELEGATE.sideMenuController.toggleSlider(.left, animated: true, complete: { (_) in
            
        })
    }
}
