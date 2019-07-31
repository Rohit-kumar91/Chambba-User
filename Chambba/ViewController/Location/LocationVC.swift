//
//  LocationVC.swift
//  Chambba
//
//  Created by Rohit Kumar on 20/03/19.
//  Copyright © 2019 Mayur chaudhary. All rights reserved.
//

import UIKit
import SwiftyJSON
import CoreLocation
import GoogleMaps
import GooglePlaces


class LocationVC: UIViewController, GMSMapViewDelegate, GMSAutocompleteFetcherDelegate {

    var searchLocationArray = [JSON]()
    var gotLocation = Bool()
    let locationManager = CLLocationManager()
    var myLocation = CLLocation()
    
    var cityNameArray = [String]()
    var placeIdArray = [String]()
    var primaryTextArray = [String]()
    var strSourceLat =  String()
    var strSourceLong = String()
    var strSourceAddress = String()
    var fetcher = GMSAutocompleteFetcher()
    var filter = GMSAutocompleteFilter()
    var locationFilter = GMSAutocompleteFilter()

    var geoCoder = CLGeocoder()
    
    let apiUrl = "https://maps.googleapis.com/maps/api/place/details/json?reference=%@&sensor=true&key=%@"
    let GOOGLEPLACE_API_KEY = "AIzaSyC0v7B3dTnPzXQZctHopABacilfcDxeMC8"
    
    @IBOutlet weak var fromText: UITextField!
    @IBOutlet weak var locationTableview: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        onLocationUpdateStart()
        self.fetcher.delegate = self
        
    }

    @IBAction func backButonTapped(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
}



extension LocationVC: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cityNameArray.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "LocationCell", for: indexPath) as! LocationCell
        
        var centerNameStr = String()
        var fullAddressStr = String()
        
        if cityNameArray.count > 0 {
            centerNameStr = primaryTextArray[indexPath.row]
            fullAddressStr = cityNameArray[indexPath.row]
        }
        
        cell.textLabel?.text = centerNameStr
        cell.detailTextLabel?.text = fullAddressStr
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let placeIdStr = placeIdArray[indexPath.row]
        getPlaceDetailForReferance(strReferance: placeIdStr)
    }
    
    func getPlaceDetailForReferance(strReferance: String) {
        
//        let completeUrl = apiUrl + strReferance + GOOGLEPLACE_API_KEY
        GMSPlacesClient.shared().lookUpPlaceID(strReferance) { (place, error) in
            let latitude = place?.coordinate.longitude
            let longitude = place?.coordinate.longitude
            
            let center = CLLocationCoordinate2DMake(latitude ?? 0.0, longitude ?? 0.0)
            let northEast = CLLocationCoordinate2DMake(center.latitude + 0.001, center.longitude + 0.001)
            let southEast = CLLocationCoordinate2DMake(center.latitude - 0.001, center.longitude - 0.001)
            let bounds = GMSCoordinateBounds(coordinate: northEast, coordinate: southEast)
            //self.fetcher = GMSAutocompleteFetcher(bounds: bounds, filter: self.filter)
            self.fetcher.delegate = self
            
            self.fromText.text = place?.formattedAddress
            self.strSourceLat = String(format: "%f", latitude!)
            self.strSourceLong = String(format: "%f", longitude!)
            self.fromText.becomeFirstResponder()

        }
    }
}

extension LocationVC : CLLocationManagerDelegate {
    
    func onLocationUpdateStart() {
        locationManager.distanceFilter = kCLDistanceFilterNone
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.requestAlwaysAuthorization()
        locationManager.startMonitoringSignificantLocationChanges()
        locationManager.startUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.first else {
            return
        }
        locationManager.stopUpdatingLocation()
        myLocation = location
        
        let center = CLLocationCoordinate2DMake(location.coordinate.latitude, location.coordinate.longitude)
        let northEast = CLLocationCoordinate2DMake(center.latitude + 0.001, center.longitude + 0.001)
        let southEast = CLLocationCoordinate2DMake(center.latitude - 0.001, center.longitude - 0.001)
        let bounds = GMSCoordinateBounds(coordinate: northEast, coordinate: southEast)
        //self.fetcher = GMSAutocompleteFetcher(bounds: bounds, filter: self.locationFilter)
        
        
        self.strSourceLat = String(format: "%.8f", location.coordinate.latitude)
        self.strSourceLong = String(format: "%.8f", location.coordinate.longitude)
        
        geoCoder.reverseGeocodeLocation(location) { (placemark, error) in
            if error == nil && (placemark?.count)! > 0 {
                let placemark = placemark?.last
                
                guard let name = placemark?.name else {
                    return
                }
                
                guard let locality = placemark?.locality else {
                    return
                }
                
                guard let subAdministrativeArea = placemark?.subAdministrativeArea else {
                    return
                }
                
                self.strSourceAddress = name + "," + locality + "," + subAdministrativeArea
                self.fromText.text = self.strSourceAddress
            }
        }
    }
    
}
extension LocationVC : UITextFieldDelegate {
    
    
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
       let updatedText = (textField.text as NSString?)?.replacingCharacters(in: range, with: string) ?? string
        
        
        if updatedText.count == 0 {
            
            cityNameArray.removeAll()
            placeIdArray.removeAll()
            primaryTextArray.removeAll()
            fetcher.sourceTextHasChanged("")
            
        } else {
            
            let updatedText = (textField.text as NSString?)?.replacingCharacters(in: range, with: string) ?? string
            
            if updatedText.count > 50 {
                return false
            }
            
            let newString = (textField.text as NSString?)?.replacingCharacters(in: range, with: string) ?? string
            fetcher.sourceTextHasChanged(newString)
        }
        
        return true
    }
    
    func didAutocomplete(with predictions: [GMSAutocompletePrediction]) {
        print("Prediction..", predictions)
        cityNameArray.removeAll()
        placeIdArray.removeAll()
        primaryTextArray.removeAll()
        
        if predictions.count != 0 {
            for prediction in predictions {
                primaryTextArray.append(prediction.attributedPrimaryText.string)
                cityNameArray.append(prediction.attributedFullText.string)
                placeIdArray.append(prediction.placeID)
            }
        }
        
        
        //Reload tableview.....
        self.locationTableview.reloadData()
        
    }
    
    func didFailAutocompleteWithError(_ error: Error) {
        print("Autocomplete Error", error)
    }
    
}

