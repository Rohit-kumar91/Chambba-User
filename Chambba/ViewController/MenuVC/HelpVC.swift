//
//  HelpVC.swift
//  Chambba
//
//  Created by Mayur chaudhary on 22/02/19.
//  Copyright © 2019 Mayur chaudhary. All rights reserved.
//

import UIKit
import MessageUI

class HelpVC: UIViewController, MFMailComposeViewControllerDelegate {

    @IBOutlet weak var webBtn: UIButton!
    @IBOutlet weak var mailBtn: UIButton!
    @IBOutlet weak var callBtn: UIButton!
    @IBOutlet weak var staticTextLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var backBtn: UIButton!
    
    //MARK:- UIViewController Life Cycle Method
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    //MARK:- Memory Warning Method
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    //MARK:- IBAction Method
    @IBAction func commonBtnAction(_ sender: UIButton) {
        switch sender.tag {
            
        case 100:           // Back Btn
            self.navigationController?.popViewController(animated: true)
            break
            
        case 101:           // Call Btn
            if let url = URL(string: "tel://\(999999999)"), UIApplication.shared.canOpenURL(url) {
                if #available(iOS 10, *) {
                    UIApplication.shared.open(url)
                }
                else{
                    AlertController.alert(title: "", message: "Call service not available")
                }
            }
            break
            
            
        case 102:           // mail Btn
            let emailTitle = "Feedback"
            let messageBody = "Feature request or bug report?"
            let toRecipents = ["test@test.com"]
            
            if MFMailComposeViewController.canSendMail(){
                
                let mc: MFMailComposeViewController = MFMailComposeViewController()
                mc.mailComposeDelegate = self
                mc.setSubject(emailTitle)
                mc.setMessageBody(messageBody, isHTML: false)
                mc.setToRecipients(toRecipents)
                self.present(mc, animated: true, completion: nil)
                
            } else {
                // show failure alert
                AlertController.alert(title: "", message: "Mail Composer not available")
            }
            break
            
        case 103:               // Web Btn
            
            if let url = URL(string: "www.google.com"), UIApplication.shared.canOpenURL(url) {
                if #available(iOS 10.0, *) {
                    UIApplication.shared.open(url, options: [:], completionHandler: nil)
                } else {
                    UIApplication.shared.openURL(url)
                }
            }
            break
            
        default:
            break
        }
    }
    
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        switch result {
        case .cancelled:
            print("Mail cancelled")
            break
        case .saved:
            print("Mail saved")
            break
        case .sent:
            print("Mail sent")
            break
        case .failed:
            print("Mail sent failure: \(String(describing: error?.localizedDescription))")
            break
        default:
            break
        }
        controller.dismiss(animated: true, completion: nil)
    }

}
