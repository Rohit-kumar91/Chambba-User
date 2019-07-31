//
//  LoginVC.swift
//  Chambba
//
//  Created by Mayur chaudhary on 28/01/19.
//  Copyright © 2019 Mayur chaudhary. All rights reserved.
//

import UIKit
import SwiftyJSON

class LoginVC: UIViewController {

    @IBOutlet weak var forgotPasswordBtn: UIButton!
    @IBOutlet weak var loginTableView: UITableView!
    @IBOutlet weak var singUpBtn: UIButton!
    @IBOutlet weak var signInBtn: UIButton!
    @IBOutlet weak var backBtn: UIButton!
    
    var imageArray = [#imageLiteral(resourceName: "userIcon"),#imageLiteral(resourceName: "passwordIcon")]
    var placeHolderArray = ["Email Address","Password"]
    var userObj = UserInfo()
    
    //MARK:- UIViewController Life Cycle Method
    override func viewDidLoad() {
        super.viewDidLoad()
        customInit()
        
        print(UserDefaults.standard.value(forKey: DEVICE_TOKEN))
        

    }
    
    //MARK:- Helper Method
    func customInit(){
        loginTableView.aroundShadow()
        singUpBtn.shadowAtBottom(red: 253, green: 234, blue: 64)
        singUpBtn.setTitle(NSLocalizedString("SIGN IN", comment: ""), for: .normal)
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
        case 101:                   // SignUp Btn
            if isAllFieldVerified(){
            self.loginAPI()
            }
            break
        case 102:                   // SignIn Btn
            let signUPVC = mainStoryboard.instantiateViewController(withIdentifier: "SignUpVC") as! SignUpVC
            self.navigationController?.pushViewController(signUPVC, animated: true)
            break
        case 103:                   // Forgotpassword Btn
            let forgotPasswordVC = mainStoryboard.instantiateViewController(withIdentifier: "ForgotPasswordVC") as! ForgotPasswordVC
            self.navigationController?.pushViewController(forgotPasswordVC, animated: true)
            break
        default:
            break
        }
    }
    
    //MARK:- Validation Method
    func isAllFieldVerified() -> Bool{
        if userObj.email.trimWhiteSpace.count == 0{
            userObj.errorString = blankEmailAddress
        } else if !userObj.email.isEmail {
            userObj.errorString = inValidEmailAddress
        }else if userObj.password.trimWhiteSpace.count == 0{
            userObj.errorString = blankPassword
        }else if userObj.password.trimWhiteSpace.length < 6 {
            userObj.errorString = inValidPassword
        }else{
            userObj.errorString = ""
            return true
        }
        AlertController.alert(title: "", message: userObj.errorString, buttons: ["OK"]) { (UIAlertAction, index) in
        }
        loginTableView.reloadData()
        return false
    }
    
    func loginAPI(){
        let paramDic = ["username" :userObj.email,"password": userObj.password,"device_token": UserDefaults.standard.value(forKey: DEVICE_TOKEN),"grant_type": "password","device_type": DEVICE_TYPE,"client_id":CLIENT_ID,"client_secret":CLIENT_SECRET]
        
        print("Login param",paramDic)
        
        ServiceHelper.sharedInstance.createPostRequest(isShowHud: true, params: paramDic as [String : AnyObject], apiName: API_Login) { (response, error) in
            if error != nil {
                AlertController.alert(title: appName, message: (error?.description)!)
                return
            }
            if (response != nil) {
                let result = response as! Dictionary<String, AnyObject>
                let message = result.validatedValue("message", expected: "" as AnyObject) as! String
                if message == "The user credentials were incorrect."{
                    AlertController.alert(title: appName, message: message)
                } else {
                let tokenValue = result.validatedValue("token_type", expected: "" as AnyObject) as! String
                let accessToken = result.validatedValue("access_token", expected: "" as AnyObject) as! String
                let refreshToken = result.validatedValue("refresh_token", expected: "" as AnyObject) as! String
                UserDefaults.standard.set(tokenValue , forKey: TOKEN_TYPE)
                UserDefaults.standard.set(accessToken, forKey: ACCESS_TOKEN)
                UserDefaults.standard.set(refreshToken, forKey: REFRESH_TOKEN)
                UserDefaults.standard.set(true, forKey: "isLoggedin")
                UserDefaults.standard.synchronize()
                self.updateDeviceToken()
                }
            }else{
                AlertController.alert(title: appName, message: "Something went wrong.")
            }
        }
    }
    
    
    func updateDeviceToken() {
        
        let param = [
            "device_token" : UserDefaults.standard.value(forKey: DEVICE_TOKEN)
        ]
        
        ServiceHelper.sharedInstance.createPostRequest(isShowHud: true, params: param as [String : AnyObject], apiName: API_UPDATE_TOKEN) { (response, error) in
            
            if error != nil {
                AlertController.alert(title: appName, message: (error?.description)!)
                return
            }
            if (response != nil) {
                //let result = response as! Dictionary<String, AnyObject>
                self.getProfileApi()
                
            }else{
                AlertController.alert(title: appName, message: "Something went wrong.")
            }
        }
        
    }
    
    func getProfileApi(){
        if (reachability?.isReachable)! {
            APPDELEGATE.showIndicator()
            AlamoFireWrapperNetwork.sharedInstance.GetDataAlamofire(url: API_GetProfile, success: { (responseDict) in
                APPDELEGATE.hideIndicator()
                debugPrint(responseDict ?? "No Value")
                
                let jsonResponse = JSON(responseDict as Any)
                print(jsonResponse)
                let fullName = responseDict?.validatedValue("first_name", expected: "" as AnyObject) as! String
                let currency = responseDict?.validatedValue("currency", expected: "" as AnyObject) as! String 
                
               
                UserDefaults.standard.set(fullName, forKey: "fullName")
                UserDefaults.standard.set(currency, forKey: "currency")
                UserDefaults.standard.synchronize()
                let nameDict:[String: String] = ["name": fullName]
                NotificationCenter.default.post(name: Notification.Name("nameSetUp"), object: nil,userInfo: nameDict)
                self.navigationController?.pushViewController(APPDELEGATE.sideMenuController, animated: true)
                
            }) { (error) in
                AlertController.alert(title: appName, message: (error?.localizedDescription)!)
            }
        }
        else{
            AlertController.alert(title: appName, message: kInternetConnection)
        }
    }
}

extension LoginVC : UITableViewDelegate , UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return imageArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CommonCell", for: indexPath) as! CommonCell
        cell.staticImg.image = imageArray[indexPath.row]
        cell.passwordShowBtn.isHidden = indexPath.row == 1 ? false : true
        cell.textField.isSecureTextEntry = indexPath.row == 1 ? true : false
        cell.textField.attributedPlaceholder = attributedPlaceholder(string: placeHolderArray[indexPath.row])
        cell.textField.tag = indexPath.row + 1000
        cell.passwordShowBtn.tag = indexPath.row + 2000
        cell.textField.keyboardType = .default
        cell.textField.returnKeyType = .next
        cell.passwordShowBtn.addTarget(self, action: #selector(showPasswordBtn(_:)), for: .touchUpInside)
        switch indexPath.row {
        case 0:
            cell.textField.keyboardType = .emailAddress
            break
        case 1:
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
        let cell = self.loginTableView.cellForRow(at: IndexPath.init(row: sender.tag - 2000 , section: 0)) as! CommonCell
        if sender.isSelected {
            cell.textField.isSecureTextEntry = false
        }else {
            cell.textField.isSecureTextEntry = true
        }
    }

}
extension LoginVC : UITextFieldDelegate {
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        switch textField.tag {
        case 1000:
            self.userObj.email = (textField.text?.trimWhiteSpace)!
            break
        case 1001:
            self.userObj.password = (textField.text?.trimWhiteSpace)!
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
