//
//  AppDelegate.swift
//  RetroCamera
//
//  Created by Junsung Park on 2022/04/18.
//

import UIKit
import Firebase

import UserNotifications

import GoogleMobileAds
import SwiftyStoreKit
//import FirebaseMessaging
import SiriusRating
import Siren


@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    
    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        FirebaseApp.configure()
        GADMobileAds.sharedInstance().start(completionHandler: nil)
        
        setupIAP()
        
        if #available(iOS 10.0, *) {
            // For iOS 10 display notification (sent via APNS)
            UNUserNotificationCenter.current().delegate = self
            
            let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
            UNUserNotificationCenter.current().requestAuthorization(
                options: authOptions,
                completionHandler: {_, _ in })
        } else {
            let settings: UIUserNotificationSettings =
            UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
            application.registerUserNotificationSettings(settings)
        }
        
        application.registerForRemoteNotifications()
        //        Siren.shared.wail() // Line 2
        //        Siren.init(globalRules: Rules, showAlertAfterCurrentVersionHasBeenReleasedForDays: Int)
        checkUpdate()
        showRating()
        
        let isFirstLaunch = !UserDefaults.standard.bool(forKey: "hasLaunchedBefore")
        
        //        isFirstLaunch = true
//        if isFirstLaunch {
//            let onboardingVC = OnboardingViewController(transitionStyle: .scroll, navigationOrientation: .horizontal, options: nil)
//            self.window?.rootViewController = onboardingVC
//            //            UserDefaults.standard.set(true, forKey: "hasLaunchedBefore")
//        } else {
//            let homeVC = HomeViewController()
//            let navController = UINavigationController(rootViewController: homeVC)
//            self.window?.rootViewController = navController
//        }
        let homeVC = HomeViewController()
        let navController = UINavigationController(rootViewController: homeVC)
        self.window?.rootViewController = navController

        return true
    }
    func checkUpdate() {
        //           let siren = Siren.shared
        //        siren.rulesManager = RulesManager(globalRules: .default,
        //                                             showAlertAfterCurrentVersionHasBeenReleasedForDays: 0)
        //
        //           siren.wail { results in
        //               switch results {
        //               case .success(let updateResults):
        //                   print("AlertAction ", updateResults.alertAction)
        //                   print("Localization ", updateResults.localization)
        //                   print("Model ", updateResults.model)
        //                   print("UpdateType ", updateResults.updateType)
        //               case .failure(let error):
        //                   print(error.localizedDescription)
        //               }
        //           }
    }
    func showRating(){
        SiriusRating.setup(
            debugEnabled: true,
            ratingConditions: [
                
                EnoughAppSessionsRatingCondition(totalAppSessionsRequired: 7),
                NotPostponedDueToReminderRatingCondition(totalDaysBeforeReminding: 14),
                NotDeclinedToRateAnyVersionRatingCondition(daysAfterDecliningToPromptUserAgain: 30, backOffFactor: 2.0, maxRecurringPromptsAfterDeclining: 2),
                NotRatedCurrentVersionRatingCondition(),
                NotRatedAnyVersionRatingCondition(daysAfterRatingToPromptUserAgain: 240, maxRecurringPromptsAfterRating: UInt.max)
                
            ]
            ,
            canPromptUserToRateOnLaunch: true,
            didOptInForReminderHandler: {
                //...
            },
            didDeclineToRateHandler: {
                //...
            },
            didRateHandler: {
                //...
            }
            
        )
    }
    func setupIAP() {
        
        SwiftyStoreKit.completeTransactions(atomically: true) { purchases in
            
            for purchase in purchases {
                switch purchase.transaction.transactionState {
                case .purchased, .restored:
                    let downloads = purchase.transaction.downloads
                    if !downloads.isEmpty {
                        SwiftyStoreKit.start(downloads)
                    } else if purchase.needsFinishTransaction {
                        // Deliver content from server, then:
                        SwiftyStoreKit.finishTransaction(purchase.transaction)
                    }
                    print("\(purchase.transaction.transactionState.debugDescription): \(purchase.productId)")
                case .failed, .purchasing, .deferred:
                    break // do nothing
                }
            }
        }
        
        SwiftyStoreKit.updatedDownloadsHandler = { downloads in
            
            // contentURL is not nil if downloadState == .finished
            let contentURLs = downloads.flatMap { $0.contentURL }
            if contentURLs.count == downloads.count {
                print("Saving: \(contentURLs)")
                SwiftyStoreKit.finishTransaction(downloads[0].transaction)
            }
        }
    }
    /*
     func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
     
     Messaging.messaging().apnsToken = deviceToken
     let token = Messaging.messaging().fcmToken
     print("FCM token: \(token ?? "")")
     
     let id =  UserDefaults.standard.string(forKey: "USER_ID")
     
     if(id == nil)
     {
     return
     }
     Messaging.messaging().token { token, error in
     if let error = error {
     print("Error fetching FCM registration token: \(error)")
     } else if let token = token {
     print("FCM registration token: \(token)")
     // self.fcmRegTokenMessage.text  = "Remote FCM registration token: \(token)"
     
     
     
     
     }
     }
     }
     func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
     print("Unable to register for remote notifications: \(error.localizedDescription)")
     }
     */
    
}
@available(iOS 10, *)
extension AppDelegate : UNUserNotificationCenterDelegate {
    
    // Receive displayed notifications for iOS 10 devices.
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification,
                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        let userInfo = notification.request.content.userInfo
        
        print(userInfo)
        
        if( userInfo["object"] != nil)
        {
            
            
        }
        
        
        completionHandler([[.alert, .sound]])
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                didReceive response: UNNotificationResponse,
                                withCompletionHandler completionHandler: @escaping () -> Void)
    {
        let userInfo = response.notification.request.content.userInfo
        
        completionHandler()
    }
    func applicationDidBecomeActive(_ application: UIApplication)
    {
        let bBuy = UserDefaults.standard.bool(forKey: "BUY_VIP")
       
        if bBuy == false{
            var topViewController = UIApplication.shared.keyWindow?.rootViewController
            if topViewController != nil{
                while ((topViewController?.presentedViewController) != nil) {
                    topViewController = topViewController?.presentedViewController
                }
                
                AdMobOpenAdManager.shared.showAdIfAvailable(viewController: topViewController!)

            }
            
        }
    }
}
/*
 extension AppDelegate : MessagingDelegate {
 // [START refresh_token]
 func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
 print("Firebase registration token: \(fcmToken)")
 // self.fcmToken = fcmToken!
 }
 
 
 func messaging(_ messaging: Messaging, didReceive remoteMessage: MessagingDelegate) {
 print("Received data message: \(remoteMessage.description)")
 }
 
 // [END refresh_token]
 }
 */
