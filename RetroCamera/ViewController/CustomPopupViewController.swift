//
//  CustomPopupViewController.swift
//  BeautyCamera
//
//  Created by Junsung Park on 2022/02/17.
//

import UIKit

protocol PopupDelegate {
    func didTapOK(sender:AnyObject)
    func didTapCancel(sender:AnyObject)
}

class CustomPopupViewController: UIViewController {

    @IBOutlet weak var msgLabel:UILabel!
    
    @IBOutlet weak var okBt:UIButton!
    @IBOutlet weak var cancelBt:UIButton!
  
    var delegate: PopupDelegate?
      
    var msg:String = ""
    let langType =   UserDefaults.standard.integer(forKey:  "LANG_TYPE")
    var popup:Any!
   
    override func viewDidLoad() {
        super.viewDidLoad()

        msgLabel.text = msg
        okBt.setTitle("OK", for: .normal)
        cancelBt.setTitle("Cancel", for: .normal)

        
    }
    override func viewWillAppear(_ animated: Bool) {
       
    }
    
    @IBAction private func OK(_ sender: AnyObject){
        if(popup != nil)
        {
            (popup as! UIViewController).dismiss(animated: true)
        }
       delegate?.didTapOK(sender: self)
       
      //  dismiss(animated: true, completion: nil)
      
    }
    
    @IBAction private func Cancel(_ sender: AnyObject){
           delegate?.didTapCancel(sender: self)
       // dismiss(animated: true, completion: nil)
 
    }
    

}
