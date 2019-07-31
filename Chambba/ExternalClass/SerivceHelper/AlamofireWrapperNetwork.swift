//
//  AlamofireWrapperNetwork.swift
//  WheyPoint
//
//  Created by Rishabh Arora on 10/31/18.
//  Copyright © 2017 Rishabh Arora. All rights reserved.
//

import Foundation
import UIKit
import Alamofire


class AlamoFireWrapperNetwork{
    
    class var sharedInstance: AlamoFireWrapperNetwork{
        struct Singleton{
            static let instance = AlamoFireWrapperNetwork()
        }
        return Singleton.instance
    }
    private init(){}
    
    
    //MARK:- Get Categories List Function
    func GetDataAlamofire(url:String, isHide:Bool? = true,success: @escaping JSONDictionaryResponseCallback, failure: @escaping APIServiceFailureCallback) {
        debugPrint(BASE_URL + "\(url)")
        let header : [String : String] = self.setHeaders(url)
        Alamofire.request(BASE_URL+"\(url)", method: .get, parameters: nil, encoding: JSONEncoding.default, headers: header).responseJSON {
            (response:DataResponse<Any>) in
//            if isHide!{
//                applicationDelegate.hideIndicator()
//            }
            switch(response.result) {
            case .success(_):
                if response.response?.statusCode == 401{
                   // self.goToInitialVc()
                }
                else{
                    if response.result.value != nil{
                        if let responseDict = response.result.value as? JSONDictionary {
                            success(responseDict)
                        }
                    }
                }
                break
            case .failure(_):
                failure(response.result.error)
                break
            }
        }
    }
    
    func setHeaders(_ apiName : String) -> [String : String]
    {
        var header = [String : String]()
        header["X-Requested-With"] = "XMLHttpRequest"
        var accessTokenValue = ""
        var tokenValue = ""
        if let accessToken = UserDefaults.standard.value(forKey: ACCESS_TOKEN){
            accessTokenValue = accessToken as! String
        }
        if let tokenvalue = UserDefaults.standard.value(forKey: TOKEN_TYPE){
            tokenValue = tokenvalue as! String
        }
        let fullTokenValue = tokenValue + " " + accessTokenValue
        
        if accessTokenValue.count != 0 {
            header["Authorization"] = fullTokenValue
        }
        
        return header
    }
    
    func PostDataAlamofire(_ parameters:[String : Any]? = nil,url:String,success:  @escaping JSONDictionaryResponseCallback, failure: @escaping APIServiceFailureCallback) {
        let header : [String : String] = self.setHeaders(url)

        Alamofire.request(BASE_URL+"\(url)", method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: header).responseJSON {
            (response:DataResponse<Any>) in
            APPDELEGATE.hideIndicator()
            switch(response.result) {
            case .success(_):
                if response.response?.statusCode == 401{
                   // self.goToInitialVc()
                }
                else{
                    if response.result.value != nil{
                        if let responseDict = response.result.value as? JSONDictionary {
                            success(responseDict)
                        }
                    }
                }
                break
            case .failure(_):
                failure(response.result.error)
                break
            }
        }
    }
    
    //MARK:- Post Multipart Data Function
    
    func PostMultipartData(_ parameters:[String : String]? = nil,url:String, imageSingle:UIImage? = nil,success:  @escaping JSONDictionaryResponseCallback, failure: @escaping APIServiceFailureCallback) {
        let header : [String : String] = self.setHeaders(url)

        Alamofire.upload(multipartFormData: { multipartFormData in
            let imageName = Date().timeIntervalSince1970
            if let myImage = imageSingle{
                let imageData = UIImagePNGRepresentation(myImage)
                if imageData != nil{
                multipartFormData.append(imageData!, withName: image,fileName: "\(imageName).png", mimeType: "image/jpeg")
                }
            }
           
            if parameters != nil{
                for (key, value) in parameters! {
                    multipartFormData.append((value).data(using: String.Encoding.utf8)!, withName: key)
                }
            }
        },to:BASE_URL+"\(url)")
        { (result) in
            //applicationDelegate.hideIndicator()
            switch(result) {
            case .success(let upload, _, _):
                
                upload.uploadProgress(closure: { (progress) in
                    debugPrint(progress)
                })
                
                upload.responseJSON { response in
                    if response.response?.statusCode == 401{
                        //self.goToInitialVc()
                    }
                    else{
                        if let responseDict = response.result.value as? JSONDictionary {
                            success(responseDict)
                        }
                    }
                }
                break
            case .failure(_):
                break
            }
        }
    }
    
    func PostMultipartDataMultiple(_ parameters:[String : String]? = nil,url:String, headers:[String:String]? = nil, imageArray:NSMutableArray,success:  @escaping JSONDictionaryResponseCallback, failure: @escaping APIServiceFailureCallback) {
        
        Alamofire.upload(multipartFormData: { multipartFormData in
            if imageArray.count>0{
                for (index,obj) in imageArray.enumerated(){
                    let imageName = Date().timeIntervalSince1970
                    let myImage = obj as? UIImage
                    let imageData = UIImagePNGRepresentation(myImage!)
                    let productNo = index + 1
                    if let unwrappedData = imageData{
                        multipartFormData.append(unwrappedData, withName: "product_image[\(productNo)]",fileName: "\(imageName).png", mimeType: "image/jpeg")
                    }}
            }
            if parameters != nil{
                for (key, value) in parameters! {
                    multipartFormData.append((value).data(using: String.Encoding.utf8)!, withName: key)
                }
            }
        },to:BASE_URL+"\(url)")
        { (result) in
            APPDELEGATE.hideIndicator()
            switch(result) {
            case .success(let upload, _, _):
                
                upload.uploadProgress(closure: { (progress) in
                    debugPrint(progress)
                })
                
                upload.responseJSON { response in
                    if response.response?.statusCode == 401{
                       // self.goToInitialVc()
                    }
                    else{
                        if let responseDict = response.result.value as? JSONDictionary {
                            success(responseDict)
                        }
                    }
                }
                break
            case .failure(_):
                break
            }
        }
    }

    func createRequestToUploadMultipleDataWithString(additionalParams : Dictionary<String,Any>,header:[String:String]? = nil, imageList: [UIImage],apiName : String,completion: @escaping (_ response: AnyObject?, _ error: NSError?) -> Void) {
        
        let URL = try! URLRequest(url: BASE_URL + apiName, method: .post, headers: header)
        
        Alamofire.upload(multipartFormData: { (multipartData) in
            for (key,value) in additionalParams {
                multipartData.append("\(value)".data(using: .utf8)!, withName: key)
            }
            if imageList.count > 0{
                for index in 0...imageList.count-1{
                    let imageData = UIImageJPEGRepresentation(imageList[index], 0.5)!
                    multipartData.append(imageData, withName: "image[\(index)]", fileName: "image\(index+1).jpg", mimeType: "image/jpeg")
                }
            }
            
        }, with: URL) { (result) in
            switch result {
            case .success(let upload, _, _):
                upload.responseJSON { response in
                    print("Success ------ \(response)")
                    if response.response?.statusCode == 200 {
                        if let jsonData = response.result.value as? NSDictionary {
                            let status = jsonData.value(forKey: "status") as? NSNumber
                            if (status == 203){
                            }else {
                                completion(response.result.value as AnyObject?, nil)
                            }
                        }else {
                            completion(nil, response.result.error as NSError?)
                        }
                    }else {
                        completion(nil, response.result.error as NSError?)
                    }
                }
                break
                
            case .failure(let encodingError):
                print("Error ------- \(encodingError)")
                completion(nil, encodingError as NSError?)
                break
            }
        }
    }
    
}
