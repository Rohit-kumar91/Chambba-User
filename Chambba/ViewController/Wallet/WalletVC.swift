//
//  WalletVC.swift
//  Chambba
//
//  Created by Rohit Kumar on 26/02/19.
//  Copyright © 2019 Mayur chaudhary. All rights reserved.
//

import UIKit
import SwiftyJSON

class WalletVC: UIViewController {
    
    
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var addMoneyButton: UIButton!
    @IBOutlet weak var addMoneyTextfield: UITextField!
    @IBOutlet weak var firstAmountButton: UIButton!
    @IBOutlet weak var secondAmountButton: UIButton!
    @IBOutlet weak var thirdAmountButton: UIButton!
    @IBOutlet weak var walletAmount: UILabel!
    
    var userObj = UserInfo()
    var payPalConfig = PayPalConfiguration()
    var cardArray = [JSON]()
    var strCardID = ""
    var strCardLastNo = ""
    
    
    //Set environment connection.
    var environment:String = PayPalEnvironmentNoNetwork {
        willSet(newEnvironment) {
            if (newEnvironment != environment) {
                PayPalMobile.preconnect(withEnvironment: newEnvironment)
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        customInit()
       
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        //getAllCard()
        getProfile()
    }
    
    
    func customInit() {
        addShadowForUIElement()
        addMoneyTextfield.keyboardType = .phonePad
        addMoneyTextfield.tag = 200
        
        let keyboardToolbar = UIToolbar()
        keyboardToolbar.sizeToFit()
        let flexBarButton = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let doneBarButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(doneBtnAction))
        keyboardToolbar.items = [flexBarButton,doneBarButton]
        addMoneyTextfield.inputAccessoryView = keyboardToolbar
        
    }
    
    func addShadowForUIElement() {

        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: 15, height: 20))
        addMoneyTextfield.leftView = paddingView
        addMoneyTextfield.leftViewMode = .always
        
        mainView.layer.shadowColor = UIColor.lightGray.cgColor
        mainView.layer.shadowOpacity = 0.9
        mainView.layer.shadowRadius = 3
        mainView.layer.masksToBounds = false
        mainView.layer.shadowOffset = CGSize(width: 0.3, height: 0.3)
        mainView.layer.cornerRadius = 3
        
    }
    
    @objc func doneBtnAction() {
        self.view.endEditing(true)
    }

    @IBAction func commonButtonAction(_ sender: UIButton) {
        switch sender.tag {
        case 100: // Back Btn
            self.navigationController?.popViewController(animated: true)
            break
            
        case 101: // price Btn
            
            firstAmountButton.layer.borderColor = #colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 1)
            secondAmountButton.layer.borderColor = #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1)
            thirdAmountButton.layer.borderColor = #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1)
            addMoneyTextfield.text = sender.titleLabel?.text
            userObj.amountWallet = "10"
            
            break
            
        case 102: // price Btn
            firstAmountButton.layer.borderColor = #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1)
            secondAmountButton.layer.borderColor = #colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 1)
            thirdAmountButton.layer.borderColor = #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1)
            addMoneyTextfield.text = sender.titleLabel?.text
            userObj.amountWallet = "20"
            
            break
            
        case 103: // price Btn
            firstAmountButton.layer.borderColor = #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1)
            secondAmountButton.layer.borderColor = #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1)
            thirdAmountButton.layer.borderColor = #colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 1)
            addMoneyTextfield.text = sender.titleLabel?.text
            userObj.amountWallet = "30"
            
            break
            
        case 104: // Add Money Btn
            
             //Paypal
             //configurePaypal(strMarchantName: "Chambba")
             
             //Go for pay in paypal for selected paypal items
             let amount = addMoneyTextfield.text!.replacingOccurrences(of: "$", with: "")
             userObj.amountWallet = amount
            
             if isAllFieldVerified() {
                
                getAllCard { (available) in
                    
                    if available! {
                        
                        if self.cardArray.count == 1 {
                            self.addMoney(amount: amount, cardId: self.cardArray[0]["card_id"].stringValue)
                        } else {
                            
                            let selectCardVC = mainStoryboard.instantiateViewController(withIdentifier: "SelectCardVC") as! SelectCardVC
                            selectCardVC.cardArray = self.cardArray
                            selectCardVC.delegate = self
                            
                            self.present(selectCardVC, animated: true, completion: nil)
                        }
                        
                    } else {
                        AlertController.alert(title: "Alert", message: "Add card to continue", buttons: ["Cancel", "Ok"], tapBlock: { (action, index) in
                            if index == 1 {
                                self.userObj.hasCard = false
                                let creditCardVC = mainStoryboard.instantiateViewController(withIdentifier: "CreditCardVC") as! CreditCardVC
                                self.navigationController?.pushViewController(creditCardVC, animated: true)
                            }
                        })
                    }
                }
                 //self.goforPayNow(shipPrice: nil, taxPrice: nil, strShortDesc: "Add to Wallet", strCurrency: "USD")
                
                
             }
            break
        
        default:
            break
        }
    }
    
    func isAllFieldVerified() -> Bool{
        if userObj.amountWallet.trimWhiteSpace.count == 0 {
            userObj.errorString = emptyAmount
        }else{
            userObj.errorString = ""
            return true
        }
        AlertController.alert(title: "", message: userObj.errorString, buttons: ["OK"]) { (UIAlertAction, index) in
        }
        return false
    }
    
    
    func addMoney(amount: String, cardId: String) {
        
        let param = [
            "amount" : amount,
            "card_id" : cardId
        ]
        
        ServiceHelper.sharedInstance.createPostRequest(isShowHud: true, params: param as [String : AnyObject], apiName: API_ADD_MONEY, completion: { (response, error) in
            
            if error != nil {
                AlertController.alert(title: appName, message: (error?.description)!)
                return
            }
            
            if response != nil {
                
                let responseJSON = JSON(response as Any)
                
                if let currencySymbol = UserDefaults.standard.value(forKey: "currency") as? String {
                    
                    
                    self.walletAmount.text = currencySymbol + String(format: "%.02f", responseJSON["user"]["wallet_balance"].floatValue)
                    self.addMoneyTextfield.text = ""
                }
            }
        })
        
    }
}

extension WalletVC : PayPalPaymentDelegate {
    
    
    //It will provide access to the card too for the payment.
    func acceptCreditCards() -> Bool {
        return self.payPalConfig.acceptCreditCards
    }
    
    func setAcceptCreditCards(acceptCreditCards: Bool) {
        self.payPalConfig.acceptCreditCards = self.acceptCreditCards()
    }
    
    
   //Configure paypal and set Marchant Name
    func configurePaypal(strMarchantName:String) {
        
        // Set up payPalConfig
        payPalConfig.acceptCreditCards = self.acceptCreditCards();
        payPalConfig.merchantName = strMarchantName
        payPalConfig.merchantPrivacyPolicyURL =  URL.init(string: "https://www.paypal.com/webapps/mpp/ua/privacy-full")
        payPalConfig.merchantUserAgreementURL = URL.init(string: "https://www.paypal.com/webapps/mpp/ua/useragreement-full")
        payPalConfig.languageOrLocale = NSLocale.preferredLanguages[0]
        payPalConfig.payPalShippingAddressOption = .payPal;
        print("PayPal iOS SDK Version: \(PayPalMobile.libraryVersion())")
        PayPalMobile.preconnect(withEnvironment: environment)
        
    }
    
    //Start Payment for selected shopping items
    
    func goforPayNow(shipPrice:String?, taxPrice:String?, strShortDesc:String?, strCurrency:String?) {
        
        var subtotal : NSDecimalNumber = 0
        var shipping : NSDecimalNumber = 0
        var tax : NSDecimalNumber = 0
        
        
        // Optional: include payment details
        if shipPrice != nil {
            shipping = NSDecimalNumber(string: shipPrice)
        }
        
        if taxPrice != nil {
            tax = NSDecimalNumber(string: taxPrice)
        }
        
        
        var description = strShortDesc
        if (description == nil) {
            description = ""
        }
        
        if userObj.amountWallet != "" {
            subtotal = NSDecimalNumber(string: userObj.amountWallet)
        }
        
        
        let paymentDetails = PayPalPaymentDetails(subtotal: subtotal, withShipping: shipping, withTax: tax)
        let total = subtotal.adding(shipping).adding(tax)
        
        let payment = PayPalPayment(amount: total, currencyCode: strCurrency!, shortDescription: description!, intent: .order)
        payment.items = nil
        payment.paymentDetails = paymentDetails
        self.payPalConfig.acceptCreditCards = self.acceptCreditCards();
        
        
        if self.payPalConfig.acceptCreditCards == true {
            print("We are able to do the card payment")
        }
        
        
        if (payment.processable) {
            
            guard let objVC = PayPalPaymentViewController(payment: payment, configuration: payPalConfig, delegate: self) else { return }
            self.present(objVC, animated: true, completion: { () -> Void in
                print("Paypal Presented")
            })
            
        } else {
            print("Payment not processalbe: \(payment)")
        }
        
    }
    
    
    func payPalPaymentDidCancel(_ paymentViewController: PayPalPaymentViewController) {
        paymentViewController.dismiss(animated: true) { () -> Void in
            print("and Dismissed")
        }
        
        print("Payment cancel")
    }
    
    
    func payPalPaymentViewController(_ paymentViewController: PayPalPaymentViewController, didComplete completedPayment: PayPalPayment) {
        paymentViewController.dismiss(animated: true) { () -> Void in
            print("and done")
            print("Payment Complete Response", completedPayment.confirmation["response"] as Any)
        }
        print("Paymane is going on")
    }
    
}


extension WalletVC {
    
    func getAllCard(completion: @escaping (_ cardAvailable: Bool?) -> Void) {
        ServiceHelper.sharedInstance.createGetRequest(isShowHud: true, params: [:], apiName: API_USER_CARD) { (response, error) in
            if error != nil {
                AlertController.alert(title: appName, message: (error?.description)!)
                return
            }
            
            if response != nil {
                
                let reponseJson = JSON(response as Any)
                print(reponseJson)
                self.cardArray = reponseJson.arrayValue
                
                if self.cardArray.count == 0 {
                    completion(false)
                } else {
                    completion(true)
                }
            }
        }
    }
    
    
    func getProfile() {
        
        let uDID = UUID().uuidString
        guard let deviceToken = UserDefaults.standard.value(forKey: DEVICE_TOKEN) else {
            AlertController.alert(title: "Device Token not found.")
            return
        }
        
        let param = [
            "device_token" :  deviceToken,
            "device_type" : DEVICE_TYPE,
            "device_id" :  uDID
        ]
        
        ServiceHelper.sharedInstance.createGetRequest(isShowHud: true, params: param as [String : AnyObject], apiName: API_GetProfile) { (response, error) in
            if error != nil {
                AlertController.alert(title: appName, message: (error?.description)!)
                return
            }
            
            if response != nil {
                let jsonResponse = JSON(response as Any)
                if let currencySymbol = UserDefaults.standard.value(forKey: "currency") as? String {
                   self.walletAmount.text = currencySymbol + String(format: "%.02f", jsonResponse["wallet_balance"].floatValue)
                }
            }
        }
    }
}

extension WalletVC: SelectCardDetails  {
    
    
    func selectCardWithDetails(_ choosedPayment: JSON) {
        strCardID =  choosedPayment["card_id"].stringValue
        strCardLastNo = choosedPayment["last_four"].stringValue
        self.addMoney(amount: userObj.amountWallet, cardId: strCardID)
    }
    
    
}
