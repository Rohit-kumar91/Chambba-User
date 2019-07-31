//
//  OtpVC.swift
//  Chambba
//
//  Created by Rohit Kumar on 27/02/19.
//  Copyright © 2019 Mayur chaudhary. All rights reserved.
//

import UIKit

class OtpVC: UIViewController {

    var imageArray = [#imageLiteral(resourceName: "userIcon"),#imageLiteral(resourceName: "passwordIcon"),#imageLiteral(resourceName: "passwordIcon"),#imageLiteral(resourceName: "passwordIcon")]
    var placeholderArray = ["Email id","Enter OTP","New Password","Confirm Password"]
    
    var userObj = UserInfo()
    var userID = String()
    var emailAddress = String()
    var strOTP = String()
    
    @IBOutlet weak var forgotPasswordTableview: UITableView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        userObj.email = emailAddress
        

        // Do any additional setup after loading the view.
    }
    
    
    @IBAction func commonButtonAction(_ sender: UIButton) {
        self.view.endEditing(true)
        switch sender.tag {
        case 100:                   // Back Btn
            self.navigationController?.popViewController(animated: true)
            break
        case 101: // change password btn
            
            if isAllFieldVerified() {
                resetPassword()
            }
 
            break
       
        default:
            break
            
        }
    }
    
    //MARK:- Validation Method
    func isAllFieldVerified() -> Bool{
        
        print("User OTP", userObj.otp)
        print("strOTP", strOTP)
        
        if userObj.email.trimWhiteSpace.count == 0 {
            userObj.errorString = blankEmailAddress
        } else if !userObj.email.isEmail {
            userObj.errorString = inValidEmailAddress
        } else if userObj.otp.trimWhiteSpace.count == 0{
            userObj.errorString = blankOtp
        } else if userObj.otp != strOTP {
            userObj.errorString = wrongOtp
        }else if userObj.password.trimWhiteSpace.count == 0{
            userObj.errorString = blankPassword
        }else if userObj.password.trimWhiteSpace.length < 6 {
            userObj.errorString = inValidPassword
        }else if userObj.confirmPassword != userObj.password{
            userObj.errorString = passwordNotMatch
        }else{
            userObj.errorString = ""
            return true
        }
        AlertController.alert(title: "", message: userObj.errorString, buttons: ["OK"]) { (UIAlertAction, index) in
        }
        forgotPasswordTableview.reloadData()
        return false
    }
    
    
    func resetPassword() {
        
        let param = [
            "email" : userObj.email,
            "password" : userObj.password,
            "password_confirmation" : userObj.confirmPassword,
            "id" : userID
        ]
        
        ServiceHelper.sharedInstance.createPostRequest(isShowHud: true, params: param as [String : AnyObject], apiName: API_RESETPASSWORD) { (response, error) in
            if error != nil {
                AlertController.alert(title: appName, message: (error?.description)!)
                return
            }
            
            if response != nil {
                let result = response as! Dictionary<String, AnyObject>
                print(result)
                
                let message = result.validatedValue("message", expected: "" as AnyObject) as! String
                
                AlertController.alert(title: appName, message: message, acceptMessage: "Ok", acceptBlock: {
                    self.navigationController?.viewControllers.remove(at: 2)
                    self.navigationController?.popViewController(animated: true)
                })
                
            }
        }
        
    }
    
}

extension OtpVC : UITableViewDelegate , UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return imageArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "CommonCell", for: indexPath) as! CommonCell
        cell.staticImg.image = imageArray[indexPath.row]
        cell.passwordShowBtn.isHidden = indexPath.row == 2 || indexPath.row == 3 ? false : true
        cell.textField.isSecureTextEntry =  indexPath.row == 2 || indexPath.row == 3 ? true : false
        cell.textField.attributedPlaceholder = attributedPlaceholder(string: placeholderArray[indexPath.row])
        cell.textField.tag = indexPath.row + 1000
        cell.passwordShowBtn.tag = indexPath.row + 2000
        cell.textField.keyboardType = .default
        cell.textField.returnKeyType = .next
        cell.passwordShowBtn.addTarget(self, action: #selector(showPasswordBtn(_:)), for: .touchUpInside)
        switch indexPath.row {
        case 0:
            cell.textField.isUserInteractionEnabled = false
            cell.textField.keyboardType = .emailAddress
            cell.textField.text = userObj.email
            cell.textField.returnKeyType = .next
            break
            
        case 1:
            cell.textField.text = userObj.otp
            break
            
        case 2:
            cell.textField.text = userObj.password
            break
            
        case 3:
            cell.textField.text = userObj.confirmPassword
            cell.textField.returnKeyType = .done
            break
        
        default:
            break
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }
    
    @objc func showPasswordBtn(_ sender : UIButton){
        sender.isSelected = !sender.isSelected
        let cell = self.forgotPasswordTableview.cellForRow(at: IndexPath.init(row: sender.tag - 2000 , section: 0)) as! CommonCell
        if sender.isSelected {
            cell.textField.isSecureTextEntry = false
        }else {
            cell.textField.isSecureTextEntry = true
        }
    }
}

extension OtpVC : UITextFieldDelegate {
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        switch textField.tag {
        case 1000:
            self.userObj.email = (textField.text?.trimWhiteSpace)!
            break
        case 1001:
            self.userObj.otp = (textField.text?.trimWhiteSpace)!
            break
        case 1002:
            self.userObj.password = (textField.text?.trimWhiteSpace)!
            break
        case 1003:
            self.userObj.confirmPassword = (textField.text?.trimWhiteSpace)!
            break
        
        default:
            break
        }
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
