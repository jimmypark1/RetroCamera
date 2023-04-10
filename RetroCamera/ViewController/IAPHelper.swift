//
//  IAPHelper.swift
//
//
//  Created by Jonas Tillges on 17.11.18.
//


import Foundation
import SwiftyStoreKit
import StoreKit

struct IAPHelper {
    typealias Finished = () -> ()
    // Your sharedSecrets
    static let sharedSecret = "44b8bc3c5c3549ebb1777756ba0683a3"
    
    // List your products / Example Products
    static let Product1 = "hint4"
    static var removeAds = "remove1"
    static var premium = "com.junsoft.beautycameravip12"
    
    //just for subscriptions
    static let termsOfServiceURL = "your - URL"
    static let privacyPolicyURL = "your - URL"
    
    static var parentCon:StoreViewController!
    
    enum PurchaseType: Int {
        case simple = 0,
        autoRenewable,
        nonRenewing
    }
    static func set(buy:Bool)
    {
        UserDefaults.standard.set(buy,forKey: "BUY_VIP")
                  
        UserDefaults.standard.set(buy, forKey: "isProUpgradePurchased1")
                        
        UserDefaults.standard.set(buy, forKey: "isProUpgradePurchased2")
                        
        UserDefaults.standard.set(buy, forKey: "isProUpgradePurchased4")
                                 
                        
        UserDefaults.standard.synchronize()
    }
    static func complete(buy:Int ,type:Int = -1)
    {
        /*
        JunSoftAPI.shared.updatePurcahse(buy: buy,type:type, completion: { [self](success, value) in
            if(buy == 1)
            {
                set(buy:true)
            }
            else
            {
                set(buy:false)
        
            }
        })
         */
    }
    static func verifyPurchase(with id: String, sharedSecret: String, type: PurchaseType, validDuration: TimeInterval? = nil){
        let appleValidator = AppleReceiptValidator(service: .production, sharedSecret: sharedSecret)
        SwiftyStoreKit.verifyReceipt(using: appleValidator) { result in
            switch result {
            case .success(let receipt):
                let productId = id
                // Verify the purchase of a Subscription
                switch type {
                case .simple:
                    // Verify the purchase of Consumable or NonConsumable
                    let purchaseResult = SwiftyStoreKit.verifyPurchase(
                        productId: id,
                        inReceipt: receipt)
                    
                    switch purchaseResult {
                    case .purchased(let receiptItem):
                        print("\(productId) is purchased: \(receiptItem)")
                    case .notPurchased:
                        print("The user has never purchased \(productId)")
                    }
                case .autoRenewable:
                    let purchaseResult = SwiftyStoreKit.verifySubscription(
                        ofType: .autoRenewable, // or .nonRenewing (see below)
                        productId: productId,
                        inReceipt: receipt)
                    var buy = 0
                    switch purchaseResult {
                    case .purchased(let expiryDate):
                        
                        print("\(productId) is valid until \(expiryDate)")
                        buy = 1
                    case .expired(let expiryDate):
                        buy = 0
                        print("\(productId) is expired since \(expiryDate)")
                    case .notPurchased:
                        
                        print("The user has never purchased \(productId)")
                        buy = 0
                    }
                    complete(buy:buy)
                case .nonRenewing:
                    guard let validDuration = validDuration else {return}
                    let purchaseResult = SwiftyStoreKit.verifySubscription(
                        ofType: .nonRenewing(validDuration: validDuration),
                        productId: id,
                        inReceipt: receipt)
                    
                    switch purchaseResult {
                    case .purchased(let expiryDate):
                        print("\(productId) is valid until \(expiryDate)")
                    case .expired(let expiryDate):
                        print("\(productId) is expired since \(expiryDate)")
                    case .notPurchased:
                        print("The user has never purchased \(productId)")
                    }
                    
                }
            case .error(let error):
                print("Receipt verification failed: \(error)")
            }
        }
    }
    
    static func purchaseProduct(with id: String, sharedSecret: String, type: PurchaseType, validDuration: TimeInterval? = nil){
   //     Spinner.start()
        if type == .simple {
            SwiftyStoreKit.retrieveProductsInfo([id]) { result in
                if let product = result.retrievedProducts.first {
                    SwiftyStoreKit.purchaseProduct(product, quantity: 1, atomically: true) { result in
                        switch result {
                        case .success(let product):
                            // fetch content from your server, then:
                            if product.needsFinishTransaction {
                                SwiftyStoreKit.finishTransaction(product.transaction)
                            }
                              print("Purchase Success: \(product.productId)")
                        //    Spinner.stop()
                        case .error(let error):
                            switch error.code {
                            case .unknown: print("Unknown error. Please contact support")
                            case .clientInvalid: print("Not allowed to make the payment")
                            case .paymentCancelled: break
                            case .paymentInvalid: print("The purchase identifier was invalid")
                            case .paymentNotAllowed: print("The device is not allowed to make the payment")
                            case .storeProductNotAvailable: print("The product is not available in the current storefront")
                            case .cloudServicePermissionDenied: print("Access to cloud service information is not allowed")
                            case .cloudServiceNetworkConnectionFailed: print("Could not connect to the network")
                            case .cloudServiceRevoked: print("User has revoked permission to use this cloud service")
                            default: print((error as NSError).localizedDescription)
                            }
                    //        Spinner.stop()
                        }
                    }
                }
            }
        }else{
            SwiftyStoreKit.purchaseProduct(id, atomically: true) { result in
                
                if case .success(let purchase) = result {
                    
                    UserDefaults.standard.set(true,forKey: "BUY_VIP")
                              
                                    UserDefaults.standard.set(true, forKey: "isProUpgradePurchased1")
                                                    
                                    UserDefaults.standard.set(true, forKey: "isProUpgradePurchased2")
                                                    
                                    UserDefaults.standard.set(true, forKey: "isProUpgradePurchased4")
                                             
                                    
                                    UserDefaults.standard.synchronize()
                      
                //    Spinner.stop()
                    // Deliver content from server, then:
                    if purchase.needsFinishTransaction {
                        SwiftyStoreKit.finishTransaction(purchase.transaction)
                    }
                    parentCon.close()
                    guard let validDuration = validDuration else { return }
                    self.verifyPurchase(with: id, sharedSecret: sharedSecret, type: type,validDuration: validDuration)
                    
                
                    
                } else {
                //    Spinner.stop()
                    // purchase error
                }
            }
        }
        
    }
    static func restorePurchases(){
     //   Spinner.start()
        SwiftyStoreKit.restorePurchases(atomically: true) { results in
            if results.restoreFailedPurchases.count > 0 {
                print("Restore Failed: \(results.restoreFailedPurchases)")
                
            }
            else if results.restoredPurchases.count > 0 {
                print("Restore Success: \(results.restoredPurchases)")
                
            }
            else {
                print("Nothing to Restore")
                
            }
        //    Spinner.stop()
        }
    }
    
    static func startHelper() {
        SwiftyStoreKit.completeTransactions(atomically: true) { purchases in
            for purchase in purchases {
                switch purchase.transaction.transactionState {
                case .purchased, .restored:
                    if purchase.needsFinishTransaction {
                        // Deliver content from server, then:
                        SwiftyStoreKit.finishTransaction(purchase.transaction)
                    }
                // Unlock content
                case .failed, .purchasing, .deferred:
                    break // do nothing
                }
            }
        }
    }
    
    struct Objects {
        var name : String!
        var priceString : String!
        var localizedDescription : String!
    }
    
    static var Info = [Objects]()
    
    static func getProductInfo(with id: String, completed: @escaping Finished)  {
       // Spinner.start()
        SwiftyStoreKit.retrieveProductsInfo([id]) { result in
            if let product = result.retrievedProducts.first {
                let priceString = product.localizedPrice!
                print("Product: \(product.localizedDescription), price: \(priceString)")
                Info.append(Objects(name: product.localizedTitle, priceString: product.localizedPrice, localizedDescription: product.localizedDescription))
                
            }
            else if let invalidProductId = result.invalidProductIDs.first {
                print("Invalid product identifier: \(invalidProductId)")
                
            }
            else {
                print("Error: \(result.error)")
            }
         //   Spinner.stop()
            completed()
        }
    }
    
    static var subscriptionTerms = "Subscription price: -,-- Please read below about the auto-renewing subscription nature of this product: • Payment will be charged to iTunes Account at confirmation of purchase • Subscription automatically renews unless auto-renew is turned off at least 24-hours before the end of the current period • Account will be charged for renewal within 24-hours prior to the end of the current period, and identify the cost of the renewal • Subscriptions may be managed by the user and auto-renewal may be turned off by going to the user's Account Settings after purchase • Any unused portion of a free trial period, if offered, will be forfeited when the user purchases a subscription to that publication, where applicable Terms of Use: Policy: "
    static func getSubscriptionTerms(with id: String, completed: @escaping Finished) {
        SwiftyStoreKit.retrieveProductsInfo([id]) { result in
            if let product = result.retrievedProducts.first {
                let priceString = product.localizedPrice!
                
                if #available(iOS 11.2, *) {
                    if let trailperiod = product.introductoryPrice?.subscriptionPeriod {
                        if let period = product.introductoryPrice?.subscriptionPeriod{
                          //  print("Start your \(period.numberOfUnits) \(unitName(unitRawValue: period.unit.rawValue)) free trial")
                            let periodString = "\(period.numberOfUnits) \(unitName(unitRawValue: period.unit.rawValue))."
                            let trailString = " \(trailperiod.numberOfUnits) \(unitName(unitRawValue: trailperiod.unit.rawValue)) free trial, "
                            
                            
                            
                          //  print("Product: \(product.localizedDescription), price: \(priceString)")
                            Info.append(Objects(name: product.localizedTitle, priceString: product.localizedPrice, localizedDescription: product.localizedDescription))
                            subscriptionTerms = "After" + trailString + "an auto-renewable subscription will be activated for \(Info[0].priceString!) / year\nPlease read below about the auto-renewing subscription nature of this product: \n• Payment will be charged to iTunes Account at confirmation of purchase \n• Subscription automatically renews unless auto-renew is turned off at least 24-hours before the end of the current period \n• Account will be charged for renewal within 24-hours prior to the end of the current period, and identify the cost of the renewal \n• Subscriptions may be managed by the user and auto-renewal may be turned off by going to the user's Account Settings after purchase \n• Any unused portion of a free trial period, if offered, will be forfeited when the user purchases a subscription to that publication, where applicable "
                        }
                    }
                } else {
                }
            }
            else if let invalidProductId = result.invalidProductIDs.first {
                print("Invalid product identifier: \(invalidProductId)")
            }
            else {
                print("Error: \(result.error)")
            }
            completed()
        }
        
    }
    static func unitName(unitRawValue:UInt) -> String {
        switch unitRawValue {
        case 0: return "days"
        case 1: return "Week"
        case 2: return "months"
        case 3: return "years"
        default: return ""
        }
    }
}

