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
       
        return true
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
