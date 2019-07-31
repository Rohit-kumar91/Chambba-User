//
//  SignUpVC.swift
//  Chambba
//
//  Created by Mayur chaudhary on 29/01/19.
//  Copyright © 2019 Mayur chaudhary. All rights reserved.
//

import UIKit
import AccountKit
import Foundation



class SignUpVC: UIViewController , AKFViewControllerDelegate{

    @IBOutlet weak var signUpTableView: UITableView!
    @IBOutlet weak var singUpBtn: UIButton!
    @IBOutlet weak var signInBtn: UIButton!
    @IBOutlet weak var backBtn: UIButton!
    
    var imageArray = [#imageLiteral(resourceName: "userIcon"),#imageLiteral(resourceName: "emailIcon"),#imageLiteral(resourceName: "mobileIcon"),#imageLiteral(resourceName: "passwordIcon"),#imageLiteral(resourceName: "passwordIcon")]
    var placeholderArray = ["Full name","Email Address","Phone number","Create password","Confirm password"]
    var userObj = UserInfo()
    var accountKit: AKFAccountKit!
    
    //MARK:- UIviewController Life Cycle Method
    override func viewDidLoad() {
        super.viewDidLoad()
        customInit()
       
    }
    
    //MARK:- Helper Method
    func customInit(){
        signUpTableView.aroundShadow()
        singUpBtn.shadowAtBottom(red: 255, green: 235, blue: 2)
        // initialize Account Kit
        if accountKit == nil {
            accountKit = AKFAccountKit(responseType: .accessToken)
        }
       
    }

    //MARK:- Account Kit SetUp Method
    func prepareLoginViewController(loginViewController: AKFViewController) {
        loginViewController.delegate = self
        //UI Theming - Optional
        loginViewController.uiManager = AKFSkinManager.init(skinType: .translucent, primaryColor: RGBA(r: 253, g: 234, b: 64, a: 1.0), backgroundImage: nil, backgroundTint: .white, tintIntensity: 1.0)
        loginViewController.uiManager.theme!()?.buttonBackgroundColor = RGBA(r: 253, g: 234, b: 64, a: 1.0)
        loginViewController.uiManager.theme!()?.buttonTextColor = UIColor.black
    }
    
    func loginWithPhone(){
        let inputState = UUID().uuidString
        let vc = (accountKit?.viewControllerForPhoneLogin(with: nil, state: inputState))!
        vc.enableSendToFacebook = true
        self.prepareLoginViewController(loginViewController: vc)
        self.present(vc as UIViewController, animated: true, completion: nil)
    }
    
    func viewController(_ viewController: (UIViewController & AKFViewController)!, didCompleteLoginWith accessToken: AKFAccessToken!, state: String!) {
        print("did complete login with access token \(accessToken.tokenString) state \(String(describing: state))")
        self.accountKit = AKFAccountKit(responseType: AKFResponseType.accessToken)
        accountKit.requestAccount {
            (account, error) -> Void in
             if let phoneNumber = account?.phoneNumber{
                self.userObj.phoneNumebr = phoneNumber.stringRepresentation()
                self.userObj.phoneNumberCountryCode = (account?.phoneNumber?.countryCode)!;
            }
            self.signUpAPi()
        }
        accountKit.logOut()

    }
    
    func viewController(_ viewController: (UIViewController & AKFViewController)!, didFailWithError error: Error!) {
        // ... implement appropriate error handling ...
        print("\(String(describing: viewController)) did fail with error: \(error.localizedDescription)")
    }
    
    func viewControllerDidCancel(_ viewController: (UIViewController & AKFViewController)!) {
        // ... handle user cancellation of the login process ...
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
                loginWithPhone()
            }
            break
        case 102:                   // SignIn Btn
            for controllers in (self.navigationController?.viewControllers)! {
                if controllers is LoginVC {
                    self.navigationController?.popToViewController(controllers, animated: false)
                }
            }
            let loginVC = mainStoryboard.instantiateViewController(withIdentifier: "LoginVC") as! LoginVC
            self.navigationController?.pushViewController(loginVC, animated: true)
            break
        default:
            break
        }
    }
    
    //MARK:- Validation Method
    func isAllFieldVerified() -> Bool{
        if userObj.fullName.trimWhiteSpace.count == 0 {
            userObj.errorString = blankFullName
        }else if userObj.email.trimWhiteSpace.count == 0{
            userObj.errorString = blankEmailAddress
        } else if !userObj.email.isEmail {
            userObj.errorString = inValidEmailAddress
        }else if userObj.phoneNumebr.trimWhiteSpace.count == 0 {
            userObj.errorString = blankMobileNumber
        }else if (userObj.phoneNumebr.length < phoneMinLength || !userObj.phoneNumebr.containsNumberOnly() || userObj.phoneNumebr.isContainsAllZeros()) {
            userObj.errorString = inValidMobileNumber
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
        signUpTableView.reloadData()
        return false
    }
}

extension SignUpVC {
    
    func signUpAPi(){
        let uDID = UUID().uuidString
        let paramDic = ["email" :userObj.email,"password": userObj.password,"first_name": userObj.fullName,"mobile": userObj.phoneNumebr ,"countryCode": userObj.phoneNumberCountryCode,"device_token": UserDefaults.standard.value(forKey: DEVICE_TOKEN),"login_by": "manual","device_type": DEVICE_TYPE,"device_id":uDID,"picture":"","social_unique_id":""]
        
        ServiceHelper.sharedInstance.createPostRequest(isShowHud: true, params: paramDic as [String : AnyObject], apiName: API_SignUp) { (response, error) in
            if error != nil {
                AlertController.alert(title: appName, message: (error?.description)!)
                return
            }
            if (response != nil) {
                if let result = response!["email"] as? [String] {
                    if result.count > 0 {
                        if result[0] == "The email has already been taken." {
                            AlertController.alert(title: appName, message: "The email has already been taken.")
                            
                            
                        }
                    }else {
                        self.loginAPI()
                    }
                }else{
                     self.loginAPI()
                }

            }else{
                AlertController.alert(title: appName, message: "Something went wrong.")
            }
        }
    }
    
    func loginAPI(){
        
        let paramDic = ["username" :userObj.email,"password": userObj.password,"device_token": UserDefaults.standard.value(forKey: DEVICE_TOKEN),"grant_type": "password","device_type": DEVICE_TYPE,"client_id":CLIENT_ID,"client_secret":CLIENT_SECRET]
        
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
                    self.getProfileApi()
                }
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
                let fullName = responseDict?.validatedValue("first_name", expected: "" as AnyObject) as! String
                let currency = responseDict?.validatedValue("currency", expected: "" as AnyObject) as! String
                UserDefaults.standard.set(fullName, forKey: "fullName")
                UserDefaults.standard.set(currency, forKey: "currency")
                
                let email = responseDict?.validatedValue("email", expected: "" as AnyObject) as! String
                UserDefaults.standard.set(email, forKey: "email")
                
                let mobile = responseDict?.validatedValue("mobile", expected: "" as AnyObject) as! String
                UserDefaults.standard.set(mobile, forKey: "mobile")
                
                UserDefaults.standard.synchronize()
                
                
                //I think there is no need of the NotificationCenter Here.
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

extension SignUpVC : UITableViewDelegate , UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return imageArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "CommonCell", for: indexPath) as! CommonCell
        cell.staticImg.image = imageArray[indexPath.row]
        cell.passwordShowBtn.isHidden = indexPath.row == 3 || indexPath.row == 4 ? false : true
        cell.textField.isSecureTextEntry = indexPath.row == 3 || indexPath.row == 4 ? true : false
        cell.textField.attributedPlaceholder = attributedPlaceholder(string: placeholderArray[indexPath.row])
        cell.textField.tag = indexPath.row + 1000
        cell.passwordShowBtn.tag = indexPath.row + 2000
        cell.textField.keyboardType = .default
        cell.textField.returnKeyType = .next
        cell.passwordShowBtn.addTarget(self, action: #selector(showPasswordBtn(_:)), for: .touchUpInside)
        switch indexPath.row {
        case 0:
            cell.textField.text = userObj.fullName
            break
        case 1:
            cell.textField.keyboardType = .emailAddress
            cell.textField.text = userObj.email
            cell.textField.returnKeyType = .next
            break
        case 2:
            cell.textField.keyboardType = .phonePad
            cell.textField.text = userObj.phoneNumebr
            break
        case 3:
            cell.textField.text = userObj.password
            break
        case 4:
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
      let cell = self.signUpTableView.cellForRow(at: IndexPath.init(row: sender.tag - 2000 , section: 0)) as! CommonCell
      if sender.isSelected {
       cell.textField.isSecureTextEntry = false
      }else {
        cell.textField.isSecureTextEntry = true
     }
    }
}

extension SignUpVC : UITextFieldDelegate {
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        switch textField.tag {
        case 1000:
            self.userObj.fullName = (textField.text?.trimWhiteSpace)!
            break
        case 1001:
            self.userObj.email = (textField.text?.trimWhiteSpace)!
            break
        case 1002:
            self.userObj.phoneNumebr = (textField.text?.trimWhiteSpace)!
            break
        case 1003:
            self.userObj.password = (textField.text?.trimWhiteSpace)!
            break
        case 1004:
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

