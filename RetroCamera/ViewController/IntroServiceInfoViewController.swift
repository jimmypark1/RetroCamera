//
//  IntroServiceInfoViewController.swift
//  BeautyCamera
//
//  Created by Junsung Park on 2022/02/22.
//

import UIKit

import WebKit

class IntroServiceInfoViewController: UIViewController {

    @IBOutlet var webView:WKWebView!
  
    @IBOutlet var selIndex:UISegmentedControl!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        var urlStr :String!
        selIndex.addTarget(self, action: #selector(tapPrivacy), for: .valueChanged)
        
        if( selIndex.selectedSegmentIndex == 0)
        {
            // Terms of Service
         //   titleLabel.text = "Terms of Service"
            urlStr = "http://www.junsoft.org/b_terms_e.html"
            
        }
        else
        {
            // Privacy Policy
          //  titleLabel.text = "Privacy Policy"
            urlStr = "http://www.junsoft.org/b_privacy_e.html"
            
        }
        let request = URLRequest( url: URL(string: urlStr)!)
       // webView.loadRequest(request)
        webView.load(request)
               
    }
    open override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return UIInterfaceOrientationMask.portrait
    }
    @objc func tapPrivacy() {
        var urlStr :String!
        
        if( selIndex.selectedSegmentIndex == 0)
        {
            // Terms of Service
            //   titleLabel.text = "Terms of Service"
            urlStr = "http://www.junsoft.org/b_terms_e.html"
            
        }
        else
        {
            // Privacy Policy
            //  titleLabel.text = "Privacy Policy"
            urlStr = "http://www.junsoft.org/b_privacy_e.html"
            
        }
        let request = URLRequest( url: URL(string: urlStr)!)
        webView.load(request)
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    @IBAction func close()
    {
        dismiss(animated: true, completion: nil)
    }
}
