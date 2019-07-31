//
//  Constant.swift
//  Abba Taxi
//
//  Created by Rishabh Arora on 10/26/18.
//  Copyright © 2018 Rishabh Arora. All rights reserved.
//

import UIKit
import Foundation

typealias JSONDictionary = [String:Any]
typealias JSONArray = [JSONDictionary]
typealias APIServiceFailureCallback = ((Error?) -> ())
typealias JSONArrayResponseCallback = ((JSONArray?) -> ())
typealias JSONDictionaryResponseCallback = ((JSONDictionary?) -> ())

let appName = "Chambba"
let reachability = Reachability()

let ACCEPTABLE_CHARACTERS = " ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz"

let BASE_URL = "http://14.141.175.109/chambba/"
let BASE_IMAGE_URL = "http://14.141.175.109/chambba/public/storage/"
let SOCKET_URL = "http://45.55.236.119:7000"


let appId = "trainwaker/id1401895046"
let apiKey = "d1608c2419512fcd32912cce3e73ea13"
let shareUrl = "https://itunes.apple.com/app/\(appId)?mt=8"

let GMSMAP_KEY = "AIzaSyB6uLaW29x4dAs5FGATQJbAwd9qfD8iKCI"//"AIzaSyB6uLaW29x4dAs5FGATQJbAwd9qfD8iKCI" //"AIzaSyBKwV2w7uWSf3bpgZeRNbMTBKdRbqnmQew"
let GMSPLACES_KEY = "AIzaSyB6uLaW29x4dAs5FGATQJbAwd9qfD8iKCI"//"AIzaSyCqcpaTcjy1vKoImiftj6GgQJs8ult59V8"

//MARK:- Constants
let WINDOW_WIDTH = UIScreen.main.bounds.width
let WINDOW_HEIGHT = UIScreen.main.bounds.height
let phoneMinLength = 10
let APPDELEGATE = UIApplication.shared.delegate as! AppDelegate
let storyboard = UIStoryboard(name: "Main", bundle: nil)
let mainStoryboard = UIStoryboard(name: "Main", bundle: nil)

let OtherStoryboard = UIStoryboard(name: "Other", bundle: nil)

let APPOUTGOINGCHATCOLOR = UIColor.init(red: (118/255.0), green: (117/255.0), blue: (135/255.0), alpha: 1.0)
let APPINCOMINGCHATCOLOR = UIColor.init(red: (255/255.0), green: (255/255.0), blue: (255/255.0), alpha: 1.0)
let APPCHATCELLBACKGROUNDCOLOR = UIColor.init(red: (242/255.0), green: (243/255.0), blue: (245/255.0), alpha: 1.0)

let UPDATE = "UPDATE"
let CONTINUE = "CONTINUE"
let kMessage = "message"
let kInternetConnection = "Internet connection not available, you must turn on to download app content."
let kLocationAccess = "Location Access Requested"
let kLocationUnavailable = "Location services are disabled, you must turn on Location Services from Settings."

let PROFILE_IMAGE = "picture"
let ACCESS_TOKEN = "access_token"
let ID = "id"
let SOS = "sos"
let TOKEN_TYPE = "token_type" 
let REFRESH_TOKEN = "ref_token"
let DEVICE_TOKEN = "DeviceToken"
let DEVICE_TYPE = "ios"
let CLIENT_ID = "11"
let CLIENT_SECRET = "rt8ARpmeGo8IL0hiGMwxeLoWjPfAGPi6tO5lKMM6"

// API Paramter
let API_SignUp = "api/user/signup"
let API_Login = "oauth/token"
let API_GetProfile = "api/user/details"
let API_GetTripHistory = "api/user/trips"
let API_UPComingTrip = "api/user/upcoming/trips"
let API_Update_Profile = "api/user/update/profile"
let API_ChangePasword = "api/user/change/password"
let API_ForgotPassword = "api/user/forgot/password"
let API_RESETPASSWORD = "api/user/reset/password"
let API_REQUEST_CHECK = "api/user/request/check"
let API_CREATE_REQUEST = "api/user/send/request"
let API_CANCEL_REQUEST = "api/user/cancel/request"
let API_GET_SERVICES = "api/user/services"
let API_GET_PROVIDER = "api/user/show/providers"
let API_GET_FARE_ESTIMATION = "api/user/estimated/fare"
let API_RATE_PROVIDER = "api/user/rate/provider"
let API_REQUEST_UPDATE_DESTINATION = "api/user/request-update-destination"
let API_HISTORY_DETAILS = "api/user/trip/details"
let API_UPCOMING_HISTORY_DETAILS = "api/user/upcoming/trip/details"
let API_UPDATE_TOKEN = "api/user/update-token"
let API_USER_CARD = "api/user/card"
let API_USER_PAYMENT = "api/user/payment"
let API_CARD_DELETE = "api/user/card/destory"
let API_ADD_MONEY = "api/user/add/money"


let kResetPassword = "Enter email to reset your password."
let WORKINPROGRESS = "Work in progress"
let kOk = "OK"
let CANCEL = "CANCEL"
let SUBMIT = "SUBMIT"
let cameraNotSupported = "Camera Is Not Supported"
let gallery = "Gallery"
let cancel = "Cancel"
let camera = "Camera"
let image = "image"
let blankEmailAddress = "Please enter email."
let inValidEmailAddress = "Please enter valid email."
let blankPassword = "Please enter password."
let inValidPassword = "Password must be more than 6 characters."
let blankFullName = "Please enter fullname."
let blankMobileNumber = "Please enter phone number."
let inValidMobileNumber = "Please enter valid phone number."
let passwordNotMatch = "Confirm password does'nt match."
let profileUpdate = "Profile updated successfully."
let blankOtp = "Please enter OTP."
let wrongOtp = "Please enter the correct OTP"
let emptyAmount = "Please enter the price to proceed."

