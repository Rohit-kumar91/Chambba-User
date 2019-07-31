//
//  YourTripsVC.swift
//  Chambba
//
//  Created by Rohit Kumar on 26/02/19.
//  Copyright © 2019 Mayur chaudhary. All rights reserved.
//

import UIKit
import SwiftyJSON

enum Trips: String{
    case passedTrip
    case upcomingTrip
}

class YourTripsVC: UIViewController {
    
    @IBOutlet weak var headerLabel: UILabel!
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var pastButton: UIButton!
    @IBOutlet weak var upcomingButton: UIButton!
    @IBOutlet weak var pastView: UIView!
    @IBOutlet weak var upcomingView: UIView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var noDataLabel: UILabel!
    
    
    //MARK: Properties
    var trips = Trips.passedTrip
    var result = [JSON]()
    var selectionType = "PAST"

    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        customInit()
    }
    
    func customInit(){
        pastView.isHidden = false
        upcomingView.isHidden = true
        tableView.isHidden = true
        noDataLabel.isHidden = true
        onGetHistroy(apiName: API_GetTripHistory)
        
    }
    
   
    func tripSelection(trip: Trips) {
        switch trip {
        case .passedTrip:
            selectionType = "PAST"
            pastView.isHidden = false
            upcomingView.isHidden = true
            onGetHistroy(apiName: API_GetTripHistory)
            break
            
        case .upcomingTrip:
            selectionType = ""
            pastView.isHidden = true
            upcomingView.isHidden = false
            onGetHistroy(apiName: API_UPComingTrip)
            break
        }
    }
    
    
    func onGetHistroy(apiName: String) {
        
        ServiceHelper.sharedInstance.createGetRequest(isShowHud: true, params: [:], apiName: apiName) { (response, error) in
            if error != nil {
                AlertController.alert(title: appName, message: (error?.description)!)
                return
            }
            
            if response != nil {
                //Handle Response here.
                self.result = JSON(response).arrayValue
                self.tableView.reloadData()
                
                print("Result", self.result)
                if self.result.count == 0 {
                    self.noDataLabel.isHidden = false
                    self.tableView.isHidden = true
                } else {
                    //Handle resopnse for tableview.
                    self.tableView.isHidden = false
                }
            }
        }
    }
    

    @IBAction func commonButtonAction(_ sender: UIButton) {
        switch sender.tag {
        case 100:                   // Back Btn
            self.navigationController?.popViewController(animated: true)
            break
        case 101: // Passed Btn
            trips = Trips.passedTrip
            tripSelection(trip: trips)
            break
            
        case 102: // UpComing Btn
            trips = Trips.upcomingTrip
            tripSelection(trip: trips)
            break
        default:
            break
        }
    }
    
//    @IBAction func cancelRequestAction(_ sender: UIButton) {
//        let requestID =  self.result[sender.tag]["id"].stringValue
//        cancelScheduleRide(reqID: requestID)
//    }
    
    @IBAction func cancelRequest(_ sender: UIButton) {
        print("Cancel Request")
        let requestID =  self.result[sender.tag]["id"].stringValue
        cancelScheduleRide(reqID: requestID)
    }
    
    func cancelScheduleRide(reqID: String) {
        
        let param = [
            "request_id" : reqID
        ]
        
        ServiceHelper.sharedInstance.createPostRequest(isShowHud: true, params: param as [String : AnyObject], apiName: API_CANCEL_REQUEST) { (response, error) in
            
            if error != nil {
                AlertController.alert(title: appName, message: (error?.description)!)
                return
            }
            
            if response != nil {
                //Handle Response here.
                self.onGetHistroy(apiName: API_UPComingTrip)
            }
            
        }
        
    }
}

extension YourTripsVC: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return result.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "YourTripsCell", for: indexPath) as! YourTripsCell
        
        
        
        cell.dateLabel.text = result[indexPath.row]["booking_id"].stringValue
        cell.timeLabel.textColor = UIColor(red: 82.0/255.0, green: 87.0/255.0, blue: 96.0/255.0, alpha: 1.0)
        
        cell.cancelButton.layer.cornerRadius = 5.0
        cell.cancelButton.layer.borderWidth = 1.0
        cell.cancelButton.borderColor = UIColor(red: 82.0/255.0, green: 87.0/255.0, blue: 96.0/255.0, alpha: 1.0)
        
        let imageUrlStr = result[indexPath.row]["static_map"].stringValue
        let refineStr = imageUrlStr.replacingOccurrences(of: "%7C", with: "|")
        let urlwithPercentEscapes = refineStr.addingPercentEncoding( withAllowedCharacters: .urlQueryAllowed)
        cell.mapImageView.sd_setImage(with: URL(string: urlwithPercentEscapes!), placeholderImage: #imageLiteral(resourceName: "rd-map"))
        
        
        if trips.rawValue == "passedTrip"{
            
            cell.amountLabel.isHidden = false
            cell.cancelButton.isHidden = true
            cell.timeLabel.text = result[indexPath.row]["assigned_at"].stringValue
            let price = result[indexPath.row]["payment"]["total"].doubleValue
            cell.amountLabel.text = "$" + String(format: "%.2f", price)
            
//            if let currencySymbol = UserDefaults.standard.value(forKey: "currency") as? String {
//                cell.amountLabel.text = currencySymbol + String(format: "%.2f", price)
//            }
            
            
            
        } else {
            cell.amountLabel.isHidden = true
            cell.cancelButton.isHidden = false
            cell.timeLabel.text = result[indexPath.row]["schedule_at"].stringValue
        }
        
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let histroyVC = self.storyboard?.instantiateViewController(withIdentifier: "HistoryVC") as! HistoryVC
        histroyVC.histroyHintStr = selectionType
        histroyVC.request_idStr = result[indexPath.row]["id"].stringValue
        self.present(histroyVC, animated: true, completion: nil)
    }
    
}
