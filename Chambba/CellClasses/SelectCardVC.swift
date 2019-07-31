//
//  SelectCardVC.swift
//  Chambba
//
//  Created by Rohit Kumar on 03/04/19.
//  Copyright © 2019 Mayur chaudhary. All rights reserved.
//

import UIKit
import SwiftyJSON


protocol SelectCardDetails: class {
    func selectCardWithDetails(_ choosedPayment: JSON)
}

class SelectCardVC: UIViewController {
    
    var cardArray = [JSON]()
     weak var delegate: SelectCardDetails?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func backButtonTapped(_ sender: UIButton) {
        
        print("backButtonTapped..")
        self.dismiss(animated: true, completion: nil)
    }
    
}

extension SelectCardVC: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cardArray.count 
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PaymentCell", for: indexPath) as! PaymentCell
       
        cell.cardNumber.text = "**** **** **** " + cardArray[indexPath.row ]["last_four"].stringValue
        cell.cardType.text = cardArray[indexPath.row]["brand"].stringValue
        cell.cardImage.image = #imageLiteral(resourceName: "visa")
     
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        print("Tableview cell selected..")
        delegate?.selectCardWithDetails(cardArray[indexPath.row])
         self.dismiss(animated: true, completion: nil)
    }
    
   
}

