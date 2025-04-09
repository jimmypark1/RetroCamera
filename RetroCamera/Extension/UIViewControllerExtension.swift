//
//  UIViewControllerExtension.swift
//  RetroCamera
//
//  Created by Junsung Park on 2022/04/25.
//

import TTGSnackbar

extension UIViewController {


    //
    func showLogin()
    {
        /*
        let storyboard = UIStoryboard(name: "Login", bundle: nil)
        
        let vc = storyboard.instantiateViewController(withIdentifier: "Login") as! LoginViewController
      
          let transition = CATransition()
        transition.duration = 0.3
        transition.type = CATransitionType(rawValue: "fade")
   //     transition.subtype = .fromRight
       // self.navigationController?.view.layer.add(transition, forKey: kCATransition)
      //  self.navigationController?.pushViewController(vc, animated: false)

        self.present(vc, animated: true, completion: nil)
         */
  
    }
    func showOnBoarding()
    {
        /*
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        
        let vc = storyboard.instantiateViewController(withIdentifier: "OnBordingViewController") as! OnBordingViewController
      
          let transition = CATransition()
        transition.duration = 0.3
        transition.type = CATransitionType(rawValue: "fade")
   //     transition.subtype = .fromRight
       // self.navigationController?.view.layer.add(transition, forKey: kCATransition)
      //  self.navigationController?.pushViewController(vc, animated: false)

        self.present(vc, animated: true, completion: nil)
         */
  
    }
    func showStore0(type:Int)
    {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        
//        let vc = storyboard.instantiateViewController(withIdentifier: "StoreViewController") as! StoreViewController
        let vc = SubscribeViewController()
      
//        vc.type = type
//        
//        if(type == 0)
//        {
//            vc.titleStr = "Face AI Sticker Lens"
//  
//        }
//        if(type == 1)
//        {
//            vc.titleStr = "Color Lookup Lens"
//  
//        }
//        if(type == 2)
//        {
//            vc.titleStr = "Face AI Swap Lens"
//  
//        }
        
          let transition = CATransition()
        transition.duration = 0.3
        transition.type = CATransitionType(rawValue: "fade")
  
        self.present(vc, animated: true, completion: nil)
  
    }
    func show(msg:String)
    {
        let snackbar = TTGSnackbar(message: msg, duration: .long)

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
    func showRegister()
    {
        /*
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        
        let vc = storyboard.instantiateViewController(withIdentifier: "SignupViewController") as! SignupViewController
      
      //  vc.parenCon = self
          let transition = CATransition()
        transition.duration = 0.3
        transition.type = CATransitionType(rawValue: "fade")
   //     transition.subtype = .fromRight
       // self.navigationController?.view.layer.add(transition, forKey: kCATransition)
      //  self.navigationController?.pushViewController(vc, animated: false)

        self.present(vc, animated: true, completion: nil)
         */
  
    }
    
    func showSouceMenu()
    {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        
        let vc = storyboard.instantiateViewController(withIdentifier: "SourceMenuViewController") as! SourceMenuViewController
        let transition = CATransition()
        transition.duration = 0.3
        transition.type = CATransitionType(rawValue: "fade")
        //transition.subtype = .fromRight
       // self.navigationController?.view.layer.add(transition, forKey: kCATransition)
       // self.navigationController?.pushViewController(vc, animated: false)
        self.present(vc, animated: true, completion: nil)
  
    }
    
    func showCameraView(){
        //
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        
        let vc = storyboard.instantiateViewController(withIdentifier: "CameraVieqController") as! ViewController
        let transition = CATransition()
        transition.duration = 0.3
        transition.type = CATransitionType(rawValue: "fade")
        //transition.subtype = .fromRight
       // self.navigationController?.view.layer.add(transition, forKey: kCATransition)
       // self.navigationController?.pushViewController(vc, animated: false)
        self.present(vc, animated: true, completion: nil)
    }
    
   
}
