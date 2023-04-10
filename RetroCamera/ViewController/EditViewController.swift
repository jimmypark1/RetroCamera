//
//  EditViewController.swift
//  RetroCamera
//
//  Created by N4225 on 2023/04/10.
//

import UIKit
import Alamofire
import SSZipArchive
import Accelerate.vImage
import GPUImage
import AVFoundation


class EditViewController: UIViewController, GPUImageVideoCameraDelegate {

    @IBOutlet weak var imgView:UIImageView!
    @IBOutlet weak var renderView:GPUImageView!
    @IBOutlet weak var collectionView:UICollectionView!
   
    var maskSource = MaskDemoItemSource()
    let itemSource:ItemDataSource = ItemDataSource()
  
    var datas:Array<String> = Array<String>()
  
    var image:UIImage!
    var sampleBuffer0: CMSampleBuffer?
    var scene:Scene?
    var jFaceLookup:LookupFilterGroup?
    var itemAccesorys:NSDictionary?
    var videoCamera:GPUImageStillCamera?
    var filter:GPUImageFilter?

    
    func willOutputSampleBuffer(_ sampleBuffer: CMSampleBuffer!) {
        
       
        
        var deviceOrientation:UIDeviceOrientation
        deviceOrientation =  UIDevice.current.orientation;
       // processPhoto(img: image)
        let buffer = convertToYUV2(image: image)
//
    
        processPhoto(img: image)
        scene?.processBuffer(sampleBuffer0, orientation: Int32(deviceOrientation.rawValue), front: true)
    
        
        
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        initSDK()
      //  processPhoto(img: image)
   
      
        
       // imgView.image = image
    }
    func initSDK()
    {
        


        scene = CameraAPI.shared.getScene()
        self.scene?.earringName = "none"
    
        self.scene?.hatName = "none"
       
        self.scene?.glassesName = "none"
      
        self.scene?.mustacheName = "none"
    
        videoCamera = CameraAPI.shared.getVideoCamera()
   
        jFaceLookup = LookupFilterGroup()

        filter = GPUImageFilter()
        renderView?.fillMode = kGPUImageFillModePreserveAspectRatioAndFill;
        videoCamera?.delegate = self
 
        filter?.addTarget(renderView)
        videoCamera?.addTarget(filter )
        videoCamera?.startCapture()

//        processPhoto(img: image)
//        var deviceOrientation:UIDeviceOrientation
//        deviceOrientation =  UIDevice.current.orientation;
//
//        scene?.processBuffer(sampleBuffer0, orientation: Int32(deviceOrientation.rawValue), front: true)
//
       // renderView
         
//        scene?.processBuffer(sampleBuffer, orientation: Int32(deviceOrientation.rawValue), front: true)
////
//        let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer0!)
//
//        // CVPixelBuffer에서 CIImage 생성
//        let ciImage = CIImage(cvPixelBuffer: pixelBuffer!)
//
//        // UIImage로 변환
//        let context = CIContext(options: nil)
//        let cgImage = context.createCGImage(ciImage, from: ciImage.extent)
//        let image0 = UIImage(cgImage: cgImage!)
//
//
//        imgView.image = image0
        
//        let json = "http://www.junsoft.org/mask/mask.json"
//
//        downloadMaskJSON(url: json,filename: "mask.json")
  
        let json = "http://www.junsoft.org/stickers/live_sticker.json"
       
      
        downloadJSON(url: json,filename: "live_sticker.json")
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
                        
                           itemSource.parentCon2 = self
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
 
    func processPhoto(img:UIImage){
        
        var photo = img//UIImage(named: "girl")
//        photo = resizePhoto(photo, outputSize: CGSize(width: 720, height: 1280))!
        //  self.arView.cancelSwitchEffect()
        if let pixelBuffer = convertToYUV2(image: photo) {
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
                                               sampleBufferOut: &sampleBuffer0)
            
            enqueueFrame(sampleBuffer0!)
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
//    func convertUIImageToYUV(image: UIImage) -> UnsafeMutableRawPointer? {
//        // UIImage를 GPUImagePicture으로 변환합니다.
//        let picture = GPUImagePicture(image: image)
//
//        // GPUImageColorConversionFilter를 생성합니다.
//        let colorConversionFilter = GPUImageColorConversionFilter()
//
//        // 프로세싱할 output 형식을 kCVPixelFormatType_420YpCbCr8BiPlanarFullRange로 설정합니다.
//        let format = kCVPixelFormatType_420YpCbCr8BiPlanarFullRange
//        colorConversionFilter.setOutputColorSpace(GPUImageColorspaceConversion(renderingPixelFormat: format))
//
//        // 필터 연결
//        picture.addTarget(colorConversionFilter)
//
//        // 필터 처리 시작
//        colorConversionFilter.useNextFrameForImageCapture()
//        picture.processImage()
//
//        // 필터 캡쳐
//        let output = colorConversionFilter.gpuImageFramebuffer?.raw()
//
//        return output
//    }
    func convertToYUV2(image: UIImage) -> CVPixelBuffer?  {
        // Create CIImage from UIImage
        guard let ciImage = CIImage(image: image) else {
            return nil
        }
        
        // Create CIContext
        let context = CIContext(options: [.useSoftwareRenderer: false])
        
        // Create pixel buffer attributes
        let width = Int(image.size.width)
        let height = Int(image.size.height)
        let pixelBufferAttributes: [String: Any] = [
            kCVPixelBufferWidthKey as String: width,
            kCVPixelBufferHeightKey as String: height,
            kCVPixelBufferPixelFormatTypeKey as String: kCVPixelFormatType_420YpCbCr8BiPlanarVideoRange
        ]
        
        // Create pixel buffer
        var pixelBuffer: CVPixelBuffer?
        let status = CVPixelBufferCreate(kCFAllocatorDefault, width, height, kCVPixelFormatType_420YpCbCr8BiPlanarVideoRange as OSType, pixelBufferAttributes as CFDictionary, &pixelBuffer)
        guard status == kCVReturnSuccess, let unwrappedPixelBuffer = pixelBuffer else {
            return nil
        }
        
        // Render CIImage to pixel buffer
        context.render(ciImage, to: unwrappedPixelBuffer)
        
        // Lock pixel buffer and get Y and UV planes
        CVPixelBufferLockBaseAddress(unwrappedPixelBuffer, CVPixelBufferLockFlags(rawValue: 0))
        
        let yPlaneAddress = CVPixelBufferGetBaseAddressOfPlane(unwrappedPixelBuffer, 0)
        let yPlaneLength = CVPixelBufferGetBytesPerRowOfPlane(unwrappedPixelBuffer, 0) * CVPixelBufferGetHeightOfPlane(unwrappedPixelBuffer, 0)
        let yData = Data(bytes: yPlaneAddress!, count: yPlaneLength)
        
        let uvPlaneAddress = CVPixelBufferGetBaseAddressOfPlane(unwrappedPixelBuffer, 1)
        let uvPlaneLength = CVPixelBufferGetBytesPerRowOfPlane(unwrappedPixelBuffer, 1) * CVPixelBufferGetHeightOfPlane(unwrappedPixelBuffer, 1)
        let uvData = Data(bytes: uvPlaneAddress!, count: uvPlaneLength)
        
        // Unlock pixel buffer
        CVPixelBufferUnlockBaseAddress(unwrappedPixelBuffer, CVPixelBufferLockFlags(rawValue: 0))
        
        return unwrappedPixelBuffer
    }
    
    func convertToYUV(image: UIImage) -> (yData: Data, uvData: Data)? {
        // Create CIImage from UIImage
        guard let ciImage = CIImage(image: image) else {
            return nil
        }
        
        // Create CIContext
        let context = CIContext(options: [.useSoftwareRenderer: false])
        
        // Create pixel buffer attributes
        let width = Int(image.size.width)
        let height = Int(image.size.height)
        let pixelBufferAttributes: [String: Any] = [
            kCVPixelBufferWidthKey as String: width,
            kCVPixelBufferHeightKey as String: height,
            kCVPixelBufferPixelFormatTypeKey as String: kCVPixelFormatType_420YpCbCr8BiPlanarVideoRange
        ]
        
        // Create pixel buffer
        var pixelBuffer: CVPixelBuffer?
        let status = CVPixelBufferCreate(kCFAllocatorDefault, width, height, kCVPixelFormatType_420YpCbCr8BiPlanarVideoRange as OSType, pixelBufferAttributes as CFDictionary, &pixelBuffer)
        guard status == kCVReturnSuccess, let unwrappedPixelBuffer = pixelBuffer else {
            return nil
        }
        
        // Render CIImage to pixel buffer
        context.render(ciImage, to: unwrappedPixelBuffer)
        
        // Lock pixel buffer and get Y and UV planes
        CVPixelBufferLockBaseAddress(unwrappedPixelBuffer, CVPixelBufferLockFlags(rawValue: 0))
        
        let yPlaneAddress = CVPixelBufferGetBaseAddressOfPlane(unwrappedPixelBuffer, 0)
        let yPlaneLength = CVPixelBufferGetBytesPerRowOfPlane(unwrappedPixelBuffer, 0) * CVPixelBufferGetHeightOfPlane(unwrappedPixelBuffer, 0)
        let yData = Data(bytes: yPlaneAddress!, count: yPlaneLength)
        
        let uvPlaneAddress = CVPixelBufferGetBaseAddressOfPlane(unwrappedPixelBuffer, 1)
        let uvPlaneLength = CVPixelBufferGetBytesPerRowOfPlane(unwrappedPixelBuffer, 1) * CVPixelBufferGetHeightOfPlane(unwrappedPixelBuffer, 1)
        let uvData = Data(bytes: uvPlaneAddress!, count: uvPlaneLength)
        
        // Unlock pixel buffer
        CVPixelBufferUnlockBaseAddress(unwrappedPixelBuffer, CVPixelBufferLockFlags(rawValue: 0))
        
        return (yData: yData, uvData: uvData)
    }
    func pixelBuffer(from uiImage: UIImage) -> CVPixelBuffer? {
        
        guard let cgImage = uiImage.cgImage else {
            return nil
        }

        let width = Int(uiImage.size.width)
        let height = Int(uiImage.size.height)
        var pixelBuffer: CVPixelBuffer?
        let status = CVPixelBufferCreate(kCFAllocatorDefault, width, height, kCVPixelFormatType_32ARGB, nil, &pixelBuffer)
        guard let buffer = pixelBuffer, status == kCVReturnSuccess else {
            return nil
        }

        // CGContext 생성
        CVPixelBufferLockBaseAddress(buffer, CVPixelBufferLockFlags(rawValue: 0))
        let context = CGContext(data: CVPixelBufferGetBaseAddress(buffer), width: width, height: height, bitsPerComponent: 8, bytesPerRow: CVPixelBufferGetBytesPerRow(buffer), space: CGColorSpaceCreateDeviceRGB(), bitmapInfo: CGImageAlphaInfo.noneSkipFirst.rawValue)!
        context.draw(cgImage, in: CGRect(x: 0, y: 0, width: width, height: height))

        // 픽셀 데이터 추출
        let yuvBuffer = UnsafeMutablePointer<UInt8>.allocate(capacity: width * height * 3 / 2)
        let yBuffer = yuvBuffer
        let uBuffer = yuvBuffer + width * height
        let vBuffer = uBuffer + (width * height / 4)
        let srcBuffer = CVPixelBufferGetBaseAddressOfPlane(buffer, 0)
        let srcStride = CVPixelBufferGetBytesPerRowOfPlane(buffer, 0)
        let dstStride = Int32(width)

        // ARGB to YUV 변환
//        vImageConvert_ARGB8888ToYpCbCr420BiPlanar(srcBuffer!, srcStride, yBuffer, dstStride, uBuffer, dstStride / 2, vBuffer, dstStride / 2, UInt32(width), UInt32(height), kvImageNoFlags)

        CVPixelBufferUnlockBaseAddress(buffer, CVPixelBufferLockFlags(rawValue: 0))

        
        return buffer
        
    }
    @IBAction func Close(){
        dismiss(animated: false)
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
                        maskSource.parentCon2 = self
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
    func processMask(item:String, cell:ItemCell)
    {
   
        
        DispatchQueue.main.async{ [self] in
                 
                 
                 let zipURL:String = String(format: "http://www.junsoft.org/mask/%@.zip", item as CVarArg)
                 let zipName:String = String(format: "%@.zip", item as CVarArg)
                 
                 let pathUrl = self.dataFileURL(fileName: zipName)
                 
                 let manager = FileManager.default
              //   self.stickerTypeName = "none"
                 
                 //logEvent
              
                 if(!manager.fileExists(atPath: pathUrl.path!))
                 {
//                     self.bBeauty = false
                     
                     self.downloadMask(url: zipURL,filename: zipName, stickerName: item, cell:cell)
                 }
                 else
                 {
//                     let picture = GPUImagePicture(image: image)
//
                        

                     self.setStickerFilter(name: item, sceneName: "FaceMask")
                     
                     
                     let picture = GPUImagePicture(image: image)

                 //    processPhoto(img: image)
                     
//                     let filter = GPUImageFilter()
//
//                     scene?.processBuffer(sampleBuffer, orientation: Int32(deviceOrientation.rawValue), front: true)
//
//                   //  jFaceLookup?.addTarget(renderView)
//
//                     picture?.addTarget(jFaceLookup)
//                     jFaceLookup!.useNextFrameForImageCapture()
//                     picture?.processImage()
//                     let filteredImage = jFaceLookup!.imageFromCurrentFramebuffer()
//
//
//                     imgView.image = filteredImage
                 
                     
                     
                      // 필터 적용
//                      picture?.addTarget(jFaceLookup)
//                     jFaceLookup!.useNextFrameForImageCapture()
//                      picture?.processImage()
//                      let filteredImage = jFaceLookup!.imageFromCurrentFramebuffer()
//
//                      // 필터 적용된 UIImage를 저장
//                      UIImageWriteToSavedPhotosAlbum(filteredImage!, nil, nil, nil)
                   
                     self.jFaceLookup?.finalFilter?.setInputRotation(GPUImageRotationMode(rawValue: 0), at: Int(kGPUImageFlipHorizonal.rawValue))
               
                     
                     
                 }
        }
        
    }
    func imageFromSampleBuffer(sampleBuffer: CMSampleBuffer) -> UIImage? {
        guard let imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else {
            return nil
        }
        
        CVPixelBufferLockBaseAddress(imageBuffer, CVPixelBufferLockFlags(rawValue: 0))
        
        let baseAddress = CVPixelBufferGetBaseAddress(imageBuffer)
        let bytesPerRow = CVPixelBufferGetBytesPerRow(imageBuffer)
        let width = CVPixelBufferGetWidth(imageBuffer)
        let height = CVPixelBufferGetHeight(imageBuffer)
        
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let bitmapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.noneSkipFirst.rawValue | CGBitmapInfo.byteOrder32Little.rawValue)
        let context = CGContext(data: baseAddress, width: width, height: height, bitsPerComponent: 8, bytesPerRow: bytesPerRow, space: colorSpace, bitmapInfo: bitmapInfo.rawValue)
        
        guard let quartzImage = context?.makeImage() else {
            return nil
        }
        
        CVPixelBufferUnlockBaseAddress(imageBuffer, CVPixelBufferLockFlags(rawValue: 0))
        
        let image = UIImage(cgImage: quartzImage)
        
        return image
    }
    func setStickerFilter(name:String, sceneName:String)
    {
       
          self.scene?.earringName = "none"
      
          self.scene?.hatName = "none"
         
          self.scene?.glassesName = "none"
         
          self.scene?.mustacheName = "none"
//        bBigEyes = true
//        bVline = true
//        ratioMode = 1
//        print("bOpenEyes: \(bOpenEyes)")
//
        if ((  filter != nil) || jFaceLookup != nil) {
            videoCamera?.removeAllTargets()
            filter?.removeAllTargets()
            jFaceLookup?.removeAllTargets()
            jFaceLookup?.removeAll()
        
            //  contrastFilter?.removeAllTargets()

        }
        
//        bOpenEyes = true
        
        scene?.initWithScene2(sceneName, filterName: name, mirroed: true, resType: 0, vline:true, openEye: false, bigEye: true)

     
            
            
//            filter = scene
            
       
//            renderView?.fillMode = kGPUImageFillModePreserveAspectRatioAndFill;
//
//            exportUrl = documentsDirectoryURL().appendingPathComponent("test4.m4v")! as NSURL
//
//            let fileManaer =  FileManager.default
//            if(fileManaer.fileExists(atPath: (exportUrl?.path!)!))
//            {
//                do{
//                    try    fileManaer.removeItem(at: exportUrl as! URL)
//
//
//                } catch {
//                    print("Error: \(error.localizedDescription)")
//                }
//            }
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
        
//        processPhoto(img: image)
//
//        var deviceOrientation:UIDeviceOrientation
//        deviceOrientation =  UIDevice.current.orientation;
//
//        scene?.processBuffer(sampleBuffer, orientation: Int32(deviceOrientation.rawValue), front: true)
//
//        let picture = GPUImagePicture(image: image)
        scene?.initWithScene2(sceneName, filterName: name, mirroed: true, resType: 0, vline:true, openEye: false, bigEye: true)

        jFaceLookup?.useNextFrameForImageCapture()
       
        jFaceLookup?.processFilter("none", scene: scene, data:nil,beauty: true, square: 0)
        
        
        jFaceLookup!.useNextFrameForImageCapture()
        jFaceLookup?.addTarget(renderView)
        videoCamera?.addTarget(jFaceLookup )
        
   
    videoCamera?.resumeCameraCapture()
    videoCamera?.delegate = self
    videoCamera?.startCapture()
  
    
       // scene?.getFrameBuffer(<#T##GPUImageFilter#>, size: <#T##CGSize#>)
     

   
        print("jFaceLookup")
        
   //    videoCamera?.addTarget(jFaceLookup )

//        var deviceOrientation:UIDeviceOrientation
//        deviceOrientation =  UIDevice.current.orientation;
//
//
//        scene?.processBuffer(sampleBuffer, orientation: Int32(deviceOrientation.rawValue), front: true)
//         let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer!)
//

//
//
//        let picture = GPUImagePicture(image: image)
//
//        // 필터 적용
//        picture!.addTarget(jFaceLookup!.finalFilter)
//        jFaceLookup!.finalFilter!.useNextFrameForImageCapture()
//        picture!.processImage()
//
//        // 필터가 적용된 이미지
//        let filteredImage = jFaceLookup!.finalFilter!.imageFromCurrentFramebuffer()

//        let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer!)
        // CVPixelBuffer에서 CIImage 생성
       
       
        

            
       //     jFaceLookup?.addTarget(movieWriter)
            
//            jFaceLookup?.addTarget(renderView)
//            videoCamera?.addTarget(jFaceLookup )
//
//
//        videoCamera?.resumeCameraCapture()
//        videoCamera?.delegate = self
//        videoCamera?.startCapture()
      
        
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
                    
                   let picture = GPUImagePicture(image: image)

                   
                    // 필터 적용
                    picture?.addTarget(scene)
                    scene!.useNextFrameForImageCapture()
                    picture?.processImage()
                    let filteredImage = scene!.imageFromCurrentFramebuffer()

                    // 필터 적용된 UIImage를 저장
                    UIImageWriteToSavedPhotosAlbum(filteredImage!, nil, nil, nil)
                    
                  //  processPhoto(img: image)
//                    if( self.bFront == false)
//                    {
//                        //   videoCamera = backCamera
//                        self.jFaceLookup?.finalFilter?.setInputRotation(kGPUImageFlipHorizonal, at: 0)
//                        
//                    }
//                    else
//                    {
//                        self.jFaceLookup?.finalFilter?.setInputRotation(GPUImageRotationMode(rawValue: 0), at: Int(kGPUImageFlipHorizonal.rawValue))
//                        
//                        //  videoCamera = frontCamera
//                    }
                    
                    
                }catch{
                    
                    
                    
                }
            }
            
            
        }
        
        
    }
 
}
