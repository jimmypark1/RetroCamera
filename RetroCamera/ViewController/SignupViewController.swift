//
//  SignupViewController.swift
//  RetroCamera
//
//  Created by Junsung Park on 2022/04/19.
//

import UIKit
import FirebaseAuth
import FirebaseMessaging

import TTGSnackbar
import SwiftyJSON

class SignupViewController: UIViewController {

    @IBOutlet weak var email: UITextField!
    @IBOutlet weak var password: UITextField!
    @IBOutlet weak var cpassword: UITextField!
    @IBOutlet weak var name : UITextField!
    @IBOutlet weak var descView : UITextView!
    var parenCon:LoginViewController!
    
    lazy var activityIndicator: UIActivityIndicatorView = {
        // Create an indicator.
        let activityIndicator = UIActivityIndicatorView()
        activityIndicator.frame = CGRect(x: 0, y: 0, width: 50, height: 50)
        activityIndicator.center = self.view.center
       activityIndicator.color = UIColor(red: 255, green: 199, blue: 44, alpha: 1)
                // Also show the indicator even when the animation is stopped.
        activityIndicator.hidesWhenStopped = true
        activityIndicator.style = UIActivityIndicatorView.Style.whiteLarge
        // Start animation.
        activityIndicator.stopAnimating()
        return activityIndicator
    
     }()
    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.addSubview(self.activityIndicator)
  
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tapPrivacy))
        descView.addGestureRecognizer(tapGesture)
    
    }
    
    open override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return UIInterfaceOrientationMask.portrait
    }
    
    @IBAction func close()
    {
        dismiss(animated: true, completion: nil)
    }

    @objc func tapPrivacy()
    {
        
        performSegue(withIdentifier: "exec_s_privacy", sender: nil)
  
    }
    @IBAction func register()
    {
        activityIndicator.startAnimating()
        email.resignFirstResponder()
        password.resignFirstResponder()
       // cpassword.resignFirstResponder()
        name.resignFirstResponder()
        
      //  let loadingView = RSLoadingView()
       // loadingView.show(on: self.view)
                
        if(self.name.text != nil)
        {
            Auth.auth().createUser(withEmail: email.text!, password: password.text!) { [self] (user, error) in
                // ...
                if (error == nil){
                    
                    Auth.auth().signIn(withEmail: self.email.text!, password: self.password.text!) { [self] (user, error) in
                        // ...
                        if let error = error {
                            // ...
                           // RSLoadingView.hide(from: self.view)
                       //     Spinner.stop()
                            activityIndicator.stopAnimating()
                     
                            return
                        }
                        guard let firUser = Auth.auth().currentUser else { return }
                        let uid = firUser.uid
                        let photo = firUser.photoURL?.absoluteString
                        
                        //user.country
                        
                        Messaging.messaging().token { token, error in
                          if let error = error {
                            print("Error fetching FCM registration token: \(error)")
                          } else if let token = token {
                            print("FCM registration token: \(token)")
                           // self.fcmRegTokenMessage.text  = "Remote FCM registration token: \(token)"
                             
                           
                              let user0 = UserData()
                              user0.profileImg = photo
                              user0.name = firUser.displayName
                              user0.email = firUser.email
                              user0.userId = uid
                              user0.token = token
                              JunSoftAPI.shared.createUser(user: user0, completion: {[self](success,value) in
                                  let json = JSON(value)
                                  let code = json["code"].intValue
                                  if(code == 200 || code == 201)
                                  {
                                      UserDefaults.standard.setValue(uid, forKey: "USER_ID")
                                       
                                      UserDefaults.standard.setValue(photo, forKey: "USER_PHOTO")
                                      
                                      UserDefaults.standard.synchronize()
                                      
                                     
                                      activityIndicator.stopAnimating()
                                      parenCon.isClose = true
                                      dismiss(animated: true, completion: nil)
                                     
                                      self.navigationController?.popViewController(animated: true)

                                  }
                                
                              
                              })
                          }
                        }
                    }
                    
                    
                }
                else
                {
                   // RSLoadingView.hide(from: self.view)
                  //  Spinner.stop()
                    
                    activityIndicator.stopAnimating()
            
                    var msg = error?.localizedDescription
                   
                    let snackbar = TTGSnackbar(message: msg!, duration: .middle)

                    // Action 1
                    snackbar.messageTextFont = UIFont(name: "Helvetica", size: 12)!
                    snackbar.leftMargin = 16
                    snackbar.rightMargin = 16
                    snackbar.cornerRadius = 6
                    snackbar.animationSpringWithDamping = 1.0
                    
                    snackbar.frame.size.height = 34
                    snackbar.contentInset = UIEdgeInsets(top: 10, left: 14, bottom: 10, right: 14)
                  
                    snackbar.backgroundColor = UIColor(red: 68, green: 68, blue: 68, alpha: 1.0)
                  
                    
                    snackbar.dismissBlock = { [self] (snackbar) in
                
              
                    }
                    snackbar.show()
                }
            }
        }
        else
        {
          //  RSLoadingView.hide(from: self.view)
          //  Spinner.stop()
                    
        }
      
    }
}
