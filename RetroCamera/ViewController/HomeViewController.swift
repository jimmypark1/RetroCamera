//
//  HomeViewController.swift
//  RetroCamera
//
//  Created by Junsung Park on 2022/04/19.
//

import UIKit
import GoogleMobileAds
//import FirebaseMessaging

class HomeViewController: UIViewController,GADFullScreenContentDelegate{

    @IBOutlet weak var ivSlideshow:UIImageView!
   
    @IBOutlet weak var cameraBt:UIImageView!
    @IBOutlet weak var profileBt:UIImageView!
    
    @IBOutlet weak var collectionView:UICollectionView!
 
    @IBOutlet weak var more0:UILabel!
    @IBOutlet weak var more1:UILabel!
    @IBOutlet weak var more2:UILabel!
  
    @IBOutlet weak var stickerFrame:UIView!
    @IBOutlet weak var swapFrame:UIView!
    
    @IBOutlet weak var bannerHeight:NSLayoutConstraint!

 
    @IBOutlet weak var desc0:UILabel!
    @IBOutlet weak var desc1:UILabel!
    @IBOutlet weak var desc2:UILabel!
  
    var imagesArraySlideshow : [UIImage] = []
    var slideShowIndex:NSInteger = 0
    
    var slideShowMax:NSInteger = 0
    var end:Bool!
  
    let filterSource:FilterDemoDataSource = FilterDemoDataSource()
    
    var datas:Array<String> = Array<String>()
    @IBOutlet weak var  bannerView: GADBannerView!
    private var interstitial: GADInterstitialAd?

    var isCamera:Bool = false
    @objc func showStore()
    {
        performSegue(withIdentifier: "exec_store", sender: 0)
    }
    @objc func showStore2()
    {
        performSegue(withIdentifier: "exec_store", sender: 1)
    }
    @objc func showStore3()
    {
        performSegue(withIdentifier: "exec_store", sender: 2)
    }
    
    func addBannerViewToView(_ bannerView: GADBannerView) {
      
      }
    
    func initUI()
    {
        desc0.text = "How are you feeling today?\nUpgrade your mood with cute and fun sticker lenses. We look forward to seeing you again.".localized
        
        desc1.text = "Retro Camera captures you beautifully, lovingly, warmly, and sometimes vintage. check it out now".localized
        
        desc2.text = "Find another face of yours!\nSometimes handsome and beautiful...\nSometimes it's fun!!!".localized
        
     
        more0.text = "More...".localized
        more1.text = "More...".localized
        more2.text = "More...".localized
        
    }
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        buildImagesArraySlideshow()
        initGesture()
        initDemoData()
        initUI()
     
        //
      //  bannerHeight.constant = 0
        bannerView.adUnitID = "ca-app-pub-7915959670508279/8457567696"
        bannerView.rootViewController = self
        bannerView.load(GADRequest())
    }
    /// Tells the delegate that the ad failed to present full screen content.
     func ad(_ ad: GADFullScreenPresentingAd, didFailToPresentFullScreenContentWithError error: Error) {
       print("Ad did fail to present full screen content.")
     }

     /// Tells the delegate that the ad will present full screen content.
     func adWillPresentFullScreenContent(_ ad: GADFullScreenPresentingAd) {
       print("Ad will present full screen content.")
     }

     /// Tells the delegate that the ad dismissed full screen content.
     func adDidDismissFullScreenContent(_ ad: GADFullScreenPresentingAd) {
       print("Ad did dismiss full screen content.")
         var vip0 = UserDefaults.standard.bool(forKey: "BUY_VIP0")
         var vip1 = UserDefaults.standard.bool(forKey: "BUY_VIP1")
         var vip2 = UserDefaults.standard.bool(forKey: "BUY_VIP2")
   
       
         if(vip0 == false)
         {
             showStore()
         }
         else if(vip1 == false)
         {
             showStore2()
         }
         else if(vip2 == false)
         {
             showStore3()
         }
     }
    func showFullAd()
    {
        //
        let request = GADRequest()
    
        GADInterstitialAd.load(withAdUnitID:"ca-app-pub-7915959670508279/7706758658",
                                       request: request,
                             completionHandler: { [self] ad, error in
                               if let error = error {
                                 print("Failed to load interstitial ad with error: \(error.localizedDescription)")
                                 return
                               }
           interstitial = ad
            interstitial?.fullScreenContentDelegate = self
            if interstitial != nil {
                interstitial!.present(fromRootViewController: (self))
              } else {
                print("Ad wasn't ready")
              }
                            
           }
           
       )
        
        
      
    }
    override func viewWillAppear(_ animated: Bool) {
        // login check
        showSlide()
       
        var vip0 = UserDefaults.standard.bool(forKey: "BUY_VIP0")
        var vip1 = UserDefaults.standard.bool(forKey: "BUY_VIP1")
        var vip2 = UserDefaults.standard.bool(forKey: "BUY_VIP2")
        
        if( vip0 == true || vip1 == true || vip2 == true)
        {
            bannerHeight.constant = 0
        }
        if( vip0 == true && vip1 == true && vip2 == true)
        {
            
        }
        else
        {
            if(JunSoftUtil.shared.isDetail == true)
            {
                JunSoftUtil.shared.isDetail = false
                showFullAd()
            }
          
        }
      
       
      
    }
    open override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return UIInterfaceOrientationMask.portrait
    }
    override func viewDidAppear(_ animated: Bool) {
         let userId = UserDefaults.standard.string(forKey: "USER_ID")
        let isIntro = UserDefaults.standard.bool(forKey: "INTRO_LOAD")
        let isInit = UserDefaults.standard.bool(forKey: "INIT_APP")
        
        if( isInit == false)
        {
            UserDefaults.standard.set(true, forKey: "INIT_APP")
            UserDefaults.standard.synchronize()
            CameraAPI.shared.initCameraSession(front: true)
    
            performSegue(withIdentifier: "exec_store", sender: 0)
     
         }
        
    
    
     /*
        if(userId != nil && userId!.count > 0)
        {
          
            if(isIntro == true && isInit == false)
            {
                UserDefaults.standard.set(true, forKey: "INIT_APP")
                UserDefaults.standard.synchronize()
                CameraAPI.shared.initCameraSession(front: true)
        
                performSegue(withIdentifier: "exec_store", sender: 0)
         
             }
        
        }
        else
        {
           
            if(isIntro == false )
            {
                showOnBoarding()
            }
            else
            {
                showLogin()
            }
            
           
            //performSegue(withIdentifier: "exec_login", sender: nil)
        }
      */
       
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.end = true
       
        isCamera = false
    }
    func buildImagesArraySlideshow(){
          // example: localImageFilePath:URL = *URLs FOR SOME LOCAL IMAGE FILES*
          
        imagesArraySlideshow.append(UIImage(named: "demo0")!)
        imagesArraySlideshow.append(UIImage(named: "demo1")!)

        imagesArraySlideshow.append(UIImage(named: "demo2")!)
        imagesArraySlideshow.append(UIImage(named: "demo3")!)

        imagesArraySlideshow.append(UIImage(named: "demo4")!)
       
      }
    func showSlide()
    {
        buildImagesArraySlideshow()
        self.end = false
        self.slideShowMax = self.imagesArraySlideshow.count
             // ivSlideshow.contentMode = .scaleToFill
              DispatchQueue.global(qos: .userInteractive).async (
                  execute: {() -> Void in
                      while self.end == false {
                          print ("MAX:"+String(self.slideShowMax))
                          
                          DispatchQueue.main.async(execute: {() -> Void in
                              let toImage = self.imagesArraySlideshow[self.slideShowIndex]
                              print ("index:"+String(self.slideShowIndex))
                              UIView.transition(
                                  with: self.ivSlideshow,
                                  duration: 0.6,
                                  options: .transitionCrossDissolve,
                                  animations: {self.ivSlideshow.image = toImage},
                                  completion: nil
                              )
                          })
                          self.slideShowIndex += 1
                          if self.slideShowIndex == self.slideShowMax {
                              self.slideShowIndex = 0
                          }
                          sleep(2)
                      }
              })
    }
  
    func initDemoData()
    {
        
        datas.removeAll()
        datas.append("p0")
        datas.append("p9")
        datas.append("p2")
        datas.append("p8")
        datas.append("p1")
        datas.append("p5")
        datas.append("p6")
        datas.append("p7")
        datas.append("p4")
        datas.append("p2")
     
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        layout.minimumLineSpacing = 0
  
        //56 + 18 + 8
        let width = UIScreen.main.bounds.size.width
        layout.itemSize = CGSize(width: 120,height: 120)
     
        filterSource.parentCon = self
        filterSource.initData(data: datas)
        collectionView.dataSource = filterSource
        collectionView.delegate = filterSource
        collectionView.setCollectionViewLayout(layout, animated: false)
       
        collectionView.reloadData()
    }
    @objc func showCamera()
    {
        
       // showSouceMenu()
        showCameraView()
        
//        if(isCamera == false)
//        {
//            isCamera = true
//            performSegue(withIdentifier: "exec_camera", sender: nil)
//        }
    }
    
    func initGesture()
    {
        let tapGesture0 = UITapGestureRecognizer(target: self, action: #selector(showCamera))
        cameraBt.isUserInteractionEnabled = true
        cameraBt.addGestureRecognizer(tapGesture0)
        
      /*
        let tapGesture1 = UITapGestureRecognizer(target: self, action: #selector(showProfile))
        profileBt.isUserInteractionEnabled = true
        profileBt.addGestureRecognizer(tapGesture1)
   */
        //ivSlideshow
        
        let tapGesture2 = UITapGestureRecognizer(target: self, action: #selector(showStore))
        stickerFrame.isUserInteractionEnabled = true
        stickerFrame.addGestureRecognizer(tapGesture2)
   
     
        let tapGesture4 = UITapGestureRecognizer(target: self, action: #selector(showStore2))
        more1.isUserInteractionEnabled = true
        more1.addGestureRecognizer(tapGesture4)
        
        let tapGesture5 = UITapGestureRecognizer(target: self, action: #selector(showStore2))
        collectionView.isUserInteractionEnabled = true
        collectionView.addGestureRecognizer(tapGesture5)
        
        let tapGesture6 = UITapGestureRecognizer(target: self, action: #selector(showStore3))
        swapFrame.isUserInteractionEnabled = true
        swapFrame.addGestureRecognizer(tapGesture6)
    }
    
    @objc func showProfile()
    {
        performSegue(withIdentifier: "exec_profile", sender: nil)
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "exec_store"{
            
            let type = sender as! Int
           
            if let detail = segue.destination as? StoreViewController {
                detail.type = type
                if(type == 0)
                {
                    detail.titleStr = "Face AI Sticker Lens"
          
                }
                if(type == 1)
                {
                    detail.titleStr = "Color Lookup Lens"
          
                }
                if(type == 2) 
                {
                    detail.titleStr = "Face AI Swap Lens"
          
                }
            }
        }
    }
}

