//
//  ProfileViewController.swift
//  RetroCamera
//
//  Created by Junsung Park on 2022/04/19.
//

import UIKit
import Carte

import GoogleSignIn
import SafariServices
import MessageUI
import FirebaseAuth
import TTGSnackbar
import Hue
import Hero


class ProfileViewController: UIViewController ,MFMailComposeViewControllerDelegate, PopupDelegate{

    @IBOutlet weak var tableView:UITableView!
    
    @IBOutlet weak var name:UILabel!
    @IBOutlet weak var profile:UIImageView!
 
    
    var version: String? { guard let dictionary = Bundle.main.infoDictionary, let version = dictionary["CFBundleShortVersionString"] as? String, let build =  dictionary["CFBundleVersion"] as? String else {return nil};
        return "v" + version }

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.separatorStyle = .none
        tableView.backgroundColor = .white
        if #available(iOS 15, *) {
            tableView.sectionHeaderTopPadding = 0
        }
        guard let firUser = Auth.auth().currentUser else { return }
        let uid = firUser.uid
        let photo = firUser.photoURL?.absoluteString
        let name0 = firUser.displayName
        let email = firUser.email
     
        if(photo != nil)
        {
            let thumbURL:URL = URL(string: photo!)!
     
          
            profile.sd_setImage(with:thumbURL, placeholderImage:nil)
         
        }
      
        if(name0 != nil)
        {
            name.text = name0

        }
        else if(name0 == nil && email != nil)
        {
            name.text = email

        }
     }
    

    @IBAction func close()
    {
        dismiss(animated: true, completion: nil)
    }
   

}

extension ProfileViewController:UITableViewDelegate,UITableViewDataSource
{
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: MyPageSettingsCell = tableView.dequeueReusableCell(withIdentifier: "MyPageSettingsCell") as! MyPageSettingsCell
       
        let section = indexPath.section
        let row = indexPath.row
        
        cell.detail.text = ""
        cell.selectionStyle = .none
  
        if(section == 0)
        {
            if(row == 0)
            {
                cell.accesory.isHidden = false
                cell.title.text = "Log out"

            }
          
            else if(row == 1)
            {
                cell.accesory.isHidden = false
                cell.title.text = "Support"

            }
            else if(row == 2)
            {
                cell.accesory.isHidden = false
                cell.title.text = "Rate this!!!"

            }
            else if(row == 3)
            {
                cell.accesory.isHidden = true
     
                cell.title.text = "Version"
                cell.detail.text = version
                cell.detail.textColor = UIColor(red: 255, green: 199, blue: 44, alpha: 1.0)
        
            }
            else if(row == 4)
            {
                cell.accesory.isHidden = false
     
                cell.title.text = "Withdrawal of Members"
              
            }
            
        }
        else if(section == 1)
        {
            cell.accesory.isHidden = false
            if(row == 0)
            {
                cell.title.text = "Privacy Policy"

            }
            else if(row == 1)
            {
                cell.title.text = "Terms of Service"

            }
          
       
        }
        else
        {
            cell.accesory.isHidden = true
 
            cell.title.text = "Store"

        }
        
   
        return cell
    }
        
   

     func tableView(_ tableView: UITableView,
                      numberOfRowsInSection section: Int) -> Int {
     
     
        
         if(section == 0)
         {
             return 5

       
         }
         else if(section == 1)
         {
             return 2

       
         }
        
         return 1
     }
         
     
     func numberOfSections(in tableView: UITableView) -> Int // Default is 1 if not implemented
     {
         return 2
        
     }
   
    func showSelectLanguage()
    {
        /*
        let storyboard = UIStoryboard(name: "Login", bundle: nil)
        
        let vc = storyboard.instantiateViewController(withIdentifier: "Language") as! LanguageSelectViewController
      
        vc.parentCon = self
        vc.type = 1
 
        let transition = CATransition()
        transition.duration = 0.3
        transition.type = CATransitionType(rawValue: "push")
        transition.subtype = .fromRight
        self.navigationController?.view.layer.add(transition, forKey: kCATransition)
        self.navigationController?.pushViewController(vc, animated: false)
         */
    }
    func showSelectCountry()
    {
        /*
        let storyboard = UIStoryboard(name: "Login", bundle: nil)
        
        let vc = storyboard.instantiateViewController(withIdentifier: "Country") as! SelectCountryViewController
      
        vc.navType = 1
 
        let transition = CATransition()
        transition.duration = 0.3
        transition.type = CATransitionType(rawValue: "push")
        transition.subtype = .fromRight
        self.navigationController?.view.layer.add(transition, forKey: kCATransition)
        self.navigationController?.pushViewController(vc, animated: false)
         */
    }
    func showEditProfile()
    {
        /*
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        
        let vc = storyboard.instantiateViewController(withIdentifier: "EditProfileViewController") as! EditProfileViewController
      
      
      
        let transition = CATransition()
        transition.duration = 0.3
        transition.type = CATransitionType(rawValue: "push")
        transition.subtype = .fromRight
        self.navigationController?.view.layer.add(transition, forKey: kCATransition)
        self.navigationController?.pushViewController(vc, animated: false)
       // self.present(vc, animated: true, completion: nil)
         */
  
    }
    func showNotificationSettings()
    {
        /*
        let storyboard = UIStoryboard(name: "Notification", bundle: nil)
        
        let vc = storyboard.instantiateViewController(withIdentifier: "NotificationSettings") as! NotificationSettingsViewController
      
       // vc.navType = 1
 
        let transition = CATransition()
        transition.duration = 0.3
        transition.type = CATransitionType(rawValue: "push")
        transition.subtype = .fromRight
        self.navigationController?.view.layer.add(transition, forKey: kCATransition)
        self.navigationController?.pushViewController(vc, animated: false)
         */
    }
    func viewLicense()
    {
        
        let vc = CarteViewController()
        
        vc.view.backgroundColor = .white
        vc.tableView.backgroundColor = .white
        let plus = UIImageView(frame: CGRect(x: 0,y: 0,width: 20,height: 20))
        plus.image = UIImage(named: "back_ic")
        plus.contentMode = .scaleAspectFit
        let plusBt = UIBarButtonItem(customView: plus)
        vc.navigationController?.isNavigationBarHidden = false

        vc.configureDetailViewController = { [self] detailVc in
            detailVc.textView.backgroundColor = .white
            detailVc.textView.textColor = UIColor.init(red: 48, green: 48, blue: 48)
          //  detailVc.navigationController?.navigationBar.backgroundColor = .white
        
          //  detailVc.navigationController?.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: UIBarButtonItem.Style.plain, target: nil, action: nil)
            detailVc.navigationController?.isNavigationBarHidden = false

            let plus = UIImageView(frame: CGRect(x: 0,y: 0,width: 20,height: 20))
            plus.image = UIImage(named: "back_ic")
            plus.contentMode = .scaleAspectFit
            let plusBt = UIBarButtonItem(customView: plus)
       
            detailVc.navigationItem.leftBarButtonItem = plusBt
            let tapGesture0 = UITapGestureRecognizer(target: self, action: #selector(didTabPrevCarte))
            plus.addGestureRecognizer(tapGesture0)
          //  detailVc.navigationController?.navigationItem.leftBarButtonItem = plusBt
        
        
        }
        let langType = UserDefaults.standard.integer(forKey: "LANG_TYPE")
        vc.navigationItem.title = "Open Source Licence"
 
        vc.navigationItem.leftBarButtonItem = plusBt
        let tapGesture0 = UITapGestureRecognizer(target: self, action: #selector(didTabPrevCarte))
        plus.addGestureRecognizer(tapGesture0)
     
        
   
        self.navigationController?.pushViewController(vc, animated: true)

   
        
    }
    @objc func didTabPrevCarte()
    {
        self.navigationController?.popViewController(animated: true)
  
    }
    //
    func showSafariViewController(_ url: URL) {
        
            let svc = SFSafariViewController(url: url)
            svc.preferredControlTintColor = UIColor.init(red: 180, green: 180, blue: 180)
            self.present(svc, animated: true, completion: nil)
        
        
    }
    func showSupport()
    {
        let composeVC = MFMailComposeViewController()
         composeVC.mailComposeDelegate = self
         composeVC.setToRecipients(["jimmy@junsoft.org"])
             
         composeVC.setMessageBody("Retro Camera Support " + String(self.version!), isHTML: false)

        
        self.present(composeVC, animated: true, completion: nil)

    }
    func mailComposeController(_ controller: MFMailComposeViewController,
                               didFinishWith result: MFMailComposeResult, error: Error?) {
      
    }
    func logout()
    {
        try? Auth.auth().signOut()
        UserDefaults.standard.setValue("", forKey: "USER_ID")
        UserDefaults.standard.setValue(false, forKey: "INTRO_LOAD")
      
        
        
        
        UserDefaults.standard.synchronize()
        dismiss(animated: true, completion: nil)
     //   showLogin()
      
    }
    func withrawal()
    {
        try? Auth.auth().signOut()
    
        JunSoftAPI.shared.withdrawal(completion: { [self](success,value) in
            
           
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
       
         //   appDelegate.moveHome()
            JunSoftUtil.shared.isUpdate = false
            JunSoftUtil.shared.isUpload = false
      
            JunSoftUtil.shared.type = 1
    
            self.tabBarController?.selectedIndex = 0
            UserDefaults.standard.setValue("", forKey: "USER_ID")
            UserDefaults.standard.setValue("", forKey: "USER_NAME")
            UserDefaults.standard.setValue("", forKey: "USER_PHOTO")
            UserDefaults.standard.setValue(false, forKey: "INTRO_LOAD")
          
            UserDefaults.standard.synchronize()
            
            dismiss(animated: true, completion: nil)

        })
    }
    open override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return UIInterfaceOrientationMask.portrait
    }
   
    func showAlert()
    {
    
        
        let current = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "CustomPopupViewController") as! CustomPopupViewController
        
        current.delegate = self
        current.isHeroEnabled = true
        current.hero.modalAnimationType = .fade
        
        current.msg =  "If you withdrawal members, uploaded content, and other activity data will all be deleted. Are you sure you want to withdrawal members?"
             
        self.present(current, animated: true, completion: nil)
         

    }
    func didTapOK(sender:AnyObject)
    {
        sender.dismiss(animated: true, completion: { [self] in
           // saveProcess(sender:sender)
            withrawal()
        })
     
      
        
 
    }
    func didTapCancel(sender:AnyObject)
    {
        sender.dismiss(animated: true, completion: nil)

    //    self.navigationController?.popViewController(animated: true)
 
    }
 
    func initData()
    {
        /*
        activityIndicator.startAnimating()
        JunSoftAPI.shared.initData(  completion: { [self] (sucess, value) in
            JunSoftUtil.shared.isUpdate = false
            JunSoftUtil.shared.isUpload = false
            JunSoftUtil.shared.type = 1
            activityIndicator.stopAnimating()
            var    msg = "Data initialization is complete."
              
             let snackbar = TTGSnackbar(message: msg, duration: .middle)

            // Action 1
            snackbar.messageTextFont = UIFont(name: "NotoSansCJKKR-Regular", size: 12)!
            snackbar.leftMargin = 16
            snackbar.rightMargin = 16
            snackbar.animationSpringWithDamping = 1.0
            snackbar.cornerRadius = 6
           
            snackbar.frame.size.height = 34
            snackbar.contentInset = UIEdgeInsets(top: 10, left: 14, bottom: 10, right: 14)
          
            snackbar.backgroundColor = UIColor(red: 68, green: 68, blue: 68, alpha: 1.0)
          
            
            snackbar.dismissBlock = { [self] (snackbar) in
            
            }
            snackbar.show()
            })
         */
    }
    /*
    
    func didTapOK(sender:AnyObject)
    {
        sender.dismiss(animated: true, completion: { [self] in
           // saveProcess(sender:sender)
            initData()
        })
      
        
 
    }
    func didTapCancel(sender:AnyObject)
    {
        sender.dismiss(animated: true, completion: nil)

    //    self.navigationController?.popViewController(animated: true)
 
    }
     */
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        self.tableView.deselectRow(at: indexPath, animated: true)
        
        let section = indexPath.section
        let row = indexPath.row
        
       
  
        if(section == 0)
        {
            if(row == 0)
            {
                logout()
            }
            else if(row == 1)
            {
                showSupport()
            }
            else if(row == 2)
            {
                if let url = URL(string: "itms-apps://itunes.apple.com/app/1282186219"), UIApplication.shared.canOpenURL(url) {
                    if #available(iOS 10.0, *) {
                        UIApplication.shared.open(url, options: [:], completionHandler: nil)
                        
                    } else { UIApplication.shared.openURL(url) }
                    
                }
            }
            else if(row == 3)
            {
                if let url = URL(string: "itms-apps://itunes.apple.com/app/1282186219"), UIApplication.shared.canOpenURL(url) {
                    if #available(iOS 10.0, *) {
                        UIApplication.shared.open(url, options: [:], completionHandler: nil)
                        
                    } else { UIApplication.shared.openURL(url) }
                    
                }
            }
            else if(row == 4)
            {
                showAlert()
            }
        }
        else if(section == 1)
        {
            if(row == 0)
            {
                showSafariViewController(URL(string:"http://www.junsoft.org/privacy_e.html")!)
       
            }
            else if(row == 1)
            {
                showSafariViewController(URL(string:"http://www.junsoft.org/terms_e.html")!)
         
            }
            else
            {
                viewLicense()
            }
        }
        else if(section == 2)
        {
            // logout
            logout()
        }
    
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 40
    }
    
   
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView?
    {
        let userType = UserDefaults.standard.integer(forKey: "USER_TYPE")
        let langType = UserDefaults.standard.integer(forKey: "LANG_TYPE")
     
        var title = ""
       
        if(section == 0)
        {
            title =  "Retro Camera"

        }
        else if(section == 1)
        {
            title =  "Terms and Policies"

        }
        else
        {
            title =  "Store"

        }
        let headerView = UIView.init(frame: CGRect.init(x: 0, y: 0, width: tableView.frame.width, height: 40))
        let label = UILabel()
        headerView.backgroundColor = UIColor(hex:"ff7088")
        
        
        let font =  UIFont(name: "NotoSans-Regular", size: 12)
        //width(withConstrainedHeight height: CGFloat, font: UIFont)
           
        label.frame = CGRect.init(x: 16, y: 10 , width: tableView.frame.width, height:20)
        label.text = title
        label.font = font
        label.textColor = .white//UIColor(red: 153, green: 153, blue: 153, alpha: 1.0)
        
        headerView.addSubview(label)
        return headerView
      
    }

  
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let v =  UIView()
        let footerView = UIView.init(frame: CGRect.init(x: 0, y: 0, width: tableView.frame.width - 16  , height: 1))
    
        let line = UIView.init(frame: CGRect.init(x: 16, y: 20, width: tableView.frame.width - 32 , height: 1))
    
        line.backgroundColor = UIColor(red: 245, green: 245, blue: 245, alpha: 1.0)
        footerView.addSubview(line)
        return footerView
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
     
        
        return 40
  
       
    }
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
            return 0
    
       
    }
    
    func tableView(_ tableView: UITableView, willDisplayFooterView view: UIView, forSection section: Int) {
            view.tintColor = UIColor.clear
      
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     
        //
    }
}
