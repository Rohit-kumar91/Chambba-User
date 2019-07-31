//
//  SocialSignUpVC.swift
//  Chambba
//
//  Created by Rohit Kumar on 28/02/19.
//  Copyright © 2019 Mayur chaudhary. All rights reserved.
//

import UIKit
import GoogleSignIn
import AccountKit
import FBSDKLoginKit
import FBSDKCoreKit


class SocialSignUpVC: UIViewController, GIDSignInDelegate, GIDSignInUIDelegate, AKFViewControllerDelegate {
   
    

    @IBOutlet weak var socialSignupTableview: UITableView!
    
    var signupArray = ["Google","Facebook"]
    var imageArray = [#imageLiteral(resourceName: "google") , #imageLiteral(resourceName: "facebook")]
    var userObj = UserInfo()
    var accountKit: AKFAccountKit!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        GIDSignIn.sharedInstance().uiDelegate = self
        GIDSignIn.sharedInstance().delegate = self
        
        if accountKit == nil {
            accountKit = AKFAccountKit(responseType: .accessToken)
        }
    }

    @IBAction func commonButtonAction(_ sender: UIButton) {
        
        switch sender.tag {
            
        case 100:       // Back Btn
            self.navigationController?.popViewController(animated: true)
            break
            
        default:
            break
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
    
}



//MARK: Tableview Delegate Method
extension SocialSignUpVC : UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return signupArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! SocialCell
        
        cell.socialLabel.text = signupArray[indexPath.row]
        cell.imageview.image  = imageArray[indexPath.row]
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if indexPath.row == 0 {
            //Google SignIn
            GIDSignIn.sharedInstance().signIn()
        } else if indexPath.row == 1 {
            //Facebook SighIn
            let fbLoginManager : FBSDKLoginManager = FBSDKLoginManager()
            fbLoginManager.logIn(withReadPermissions: ["email"], from: self) { (result, error) in
                
                if (error == nil){
                    
                    let fbloginresult : FBSDKLoginManagerLoginResult = result!
                    if fbloginresult.grantedPermissions != nil {
                        if fbloginresult.grantedPermissions.contains("email")
                        {
                            self.getFBUserData()
                            //fbLoginManager.logOut()
                        }
                    }
                } else {
                    AlertController.alert(title: "", message: error!.localizedDescription, buttons: ["OK"]) { (UIAlertAction, index) in
                    }
                }
            }
        }
    }
    
    //MARK: Facebook SignIn Parameter
    func getFBUserData(){
        
        
        if FBSDKAccessToken.current() != nil {
            FBSDKGraphRequest(graphPath: "me", parameters: ["fields": "id, name, first_name, last_name, picture.type(large), email"]).start(completionHandler: { (connection, result, error) -> Void in
                
                if error != nil {
                    print("error facebook",FBSDKAccessToken.current())
                } else {
                    print("LoggedIn")
                    let dict = result as! [String : AnyObject]
                    print(result!)
                    print(dict)
                    
                    guard let name = dict["name"] else { return }
                    guard let id = dict["id"] else { return }
                    
                    if let profilePicture = dict["picture"]  {
                        if let data = profilePicture["data"] as? [String: Any] {
                            if let url = data["url"] as? String {
                                self.userObj.socialImageUrl = url
                            }
                        }
                    }
                    
                    if let email = dict["email"] as? String {
                        self.userObj.email = email
                    } else {
                        let UID = id as! String
                        self.userObj.email = UID + "@gmail.com"
                    }
                    
                    self.userObj.fullName = name as! String
                    self.userObj.signInMethod = "facebook"
                    self.userObj.socialId = id as! String
                    self.loginWithPhone()
                }
            })
        }
    }
    
}
    
  

//MARK: Google SignIn

extension SocialSignUpVC {
    
    // pressed the Sign In button
    func sign(inWillDispatch signIn: GIDSignIn!, error: Error?) {
        //myActivityIndicator.stopAnimating()
    }
    
    // Present a view that prompts the user to sign in with Google
    func sign(_ signIn: GIDSignIn!,
              present viewController: UIViewController!) {
        self.present(viewController, animated: true, completion: nil)
    }
    
    // Dismiss the "Sign in with Google" view
    func sign(_ signIn: GIDSignIn!, dismiss viewController: UIViewController!) {
        self.dismiss(animated: true, completion: nil)
    }
    
    
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        if let error = error {
            print("\(error.localizedDescription)")
        } else {
            // Perform any operations on signed in user here.
            userObj.email = user.profile.email
            userObj.fullName = user.profile.name
            userObj.signInMethod = "google"
            userObj.socialId = user.userID
            
            if user.profile.hasImage{
                // crash here !!!!!!!! cannot get imageUrl here, why?
                // let imageUrl = user.profile.imageURLWithDimension(120)
                let imageUrl = signIn.currentUser.profile.imageURL(withDimension: 120)
                userObj.socialImageUrl = (imageUrl?.absoluteString)!
            }
            
            loginWithPhone()
            
        }
    }
    
    func sign(_ signIn: GIDSignIn!, didDisconnectWith user: GIDGoogleUser!,
              withError error: Error!) {
        // Perform any operations when the user disconnects from app here.
        // ...
    }
}

extension SocialSignUpVC {
    
    func signUpAPi(){
        let uDID = UUID().uuidString
        let paramDic = ["email" :userObj.email,"first_name": userObj.fullName,"password":userObj.socialId,"mobile": userObj.phoneNumebr ,"countryCode": userObj.phoneNumberCountryCode,"device_token": UserDefaults.standard.value(forKey: DEVICE_TOKEN),"login_by": userObj.signInMethod,"device_type": DEVICE_TYPE,"device_id":uDID,"picture": userObj.socialImageUrl,"social_unique_id": userObj.socialId]
        
        ServiceHelper.sharedInstance.createPostRequest(isShowHud: true, params: paramDic as [String : AnyObject], apiName: API_SignUp) { (response, error) in
            if error != nil {
                AlertController.alert(title: appName, message: (error?.description)!)
                return
            }
            if (response != nil) {
                if let result = response!["email"] as? [String] {
                    if result.count > 0 {
                        if result[0] == "The email has already been taken." {
                            //AlertController.alert(title: appName, message: "The email has already been taken.")
                            self.loginAPI()
                        }
                    }else {
                        self.loginAPI()
                        
                    }
                }else {
                    self.loginAPI()
                    
                }
                
            }else{
                AlertController.alert(title: appName, message: "Something went wrong.")
            }
        }
    }
    
    func loginAPI(){
        
        let paramDic = ["username" :userObj.email,"password": userObj.socialId,"device_token": UserDefaults.standard.value(forKey: DEVICE_TOKEN),"grant_type": "password","device_type": DEVICE_TYPE,"client_id":CLIENT_ID,"client_secret":CLIENT_SECRET]
        
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
                UserDefaults.standard.set(fullName, forKey: "fullName")
                
                let email = responseDict?.validatedValue("email", expected: "" as AnyObject) as! String
                UserDefaults.standard.set(email, forKey: "email")
                
                let mobile = responseDict?.validatedValue("mobile", expected: "" as AnyObject) as! String
                UserDefaults.standard.set(mobile, forKey: "mobile")
                
                let picture = responseDict?.validatedValue("picture", expected: "" as AnyObject) as! String
                UserDefaults.standard.set(picture, forKey: "picture")
                
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

