//
//  CameraAPI.swift
//  RetroCamera
//
//  Created by Junsung Park on 2022/04/27.
//

import Foundation
import Hue


class CameraAPI{
    static let shared = CameraAPI()
    var videoCamera:GPUImageVideoCamera?
     
    var frontCamera:GPUImageVideoCamera?
    
  
    var backCamera:GPUImageVideoCamera?
    var scene:Scene?
    var framerate:Float64?
    var fov:Float?
    var bFront :Bool = true
   
    private init(){
        self.frontCamera = GPUImageVideoCamera(sessionPreset: AVCaptureSession.Preset.vga640x480.rawValue, cameraPosition: .front)
        self.frontCamera!.outputImageOrientation = .portrait;
        self.frontCamera!.horizontallyMirrorFrontFacingCamera = true
        
        self.backCamera = GPUImageVideoCamera(sessionPreset: AVCaptureSession.Preset.vga640x480.rawValue, cameraPosition: .back)
        self.backCamera!.outputImageOrientation = .portrait;
        
        if(bFront == true)
        {
            self.videoCamera = self.frontCamera
            
        }
        else
        {
            self.videoCamera = self.backCamera
            
        }
        self.framerate = (self.videoCamera!.inputCamera.activeFormat.videoSupportedFrameRateRanges[0] as AnyObject).maxFrameRate as Float64
        
        self.fov = self.videoCamera?.inputCamera.activeFormat.videoFieldOfView
   
        scene = Scene()
        
        self.scene?.initSDKFrameRate(Float(self.framerate!), fov:self.fov!,size:CGSize(width: 640, height: 480))
 
        
    }
   
    func initCameraSession(front:Bool)
    {
       
        
        bFront = front
            
    }
    func getScene() -> Scene?
    {
        return scene
    }
    
    func getVideoCamera() -> GPUImageVideoCamera?
    {
        return videoCamera
    }
    
    func isFront() -> Bool?
    {
        return bFront
    }
    
}
