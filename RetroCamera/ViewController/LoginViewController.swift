//
//  LoginViewController.swift
//  RetroCamera
//
//  Created by Junsung Park on 2022/04/19.
//

import UIKit
import FBSDKCoreKit
import FBSDKLoginKit
import Firebase
import FirebaseAuth
import GoogleSignIn
import AuthenticationServices
import CommonCrypto
import CryptoKit
import SwiftyJSON
import FirebaseMessaging
import TTGSnackbar

class LoginViewController: UIViewController {

    @IBOutlet weak var facebookBt:UIView!
    @IBOutlet weak var googleBt:UIView!
    @IBOutlet weak var appleBt:UIView!
    @IBOutlet weak var signUpBt:UIButton!
    @IBOutlet weak var loginBt:UIButton!
   
    @IBOutlet weak var email:UITextField!
    @IBOutlet weak var password:UITextField!
  
    @IBOutlet weak var descView : UITextView!
    
    var isClose:Bool = false
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

        initUI()
        initGesture()
    }
    

    override func viewWillAppear(_ animated: Bool) {
        if(isClose == true)
        {
            isClose = false
            dismiss(animated: true, completion: nil)
        }
    }
   
    func initUI()
    {
   //     loginBt.layer.cornerRadius = 22
   //     loginBt.layer.borderWidth = 2
   //     loginBt.layer.borderColor = UIColor.white.cgColor
     
        email.backgroundColor = UIColor(hex:"f7f2f5")
        password.backgroundColor = UIColor(hex:"f7f2f5")
      
        email.layer.cornerRadius = 8
        password.layer.cornerRadius = 8
        let leftView0 = UIView(frame: CGRect(x: 0, y: 0, width: 15, height: 16))
        let paddingView0 = UILabel(frame: CGRect(x: 0, y: 0, width: 10, height: 16))
        paddingView0.text = " "
        
        leftView0.addSubview(paddingView0)
        email.placeholder = "Email"
       email.leftView = leftView0
      
        let leftView1 = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: 16))
        let paddingView1 = UILabel(frame: CGRect(x: 0, y: 0, width: 10, height: 16))
        paddingView1.text = " "
        leftView1.addSubview(paddingView1)
        password.placeholder = "Password"
    
      password.leftView = leftView1
   
        email.leftViewMode = .always
        password.leftViewMode = .always
        facebookBt.layer.cornerRadius = 22
        appleBt.layer.cornerRadius = 22
    
        googleBt.layer.cornerRadius = 22
    
        
        let shadowOffset1 = CGSize(width: 2, height: 2.0)
        loginBt.layer.addShadow(shadowOffset: shadowOffset1, opacity: 0.2, radius: 10, shadowColor: UIColor.black)
   
        signUpBt.layer.addShadow(shadowOffset: shadowOffset1, opacity: 0.2, radius: 10, shadowColor: UIColor.black)
   
    }
    open override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return UIInterfaceOrientationMask.portrait
    }
    func initGesture()
    {
        let tapGesture0 = UITapGestureRecognizer(target: self, action: #selector(didTapLogin))
    //    loginBt.isUserInteractionEnabled = true
    //    loginBt.addGestureRecognizer(tapGesture0)
        
        let tapGesture1 = UITapGestureRecognizer(target: self, action: #selector(didTapFacebook))
        facebookBt.isUserInteractionEnabled = true
        facebookBt.addGestureRecognizer(tapGesture1)
        
        let tapGesture2 = UITapGestureRecognizer(target: self, action: #selector(didTapGoogle))
        googleBt.isUserInteractionEnabled = true
        googleBt.addGestureRecognizer(tapGesture2)
        
        let didTapApple = UITapGestureRecognizer(target: self, action: #selector(didTapApple))
        appleBt.isUserInteractionEnabled = true
        appleBt.addGestureRecognizer(didTapApple)
        
        let signup0 = UITapGestureRecognizer(target: self, action: #selector(didTapSignUp))
     //   signUpBt.isUserInteractionEnabled = true
     //   signUpBt.addGestureRecognizer(signup0)
        
        let tapGesture3 = UITapGestureRecognizer(target: self, action: #selector(tapPrivacy))
        descView.addGestureRecognizer(tapGesture3)
    }
    @IBAction func signIn()
    {
        activityIndicator.startAnimating()
   
        Auth.auth().signIn(withEmail: self.email.text!, password: self.password.text!) {[self] (user, error) in
            // ...
            if let error = error {
                // ...
               // RSLoadingView.hide(from: self.view)
                      
                showMsg(str: error.localizedDescription)
                activityIndicator.stopAnimating()
                return
            }
            guard let firUser = Auth.auth().currentUser else { return }
            
            let uid = firUser.uid
            let photo = firUser.photoURL?.absoluteString
            Messaging.messaging().token { token, error in
              if let error = error {
                print("Error fetching FCM registration token: \(error)")
              } else if let token = token {
                print("FCM registration token: \(token)")
               // self.fcmRegTokenMessage.text  = "Remote FCM registration token: \(token)"
                 
               
                  let user0 = UserData()
                  user0.profileImg = photo
                 // user0.name = firUser.displayName
                  user0.email = firUser.email
                  user0.userId = uid
                  user0.token = token
                  JunSoftAPI.shared.createUser(user: user0, completion: {[self](success,value) in
                      let json = JSON(value)
                      let code = json["code"].intValue
                      if(code == 200 || code == 201)
                      {
                          UserDefaults.standard.setValue(uid, forKey: "USER_ID")
                           
                       //   UserDefaults.standard.setValue(photo, forKey: "USER_PHOTO")
                          
                          UserDefaults.standard.synchronize()
                          
                          
                          dismiss(animated: true, completion: nil)
                         
                      }
                    
                  
                  })
              }
            }
            
            
        }
    }
    @IBAction func signup()
    {
        performSegue(withIdentifier: "exec_signup", sender: nil)

    }
    @objc func tapPrivacy()
    {
        performSegue(withIdentifier: "exec_privacy", sender: nil)
  
    }
    @objc func didTapSignUp()
    {
        performSegue(withIdentifier: "exec_signup", sender: nil)

    }
    @objc func didTapLogin()
    {
        performSegue(withIdentifier: "exec_email", sender: nil)
    }

    func showMsg(str:String)
    {
        var msg = str
       
        let snackbar = TTGSnackbar(message: msg, duration: .middle)

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
    @objc func didTapFacebook()
    {
        let fbLoginManager : FBSDKLoginKit.LoginManager = FBSDKLoginKit.LoginManager()
       
        //let loadingView = RSLoadingView()
        //loadingView.show(on: self.view)
     //   Spinner.start()
        activityIndicator.startAnimating()
   
        fbLoginManager.logIn(permissions: ["public_profile","email"], from: self) { [self] (result, error) -> Void in
            //self.view.isOpaque = true
            //self.view?.backgroundColor = UIColor(white: 1, alpha: 0.5)
            

            if (error == nil){
                let fbloginresult : LoginManagerLoginResult = result!
                if (result?.isCancelled)!{
                   // RSLoadingView.hide(from: self.view)
                    showMsg(str: error!.localizedDescription)
                    activityIndicator.stopAnimating()
                 
                    return
                }
                
                let credential = FacebookAuthProvider.credential(withAccessToken: AccessToken.current!.tokenString)
                Auth.auth().signIn(with: credential) {[self] (user, error) in
                    if let error = error {
                        // ...
                       // RSLoadingView.hide(from: self.view)
                  //      Spinner.stop()
                        showMsg(str: error.localizedDescription)
                        activityIndicator.stopAnimating()
                   
                        return
                    }
                    guard let firUser = Auth.auth().currentUser else { return }
                    let uid = firUser.uid
                    let photo = firUser.photoURL?.absoluteString
                    
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
                             
                                  dismiss(animated: true, completion: nil)
                                 
                              }
                            
                          
                          })
                      }
                    }
               
                    
                }
                
            }
        }
        
        
    }
    @objc func didTapGoogle()
    {
        activityIndicator.startAnimating()
   
        let clientId = "5691484609-bkp3odsfdl5b6euetu9vubj98rnpcq1q.apps.googleusercontent.com"
        let signInConfig = GIDConfiguration.init(clientID: clientId)
        GIDSignIn.sharedInstance.signIn(with: signInConfig, presenting: self) { user, error in
           guard error == nil else { return }

            guard let authentication = user?.authentication else { return }
      
            let credential = GoogleAuthProvider.credential(withIDToken: authentication.idToken!,
                                                           accessToken: authentication.accessToken)
      
            Auth.auth().signIn(with: credential) { [self] (user, error) in
                
                if let error = error {
                    // ...
                   // RSLoadingView.hide(from: self.view)
               
                    showMsg(str: error.localizedDescription)
            
                    activityIndicator.stopAnimating()
               
                    return
                }
            
                
                guard let firUser = Auth.auth().currentUser else { return }
                
                let uid = firUser.uid
                let photo = firUser.photoURL?.absoluteString
                
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
                         
                              dismiss(animated: true, completion: nil)
                             
                          }
                        
                      
                      })
                  }
                }
            
            }
        }
    }
    @objc func didTapApple()
    {
        activityIndicator.startAnimating()
   
        if #available(iOS 13.0, *) {
            FirebaseAuthentication.shared.parentCon = self
            FirebaseAuthentication.shared.signInWithApple(window: self.view.window!)
        } else {
            // Fallback on earlier versions
         //   appleBt.isHidden = true
        }
    }
    func appleLoginDelegate()
    {
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
                 
                      
                      dismiss(animated: true, completion: nil)
                     
                  }
                
              
              })
          }
        }
        
       
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "exec_signup"{
            
           
            if let detail = segue.destination as? SignupViewController {
                detail.parenCon = self
            }
        }
    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        
        email.resignFirstResponder()
        password.resignFirstResponder()
    //    cpassword.resignFirstResponder()
       
    }
}
