//
//  EmailLoginViewController.swift
//  RetroCamera
//
//  Created by Junsung Park on 2022/04/19.
//

import UIKit

class EmailLoginViewController: UIViewController {

    @IBOutlet weak var loginBt:UIButton!
    
    @IBOutlet weak var email:UITextField!
    @IBOutlet weak var password:UITextField!
    
  
    override func viewDidLoad() {
        super.viewDidLoad()

        initUI()
    }
    

  
    @IBAction func Close()
    {
        dismiss(animated: true, completion: nil)
    }
    open override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return UIInterfaceOrientationMask.portrait
    }
    func initUI()
    {
        loginBt.layer.cornerRadius = 22
       
        email.layer.cornerRadius = 22
        email.layer.borderWidth = 2
        email.layer.borderColor = UIColor.white.cgColor
     
  
        password.layer.cornerRadius = 22
        password.layer.borderWidth = 2
        password.layer.borderColor = UIColor.white.cgColor
    
        
        email.attributedPlaceholder = NSAttributedString(string: "Email", attributes: [NSAttributedString.Key.foregroundColor : UIColor.white])
        
        password.attributedPlaceholder = NSAttributedString(string: "Password", attributes: [NSAttributedString.Key.foregroundColor : UIColor.white])
        
        
        
        let leftView = UIView(frame: CGRect(x: 0, y: 0, width: 15, height: 16))
        let paddingView = UILabel(frame: CGRect(x: 0, y: 0, width: 10, height: 16))
        paddingView.text = " "
     
        leftView.addSubview(paddingView)
     
        email.leftView = leftView
        email.leftViewMode = .always;

        let leftView2 = UIView(frame: CGRect(x: 0, y: 0, width: 15, height: 16))
        let paddingView2 = UILabel(frame: CGRect(x: 0, y: 0, width: 10, height: 16))
        paddingView2.text = " "
     
        leftView2.addSubview(paddingView2)
     
        password.leftView = leftView2
        password.leftViewMode = .always;

    }
}
