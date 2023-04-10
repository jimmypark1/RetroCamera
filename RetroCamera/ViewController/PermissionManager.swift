//
//  PermissionManager.swift
//  RetroCamera
//
//  Created by Junsung Park on 2022/04/26.
//

import Foundation


import UIKit
import Photos
import Contacts
import AVFoundation

enum Permission {
    case cameraUsage
     case microphoneUsage
}

class PermissionManager {

    private init(){}
    public static let shared = PermissionManager()
    
    let PHOTO_LIBRARY_PERMISSION: String = "Require access to Photo library to proceed. Would you like to open settings and grant permission to photo library?"
    let CAMERA_USAGE_PERMISSION: String = "This app requires access to your camera to take pictures and record videos?"
    let CONTACT_USAGE_ALERT: String = "Require access to Contact to proceed. Would you like to open Settings and grant permission to Contact?"
    let MICROPHONE_USAGE_ALERT: String = "This app requires access to your microphone to record voice during video recording"
    
    
    
    func requestAccess(vc: UIViewController,
                       _ permission: Permission,
                       completionHandler: @escaping (_ accessGranted: Bool) -> Void){
        
        switch permission {
  
        case .cameraUsage: ////////////////// Camera
            switch AVCaptureDevice.authorizationStatus(for: .video) {
            case .authorized:
                completionHandler(true)
            case .denied:
                showSettingsAlert(controller: vc, msg: CAMERA_USAGE_PERMISSION, completionHandler)
            case .restricted, .notDetermined:
                AVCaptureDevice.requestAccess(for: .video) { granted in
                    if granted {
                        completionHandler(true)
                    } else {
                        DispatchQueue.main.async {
                            self.showSettingsAlert(controller: vc, msg: self.CAMERA_USAGE_PERMISSION, completionHandler)
                        }
                    }
                }
            }
            break
            
            
       
       
            
        case .microphoneUsage:  //////////////////////// Microphone usage
            switch AVAudioSession.sharedInstance().recordPermission{
            case .granted:
                completionHandler(true)
                break
            case .denied:
                showSettingsAlert(controller: vc, msg: MICROPHONE_USAGE_ALERT, completionHandler)
                break
            case .undetermined:
                AVAudioSession.sharedInstance().requestRecordPermission({ (granted) in
                    if granted{
                        completionHandler(true)
                    }else{
                        DispatchQueue.main.async {
                            self.showSettingsAlert(controller: vc, msg: self.MICROPHONE_USAGE_ALERT, completionHandler)
                        }
                    }
                })
                break
            }
        
        }
    }
    
    
    
    private func showSettingsAlert(controller: UIViewController ,
                                   msg: String,
                                   _ completionHandler: @escaping (_ accessGranted: Bool) -> Void) {
        
        let alert = UIAlertController(title: nil, message: msg, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Open Settings", style: .default) { action in
            completionHandler(false)
            
            if let settingsUrl = URL(string: UIApplication.openSettingsURLString) {
                if UIApplication.shared.canOpenURL(settingsUrl){
                    if #available(iOS 10.0, *) {
                        UIApplication.shared.open(settingsUrl)
                    } else {
                        UIApplication.shared.openURL(settingsUrl)
                    }
                }
            }
        })
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel) { action in
            completionHandler(false)
        })
        controller.present(alert, animated: true)
    }
}
