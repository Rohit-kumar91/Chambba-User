//
//  HistoryVC.swift
//  Chambba
//
//  Created by Rohit Kumar on 18/03/19.
//  Copyright © 2019 Mayur chaudhary. All rights reserved.
//

import UIKit
import SwiftyJSON
import HCSStarRatingView

class HistoryVC: UIViewController {

    var histroyHintStr = String()
    var request_idStr = String()
    var serviceUrl = String()
    var id_Str = String()
    var phoneNumber = String()

    
    @IBOutlet weak var mapImageView: UIImageView!
    @IBOutlet weak var bookingIdLbl: UILabel!
    @IBOutlet weak var nameLbl: UILabel!
    @IBOutlet weak var dateLbl: UILabel!
    @IBOutlet weak var ratingUser: HCSStarRatingView!
    @IBOutlet weak var timeLbl: UILabel!
    @IBOutlet weak var userImg: UIImageView!
    @IBOutlet weak var pcikLbl: UILabel!
    @IBOutlet weak var dropLbl: UILabel!
    @IBOutlet weak var payTypeLbl: UILabel!
    @IBOutlet weak var cashLbl: UILabel!
    @IBOutlet weak var comment: UITextView!
    @IBOutlet weak var callBtn: UIButton!
    @IBOutlet weak var cancelBtn: UIButton!
    @IBOutlet weak var viewReciptBtn: UIButton!
    @IBOutlet weak var viewReciptBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var baseFareLbl: UILabel!
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var taxLabel: UILabel!
    @IBOutlet weak var walletDeduction: UILabel!
    @IBOutlet weak var discount: UILabel!
    @IBOutlet weak var totalLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        getHistoryDetails()
        self.viewReciptBtn.isHidden = true
    }
    
    func getHistoryDetails() {
        
        if histroyHintStr == "PAST" {
            serviceUrl = API_HISTORY_DETAILS
            
             self.callBtn.isHidden = true
             self.cancelBtn.isHidden = true
            
        } else {
            serviceUrl = API_UPCOMING_HISTORY_DETAILS
            
            self.callBtn.isHidden = false
            self.cancelBtn.isHidden = false
        }
        
        let param = [
            "request_id" : request_idStr
        ]
        
        print(param)
        
        ServiceHelper.sharedInstance.createGetRequest(isShowHud: true, params: param as [String : AnyObject], apiName: serviceUrl) { (response, error) in
            if error != nil {
                AlertController.alert(title: appName, message: (error?.description)!)
                return
            }
            
            if response != nil {
                let result = JSON(response as Any).arrayValue
                print("Result", result)
                
                if result.count != 0 {
                    
                    let dictVal = result[0]
                    self.id_Str = dictVal["id"].stringValue
                    
                    let imageUrlStr = dictVal["static_map"].stringValue
                    let refineStr = imageUrlStr.replacingOccurrences(of: "%7C", with: "|")
                    let urlwithPercentEscapes = refineStr.addingPercentEncoding( withAllowedCharacters: .urlQueryAllowed)
                    self.mapImageView.sd_setImage(with: URL(string: urlwithPercentEscapes ?? ""), placeholderImage: #imageLiteral(resourceName: "rd-map"))
                    
                    self.userImg.sd_setImage(with: URL(string: BASE_URL + "storage/app/public/" + dictVal["provider"]["avatar"].stringValue), placeholderImage: #imageLiteral(resourceName: "userProfileIcon"))
                    
                    self.bookingIdLbl.text = dictVal["booking_id"].stringValue
                    self.dropLbl.text = dictVal["d_address"].stringValue
                    self.pcikLbl.text = dictVal["s_address"].stringValue
                    self.nameLbl.text = dictVal["provider"]["first_name"].stringValue
                    self.payTypeLbl.text = dictVal["payment_mode"].stringValue
                    self.distanceLabel.text = dictVal["payment"]["distance"].stringValue
                    self.phoneNumber = dictVal["provider"]["mobile"].stringValue
                    
                    if let currencySymbol = UserDefaults.standard.value(forKey: "currency") as? String {
                        self.walletDeduction.text = currencySymbol + ""
                        self.discount.text =  currencySymbol + " " + dictVal["payment"]["discount"].stringValue
                        self.totalLabel.text =  currencySymbol + " " + dictVal["payment"]["total"].stringValue
                        self.baseFareLbl.text =  currencySymbol + " " + dictVal["payment"]["fixed"].stringValue
                        self.taxLabel.text = currencySymbol + " " + dictVal["payment"]["tax"].stringValue
                    }
                    
                    
                    self.ratingUser.value = CGFloat(dictVal["rating"]["user_rating"].intValue)
                     self.comment.text = dictVal["rating"]["user_comment"].stringValue
                    
                    if self.histroyHintStr == "PAST" {
                        
                        if let currencySymbol = UserDefaults.standard.value(forKey: "currency") as? String {
                            self.cashLbl.text =  currencySymbol + dictVal["payment"]["total"].stringValue
                            
                            let stringStr =  dictVal["started_at"].stringValue
                            let strArr = stringStr.components(separatedBy: " ")
                            
                            self.dateLbl.text = strArr[0]
                            self.timeLbl.text = strArr[1]
                        }
                        

                    
                    } else {
                        
                        if let currencySymbol = UserDefaults.standard.value(forKey: "currency") as? String {
                            self.cashLbl.text = currencySymbol + "0.0"
                            let stringStr =  dictVal["created_at"].stringValue
                            let strArr = stringStr.components(separatedBy: " ")
                            
                            self.dateLbl.text = strArr[0]
                            self.timeLbl.text = strArr[1]
                        }
                        
                        self.callBtn.isHidden = false
                        self.cancelBtn.isHidden = false
                        self.viewReciptBtn.isHidden = true
                    }
                }
            }
        }
    }
    
    @IBAction func viewReciptBtnAction(_ sender: UIButton) {
        viewReciptBottomConstraint.constant = 0
        UIView.animate(withDuration: 0.45) {
            self.view.layoutIfNeeded()
        }
    }
    
    @IBAction func cancelBtnAction(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    
    @IBAction func backButtonWasTapped(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func callBtnAction(_ sender: UIButton) {
        if phoneNumber == "" {
            if let phoneCallURL = URL(string: "tel://\(phoneNumber)") {
                
                let application:UIApplication = UIApplication.shared
                if (application.canOpenURL(phoneCallURL)) {
                    application.open(phoneCallURL, options: [:], completionHandler: nil)
                }
            }
        } else {
            AlertController.alert(message: "Driver was not provided the number to call.")
        }
    }
    
    
    @IBAction func tapgestureAction(_ sender: UITapGestureRecognizer) {
//        viewReciptBottomConstraint.constant = -300
//        UIView.animate(withDuration: 0.45) {
//            self.view.layoutIfNeeded()
//        }
    }
}
