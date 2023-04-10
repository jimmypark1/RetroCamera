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
