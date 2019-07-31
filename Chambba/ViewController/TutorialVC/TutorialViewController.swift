//
//  TutorialViewController.swift
//  KawafilShipper
//
//  Created by Mayur chaudhary on 08/06/18.
//  Copyright © 2018 Ashish Kumar singh. All rights reserved.
//

import UIKit

class TutorialViewController: UIViewController, UIPageViewControllerDelegate,VSDropdownDelegate {
    
    @IBOutlet weak var languageBtn: UIButton!
    @IBOutlet weak var welcomeStaticLabel: UILabel!
    @IBOutlet weak var staticTextLabel: UILabel!
    @IBOutlet weak var tutorialPageControl: UIPageControl!
    @IBOutlet weak var tutorialImageView: UIImageView!
    
    @IBOutlet weak var pageView: UIView!
    @IBOutlet weak var signInBtn: UIButton!
    @IBOutlet weak var signUpBtn: UIButton!

    var  pageIndex : Int = 0
    var timer = Timer()
    let images: [UIImage] = [
        UIImage(named: "welcomeIcon")!,
        UIImage(named: "welcomeIcon")!,
        UIImage(named: "welcomeIcon")!
    ]
    var _dropdown = VSDropdown()

    //MARK:- UIView Life Cycle Method
    override func viewDidLoad() {
        super.viewDidLoad()
        helperMethod()
        
    }
    
   
    
    //MARK:- Helper Method
    func helperMethod()    {
        tutorialPageControl.numberOfPages = 3
        tutorialPageControl.currentPage = images.count
        //swipe gesture
        let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(self.respondToSwipeGesture))
        swipeRight.direction = UISwipeGestureRecognizerDirection.right
        self.view.addGestureRecognizer(swipeRight)
        
        tutorialPageControl.currentPage = 0
        tutorialImageView.image = images[0]
        
        let swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(self.respondToSwipeGesture))
        swipeLeft.direction = UISwipeGestureRecognizerDirection.left
        self.view.addGestureRecognizer(swipeLeft)
        tutorialPageControl.addTarget(self, action: #selector(TutorialViewController.pagebuttonAction(_:)), for: .valueChanged)
        
        _dropdown = VSDropdown(delegate: self)
        _dropdown.adoptParentTheme = true
        _dropdown.shouldSortItems = true
        
        signInBtn.shadowAtBottom(red: 255, green: 235, blue: 2)
        signUpBtn.shadowAtBottom()

        
    }
    
    
    //MARK:- SwipeGesture Method
    @objc func pagebuttonAction( _ sender : UIPageControl) {
        if self.tutorialPageControl.currentPage < self.pageIndex  {
            self.swapRight()
        } else {
           self.swapLeft()
        }
    }
    
    @objc func respondToSwipeGesture(gesture: UIGestureRecognizer) {
        if let swipeGesture = gesture as? UISwipeGestureRecognizer {
            switch swipeGesture.direction {
            case UISwipeGestureRecognizerDirection.right:
              self.swapRight()
                break
            case UISwipeGestureRecognizerDirection.left:
               self.swapLeft()
                break
            default:
                break
            }
            
        }
    }
    
    func swapRight() {
        if pageIndex<=images.count-1 && pageIndex != 0{
            pageIndex-=1
            self.tutorialPageControl.currentPage = self.pageIndex
            self.tutorialImageView.image = images[pageIndex]
            let transition = CATransition()
            transition.duration = 0.5
            transition.type = kCATransitionPush
            transition.subtype = kCATransitionFromLeft
            transition.timingFunction = CAMediaTimingFunction.init(name: kCAMediaTimingFunctionEaseInEaseOut)
            self.tutorialImageView.layer.add(transition, forKey:"SwitchToView")
        }
    }
    
    func swapLeft() {
        if pageIndex<images.count-1 && pageIndex != 3{
            pageIndex+=1
            self.tutorialPageControl.currentPage = self.pageIndex
            self.tutorialImageView.image = images[pageIndex]
            let transition = CATransition()
            transition.duration = 0.5
            transition.type = kCATransitionPush
            transition.subtype = kCATransitionFromRight
            transition.timingFunction = CAMediaTimingFunction.init(name: kCAMediaTimingFunctionEaseInEaseOut)
            self.tutorialImageView.layer.add(transition, forKey:"SwitchToView")
        }
    }
    
    //MARK:- IBAction Method
    @IBAction func commonBtnAction(_ sender : UIButton){
        switch sender.tag {
        case 100:                   // Language Btn
            showDropDown(for: sender, adContents: ["English","Spanish"], multipleSelection: false)
            break
        case 101:                   // Sign In Btn
            let loginVC = mainStoryboard.instantiateViewController(withIdentifier: "LoginVC") as! LoginVC
            self.navigationController?.pushViewController(loginVC, animated: true)
            break
        case 102:                   // Sign Up Btn
            let signUpVC = mainStoryboard.instantiateViewController(withIdentifier: "SignUpVC") as! SignUpVC
            self.navigationController?.pushViewController(signUpVC, animated: true)
            break
        case 103:                   // Social Login Btn
            
            let socialSignUpVC = mainStoryboard.instantiateViewController(withIdentifier: "SocialSignUpVC") as! SocialSignUpVC
            self.navigationController?.pushViewController(socialSignUpVC, animated: true)
            break
        default:
            break
        }
    }
    
    // MARK: - VSDropdown Delegate methods.
    func dropdown(_ dropDown: VSDropdown!, didChangeSelectionForValue str: String!, at index: UInt, selected: Bool) {
        if index == 0 {
            languageBtn.setTitle("English", for: .normal)
        }else {
            languageBtn.setTitle("Spanish", for: .normal)
        }
    
    }
    
    func outlineColor(for dropdown: VSDropdown) -> UIColor {
        let btn: UIButton? = (dropdown.dropDownView as? UIButton)
        return (btn?.titleLabel?.textColor!)!
    }
    
    func outlineWidth(for dropdown: VSDropdown) -> CGFloat {
        return 1.0
    }
    
    func cornerRadius(for dropdown: VSDropdown) -> CGFloat {
        return 1.0
    }
    
    func offset(for dropdown: VSDropdown) -> CGFloat {
        return -2.0
    }
    
    @objc func showDropViewForLanguage(_ sender: UIButton) {
        showDropDown(for: sender, adContents: ["English","Spanish"], multipleSelection: false)
        
    }
    
    
    func showDropDown(for sender: UIButton, adContents contents: [Any], multipleSelection: Bool) {
        _dropdown.drodownAnimation = DropdownAnimation(rawValue: UInt(arc4random()))!
        _dropdown.allowMultipleSelection = multipleSelection
        _dropdown.setupDropdown(for: sender)
        _dropdown.separatorColor = sender.titleLabel?.textColor
        
        if _dropdown.allowMultipleSelection {
            _dropdown.reload(withContents: contents, andSelectedItems: sender.title(for: .normal)?.components(separatedBy: ";"))
        }
        else{
            _dropdown.reload(withContents: contents, andSelectedItems: [sender.title(for: .normal) ?? "hel"])
            
        }
        
    }
    //MARK:- Memory Warning Method
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}



