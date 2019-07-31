//
//  ChangePasswordVC.swift
//  Chambba
//
//  Created by Mayur chaudhary on 22/02/19.
//  Copyright © 2019 Mayur chaudhary. All rights reserved.
//

import UIKit

class ChangePasswordVC: UIViewController {

    @IBOutlet weak var changePasswordTableView: UITableView!
    @IBOutlet weak var saveBtn: UIButton!
    @IBOutlet weak var backBtn: UIButton!
    
    var userObj = UserInfo()
    var imageArray = [#imageLiteral(resourceName: "passwordIcon"),#imageLiteral(resourceName: "passwordIcon"),#imageLiteral(resourceName: "passwordIcon")]
    var placeholderArray = ["Old password","New password","Confirm password"]
    
    //MARK:- UIViewController Life Cycle Method
    override func viewDidLoad() {
        super.viewDidLoad()
        changePasswordTableView.aroundShadow()
        saveBtn.shadowAtBottom(red: 253, green: 234, blue: 64)
    }

    //MARK:- Memory Warning Method
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    //MARK:- IBACtion Method
    @IBAction func commonBtnAction(_ sender: UIButton) {
        self.view.endEditing(true)
        switch sender.tag {
        case 100:                   // Back Btn
            self.navigationController?.popViewController(animated: true)
            break
        case 101:                   // Save Btn
            if isAllFieldVerified(){
                 changePassword() 
            }
            break
        default:
            break
        }
    }
    
    //MARK:- Validation Method
    func isAllFieldVerified() -> Bool{
        if userObj.password.trimWhiteSpace.count == 0{
            userObj.errorString = blankPassword
        }else if userObj.password.trimWhiteSpace.length < 6 {
            userObj.errorString = inValidPassword
        }else if userObj.newPassword.trimWhiteSpace.count == 0{
            userObj.errorString = blankPassword
        }else if userObj.newPassword.trimWhiteSpace.length < 6 {
            userObj.errorString = inValidPassword
        }else if userObj.confirmPassword != userObj.newPassword{
            userObj.errorString = passwordNotMatch
        }else{
            userObj.errorString = ""
            return true
        }
        AlertController.alert(title: "", message: userObj.errorString, buttons: ["OK"]) { (UIAlertAction, index) in
        }
        changePasswordTableView.reloadData()
        return false
    }
    
    
    func changePassword() {
        let paramDic = ["old_password" :userObj.password, "password": userObj.newPassword, "password_confirmation": userObj.confirmPassword]
        ServiceHelper.sharedInstance.createPostRequest(isShowHud: true, params: paramDic as [String : AnyObject], apiName: API_ChangePasword) { (response, error) in
            
            if error != nil {
                AlertController.alert(title: appName, message: (error?.description)!)
                return
            }
            
            if response != nil {
                let result = response as! Dictionary<String, AnyObject>
                let message = result.validatedValue("message", expected: "" as AnyObject) as! String
                let errormessage = result.validatedValue("error", expected: "" as AnyObject) as! String
                let finalMessage: String?
                var errorBool: Bool?
                if message != "" {
                    finalMessage = message
                    errorBool = false
                } else {
                    finalMessage = errormessage
                    errorBool = true
                }
                
                AlertController.alert(title: appName, message: finalMessage!, acceptMessage: "Ok", acceptBlock: {
                    if !errorBool! {
                        self.navigationController?.popViewController(animated: true)
                    }
                })
            }
        }
    }
}


extension ChangePasswordVC : UITableViewDelegate , UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return imageArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CommonCell", for: indexPath) as! CommonCell
        cell.staticImg.image = imageArray[indexPath.row]
        cell.passwordShowBtn.isHidden = false
        cell.textField.isSecureTextEntry = true
        cell.textField.attributedPlaceholder = attributedPlaceholder(string: placeholderArray[indexPath.row])
        cell.textField.tag = indexPath.row + 1000
        cell.passwordShowBtn.tag = indexPath.row + 2000
        cell.textField.keyboardType = .default
        cell.textField.returnKeyType = .next
        cell.passwordShowBtn.addTarget(self, action: #selector(showPasswordBtn(_:)), for: .touchUpInside)
        switch indexPath.row {
        case 0:
            cell.textField.text = userObj.password
            break
        case 1:
            cell.textField.text = userObj.newPassword
            break
        case 2:
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
        let cell = self.changePasswordTableView.cellForRow(at: IndexPath.init(row: sender.tag - 2000 , section: 0)) as! CommonCell
        if sender.isSelected {
            cell.textField.isSecureTextEntry = false
        }else {
            cell.textField.isSecureTextEntry = true
        }
    }
    
}
extension ChangePasswordVC : UITextFieldDelegate {
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        switch textField.tag {
        case 1000:
            userObj.password = (textField.text?.trimWhiteSpace)!
            break
        case 1001:
            userObj.newPassword = (textField.text?.trimWhiteSpace)!
            break
        case 1002:
            userObj.confirmPassword = (textField.text?.trimWhiteSpace)!
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
