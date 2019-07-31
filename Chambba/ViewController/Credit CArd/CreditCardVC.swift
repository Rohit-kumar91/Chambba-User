//
//  CreditCardVC.swift
//  Chambba
//
//  Created by Rohit Kumar on 02/04/19.
//  Copyright © 2019 Mayur chaudhary. All rights reserved.
//

import UIKit
import Stripe
import SwiftyJSON

protocol updateCards: class {
    func updateYourCards()
}

class CreditCardVC: UIViewController, STPPaymentCardTextFieldDelegate {

    
    @IBOutlet weak var cardText: UITextField!
    @IBOutlet weak var dateText: UITextField!
    @IBOutlet weak var cvvText: UITextField!
    @IBOutlet weak var addButtonOutlet: UIButton!
    
    let cardParams =  STPCardParams()
    weak var delegate: updateCards?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: 38, height: cardText.frame.height))
        cardText.leftView = paddingView
        cardText.leftViewMode = UITextFieldViewMode.always

        
    }
    
    
    @IBAction func addCardButtonAction(_ sender: UIButton) {
        
        if cardText.text == "" || dateText.text == "" || cvvText.text == "" {
            AlertController.alert(message: "Enter card details.")
        } else {
            
            let dateStr = dateText.text!.components(separatedBy: "-")
            let mm = Int(dateStr[0])
            let yyyy = Int(dateStr[1])
            
            var cardno = cardText.text!
            cardno = cardno.replacingOccurrences(of: " ", with: "")
            
            cardParams.number = cardno
            cardParams.expMonth = UInt(mm!)
            cardParams.expYear = UInt(yyyy!)
            cardParams.cvc = cvvText.text!
            
            STPAPIClient.shared().createToken(withCard: cardParams) { (token: STPToken?, error: Error?)  in
                
                guard let token = token, error == nil else {
                    // Present error to user...
                    AlertController.alert(title: appName, message: (error?.localizedDescription)!)
                    return
                }
                
                
                
                let param = [
                    "stripe_token" : token.tokenId
                ]
                
                
                ServiceHelper.sharedInstance.createPostRequest(isShowHud: true, params: param as [String : AnyObject], apiName: API_USER_CARD, completion: { (response, error) in
                    
                    if error != nil {
                        AlertController.alert(title: appName, message: (error?.description)!)
                        return
                    }
                    
                    if response != nil {
                        let response = JSON(response as Any)
                        
                        AlertController.alert(title: "Success!", message: response["message"].stringValue, buttons: ["Ok"], tapBlock: { (action, index) in
                            
                            if index == 0 {
                                self.delegate?.updateYourCards()
                                self.navigationController?.popViewController(animated: true)
                            }
                        })
                    }
                })
            }
        }
    }
    
    @IBAction func backButtonAction(_ sender: UIButton) {
       self.navigationController?.popViewController(animated: true)
    }
}

extension CreditCardVC : UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == cardText {
           dateText.becomeFirstResponder()
        } else if textField == dateText {
            cvvText.becomeFirstResponder()
        }  else {
            textField.resignFirstResponder()
        }
        
        return true
    }
    
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
       
        if textField == cardText {
            if range.location == 19 {
                return false
            }
            
            if string.length == 0 {
                return true
            }
            
            if range.location == 4 || range.location == 9 || range.location == 14 {
                let str  = String(format: "%@ ", textField.text!)
                textField.text = str
            }
            
            return true
        }
        else if textField == cvvText {
            let oldLength = textField.text?.length
            let replacementLength = string.length
            let rangeLength = range.length
            let newLength = oldLength! - rangeLength + replacementLength
            
           let returnKey = string.range(of: "\n") != nil
            return newLength <= 4 || returnKey
        }
        else if textField == dateText {
            
            let length = getLength(number: textField.text!)
            
            if length == 5 {
                if range.length == 0 {
                    return false
                }
            }
            
            
            if length == 2 {
                let num =  formatNumber(number: textField.text!)
                textField.text = String(format: "%@-", num)
                
                if range.length > 0 {
                    let indexEndOfText = num.index(num.endIndex, offsetBy: -2)
                    textField.text = String(format: "%@", String(num[..<indexEndOfText]))
                }
            }
            
            let oldLength = textField.text?.length
            let replacementLength = string.length
            let rangeLength = range.length
            
            let newLength = oldLength! - rangeLength + replacementLength
            let returnKey = string.range(of: "\n") != nil
            
            return newLength <= 5 || returnKey
        } else {
            return true
        }
        
        
        
    }
    
    
    func formatNumber( number: String) -> String {
       
        var num = number
        num = num.replacingOccurrences(of: "(", with: "")
        num = num.replacingOccurrences(of: ")", with: "")
        num = num.replacingOccurrences(of: " ", with: "")
        num = num.replacingOccurrences(of: "-", with: "")
        num = num.replacingOccurrences(of: "+", with: "")
        
        let length  =  num.length
        if length > 10 {
            let index = length - 10
            let indexStartOfText = num.index(num.startIndex, offsetBy: index)
            num = String(num[indexStartOfText...])
        }
        return num
        
    }
    
    
    
    func getLength( number: String) -> Int {
        var num = number
        num = num.replacingOccurrences(of: "(", with: "")
        num = num.replacingOccurrences(of: ")", with: "")
        num = num.replacingOccurrences(of: " ", with: "")
        num = num.replacingOccurrences(of: "-", with: "")
        num = num.replacingOccurrences(of: "+", with: "")
        
        let length = num.length
        return length
    }
    
   
    
}
