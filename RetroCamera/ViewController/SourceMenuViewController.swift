//
//  SourceMenuViewController.swift
//  RetroCamera
//
//  Created by N4225 on 2023/04/10.
//

import UIKit
import Photos

class SourceMenuViewController: UIViewController,UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    var sampleBuffer: CMSampleBuffer?
    var scene:Scene?
    var jFaceLookup:LookupFilterGroup?
  
    func initSDK()
    {
        
//         sceneType = "none"
//
//        stickerTypeName = "none"
//
//        self.filterName = "none"
//
//        maskTypeName = "none"
//
//        maskOldTypeName = "none"
//
//         isRecording = false
//        bFront = CameraAPI.shared.isFront()
//        self.scene?.earringName = "none"
//
//        self.scene?.hatName = "none"
//
//        self.scene?.glassesName = "none"
//
//        self.scene?.mustacheName = "none"
//        self.videoCamera?.delegate = self
//        videoCamera = CameraAPI.shared.getVideoCamera()

        scene = CameraAPI.shared.getScene()
        
        jFaceLookup = LookupFilterGroup()
      
      
    
    }
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
        
        var deviceOrientation:UIDeviceOrientation
        deviceOrientation =  UIDevice.current.orientation;
     
        scene!.processBuffer(sampleBuffer, orientation: Int32(deviceOrientation.rawValue), front: true)

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
    override func viewDidLoad() {
        super.viewDidLoad()

      
        initSDK()
        
    }
    
    @IBAction func Close(){
        dismiss(animated: false)
    }


    @IBAction func processCamera(){
        showCameraView()
    }
    
    @IBAction func processGallery(){
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.allowsEditing = false
        imagePicker.sourceType = .photoLibrary
        present(imagePicker, animated: true, completion: nil)

    }
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        if let photo = info[.originalImage] as? UIImage {
       
            let captureImg = resizePhoto(photo, outputSize: CGSize(width: 720, height: 1280))
            picker.dismiss(animated: true, completion: nil)
//
            showEdit(img: captureImg!)
       }
        
    }
    func showEdit(img:UIImage){
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        
        let vc = storyboard.instantiateViewController(withIdentifier: "EditViewController") as! EditViewController
      
        vc.image = img

        let transition = CATransition()
        transition.duration = 0.3
        transition.type = CATransitionType(rawValue: "fade")
        self.present(vc, animated: true, completion: nil)

    }
}
