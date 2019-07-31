//
//  LanguageSelectionViewController.swift
//  KawafilShipper
//
//  Created by Mayur chaudhary on 08/06/18.
//  Copyright © 2018 Ashish Kumar singh. All rights reserved.
//


import UIKit
import CoreLocation

let isDeviceHasCamera = UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.camera)
let USERDEFAULT = UserDefaults.standard

let showLog = true

let kWindowWidth = UIScreen.main.bounds.size.width
let kWindowHeight = UIScreen.main.bounds.size.height

struct DeviceType {
  static let IS_IPHONE_4_OR_LESS  = UIDevice.current.userInterfaceIdiom == .phone && ScreenSize.SCREEN_MAX_LENGTH < 568.0
  static let IS_IPHONE_5          = UIDevice.current.userInterfaceIdiom == .phone && ScreenSize.SCREEN_MAX_LENGTH == 568.0
  static let IS_IPHONE_6          = UIDevice.current.userInterfaceIdiom == .phone && ScreenSize.SCREEN_MAX_LENGTH == 667.0
  static let IS_IPHONE_6P         = UIDevice.current.userInterfaceIdiom == .phone && ScreenSize.SCREEN_MAX_LENGTH == 736.0
  static let IS_IPHONE_X          =  UIDevice.current.userInterfaceIdiom == .phone && ScreenSize.SCREEN_MAX_LENGTH == 812.0
  static let IS_IPAD              = UIDevice.current.userInterfaceIdiom == .pad && ScreenSize.SCREEN_MAX_LENGTH == 1024.0
  static let IS_IPAD_PRO          = UIDevice.current.userInterfaceIdiom == .pad && ScreenSize.SCREEN_MAX_LENGTH == 1366.0
}


struct ScreenSize {
  
  static let SCREEN_WIDTH         = UIScreen.main.bounds.size.width
  static let SCREEN_HEIGHT        = UIScreen.main.bounds.size.height
  static let SCREEN_MAX_LENGTH    = max(ScreenSize.SCREEN_WIDTH, ScreenSize.SCREEN_HEIGHT)
  static let SCREEN_MIN_LENGTH    = min(ScreenSize.SCREEN_WIDTH, ScreenSize.SCREEN_HEIGHT)
}



// MARK: - Useful functions

func RGBA(r: CGFloat, g: CGFloat, b: CGFloat, a: CGFloat) -> UIColor {
    return UIColor(red: (r/255.0), green: (g/255.0), blue: (b/255.0), alpha: a)
}

var timeStamp: String{
    let time = String(format: "%0.0f", Date().timeIntervalSince1970 * 1000)
    return time
}

func dateMethod(dateFormat : String) -> String{
    let formatter = DateFormatter()
    formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssxxxxx"
    
    if let dateFromString = formatter.date(from: dateFormat) {
        formatter.dateFormat = "dd/MM/YYYY" //which format is needed
        let stringFromDate = formatter.string(from: dateFromString)
        return stringFromDate
    }
    return ""
}

func imageIsNullOrNot(imageName : UIImage)-> Bool
{
    let size = CGSize(width: 0, height: 0)
    if (imageName.size.width == size.width)
    {
        return false
    }
    else
    {
        return true
    }
}
func getDateFromTimestamp(_ timestamp: Double) -> String {
    
    let current = Date()
    let objDateFormatter = DateFormatter()
    objDateFormatter.dateFormat = "YYYY"
    //  let currentYear: String = objDateFormatter.string(from: current)
    let date = Date(timeIntervalSince1970: timestamp / 1000)  // /1000
    let dateFormatter = DateFormatter()
    let dateFormatter1 = DateFormatter()
    dateFormatter1.dateFormat = "YYYY"
    // let year: String = dateFormatter1.string(from: date)
    dateFormatter.dateFormat = "MMM"
    var dateString1: String = dateFormatter.string(from: date)
    dateString1 = "\(dateString1)"
    
    let distanceBetweenDates: TimeInterval = current.timeIntervalSince(date)
    let min: Int = Int(distanceBetweenDates) / 60
    let gregorianCalendar = Calendar(identifier: .gregorian)
    //            var components: DateComponents? = gregorianCalendar.dateComponents(.day, from: date, to: current, options:.wrapComponents)
    let components = gregorianCalendar.dateComponents([.day], from: date, to: current)
    //   var components: DateComponents? = (gregorianCalendar as NSCalendar).components(.day, from: date)
    
    let noOfDay: Int? = components.day
    
    if min <= 59 {
        if min < 1 {
            return "Just Now"
        }
        else if min == 1 {
            return "\(min) min ago"
        }
        else {
            return "\(min) mins ago"
        }
    }
    else if (min / 60) <= 23 {
        if (min / 60) == 1 {
            return "\(min / 60) hr ago"
        }
        else {
            return "\(min / 60) hrs ago"
        }
    }
    else if noOfDay! < 31 {
        if noOfDay! <= 1 {
            return "\(noOfDay!) day ago"
        }
        else {
            return "\(noOfDay!) days ago"
        }
    }
    else if noOfDay! < 365{
        let noOfMonth : Int = noOfDay! / 30
        if noOfMonth <= 1 {
            return "\(noOfMonth) month ago"
        }
        else {
            return "\(noOfMonth) months ago"
        }
    }
    else {
        let noOfYear : Int = noOfDay! / 365
        if noOfYear <= 1 {
            return "\(noOfYear) year ago"
        }else{
            return "\(noOfYear) years ago"
        }
        //                    if (year == currentYear) {
        //                        return "\(dateString1)"
        //                    }
        //                    else {
        //                      return "\(dateString1), \(year)"
        //                    }
    }
}

func getAddressFromLatLon(pdblLatitude: Double, withLongitude pdblLongitude: Double, completionHandler: @escaping (_ address:String) -> Void){
    
    var center : CLLocationCoordinate2D = CLLocationCoordinate2D()
    let ceo: CLGeocoder = CLGeocoder()
    center.latitude = pdblLatitude
    center.longitude = pdblLongitude
    
    let loc: CLLocation = CLLocation(latitude:center.latitude, longitude: center.longitude)
    var addressString : String = ""
    
    ceo.reverseGeocodeLocation(loc, completionHandler:
        {(placemarks, error) in
            if (error != nil){
                print("reverse geodcode fail: \(error!.localizedDescription)")
            }
            if placemarks != nil{
                let pm = placemarks! as [CLPlacemark]
                if pm.count > 0 {
                    
                    let pm = placemarks![0]
                    if pm.name != nil {
                         addressString = addressString + pm.name! + ", "
                    }
                    if pm.subLocality != nil{
                        addressString = addressString + pm.subLocality! + ", "
                       
                    }
                    if pm.thoroughfare != nil{
                        addressString = addressString + pm.thoroughfare! + ", "
                    }
                    if pm.locality != nil{
                        addressString = addressString + pm.locality! + ", "
                    }
                    if pm.country != nil {
                        addressString = addressString + pm.country! + ", "
                    }
                    if pm.postalCode != nil {
                        addressString = addressString + pm.postalCode! + " "
                    }
                    completionHandler(addressString)
                }
            }
            
    })
}

func attributedPlaceholder(string : String) -> NSAttributedString{
    return NSAttributedString(string: string,
                              attributes: [NSAttributedStringKey.foregroundColor: UIColor.darkGray])
}

func addDoneToolBarOnTextfield(textField: UITextField, target: UIViewController) -> UIToolbar {
    
    let numberToolbar = UIToolbar.init(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 50))
    numberToolbar.barStyle = UIBarStyle.default
    numberToolbar.items = [UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: nil, action: nil),
        UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: nil, action: nil),
        UIBarButtonItem(title:"Done", style: UIBarButtonItemStyle.plain, target: target, action: Selector(("doneButtonMethod")))
        
    ]
    
    numberToolbar.sizeToFit()
    return numberToolbar
}
func addToolNextBarOnTextfield(textField: UITextField, target: UIViewController) -> UIToolbar {
    
    let numberToolbar = UIToolbar.init(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 50))
    numberToolbar.barStyle = UIBarStyle.default
    numberToolbar.items = [
        UIBarButtonItem(title:"", style: UIBarButtonItemStyle.plain, target: target, action: Selector(("doneButtonMethod"))),
        UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: nil, action: nil),
        UIBarButtonItem(title:"Next", style: UIBarButtonItemStyle.plain, target: target, action: Selector(("nextButtonMethod")))
        
    ]
    
    numberToolbar.sizeToFit()
    return numberToolbar
}

func doneButtonMethod() {
}

func nextButtonMethod() {
}

//get string from date Method
func getStringFromDate(date : Date) -> String {
    let dateFormat = DateFormatter.init()
    dateFormat.timeZone = NSTimeZone.local
    dateFormat.dateFormat = "MM/dd/YYYY"
    return dateFormat.string(from: date)
}

// custom log
func logInfo(message: String, file: String = #file, function: String = #function, line: Int = #line, column: Int = #column) {
    if (showLog) {
        print("\(function): \(line): \(message)")
    }
}

// MARK:- Dictionary Extensions >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

extension Dictionary {
    mutating func unionInPlace(
        _ dictionary: Dictionary<Key, Value>) {
        for (key, value) in dictionary {
            self[key] = value
        }
    }
    
    mutating func unionInPlace<S: Sequence>(_ sequence: S) where S.Iterator.Element == (Key,Value) {
        for (key, value) in sequence {
            self[key] = value
        }
    }
    
    func validatedValue(_ key: Key, expected: AnyObject) -> AnyObject {
        
        // checking if in case object is nil
        
        if let object = self[key] as? AnyObject{
            
            // added helper to check if in case we are getting number from server but we want a string from it
            if object is NSNumber && expected is String {
                
                //logInfo("case we are getting number from server but we want a string from it")
                
                return "\(object)" as AnyObject
            }
                
                // checking if object is of desired class
            else if (object.isKind(of: expected.classForCoder) == false) {
                //logInfo("case // checking if object is of desired class....not")
                
                return expected
            }
                
                // checking if in case object if of string type and we are getting nil inside quotes
            else if object is String {
                if ((object as! String == "null") || (object as! String == "<null>") || (object as! String == "(null)")) {
                    //logInfo("null string")
                    return "" as AnyObject
                }
            }
            
            return object
        }
        else {
            
            if expected is String || expected as! String == "" {
                return "" as AnyObject
            }
            
            return expected
        }
    }
    
}

extension UIImageView {
    public func imageFromURL(urlString: String) {
        
        let activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: .gray)
        activityIndicator.frame = CGRect.init(x: 0, y: 0, width: self.frame.size.width, height: self.frame.size.height)
        activityIndicator.startAnimating()
        if self.image == nil{
            self.addSubview(activityIndicator)
        }
        
        if !urlString.isEmpty {
        URLSession.shared.dataTask(with: NSURL(string: urlString)! as URL, completionHandler: { (data, response, error) -> Void in
            
            if error != nil {
                print(error ?? "No Error")
                return
            }
            DispatchQueue.main.async(execute: { () -> Void in
                let image = UIImage(data: data!)
                activityIndicator.removeFromSuperview()
                self.image = image
            })
            
        }).resume()
        }
    }
}

extension String {
    var htmlToAttributedString: NSAttributedString? {
        guard let data = data(using: .utf8) else { return NSAttributedString() }
        do {
            return try NSAttributedString(data: data, options: [.documentType: NSAttributedString.DocumentType.html, .characterEncoding:String.Encoding.utf8.rawValue], documentAttributes: nil)
        } catch {
            return NSAttributedString()
        }
    }
    var htmlToString: String {
        return htmlToAttributedString?.string ?? ""
    }
    
  
    
    func isValidUserName() -> Bool {
        let nameRegEx = "^[a-zA-Z0-9._]+$"
        let nameTest = NSPredicate(format:"SELF MATCHES %@", nameRegEx)
        return nameTest.evaluate(with: self)
    }
    
    func containsNumberOnly() -> Bool {
        let nameRegEx = "^[0-9]+$"
        let nameTest = NSPredicate(format:"SELF MATCHES %@", nameRegEx)
        return nameTest.evaluate(with: self)
    }
    
    func isContainsAllZeros() -> Bool {
        let mobileNoRegEx = "^0*$";
        let mobileNoTest = NSPredicate(format:"SELF MATCHES %@", mobileNoRegEx)
        return mobileNoTest.evaluate(with: self)
    }

    var trimWhiteSpace: String {
        let trimmedString = self.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        return trimmedString
    }
    
    var isEmail: Bool {
        let regex = try? NSRegularExpression(pattern: "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}", options: .caseInsensitive)
        return regex?.firstMatch(in: self, options: [], range: NSMakeRange(0, self.count)) != nil
    }
    
    var length: Int {
        return self.count
    }
    
}
extension UITextField{
    @IBInspectable var placeHolderColor: UIColor? {
        get {
            return self.placeHolderColor
        }
        set {
            self.attributedPlaceholder = NSAttributedString(string:self.placeholder != nil ? self.placeholder! : "", attributes:[NSAttributedStringKey.foregroundColor: newValue!])
        }
    }
  
    func setLeftPaddingPoints(_ amount:CGFloat){
            let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: amount, height: self.frame.size.height))
            self.leftView = paddingView
            self.leftViewMode = .always
    }
    func setRightPaddingPoints(_ amount:CGFloat){
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: amount, height: self.frame.size.height))
        self.rightView = paddingView
        self.rightViewMode = .always
    }
    
  
    
}

extension NSMutableAttributedString {
    
    func setColorForText(textForAttribute: String, withColor color: UIColor) {
        let range: NSRange = self.mutableString.range(of: textForAttribute, options: .caseInsensitive)
        self.addAttribute(NSAttributedStringKey.foregroundColor, value: color, range: range)
    }
    
}

class AppUtility: NSObject {
    
    class func deviceUDID() -> String {
        var udidString = ""
        if let udid = UIDevice.current.identifierForVendor?.uuidString {
            udidString = udid
        }
        return udidString
    }
   
}

