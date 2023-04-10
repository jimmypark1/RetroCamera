//
//  PhotoViewController.swift
//  RetroCamera
//
//  Created by Junsung Park on 2022/04/21.
//

import UIKit
import TTGSnackbar
import GoogleMobileAds


class PhotoViewController: UIViewController {

    @IBOutlet weak var imgView:UIImageView!
    @IBOutlet weak var bottom:NSLayoutConstraint!
    @IBOutlet weak var shareBt:UIButton!
   
    var image:UIImage!
    var ratioMode:Int = 0
    @IBOutlet weak var  bannerView: GADBannerView!
   
    var sampleBuffer: CMSampleBuffer?

    
    func processPhoto(img:UIImage){
        
        var photo = img//UIImage(named: "girl")
//        photo = resizePhoto(photo, outputSize: CGSize(width: 720, height: 1280))!
        //  self.arView.cancelSwitchEffect()
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
        
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.enqueueFrame(sampleBuffer)
        }
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
    
    func CropImage( image:UIImage , cropRect:CGRect) -> UIImage
    {
            UIGraphicsBeginImageContextWithOptions(cropRect.size, false, 0);
            let context = UIGraphicsGetCurrentContext();
            
          //  context?.translateBy(x: 0.0, y: image.size.height);
            context?.draw(image.cgImage!, in: CGRect(x:0, y:0, width:image.size.width, height:image.size.height), byTiling: false);
            context?.clip(to: [cropRect]);
          //context?.translateBy(x: 0.0, y: image.size.height);
       //   context?.scaleBy(x: 1.0, y: -1.0);
     
            let croppedImage = UIGraphicsGetImageFromCurrentImageContext();
            UIGraphicsEndImageContext();
        
            return croppedImage!;
    }
    override func viewDidLoad() {
        super.viewDidLoad()

        imgView.image = image
//        
//        if(ratioMode == 1)
//        {
//            let width = UIScreen.main.bounds.size.width
//            let height = width * 4.0 / 3.0
//            bottom.constant = UIScreen.main.bounds.size.height - height
//        }
//        
//        else
//        {
//            let width = UIScreen.main.bounds.size.width
//            let height = width * 3.0 / 3.0
//            let img = image
//            bottom.constant = UIScreen.main.bounds.size.height - height
//        }
//        
        bannerView.adUnitID = "ca-app-pub-7915959670508279/8457567696"
        bannerView.rootViewController = self
        bannerView.load(GADRequest())
    }
    @IBAction func share()
    {
        JunSoftUtil.shared.isDetail = true

            let imageToShare = [image ]
            let activityViewController = UIActivityViewController(activityItems: imageToShare, applicationActivities: nil)
            activityViewController.popoverPresentationController?.sourceView = shareBt // so that iPads won't crash

            // exclude some activity types from the list (optional)
            activityViewController.excludedActivityTypes = [UIActivity.ActivityType.airDrop,UIActivity.ActivityType.copyToPasteboard,UIActivity.ActivityType.print,UIActivity.ActivityType.addToReadingList,UIActivity.ActivityType.assignToContact,UIActivity.ActivityType.openInIBooks]

            // present the view controller
            self.present(activityViewController, animated: true, completion: nil)
    }
    @IBAction func close()
    {
        dismiss(animated: true, completion: nil)
    }
    
    open override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return UIInterfaceOrientationMask.portrait
    }
    @IBAction func save()
    {
      
        JunSoftUtil.shared.isDetail = true

        let snackbar = TTGSnackbar(message: "Saved!!!", duration: .middle)

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
         
        if(ratioMode == 2)
        {
            let size0 = self.image.size
        
            let width = size0.width
         
            let cropRect = CGRect(x: 0, y: size0.height - size0.width , width: width, height: width)
           // let crop = CropImage(image: self.image,cropRect: cropRect)
       
            let sourceCGImage = image.cgImage!
            let croppedCGImage = sourceCGImage.cropping(
                to: cropRect
            )!
            let croppedImage = UIImage(
                cgImage: croppedCGImage,
                scale: image.imageRendererFormat.scale,
                orientation: image.imageOrientation
            )
            let imgData = image.pngData()
              
            UIImageWriteToSavedPhotosAlbum(UIImage(data: imgData!)!, nil, nil, nil);
                
        }
        else
        {
            let size0 = self.image.size
        
            let width = size0.width
            let height = size0.width * 4 / 3

            let cropRect = CGRect(x: 0, y: size0.height - height , width: width, height: height)
          //  let crop = CropImage(image: self.image,cropRect: cropRect)
       
            
            let imgData = image.pngData()
              
            UIImageWriteToSavedPhotosAlbum(UIImage(data: imgData!)!, nil, nil, nil);
                
        }
   
          
              
    }
   
    

}
