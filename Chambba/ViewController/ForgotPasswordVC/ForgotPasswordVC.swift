//
//  ForgotPasswordVC.swift
//  Chambba
//
//  Created by Mayur chaudhary on 29/01/19.
//  Copyright © 2019 Mayur chaudhary. All rights reserved.
//

import UIKit

class ForgotPasswordVC: UIViewController {

    @IBOutlet weak var staticForgotPasswordLabel: UILabel!
    @IBOutlet weak var staticTextLabel: UILabel!
    @IBOutlet weak var forgotPasswordTableView: UITableView!
    @IBOutlet weak var resendEmailBtn: UIButton!
    @IBOutlet weak var sendBtn: UIButton!
    @IBOutlet weak var backBtn: UIButton!
    
    var userObj = UserInfo()
    
    //MARK:- UIViewController Life Cycle Method
    override func viewDidLoad() {
        super.viewDidLoad()
        customInit()
    }
    
    func customInit(){
        forgotPasswordTableView.aroundShadow()
        sendBtn.shadowAtBottom(red: 255, green: 235, blue: 2)
    }

    //MARK:- Memory Warning Method
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func commonBtnAction(_ sender: UIButton) {
        self.view.endEditing(true)
        switch sender.tag {
        case 100:                   // Back Btn
            self.navigationController?.popViewController(animated: true)
            break
        case 101:                   // Send Btn
            if isAllFieldVerified(){
                forgotPassword()
            }
            break
        case 102:                   // Resend Email Btn
            if isAllFieldVerified(){
                forgotPassword()
            }
            break
        default:
            break
            
        }
    }
    
    //MARK:- Valdiation Method
    func isAllFieldVerified() -> Bool{
        if userObj.email.trimWhiteSpace.count == 0{
            userObj.errorString = blankEmailAddress
        } else if !userObj.email.isEmail {
           userObj.errorString = inValidEmailAddress
        }else{
            userObj.errorString = ""
            return true
        }
        AlertController.alert(title: "", message: userObj.errorString, buttons: ["OK"]) { (UIAlertAction, index) in
        }
        forgotPasswordTableView.reloadData()
        return false
    }
    
    //MARK:- Forgot Password Method
    func forgotPassword() {
        
        let param = ["email" : userObj.email]
        
        ServiceHelper.sharedInstance.createPostRequest(isShowHud: true, params: param as [String : AnyObject], apiName: API_ForgotPassword) { (response, error) in
            if error != nil {
                AlertController.alert(title: appName, message: (error?.description)!)
                return
            }
            
            if response != nil {

                let result = response as! Dictionary<String, AnyObject>
                let message = result.validatedValue("message", expected: "" as AnyObject) as! String
                if let result = response!["email"] as? [String] {
                    if result.count > 0 {
                        if result[0] == "The selected email is invalid." {
                            AlertController.alert(title: appName, message: "The selected email is invalid.")
                        }
                    }
                }else{
                    let otpVC =  mainStoryboard.instantiateViewController(withIdentifier: "OtpVC") as! OtpVC
                    
                    let userResponse = result["user"] as! Dictionary<String, AnyObject>
                    let emailAddressStr = userResponse.validatedValue("email", expected: "" as AnyObject) as! String
                    let idStr = userResponse.validatedValue("id", expected: "" as AnyObject) as! String
                    let strOtp = userResponse.validatedValue("otp", expected: "" as AnyObject) as! String
                    
                    print(strOtp)

                    otpVC.userID = idStr
                    otpVC.emailAddress = emailAddressStr
                    otpVC.strOTP = strOtp

                    self.navigationController?.pushViewController(otpVC, animated: true)
                    AlertController.alert(title: appName, message: message)
                }
            }
        }
    }
    
}

extension ForgotPasswordVC : UITableViewDelegate , UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CommonCell", for: indexPath) as! CommonCell
        cell.staticImg.image = #imageLiteral(resourceName: "emailIcon")
        cell.textField.attributedPlaceholder = attributedPlaceholder(string: "Email Address")
        cell.textField.tag = 1000
        cell.textField.keyboardType = .emailAddress
        cell.textField.returnKeyType = .done
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }
    
}

extension ForgotPasswordVC : UITextFieldDelegate {
    
    func textFieldDidEndEditing(_ textField: UITextField) {
            self.userObj.email = (textField.text?.trimWhiteSpace)!
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if (textField.textInputMode?.primaryLanguage == "emoji") || !((textField.textInputMode?.primaryLanguage) != nil) {
            return false
        }
        var str:NSString = textField.text! as NSString
        str = str.replacingCharacters(in: range, with: string) as NSString
        if string.isEqual("") == true || str.length <= 64 {
            return true
        } else {
            return false
        }
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField.returnKeyType == .next {
            let tf: UITextField? = (view.viewWithTag(textField.tag + 1) as? UITextField)
            tf?.becomeFirstResponder()
        }
        else {
            view.endEditing(true)
        }
        return true
    }
}
