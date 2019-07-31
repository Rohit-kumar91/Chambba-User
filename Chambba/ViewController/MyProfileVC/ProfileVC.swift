//
//  ProfileVC.swift
//  Chambba
//
//  Created by Mayur chaudhary on 21/02/19.
//  Copyright © 2019 Mayur chaudhary. All rights reserved.
//

import UIKit
import SDWebImage

class ProfileVC: UIViewController,UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var changePasswordBtn: UIButton!
    @IBOutlet weak var updateBtn: UIButton!
    @IBOutlet weak var profileImg: UIImageView!
    @IBOutlet weak var profileImageBtn: UIButton!
    @IBOutlet weak var backBtn: UIButton!
    @IBOutlet weak var editProfileTableView: UITableView!
    
    var staticTextArray = [String]()
    var userObj = UserInfo()
    var picker = UIImagePickerController()

    //MARK:- UIViewController Life Cycle Method
    override func viewDidLoad() {
        super.viewDidLoad()
        customInit()
        getProfileData()
    }
    
    func customInit(){
        staticTextArray = ["Full name","Email","Phone number"]
        updateBtn.shadowAtBottom(red: 253, green: 234, blue: 64)
        changePasswordBtn.shadowAtBottom(red: 253, green: 234, blue: 64)
    }

    //MARK:- Memory Warning Method
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    //MARK:- IBAction method
    @IBAction func commonBtnAction(_ sender: UIButton) {
        self.view.endEditing(true)
        switch sender.tag {
        case 100:               // Back Btn
            self.navigationController?.popViewController(animated: true)
            break
        case 101:                   // Image Picker Btn
            imagePickerMethod()
            break
        case 102:                   // Update Btn
            if isAllFieldVerified() {
                updateProfile()
            }
            break
        case 103:                   // Change Password Btn
            let changePasswordVC = mainStoryboard.instantiateViewController(withIdentifier: "ChangePasswordVC") as! ChangePasswordVC
            self.navigationController?.pushViewController(changePasswordVC, animated: true)
            break
        default:
            break
        }
    }
    
    
    func getProfileData() {
        
        ServiceHelper.sharedInstance.createGetRequest(isShowHud: true, params: [:], apiName: API_GetProfile) { (response, error) in
            
            if error != nil {
                AlertController.alert(title: appName, message: (error?.description)!)
                return
            }
            
            if response != nil {
                //Handle Response here.
                let result = response as! Dictionary<String, AnyObject>
                
                let fullName = result.validatedValue("first_name", expected: "" as AnyObject) as! String
                self.userObj.fullName = fullName
                
                let imageUrl =  result.validatedValue(PROFILE_IMAGE, expected: "" as AnyObject) as! String
                let imageURL = BASE_IMAGE_URL + imageUrl
                
                self.profileImg?.sd_setImage(with: URL(string: imageURL), placeholderImage: #imageLiteral(resourceName: "userProfileIcon"))
                
                let email =  result.validatedValue("email", expected: "" as AnyObject) as! String
                self.userObj.email = email
                
                let phone = result.validatedValue("mobile", expected: "" as AnyObject) as! String
                self.userObj.phoneNumebr = phone
                
                //reload TableView
                DispatchQueue.main.async {
                    self.editProfileTableView.reloadData()
                }
                
            }
        }
    }
    
    
    //MARK:- Validation Method
    func isAllFieldVerified() -> Bool{
        if userObj.email.trimWhiteSpace.count == 0 {
            userObj.errorString = blankEmailAddress
        } else if !userObj.email.isEmail {
            userObj.errorString = inValidEmailAddress
        } else if userObj.phoneNumebr.trimWhiteSpace.count == 0 {
            userObj.errorString = blankMobileNumber
        } else{
            userObj.errorString = ""
            return true
        }
        AlertController.alert(title: "", message: userObj.errorString, buttons: ["OK"]) { (UIAlertAction, index) in
        }
        
        DispatchQueue.main.async {
            self.editProfileTableView.reloadData()
        }
        return false
    }
    
    
    func updateProfile() {
        
        let imageData = UIImageJPEGRepresentation(profileImg.image!, 1.0)
        
        let params = ["email":userObj.email, "first_name": userObj.fullName, "mobile": userObj.phoneNumebr]
        
        let userID = UUID().uuidString
        
        ServiceHelper.sharedInstance.createRequestToUploadDataWithString(additionalParams: params, dataContent: imageData, strName: "picture", strFileName: userID + ".jpg", strType: "file", apiName: API_Update_Profile) { (response, error) in
            
            if error != nil {
                AlertController.alert(title: appName, message: (error?.description)!)
                return
            }
            
            if response != nil {
                let result = response as! Dictionary<String, AnyObject>
                print("My Updateed Result",result)
                
                let fullName = result.validatedValue("first_name", expected: "" as AnyObject) as! String
                UserDefaults.standard.set(fullName, forKey: "fullName")
                
                let email = result.validatedValue("email", expected: "" as AnyObject) as! String
                UserDefaults.standard.set(email, forKey: "email")
                
                let mobile = result.validatedValue("mobile", expected: "" as AnyObject) as! String
                UserDefaults.standard.set(mobile, forKey: "mobile")
                
                let picture = result.validatedValue("picture", expected: "" as AnyObject) as! String
                UserDefaults.standard.set(picture, forKey: "picture")
                
                UserDefaults.standard.synchronize()
                
                
                
                self.navigationController?.popViewController(animated: true)
                
                AlertController.alert(title: appName, message: profileUpdate)
            }
        }
    }
    
    

    func imagePickerMethod(){
        let alert = UIAlertController()
        alert.addAction(UIAlertAction(title: "Choose Camera", style: .default , handler:{ (UIAlertAction)in
            
            if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.camera){
                self.picker.delegate = self
                self.picker.sourceType = UIImagePickerControllerSourceType.camera;
                self.picker.allowsEditing = true
                self.present(self.picker, animated: true, completion: nil)
            }
        }))
        alert.addAction(UIAlertAction(title: "Choose from gallery", style: .default , handler:{ (UIAlertAction)in
            if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.photoLibrary) {
                
                let imagePicker = UIImagePickerController()
                imagePicker.delegate = self
                imagePicker.sourceType = UIImagePickerControllerSourceType.photoLibrary;
                imagePicker.allowsEditing = true
                self.present(imagePicker, animated: true, completion: {
                })
            }
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler:{ (UIAlertAction)in
        }))
        self.present(alert, animated: true, completion: {
            
        })
    }
    
    //MARK: - Camera delegate
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        if let image = info[UIImagePickerControllerEditedImage] as? UIImage {
            profileImg.image = image

        } else {
        }
        self.dismiss(animated: true, completion: nil)
        
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
}



extension ProfileVC : UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return staticTextArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ProfileCell", for: indexPath) as! ProfileCell
        cell.textField.delegate = self
        cell.textField.tag = indexPath.row + 1000
        cell.staticTextLabel.text = staticTextArray[indexPath.row]
        cell.textField.keyboardType = .default
        cell.textField.returnKeyType = .next
        switch indexPath.row {
        case 0:
            cell.textField.text = userObj.fullName
            break
        case 1:
            cell.textField.text = userObj.email
            cell.textField.keyboardType = .emailAddress
            break
        case 2:
            cell.textField.text = userObj.phoneNumebr
            cell.textField.keyboardType = .phonePad
            break
        default:
            break
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
}



extension ProfileVC : UITextFieldDelegate{
    func textFieldDidEndEditing(_ textField: UITextField) {
        switch textField.tag {
        case 1000:
            userObj.fullName = (textField.text?.trimWhiteSpace)!
            break
        case 1001:
            userObj.email = (textField.text?.trimWhiteSpace)!
            break
        case 1002:
            userObj.phoneNumebr = (textField.text?.trimWhiteSpace)!
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

