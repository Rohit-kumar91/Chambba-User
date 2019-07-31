//
//  AppDelegate.swift
//  Chambba
//
//  Created by Mayur chaudhary on 28/01/19.
//  Copyright © 2019 Mayur chaudhary. All rights reserved.
//

import UIKit
import GoogleMaps
import UserNotifications
import SystemConfiguration
import GoogleSignIn
import FBSDKCoreKit
import GooglePlaces
import Firebase
import Stripe

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate,UNUserNotificationCenterDelegate {

    var window: UIWindow?
    var navigationController : UINavigationController?
    var privateSideMenuController: MASliderViewController?
    var gcmMessageIDKey = "gcm_message_id"

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        GMSServices.provideAPIKey(GMSMAP_KEY)
        GMSPlacesClient.provideAPIKey(GMSPLACES_KEY)
        GMSServices.provideAPIKey(GMSPLACES_KEY)
        setInitialController()
        self.registerForRemoteNotification(application)
        if  launchOptions?[UIApplicationLaunchOptionsKey.remoteNotification] != nil {  //launching from push notification
            let when = DispatchTime.now() + 0 // change 2 to desired number of seconds
            DispatchQueue.main.asyncAfter(deadline: when) {
                // Your code with delay
            }
        } else {
        }


        //Paypal initilize with client_id for Enviornment (Live/Sandbox)
        PayPalMobile.initializeWithClientIds(forEnvironments: [PayPalEnvironmentProduction: "Afwdge98SP0YphW3yLlDSRnAXVsoL8aw31ShG_npmHBzXK4CND-JM7O3QZJT3p6jCII-t0GX1ZyD9AQT", PayPalEnvironmentSandbox: "AcZZzE6olQMmV_3HkJLnD5KKF80oZhrrqP801krawW7Cu_motk0Sni9NCYN225xpLhghoGg0B2d-dxft"])

        //Google SignIN integration configutration
        //628365538015-4n3me0ta3sibfv8hn16fdfiu88c3tl6m.apps.googleusercontent.com

        GIDSignIn.sharedInstance().clientID = "589803196465-gr2bgs3u5kjkjp2k9ommhdjk05spje7l.apps.googleusercontent.com"  //I am using my credential here need client cred.

        //Facebook Login
        FBSDKApplicationDelegate.sharedInstance()?.application(application, didFinishLaunchingWithOptions: launchOptions)
        Messaging.messaging().delegate = self
        FirebaseApp.configure()
        
        //Stripe
        STPPaymentConfiguration.shared().publishableKey = "pk_test_siHEw05Z8AD4THO4R8a1jCwR00FJXbw6XI"

        return true
    }

    //MARK:- Initial Controller Method
    func setInitialController() {
        window = UIWindow(frame:UIScreen.main.bounds)
        let rootVC = mainStoryboard.instantiateViewController(withIdentifier: "TutorialViewController")
        let homeVC = APPDELEGATE.sideMenuController
        var autoLogin = false
        autoLogin = UserDefaults.standard.bool(forKey: "isLoggedin")
        if autoLogin == true {
        self.navigationController = UINavigationController.init(rootViewController: homeVC)
        }else {
        self.navigationController = UINavigationController.init(rootViewController: rootVC)
        }
        self.navigationController?.isNavigationBarHidden = true
        self.window!.rootViewController = self.navigationController
        self.window?.makeKeyAndVisible()

    }

    //Mark :- To Check Reachability
    func checkReachablility() -> Bool {
        var zeroAddress = sockaddr_in()
        zeroAddress.sin_len = UInt8(MemoryLayout.size(ofValue: zeroAddress))
        zeroAddress.sin_family = sa_family_t(AF_INET)

        let defaultRouteReachability = withUnsafePointer(to: &zeroAddress) {
            $0.withMemoryRebound(to: sockaddr.self, capacity: 1) {zeroSockAddress in
                SCNetworkReachabilityCreateWithAddress(nil, zeroSockAddress)
            }
        }

        var flags = SCNetworkReachabilityFlags()
        if !SCNetworkReachabilityGetFlags(defaultRouteReachability!, &flags) {
            return false
        }
        let isReachable = (flags.rawValue & UInt32(kSCNetworkFlagsReachable)) != 0
        let needsConnection = (flags.rawValue & UInt32(kSCNetworkFlagsConnectionRequired)) != 0
        return (isReachable && !needsConnection)
    }

    //MARK: Side Menu
    var sideMenuController: MASliderViewController {

        let mainStoryboard = UIStoryboard.init(name: "Main", bundle: nil)

        if let privateSideMenuController = privateSideMenuController {
            return privateSideMenuController
        }
        self.navigationController?.navigationBar.isHidden = true
        let mainViewController = mainStoryboard.instantiateViewController(withIdentifier: "HomeVC") as! HomeVC
        let drawerViewController = mainStoryboard.instantiateViewController(withIdentifier: "MenuVC") as! MenuVC
        let centerNavController = UINavigationController.init(rootViewController: mainViewController)
        privateSideMenuController?.navigationController?.navigationBar.isHidden = true;
        let sliderViewController = MASliderViewController()
        self.setNavigationController(navigation: centerNavController)
        sliderViewController.leftViewController = drawerViewController
        sliderViewController.centerViewController = centerNavController
        sliderViewController.leftDrawerWidth = WINDOW_WIDTH - 100
        privateSideMenuController = sliderViewController
        return privateSideMenuController!
    }

    func setNavigationController(navigation:UINavigationController) {
        navigation.navigationBar.isTranslucent = false
        navigation.interactivePopGestureRecognizer?.isEnabled = false
        navigation.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        navigation.navigationBar.shadowImage = UIImage()
        navigation.navigationBar.isHidden = true
    }



    //MARK:- Push Notification Delegate Methods
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {

        Messaging.messaging().apnsToken = deviceToken
        
        InstanceID.instanceID().instanceID { (result, error) in
            if let error = error {
                print("Error fetching remote instange ID: \(error)")
            } else if let result = result {
                print("Remote instance ID token: \(result.token)")
                UserDefaults.standard.set(result.token, forKey: "DeviceToken")

            }
        }
    }

    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        UserDefaults.standard.set("jdshkfhsdkjfsdkjf", forKey: "DeviceToken")
        UserDefaults.standard.synchronize()
    }



    //MARK:- Register For Push Notification
    fileprivate func registerForRemoteNotification(_ application: UIApplication) {
        if #available(iOS 10.0, *) {
            UNUserNotificationCenter.current().delegate = self
            UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { (granted, error) in
                guard error == nil else {
                    return
                }
                if granted {
                    DispatchQueue.main.async {
                        application.registerForRemoteNotifications()
                    }
                } else {
                    //Handle user denying permissions..
                    self.registerForRemoteNotification(application)
                }
            }
        } else {
            let settings: UIUserNotificationSettings =
                UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
            application.registerUserNotificationSettings(settings)
        }
        DispatchQueue.main.async {
            application.registerForRemoteNotifications()
        }
    }

    //Setting URL For Google SignIn.
    func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any] = [:]) -> Bool {
//        return GIDSignIn.sharedInstance().handle(url as URL?,
//                                                 sourceApplication: options[UIApplicationOpenURLOptionsKey.sourceApplication] as? String,
//                                                 annotation: options[UIApplicationOpenURLOptionsKey.annotation])
        let googleDidHandle = GIDSignIn.sharedInstance().handle(url as URL?,
                                                                   sourceApplication: options[UIApplicationOpenURLOptionsKey.sourceApplication] as? String,
                                                                   annotation: options[UIApplicationOpenURLOptionsKey.annotation])

        let facebookDidHandle = FBSDKApplicationDelegate.sharedInstance().application(app, open: url, options: options)

        return googleDidHandle || facebookDidHandle

    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.


    }


    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any]) {
        // If you are receiving a notification message while your app is in the background,
        // this callback will not be fired till the user taps on the notification launching the application.
        // TODO: Handle data of notification

        // With swizzling disabled you must let Messaging know about the message, for Analytics
        // Messaging.messaging().appDidReceiveMessage(userInfo)

        // Print message ID.
        if let messageID = userInfo[gcmMessageIDKey] {
            print("Message ID: \(messageID)")
        }

        // Print full message.
        print(userInfo)
    }

    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any],
                     fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        // If you are receiving a notification message while your app is in the background,
        // this callback will not be fired till the user taps on the notification launching the application.
        // TODO: Handle data of notification

        // With swizzling disabled you must let Messaging know about the message, for Analytics
        // Messaging.messaging().appDidReceiveMessage(userInfo)

        // Print message ID.
        if let messageID = userInfo[gcmMessageIDKey] {
            print("Message ID: \(messageID)")
        }

        // Print full message.
        print(userInfo)

        completionHandler(UIBackgroundFetchResult.newData)
    }


    //MARK:- activityIndicator
    func showIndicator() {
            let attribute = RappleActivityIndicatorView.attribute(style: RappleStyleCircle, tintColor: .white, screenBG: nil, progressBG: .black, progressBarBG: .lightGray, progreeBarFill: .yellow)
            RappleActivityIndicatorView.startAnimating(attributes: attribute)
    }

    //MARK:- HIde ActivityIdicator
    func hideIndicator() {
        RappleActivityIndicatorView.stopAnimation()
    }



}

extension AppDelegate : MessagingDelegate {
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String) {
        print("Firebase registration token: \(fcmToken)")

        let dataDict:[String: String] = ["token": fcmToken]
        NotificationCenter.default.post(name: Notification.Name("FCMToken"), object: nil, userInfo: dataDict)
        // TODO: If necessary send token to application server.
        // Note: This callback is fired at each app startup and whenever a new token is generated.
    }

    func messaging(_ messaging: Messaging, didReceive remoteMessage: MessagingRemoteMessage) {
        print("REmote messages", remoteMessage)
    }
}

@available(iOS 10, *)
extension AppDelegate  {

    // Receive displayed notifications for iOS 10 devices.
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification,
                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        let userInfo = notification.request.content.userInfo

        // With swizzling disabled you must let Messaging know about the message, for Analytics
        //Messaging.messaging().appDidReceiveMessage(userInfo)

//        // Print message ID.
        if let messageID = userInfo[gcmMessageIDKey] {
            print("Message ID: \(messageID)")
        }

        // Print full message.
        print(userInfo)

        // Change this to your preferred presentation option
        completionHandler([.alert])
    }

    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                didReceive response: UNNotificationResponse,
                                withCompletionHandler completionHandler: @escaping () -> Void) {
        let userInfo = response.notification.request.content.userInfo
        // Print message ID.
        if let messageID = userInfo[gcmMessageIDKey] {
            print("Message ID: \(messageID)")
        }
//
        // Print full message.
        print(userInfo)

        completionHandler()
    }
}







