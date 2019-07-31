//
//  HomeVC.swift
//  Chambba
//
//  Created by Mayur chaudhary on 29/01/19.
//  Copyright © 2019 Mayur chaudhary. All rights reserved.
//

import UIKit
import GoogleMaps
import SwiftyJSON
import HCSStarRatingView
import SocketIO
import GooglePlaces
import Alamofire

class HomeVC: UIViewController {
    
    @IBOutlet weak var serviceView: UIView!
    @IBOutlet weak var serviceCollectionView: UICollectionView!
    @IBOutlet weak var yourLocationLabel: UILabel!
    @IBOutlet weak var yourLocationView: UIView!
    @IBOutlet weak var currentLocationBtn: UIButton!
    @IBOutlet weak var mapView: GMSMapView!
    @IBOutlet weak var menuBtn: UIButton!
    @IBOutlet weak var imgAnimation: UIImageView!
    @IBOutlet weak var requestWaitingView: UIView!
    @IBOutlet weak var labelStatusText: UILabel!
    @IBOutlet weak var userImgBtn: UIButton!
    @IBOutlet weak var nameLbl: UILabel!
    @IBOutlet weak var ServiceBtn: UIButton!
    @IBOutlet weak var lblServiceName: UILabel!
    @IBOutlet weak var lblCarNumber: UILabel!
    @IBOutlet weak var notifyViewBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var ringButtonOutlet: UIButton!
    @IBOutlet weak var cancelRequestButtonOutlet: UIButton!
    @IBOutlet weak var ratingScrollView: UIScrollView!
    @IBOutlet weak var lblRateWithName: UILabel!
    @IBOutlet weak var ratingProviderImage: UIImageView!
    @IBOutlet weak var rateToProvider: HCSStarRatingView!
    @IBOutlet weak var commentText: UITextView!
    @IBOutlet weak var ratingViewBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var rideNowView: UIView!
    @IBOutlet weak var scheduleBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var scheduleDateTimeLable: UILabel!
    @IBOutlet weak var stackviewShowingPaymentType: UIStackView!
    @IBOutlet weak var bookingId: UILabel!
    
    @IBOutlet weak var userPinImgOutlet: UIImageView!
    
    @IBOutlet weak var baseFareLabel: UILabel!
    @IBOutlet weak var distanceLable: UILabel!
    @IBOutlet weak var taxlabel: UILabel!
    @IBOutlet weak var walletDeductionLabel: UILabel!
    @IBOutlet weak var discountLabel: UILabel!
    @IBOutlet weak var totatPriceLabel: UILabel!
    @IBOutlet weak var cashLabel: UILabel!
    @IBOutlet weak var walletDeductionStack: UIStackView!
    @IBOutlet weak var discountStack: UIStackView!
    @IBOutlet weak var invoiceBottomConstrint: NSLayoutConstraint!
    @IBOutlet weak var cardImage: UIImageView!
    @IBOutlet weak var cardNumberLabel: UILabel!
    @IBOutlet weak var continueToPayOutlet: UIButton!
    @IBOutlet weak var changeCard: UIButton!
    
    private let locationManager = CLLocationManager()
    var locationCor = CLLocation()
    var lat = ""
    var long = ""
    var sourceLat = ""
    var sourceLong = ""
    var destLat = ""
    var destLong = ""
    var locName = ""
    var serviceArray = [JSON]()
    var selectedIndex = 500
    var carActiveArray = [#imageLiteral(resourceName: "microActiveIcon"),#imageLiteral(resourceName: "sedanActiveIcon"),#imageLiteral(resourceName: "miniActiveIcon")]
    var timerRequestCheck = Timer()
    var socketConnectFlag = Bool()
    var path2 = GMSMutablePath()
    var i = 0
    var polylineBlack = GMSPolyline()
    var checkSourceLatLong = false
    let sourceMarker = GMSMarker()
   
    let destMarker = GMSMarker()
    var globalStatus = String()
    var strServiceID = String()
    var userNameStr = String()
    var strProviderCell = String()
    var strRating = "0"
    var serviceType = Int()
    var isSchduleTime = false
    var dateSelected = Date()
    var polyline = GMSPolyline()
    var polylineTimer = Timer()
    let endLocationMarker = GMSMarker()
    let startLocationMarker = GMSMarker()
    let markerCarLocation = GMSMarker()
    let providerMarkers = GMSMarker()
    let startbounds = GMSCoordinateBounds()
    let endbounds = GMSCoordinateBounds()
    let manager = SocketManager(socketURL: URL(string: SOCKET_URL)!, config: [.log(true), .compress])
    var arrayPolylineBlack = NSMutableArray()
    
    var getWalletAmount = 0
    var getEstimatedFareAmount = 0
    var currencyStrValue = 0
    let formatter = DateFormatter()
    var userPickupLat = Double()
    var userPickupLong = Double()
    
    var strCardID = ""
    var strCardLastNo = String()
    var cardArray = [JSON]()
    //var checkCompleteStatus = Bool()
    var walletAmount = Int()
    var usingWallet = Bool()
    
    
    //MARK:- UIViewController Life Cycle Method
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.rateToProvider.value = 1
        ratingProviderImage.layer.cornerRadius = 35
        ratingProviderImage.clipsToBounds = true
        
        if strCardID == "" {
            cardImage.image = #imageLiteral(resourceName: "wallet")
            cardNumberLabel.text = "Wallet"
        }
        
        
        sourceMarker.icon =  #imageLiteral(resourceName: "destinationmarker")
        destMarker.icon =  #imageLiteral(resourceName: "sourcemarker")
        
        self.invoiceBottomConstrint.constant = -300
        UIView.animate(withDuration: 0.45, animations: {
            self.view.layoutIfNeeded()
        })
     
        
        formatter.dateFormat = "dd-MM-yyyy HH:mm"
        let date = formatter.string(from: Date())
        
        scheduleDateTimeLable.text = "\(date)"
        datePicker.datePickerMode = .dateAndTime
        datePicker.minimumDate =  Date()
       
        let tap = UITapGestureRecognizer(target: self, action: #selector(HomeVC.searchLocationTapped))
        yourLocationLabel.addGestureRecognizer(tap)
        yourLocationLabel.isUserInteractionEnabled = true
        
        updateLocation()
        onGetServices()
        getAllCard()
        

        timerRequestCheck = Timer.scheduledTimer(timeInterval: 3.0, target: self, selector: #selector(onRequestCheck), userInfo: nil, repeats: true)
        let imageData = try? Data(contentsOf: Bundle.main.url(forResource: "location", withExtension: "gif")!)
        let gif = UIImage.gifImageWithData(imageData!)
        imgAnimation.image = gif
       
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
    }
    
    
    

    @objc func searchLocationTapped() {
//        let locationVC  = self.storyboard?.instantiateViewController(withIdentifier: "LocationVC") as! LocationVC
//        self.present(locationVC, animated: true, completion: nil)
        
        let autocompleteController = GMSAutocompleteViewController()
        autocompleteController.delegate = self
        
        // Specify the place data types to return.
        //let fields: GMSPlaceField = GMSPlaceField(rawValue: UInt(GMSPlaceField.name.rawValue) |
         //   UInt(GMSPlaceField.placeID.rawValue))!
       // autocompleteController.placeFields = fields
        
        // Specify a filter.
        let filter = GMSAutocompleteFilter()
        filter.type = .address
        autocompleteController.autocompleteFilter = filter
        
        
        // Display the autocomplete view controller.
        present(autocompleteController, animated: true, completion: nil)
        
        
    }
    

    
    //MARK:- Memory Warning Method
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    //MARK:- Location Update Method
    @objc func updateLocation(){
        locationManager.delegate = self
        locationManager.requestAlwaysAuthorization()
    }
    
    //MARK:- IBAction Method
    
    @IBAction func schduleActionTapped(_ sender: UIButton) {
        
        self.scheduleBottomConstraint.constant = 0
        UIView.animate(withDuration: 0.45) {
            self.view.layoutIfNeeded()
        }
    }
    
    @IBAction func scheduleRequest(_ sender: UIButton) {
        isSchduleTime = true
        
        getProfile()
        getAllCard()
        if walletAmount == 0 || cardArray.count == 0 {
            AlertController.alert(title: "Payment", message: "Add money in wallet of card to book a ride.")
        } else {
             app_RateRequest()
        }
       
        self.scheduleBottomConstraint.constant = -300
        UIView.animate(withDuration: 0.45) {
            self.view.layoutIfNeeded()
        }
    }
    
    
    @IBAction func valueChanged(sender: UIDatePicker, forEvent event: UIEvent) {
        let _ = "\(sender.date.getDayMonthYearHourMinutesSecond().day) \(sender.date.getDayMonthYearHourMinutesSecond().month) \(sender.date.getDayMonthYearHourMinutesSecond().year) \(sender.date.getDayMonthYearHourMinutesSecond().minute) \(sender.date.getDayMonthYearHourMinutesSecond().second)"
        
        dateSelected = datePicker.date
        let date = formatter.string(from: datePicker.date)
        scheduleDateTimeLable.text = "\(date)"
    }
    
    @IBAction func menuBtnAction(_ sender: UIButton) {
        self.toggleSlider()
    }
    
    @IBAction func hideScheduleView(_ sender: UIButton) {
        self.scheduleBottomConstraint.constant = -300
        UIView.animate(withDuration: 0.45) {
            self.view.layoutIfNeeded()
        }
    }
    
    @IBAction func currentLocationBtnAction(_ sender: UIButton) {
        mapView.camera = GMSCameraPosition(target: locationCor.coordinate, zoom: 15, bearing: 0, viewingAngle: 0)
    }
    
    
    @IBAction func requestCancelRideBtn(_ sender: UIButton) {
    
        guard let request_id = UserDefaults.standard.string(forKey: "request_id") else {
            print("Error in requestCancelRideBtn")
            return
        }
        
        let param = [
            "request_id" : request_id
        ]
        
        ServiceHelper.sharedInstance.createPostRequest(isShowHud: true, params: param as [String : AnyObject] , apiName: API_CANCEL_REQUEST) { (response, error) in
        
            if response != nil {
                
                UserDefaults.standard.set("" , forKey: "request_id")
                self.requestWaitingView.isHidden = true
                
                self.hideViews(status: false)
                self.mapView.clear()
                self.notifyViewBottomConstraint.constant = -300
                UIView.animate(withDuration: 0.45, animations: {
                    self.view.layoutIfNeeded()
                })
            }
        }
    }
    
    
    @IBAction func rideNowButtonTapped(_ sender: UIButton) {
        
        getAllCard()
        getProfile()
        self.checkSourceLatLong = true
        //self.checkCompleteStatus = false
        if cardArray.count == 0 {
            AlertController.alert(message: "Please add your card to proceed.")
        } else {
            
            if walletAmount == 0 && cardArray.count == 0 {
                AlertController.alert(title: "Payment", message: "Add money in wallet of card to book a ride.")
            } else if usingWallet && walletAmount == 0 {
                AlertController.alert(title: "Wallet", message: "Add wallet amount.")
            } else {
                app_RateRequest()
            }
        }
    }
    
   
    
    @IBAction func callBtnTapped(_ sender: UIButton) {
        if strProviderCell == "" {
            AlertController.alert(title: "Alert", message: "Driver was not provided the number to call.")
        } else {
            callNumber(phoneNumber: strProviderCell)
        }
    }
    
    
    
    @IBAction func changePaymentMode(_ sender: UIButton) {
        
        if sender.currentTitle == "Add" {
            let creditCardVC = mainStoryboard.instantiateViewController(withIdentifier: "CreditCardVC") as! CreditCardVC
            creditCardVC.delegate = self
            self.navigationController?.pushViewController(creditCardVC, animated: true)
        } else {
            let paymentVC = mainStoryboard.instantiateViewController(withIdentifier: "PaymentVC") as! PaymentVC
            paymentVC.delegate = self
            self.navigationController?.pushViewController(paymentVC, animated: true)
        }
        
        
       
    }
    
    
    private func callNumber(phoneNumber:String) {
        
        if let phoneCallURL = URL(string: "tel://\(phoneNumber)") {
            
            let application:UIApplication = UIApplication.shared
            if (application.canOpenURL(phoneCallURL)) {
                application.open(phoneCallURL, options: [:], completionHandler: nil)
            }
        }
    }
    
    
    @IBAction func submitReviewButton(_ sender: Any) {
        
        guard let request_id = UserDefaults.standard.string(forKey: "request_id") else {
            print("Error in requestCancelRideBtn")
            return
        }
        
        
      let param = [
        "request_id": Int(request_id)!,
        "rating": Int(strRating)!,
        "comment": commentText.text!
        ] as [String: Any]
        
        ServiceHelper.sharedInstance.createPostRequest(isShowHud: true, params: param as [String : AnyObject], apiName: API_RATE_PROVIDER) { (response, error) in
            
            
            if error != nil {
                AlertController.alert(title: appName, message: (error?.description)!)
                return
            }
            
            if response != nil {
              
                self.rateToProvider.value = 1
                //self.onClearLatLong()
                self.strRating = "1"
                self.commentText.text = ""
                self.rateToProvider.value = 1
                
                //paid check goes here
                //self.rideNowView.isHidden = false
                self.ratingViewBottomConstraint.constant = -300
                UIView.animate(withDuration: 0.45, animations: {
                    self.view.layoutIfNeeded()
                })
                self.ratingScrollView.isHidden = true
                
                //self.updateUserLocation()
                
            }
        }
    }
    
    
    @IBAction func didChangeRating(_ sender: HCSStarRatingView) {
        strRating = String(format: "%.f", sender.value)
    }
    
    @IBAction func paymentBtnAction(_ sender: UIButton) {
        
            guard let request_id = UserDefaults.standard.string(forKey: "request_id") else {
                print("Error in requestCancelRideBtn")
                return
            }
            
            let param = [
                "request_id" : request_id
            ]
            
            print(param)
            
            ServiceHelper.sharedInstance.createPostRequest(isShowHud: true, params: param as [String : AnyObject], apiName: API_USER_PAYMENT) { (response, error) in
                
                if error != nil {
                    AlertController.alert(title: appName, message: (error?.description)!)
                    return
                }
                
                if response != nil {
                    
                    self.invoiceBottomConstrint.constant = -300
                    UIView.animate(withDuration: 0.45, animations: {
                        self.view.layoutIfNeeded()
                    })
                    
                    self.ratingScrollView.isHidden = false
                    self.ratingViewBottomConstraint.constant = 0
                    UIView.animate(withDuration: 0.45, animations: {
                        self.view.layoutIfNeeded()
                    })
                }
            }
      
        }
        
        
        
}

extension HomeVC : UICollectionViewDelegate , UICollectionViewDataSource , UICollectionViewDelegateFlowLayout{
    
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int{
        return serviceArray.count
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell{
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ServiceCollectionViewCell" , for: indexPath) as! ServiceCollectionViewCell
        
        //cell.kmHeightConstraint.constant = 0
        cell.carNameLabel.text = serviceArray[indexPath.row]["name"].stringValue
        cell.carImage.sd_setImage(with: URL(string: serviceArray[indexPath.row]["image"].stringValue), placeholderImage: #imageLiteral(resourceName: "sedanActiveIcon"))
        cell.carImage.layer.cornerRadius = 21
        cell.carImage.clipsToBounds = true
        
        
        cell.kmLabel.text = serviceArray[indexPath.row]["distance"].stringValue + "Km"
        if let currencySymbol = UserDefaults.standard.value(forKey: "currency") as? String {
             cell.priceLabel.text = currencySymbol + serviceArray[indexPath.row]["price"].stringValue
        }

        if serviceArray[indexPath.row]["isSelected"].boolValue {
            //cell.carImage.frame = CGRect(x: 0, y: 0, width: 15, height:15 )
            //cell.kmHeightConstraint.constant = 20
           // cell.kmHeightConstraint.constant = 15
            cell.carNameLabel.textColor = UIColor.black
            cell.priceLabel.isHidden = false
           // cell.imageHeightConstraint.constant = 15
            cell.backGroundBtn.isHidden = false
        }else {
           // cell.kmHeightConstraint.constant = 0
            cell.carNameLabel.textColor = UIColor.lightGray
            cell.priceLabel.isHidden = true
            //cell.imageHeightConstraint.constant = 20
            cell.backGroundBtn.isHidden = true
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        for (index, _ ) in serviceArray.enumerated() {
            if index == indexPath.row {
                serviceArray[index]["isSelected"] = true
                serviceType = serviceArray[index]["id"].intValue
            } else {
                serviceArray[index]["isSelected"] = false
            }
        }
        
        self.serviceCollectionView.reloadData()
        getProvidersInCurrentLocation()
      
        
       // self.rideNoeBottomConstraint.constant = 0
       //self.rideNowView.isHidden = false

    }
    
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: (WINDOW_WIDTH - 80) / 3 , height: collectionView.frame.size.height )
    }
}

extension HomeVC: CLLocationManagerDelegate,GMSMapViewDelegate {
    
    // MARK: - CLLocationManagerDelegate
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .authorizedAlways, .authorizedWhenInUse:
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.startUpdatingLocation()
        case .denied:
            showAcessDeniedAlert()
        case .notDetermined:
            locationManager.delegate = self
            locationManager.requestAlwaysAuthorization()
        default:
            break
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.first else {
            return
        }
        
        locationCor = location
        reverseGeocodeCoordinate(location.coordinate)
        lat = "\(location.coordinate.latitude)"
        long = "\(location.coordinate.longitude)"
        sourceLat = "\(location.coordinate.latitude)"
        sourceLong = "\(location.coordinate.longitude)"
        
        
         
        //mapView.clear()
       // let marker = PlaceMarker(place: CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude), image: "UserIcon")
        //marker.map = mapView
        mapView.camera = GMSCameraPosition(target: location.coordinate, zoom: 15, bearing: 0, viewingAngle: 0)
        locationManager.stopUpdatingLocation()
    }
    
    // MARK: - MapviewDelegate
    
    func mapView(_ mapView: GMSMapView, didChange position: GMSCameraPosition) {
    }
    
    func mapView(_ mapView: GMSMapView, idleAt position: GMSCameraPosition) {
        reverseGeocodeCoordinate(position.target)
        sourceLat = "\(position.target.latitude)"
        sourceLong = "\(position.target.longitude)"
        
        print(sourceLat,sourceLong)
        //get nearby driver.
    }
    
    private func reverseGeocodeCoordinate(_ coordinate: CLLocationCoordinate2D) {
        
        let geocoder = GMSGeocoder()
        geocoder.reverseGeocodeCoordinate(coordinate) { response, error in
            guard let address = response?.firstResult(), let lines = address.lines else {
                return
            }
            self.locName = lines.joined(separator: "\n")
            self.yourLocationLabel.numberOfLines = 2
            self.yourLocationLabel.text = self.locName
            
            UIView.animate(withDuration: 0.25) {
                self.view.layoutIfNeeded()
            }
        }
    }
    
    func showAcessDeniedAlert() {
        
        let alertController = UIAlertController(title: kLocationAccess,
                                                message: kLocationUnavailable,
                                                preferredStyle: .alert)
        let settingsAction = UIAlertAction(title: "Settings", style: .default) { (alertAction) in
            if let appSettings = URL(string: UIApplicationOpenSettingsURLString) {
                UIApplication.shared.open(appSettings as URL)
            }
            self.navigationController?.popViewController(animated: true)
        }
        alertController.addAction(settingsAction)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel){ (alertAction) in
            self.navigationController?.popViewController(animated: true)
        }
        alertController.addAction(cancelAction)
        present(alertController, animated: true, completion: nil)
    }
    
}

extension HomeVC {
    
//    func onGetFareEstimation() {
//
//        let param = [
//            "s_latitude" : sourceLat,
//            "s_longitude" : sourceLong,
//            "service_type" : serviceType
//
//            ] as [String : Any]
//
//
//        print("ONGETESTIMATION",param)
//        ServiceHelper.sharedInstance.createGetRequest(isShowHud: true, params: param as [String : AnyObject], apiName: API_GET_FARE_ESTIMATION) { (response, error) in
//
//            if error != nil {
//                AlertController.alert(title: appName, message: (error?.description)!)
//                return
//            }
//
//            if response != nil {
//                let jsonResponse = JSON(response as Any)
//
////                self.rideNowView.isHidden = false
////                self.rideNoeBottomConstraint.constant = 0
////                UIView.animate(withDuration: 0.45, animations: {
////                    self.view.layoutIfNeeded()
////                })
////
//            }
//
//        }
//
//
//    }
    
    
    func app_RateRequest() {
        
        var param = [String : Any]()
        var strPay = ""
        var useWallet = "0"
        //Select the payment type ......
        
        
        if strCardID == "" {
            strPay = "CASH"
            useWallet = "1"
        } else {
            strPay = "CARD"
            useWallet = "0"
        }
        
        if isSchduleTime {
            
            isSchduleTime = false
            let dateArr = scheduleDateTimeLable.text?.components(separatedBy: " ")
            let scheduledate = dateArr?[0]
            let scheduleTime = dateArr?[1]
            
            param = [
                "s_latitude" : sourceLat,
                "s_longitude" : sourceLong,
                "service_type" : serviceType,
                "payment_mode" : strPay,
                "card_id" : strCardID,
                "s_address" : self.yourLocationLabel.text!,
                "use_wallet" : useWallet,
                "schedule_date" : scheduledate ?? "",
                "schedule_time" : scheduleTime ?? ""
                
                ] as [String : Any]
            
        } else {
            param = [
                "s_latitude" : sourceLat,
                "s_longitude" : sourceLong,
                "service_type" : serviceType,
                "payment_mode" : strPay,
                "card_id" : strCardID,
                "s_address" : self.yourLocationLabel.text!,
                "use_wallet" : useWallet
                
                ] as [String : Any]
        }
        
       print(param)
        
        ServiceHelper.sharedInstance.createPostRequest(isShowHud: true, params: param as [String : AnyObject], apiName: API_CREATE_REQUEST) { (response, error) in
            
            if error != nil {
                AlertController.alert(title: appName, message: (error?.description)!)
                return
            }
            
            if response != nil {
                let jsonResponse = JSON(response as Any)
                let reqStr = jsonResponse["request_id"].stringValue
                if reqStr == "" || reqStr.length == 0 {
                    //Alert
                    AlertController.alert(title: "Alert!", message: jsonResponse["message"].stringValue)
                } else {
                    UserDefaults.standard.set(reqStr , forKey: "request_id")
                    self.requestWaitingView.isHidden = false
                }
            }
        }
    }
    
    
    
    
    @objc func onRequestCheck() {
        
        ServiceHelper.sharedInstance.createGetRequest(isShowHud: false, params: [:], apiName: API_REQUEST_CHECK) { (response, error) in
            
           if error != nil {
                //AlertController.alert(title: appName, message: (error?.description)!)
                return
            }
            
            if response != nil {
                let jsonResponse = JSON(response as Any)
                let arrLocal = jsonResponse["data"].arrayValue
                
                if arrLocal.count != 0 {
                    
                    let dictVal = arrLocal[0]
                    let statusCheck = dictVal["status"].stringValue
                    let id = dictVal["id"].stringValue
                    var strPayment = ""
                    
                    UserDefaults.standard.set(id , forKey: "request_id")
                    self.globalStatus = statusCheck
                    

                    if statusCheck == "ACCEPTED" {
                        
                        self.labelStatusText.text = "Driver Accepted your request"
                        
                    } else if statusCheck == "STARTED" {
                        self.labelStatusText.text = "Arriving at your location"
                       
                        
                    } else if statusCheck == "ARRIVED" {
                        self.labelStatusText.text = "Arrived to your location"
                    } else if statusCheck == "PICKEDUP" {
                        self.labelStatusText.text = "You are on Ride"
                    }
                    
                    
                    //Getting Payment type ...
                    strPayment = dictVal["payment_mode"].stringValue
                   
                    if strPayment == "CASH" {
                        self.cardImage.image = #imageLiteral(resourceName: "wallet")
                         self.cardNumberLabel.text = "Using Wallet"
                    }
//                    else {
//                        self.cardImage.image = #imageLiteral(resourceName: "visa")
//                         self.cardNumberLabel.text = strPayment
//                    }
                    
                    
                    if statusCheck == "STARTED" || statusCheck == "ARRIVED" || statusCheck == "ACCEPTED" || statusCheck == "PICKEDUP" {
                        self.hideViews(status: true)
                        self.startLocationMarker.isDraggable = false
                        self.endLocationMarker.isDraggable = false
                        self.requestWaitingView.isHidden = true
                        
                        if self.socketConnectFlag {
                            
                        } else {
                            //Connect Socket
                        }
                        
                        let userDictLocal = dictVal["user"]
                        self.userNameStr = userDictLocal["first_name"].stringValue + " " +
                        userDictLocal["last_name"].stringValue
                        
                        
                        //Source ...
                        let sourceLat = dictVal["s_latitude"].doubleValue
                        let sourceLong = dictVal["s_longitude"].doubleValue
                        
                        //Provider.....
                        let dictLocal = dictVal["provider"]
                        var imageURL = dictLocal["avatar"].stringValue
                        
                        if imageURL.contains("http") {
                            imageURL = dictLocal["avatar"].stringValue
                        } else {
                            imageURL = BASE_URL + "public/storage/" + dictLocal["avatar"].stringValue
                        }
                        
                        self.userImgBtn.sd_setImage(with: URL(string: imageURL), for: .normal)
                        self.nameLbl.text = dictLocal["first_name"].stringValue + " " + dictLocal["last_name"].stringValue
                        self.strProviderCell = dictLocal["mobile"].stringValue
                        
                        let lat = dictLocal["latitude"].doubleValue
                        let long = dictLocal["longitude"].doubleValue
                        let navi_location = CLLocationCoordinate2D(latitude: lat, longitude: long)
                        let old = self.markerCarLocation.position
                        let new = navi_location
                        
                      
                        self.markerCarLocation.position = navi_location
                        self.markerCarLocation.icon = #imageLiteral(resourceName: "car")
                        self.markerCarLocation.map = self.mapView
                       
                            
                        CATransaction.begin()
                        CATransaction.animationDuration()
                        self.markerCarLocation.position = navi_location
                        CATransaction.commit()
                        
                       
                        self.makeRoute(sourceLat: navi_location.latitude, sourceLong: navi_location.longitude, destinationLat: sourceLat, destinationLong:  sourceLong, mapView: self.mapView)
                        
                        let getAngle = self.angleFromCoordinate(first: old, toCoordinate: new)
                        self.markerCarLocation.rotation = getAngle * (180 / 3.14159265358979323846264338327950288)
                        
                        
                        //Rating....... Here...
                        
                        
                        let dictServiceType = dictVal["service_type"]
                        let serviceImageUrl =  dictServiceType["image"].stringValue
                        
                        self.ServiceBtn.sd_setImage(with: URL(string: serviceImageUrl), for: .normal)
                        self.lblServiceName.text = dictServiceType["name"].stringValue
                        
                        let carNumberDict = dictVal["provider_service"]
                        let carNumber = carNumberDict["service_number"].stringValue
                        let carModel = carNumberDict["service_model"].stringValue
                        self.lblCarNumber.text = carModel + "\n" + carNumber
                        
                        if statusCheck == "STARTED" || statusCheck == "ACCEPTED" {
                            //Notify View
                            
                            //self.rideNowView.isHidden = true
                            //self.rideNoeBottomConstraint.constant = -300
                            self.notifyViewBottomConstraint.constant = 0
                            UIView.animate(withDuration: 0.45, animations: {
                                self.view.layoutIfNeeded()
                            })
                        } else if statusCheck == "ARRIVED" {
                           // self.rideNowView.isHidden = true
                            self.notifyViewBottomConstraint.constant = 0
                            UIView.animate(withDuration: 0.45, animations: {
                                self.view.layoutIfNeeded()
                            })
                            
                            
                        } else if statusCheck == "PICKEDUP" {
                            self.ringButtonOutlet.isHidden = true
                            self.cancelRequestButtonOutlet.isHidden = true
                        }
                        
                    }
                    else if statusCheck == "DROPPED"  &&
                        (dictVal["paid"].stringValue == "0" ||
                         strPayment == "CARD" ) {
                        
                            let dictPayment = dictVal["payment"]
                            if let currencySymbol = UserDefaults.standard.value(forKey: "currency") as? String {
                                self.baseFareLabel.text = currencySymbol + dictPayment["fixed"].stringValue
                                self.taxlabel.text = currencySymbol + dictPayment["tax"].stringValue
                                self.totatPriceLabel.text = currencySymbol + dictPayment["total"].stringValue
                                self.distanceLable.text = currencySymbol + dictPayment["distance"].stringValue
                                self.walletDeductionLabel.text = currencySymbol + dictPayment["wallet"].stringValue
                                
                                if dictPayment["wallet"].intValue == 0 {
                                    self.walletDeductionStack.isHidden = true
                                }
                                
                                if dictPayment["discount"].intValue == 0 {
                                    self.discountStack.isHidden = true
                                }
                            }
                            
                            self.notifyViewBottomConstraint.constant = -300
                            UIView.animate(withDuration: 0.45, animations: {
                                self.view.layoutIfNeeded()
                            })
                            
                            self.continueToPayOutlet.isHidden = true
                            self.invoiceBottomConstrint.constant = 0
                            UIView.animate(withDuration: 0.45, animations: {
                                self.view.layoutIfNeeded()
                            })
                        
                        
                        
                        
                        
                    } else if statusCheck == "COMPLETED"  {
                        
                        
                            let dictPayment = dictVal["payment"]
                            self.stackviewShowingPaymentType.isHidden = true
                            self.continueToPayOutlet.setTitle("Done", for: .normal)
                            self.continueToPayOutlet.tag = 121
                            
                            if let currencySymbol = UserDefaults.standard.value(forKey: "currency") as? String {
                                self.baseFareLabel.text = currencySymbol + dictPayment["fixed"].stringValue
                                self.taxlabel.text = currencySymbol + dictPayment["tax"].stringValue
                                self.totatPriceLabel.text = currencySymbol + dictPayment["total"].stringValue
                                self.distanceLable.text = currencySymbol + dictPayment["distance"].stringValue
                                self.walletDeductionLabel.text = currencySymbol + dictPayment["wallet"].stringValue
                                
                                if dictPayment["wallet"].intValue == 0 {
                                    self.walletDeductionStack.isHidden = true
                                }
                                
                                if dictPayment["discount"].intValue == 0 {
                                    self.discountStack.isHidden = true
                                }
                                
                            }
                        
                        
                        //For Reviews.....
                        self.lblRateWithName.text = "Rate Your Trip " +  dictVal["provider"]["first_name"].stringValue + " " + dictVal["provider"]["last_name"].stringValue
                        
                        let dictLocal = dictVal["provider"]
                        var imageURL = dictLocal["avatar"].stringValue
                        
                        if imageURL.contains("http") {
                            imageURL = dictLocal["avatar"].stringValue
                        } else {
                            imageURL = BASE_URL + "public/storage/" + dictLocal["avatar"].stringValue
                        }
                        
                        self.ratingProviderImage.sd_setImage(with: URL(string: imageURL), placeholderImage: #imageLiteral(resourceName: "userProfileIcon"))
                        
                        self.mapView.clear()
                        self.hideViews(status: false)
                        
                        
                        //For invoice only....
                        
                        self.invoiceBottomConstrint.constant = -300
                        UIView.animate(withDuration: 0.45, animations: {
                            self.view.layoutIfNeeded()
                        })
                        
                        
                        //paid check goes here
                        self.ratingScrollView.isHidden = false
                        self.ratingViewBottomConstraint.constant = 0
                        UIView.animate(withDuration: 0.45, animations: {
                            self.view.layoutIfNeeded()
                        })
                        
                        
                        
                        
                    }
                        
//                    else  if statusCheck == "COMPLETED" && dictVal["paid"].intValue == 1  { //1
//
//                        self.lblRateWithName.text = "Rate Your Trip " +  dictVal["provider"]["first_name"].stringValue + " " + dictVal["provider"]["last_name"].stringValue
//
//                        let dictLocal = dictVal["provider"]
//                        var imageURL = dictLocal["avatar"].stringValue
//
//                        if imageURL.contains("http") {
//                            imageURL = dictLocal["avatar"].stringValue
//                        } else {
//                            imageURL = BASE_URL + "public/storage/" + dictLocal["avatar"].stringValue
//                        }
//
//                        self.ratingProviderImage.sd_setImage(with: URL(string: imageURL), placeholderImage: #imageLiteral(resourceName: "userProfileIcon"))
//
//                        self.invoiceBottomConstrint.constant = -300
//                        UIView.animate(withDuration: 0.45, animations: {
//                            self.view.layoutIfNeeded()
//                        })
//
//
//                        //Clear mapview
//                        self.mapView.clear()
//                        self.hideViews(status: false)
//
//                        //paid check goes here
//                        self.ratingScrollView.isHidden = false
//                        self.ratingViewBottomConstraint.constant = 0
//                        UIView.animate(withDuration: 0.45, animations: {
//                            self.view.layoutIfNeeded()
//                        })
//
//                    }
                    
                    else if statusCheck == "SEARCHING" {
                        self.requestWaitingView.isHidden = false
                        
                    } else if statusCheck == "CANCELLED" {
                        self.requestWaitingView.isHidden = true
                    }
                    
                    
                } else {
                    
                    
                    if self.globalStatus == "SEARCHING" || self.globalStatus == "STARTED" || self.globalStatus == "ARRIVED" || self.globalStatus == "COMPLETED" {
                        
                        self.globalStatus = ""
                        //self.mapView.clear()
                        
                    }
                    
                    self.mapView.clear()
                    self.hideViews(status: false)
                    self.requestWaitingView.isHidden = true
                    
                    self.ratingViewBottomConstraint.constant = -300
                    UIView.animate(withDuration: 0.45, animations: {
                        self.view.layoutIfNeeded()
                    })
                    
                    self.notifyViewBottomConstraint.constant = -300
                    UIView.animate(withDuration: 0.45, animations: {
                        self.view.layoutIfNeeded()
                    })
                    
                    self.invoiceBottomConstrint.constant = -300
                    UIView.animate(withDuration: 0.45, animations: {
                        self.view.layoutIfNeeded()
                    })
                    
                   // self.mapView.clear()
                }
            }
        }
    }
    
    
    func angleFromCoordinate(first: CLLocationCoordinate2D, toCoordinate second: CLLocationCoordinate2D) -> Double {
        let deltaLongitude = second.longitude - first.longitude
        let deltaLatitude =  second.latitude - first.latitude
        let angle =  (3.14159265358979323846264338327950288 * 0.5) - atan(deltaLatitude/deltaLongitude)
        
        if deltaLongitude > 0 {
            return angle
        } else if deltaLongitude < 0 {
            return angle + 3.14159265358979323846264338327950288
        } else if deltaLatitude < 0 {
            return 3.14159265358979323846264338327950288
        }
        
        return 0.0
    
    }
    
//    func onClearLatLong() {
//
//        sourceLat = ""
//        sourceLong = ""
//        destLat = ""
//        destLong = ""
//
//    }
    
    
    func onGetServices() {
        ServiceHelper.sharedInstance.createGetRequest(isShowHud: true, params: [:], apiName: API_GET_SERVICES) { (response, error) in
            
            if error != nil {
                AlertController.alert(title: appName, message: (error?.description)!)
                return
            }
            
            if response != nil {
                self.serviceArray.removeAll()
                let jsonResponse = JSON(response as Any)
                for (index, var element) in jsonResponse.arrayValue.enumerated() {
                    
                    if index == 0 {
                        element["isSelected"] = true
                        self.serviceType = element["id"].intValue
                    } else {
                        element["isSelected"] = false
                    }
                    
                    self.serviceArray.append(element)
                }
                self.serviceCollectionView.reloadData()
                //self.rideNowView.isHidden = false
            }
        }
    }
    
    func getProvidersInCurrentLocation() {
        
       
        let startLat = String(format: "%.8f",locationCor.coordinate.latitude)
        let startLong = String(format: "%.8f",locationCor.coordinate.longitude)
        
        let param = [
            "latitude" : startLat,
            "longitude": startLong,
            "service" : serviceType
            ] as [String : Any]
        
        ServiceHelper.sharedInstance.createGetRequest(isShowHud: true, params: param as [String : AnyObject], apiName: API_GET_PROVIDER) { (response, error) in
            
            if error != nil {
                AlertController.alert(title: appName, message: (error?.description)!)
                return
            }
            
            if response != nil {
                let jsonResponse = JSON(response as Any)
                let jsonResponseArray = jsonResponse.arrayValue
                
                if jsonResponseArray.count != 0 {
                    for (_, element) in jsonResponseArray.enumerated() {
                        
                        let latStr = element["latitude"].doubleValue
                        let longStr = element["longitude"].doubleValue
                        
                        self.providerMarkers.position = CLLocationCoordinate2D(latitude: latStr, longitude: longStr)
                        self.providerMarkers.groundAnchor = CGPoint(x: 0.5, y: 0.5)
                        self.providerMarkers.isDraggable = false
                        self.providerMarkers.icon = #imageLiteral(resourceName: "car")
                        self.providerMarkers.map = self.mapView
                        
                    }
                }
            } else {
                //HANDLE NIL RESPONSE...
            }
        }
    }
    
    func onMapReload() {
        
        let polyLine = GMSPolyline()
        polyLine.map = nil
        //mapView.clear()
        
        startLocationMarker.map = nil
        startLocationMarker.position = CLLocationCoordinate2D(latitude: Double(sourceLat) ?? 0.0, longitude: Double(sourceLong) ?? 0.0)
        startLocationMarker.icon = #imageLiteral(resourceName: "ub__ic_pin_pickup")
        startLocationMarker.groundAnchor = CGPoint(x: 0.5, y: 0.5)
        startLocationMarker.isDraggable = true
        startLocationMarker.userData = "PICKUP"
        startbounds.includingCoordinate(startLocationMarker.position)
        startLocationMarker.map = mapView
        
        endLocationMarker.map = nil
        endLocationMarker.position = CLLocationCoordinate2D(latitude: Double(sourceLat) ?? 0.0, longitude: Double(sourceLong) ?? 0.0)
        endLocationMarker.icon = #imageLiteral(resourceName: "ub__ic_pin_dropoff")
        endLocationMarker.groundAnchor = CGPoint(x: 0.5, y: 0.5)
        endLocationMarker.isDraggable = true
        endLocationMarker.userData = "DROP"
        endbounds.includingCoordinate(endLocationMarker.position)
        endLocationMarker.map = mapView
        
    }
    
    
    
    func makeRoute(sourceLat: Double, sourceLong: Double, destinationLat: Double, destinationLong: Double, mapView:GMSMapView){
        
        
        let source = "\(sourceLat),\(sourceLong)"
        let dest = "\(destinationLat),\(destinationLong)"
        
        if (reachability?.isReachable)! {
            
            let url = "https://maps.googleapis.com/maps/api/directions/json?origin=\(source)&destination=\(dest)&mode=driving&key=\(GMSPLACES_KEY)"
            
            Alamofire.request(url).responseJSON { response in
                
                debugPrint(response)
                if response.result.value != nil{
                    
                    self.sourceMarker.position = CLLocationCoordinate2D(latitude: sourceLat, longitude: sourceLong)
                    //self.sourceMarker.map = self.mapView
                    
                    self.destMarker.position = CLLocationCoordinate2D(latitude: destinationLat, longitude: destinationLong)
                    self.destMarker.map = self.mapView
               
                    
                    if let json = response.result.value! as? NSDictionary{
                        if let routes = json["routes"] as? NSArray{
                            
                            for route in routes
                            {
                                
                                
                                let routeOverviewPolyline:NSDictionary = (route as! NSDictionary).value(forKey: "overview_polyline") as! NSDictionary
                                let points = routeOverviewPolyline.object(forKey: "points") as! String
                                if let path = GMSPath.init(fromEncodedPath: points){
                                    
                                    
                                    self.polyline.map = nil
                                    self.polyline = GMSPolyline(path: path)
                                    self.polyline.strokeColor = .lightGray
                                    self.polyline.strokeWidth = 3.0
                                    self.polyline.map = mapView
                                    
                                    self.polylineTimer.invalidate()
                                    self.polylineTimer = Timer.scheduledTimer(withTimeInterval: 0.005, repeats: true, block: { timer in
                                        self.animate(path)
                                    })
                                    
                                    let bounds = GMSCoordinateBounds(path: path)
                                    let cameraUpdate = GMSCameraUpdate.fit(bounds, with: UIEdgeInsets(top: 70, left: 50, bottom: 70, right: 50))
                                    mapView.animate(with: cameraUpdate)
                                    
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    
    func animate(_ path: GMSPath) {
        DispatchQueue.main.async {
            let pathCount = path.count()
            if self.i < pathCount {
                self.path2.add(path.coordinate(at: UInt(self.i)))
                self.polylineBlack = GMSPolyline(path: self.path2)
                self.polylineBlack.strokeColor = #colorLiteral(red: 0.2233502538, green: 0.2233502538, blue: 0.2233502538, alpha: 1)
                self.polylineBlack.strokeWidth = 3
                self.polylineBlack.map = self.mapView
                self.arrayPolylineBlack.add(self.polylineBlack)
                self.i += 1
            } else {
                self.i = 0
                self.path2 = GMSMutablePath()
                self.polylineTimer.invalidate()
            }
        }
    }
    
}


extension HomeVC: GMSAutocompleteViewControllerDelegate {
    
    // Handle the user's selection.
    func viewController(_ viewController: GMSAutocompleteViewController, didAutocompleteWith place: GMSPlace) {
//        print("Place name: \(place.name)")
//        print("Place ID: \(place.placeID)")
//        print("Place attributions: \(place.attributions)")
        sourceLat = "\(place.coordinate.latitude)"
        sourceLong = "\(place.coordinate.longitude)"
        mapView.camera = GMSCameraPosition(target: place.coordinate, zoom: 15, bearing: 0, viewingAngle: 0)
        print(sourceLat,sourceLong)
        yourLocationLabel.text = place.name
        dismiss(animated: true, completion: nil)
    }
    
    func viewController(_ viewController: GMSAutocompleteViewController, didFailAutocompleteWithError error: Error) {
        // TODO: handle the error.
        print("Error: ", error.localizedDescription)
    }
    
    // User canceled the operation.
    func wasCancelled(_ viewController: GMSAutocompleteViewController) {
        dismiss(animated: true, completion: nil)
    }
    
    // Turn the network activity indicator on and off again.
    func didRequestAutocompletePredictions(_ viewController: GMSAutocompleteViewController) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
    }
    
    func didUpdateAutocompletePredictions(_ viewController: GMSAutocompleteViewController) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
    }
    
    
    func hideViews(status: Bool) {
        userPinImgOutlet.isHidden = status
        serviceView.isHidden = status
        yourLocationView.isHidden = status
    }
    
    
}

extension HomeVC: CardDetailsSend, updateCards  {
    
    func updateYourCards() {
        getAllCard()
    }
    
    func onChangePaymentMode(_ choosedPayment: JSON) {
        print("Chooseed payment",choosedPayment)
        
        strCardID =  choosedPayment["card_id"].stringValue
        strCardLastNo = choosedPayment["last_four"].stringValue
        
       
        
        if strCardID == "" {
            cardImage.image = #imageLiteral(resourceName: "wallet")
            cardNumberLabel.text = "Using Wallet"
            usingWallet = true
        } else {
            cardImage.image = #imageLiteral(resourceName: "visa")
            cardNumberLabel.text = "**** **** **** " + strCardLastNo
        }
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
                
                if self.cardArray.count == 0 {
                    self.cardImage.image = #imageLiteral(resourceName: "wallet")
                    self.cardNumberLabel.text = "Use Wallet"
                    self.changeCard.setTitle("Add", for: .normal)
                    
                } else {
                    
                    if self.strCardID == "" {
                        self.cardImage.image = #imageLiteral(resourceName: "wallet")
                        self.cardNumberLabel.text = "Using Wallet"
                    } else {
                        self.cardImage.image = #imageLiteral(resourceName: "visa")
                        self.cardNumberLabel.text = "**** **** **** " + self.cardArray[0]["last_four"].stringValue
                        self.strCardID =  self.cardArray[0]["card_id"].stringValue
                        self.strCardLastNo = self.cardArray[0]["last_four"].stringValue
                        self.usingWallet = false
                        self.changeCard.setTitle("Change", for: .normal)
                    }
                    
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
               
                   self.walletAmount =  jsonResponse["wallet_balance"].intValue
               
            }
        }
    }
}

