//
//  CouponVC.swift
//  Chambba
//
//  Created by Rohit Kumar on 26/02/19.
//  Copyright © 2019 Mayur chaudhary. All rights reserved.
//

import UIKit

class CouponVC: UIViewController {

    
    
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var applyButton: UIButton!
    @IBOutlet weak var couponCodeTextfield: UITextField!
    @IBOutlet weak var outerUpperView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        customInit()
    }
    
    func customInit() {
        
        outerUpperView.layer.borderWidth = 1
        outerUpperView.layer.borderColor = UIColor.lightGray.cgColor
        outerUpperView.layer.shadowColor = UIColor.lightGray.cgColor
        outerUpperView.layer.shadowOpacity = 0.9
        outerUpperView.layer.shadowRadius = 5
        outerUpperView.layer.shadowOffset = CGSize(width: 4.0, height: 4.0)
        
    }
    
    
    

    
    @IBAction func commonButtonAction(_ sender: UIButton) {
        switch sender.tag {
        case 100: // Back Btn
            self.navigationController?.popViewController(animated: true)
            break
        case 101: // Apply Btn
            break
        default:
            break
        }
    }

}
