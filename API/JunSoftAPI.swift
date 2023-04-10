//
//  JunSoftAPI.swift
//  BeautyCamera
//
//  Created by Junsung Park on 2021/12/03.
//

import Foundation
//import SwiftyJSON
import Alamofire


class JunSoftAPI{
    static let shared = JunSoftAPI()
    
    private init(){}
    
    var version: String? { guard let dictionary = Bundle.main.infoDictionary, let version = dictionary["CFBundleShortVersionString"] as? String, let build =  dictionary["CFBundleVersion"] as? String else {return nil};
        return  version }
/*
    func withdrawal( completion:@escaping ((Bool, JSON) -> ()))
    {
        return
        let userId = UserDefaults.standard.string(forKey: "USER_ID")
        let url = JunSoftUtil.shared.baseurl + "/user/withdrawal/retro/v2/" + userId!
        let headers: HTTPHeaders = [
            
            "Content-Type": "application/json",
          ]
      
        AF.request(url, method: .get, parameters: nil,encoding: JSONEncoding.default, headers: headers)
            .responseJSON{ [self] response in
                
               // debugPrint(response)
                
                switch response.result {
                
                case .success(let value):
                    
                    let json = JSON(value)
                    
                    completion(true, json)
           
                    
                case .failure(let error):
                    
                    print("error : \(error)")
                    
                    let json = JSON(error)
                   
                 
                    completion(false, json)
       
                    break;
                    
                }
                
            }
    }
    func createUser(user:UserData,completion:@escaping ((Bool, JSON) -> ())) {
        return
        let userId = UserDefaults.standard.string(forKey: "USER_ID")
        let userType = UserDefaults.standard.integer(forKey: "USER_TYPE")
        
        let url = JunSoftUtil.shared.baseurl + "/user/createUser/retro/"
        let token = UserDefaults.standard.string(forKey: "USER_TOKEN")
        let headers: HTTPHeaders = [
            
            "Content-Type": "application/json",
          //  "token": token!
        ]
       
      
       
        let parameters : Parameters
            
          = [
            "userId" : user.userId,
            "name" : user.name,
            "email" : user.email,
        
            "country" : Locale.current.regionCode,
            "profileImg" : user.profileImg,
            "token" : user.token,
            "version" : version,
         
            "platform":"iOS"
   
          ]
  
        AF.request(url, method: .post, parameters: parameters,encoding: JSONEncoding.default, headers: headers)
            .responseJSON { (response) in
               // debugPrint(response)
                
                switch response.result {
                
                case .success(let value):
                    let json = JSON(value)
                 
                    completion(true, json)
      
                    
                    
                case .failure(let error):
                    let json = JSON(error)
               
                    completion(false, json)
       
                    
                }
                
            }
 
    }
    func updatePurcahse0(buy:Int,completion:@escaping ((Bool, JSON) -> ())) {
        return
        let userId = UserDefaults.standard.string(forKey: "USER_ID")
        let userType = UserDefaults.standard.integer(forKey: "USER_TYPE")
        
        let url = JunSoftUtil.shared.baseurl + "/user/updatePurchase0/retro/"
        let token = UserDefaults.standard.string(forKey: "USER_TOKEN")
        let headers: HTTPHeaders = [
            
            "Content-Type": "application/json",
          //  "token": token!
        ]
       
      
       
        let parameters : Parameters
            
          = [
            "userId" : userId,
           
            "buy":buy
   
          ]
  
        AF.request(url, method: .post, parameters: parameters,encoding: JSONEncoding.default, headers: headers)
            .responseJSON { (response) in
               // debugPrint(response)
                
                switch response.result {
                
                case .success(let value):
                    let json = JSON(value)
                 
                    completion(true, json)
      
                    
                    
                case .failure(let error):
                    let json = JSON(error)
               
                    completion(false, json)
       
                    
                }
                
            }
 
    }
    func updatePurcahse1(buy:Int,completion:@escaping ((Bool, JSON) -> ())) {
        
        return
        let userId = UserDefaults.standard.string(forKey: "USER_ID")
        let userType = UserDefaults.standard.integer(forKey: "USER_TYPE")
        
        let url = JunSoftUtil.shared.baseurl + "/user/updatePurchase1/retro/"
        let token = UserDefaults.standard.string(forKey: "USER_TOKEN")
        let headers: HTTPHeaders = [
            
            "Content-Type": "application/json",
          //  "token": token!
        ]
       
      
       
        let parameters : Parameters
            
          = [
            "userId" : userId,
           
            "buy":buy
   
          ]
  
        AF.request(url, method: .post, parameters: parameters,encoding: JSONEncoding.default, headers: headers)
            .responseJSON { (response) in
               // debugPrint(response)
                
                switch response.result {
                
                case .success(let value):
                    let json = JSON(value)
                 
                    completion(true, json)
      
                    
                    
                case .failure(let error):
                    let json = JSON(error)
               
                    completion(false, json)
       
                    
                }
                
            }
 
    }
    func updatePurcahse2(buy:Int,completion:@escaping ((Bool, JSON) -> ())) {
        return
        let userId = UserDefaults.standard.string(forKey: "USER_ID")
        let userType = UserDefaults.standard.integer(forKey: "USER_TYPE")
        
        let url = JunSoftUtil.shared.baseurl + "/user/updatePurchase2/retro/"
        let token = UserDefaults.standard.string(forKey: "USER_TOKEN")
        let headers: HTTPHeaders = [
            
            "Content-Type": "application/json",
          //  "token": token!
        ]
       
      
       
        let parameters : Parameters
            
          = [
            "userId" : userId,
           
            "buy":buy
   
          ]
  
        AF.request(url, method: .post, parameters: parameters,encoding: JSONEncoding.default, headers: headers)
            .responseJSON { (response) in
               // debugPrint(response)
                
                switch response.result {
                
                case .success(let value):
                    let json = JSON(value)
                 
                    completion(true, json)
      
                    
                    
                case .failure(let error):
                    let json = JSON(error)
               
                    completion(false, json)
       
                    
                }
                
            }
 
    }
    
    func updateToken(token:String,completion:@escaping ((Bool, JSON) -> ())) {
        return
        let userId = UserDefaults.standard.string(forKey: "USER_ID")
        let userType = UserDefaults.standard.integer(forKey: "USER_TYPE")
        
        let url = JunSoftUtil.shared.baseurl + "/updateToken/retro/"
        let token = UserDefaults.standard.string(forKey: "USER_TOKEN")
        let headers: HTTPHeaders = [
            
            "Content-Type": "application/json",
          //  "token": token!
        ]
       
      
       
        let parameters : Parameters
            
          = [
            "userId" : userId,
           
            "token":token
   
          ]
  
        AF.request(url, method: .post, parameters: parameters,encoding: JSONEncoding.default, headers: headers)
            .responseJSON { (response) in
               // debugPrint(response)
                
                switch response.result {
                
                case .success(let value):
                    let json = JSON(value)
                 
                    completion(true, json)
      
                    
                    
                case .failure(let error):
                    let json = JSON(error)
               
                    completion(false, json)
       
                    
                }
                
            }
 
    }
 */
}
