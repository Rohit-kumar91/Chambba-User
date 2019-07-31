//
//  PaymentVC.swift
//  Chambba
//
//  Created by Mayur chaudhary on 22/02/19.
//  Copyright © 2019 Mayur chaudhary. All rights reserved.
//

import UIKit
import SwiftyJSON


protocol CardDetailsSend: class {
    func onChangePaymentMode(_ choosedPayment: JSON)
}

class PaymentVC: UIViewController {

    @IBOutlet weak var paymenttableView: UITableView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var backBtn: UIButton!
    
    var cardArray = [JSON]()
    weak var delegate: CardDetailsSend?
    
    //MARK:- UIViewController Life Cycle Method
    override func viewDidLoad() {
        super.viewDidLoad()
       
    }
    
    override func viewWillAppear(_ animated: Bool) {
         getAllCard()
    }

    //MARK:- Memory Warning Method
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func addCardButtonTapped(_ sender: Any) {
        let creditCardVC = mainStoryboard.instantiateViewController(withIdentifier: "CreditCardVC") as! CreditCardVC
        self.navigationController?.pushViewController(creditCardVC, animated: true)
    }
    
    //MARK:- IBAction Method
    
    
    @IBAction func backBtnAction(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    func getAllCard() {
        ServiceHelper.sharedInstance.createGetRequest(isShowHud: true, params: [:], apiName: API_USER_CARD) { (response, error) in
            if error != nil {
                AlertController.alert(title: appName, message: (error?.description)!)
                return
            }
            
            if response != nil {
                
                let reponseJson = JSON(response as Any)
                print(reponseJson)
                self.cardArray = reponseJson.arrayValue
                self.paymenttableView.reloadData()
                
            }
        }
    }
}


extension PaymentVC: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cardArray.count + 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "PaymentCell", for: indexPath) as! PaymentCell
        
        if indexPath.row == 0 {
            cell.cardNumber.text = "Use Wallet Amount."
            cell.cardType.isHidden = true
            cell.cardImage.image = #imageLiteral(resourceName: "wallet")
        } else {
            cell.cardNumber.text = "**** **** **** " + cardArray[indexPath.row - 1]["last_four"].stringValue
            cell.cardType.text = cardArray[indexPath.row - 1]["brand"].stringValue
            cell.cardImage.image = #imageLiteral(resourceName: "visa")
        }
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
     
        if indexPath.row == 0 {
            let localDict = [
                "card_id" : "" ,
                "last_four" : ""
            ]
            delegate?.onChangePaymentMode(JSON(localDict))
            
        } else {
            delegate?.onChangePaymentMode(cardArray[indexPath.row - 1])
        }
        
        self.navigationController?.popViewController(animated: true)
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        
                if editingStyle == .delete {
                    let param = [
                        "_method" : "DELETE",
                        "card_id" :  cardArray[indexPath.row - 1]["card_id"].stringValue
                    ]
                    
                    ServiceHelper.sharedInstance.createPostRequest(isShowHud: true, params: param as [String : AnyObject] , apiName: API_CARD_DELETE) { (response, error) in
                        if error != nil {
                            AlertController.alert(title: appName, message: (error?.description)!)
                            return
                        }
                        
                        if response != nil {
                            self.cardArray.remove(at: indexPath.row - 1)
                            self.paymenttableView.deleteRows(at: [indexPath], with: .fade)
                        }
                    }
                }
  
    }
}
