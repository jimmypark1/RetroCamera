//
//  OnBordingViewController.swift
//  RetroCamera
//
//  Created by Junsung Park on 2022/04/26.
//

import UIKit
import SwiftyOnboard
import Hue
import PermissionWizard

class OnBordingViewController: UIViewController {
    var swiftyOnboard: SwiftyOnboard!
      
//    let colors:[UIColor] = [#colorLiteral(red: 0.9980840087, green: 0.3723873496, blue: 0.4952875376, alpha: 1),#colorLiteral(red: 0.2666860223, green: 0.5116362572, blue: 1, alpha: 1),#colorLiteral(red: 0.1019607857, green: 0.2784313858, blue: 0.400000006, alpha: 1)]
    
    var gradiant: CAGradientLayer = {
         //Gradiant for the background view
         let blue = UIColor(red: 69/255, green: 127/255, blue: 202/255, alpha: 1.0).cgColor
         let purple = UIColor(red: 166/255, green: 172/255, blue: 236/255, alpha: 1.0).cgColor
         let gradiant = CAGradientLayer()
         gradiant.colors = [purple, blue]
         gradiant.startPoint = CGPoint(x: 0.5, y: 0.18)
         return gradiant
     }()
    override func viewDidLoad() {
        super.viewDidLoad()
        gradient()
          
        do {
            try Permission.camera.requestAccess(completion:  {[self] status in
                
             
               
                 
            })
        } catch let error {
             
            guard let error = error as? Permission.Error else {
                return
            }
            
            error.type // .missingPlistKey
        }
        initOnBoard()
    }
    override var preferredStatusBarStyle: UIStatusBarStyle {
    
        return .lightContent
    
    }
    func gradient() {
          //Add the gradiant to the view:
          self.gradiant.frame = view.bounds
          view.layer.addSublayer(gradiant)
      }
      
    func initOnBoard()
    {
       
        swiftyOnboard = SwiftyOnboard(frame: view.frame, style: .light)
        view.addSubview(swiftyOnboard)
        swiftyOnboard.dataSource = self
        swiftyOnboard.delegate = self
    }
    @objc func handleSkip() {
          swiftyOnboard?.goToPage(index: 2, animated: true)
      }
      
      @objc func handleContinue(sender: UIButton) {
          let index = sender.tag
          swiftyOnboard?.goToPage(index: index + 1, animated: true)
          if(index == 2)
          {
              UserDefaults.standard.set(true, forKey: "INTRO_LOAD")
              UserDefaults.standard.synchronize()
              dismiss(animated: true, completion: nil)
              
           //   showLogin()
          }
      }
    open override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return UIInterfaceOrientationMask.portrait
    }
}

extension OnBordingViewController: SwiftyOnboardDelegate,SwiftyOnboardDataSource {

    func swiftyOnboardNumberOfPages(_ swiftyOnboard: SwiftyOnboard) -> Int {
            return 3
        }

    func swiftyOnboardPageForIndex(_ swiftyOnboard: SwiftyOnboard, index: Int) -> SwiftyOnboardPage? {
           
        let view = CustomPage.instanceFromNib() as? CustomPage
        view?.image.image = UIImage(named: "\(index + 1)")
       
        view?.titleLabel.layer.zPosition = 100
        if index == 0 {
            //On the first page, change the text in the labels to say the following:
            view?.titleLabel.text = "Retro Camera pays\nmore attention to you."
         //   view?.subTitleLabel.text = "Earth, otherwise known as the World, is the third planet from the Sun."
        } else if index == 1 {
            //On the second page, change the text in the labels to say the following:
            view?.titleLabel.text = "Vintage filter and funny effect give you a feeling."
           // view?.subTitleLabel.text = "Outer space or just space, is the void that exists between celestial bodies, including Earth."
        } else {
            //On the thrid page, change the text in the labels to say the following:
            view?.titleLabel.text = "Retro Camera\nis waiting for you."
           // view?.subTitleLabel.text = "Extraterrestrial life, also called alien life, is life that does not originate from Earth."
        }
        return view
        
    }
    
    func swiftyOnboardViewForOverlay(_ swiftyOnboard: SwiftyOnboard) -> SwiftyOnboardOverlay? {
        /*
            let overlay = SwiftyOnboardOverlay()
            
            //Setup targets for the buttons on the overlay view:
            overlay.skipButton.addTarget(self, action: #selector(handleSkip), for: .touchUpInside)
            overlay.continueButton.addTarget(self, action: #selector(handleContinue), for: .touchUpInside)
            
            //Setup for the overlay buttons:
            overlay.continueButton.titleLabel?.font = UIFont(name: "Lato-Bold", size: 30)
            overlay.continueButton.setTitleColor(UIColor.white, for: .normal)
            overlay.skipButton.setTitleColor(UIColor.white, for: .normal)
            overlay.skipButton.titleLabel?.font = UIFont(name: "Lato-Heavy", size: 18)
            
            //Return the overlay view:
            return overlay
         */
            let overlay = CustomOverlay.instanceFromNib() as? CustomOverlay
            overlay?.skip.addTarget(self, action: #selector(handleSkip), for: .touchUpInside)
            overlay?.buttonContinue.addTarget(self, action: #selector(handleContinue), for: .touchUpInside)
            return overlay
        }
        
        func swiftyOnboardOverlayForPosition(_ swiftyOnboard: SwiftyOnboard, overlay: SwiftyOnboardOverlay, for position: Double) {
             /*
              let currentPage = round(position)
                  overlay.pageControl.currentPage = Int(currentPage)
            print(Int(currentPage))
            overlay.continueButton.tag = Int(position)
            
            if currentPage == 0.0 || currentPage == 1.0 {
                overlay.continueButton.setTitle("Continue", for: .normal)
                overlay.skipButton.setTitle("Skip", for: .normal)
                overlay.skipButton.isHidden = false
            } else {
                overlay.continueButton.backgroundColor = UIColor(hex:"f64a8a")
                overlay.continueButton.layer.cornerRadius = 10
                var rect = overlay.continueButton.frame
                rect.size.height = 44
                overlay.continueButton.frame = rect
                overlay.continueButton.setTitleColor(UIColor(hex:"ffffff"), for: .normal)
                overlay.continueButton.setTitle("Get Started!", for: .normal)
                overlay.skipButton.isHidden = true
            }
             */
            let overlay = overlay as! CustomOverlay
            let currentPage = round(position)
            overlay.contentControl.currentPage = Int(currentPage)
            overlay.buttonContinue.tag = Int(position)
            if currentPage == 0.0 || currentPage == 1.0 {
                overlay.buttonContinue.setTitle("Continue", for: .normal)
                overlay.skip.setTitle("Skip", for: .normal)
                overlay.skip.isHidden = false
            } else {
                overlay.buttonContinue.setTitle("Get Started!", for: .normal)
                overlay.skip.isHidden = true
            }
        }
}
