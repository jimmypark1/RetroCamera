//
//  StoreViewController.swift
//  RetroCamera
//
//  Created by Junsung Park on 2022/04/20.
//

import UIKit
import Alamofire
import SSZipArchive
import GPUImage
import SwiftyStoreKit
import StoreKit
import SafariServices

class StoreViewController: UIViewController {

    @IBOutlet weak var imgView:UIImageView!
    @IBOutlet weak var collectionView:UICollectionView!
    @IBOutlet weak var renderView: GPUImageView?
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var termsLabel: UITextView!
    @IBOutlet weak var desc:UILabel!

    @IBOutlet weak var priceFrame: UIView!
    @IBOutlet weak var subscribeBt:UIButton!
   
    @IBOutlet weak var termsBt: UILabel!
    
    @IBOutlet weak var privacyBt: UILabel!
  
    @IBOutlet weak var restoreBt: UILabel!
  
    let itemSource:ItemDataSource = ItemDataSource()
  
    var datas:Array<String> = Array<String>()
    var itemAccesorys:NSDictionary?

    var sdkManager:SDKManager = SDKManager()
    var scene:Scene?
    
    var type:Int = 0
    //
    var videoCamera:GPUImageStillCamera?
     var frontCamera:GPUImageStillCamera?
     
     var frontCamera0:GPUImageStillCamera?
     var frontCamera1:GPUImageStillCamera?
     
     var front480Camera:GPUImageStillCamera?
     var backCamera:GPUImageStillCamera?
     var filter: GPUImageFilter?
     var beautyFilterGroup: BeautyFilterGroup?
     var cropFilter: CropFilter?
     
   //  var movieWriter: GPUImageMovieWriter?
     var framerate:Float64?
     var fov:Float?
     var fov1:Float?
     var ret:Bool?
     var beautyFilter:BeautyFilter?
     var sharpenFilter:GPUImageSharpenFilter?
     var contrastFilter:GPUImageContrastFilter?
     
     var jFaceLookup:LookupFilterGroup?
     var capturedImage:UIImage?
     // var stickerDelegate : StickerDelegate?
     
     var toneData:Data?
     
     var bFront :Bool?
     var bTorch:Bool?
     var bSqare:Bool?
     
     var ratioMode: Int?
     var oldRatioMode: Int?
     
     var timer:Timer?
     var count = 0
     var timerShotCount: Int?
     
     var bVline:Bool!
     var bOpenEyes:Bool!
     var bBigEyes:Bool!
     var bClick:Bool!
    var exportUrl:NSURL?
    var bBeauty:Bool?
    
    var frameCount:Int!
    var filters:NSMutableArray?
    var filterSource:FiterItemSource!
    
    var maskSource = MaskDemoItemSource()

 
    var titleStr:String = ""
    
    var timer0:Timer?
    var isCameraOn = false
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
    func getProduct()
    {
        var producrId = "com.junsoft.retro.sticker"
        if(type == 1)
        {
            producrId = "com.junsoft.retro.filter"
        }
        else if(type == 2)
        {
            producrId = "com.junsoft.retro.swap"
        }
        SwiftyStoreKit.retrieveProductsInfo([producrId]) { result in
             if let product = result.retrievedProducts.first {
                 let priceString = product.localizedPrice!
               //  print("Product: \(product.localizedDescription), price: \(priceString)")
                self.priceLabel.text = priceString + " / " + "weeks"
                 self.termsLabel.text = "- Please read below about the auto-renewing subscription nature of this product: • Payment will be charged to iTunes Account at confirmation of purchase • Subscription automatically renews unless auto-renew is turned off at least 24-hours before the end of the current period • Account will be charged for renewal within 24-hours prior to the end of the current period, and identify the cost of the renewal • Subscriptions may be managed by the user and auto-renewal may be turned off by going to the user's Account Settings after purchase • Any unused portion of a free trial period, if offered, will be forfeited when the user purchases a subscription to that publication, where applicable "
         
             }
             else if let invalidProductId = result.invalidProductIDs.first {
                 print("Invalid product identifier: \(invalidProductId)")
                 
             }
             else {
                 print("Error: \(result.error)")
             }
            
       
         }
             
    }
    @IBAction func buy()
    {
        var product :String = "com.junsoft.retro.sticker"
        
        if(type == 1)
        {
            product = "com.junsoft.retro.filter"
          
        }
        else if(type == 2)
        {
            product = "com.junsoft.retro.swap"
        
    
        }
        SwiftyStoreKit.purchaseProduct(product, atomically: true) {[self] result in
            
            if case .success(let purchase) = result {

                if(type == 0)
                {
                    UserDefaults.standard.set(true,forKey: "BUY_VIP0")
                    
                    UserDefaults.standard.synchronize()
                }
                else if(type == 1)
                {
                    UserDefaults.standard.set(true,forKey: "BUY_VIP1")
                    
                    UserDefaults.standard.synchronize()
                }
                else if(type == 2)
                {
                    UserDefaults.standard.set(true,forKey: "BUY_VIP2")
                    
                    UserDefaults.standard.synchronize()
                }
               
                  

                if purchase.needsFinishTransaction {
                    SwiftyStoreKit.finishTransaction(purchase.transaction)
                }
                let appleValidator = AppleReceiptValidator(service: .production, sharedSecret: IAPHelper.sharedSecret)
                SwiftyStoreKit.verifyReceipt(using: appleValidator) { [self] result in
                    switch result {
                    case .success(let receipt):
                        let purchaseResult = SwiftyStoreKit.verifySubscription(
                            ofType: .autoRenewable, // or .nonRenewing (see below)
                            productId: product,
                            inReceipt: receipt)
                        var buy = 0
                        switch purchaseResult {
                        case .purchased(let expiryDate):
                            
                           buy = 1
                        case .expired(let expiryDate):
                            buy = 0
                        case .notPurchased:
                            
                            buy = 0
                        }
                      
                       // self.complete(buy:buy, type:type)
                       
                        if(buy == 1)
                        {
                            show(msg:"The purchase was successful.")
             
                            self.close()
                        }
                       
                   
                    case .error(let error):
                        print("Receipt verification failed: \(error)")
                      //  activityIndicator.stopAnimating()
                        show(msg: "Receipt verification failed")
         
                    }
                }
            
                
            } else {
            //    Spinner.stop()
                // purchase error
              
                if case .error(let error) = result {
                    
                    var msg =  "\(error)"
                    show(msg:"Receipt verification failed")
     
                    print("Receipt verification failed: \(error.code)")
                 
                }
             
          
            }
        }
    }
    func initSDK()
    {
        
       
        scene = CameraAPI.shared.getScene()
        bFront = CameraAPI.shared.isFront()
        
        videoCamera = CameraAPI.shared.getVideoCamera()
   
        self.scene?.earringName = "none"
    
        self.scene?.hatName = "none"
       
        self.scene?.glassesName = "none"
      
        self.scene?.mustacheName = "none"
        self.videoCamera?.delegate = self
      
        jFaceLookup = LookupFilterGroup()
      
      
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.addSubview(self.activityIndicator)

        initGesture()
        initSDK()
        filters = NSMutableArray()
         
        titleLabel.text = titleStr
        
        priceFrame.layer.cornerRadius = 10
        priceFrame.layer.borderWidth = 1
        priceFrame.layer.borderColor = UIColor(hex:"62afe2").cgColor
   //     priceFrame.backgroundColor = UIColor(hex:"EDFFFB")
        
        
        let shadowOffset1 = CGSize(width: 2, height: 2.0)
        activityIndicator.startAnimating()
        subscribeBt.layer.addShadow(shadowOffset: shadowOffset1, opacity: 0.2, radius: 10, shadowColor: UIColor.black)
    
        
        subscribeBt.setTitle("Add to Lens".localized, for: .normal)
        getProduct()
  
        if(type == 0)
        {
             let json = "http://www.junsoft.org/stickers/live_sticker.json"
            
            desc.text = "Try the filter lenses beforehand.These filter lenses make the new you stand out or make you cute.Would you like to apply that filter lens?".localized
            downloadJSON(url: json,filename: "live_sticker.json")
        
        }
        else if(type == 1)
        {
           // let json = "http://www.junsoft.org/stickers/live_sticker.json"
            
            //downloadJSON(url: json,filename: "live_sticker.json")
            desc.text = "Retro Camera captures you beautifully, lovingly, warmly, and sometimes vintage. check it out now".localized
            makeFilterList()
        }
        else
        {
            let json = "http://www.junsoft.org/mask/mask.json"
            
            desc.text = "Find another face of yours!Sometimes handsome and beautiful...Sometimes it's fun!!!Would you like to apply that Swap lens?".localized
            downloadMaskJSON(url: json,filename: "mask.json")
           
            //downloadJSON(url: json,filename: "live_sticker.json")
           // makeFilterList()
        }
        //
     
        //
        
       // let json = "http://www.junsoft.org/stickers/live_sticker.json"
        
       renderView?.layer.cornerRadius = 10
       renderView?.layer.masksToBounds = true
  
        
   
    }
    func downloadMaskJSON(url : String, filename : String)
    {
        
        let manager = FileManager.default


        let path = String(format: "sticker/%@", filename)

        let pathUrl = dataFileURL(fileName: filename)

        let destination: DownloadRequest.Destination = { _, _ in

            var documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            documentsURL.appendPathComponent(path)
            return (documentsURL, [.removePreviousFile])
                           
        }
        if(manager.fileExists(atPath: pathUrl.path!))
        {
             do{
                 try manager.removeItem(at:  pathUrl as URL)
                 
             } catch {
                 print("Error: \(error.localizedDescription)")
             }
        }
        AF.download(url,to:destination).responseData { [self] (_data) in
                        
          
            if(_data.error != nil)
            {
                 
                                 
                return
            }
                  
            var data:NSData = manager.contents(atPath: pathUrl.path!) as! NSData
          
            if(data.length != 0)
            {
                    do{
                      
                        self.itemAccesorys = try JSONSerialization.jsonObject(with: data as Data, options:[]) as? [String: AnyObject] as! NSDictionary
                        
                        
                      //  self.dataSourceMask = MaskDelegate(items:self.masks!,owner:self)
                        
                      //  self.collectionView?.delegate = self.dataSourceMask
                     //   self.collectionView?.dataSource = self.dataSourceMask
                        
                        let layout = UICollectionViewFlowLayout()
                            
                        let width = UIScreen.main.bounds.size.width
                        layout.itemSize = CGSize(width: 60,height: 60)
                     
                        layout.scrollDirection = .horizontal
                        layout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
                        layout.minimumLineSpacing = 15
                   
                        //
                   
                        maskSource = MaskDemoItemSource()
                        maskSource.parentCon = self
                        maskSource.initData(data: self.itemAccesorys!)
                        self.collectionView?.delegate = maskSource
                        self.collectionView?.dataSource = maskSource
                        collectionView.setCollectionViewLayout(layout, animated: false)
              
                        self.collectionView?.reloadData()
                        
                        
                        
                        
                    }catch{
                        
                      
                        
                    }
                }
                
    
        }
    
      
    }
    open override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return UIInterfaceOrientationMask.portrait
    }
    func initGesture()
    {
        let tapGesture0 = UITapGestureRecognizer(target: self, action: #selector(showTerms))
        termsBt.isUserInteractionEnabled = true
        termsBt.addGestureRecognizer(tapGesture0)
      
        let tapGesture1 = UITapGestureRecognizer(target: self, action: #selector(showPrivacy))
        privacyBt.isUserInteractionEnabled = true
        privacyBt.addGestureRecognizer(tapGesture1)
    
        let tapGesture2 = UITapGestureRecognizer(target: self, action: #selector(restorePurchase))
        restoreBt.isUserInteractionEnabled = true
        restoreBt.addGestureRecognizer(tapGesture2)
    
    }
    func showSafariViewController(_ url: URL) {
        
            let svc = SFSafariViewController(url: url)
            svc.preferredControlTintColor = UIColor.init(red: 180, green: 180, blue: 180)
            self.present(svc, animated: true, completion: nil)
        
        
    }
    @objc func showTerms()
    {
        
        showSafariViewController(URL(string:"http://www.junsoft.org/terms_e.html")!)

    }
    @objc func showPrivacy()
    {
        showSafariViewController(URL(string:"http://www.junsoft.org/privacy_e.html")!)

    }
    @objc func restorePurchase()
    {
        SwiftyStoreKit.restorePurchases(atomically: true) { [self] results in
            
                      //  Spinner.stop()
            
            if results.restoreFailedPurchases.count > 0 {
                      print("Restore Failed: \(results.restoreFailedPurchases)")
                         show(msg:"Restore Failed")
   
                      UserDefaults.standard.set(false,forKey: "BUY_VIP")
                       UserDefaults.standard.synchronize()
             
                show(msg:"Restore Failed: \(results.restoreFailedPurchases)")

                  }
                  else if results.restoredPurchases.count > 0 {
                      print("Restore Success: \(results.restoredPurchases)")
                
                  
                      for purchase in results.restoredPurchases
                      {
                          let productId = purchase.productId
                       
                         // print(productId)
                          var buy = false
                          if(type == 0)
                          {
                              if(productId == "com.junsoft.retro.sticker")
                              {
                                  UserDefaults.standard.set(true,forKey: "BUY_VIP0")
                                  UserDefaults.standard.synchronize()
                                  buy = true
                                  show(msg:"Restore Success")
                                  close()
                            
                              }
                          }
                          else if(type == 1)
                          {
                              if(productId == "com.junsoft.retro.filter")
                              {
                                  UserDefaults.standard.set(true,forKey: "BUY_VIP1")
                                  UserDefaults.standard.synchronize()
                                  buy = true
                                  show(msg:"Restore Success")
                                  close()
                            
                              }
                          }
                          else if(type == 2)
                          {
                              if(productId == "com.junsoft.retro.swap")
                              {
                                  UserDefaults.standard.set(true,forKey: "BUY_VIP2")
                                  UserDefaults.standard.synchronize()
                                  buy = true
                                  show(msg:"Restore Success")
                                  close()
                            
                              }
                          }
                          
                          if(buy == false)
                          {
                              show(msg:"Nothing to Restore")
                            //  close()
                        
                          }
                        
                      }
                   
               //     self.showAlertView(msg: "Restore Success",title: "Info")
               //
                    
                   //   self.complete(buy:1)
                  
     
                   
  
                  }
                  else {
                      print("Nothing to Restore")
                    
                      show(msg:"Nothing to Restore")
               
                  }
       
              
        }
   
    }
    func downloadMask(url : String, filename : String, stickerName:String, cell:ItemCell)
    {
        let manager = FileManager.default


        let path = String(format: "sticker/%@", filename)

        let pathUrl = dataFileURL(fileName: filename)

        let destination: DownloadRequest.Destination = { _, _ in

            var documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            documentsURL.appendPathComponent(path)
            return (documentsURL, [.removePreviousFile])
                           
        }
        if(manager.fileExists(atPath: pathUrl.path!))
        {
             do{
                 try manager.removeItem(at:  pathUrl as URL)
                 
             } catch {
                 print("Error: \(error.localizedDescription)")
             }
        }
        AF.download(url,to:destination).responseData { [self] (_data) in
                        
          
            if(_data.error != nil)
            {
                 
                                 
                return
            }
                  
            var data:NSData = manager.contents(atPath: pathUrl.path!) as! NSData
          
            if(data.length != 0)
            {
                    do{
                      
                        let targetPath = self.documentsDirectoryURL().appendingPathComponent("sticker")! as NSURL
                        
                        var ret =  SSZipArchive.unzipFile(atPath: pathUrl.path!, toDestination: targetPath.path!)
                        
                       // self.maskTypeName = stickerName
                        cell.indicator?.isHidden = true
                        cell.indicator?.stopAnimating()
                     
                        if(ret)
                        {
                            //stickerTypeName
                            self.setStickerFilter(name: stickerName,sceneName: "FaceMask")
                            
                        }
                        
                        if( self.bFront == false)
                        {
                            //   videoCamera = backCamera
                            self.jFaceLookup?.finalFilter?.setInputRotation(kGPUImageFlipHorizonal, at: 0)
                            
                        }
                        else
                        {
                            self.jFaceLookup?.finalFilter?.setInputRotation(GPUImageRotationMode(rawValue: 0), at: Int(kGPUImageFlipHorizonal.rawValue))
                            
                            //  videoCamera = frontCamera
                        }
                        
                        
                    }catch{
                        
                      
                        
                    }
                }
                
    
        }
           /*
           let request = URLRequest( url: URL(string: url)!)
           let session = AFHTTPSessionManager()
           
           let pathUrl = dataFileURL(fileName: filename)
           
           
           let downloadTask = session.downloadTask(with: request, progress: nil, destination: {(file, responce) in (pathUrl as URL)},
                                                   completionHandler:
               {
                   response, localfile, error in
                   
                   if( error == nil)
                   {
                       let targetPath = self.documentsDirectoryURL().appendingPathComponent("sticker")! as NSURL
                       
                       var ret =  SSZipArchive.unzipFile(atPath: pathUrl.path!, toDestination: targetPath.path!)
                       
                       self.maskTypeName = stickerName
                       
                       if(ret)
                       {
                           //stickerTypeName
                           self.setStickerFilter(name: stickerName,sceneName: "FaceMask")
                           
                       }
                       cell.indicator?.isHidden = true
                       cell.indicator?.stopAnimating()
                       
                       if( self.bFront == false)
                       {
                           //   videoCamera = backCamera
                           self.jFaceLookup?.finalFilter?.setInputRotation(kGPUImageFlipHorizonal, at: 0)
                           
                       }
                       else
                       {
                           self.jFaceLookup?.finalFilter?.setInputRotation(GPUImageRotationMode(rawValue: 0), at: Int(kGPUImageFlipHorizonal.rawValue))
                           
                           //  videoCamera = frontCamera
                       }
                   }
                   else
                   {
                       cell.indicator?.isHidden = true
                       cell.indicator?.stopAnimating()
                       self.errorMsg()
                       
                   }
                   
                   //print(ret)
                   
                   
           })
           
           downloadTask.resume()
            */
       }
 
    @objc func update0()
    {
        if(isCameraOn == true)
        {
            activityIndicator.stopAnimating()
          
            timer0?.invalidate()
            self.initCamera()
            initNoneFilter()
            isCameraOn = false
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
     
        
        
        
        DispatchQueue.main.async {[self] in
            // your code here
    
            self.openVideoCamera(ratio: true)
            filter = GPUImageFilter()
            renderView?.fillMode = kGPUImageFillModePreserveAspectRatioAndFill;
            videoCamera?.delegate = self
     
            filter?.addTarget(renderView)
            videoCamera?.addTarget(filter )
            videoCamera?.startCapture()
   
            renderView?.layer.cornerRadius = 10
            renderView?.layer.masksToBounds = true
            self.timer0 = Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(self.update0), userInfo: nil, repeats: true)
      
        
          
        }
        
        subscribeBt.transform = CGAffineTransform(scaleX: 0.1, y: 0.1)
                UIView.animate(withDuration: 0.7, // your duration
                               delay: 0,
                               usingSpringWithDamping: 0.2,
                               initialSpringVelocity: 6.0,
                               animations: { [self] in
                    subscribeBt.transform = .identity
                    },
                               completion: { _ in
                                // Implement your awesome logic here.
                })
       
    }
    func setTexture(name:String, filterName:String, thumb:String, type:String, category:String)
       {
           var data:FilterData
           data = FilterData(name: name, filterName:filterName,thumb: thumb,type: type,category: category)
           
           filters?.add(data)
       }
    func makeBasic() -> NSMutableArray
    {
        setTexture(name: "midnight.acv", filterName: "Midnight", thumb: "", type: "ToneCurve",category:"Basic")
        setTexture(name: "coffee.acv", filterName: "Coffee", thumb: "", type: "ToneCurve",category:"Basic")
        
        setTexture(name: "sweet_day.acv", filterName: "Sweet Day", thumb: "", type: "ToneCurve",category:"Basic")
        setTexture(name: "canela.acv", filterName: "Canela", thumb: "", type: "ToneCurve",category:"Basic")
        setTexture(name: "winter.acv", filterName: "Winter", thumb: "", type: "ToneCurve",category:"Basic")
        setTexture(name: "warm_pink.acv", filterName: "Warm Pink", thumb: "", type: "ToneCurve",category:"Basic")
        
        setTexture(name: "haze_green.acv", filterName: "Haze Green", thumb: "", type: "ToneCurve",category:"Basic")
        setTexture(name: "old_memories.acv", filterName: "Old Memories", thumb: "", type: "ToneCurve",category:"Basic")
        setTexture(name: "wine.acv", filterName: "Wine", thumb: "", type: "ToneCurve",category:"Basic")
        setTexture(name: "old_magenta.acv", filterName: "Old Magenta", thumb: "", type: "ToneCurve",category:"Basic")
        setTexture(name: "night.acv", filterName: "Night", thumb: "", type: "ToneCurve",category:"Basic")
        setTexture(name: "christmas.acv", filterName: "Christmas", thumb: "", type: "ToneCurve",category:"Basic")
        setTexture(name: "orange_dream.acv", filterName: "Orange Dream", thumb: "", type: "ToneCurve",category:"Basic")
        setTexture(name: "red_dream.acv", filterName: "Red Dream", thumb: "", type: "ToneCurve",category:"Basic")
        setTexture(name: "uva.acv", filterName: "UVA", thumb: "", type: "ToneCurve",category:"Basic")
        
        return filters!
        
    }
    
    func makeHaze()->NSMutableArray
    {
        
        
        setTexture(name: "lookup_haze_basic.png", filterName: "Haze Basic", thumb: "", type: "Lookup",category:"Haze")
        setTexture(name: "lookup_haze_blueberry.png", filterName: "Haze Blueberry", thumb: "", type: "Lookup",category:"Haze")
        setTexture(name: "lookup_haze_bw_heavy.png", filterName: "Haze B&W Heavy", thumb: "", type: "Lookup",category:"Haze")
        
        setTexture(name: "lookup_haze_bw_high_contrast.png", filterName: "Haze High Contrast", thumb: "", type: "Lookup",category:"Haze")
        setTexture(name: "lookup_haze_bw.png", filterName: "Haze B&W", thumb: "", type: "Lookup",category:"Haze")
        setTexture(name: "lookup_haze_cool.png", filterName: "Haze Cool", thumb: "", type: "Lookup",category:"Haze")
        setTexture(name: "lookup_haze_desaturation.png", filterName: "Haze Desaturation", thumb: "", type: "Lookup",category:"Haze")
        setTexture(name: "lookup_haze_gold.png", filterName: "Haze Gold", thumb: "", type: "Lookup",category:"Haze")
        setTexture(name: "lookup_haze_heavy.png", filterName: "Haze Heavy", thumb: "", type: "Lookup",category:"Haze")
        setTexture(name: "lookup_haze_high_contrast.png", filterName: "Haze High Contrast", thumb: "", type: "Lookup",category:"Haze")
        setTexture(name: "lookup_haze_purple.png", filterName: "Haze Purple", thumb: "", type: "Lookup",category:"Haze")
        setTexture(name: "lookup_haze_strawberry.png", filterName: "Haze Strawberry", thumb: "", type: "Lookup",category:"Haze")
        setTexture(name: "lookup_haze_vibrant.png", filterName: "Haze Vibrant", thumb: "", type: "Lookup",category:"Haze")
        setTexture(name: "lookup_haze_warm.png", filterName: "Haze Warm", thumb: "", type: "Lookup",category:"Haze")
        
        return filters!
        
    }
    func makeNewBasic() -> NSMutableArray
    {
       
               setTexture(name: "lookup_gb_0216.png", filterName: "2Me", thumb: "", type: "Lookup",category:"Haze")
             setTexture(name: "lookup_pistachio.png", filterName: "Pistachio", thumb: "", type: "Lookup",category:"Haze")
             setTexture(name: "lookup_lime.png", filterName: "Lime", thumb: "", type: "Lookup",category:"Haze")
             setTexture(name: "lookup_mint.png", filterName: "Mint", thumb: "", type: "Lookup",category:"Haze")
             setTexture(name: "lookup_avocado.png", filterName: "Avocado", thumb: "", type: "Lookup",category:"Haze")
             setTexture(name: "lookup_olive.png", filterName: "olive", thumb: "", type: "Lookup",category:"Haze")
             setTexture(name: "lookup_duorora_02.png", filterName: "Selena", thumb: "", type: "Lookup",category:"Haze")
             setTexture(name: "lookup_duorora_01.png", filterName: "Gaga", thumb: "", type: "Lookup",category:"Haze")
             setTexture(name: "lookup_duorora_05.png", filterName: "Katy", thumb: "", type: "Lookup",category:"Haze")
             setTexture(name: "lookup_lyn.png", filterName: "Fab", thumb: "", type: "Lookup",category:"Haze")
             setTexture(name: "lookup_roro2.png", filterName: "Cutie", thumb: "", type: "Lookup",category:"Haze")
             setTexture(name: "lookup_pink4.png", filterName: "Boo", thumb: "", type: "Lookup",category:"Haze")
             setTexture(name: "lookup_glory5.png", filterName: "Chill", thumb: "", type: "Lookup",category:"Haze")
             setTexture(name: "lookup_gi_0193.png", filterName: "Polaris", thumb: "", type: "Lookup",category:"Haze")
             setTexture(name: "lookup_gi_0188.png", filterName: "Propus", thumb: "", type: "Lookup",category:"Haze")
             setTexture(name: "lookup_50_fm1.png", filterName: "29Cu", thumb: "", type: "Lookup",category:"Haze")
             setTexture(name: "lookup_ff_kelvin.png", filterName: "Kelvin", thumb: "", type: "Lookup",category:"Haze")
             setTexture(name: "lookup_ff_walden.png", filterName: "Walden", thumb: "", type: "Lookup",category:"Haze")
             setTexture(name: "lookup_ff_hudson.png", filterName: "Hudson", thumb: "", type: "Lookup",category:"Haze")
             setTexture(name: "lookup_gi_0200.png", filterName: "Mizar", thumb: "", type: "Lookup",category:"Haze")
             setTexture(name: "lookup_FT0003.png", filterName: "Naak", thumb: "", type: "Lookup",category:"Haze")
           
           
        ////////////////
            // new
            
             setTexture(name: "lookup_FT0001.png", filterName: "Azra", thumb: "", type: "Lookup",category:"Haze")
             setTexture(name: "lookup_FT0002.png", filterName: "Suji", thumb: "", type: "Lookup",category:"Haze")
             setTexture(name: "lookup_FT0004.png", filterName: "Sora", thumb: "", type: "Lookup",category:"Haze")
             setTexture(name: "lookup_FT0007.png", filterName: "Ava", thumb: "", type: "Lookup",category:"Haze")
             setTexture(name: "lookup_a1_2944.png", filterName: "Shine", thumb: "", type: "Lookup",category:"Haze")
             setTexture(name: "lookup_a1_2939.png", filterName: "Ahoy", thumb: "", type: "Lookup",category:"Haze")
             setTexture(name: "lookup_a1_2923.png", filterName: "Sparkle", thumb: "", type: "Lookup",category:"Haze")
             setTexture(name: "lookup_m1_2867.png", filterName: "Pew Pew", thumb: "", type: "Lookup",category:"Haze")
             setTexture(name: "lookup_pw_2854.png", filterName: "Flutter", thumb: "", type: "Lookup",category:"Haze")
             setTexture(name: "lookup_a1_2968.png", filterName: "Tick-Tock", thumb: "", type: "Lookup",category:"Haze")
             setTexture(name: "lookup_a1_2942.png", filterName: "Yee-haw", thumb: "", type: "Lookup",category:"Haze")
             setTexture(name: "lookup_wi_i_dr.png", filterName: "i", thumb: "", type: "Lookup",category:"Haze")
             setTexture(name: "lookup_wi_classic.png", filterName: "Eastern", thumb: "", type: "Lookup",category:"Haze")
             setTexture(name: "lookup_w_st.png", filterName: "New Tan", thumb: "", type: "Lookup",category:"Haze")
             setTexture(name: "lookup_vintage_breeze.png", filterName: "Breeze", thumb: "", type: "Lookup",category:"Haze")
             setTexture(name: "lookup_ttt_polaroid.png", filterName: "Polaroid", thumb: "", type: "Lookup",category:"Haze")
             setTexture(name: "lookup_saturn-rings-9-2.png", filterName: "Saturn", thumb: "", type: "Lookup",category:"Haze")
             setTexture(name: "lookup_50_ed.png", filterName: "E.D.", thumb: "", type: "Lookup",category:"Haze")
             setTexture(name: "lookup_gg_0176.png", filterName: "Relevé", thumb: "", type: "Lookup",category:"Haze")
             setTexture(name: "lookup_gg_0185.png", filterName: "Tendu", thumb: "", type: "Lookup",category:"Haze")
             setTexture(name: "lookup_gg_0186.png", filterName: "Plié", thumb: "", type: "Lookup",category:"Haze")
             setTexture(name: "lookup_gg_0177.png", filterName: "Écarté", thumb: "", type: "Lookup",category:"Haze")
             setTexture(name: "lookup_gg_0180.png", filterName: "Côté", thumb: "", type: "Lookup",category:"Haze")
             setTexture(name: "lookup_gg_0183.png", filterName: "Porteé", thumb: "", type: "Lookup",category:"Haze")
             setTexture(name: "lookup_gg_0181.png", filterName: "Piqué", thumb: "", type: "Lookup",category:"Haze")
             setTexture(name: "lookup_gg_0184.png", filterName: "Chassé", thumb: "", type: "Lookup",category:"Haze")
             setTexture(name: "lookup_jj-20.png", filterName: "B & W", thumb: "", type: "Lookup",category:"Haze")
             setTexture(name: "lookup_gb_0209.png", filterName: "Talini", thumb: "", type: "Lookup",category:"Haze")
             setTexture(name: "lookup_gb_0207.png", filterName: "Sotla", thumb: "", type: "Lookup",category:"Haze")
             setTexture(name: "lookup_bw_infrared.png", filterName: "Infrared", thumb: "", type: "Lookup",category:"Haze")
             setTexture(name: "lookup_gb_0214.png", filterName: "Hootlin", thumb: "", type: "Lookup",category:"Haze")
             setTexture(name: "lookup_sv_rol_oo.png", filterName: "Ortho", thumb: "", type: "Lookup",category:"Haze")
             setTexture(name: "lookup_gb_0208.png", filterName: "Nyik", thumb: "", type: "Lookup",category:"Haze")
             setTexture(name: "lookup_gb_0210.png", filterName: "Chiup", thumb: "", type: "Lookup",category:"Haze")
             setTexture(name: "lookup_gb_0212.png", filterName: "Kripya", thumb: "", type: "Lookup",category:"Haze")
             setTexture(name: "lookup_ull_bw_faded.png", filterName: "Faded", thumb: "", type: "Lookup",category:"Haze")
             setTexture(name: "lookup_uf_caramel.png", filterName: "Caramel", thumb: "", type: "Lookup",category:"Haze")
             setTexture(name: "lookup_uf_frontpage.png", filterName: "Frontpage", thumb: "", type: "Lookup",category:"Haze")
             setTexture(name: "lookup_uf_qouzi.png", filterName: "Mint Cream", thumb: "", type: "Lookup",category:"Haze")
             setTexture(name: "lookup_a5.png", filterName: "A5", thumb: "", type: "Lookup",category:"Haze")
             setTexture(name: "lookup_50_at3.png", filterName: "AT3", thumb: "", type: "Lookup",category:"Haze")
             setTexture(name: "lookup_a5.png", filterName: "A5", thumb: "", type: "Lookup",category:"Haze")
             setTexture(name: "lookup_90p-RetroMorning.png", filterName: "Morning", thumb: "", type: "Lookup",category:"Haze")
             setTexture(name: "lookup_f_cool.png", filterName: "Cool", thumb: "", type: "Lookup",category:"Haze")
             setTexture(name: "lookup_50_s_cold.png", filterName: "Cold", thumb: "", type: "Lookup",category:"Haze")
             setTexture(name: "lookup_50_ev3.png", filterName: "Deep Green", thumb: "", type: "Lookup",category:"Haze")
             setTexture(name: "lookup_uf_lemonpeel.png", filterName: "Lemonpeel", thumb: "", type: "Lookup",category:"Haze")
             setTexture(name: "lookup_uf_scarlet.png", filterName: "Scarlet", thumb: "", type: "Lookup",category:"Haze")
             setTexture(name: "lookup_uf_bonsai.png", filterName: "Bonsai", thumb: "", type: "Lookup",category:"Haze")
             setTexture(name: "lookup_uf_iris.png", filterName: "Iris", thumb: "", type: "Lookup",category:"Haze")
             setTexture(name: "lookup_uf_hibiscus.png", filterName: "Hibiscus", thumb: "", type: "Lookup",category:"Haze")
             setTexture(name: "lookup_uf_fridge.png", filterName: "Fridge", thumb: "", type: "Lookup",category:"Haze")
             setTexture(name: "lookup_uf_verdial.png", filterName: "Verdial", thumb: "", type: "Lookup",category:"Haze")
             setTexture(name: "lookup_uf_cufflink.png", filterName: "Gainsboro", thumb: "", type: "Lookup",category:"Haze")
             setTexture(name: "lookup_uf_deutan.png", filterName: "Fab Four", thumb: "", type: "Lookup",category:"Haze")
             setTexture(name: "lookup_saturn-rings-9-1.png", filterName: "Purple", thumb: "", type: "Lookup",category:"Haze")
             setTexture(name: "lookup_50_ps1.png", filterName: "Grizzled", thumb: "", type: "Lookup",category:"Haze")
             setTexture(name: "lookup_wi_green.png", filterName: "Y-Green", thumb: "", type: "Lookup",category:"Haze")
             setTexture(name: "lookup_wi_red.png", filterName: "Golden", thumb: "", type: "Lookup",category:"Haze")
             setTexture(name: "lookup_uf_goldie.png", filterName: "Goldie", thumb: "", type: "Lookup",category:"Haze")
             setTexture(name: "lookup_50_fm2.png", filterName: "Illume", thumb: "", type: "Lookup",category:"Haze")
             setTexture(name: "lookup_50_os1.png", filterName: "Teal", thumb: "", type: "Lookup",category:"Haze")
             setTexture(name: "lookup_50_os3.png", filterName: "Teal2", thumb: "", type: "Lookup",category:"Haze")
             setTexture(name: "lookup_50_os2.png", filterName: "Slate", thumb: "", type: "Lookup",category:"Haze")
            
             setTexture(name: "lookup_gi_0198.png", filterName: "Rigel", thumb: "", type: "Lookup",category:"Haze")
             setTexture(name: "lookup_gi_0206.png", filterName: "Ain", thumb: "", type: "Lookup",category:"Haze")
             setTexture(name: "lookup_gi_0194.png", filterName: "Sarir", thumb: "", type: "Lookup",category:"Haze")
             setTexture(name: "lookup_gi_0205.png", filterName: "Heze", thumb: "", type: "Lookup",category:"Haze")
             setTexture(name: "lookup_gi_0190.png", filterName: "Navi", thumb: "", type: "Lookup",category:"Haze")
             setTexture(name: "lookup_gi_0192.png", filterName: "Zosma", thumb: "", type: "Lookup",category:"Haze")
             setTexture(name: "lookup_ff_am.png", filterName: "AM", thumb: "", type: "Lookup",category:"Haze")
             setTexture(name: "lookup_wd_momentous.png", filterName: "Momentous", thumb: "", type: "Lookup",category:"Haze")
             setTexture(name: "lookup_ff_lfhp5.png", filterName: "H5", thumb: "", type: "Lookup",category:"Haze")
             setTexture(name: "lookup_ff_toaster.png", filterName: "Toaster", thumb: "", type: "Lookup",category:"Haze")
             setTexture(name: "lookup_ff_inkwell.png", filterName: "Inkwell", thumb: "", type: "Lookup",category:"Haze")
             setTexture(name: "lookup_ff_tzp-expired1.png", filterName: "Expired", thumb: "", type: "Lookup",category:"Haze")
             setTexture(name: "lookup_ff_px_70.png", filterName: "70", thumb: "", type: "Lookup",category:"Haze")
             setTexture(name: "lookup_ff_px_680.png", filterName: "680", thumb: "", type: "Lookup",category:"Haze")
             setTexture(name: "lookup_ff_px_100uvcold.png", filterName: "100 Cold", thumb: "", type: "Lookup",category:"Haze")
             setTexture(name: "lookup_ff_px_680coldalt.png", filterName: "680 Cold 2", thumb: "", type: "Lookup",category:"Haze")
             setTexture(name: "lookup_ff_px_100uvwarm.png", filterName: "100 Warm", thumb: "", type: "Lookup",category:"Haze")
           
             setTexture(name: "lookup_ff_px_70cold.png", filterName: "70 Cold", thumb: "", type: "Lookup",category:"Haze")
             setTexture(name: "lookup_ff_px_70warm.png", filterName: "70 Warm", thumb: "", type: "Lookup",category:"Haze")
             setTexture(name: "lookup_ff_px_680warm.png", filterName: "680 Warm", thumb: "", type: "Lookup",category:"Haze")
             setTexture(name: "lookup_ff_px_680cold.png", filterName: "680 Cold", thumb: "", type: "Lookup",category:"Haze")
             setTexture(name: "lookup_pxg_valis.png", filterName: "29Cu", thumb: "", type: "Lookup",category:"Haze")
          
             setTexture(name: "lookup_gg_0176.png", filterName: "3Li", thumb: "", type: "Lookup",category:"Haze")
             setTexture(name: "lookup_ff_px_100uvcold.png", filterName: "47Ag", thumb: "", type: "Lookup",category:"Haze")
             setTexture(name: "lookup_ull_bw_faded.png", filterName: "55Cs", thumb: "", type: "Lookup",category:"Haze")
             setTexture(name: "lookup_ff_px_100uvwarm.png", filterName: "54Xe", thumb: "", type: "Lookup",category:"Haze")
             setTexture(name: "lookup_ull_bw_standard.png", filterName: "26Fe", thumb: "", type: "Lookup",category:"Haze")
            
             setTexture(name: "lookup_pxg_uranus.png", filterName: "Uranus", thumb: "", type: "Lookup",category:"Haze")
             setTexture(name: "lookup_pxg_1064nm.png", filterName: "Pluto", thumb: "", type: "Lookup",category:"Haze")
             setTexture(name: "lookup_pxg_valis.png", filterName: "Mars", thumb: "", type: "Lookup",category:"Haze")
             setTexture(name: "lookup_pxg_electrolumine.png", filterName: "Neptune", thumb: "", type: "Lookup",category:"Haze")
             setTexture(name: "lookup_pxg_majoris.png", filterName: "Jupiter", thumb: "", type: "Lookup",category:"Haze")
             setTexture(name: "lookup_pxg_chloroplast.png", filterName: "Venus", thumb: "", type: "Lookup",category:"Haze")
             setTexture(name: "lookup_cn_2strip.png", filterName: "Two Strip", thumb: "", type: "Lookup",category:"Haze")
             setTexture(name: "lookup_cn_spartan.png", filterName: "Spartan", thumb: "", type: "Lookup",category:"Haze")
             setTexture(name: "lookup_cn_ktmax.png", filterName: "K-Max", thumb: "", type: "Lookup",category:"Haze")
             setTexture(name: "lookup_cn_process2.png", filterName: "Process 2", thumb: "", type: "Lookup",category:"Haze")
             setTexture(name: "lookup_cn_horror.png", filterName: "Horror", thumb: "", type: "Lookup",category:"Haze")
             setTexture(name: "lookup_cn_hacker.png", filterName: "Hacker", thumb: "", type: "Lookup",category:"Haze")
             setTexture(name: "lookup_cn_vintageromance.png", filterName: "Vintage", thumb: "", type: "Lookup",category:"Haze")
             setTexture(name: "lookup_cn_t_hc.png", filterName: "T-HC", thumb: "", type: "Lookup",category:"Haze")
             setTexture(name: "lookup_cn_t_lc.png", filterName: "T-LC", thumb: "", type: "Lookup",category:"Haze")
              
             
           return filters!
           
       
    }
    func makeFilterList()
       {
           filters?.removeAllObjects()
           var items:NSMutableArray?
           items = makeNewBasic()
          //
           let layout = UICollectionViewFlowLayout()
               
           let width = UIScreen.main.bounds.size.width
           layout.itemSize = CGSize(width: 60,height: 60)
        
           layout.scrollDirection = .horizontal
           layout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
           layout.minimumLineSpacing = 10
      
           //
      
           filterSource = FiterItemSource()
           filterSource.parentCon = self
           filterSource.initData(data: filters!)
           self.collectionView?.delegate = filterSource
           self.collectionView?.dataSource = filterSource
           collectionView.setCollectionViewLayout(layout, animated: false)
 
           self.collectionView?.reloadData()
           
           
       }
    func processMask(item:String, cell:ItemCell)
    {
   
        
        DispatchQueue.main.async{
                 
                 
                 let zipURL:String = String(format: "http://www.junsoft.org/mask/%@.zip", item as CVarArg)
                 let zipName:String = String(format: "%@.zip", item as CVarArg)
                 
                 let pathUrl = self.dataFileURL(fileName: zipName)
                 
                 let manager = FileManager.default
              //   self.stickerTypeName = "none"
                 
                 //logEvent
              
                 if(!manager.fileExists(atPath: pathUrl.path!))
                 {
                     self.bBeauty = false
                     
                     self.downloadMask(url: zipURL,filename: zipName, stickerName: item, cell:cell)
                 }
                 else
                 {
                
                     self.setStickerFilter(name: item, sceneName: "FaceMask")
                   
                     self.jFaceLookup?.finalFilter?.setInputRotation(GPUImageRotationMode(rawValue: 0), at: Int(kGPUImageFlipHorizonal.rawValue))
               
                     
                     
                 }
        }
        
    }
    func processFilter(item:String,type:String, cell:ItemCell)
    {
        let url:String = String(format: "http://www.junsoft.org/filter/%@", item as CVarArg)
              
      //  sceneType = ""
        bBeauty = true
      
             
        downloadFilter(url: url,filename: item, type: type, stickerName: "", cell:cell)

        
    }
    func downloadFilter(url : String, filename : String,type:String, stickerName:String, cell:ItemCell)
      {
          
          
          let manager = FileManager.default

          let request = URLRequest( url: URL(string: url)!)
              
          let path = String(format: "sticker/%@", filename)

          let pathUrl = dataFileURL(fileName: filename)
    ///
          let destination: DownloadRequest.Destination = { _, _ in

              var documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
              documentsURL.appendPathComponent(path)
              return (documentsURL, [.removePreviousFile])
                             
          }
          if(manager.fileExists(atPath: pathUrl.path!))
          {
               do{
                   try manager.removeItem(at:  pathUrl as URL)
                   
               } catch {
                   print("Error: \(error.localizedDescription)")
               }
          }
          AF.download(url,to:destination).responseData { [self] (_data) in
                          
            
              if(_data.error != nil)
              {
               
                                   
                  return
              }
                    
              var data:NSData = manager.contents(atPath: pathUrl.path!) as! NSData
            
              if(data.length != 0)
              {
                  let targetPath = self.documentsDirectoryURL().appendingPathComponent("sticker")! as NSURL
                  
                  // exist
                  cell.indicator?.isHidden = true
                  cell.indicator?.stopAnimating()
               
                  if(type=="Lookup")
                  {
                      self.setLookupFilter(name: filename,sceneName: "Filter")
                      //
                    
                      
                  }
                  if(type=="ToneCurve")
                  {
                      //setToneFilter
                      let data = manager.contents(atPath: pathUrl.path!)
                      
                      self.setToneFilter(toneData: data!)
                      
                   
                      
                      ///
                  }
                  if( bFront == false)
                  {
                      //   videoCamera = backCamera
                      self.jFaceLookup?.finalFilter?.setInputRotation(kGPUImageFlipHorizonal, at: 0)
                      
                  }
                  else
                  {
                      self.jFaceLookup?.finalFilter?.setInputRotation(GPUImageRotationMode(rawValue: 0), at: Int(kGPUImageFlipHorizonal.rawValue))
                      
                      //  videoCamera = frontCamera
                  }
              }
              else
              {
                  
              }
               
      
          }
          
      }
    func setToneFilter(toneData:Data)
     {
         
         if (jFaceLookup != nil || filter != nil) {
             
             videoCamera?.removeAllTargets()
             filter?.removeAllTargets()
             
             jFaceLookup?.removeAllTargets()
             jFaceLookup?.removeAll()
             beautyFilter?.removeAllTargets()
             cropFilter?.removeAllTargets()
             //   contrastFilter?.removeAllTargets()
             
             
             //
             
             
         }
         bBigEyes = true
         bVline = true
         scene?.initWithScene2("LiveSticker", filterName: "none", mirroed: true, resType: 0, vline:bVline, openEye: bOpenEyes, bigEye: bBigEyes)
         filter = scene
         self.toneData = toneData
         
          jFaceLookup?.useNextFrameForImageCapture()
         jFaceLookup?.processFilter("none", scene: scene ,data:toneData as Data?,beauty: bBeauty!, square: Int32(ratioMode!))
         
         
         
         
         
         renderView?.fillMode = kGPUImageFillModePreserveAspectRatioAndFill;
         
         exportUrl = documentsDirectoryURL().appendingPathComponent("test4.m4v")! as NSURL
         
         let fileManaer =  FileManager.default
         if(fileManaer.fileExists(atPath: (exportUrl?.path!)!))
         {
             do{
                 try    fileManaer.removeItem(at: exportUrl as! URL)
                 
                 
             } catch {
                 print("Error: \(error.localizedDescription)")
             }
         }
         /*
         if(ratioMode == 0 )
         {
             movieWriter = GPUImageMovieWriter.init(movieURL: exportUrl as URL?, size: CGSize(width: 720     , height: 1280))
             
         }
         if(ratioMode == 1 )
         {
             movieWriter = GPUImageMovieWriter.init(movieURL: exportUrl as URL?, size: CGSize(width: 480     , height: 640))
             
         }
         if(ratioMode == 2 )
         {
             movieWriter = GPUImageMovieWriter.init(movieURL: exportUrl as URL?, size: CGSize(width: 480     , height: 480))
             
         }
         videoCamera?.audioEncodingTarget = movieWriter
         
         
         
         jFaceLookup?.addTarget(movieWriter)
         */
         jFaceLookup?.addTarget(renderView)
         videoCamera?.addTarget(jFaceLookup)
         
     }
    func downloadSticker(url : String, filename : String, stickerName:String, cell:ItemCell)
     {
         
         let manager = FileManager.default


         let path = String(format: "sticker/%@", filename)

         let pathUrl = dataFileURL(fileName: filename)

         ///
         ///
       
         ///
         let destination: DownloadRequest.Destination = { _, _ in

             var documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
             documentsURL.appendPathComponent(path)
             return (documentsURL, [.removePreviousFile])
                            
         }
         if(manager.fileExists(atPath: pathUrl.path!))
         {
              do{
                  try manager.removeItem(at:  pathUrl as URL)
                  
              } catch {
                  print("Error: \(error.localizedDescription)")
              }
         }
         AF.download(url,to:destination).responseData { [self] (_data) in
                         
           
             if(_data.error != nil)
             {
                  
                                  
                 return
             }
                   
             var data:NSData = manager.contents(atPath: pathUrl.path!) as! NSData
           
             if(data.length != 0)
             {
                 let targetPath = self.documentsDirectoryURL().appendingPathComponent("sticker")! as NSURL
                 
                 var ret =  SSZipArchive.unzipFile(atPath: pathUrl.path!, toDestination: targetPath.path!)
                 
                 self.setStickerFilter(name: stickerName,sceneName: "LiveSticker")
                 cell.indicator?.isHidden = true
                 cell.indicator?.stopAnimating()
              
              
             }
              
     
         }
     
       
     }
    func setLookupFilter(name:String, sceneName:String)
    {
       
          self.scene?.earringName = "none"
      
          self.scene?.hatName = "none"
         
          self.scene?.glassesName = "none"
         
          self.scene?.mustacheName = "none"
        bBigEyes = true
        bVline = true
        ratioMode = 1
        print("bOpenEyes: \(bOpenEyes)")
        
        if ((beautyFilter != nil ||  filter != nil) || jFaceLookup != nil) {
            videoCamera?.removeAllTargets()
            filter?.removeAllTargets()
            jFaceLookup?.removeAllTargets()
            jFaceLookup?.removeAll()
            beautyFilter?.removeAllTargets()
            cropFilter?.removeAllTargets()
            //  contrastFilter?.removeAllTargets()
            scene?.release()
            
        }
        
        // [self useNextFrameForImageCapture];
     
     
        jFaceLookup = LookupFilterGroup()
        scene?.initWithScene2("LiveSticker", filterName: "none", mirroed: true, resType: 0, vline:bVline, openEye: bOpenEyes, bigEye: bBigEyes)
   
        self.toneData = nil
        jFaceLookup?.useNextFrameForImageCapture()
        jFaceLookup?.processFilter(name, scene: scene, data:nil,beauty: bBeauty!, square: Int32(ratioMode!))
        
        // renderView?.fillMode = kGPUImageFillModePreserveAspectRatio;
        renderView?.fillMode = kGPUImageFillModePreserveAspectRatioAndFill;
        
        exportUrl = documentsDirectoryURL().appendingPathComponent("test4.m4v")! as NSURL
        let fileManaer =  FileManager.default
        
        if(fileManaer.fileExists(atPath: (exportUrl?.path!)!))
        {
            do{
                try    fileManaer.removeItem(at: exportUrl as! URL)
                
                
            } catch {
                print("Error: \(error.localizedDescription)")
            }
        }
        /*
        if(ratioMode == 0 )
        {
            movieWriter = GPUImageMovieWriter.init(movieURL: exportUrl as URL?, size: CGSize(width: 720     , height: 1280))
            
        }
        if(ratioMode == 1 )
        {
            movieWriter = GPUImageMovieWriter.init(movieURL: exportUrl as URL?, size: CGSize(width: 480     , height: 640))
            
        }
        if(ratioMode == 2 )
        {
            movieWriter = GPUImageMovieWriter.init(movieURL: exportUrl as URL?, size: CGSize(width: 480     , height: 480))
            
        }
        
        videoCamera?.audioEncodingTarget = movieWriter
        
        jFaceLookup?.addTarget(movieWriter)
         */
        
        jFaceLookup?.addTarget(renderView)
        videoCamera?.addTarget(jFaceLookup )
            
            filter = scene
            
        
        videoCamera?.resumeCameraCapture()
        videoCamera?.delegate = self
        videoCamera?.startCapture()
      
        
    }
    func setStickerFilter(name:String, sceneName:String)
    {
       
          self.scene?.earringName = "none"
      
          self.scene?.hatName = "none"
         
          self.scene?.glassesName = "none"
         
          self.scene?.mustacheName = "none"
        bBigEyes = true
        bVline = true
        ratioMode = 1
        print("bOpenEyes: \(bOpenEyes)")
        
        if ((beautyFilter != nil ||  filter != nil) || jFaceLookup != nil) {
            videoCamera?.removeAllTargets()
            filter?.removeAllTargets()
            jFaceLookup?.removeAllTargets()
            jFaceLookup?.removeAll()
            beautyFilter?.removeAllTargets()
            cropFilter?.removeAllTargets()
            //  contrastFilter?.removeAllTargets()
            
        }
        
        bOpenEyes = true
        
        scene?.initWithScene2(sceneName, filterName: name, mirroed: true, resType: 0, vline:bVline, openEye: bOpenEyes, bigEye: bBigEyes)

     
            
            
            filter = scene
            
            // beautyFilter = GPUImageBeautifyFilter()
            // beautyFilter?.process()
            
            // renderView?.fillMode = kGPUImageFillModePreserveAspectRatio;
            renderView?.fillMode = kGPUImageFillModePreserveAspectRatioAndFill;
            
            exportUrl = documentsDirectoryURL().appendingPathComponent("test4.m4v")! as NSURL
            
            let fileManaer =  FileManager.default
            if(fileManaer.fileExists(atPath: (exportUrl?.path!)!))
            {
                do{
                    try    fileManaer.removeItem(at: exportUrl as! URL)
                    
                    
                } catch {
                    print("Error: \(error.localizedDescription)")
                }
            }
        /*
            if(ratioMode == 0 )
            {
                movieWriter = GPUImageMovieWriter.init(movieURL: exportUrl as URL?, size: CGSize(width: 720     , height: 1280))
                
            }
            if(ratioMode == 1 )
            {
                movieWriter = GPUImageMovieWriter.init(movieURL: exportUrl as URL?, size: CGSize(width: 480     , height: 640))
                
            }
            if(ratioMode == 2 )
            {
                movieWriter = GPUImageMovieWriter.init(movieURL: exportUrl as URL?, size: CGSize(width: 480     , height: 480))
                
            }
            videoCamera?.audioEncodingTarget = movieWriter
            */
             jFaceLookup?.useNextFrameForImageCapture()
            
        jFaceLookup?.processFilter("none", scene: scene, data:nil,beauty: true, square: 0)

            
       //     jFaceLookup?.addTarget(movieWriter)
            
            jFaceLookup?.addTarget(renderView)
            videoCamera?.addTarget(jFaceLookup )
            
       
        videoCamera?.resumeCameraCapture()
        videoCamera?.delegate = self
        videoCamera?.startCapture()
      
        
    }
    func processImage(name:String, cell:ItemCell)
    {
        let name0 = name.replacingOccurrences(of: "_thumb", with: "")

        let zipURL:String = String(format: "http://www.junsoft.org/zip/%@.zip", name0 as CVarArg)
        let zipName:String = String(format: "%@.zip", name0 as CVarArg)
     
        ///
        
        downloadSticker(url: zipURL,filename: zipName, stickerName: name0, cell:cell)

        //
   
     //   sdkManager.processStillImage(UIImage(named: "test"), filter: filter)
    }
 
    @IBAction func close()
    {
        if(self.timer0 != nil)
        {
            self.timer0?.invalidate()
        }
        dismiss(animated: true, completion: nil)
    }
    
    func initDemoData()
    {
        
       
       
    }
    func documentsDirectoryURL() -> NSURL {
            let manager = FileManager.default
            let URLs = manager.urls(for: .documentDirectory, in: .userDomainMask)
            return URLs[0] as NSURL
        }
    func dataFileURL(fileName:String) -> NSURL {
        
        let path = String(format: "sticker/%@", fileName)
        let targetPath = documentsDirectoryURL().appendingPathComponent("sticker")! as NSURL
        
        let manager = FileManager.default
        
        if(manager.fileExists(atPath: targetPath.path!))
        {
            print("exist")
        }
        else
        {
            do{
                try   manager.createDirectory(at: targetPath as URL, withIntermediateDirectories: false, attributes: nil)
                
            } catch {
                print("Error: \(error.localizedDescription)")
            }
        }
        
        
        
        return documentsDirectoryURL().appendingPathComponent(path)! as NSURL
        
    }
    func dataFilterURL(fileName:String) -> NSURL {
        
        let path = String(format: "filter/%@", fileName)
        let targetPath = documentsDirectoryURL().appendingPathComponent("filter")! as NSURL
        
        let manager = FileManager.default
        
        if(manager.fileExists(atPath: targetPath.path!))
        {
            print("exist")
        }
        else
        {
            do{
                try   manager.createDirectory(at: targetPath as URL, withIntermediateDirectories: false, attributes: nil)
                
            } catch {
                print("Error: \(error.localizedDescription)")
            }
        }
        
        
        
        return documentsDirectoryURL().appendingPathComponent(path)! as NSURL
        
    }
    func downloadJSON(url : String, filename : String)
       {
           
           let manager = FileManager.default


           let path = String(format: "sticker/%@", filename)

           let pathUrl = dataFileURL(fileName: filename)

           let destination: DownloadRequest.Destination = { _, _ in

               var documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
               documentsURL.appendPathComponent(path)
               return (documentsURL, [.removePreviousFile])
                              
           }
           if(manager.fileExists(atPath: pathUrl.path!))
           {
                do{
                    try manager.removeItem(at:  pathUrl as URL)
                    
                } catch {
                    print("Error: \(error.localizedDescription)")
                }
           }
           AF.download(url,to:destination).responseData { [self] (_data) in
                           
             
               if(_data.error != nil)
               {
                    
                                    
                   return
               }
                     
               var data:NSData = manager.contents(atPath: pathUrl.path!) as! NSData
             
               if(data.length != 0)
               {
                       do{
                            
                           self.itemAccesorys = try JSONSerialization.jsonObject(with: data as Data, options:[]) as? [String: AnyObject] as! NSDictionary
                           
                           
                           var data:NSData = manager.contents(atPath: pathUrl.path!) as! NSData
                         
                           let targetPath = self.documentsDirectoryURL().appendingPathComponent("sticker")! as NSURL
                           
                           var ret =  SSZipArchive.unzipFile(atPath: pathUrl.path!, toDestination: targetPath.path!)
                   
                           let layout = UICollectionViewFlowLayout()
                           layout.scrollDirection = .horizontal
                           layout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
                           layout.minimumLineSpacing = 10
                     
                           //56 + 18 + 8
                           let width = UIScreen.main.bounds.size.width
                           layout.itemSize = CGSize(width: 60,height: 60)
                        
                           itemSource.parentCon = self
                           itemSource.itemDict = self.itemAccesorys 
                           itemSource.initData(data: datas)
                           collectionView.dataSource = itemSource
                           collectionView.delegate = itemSource
                           collectionView.setCollectionViewLayout(layout, animated: false)
                          
                           collectionView.reloadData()
                           
                           
                           
                       }catch{
                           
                         
                           
                       }
                   }
                   
       
           }
       
           
           
       }
    func openVideoCamera(ratio:Bool)
   {
       
     
       /*
       self.frontCamera = GPUImageStillCamera(sessionPreset: AVCaptureSession.Preset.hd1280x720.rawValue, cameraPosition: .front)
       self.frontCamera!.outputImageOrientation = .portrait;
       //frontCamera!.horizontallyMirrorFrontFacingCamera = true
       //  frontCamera?.delegate = self
       
       self.backCamera = GPUImageStillCamera(sessionPreset: AVCaptureSession.Preset.hd1280x720.rawValue, cameraPosition: .back)
       self.backCamera!.outputImageOrientation = .portrait;
       
       
       let rect:CGRect =  self.view.bounds
     
       self.videoCamera = self.frontCamera
  
       self.framerate = (self.videoCamera!.inputCamera.activeFormat.videoSupportedFrameRateRanges[0] as AnyObject).maxFrameRate as Float64
       
       self.fov = self.videoCamera?.inputCamera.activeFormat.videoFieldOfView
       
       if(self.scene != nil)
       {
           //       scene?.release()
           let size:CGSize = CGSize(width: 1280, height: 720)
    
           self.scene?.resetBufferSize(size)
           
       }
       else
       {
           self.scene = Scene()
           let image0 = UIImage(named: "test")!
          
           self.ret = self.scene?.initSDKFrameRate(Float(self.framerate!), fov:self.fov!,size:CGSize(width: 1280, height: 720))
         
       }
       */
       if(self.cropFilter != nil)
       {
           self.cropFilter?.removeAllTargets()
       }
       let cropRect:CGRect = CGRect(x: 0, y: 0, width: 1, height: 1.0)
       self.cropFilter = CropFilter(cropRegion: cropRect)
   }
   
    func initCamera()
      {
         
          let user:UserDefaults = UserDefaults.standard
               bOpenEyes =  user.bool(forKey: "OPEN_EYES")
               bVline =  user.bool(forKey: "VLINE")
               bBigEyes =  user.bool(forKey: "BIG_EYES")
               //OPEN_EYES
               
          bBigEyes = true
          bVline = true
               
               videoCamera?.resumeCameraCapture()
          initNoneFilter()
    
          self.jFaceLookup?.finalFilter?.setInputRotation(GPUImageRotationMode(rawValue: 0), at: Int(kGPUImageFlipHorizonal.rawValue))
      
          
      }
    func initNoneFilter()
    {
        ratioMode = 0
        if (beautyFilter != nil || jFaceLookup != nil) {
            videoCamera?.removeAllTargets()
            filter?.removeAllTargets()
            jFaceLookup?.removeAllTargets()
            jFaceLookup?.removeAll()
            beautyFilter?.removeAllTargets()
            //  contrastFilter?.removeAllTargets()
            
            cropFilter?.removeAllTargets()
            //[camera removeAllTargets];
          //  scene?.release()
            
        }
        
        
        scene?.initWithScene2("LiveSticker", filterName: "none", mirroed: true, resType: 0, vline:bVline, openEye: bOpenEyes, bigEye: bBigEyes)
        //  filter = scene
        
        /////
        jFaceLookup?.processFilter("none", scene: scene ,data:toneData as Data?,beauty: true, square: Int32(ratioMode!))
        
        
        //
        //renderView?.fillMode = kGPUImageFillModePreserveAspectRatioAndFill;
        renderView?.fillMode = kGPUImageFillModePreserveAspectRatioAndFill;
        
        renderView?.fillMode = kGPUImageFillModePreserveAspectRatioAndFill;
             
             
      
        
              jFaceLookup?.addTarget(renderView)
              videoCamera?.addTarget(jFaceLookup)
              ////
              if( self.bFront == false)
              {
                  //   videoCamera = backCamera
                  self.jFaceLookup?.finalFilter?.setInputRotation(kGPUImageFlipHorizonal, at: 0)
                  
              }
              else
              {
                  self.jFaceLookup?.finalFilter?.setInputRotation(GPUImageRotationMode(rawValue: 0), at: Int(kGPUImageFlipHorizonal.rawValue))
                  
                  //  videoCamera = frontCamera
              }
              
    }
}

extension UIImage {
    var cvPixelBuffer: CVPixelBuffer? {
        var pixelBuffer: CVPixelBuffer? = nil
        let options: [NSObject: Any] = [
            kCVPixelBufferCGImageCompatibilityKey: false,
            kCVPixelBufferCGBitmapContextCompatibilityKey: false,
            ]
        
        _ = CVPixelBufferCreate( kCFAllocatorDefault,
                                          Int(size.width),
                                          Int(size.height),
                                          kCVPixelFormatType_32BGRA,
                                          options as CFDictionary, &pixelBuffer)
        
        CVPixelBufferLockBaseAddress(pixelBuffer!, CVPixelBufferLockFlags(rawValue: 0))
        let pixelData = CVPixelBufferGetBaseAddress(pixelBuffer!)
        let rgbColorSpace = CGColorSpaceCreateDeviceRGB()
        let context = CGContext(data: pixelData,
                                width: Int(size.width),
                                height: Int(size.height),
                                bitsPerComponent: 8,
                                bytesPerRow: CVPixelBufferGetBytesPerRow(pixelBuffer!),
                                space: rgbColorSpace,
                                bitmapInfo: CGBitmapInfo.byteOrder32Little.rawValue)
        
        context?.draw(cgImage!, in: CGRect(origin: .zero, size: size))
        CVPixelBufferUnlockBaseAddress(pixelBuffer!, CVPixelBufferLockFlags(rawValue: 0))
        return pixelBuffer
    }
        
    var cmSampleBuffer: CMSampleBuffer {
        let pixelBuffer = cvPixelBuffer
        var newSampleBuffer: CMSampleBuffer? = nil
        var timimgInfo: CMSampleTimingInfo = CMSampleTimingInfo.invalid
        var videoInfo: CMVideoFormatDescription? = nil
        CMVideoFormatDescriptionCreateForImageBuffer(allocator: nil,
                                          imageBuffer: pixelBuffer!,
                                          formatDescriptionOut: &videoInfo)
                                          
        CMSampleBufferCreateForImageBuffer(allocator: kCFAllocatorDefault,
                                           imageBuffer: pixelBuffer!,
                                           dataReady: true,
                                           makeDataReadyCallback: nil,
                                           refcon: nil,
                                           formatDescription: videoInfo!,
                                           sampleTiming: &timimgInfo,
                                           sampleBufferOut: &newSampleBuffer)
        return newSampleBuffer!
    }
    func toCVPixelBuffer() -> CVPixelBuffer? {
           let attrs = [kCVPixelBufferCGImageCompatibilityKey: kCFBooleanTrue, kCVPixelBufferCGBitmapContextCompatibilityKey: kCFBooleanTrue] as CFDictionary
           var pixelBuffer : CVPixelBuffer?
           let status = CVPixelBufferCreate(kCFAllocatorDefault, Int(self.size.width), Int(self.size.height), kCVPixelFormatType_32ARGB, attrs, &pixelBuffer)
           guard status == kCVReturnSuccess else {
               return nil
           }

           if let pixelBuffer = pixelBuffer {
               CVPixelBufferLockBaseAddress(pixelBuffer, CVPixelBufferLockFlags(rawValue: 0))
               let pixelData = CVPixelBufferGetBaseAddress(pixelBuffer)

               let rgbColorSpace = CGColorSpaceCreateDeviceRGB()
               let context = CGContext(data: pixelData, width: Int(self.size.width), height: Int(self.size.height), bitsPerComponent: 8, bytesPerRow: CVPixelBufferGetBytesPerRow(pixelBuffer), space: rgbColorSpace, bitmapInfo: CGImageAlphaInfo.noneSkipFirst.rawValue)

               context?.translateBy(x: 0, y: self.size.height)
               context?.scaleBy(x: 1.0, y: -1.0)

               UIGraphicsPushContext(context!)
               self.draw(in: CGRect(x: 0, y: 0, width: self.size.width, height: self.size.height))
               UIGraphicsPopContext()
               CVPixelBufferUnlockBaseAddress(pixelBuffer, CVPixelBufferLockFlags(rawValue: 0))

               return pixelBuffer
           }

           return nil
       }
    func rotate(radians: Float) -> UIImage? {
            var newSize = CGRect(origin: CGPoint.zero, size: self.size).applying(CGAffineTransform(rotationAngle: CGFloat(radians))).size
            // Trim off the extremely small float value to prevent core graphics from rounding it up
            newSize.width = floor(newSize.width)
            newSize.height = floor(newSize.height)

            UIGraphicsBeginImageContextWithOptions(newSize, false, self.scale)
            let context = UIGraphicsGetCurrentContext()!

            // Move origin to middle
            context.translateBy(x: newSize.width/2, y: newSize.height/2)
            // Rotate around middle
            context.rotate(by: CGFloat(radians))
            // Draw the image at its center
            self.draw(in: CGRect(x: -self.size.width/2, y: -self.size.height/2, width: self.size.width, height: self.size.height))

            let newImage = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()

            return newImage
        }
    enum Axis {
        case horizontal, vertical
      }
      
      func flipped(_ axis: Axis) -> UIImage {
        let renderer = UIGraphicsImageRenderer(size: size)
        
        return renderer.image {
          let context = $0.cgContext
          context.translateBy(x: size.width / 2, y: size.height / 2)
          
          switch axis {
          case .horizontal:
            context.scaleBy(x: -1, y: 1)
          case .vertical:
            context.scaleBy(x: 1, y: -1)
          }
          
          context.translateBy(x: -size.width / 2, y: -size.height / 2)
          
          draw(at: .zero)
        }
      }
}



extension StoreViewController : GPUImageVideoCameraDelegate{
    
    func willOutputSampleBuffer(_ sampleBuffer: CMSampleBuffer!) {
        
       
        
        var deviceOrientation:UIDeviceOrientation
        deviceOrientation =  UIDevice.current.orientation;
        
        scene?.processBuffer(sampleBuffer, orientation: Int32(deviceOrientation.rawValue), front: true)
    
        isCameraOn = true
        
        
        
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
}
