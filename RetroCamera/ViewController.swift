//
//  ViewController.swift
//  RetroCamera
//
//  Created by Junsung Park on 2022/04/18.
//

import UIKit
import GPUImage
import Alamofire

import SSZipArchive

class ViewController: UIViewController {

   // @IBOutlet weak var segmentedControl:ScrollableSegmentedControl!
    var sceneType:String?
     var sceneName:String?
     var filterName:String!
     var stickerTypeName:String?
     var maskTypeName:String?
     var maskOldTypeName:String?
     var itemJSonURL:String!
     var stickerJSonURL:String!
     
     var owner:Any?
     
     
     var threeFilter: GPUImageThreeInputFilter?
     var sdkManager:SDKManager = SDKManager()
     var filteredImage : UIImage?
     var outputFrameBuffer : GPUImageFramebuffer?
     
     var stickers:NSDictionary?
     var itemAccesorys:NSDictionary?
     var masks:NSDictionary?
     
  //   var dataSource:StickerDelegate?
  //   var dataSourceMask:MaskDelegate?
  //   var dataSourceItem:ItemDelegate?
     var bSticker:Bool?
     var bFilter:Bool?
   //  var filterMenuSource:FiterMenuDelegate?
   //  var filterSource:FilterDelegate?
     
     var stickerMenuSource:StickerMenuDelegate?
     
     var filters:NSMutableArray?
     var bMore:Bool?
     
     var exportUrl:NSURL?
     var bBeauty:Bool?
     
     var frameCount:Int!
     
     var appDelegate:AppDelegate!
     var isRecording:Bool!
    var isCameraOn = false
     
    var stickerDataSource :StickerDelegate! //(items:self.stickers!,owner:self)

    var maskDataSource :MaskItemSource! //(items:self.stickers!,owner:self)

    @IBOutlet weak var renderView: GPUImageView?
    @IBOutlet weak var stickerView:UICollectionView?
    @IBOutlet weak var menuView:UICollectionView?
    @IBOutlet weak var filterView:UICollectionView?
    @IBOutlet weak var filterMenuView:UICollectionView?
    @IBOutlet weak var itemMenuView:UICollectionView?
    
    @IBOutlet weak var captureBt:UIButton?
    @IBOutlet weak var stickerBt:UIButton?
    @IBOutlet weak var filterBt:UIButton?
    @IBOutlet weak var moreBt:UIButton?
    @IBOutlet weak var torchBt:UIImageView!
    @IBOutlet weak var indicator:UIActivityIndicatorView?
    
    @IBOutlet weak var closeBt:UIImageView!
  
    @IBOutlet weak var albumbBt:UIImageView?
    @IBOutlet weak var timerBt:UIImageView!
    @IBOutlet weak var storeBt:UIButton?
    @IBOutlet weak var settingBt:UIButton?
    @IBOutlet weak var ratioBt:UIImageView!
    @IBOutlet weak var rotateBt:UIImageView!
    
    @IBOutlet weak var swapBt:UIButton!
    
    @IBOutlet weak var bottomMargin:NSLayoutConstraint?
    @IBOutlet weak var topMargin:NSLayoutConstraint?
    @IBOutlet weak var container:UIView?
    @IBOutlet weak var displayTitle:UILabel?
    
  //  @IBOutlet weak var ring1: UICircularProgressRing!
    @IBOutlet weak var menuOrg:UIView?
    @IBOutlet weak var menuItem:UIView?
    @IBOutlet weak var noFilter:UIView?
    @IBOutlet weak var testView:UIImageView!
    
    @IBOutlet weak var prevTop:NSLayoutConstraint!
    @IBOutlet weak var timerTop:NSLayoutConstraint!
    @IBOutlet weak var ratioTop:NSLayoutConstraint!
    @IBOutlet weak var torchTop:NSLayoutConstraint!
    @IBOutlet weak var rotateTop:NSLayoutConstraint!
      
    
    @IBOutlet weak var ratioConstant:NSLayoutConstraint!
 
    var bVip = false
    var filterSource:FilterSource!
 
    var videoCamera:GPUImageVideoCamera?
     var frontCamera:GPUImageVideoCamera?
     
     var frontCamera0:GPUImageVideoCamera?
     var frontCamera1:GPUImageVideoCamera?
     
     var front480Camera:GPUImageVideoCamera?
     var backCamera:GPUImageVideoCamera?
     var filter: GPUImageFilter?
     var beautyFilterGroup: BeautyFilterGroup?
     var cropFilter: CropFilter?
     
    // var movieWriter: GPUImageMovieWriter?
     var scene:Scene?
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
    var timer0:Timer?
 
     var count = 0
     var timerShotCount: Int?
     
     var bVline:Bool!
     var bOpenEyes:Bool!
     var bBigEyes:Bool!
     var bClick:Bool!
     
     var bReward:Bool!
    var sampleBuffer: CMSampleBuffer?

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
    func initSDK()
    {
        
         sceneType = "none"
              
        stickerTypeName = "none"
        
        self.filterName = "none"
        
        maskTypeName = "none"
        
        maskOldTypeName = "none"
              
         isRecording = false
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
    override func viewWillAppear(_ animated: Bool) {
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        initGesture()
        bFront = true
        ratioMode = 1
        self.view.addSubview(self.activityIndicator)

         ratioConstant.constant = UIScreen.main.bounds.height -  UIScreen.main.bounds.width * CGFloat(4.0) / CGFloat(3.0) - 88
        //
        
        activityIndicator.startAnimating()
        //
        initTimer()
   
        bOpenEyes = true
        bBigEyes = true
        
        filters = NSMutableArray()
        
        sceneType = "none"
              
        stickerTypeName = "none"
        
        self.filterName = "none"
        
        maskTypeName = "none"
        
        maskOldTypeName = "none"
              
         isRecording = false
        
        itemJSonURL = "http://www.junsoft.org/stickers/item.json"
        stickerJSonURL = "http://www.junsoft.org/stickers/live_sticker.json"
              
        stickerJSonURL = "http://www.junsoft.org/test2/live_sticker.json"
              
        itemJSonURL = "http://www.junsoft.org/test2/item.json"
        
        
        stickerView?.isHidden  = true
              
        stickerView?.backgroundColor = UIColor(
                  hue: 0.0,
                  saturation: 0.0,
                  brightness: 0.0,
                  alpha: 1)
              
   //     self.container?.backgroundColor = UIColor.black
             
        initSDK()
    }
    func pixelBuffer(from image: CGImage) -> CVPixelBuffer? {
        
        let width = image.width
        let height = image.height
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let bytesPerPixel = 4
        let bytesPerRow = bytesPerPixel * width
        let bitsPerComponent = 8
        let bitmapInfo = CGBitmapInfo.byteOrder32Little.rawValue | CGImageAlphaInfo.premultipliedFirst.rawValue
        
        var pixelBuffer: CVPixelBuffer?
        let status = CVPixelBufferCreate(kCFAllocatorDefault, width, height, kCVPixelFormatType_32BGRA, nil, &pixelBuffer)
        guard status == kCVReturnSuccess, let buffer = pixelBuffer else {
            return nil
        }
        
        CVPixelBufferLockBaseAddress(buffer, CVPixelBufferLockFlags(rawValue: 0))
        let context = CGContext(data: CVPixelBufferGetBaseAddress(buffer), width: width, height: height, bitsPerComponent: bitsPerComponent, bytesPerRow: bytesPerRow, space: colorSpace, bitmapInfo: bitmapInfo)
        context?.draw(image, in: CGRect(x: 0, y: 0, width: width, height: height))
        CVPixelBufferUnlockBaseAddress(buffer, CVPixelBufferLockFlags(rawValue: 0))
        
        return pixelBuffer
        
    }
    func resizePhoto(_ image: UIImage, outputSize: CGSize) -> UIImage? {
        var imageRect: CGRect = .zero
        
        if outputSize.height / outputSize.width < image.size.height / image.size.width {
            let height = outputSize.width * image.size.height / image.size.width
            imageRect = CGRect(x: 0, y: (outputSize.height - height) / 2.0, width: outputSize.width, height: height)
        } else {
            let width = outputSize.height * image.size.width / image.size.height
            imageRect = CGRect(x: (outputSize.width - width) / 2.0, y: 0, width: width, height: outputSize.height)
        }
        
        UIGraphicsBeginImageContext(outputSize)
        image.draw(in: imageRect)
        let destImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return destImage
    }
    func deleteBuffer()
    {
        if sampleBuffer != nil{
            CMSampleBufferInvalidate(sampleBuffer!)

        }
        
    }
    func processPhoto(img:UIImage){
        var photo = resizePhoto(img, outputSize: CGSize(width: 720, height: 1280))!
           
        if let pixelBuffer = pixelBuffer(from: (photo.cgImage!)) {
            let presentationTime = CMTimeMake(value: 10, timescale: 1000000)
            var timingInfo = CMSampleTimingInfo(duration: CMTime.invalid,
                                                presentationTimeStamp: presentationTime,
                                                decodeTimeStamp: CMTime.invalid)
            var videoInfo: CMVideoFormatDescription?
            CMVideoFormatDescriptionCreateForImageBuffer(allocator: nil,
                                                         imageBuffer: pixelBuffer,
                                                         formatDescriptionOut: &videoInfo)
            CMSampleBufferCreateForImageBuffer(allocator: kCFAllocatorDefault,
                                               imageBuffer: pixelBuffer,
                                               dataReady: true,
                                               makeDataReadyCallback: nil,
                                               refcon: nil,
                                               formatDescription: videoInfo!,
                                               sampleTiming: &timingInfo,
                                               sampleBufferOut: &sampleBuffer)
            
            enqueueFrame(sampleBuffer!)
        }
        
    }
    func enqueueFrame(_ sampleBuffer: CMSampleBuffer) {
        
        
//        deepAR.enqueueCameraFrame(sampleBuffer, mirror: false)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.enqueueFrame(sampleBuffer)
        }
    }
    //
    @objc func close()
    {
        videoCamera?.delegate = nil
        videoCamera?.pauseCapture()
        
        if(timer != nil)
        {
            timer?.invalidate()
        }
        if(timer0 != nil)
        {
            timer0?.invalidate()
        }
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
        dismiss(animated: true, completion: nil)
    }
    func initGesture()
    {
        let tapGesture0 = UITapGestureRecognizer(target: self, action: #selector(close))
        closeBt.isUserInteractionEnabled = true
        closeBt.addGestureRecognizer(tapGesture0)
        
        
        let tapGesture1 = UITapGestureRecognizer(target: self, action: #selector(setTorch))
        torchBt.isUserInteractionEnabled = true
        torchBt.addGestureRecognizer(tapGesture1)
        
        let tapGesture2 = UITapGestureRecognizer(target: self, action: #selector(rotateCamera))
        rotateBt.isUserInteractionEnabled = true
        rotateBt.addGestureRecognizer(tapGesture2)
         
        let tapGesture3 = UITapGestureRecognizer(target: self, action: #selector(setRatio))
        ratioBt.isUserInteractionEnabled = true
        ratioBt.addGestureRecognizer(tapGesture3)
        
        let tapGesture4 = UITapGestureRecognizer(target: self, action: #selector(timerShot))
        timerBt.isUserInteractionEnabled = true
        timerBt.addGestureRecognizer(tapGesture4)
   
    }
    @objc func timerShot()
       {
           let user:UserDefaults = UserDefaults.standard
           
           timerShotCount = user.integer(forKey: "SNAPSHOT_TIMER")
           
           if(timerShotCount == 0)
           {
               // 3
               timerShotCount = 3
               user.set(timerShotCount, forKey: "SNAPSHOT_TIMER")
               
               let timer3 = UIImage(named: "timer_3")
               self.timerBt.image = timer3
               
            
           }
           else if(timerShotCount == 3)
           {
               // 5
               timerShotCount = 5
               user.set(timerShotCount, forKey: "SNAPSHOT_TIMER")
               
               let timer5 = UIImage(named: "timer_5")
              
               self.timerBt.image = timer5
       
           }
           else if(timerShotCount == 5)
           {
               // 10
               timerShotCount = 10
               user.set(timerShotCount, forKey: "SNAPSHOT_TIMER")
               
               let timer10 = UIImage(named: "timer_10")
               
                self.timerBt.image = timer10
        
               
           }
           else if(timerShotCount == 10)
           {
               // 0
               timerShotCount = 0
               user.set(timerShotCount, forKey: "SNAPSHOT_TIMER")
               
               let timer0 = UIImage(named: "timer0")
               
               
                self.timerBt.image = timer0
        
           }
           user.synchronize()
           
       }
     func initTimer()
       {
           let user:UserDefaults = UserDefaults.standard
           
           timerShotCount = user.integer(forKey: "SNAPSHOT_TIMER")
           
           if(timerShotCount == 0)
           {
               // 3
               
               let timer0 = UIImage(named: "timer0")
               
               
                self.timerBt.image = timer0
               
            
               
            
           }
           else if(timerShotCount == 3)
           {
               // 5
               let timer3 = UIImage(named: "timer_3")
               self.timerBt.image = timer3
           
       
           }
           else if(timerShotCount == 5)
           {
               // 10
               
                   
               let timer5 = UIImage(named: "timer_5")
              
               self.timerBt.image = timer5
               
            
               
           }
           else if(timerShotCount == 10)
           {
               // 0
               let timer10 = UIImage(named: "timer_10")
               
                self.timerBt.image = timer10
        
        
           }
         //  user.synchronize()
           
       }
    func startTimer(){
         self.timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(self.update), userInfo: nil, repeats: true)
     }
     
     @objc func update(){
         //0.5초마다 반복
         print("update")
         let user:UserDefaults = UserDefaults.standard
         let timerCnt:Int = user.integer(forKey: "SNAPSHOT_TIMER")
         
         
         count = count + 1
         let strokeTextAttributes: [NSAttributedString.Key : Any] = [
            NSAttributedString.Key.strokeColor : UIColor.gray,
            NSAttributedString.Key.foregroundColor : UIColor.white,
            NSAttributedString.Key.strokeWidth : -1.0,
             ]
         
         
         self.displayTitle?.attributedText = NSAttributedString(string:String(timerCnt-count), attributes: strokeTextAttributes)
         
         
         if( count >= timerCnt )
         {
             self.stopTimer()
             
         }
     }
     
     func stopTimer()
    {
        
        print("stopTimer")
       
         self.timer?.invalidate()
         self.timer = nil
         count = 0
         self.displayTitle?.text = ""
         
         let user:UserDefaults = UserDefaults.standard
       
       // takePicture0()

        videoCamera?.pauseCapture()
    
        var size:CGSize?
        if(ratioMode == 1 )
        {
            size = CGSize(width: 480, height: 640)
        }
        else if(ratioMode == 2)
        {
            size = CGSize(width: 480, height: 480)
        }
        else
        {
            size = CGSize(width: 720, height: 1280)
            
        }
        if(jFaceLookup?.finalFilter != nil)
        {
            capturedImage = cropFilter?.getFrameBuffer(jFaceLookup?.finalFilter,size: size!)
            
        }
        else
        {
            capturedImage = cropFilter?.getFrameBuffer(cropFilter, size: size!)
            //   capturedImage = manager.takePicture(videoCamera)
        }
        videoCamera?.resumeCameraCapture()
        performSegue(withIdentifier: "exec_photo", sender: nil)
     }
    func initRestoreUI()
      {
          
          
          /*
          if(ratioMode == 0)
          {
              let ratioImg = UIImage(named: "ratio2_w")
              self.ratioBt.image = ratioImg
              
          }
           */
          if(ratioMode == 1)
          {
              let ratioImg = UIImage(named: "ratio2_w")
              self.ratioBt.image = ratioImg
              
          }
          if(ratioMode == 2)
          {
              let ratioImg = UIImage(named: "ratio1_w")
              self.ratioBt.image = ratioImg
              
          }
           
          let timer0Img = UIImage(named: "timer0")
          self.timerBt.image = timer0Img
          
          let torchImg = UIImage(named: "torch2")
          self.torchBt.image = torchImg
          
          
          let rotateImg = UIImage(named: "rotate")
          self.rotateBt.image = rotateImg
          
    
      }
    @objc func setRatio(){
            
           
            DispatchQueue.main.async {
                UIView.animate(withDuration: 0.25, animations: {
                    /*
                    if( self.ratioMode == 0)
                    {
                        self.container?.backgroundColor = UIColor.black
                        self.initRestoreUI()
                        //  self.invertControl()
                        
                    }
                     */
                    if( self.ratioMode == 1)
                    {
                        self.container?.backgroundColor = UIColor.white
                        //          self.initInvertUI()
                        self.initRestoreUI()
                        
                        
                    }
                    if( self.ratioMode == 2)
                    {
                        self.container?.backgroundColor = UIColor.black
                        self.initRestoreUI()
                        // self.initControl()
                        
                    }
                    self.renderView?.alpha = 0.0
                }) { (finished) in
                    // fade out
                    if( self.ratioMode == 0 )
                    {
                        self.container?.backgroundColor = UIColor.white
                        
                        
                        //self.segmentedControl.segmentContentColor = UIColor.black//UIColor(hex: "e4e2e2")
                        //self.segmentedControl.selectedSegmentContentColor = UIColor.black
                        
                        let myShadow = NSShadow()
                        myShadow.shadowBlurRadius = 2
                        myShadow.shadowOffset = CGSize(width: 1, height: 1)
                        myShadow.shadowColor = UIColor.lightGray
                        
                        let largerRedTextAttributes = [NSAttributedString.Key.font: UIFont(name: "Helvetica", size: 12), NSAttributedString.Key.foregroundColor: UIColor.black, NSAttributedString.Key.shadow: myShadow, .strokeWidth: -1.0,.strokeColor: UIColor.lightGray] as [NSAttributedString.Key : Any]
                        let largerRedTextHighlightAttributes = [NSAttributedString.Key.font: UIFont(name: "Helvetica", size: 12), NSAttributedString.Key.foregroundColor: UIColor.black, NSAttributedString.Key.shadow: myShadow, .strokeWidth: -1.0,.strokeColor: UIColor.lightGray] as [NSAttributedString.Key : Any]
                        let largerRedTextSelectAttributes = [NSAttributedString.Key.font: UIFont(name: "Helvetica", size: 12), NSAttributedString.Key.foregroundColor: UIColor.black, NSAttributedString.Key.shadow: myShadow, .strokeWidth: -1.0,.strokeColor: UIColor.lightGray] as [NSAttributedString.Key : Any]
                      /*
                        self.segmentedControl.setTitleTextAttributes(largerRedTextAttributes, for: .normal)
                        self.segmentedControl.setTitleTextAttributes(largerRedTextHighlightAttributes, for: .highlighted)
                        self.segmentedControl.setTitleTextAttributes(largerRedTextSelectAttributes, for: .selected)
                     */
                    }
                    if( self.ratioMode == 1)
                    {
                        self.container?.backgroundColor = UIColor.white
                        /*
                        self.segmentedControl.segmentContentColor = UIColor.black//UIColor(hex: "e4e2e2")
                        self.segmentedControl.selectedSegmentContentColor = UIColor.black
                        */
                        let myShadow = NSShadow()
                        myShadow.shadowBlurRadius = 2
                        myShadow.shadowOffset = CGSize(width: 1, height: 1)
                        myShadow.shadowColor = UIColor.lightGray
                        
                        let largerRedTextAttributes = [NSAttributedString.Key.font: UIFont(name: "Helvetica", size: 12), NSAttributedString.Key.foregroundColor: UIColor.black, NSAttributedString.Key.shadow: myShadow, .strokeWidth: -1.0,.strokeColor: UIColor.lightGray] as [NSAttributedString.Key : Any]
                        let largerRedTextHighlightAttributes = [NSAttributedString.Key.font: UIFont(name: "Helvetica", size: 12), NSAttributedString.Key.foregroundColor: UIColor.black, NSAttributedString.Key.shadow: myShadow, .strokeWidth: -1.0,.strokeColor: UIColor.lightGray] as [NSAttributedString.Key : Any]
                        let largerRedTextSelectAttributes = [NSAttributedString.Key.font: UIFont(name: "Helvetica", size: 12), NSAttributedString.Key.foregroundColor: UIColor.black, NSAttributedString.Key.shadow: myShadow, .strokeWidth: -1.0,.strokeColor: UIColor.lightGray] as [NSAttributedString.Key : Any]
                        /*
                        self.segmentedControl.setTitleTextAttributes(largerRedTextAttributes, for: .normal)
                        self.segmentedControl.setTitleTextAttributes(largerRedTextHighlightAttributes, for: .highlighted)
                        self.segmentedControl.setTitleTextAttributes(largerRedTextSelectAttributes, for: .selected)
                         */
                        //  self.initInvertUI()
                    }
                    if( self.ratioMode == 2)
                    {
                        self.container?.backgroundColor = UIColor.black
                        /*
                        self.segmentedControl.segmentContentColor = UIColor(hex: "e4e2e2")
                        self.segmentedControl.selectedSegmentContentColor = UIColor.white
                         */
                        //  self.initRestoreUI()
                        let myShadow = NSShadow()
                        myShadow.shadowBlurRadius = 2
                        myShadow.shadowOffset = CGSize(width: 1, height: 1)
                        myShadow.shadowColor = UIColor.lightGray
                        
                        let largerRedTextAttributes = [NSAttributedString.Key.font: UIFont(name: "Helvetica", size: 12), NSAttributedString.Key.foregroundColor:  UIColor(red: 1, green: 1, blue: 1, alpha: 0.5), NSAttributedString.Key.shadow: myShadow, .strokeWidth: -1.0,.strokeColor: UIColor.lightGray] as [NSAttributedString.Key : Any]
                        let largerRedTextHighlightAttributes = [NSAttributedString.Key.font: UIFont(name: "Helvetica", size: 12), NSAttributedString.Key.foregroundColor: UIColor.gray, NSAttributedString.Key.shadow: myShadow, .strokeWidth: -1.0,.strokeColor: UIColor.lightGray] as [NSAttributedString.Key : Any]
                        let largerRedTextSelectAttributes = [NSAttributedString.Key.font: UIFont(name: "Helvetica", size: 12), NSAttributedString.Key.foregroundColor: UIColor.white, NSAttributedString.Key.shadow: myShadow, .strokeWidth: -1.0,.strokeColor: UIColor.lightGray] as [NSAttributedString.Key : Any]
                        /*
                        self.segmentedControl.setTitleTextAttributes(largerRedTextAttributes, for: .normal)
                        self.segmentedControl.setTitleTextAttributes(largerRedTextHighlightAttributes, for: .highlighted)
                        self.segmentedControl.setTitleTextAttributes(largerRedTextSelectAttributes, for: .selected)
                         */
                        
                    }
                    
                    self.processRatio()
                    UIView.animate(withDuration: 0.25, animations: {
                        self.renderView?.alpha = 1.0
                    })
                }
            }
            
           
            
            
        }
    func processRatio()
    {
         //  videoCamera?.pauseCapture()
         /*
           videoCamera?.captureSession.stopRunning()
           videoCamera?.captureSession.beginConfiguration()
        */
        let size:CGSize = CGSize(width: 640, height: 480)
  //      self.scene?.release()
  //      self.scene?.resetBufferSize(size)
        
  //      initSDK()
            
        
           /*
           if(self.ratioMode == 0)
           {
               //3:4
               let image = UIImage(named: "ratio2_w")
               // self.ratioBt?.setImage(image,  for: UIControlState.normal)
               
               self.ratioMode = 1
               self.bSqare = false
               
               let rect:CGRect =  self.renderView!.bounds
               ratioConstant.constant = UIScreen.main.bounds.height -  UIScreen.main.bounds.width * CGFloat(4.0) / CGFloat(3.0) - 88
                   //    self.topMargin?.constant = 0
               
               self.videoCamera?.delegate = nil
               openVideoCamera(ratio: self.bSqare!)
               
               
           }
           else
            */
            if(self.ratioMode == 1)
           {
               // 1:1
                
               
               self.ratioMode = 2
               self.bSqare = true
               
               ratioConstant.constant = UIScreen.main.bounds.height -  UIScreen.main.bounds.width * CGFloat(3.0) / CGFloat(3.0) - 88
            
             //  ratioConstant.multiplier = 1
        
               
               let rect:CGRect =  self.view.bounds
            //   self.bottomMargin?.constant = rect.size.height - rect.size.width
          //     self.topMargin?.constant = 80
          //     self.videoCamera?.delegate = nil
               
              openVideoCamera(ratio: self.bSqare!)
           }
           else if(self.ratioMode == 2)
           {
               // full
               
               
               self.ratioMode = 1
               self.bSqare = false
               let rect:CGRect =  self.renderView!.bounds
               ratioConstant.constant = UIScreen.main.bounds.height -  UIScreen.main.bounds.width * CGFloat(4.0) / CGFloat(3.0) - 88
                   //    self.topMargin?.constant = 0
               
            //   self.videoCamera?.delegate = nil
               openVideoCamera(ratio: self.bSqare!)
      
               
           }
       
        
        initCamera()
        
       
    }
       
       
       func processInvert(_image:UIImage)->UIImage
       {
           let beginImage = CIImage(image: _image)
           let filter = CIFilter(name: "CIColorInvert")
           filter?.setValue(beginImage, forKey: kCIInputImageKey)
           let newImage = UIImage(ciImage: (filter?.outputImage!)!)
           return newImage
      
       }
    @objc func rotateCamera(){
          
          
          
        UIView.transition(with: self.renderView!, duration: 0.75, options: UIView.AnimationOptions.transitionFlipFromLeft,  animations: {
              
              self.renderView?.alpha = 0.0
              if(self.bFront == true)
              {
                  self.videoCamera?.pauseCapture()
                  self.bFront = false
                  CameraAPI.shared.bFront = self.bFront!
                  self.videoCamera?.rotateCamera()
                  
              }
              else
              {
                  self.videoCamera?.pauseCapture()
                  self.videoCamera?.rotateCamera()
                  self.bFront = true
                  CameraAPI.shared.bFront = self.bFront!
             
              }
              // animation
              
          }, completion: { (finished: Bool) -> () in
              
              self.renderView?.alpha = 1.0
              self.initCamera()
              self.videoCamera?.resumeCameraCapture()
              
          })
          
      }
    @objc func update0()
    {
        if(isCameraOn == true)
        {
            timer0?.invalidate()
            
            initCamera()
            
            activityIndicator.stopAnimating()
          
            
            initNoneFilter()
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
      
         
            processPhoto(img: UIImage(named: "test")!)
   
          
        }
        
    
       
    }

    func openVideoCamera(ratio:Bool)
   {
       
       if ((beautyFilter != nil ||  filter != nil) || jFaceLookup != nil) {
           videoCamera?.removeAllTargets()
           filter?.removeAllTargets()
           jFaceLookup?.removeAllTargets()
           jFaceLookup?.removeAll()
           beautyFilter?.removeAllTargets()
           cropFilter?.removeAllTargets()
  
           
       }
       
            
       if(self.ratioMode == 1)
       {
           let cropRect:CGRect = CGRect(x: 0, y: 0, width: 1, height: 1.0)
           self.cropFilter = CropFilter(cropRegion: cropRect)
           self.cropFilter?.forceProcessing(at: CGSize(width: 640, height: 480))
       }
       else if(self.ratioMode == 2)
       {
           let cropRect:CGRect = CGRect(x: 0, y: 0, width: 1, height: 0.75)
           self.cropFilter = CropFilter(cropRegion: cropRect)
           self.cropFilter?.forceProcessing(at: CGSize(width: 480, height: 480))
  
       }
      
   }
   
    
    func initCamera()
    {
    
        let user:UserDefaults = UserDefaults.standard

        bOpenEyes =  user.bool(forKey: "OPEN_EYES")
        
        bVline =  user.bool(forKey: "VLINE")
        
        bBigEyes =  user.bool(forKey: "BIG_EYES")
        
        videoCamera?.resumeCameraCapture()
        
        if(sceneType == "none")
        {
        
            bBeauty = true
            
            initNoneFilter()
               
            
        }
        else
        {
                let manager = FileManager.default
                if(sceneType=="Lookup")
                {
                    bBeauty = true
                    setStickerFilter(name: self.filterName,sceneName: "Filter")
                    
                }
                if(sceneType=="LiveSticker")
                {
                    bBeauty = true
                    maskTypeName = "none"
                    frameCount = 0
                    setStickerFilter(name: stickerTypeName!,sceneName: "LiveSticker")
                    
                }
                if(sceneType=="FaceMask")
                {
                    bBeauty = false
                    if(maskTypeName == "none")
                    {
                        setStickerFilter(name: "none",sceneName: "LiveSticker")
                        
                    }
                    else if(maskTypeName != nil)
                    {
                        setStickerFilter(name: maskTypeName!,sceneName: "FaceMask")
                        
                    }
                    
                }
                if(sceneType=="ToneCurve")
                {
                    bBeauty = true
                    //setToneFilter
                    //exception
                    if(self.filterName == "none" || self.filterName == nil || self.filterName.isEmpty)
                    {
                        sceneType = "none"
                        bBeauty = true
                        setStickerFilter(name: "none", sceneName: "Filter")
                        
                    }
                    else
                    {
                        let pathUrl = dataFilterURL(fileName: self.filterName )//dataFileURL(fileName: filename)
                        let data = manager.contents(atPath: pathUrl.path!)
                        
                        if(data!.count != 0 )
                        {
                            setToneFilter(toneData: data!)
                            
                        }
                    }
                    
                    
                }
                
                
            }
            
            if( bFront == false)
            {
                self.jFaceLookup?.finalFilter?.setInputRotation(kGPUImageFlipHorizonal, at: 0)
                
            }
            else
            {
                self.jFaceLookup?.finalFilter?.setInputRotation(GPUImageRotationMode(rawValue: 0), at: Int(kGPUImageFlipHorizonal.rawValue))
            }
       
      }
    func setToneFilter(toneData:Data)
     {
         
         if (jFaceLookup != nil || filter != nil) {
             
             videoCamera?.removeAllTargets()
             filter?.removeAllTargets()
             
             jFaceLookup?.removeAllTargets()
             beautyFilter?.removeAllTargets()
             cropFilter?.removeAllTargets()
             
         }
         bBigEyes = true
         bVline = true
         if((sceneType == "none" || stickerTypeName == "none") && maskTypeName == "none")
         {
             scene?.initWithScene2("LiveSticker", filterName: "none", mirroed: true, resType: 0, vline:bVline, openEye: bOpenEyes, bigEye: bBigEyes)
         }
         else if(stickerTypeName != "none")
         {
             scene?.initWithScene2("LiveSticker", filterName: stickerTypeName, mirroed: true, resType: 0, vline:bVline, openEye: bOpenEyes, bigEye: bBigEyes)
         }
         else if(maskTypeName != "none")
         {
             scene?.initWithScene2("FaceMask", filterName: maskTypeName, mirroed: true, resType: 0, vline:bVline, openEye: bOpenEyes, bigEye: bBigEyes)
         }
         filter = scene
         self.toneData = toneData
         
         jFaceLookup?.useNextFrameForImageCapture()
         jFaceLookup?.processFilter("none", scene: scene ,data:toneData as Data?,beauty: bBeauty!, square: Int32(ratioMode!))
         
         
         
         
         
         renderView?.fillMode = kGPUImageFillModePreserveAspectRatioAndFill;
         
      
         jFaceLookup?.addTarget(renderView)
         videoCamera?.addTarget(jFaceLookup)
         
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
    
    func initNoneFilter()
    {
        if (jFaceLookup != nil) {
               
            videoCamera?.removeAllTargets()
            
            filter?.removeAllTargets()
            
            jFaceLookup?.removeAllTargets()
            
            
            cropFilter?.removeAllTargets()
            
        }
        
        scene?.initWithScene2("LiveSticker", filterName: "none", mirroed: true, resType: 0, vline:true, openEye: true, bigEye: true)
        
        if( self.bFront == false)
        {
            self.jFaceLookup?.finalFilter?.setInputRotation(kGPUImageFlipHorizonal, at: 0)
        }
        else
        {
            self.jFaceLookup?.finalFilter?.setInputRotation(GPUImageRotationMode(rawValue: 0), at: Int(kGPUImageFlipHorizonal.rawValue))
        }
        
        jFaceLookup?.processFilter("none", scene: scene ,data:nil,beauty: true, square: Int32(ratioMode!))
        
        renderView?.fillMode = kGPUImageFillModePreserveAspectRatioAndFill;
        
        jFaceLookup?.addTarget(renderView)
        
        videoCamera?.addTarget(jFaceLookup)
        
     
    }
    func setStickerFilter(name:String, sceneName:String)
    {
       
        let user:UserDefaults = UserDefaults.standard
        
        bOpenEyes =  user.bool(forKey: "OPEN_EYES")
        bBigEyes =  user.bool(forKey: "BIG_EYES")
        bVline =  user.bool(forKey: "VLINE")
        bBigEyes = true
        bVline = true
        bOpenEyes = true
        
        self.scene?.earringName = "none"
    
        self.scene?.hatName = "none"
       
        self.scene?.glassesName = "none"
       
        self.scene?.mustacheName = "none"
     
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
        
        if ((filter != nil) || jFaceLookup != nil) {
        
            videoCamera?.removeAllTargets()
            filter?.removeAllTargets()
            jFaceLookup?.removeAllTargets()
            beautyFilter?.removeAllTargets()
            cropFilter?.removeAllTargets()
        }
        
        if(sceneName == "Filter")
        {
            filterName = name
            if((sceneType == "none" || stickerTypeName == "none") && maskTypeName == "none")
            {
                scene?.initWithScene2("LiveSticker", filterName: "none", mirroed: true, resType: 0, vline:bVline, openEye: bOpenEyes, bigEye: bBigEyes)
                
            }
            else if(stickerTypeName != "none")
            {
                scene?.initWithScene2("LiveSticker", filterName: stickerTypeName, mirroed: true, resType: 0, vline:bVline, openEye: bOpenEyes, bigEye: bBigEyes)
                
            }
            else if(maskTypeName != "none")
            {
            
                scene?.initWithScene2("FaceMask", filterName: maskTypeName, mirroed: true, resType: 0, vline:bVline, openEye:bOpenEyes, bigEye: bBigEyes)
                
            }
            
            self.toneData = nil
            jFaceLookup?.useNextFrameForImageCapture()
            jFaceLookup?.processFilter(filterName, scene: scene, data:nil,beauty: true, square: Int32(ratioMode!))
            renderView?.fillMode = kGPUImageFillModePreserveAspectRatioAndFill;
 
            jFaceLookup?.addTarget(renderView)
            videoCamera?.addTarget(jFaceLookup)
            
        }
        else
        {
            sceneType = sceneName
            if( sceneType == "FaceMask")
            {
                scene?.initWithScene2(sceneName, filterName: name, mirroed: true, resType: 0, vline:bVline, openEye: bOpenEyes, bigEye: bBigEyes)

            }
            else
            {
                stickerTypeName = name
                scene?.initWithScene2(sceneName, filterName: name, mirroed: true, resType: 0, vline:bVline, openEye: bOpenEyes, bigEye: bBigEyes)
                
            }
            filter = scene
            renderView?.fillMode = kGPUImageFillModePreserveAspectRatioAndFill;
            jFaceLookup?.useNextFrameForImageCapture()
            
            if(self.toneData != nil)
            {
                jFaceLookup?.processFilter(filterName, scene: scene, data:self.toneData as! Data,beauty: bBeauty!, square: Int32(ratioMode!))
            }
            else
            {
                jFaceLookup?.processFilter(filterName, scene: scene, data:nil,beauty: true, square: Int32(ratioMode!))
            }
            
            jFaceLookup?.addTarget(renderView)
            videoCamera?.addTarget(jFaceLookup )
            
        }
        
        videoCamera?.delegate = self
        videoCamera?.startCapture()
                 
        
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
       func makeFloral()->NSMutableArray
       {
           setTexture(name: "lookup_floral_aureolin.png", filterName: "Floral Aureolin", thumb: "", type: "Lookup",category:"Floral")
           setTexture(name: "lookup_floral_black_cherry.png", filterName: "Floral Black Cherry", thumb: "", type: "Lookup",category:"Floral")
           setTexture(name: "lookup_floral_bliss.png", filterName: "Floral Bliss", thumb: "", type: "Lookup",category:"Floral")
           setTexture(name: "lookup_floral_california.png", filterName: "Floral California", thumb: "", type: "Lookup",category:"Floral")
           setTexture(name: "lookup_floral_caramel.png", filterName: "Floral Caramel", thumb: "", type: "Lookup",category:"Floral")
           setTexture(name: "lookup_floral_colorwheel.png", filterName: "Floral Color Wheel", thumb: "", type: "Lookup",category:"Floral")
           setTexture(name: "lookup_floral_cross_proccesing.png", filterName: "Floral Cross processing", thumb: "", type: "Lookup",category:"Floral")
           setTexture(name: "lookup_floral_echo.png", filterName: "Floral Echo", thumb: "", type: "Lookup",category:"Floral")
           setTexture(name: "lookup_floral_edition.png", filterName: "Floral Edition", thumb: "", type: "Lookup",category:"Floral")
           setTexture(name: "lookup_floral_expedition.png", filterName: "Floral Expedition", thumb: "", type: "Lookup",category:"Floral")
           setTexture(name: "lookup_floral_extravagant.png", filterName: "Floral Extravagant", thumb: "", type: "Lookup",category:"Floral")
           setTexture(name: "lookup_floral_focus_highlight.png", filterName: "Floral Focus Highlight", thumb: "", type: "Lookup",category:"Floral")
           setTexture(name: "lookup_floral_frontpage.png", filterName: "Floral Frontpage", thumb: "", type: "Lookup",category:"Floral")
           setTexture(name: "lookup_floral_gamma.png", filterName: "Floral Gamma", thumb: "", type: "Lookup",category:"Floral")
           setTexture(name: "lookup_floral_golden_yellow.png", filterName: "Floral Golden Yellow", thumb: "", type: "Lookup",category:"Floral")
           setTexture(name: "lookup_floral_hazel.png", filterName: "Floral Hazel", thumb: "", type: "Lookup",category:"Floral")
           setTexture(name: "lookup_floral_infrared.png", filterName: "Floral Infra Red", thumb: "", type: "Lookup",category:"Floral")
           setTexture(name: "lookup_floral_iris.png", filterName: "Floral Iris", thumb: "", type: "Lookup",category:"Floral")
           setTexture(name: "lookup_floral_lavender.png", filterName: "Floral Lavender", thumb: "", type: "Lookup",category:"Floral")
           setTexture(name: "lookup_floral_long_journey.png", filterName: "Floral Long Journey", thumb: "", type: "Lookup",category:"Floral")
           setTexture(name: "lookup_floral_neutral_density.png", filterName: "Floral Neutral Density", thumb: "", type: "Lookup",category:"Floral")
           setTexture(name: "lookup_floral_nonphoto_blue.png", filterName: "Floral Nonphoto Blue", thumb: "", type: "Lookup",category:"Floral")
           setTexture(name: "lookup_floral_orton.png", filterName: "Floral Orton", thumb: "", type: "Lookup",category:"Floral")
           setTexture(name: "lookup_floral_overexposure_soft.png", filterName: "Floral Overexposure Soft", thumb: "", type: "Lookup",category:"Floral")
           setTexture(name: "lookup_floral_passion.png", filterName: "Floral Passion", thumb: "", type: "Lookup",category:"Floral")
           setTexture(name: "lookup_floral_pole.png", filterName: "Floral Pole", thumb: "", type: "Lookup",category:"Floral")
           setTexture(name: "lookup_floral_raw_filter.png", filterName: "Floral Raw Filter", thumb: "", type: "Lookup",category:"Floral")
           setTexture(name: "lookup_floral_saffron.png", filterName: "Floral Saffron", thumb: "", type: "Lookup",category:"Floral")
           setTexture(name: "lookup_floral_seashell.png", filterName: "Floral Sea Shell", thumb: "", type: "Lookup",category:"Floral")
           setTexture(name: "lookup_floral_silent_night.png", filterName: "Floral Silent Night", thumb: "", type: "Lookup",category:"Floral")
           setTexture(name: "lookup_floral_skin.png", filterName: "Floral Skin", thumb: "", type: "Lookup",category:"Floral")
           setTexture(name: "lookup_floral_spring.png", filterName: "Floral Spring", thumb: "", type: "Lookup",category:"Floral")
           setTexture(name: "lookup_floral_twistedline.png", filterName: "Floral Twisted line", thumb: "", type: "Lookup",category:"Floral")
           setTexture(name: "lookup_floral_velvet.png", filterName: "Floral Velvet", thumb: "", type: "Lookup",category:"Floral")
           setTexture(name: "lookup_floral_white.png", filterName: "Floral White", thumb: "", type: "Lookup",category:"Floral")
           
           return filters!
       }
       func makeStudio()->NSMutableArray
       {
           
           setTexture(name: "lookup_studio_coldfocus.png", filterName: "Studio Cold Focus", thumb: "", type: "Lookup",category:"Studio")
           setTexture(name: "lookup_studio_elegant.png", filterName: "Studio Elegant", thumb: "", type: "Lookup",category:"Studio")
           setTexture(name: "lookup_studio_memories.png", filterName: "Studio Memories", thumb: "", type: "Lookup",category:"Studio")
           setTexture(name: "lookup_studio_overexposure_soft.png", filterName: "Studio Over Exposure", thumb: "", type: "Lookup",category:"Studio")
           setTexture(name: "lookup_studio_ultracontrast.png", filterName: "Studio Ultra Contrast", thumb: "", type: "Lookup",category:"Studio")
           setTexture(name: "lookup_studio_wavelength.png", filterName: "Studio Wavelength", thumb: "", type: "Lookup",category:"Studio")
           setTexture(name: "lookup_bw_classic.png", filterName: "Studio Classic", thumb: "", type: "Lookup",category:"Studio")
           setTexture(name: "lookup_bw_hill.png", filterName: "Studio Hill", thumb: "", type: "Lookup",category:"Studio")
           setTexture(name: "lookup_bw_photo_master.png", filterName: "Studio Photo Master", thumb: "", type: "Lookup",category:"Studio")
           setTexture(name: "lookup_bw_toning_classic_summer.png", filterName: "Studio Toning Classic Summer", thumb: "", type: "Lookup",category:"Studio")
           setTexture(name: "lookup_bw_toning_everest.png", filterName: "Studio Toning Everest", thumb: "", type: "Lookup",category:"Studio")
           setTexture(name: "lookup_bw_toning_polaroid.png", filterName: "Studio Toning Polaroid", thumb: "", type: "Lookup",category:"Studio")
           setTexture(name: "lookup_bw_toning_selenium.png", filterName: "Studio Toning Selenium", thumb: "", type: "Lookup",category:"Studio")
           setTexture(name: "lookup_bw_toning_strawberry.png", filterName: "Studio Toning Strawberry", thumb: "", type: "Lookup",category:"Studio")
           setTexture(name: "lookup_bw_waves.png", filterName: "Studio Waves", thumb: "", type: "Lookup",category:"Studio")
           
           return filters!
       }
       func makeWdding()->NSMutableArray
       {
           
           setTexture(name: "lookup_wdding_apollo.png", filterName: "Wedding Apollo", thumb: "", type: "Lookup",category:"Wedding")
           setTexture(name: "lookup_wdding_aquamarine.png", filterName: "Wedding Aqua Marine", thumb: "", type: "Lookup",category:"Wedding")
           setTexture(name: "lookup_wdding_bronzer.png", filterName: "Wedding Bronzer", thumb: "", type: "Lookup",category:"Wedding")
           setTexture(name: "lookup_wedding_autumnal.png", filterName: "Wedding Autumnal", thumb: "", type: "Lookup",category:"Wedding")
           setTexture(name: "lookup_wedding_bw_diana.png", filterName: "Wedding B&W Diana", thumb: "", type: "Lookup",category:"Wedding")
           setTexture(name: "lookup_wedding_bw_lowkey.png", filterName: "Wedding B&W Lowkey", thumb: "", type: "Lookup",category:"Wedding")
           setTexture(name: "lookup_wedding_dramatic_light.png", filterName: "Wedding Dramatic Light", thumb: "", type: "Lookup",category:"Wedding")
           setTexture(name: "lookup_wedding_enhance.png", filterName: "Wedding Enhance", thumb: "", type: "Lookup",category:"Wedding")
           setTexture(name: "lookup_wedding_ezon.png", filterName: "Wedding Ezon", thumb: "", type: "Lookup",category:"Wedding")
           setTexture(name: "lookup_wedding_fashion.png", filterName: "Wedding Fashion", thumb: "", type: "Lookup",category:"Wedding")
           setTexture(name: "lookup_wedding_galaxy.png", filterName: "Wedding Galaxy", thumb: "", type: "Lookup",category:"Wedding")
           setTexture(name: "lookup_wedding_hazel.png", filterName: "Wedding Hazel", thumb: "", type: "Lookup",category:"Wedding")
           setTexture(name: "lookup_wedding_highbubble.png", filterName: "Wedding High Bubble", thumb: "", type: "Lookup",category:"Wedding")
           setTexture(name: "lookup_wedding_layan.png", filterName: "Wedding Layan", thumb: "", type: "Lookup",category:"Wedding")
           setTexture(name: "lookup_wedding_pastel.png", filterName: "Wedding Pastel", thumb: "", type: "Lookup",category:"Wedding")
           setTexture(name: "lookup_wedding_summer.png", filterName: "Wedding Summer", thumb: "", type: "Lookup",category:"Wedding")
           setTexture(name: "lookup_wedding_urban_style.png", filterName: "Wedding Urbal Style", thumb: "", type: "Lookup",category:"Wedding")
           
           return filters!
       }
       
       func makeModern()->NSMutableArray
       {
           setTexture(name: "lookup_modern_apricot.png", filterName: "Modern Apicot", thumb: "", type: "Lookup",category:"Modern")
           setTexture(name: "lookup_modern_delicate.png", filterName: "Modern Delicate", thumb: "", type: "Lookup",category:"Modern")
           setTexture(name: "lookup_modern_deluxe.png", filterName: "Modern Deluxe", thumb: "", type: "Lookup",category:"Modern")
           setTexture(name: "lookup_modern_dot_digital.png", filterName: "Modern Dot Digital1", thumb: "", type: "Lookup",category:"Modern")
           setTexture(name: "lookup_modern_dot_digital2.png", filterName: "Modern Dot Digital2", thumb: "", type: "Lookup",category:"Modern")
           setTexture(name: "lookup_modern_ecru.png", filterName: "Modern Ecru", thumb: "", type: "Lookup",category:"Modern")
           setTexture(name: "lookup_modern_emerald.png", filterName: "Modern Emerald", thumb: "", type: "Lookup",category:"Modern")
           setTexture(name: "lookup_modern_exquisite.png", filterName: "Modern Exquisite", thumb: "", type: "Lookup",category:"Modern")
           setTexture(name: "lookup_modern_graceful.png", filterName: "Modern Graceful", thumb: "", type: "Lookup",category:"Modern")
           setTexture(name: "lookup_modern_light_faded.png", filterName: "Modern Light Faded", thumb: "", type: "Lookup",category:"Modern")
           setTexture(name: "lookup_modern_muted.png", filterName: "Modern Muted", thumb: "", type: "Lookup",category:"Modern")
           setTexture(name: "lookup_modern_orange_peel.png", filterName: "Modern Orange Peel", thumb: "", type: "Lookup",category:"Modern")
           setTexture(name: "lookup_modern_peri_winkle.png", filterName: "Modern Periwinkle", thumb: "", type: "Lookup",category:"Modern")
           setTexture(name: "lookup_modern_pistachio.png", filterName: "Modern Pistachio", thumb: "", type: "Lookup",category:"Modern")
           setTexture(name: "lookup_modern_sunny.png", filterName: "Modern Sunny", thumb: "", type: "Lookup",category:"Modern")
           setTexture(name: "lookup_modern_vanilla.png", filterName: "Modern Vanilla", thumb: "", type: "Lookup",category:"Modern")
           setTexture(name: "lookup_modern_white_smoke.png", filterName: "Modern White Smoke", thumb: "", type: "Lookup",category:"Modern")
           
           return filters!
       }
       func makeVintage() -> NSMutableArray
       {
           
           setTexture(name: "lookup_vintage_aged.png", filterName: "Vintage Aged", thumb: "", type: "Lookup",category:"Vintage")
           setTexture(name: "lookup_vintage_antique.png", filterName: "Vintage Antique", thumb: "", type: "Lookup",category:"Vintage")
           
           setTexture(name: "lookup_vintage_blue_fade.png", filterName: "Vintage Blue Fade", thumb: "", type: "Lookup",category:"Vintage")
           setTexture(name: "lookup_vintage_brash.png", filterName: "Vintage Brashs", thumb: "", type: "Lookup",category:"Vintage")
           setTexture(name: "lookup_vintage_classic_fade.png", filterName: "Vintage Classic Fade", thumb: "", type: "Lookup",category:"Vintage")
           setTexture(name: "lookup_vintage_classica.png", filterName: "Vintage Classica", thumb: "", type: "Lookup",category:"Vintage")
           setTexture(name: "lookup_vintage_colors.png", filterName: "Vintage Colors", thumb: "", type: "Lookup",category:"Vintage")
           setTexture(name: "lookup_vintage_cool.png", filterName: "Vintage Cool", thumb: "", type: "Lookup",category:"Vintage")
           setTexture(name: "lookup_vintage_cool2.png", filterName: "Vintage Cool2", thumb: "", type: "Lookup",category:"Vintage")
           setTexture(name: "lookup_vintage_creamy.png", filterName: "Vintage Creamy", thumb: "", type: "Lookup",category:"Vintage")
           setTexture(name: "lookup_vintage_darkness.png", filterName: "Vintage Darkness", thumb: "", type: "Lookup",category:"Vintage")
           setTexture(name: "lookup_vintage_days_gone_by.png", filterName: "Vintage Days Gone by", thumb: "", type: "Lookup",category:"Vintage")
           setTexture(name: "lookup_vintage_depth.png", filterName: "Vintage Depth", thumb: "", type: "Lookup",category:"Vintage")
           setTexture(name: "lookup_vintage_earthy.png", filterName: "Vintage Earthy", thumb: "", type: "Lookup",category:"Vintage")
           setTexture(name: "lookup_vintage_earthy2.png", filterName: "Vintage Earthy2", thumb: "", type: "Lookup",category:"Vintage")
           setTexture(name: "lookup_vintage_fade.png", filterName: "Vintage Fade", thumb: "", type: "Lookup",category:"Vintage")
           setTexture(name: "lookup_vintage_fade2.png", filterName: "Vintage Fade2", thumb: "", type: "Lookup",category:"Vintage")
           setTexture(name: "lookup_vintage_glory_days.png", filterName: "Vintage Glory Days", thumb: "", type: "Lookup",category:"Vintage")
           setTexture(name: "lookup_vintage_golden_fade.png", filterName: "Vintage Golden Fade", thumb: "", type: "Lookup",category:"Vintage")
           setTexture(name: "lookup_vintage_haze.png", filterName: "Vintage Haze", thumb: "", type: "Lookup",category:"Vintage")
           setTexture(name: "lookup_vintage_heaven.png", filterName: "Vintage Heaven", thumb: "", type: "Lookup",category:"Vintage")
           setTexture(name: "lookup_vintage_history.png", filterName: "Vintage History", thumb: "", type: "Lookup",category:"Vintage")
           setTexture(name: "lookup_vintage_icy.png", filterName: "Vintage Icy", thumb: "", type: "Lookup",category:"Vintage")
           setTexture(name: "lookup_vintage_insomnia.png", filterName: "Vintage Insomnia", thumb: "", type: "Lookup",category:"Vintage")
           setTexture(name: "lookup_vintage_intense.png", filterName: "Vintage Intense", thumb: "", type: "Lookup",category:"Vintage")
           setTexture(name: "lookup_vintage_light.png", filterName: "Vintage Light", thumb: "", type: "Lookup",category:"Vintage")
           setTexture(name: "lookup_vintage_lostdays.png", filterName: "Vintage Lost Days", thumb: "", type: "Lookup",category:"Vintage")
           setTexture(name: "lookup_vintage_matte.png", filterName: "Vintage Matte", thumb: "", type: "Lookup",category:"Vintage")
           setTexture(name: "lookup_vintage_matte2.png", filterName: "Vintage Matte2", thumb: "", type: "Lookup",category:"Vintage")
           setTexture(name: "lookup_vintage_memories.png", filterName: "Vintage Memories", thumb: "", type: "Lookup",category:"Vintage")
           setTexture(name: "lookup_vintage_morning.png", filterName: "Vintage Morning", thumb: "", type: "Lookup",category:"Vintage")
           setTexture(name: "lookup_vintage_old_timer.png", filterName: "Vintage Old Timer", thumb: "", type: "Lookup",category:"Vintage")
           setTexture(name: "lookup_vintage_outdated.png", filterName: "Vintage Outdated", thumb: "", type: "Lookup",category:"Vintage")
           setTexture(name: "lookup_vintage_overcast.png", filterName: "Vintage Overcast", thumb: "", type: "Lookup",category:"Vintage")
           setTexture(name: "lookup_vintage_past_tense.png", filterName: "Vintage Past Tense", thumb: "", type: "Lookup",category:"Vintage")
           setTexture(name: "lookup_vintage_peach.png", filterName: "Vintage Peach", thumb: "", type: "Lookup",category:"Vintage")
           setTexture(name: "lookup_vintage_pressed.png", filterName: "Vintage Pressed", thumb: "", type: "Lookup",category:"Vintage")
           setTexture(name: "lookup_vintage_purpleish.png", filterName: "Vintage Purple-ish", thumb: "", type: "Lookup",category:"Vintage")
           setTexture(name: "lookup_vintage_retro_fix.png", filterName: "Vintage Retro Fix", thumb: "", type: "Lookup",category:"Vintage")
           setTexture(name: "lookup_vintage_retro_red.png", filterName: "Vintage Retro Red", thumb: "", type: "Lookup",category:"Vintage")
           setTexture(name: "lookup_vintage_retro_red2.png", filterName: "Vintage Retro Red2", thumb: "", type: "Lookup",category:"Vintage")
           setTexture(name: "lookup_vintage_rose.png", filterName: "Vintage Rose", thumb: "", type: "Lookup",category:"Vintage")
           setTexture(name: "lookup_vintage_second_hand.png", filterName: "Vintage Second Hand", thumb: "", type: "Lookup",category:"Vintage")
           setTexture(name: "lookup_vintage_serious.png", filterName: "Vintage Serious", thumb: "", type: "Lookup",category:"Vintage")
           setTexture(name: "lookup_vintage_soft.png", filterName: "Vintage Soft", thumb: "", type: "Lookup",category:"Vintage")
           setTexture(name: "lookup_vintage_something_blue.png", filterName: "Vintage Something Blue", thumb: "", type: "Lookup",category:"Vintage")
           setTexture(name: "lookup_vintage_something_old.png", filterName: "Vintage Something Old", thumb: "", type: "Lookup",category:"Vintage")
           setTexture(name: "lookup_vintage_sun.png", filterName: "Vintage Sun", thumb: "", type: "Lookup",category:"Vintage")
           setTexture(name: "lookup_vintage_sun2.png", filterName: "Vintage Sun2", thumb: "", type: "Lookup",category:"Vintage")
           setTexture(name: "lookup_vintage_timid.png", filterName: "Vintage Timid", thumb: "", type: "Lookup",category:"Vintage")
           setTexture(name: "lookup_vintage_touch.png", filterName: "Vintage Touch", thumb: "", type: "Lookup",category:"Vintage")
           setTexture(name: "lookup_vintage_very.png", filterName: "Vintage Very", thumb: "", type: "Lookup",category:"Vintage")
           setTexture(name: "lookup_vintage_wash.png", filterName: "Vintage Wash", thumb: "", type: "Lookup",category:"Vintage")
           setTexture(name: "lookup_vintage_whisper.png", filterName: "Vintage Whisper", thumb: "", type: "Lookup",category:"Vintage")
           setTexture(name: "lookup_old_beach.png", filterName: "Vintage Beach", thumb: "", type: "Lookup",category:"Vintage")
           setTexture(name: "lookup_old_broadway.png", filterName: "Vintage Broadway", thumb: "", type: "Lookup",category:"Vintage")
           setTexture(name: "lookup_old_covershot.png", filterName: "Vintage Covershot", thumb: "", type: "Lookup",category:"Vintage")
           setTexture(name: "lookup_oldmemories.png", filterName: "Vintage Memories", thumb: "", type: "Lookup",category:"Vintage")
           
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
          items = makeVintage()
          items = makeHaze()
          items = makeModern()
          items = makeWdding()
          items = makeStudio()
          items = makeFloral()
      
           filterSource = FilterSource(items: filters!, owner: self)
           
           /*
           self.filterView?.delegate = self.filterSource
           self.filterView?.dataSource = self.filterSource
           
           self.filterView?.scrollToItem(at: IndexPath(row: 0, section: 0),
                                         at: .left,
                                         animated: true)
           
           self.filterView?.reloadData()
            */
           self.stickerView?.delegate = filterSource
           self.stickerView?.dataSource = filterSource
     
           
           self.stickerView?.reloadData()
           
           
       
   
       }
    
  
   
    func processFilter(item:String,type:String, cell:ThumbCell)
    {
        let url:String = String(format: "http://www.junsoft.org/filter/%@", item as CVarArg)
              
        sceneType = ""
        bBeauty = true
      
             
        downloadFilter(url: url,filename: item, type: type, stickerName: "", cell: cell)

        
    }
    func downloadFilter(url : String, filename : String,type:String, stickerName:String, cell:ThumbCell)
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
                  cell.indicator?.isHidden = true
                  cell.indicator?.stopAnimating()
             
                  // exist
                  if(type=="Lookup")
                  {
                      self.setStickerFilter(name: filename,sceneName: "Filter")
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
   
           @objc func  setTorch()
           {
            
            let device = videoCamera?.inputCamera;
            // if ([flashLight isTorchAvailable] && [flashLight isTorchModeSupported:AVCaptureTorchModeOn])
            
            if (device?.hasTorch)! {
                
                do {
                    try device?.lockForConfiguration()
                    
                    if(device?.torchMode == .off){
                        device?.torchMode = .on
                        bTorch = true
                        
                     
                    } else {
                        
                        device?.torchMode = .off
                        bTorch = false
                        
                     
                        
                    }
                    
                    device?.unlockForConfiguration()
                } catch {
                    print("Torch could not be used")
                }
            }
            
            
        }
    
    func showMask()
    {
        downloadMaskJSON(url: "http://www.junsoft.org/mask/mask.json", filename: "mask.json")
    }
    @IBAction func showSwap()
    {
        
        var vip2 = UserDefaults.standard.bool(forKey: "BUY_VIP2")
       
       // vip2 =  true
        if(vip2 == true)
        {
            UIView.animate(withDuration: 0.25) {
                self.bSticker = true
                self.bFilter = false
                
                self.captureBt?.isHidden = true
                self.filterBt?.isHidden = true
                self.stickerBt?.isHidden = true
                
                self.stickerView?.isHidden = false
                self.menuView?.isHidden = false
                
                self.menuOrg?.isHidden  = false
                self.menuItem?.isHidden  = false
                
                self.filterMenuView?.isHidden = true
                self.filterView?.isHidden = true
                
                self.swapBt.isHidden = true
              //  self.segmentedControl.isHidden = true
                
                
                
                self.indicator?.isHidden = false
                
                self.indicator?.startAnimating()
                
                self.stickerMenuSource = StickerMenuDelegate(owner: self)
                
                self.menuView?.delegate = self.stickerMenuSource
                self.menuView?.dataSource = self.stickerMenuSource
                
                
            }
            
            //    self.captureBt?.layer.zPosition = 1000
            
            let user:UserDefaults = UserDefaults.standard
            
            let index:Int = user.integer(forKey: "STICKER_MENU")
            downloadMaskJSON(url: "http://www.junsoft.org/mask/mask.json", filename: "mask.json")

        }
        else
        {
            showStore0(type: 2)
        }
        
      
        //showMask()
    }
    open override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return UIInterfaceOrientationMask.portrait
    }
    @IBAction func showFilter()
    {
        
        self.captureBt?.isHidden = true
        self.filterBt?.isHidden = true
        self.stickerBt?.isHidden = true
        
        self.stickerView?.isHidden = false
        self.menuView?.isHidden = false
        
        self.menuOrg?.isHidden  = false
        self.menuItem?.isHidden  = false
        
        self.filterMenuView?.isHidden = true
        self.filterView?.isHidden = true
        self.swapBt.isHidden = true
        
      //  self.segmentedControl.isHidden = true
        
        
        
        self.indicator?.isHidden = false
        
        self.indicator?.startAnimating()
        
        self.stickerMenuSource = StickerMenuDelegate(owner: self)
        
        self.menuView?.delegate = self.stickerMenuSource
        self.menuView?.dataSource = self.stickerMenuSource
        makeFilterList()
//
//        let vip0 = UserDefaults.standard.bool(forKey: "BUY_VIP0")
//        var vip1 = UserDefaults.standard.bool(forKey: "BUY_VIP1")
//        let vip2 = UserDefaults.standard.bool(forKey: "BUY_VIP2")
//        var isVip = false
//        
//       // vip1 = true
//        if(vip1 == true)
//        {
//            self.captureBt?.isHidden = true
//            self.filterBt?.isHidden = true
//            self.stickerBt?.isHidden = true
//            
//            self.stickerView?.isHidden = false
//            self.menuView?.isHidden = false
//            
//            self.menuOrg?.isHidden  = false
//            self.menuItem?.isHidden  = false
//            
//            self.filterMenuView?.isHidden = true
//            self.filterView?.isHidden = true
//            self.swapBt.isHidden = true
//            
//          //  self.segmentedControl.isHidden = true
//            
//            
//            
//            self.indicator?.isHidden = false
//            
//            self.indicator?.startAnimating()
//            
//            self.stickerMenuSource = StickerMenuDelegate(owner: self)
//            
//            self.menuView?.delegate = self.stickerMenuSource
//            self.menuView?.dataSource = self.stickerMenuSource
//            makeFilterList()
//        }
//        else
//        {
//            showStore0(type: 1)
//        }
        
       
    }
    @IBAction func showSticker(){
        
        var vip0 = UserDefaults.standard.bool(forKey: "BUY_VIP0")
        
      //  vip0 = true
          
        if(vip0 == true)
        {
            UIView.animate(withDuration: 0.25) {
                self.bSticker = true
                self.bFilter = false
                
                self.captureBt?.isHidden = true
                self.filterBt?.isHidden = true
                self.stickerBt?.isHidden = true
                
                self.stickerView?.isHidden = false
                self.menuView?.isHidden = false
                
                self.menuOrg?.isHidden  = false
                self.menuItem?.isHidden  = false
                
                self.filterMenuView?.isHidden = true
                self.filterView?.isHidden = true
                
              //  self.segmentedControl.isHidden = true
                
                self.swapBt.isHidden = true
         
                
                self.indicator?.isHidden = false
                
                self.indicator?.startAnimating()
                
                self.stickerMenuSource = StickerMenuDelegate(owner: self)
                
                self.menuView?.delegate = self.stickerMenuSource
                self.menuView?.dataSource = self.stickerMenuSource
                
                
            }
            
            //    self.captureBt?.layer.zPosition = 1000
            
            let user:UserDefaults = UserDefaults.standard
            
            let index:Int = user.integer(forKey: "STICKER_MENU")
           
            
            downloadJSON(url: "http://www.junsoft.org/stickers/live_sticker.json",filename: "live_sticker.json")

        }
        else
        {
            showStore0(type: 0)
        }
            
   
    }
    
    func takePicture0()
    {
           let user:UserDefaults = UserDefaults.standard
                  
           let timerCnt:Int = user.integer(forKey: "SNAPSHOT_TIMER")
               
           
            if( timerCnt > 0)
             {
                let strokeTextAttributes: [NSAttributedString.Key : Any] = [
                    NSAttributedString.Key.strokeColor : UIColor.gray,
                    NSAttributedString.Key.foregroundColor : UIColor.white,
                     NSAttributedString.Key.strokeWidth : -1.0,
                     ]
                 
                 
                 self.displayTitle?.attributedText = NSAttributedString(string:String(timerCnt), attributes: strokeTextAttributes)
                 
                 startTimer();
                 
            
           
            }
           
            else
            {
                videoCamera?.pauseCapture()
            
                var size:CGSize?
                if(ratioMode == 1 )
                {
                    size = CGSize(width: 480, height: 640)
                }
                else if(ratioMode == 2)
                {
                    size = CGSize(width: 480, height: 480)
                }
                else
                {
                    size = CGSize(width: 720, height: 1280)
                    
                }
                if(jFaceLookup?.finalFilter != nil)
                {
                    capturedImage = cropFilter?.getFrameBuffer(jFaceLookup?.finalFilter,size: size!)
                    
                }
                else
                {
                    capturedImage = cropFilter?.getFrameBuffer(cropFilter, size: size!)
                    //   capturedImage = manager.takePicture(videoCamera)
                }
                videoCamera?.resumeCameraCapture()
                performSegue(withIdentifier: "exec_photo", sender: nil)
            }
         
           
       }
       
    @IBAction func takePicture()
    {
        let user:UserDefaults = UserDefaults.standard
        
      
        takePicture0()

        
    }
  
    func showStickerStatic()
    {
            
        downloadJSON(url: stickerJSonURL ,filename: "live_sticker.json")

     
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
                   self.indicator?.stopAnimating()
                                    
                   self.indicator?.isHidden = true
                   
                                    
                   return
               }
                     
               var data:NSData = manager.contents(atPath: pathUrl.path!) as! NSData
             
               if(data.length != 0)
               {
                       do{
                           self.indicator?.stopAnimating()
                           self.indicator?.isHidden = true
                           
                           self.stickers = try JSONSerialization.jsonObject(with: data as Data, options:[]) as? [String: AnyObject] as! NSDictionary
                           
                           
                           //   var array:NSArray = NSArray(objects: "intro_logo")
                           stickerDataSource = StickerDelegate(items:self.stickers!,owner:self)

                        
                           
                           self.stickerView?.delegate = stickerDataSource
                           self.stickerView?.dataSource = stickerDataSource
                     /*
                           self.stickerView?.scrollToItem(at: IndexPath(row: 0, section: 0),
                                                          at: .top,
                                                          animated: true)
                           */
                           
                           self.stickerView?.reloadData()
                           
                           
                       }catch{
                           
                           self.indicator?.stopAnimating()
                           self.indicator?.isHidden = true
                           
                       }
                   }
                   else
                   {
                       self.indicator?.stopAnimating()
                       self.indicator?.isHidden = true
                       
                   }
       
           }
       
           
           
       }
    func downloadSticker(url : String, filename : String, stickerName:String, cell:ThumbCell)
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
                 self.indicator?.stopAnimating()
                                  
                 self.indicator?.isHidden = true
                 
                                  
                 return
             }
                   
             var data:NSData = manager.contents(atPath: pathUrl.path!) as! NSData
           
             if(data.length != 0)
             {
                 cell.indicator?.isHidden = true
                 cell.indicator?.stopAnimating()
            
                 let targetPath = self.documentsDirectoryURL().appendingPathComponent("sticker")! as NSURL
                 
                 var ret =  SSZipArchive.unzipFile(atPath: pathUrl.path!, toDestination: targetPath.path!)
                 
                 if(self.maskTypeName != "none")
                 {
                     self.setStickerFilter(name: stickerName,sceneName: "FaceMask")
                     
                 }
                 else
                 {
                     self.setStickerFilter(name: stickerName,sceneName: "LiveSticker")
                     
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
               
             }
              
     
         }
     
       
     }
       func downloadItemJSON(url : String, filename : String, type:Int)
       {
           /*
           let request = URLRequest( url: URL(string: url)!)
           let session = AFHTTPSessionManager()
           
           let pathUrl = dataFileURL(fileName: filename)
           
           let manager = FileManager.default
           
           do{
               try manager.removeItem(at:  pathUrl as URL)
               
           } catch {
               print("Error: \(error.localizedDescription)")
           }
           
           
           let downloadTask = session.downloadTask(with: request, progress: nil, destination: {(file, responce) in (pathUrl as URL)},
                                                   completionHandler:
               {
                   response, localfile, error in
                   
                   if( error == nil )
                   {
                       
                       let data:NSData = manager.contents(atPath: pathUrl.path!) as! NSData
                       if(data.length != 0)
                       {
                           do{
                               self.indicator?.stopAnimating()
                               self.indicator?.isHidden = true
                               
                               self.itemAccesorys = try JSONSerialization.jsonObject(with: data as Data, options:[]) as? [String: AnyObject] as! NSDictionary
                               
                               
                               
                               self.dataSourceItem = ItemDelegate(items:self.itemAccesorys!,owner:self, type:type)
                               
                               self.itemMenuView?.delegate = self.dataSourceItem
                               self.itemMenuView?.dataSource = self.dataSourceItem
                               
                               self.itemMenuView?.scrollToItem(at: IndexPath(row: 0, section: 0),
                                                               at: .left,
                                                               animated: true)
                               
                               
                               self.itemMenuView?.reloadData()
                               
                               
                           }catch{
                               
                           }
                       }
                       
                   }
                   else{
                       self.indicator?.stopAnimating()
                       self.indicator?.isHidden = true
                       self.errorMsg()
                       
                   }
                   
                   
                   
                   
           })
           
           downloadTask.resume()
            */
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
                      
                           maskDataSource = MaskItemSource()
                           
                         
                           maskDataSource.parentCon = self
                           maskDataSource.initData(data: self.itemAccesorys!)
                           self.stickerView?.delegate = maskDataSource
                           self.stickerView?.dataSource = maskDataSource
                     
                           
                           self.stickerView?.reloadData()
                      
                           
                           
                           
                           
                       }catch{
                           
                         
                           
                       }
                   }
                   
       
           }
       
       }
    func processMask(item:String, cell:ThumbCell)
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
                     cell.indicator?.isHidden = true
                     cell.indicator?.stopAnimating()
                  
                     self.setStickerFilter(name: item, sceneName: "FaceMask")
                   
                     self.jFaceLookup?.finalFilter?.setInputRotation(GPUImageRotationMode(rawValue: 0), at: Int(kGPUImageFlipHorizonal.rawValue))
               
                     
                     
                 }
        }
        
    }
    func downloadMask(url : String, filename : String, stickerName:String, cell:ThumbCell)
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
           
       }
    func processSticker(item:String, cell:ThumbCell)
       {
           print("processSticker:%@",item)
           let zipURL:String = String(format: "http://www.junsoft.org/zip/%@.zip", item as CVarArg)
           let zipName:String = String(format: "%@.zip", item as CVarArg)
           
           let pathUrl = dataFileURL(fileName: zipName)
           
           bBeauty = true
           
           maskTypeName = "none"
           frameCount = 0
           
           scene?.glassesName = "none"
           scene?.hatName = "none"
           scene?.earringName = "none"
           scene?.mustacheName = "none"
           
           
           
           
           
           let manager = FileManager.default
           if(!manager.fileExists(atPath: pathUrl.path!))
           {
               downloadSticker(url: zipURL,filename: zipName, stickerName: item, cell: cell)
           }
           else
           {
               setStickerFilter(name: item, sceneName: "LiveSticker")
               cell.indicator?.isHidden = true
               cell.indicator?.stopAnimating()
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
           
       }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
            super.touchesEnded(touches, with: event)
            let touch = touches.first
            let position = touch?.location(in: self.view)
            
            var rect:CGRect = stickerView!.frame;
         //   let rectFilterMenu:CGRect = filterMenuView!.frame;
         //   let rectStickerMenu:CGRect = menuView!.frame;
         //   var rect2:CGRect = filterView!.frame;
          //  rect2.size.height = rectFilterMenu.size.height + rect2.size.height
          //  rect2.origin.y = rectFilterMenu.origin.y
            
          //  rect.size.height = rectStickerMenu.size.height + rect.size.height
          //  rect.origin.y = rectStickerMenu.origin.y
        if(stickerView?.isHidden == false)
        {
            UIView.animate(withDuration: 0.25) {
                self.stickerView?.isHidden = true
                self.captureBt?.isHidden = false
                self.stickerBt?.isHidden = false
                self.filterBt?.isHidden = false
                self.swapBt.isHidden = false
         
            }
        }
            /*
            UIView.animate(withDuration: 0.25) {
                if(self.bSticker! == true && !rect.contains(position!))
                {
                    self.stickerView?.isHidden = true
                    self.menuView?.isHidden = true
                //    self.filterView?.isHidden = true
               //     self.filterMenuView?.isHidden = true
                    self.menuOrg?.isHidden  = true
                    self.menuItem?.isHidden  = true
                    
                    self.itemMenuView?.isHidden  = true
                    
                    self.captureBt?.isHidden = false
                    self.stickerBt?.isHidden = false
                    self.filterBt?.isHidden = false
                    self.bSticker = false
                    self.bFilter = false
                   // self.noFilter?.isHidden  = true
                    
                    
                }
                
                if(self.bFilter! == true && !rect2.contains(position!))
                {
                    self.stickerView?.isHidden = true
                    self.menuView?.isHidden = true
                 //   self.filterView?.isHidden = true
                    self.menuOrg?.isHidden  = true
                    self.menuItem?.isHidden  = true
                  //  self.noFilter?.isHidden  = true
                    
                    self.filterMenuView?.isHidden = true
                    self.itemMenuView?.isHidden  = true
                    
                    self.captureBt?.isHidden = false
                    self.stickerBt?.isHidden = false
                    self.filterBt?.isHidden = false
                    
                    self.bSticker = false
                    self.bFilter = false
                    
                }
                
             //   self.segmentedControl.isHidden = false
                
            }
            
            UIView.animate(withDuration: 0.25) {
                let trans = CGAffineTransform(translationX: 0,y: 0);
                self.captureBt?.transform = trans
               // self.ring1.transform = trans
            }
            */
            
            
        }
    
    
    func pixelBuffer (forImage image:CGImage) -> CVPixelBuffer? {
           
           
           let frameSize = CGSize(width: image.width, height: image.height)
           
           var pixelBuffer:CVPixelBuffer? = nil
           let status = CVPixelBufferCreate(kCFAllocatorDefault, Int(frameSize.width), Int(frameSize.height), kCVPixelFormatType_32BGRA , nil, &pixelBuffer)
           
           if status != kCVReturnSuccess {
               return nil
               
           }
           
           CVPixelBufferLockBaseAddress(pixelBuffer!, CVPixelBufferLockFlags.init(rawValue: 0))
           let data = CVPixelBufferGetBaseAddress(pixelBuffer!)
           let rgbColorSpace = CGColorSpaceCreateDeviceRGB()
           let bitmapInfo = CGBitmapInfo(rawValue: CGBitmapInfo.byteOrder32Little.rawValue | CGImageAlphaInfo.premultipliedFirst.rawValue)
           let context = CGContext(data: data, width: Int(frameSize.width), height: Int(frameSize.height), bitsPerComponent: 8, bytesPerRow: CVPixelBufferGetBytesPerRow(pixelBuffer!), space: rgbColorSpace, bitmapInfo: bitmapInfo.rawValue)
           
           
           context?.draw(image, in: CGRect(x: 0, y: 0, width: image.width, height: image.height))
           
           CVPixelBufferUnlockBaseAddress(pixelBuffer!, CVPixelBufferLockFlags(rawValue: 0))
           
           return pixelBuffer
           
       }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "exec_photo"{
            
           
            if let detail = segue.destination as? PhotoViewController {
                detail.image = capturedImage
                detail.ratioMode = ratioMode!
             
            }
        }
    }
}

extension ViewController : GPUImageVideoCameraDelegate{
//    func convertImageToSampleBuffer(image: UIImage) -> CMSampleBuffer? {
        
        
//        if let pixelBuffer = pixelBuffer(from: (image.cgImage!)) {
//              var videoInfo: CMVideoFormatDescription?
//            CMVideoFormatDescriptionCreateForImageBuffer(allocator: nil,
//                                                         imageBuffer: pixelBuffer,
//                                                         formatDescriptionOut: &videoInfo)
//            CMSampleBufferCreateForImageBuffer(allocator: kCFAllocatorDefault,
//                                               imageBuffer: pixelBuffer,
//                                               dataReady: true,
//                                               makeDataReadyCallback: nil,
//                                               refcon: nil,
//                                               formatDescription: videoInfo!,
//                                               sampleTiming: &timingInfo,
//                                               sampleBufferOut: &sampleBuffer)
//        }
        // Create a CGImage from the UIImage
//        guard let cgImage = image.cgImage else {
//            return nil
//        }
//
//        // Calculate the image size
//        let width = cgImage.width
//        let height = cgImage.height
//
//        // Create a dictionary with the pixel format type
//        let pixelBufferAttributes: [String: Any] = [
//            kCVPixelBufferCGImageCompatibilityKey as String: true,
//            kCVPixelBufferCGBitmapContextCompatibilityKey as String: true,
//            kCVPixelBufferPixelFormatTypeKey as String: kCVPixelFormatType_32ARGB
//        ]
//
//        var pixelBuffer: CVPixelBuffer?
//        let status = CVPixelBufferCreate(kCFAllocatorDefault,
//                                         width,
//                                         height,
//                                         kCVPixelFormatType_32ARGB,
//                                         pixelBufferAttributes as CFDictionary,
//                                         &pixelBuffer)
//        guard status == kCVReturnSuccess, let pixelBuffer = pixelBuffer else {
//            return nil
//        }
//
//        CVPixelBufferLockBaseAddress(pixelBuffer, CVPixelBufferLockFlags(rawValue: 0))
//
//        // Create a CGContext to draw the image
//        let context = CGContext(data: CVPixelBufferGetBaseAddress(pixelBuffer),
//                                width: width,
//                                height: height,
//                                bitsPerComponent: 8,
//                                bytesPerRow: CVPixelBufferGetBytesPerRow(pixelBuffer),
//                                space: CGColorSpaceCreateDeviceRGB(),
//                                bitmapInfo: CGImageAlphaInfo.premultipliedFirst.rawValue)!
//
//        // Draw the image into the CGContext
//        context.draw(cgImage, in: CGRect(x: 0, y: 0, width: width, height: height))
//
//        CVPixelBufferUnlockBaseAddress(pixelBuffer, CVPixelBufferLockFlags(rawValue: 0))
//
//        // Create a CMSampleBuffer from the CVPixelBuffer
//        var sampleBuffer: CMSampleBuffer?
//        var timingInfo = CMSampleTimingInfo(duration: CMTimeMake(value: 1, timescale: 30), presentationTimeStamp: CMTime.zero, decodeTimeStamp: CMTime.invalid)
//        let status2 = CMSampleBufferCreateForImageBuffer(allocator: kCFAllocatorDefault,
//                                                         imageBuffer: pixelBuffer,
//                                                         dataReady: true,
//                                                         makeDataReadyCallback: nil,
//                                                         refcon: nil,
//                                                         formatDescription: CMTimeRangeMake(start: CMTime.zero, duration: CMTimeMake(value: 1, timescale: 30)) as! CMVideoFormatDescription,
//                                                         sampleTiming: &timingInfo,
//                                                         sampleBufferOut: &sampleBuffer)
//
//        guard status2 == noErr, let buffer = sampleBuffer else {
//            return nil
//        }
//
//        return buffer
//    }
    func willOutputSampleBuffer(_ sampleBuffer: CMSampleBuffer!) {
        
       
        
        var deviceOrientation:UIDeviceOrientation
        deviceOrientation =  UIDevice.current.orientation;
        
     
        self.sampleBuffer = sampleBuffer
//        processPhoto(img: UIImage(named: "test")!)
//        self.sampleBuffer = convertImageToSampleBuffer(image: UIImage(named: "test")!)
//        let pixelBuffer = ImageUtility.buffer(from: UIImage(named: "d0")!)
              
//        func convertUIImageToCMSampleBuffer(image: UIImage)
        scene!.processBuffer(self.sampleBuffer, orientation: Int32(deviceOrientation.rawValue), front: bFront!)

        
        isCameraOn = true
        
        
    }
    
//    override var prefersStatusBarHidden: Bool {
//        return true
//    }
}
