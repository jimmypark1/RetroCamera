//
//  FilterSource.swift
//  RetroCamera
//
//  Created by Junsung Park on 2022/04/21.
//

import UIKit
import Kingfisher

class FilterSource: NSObject ,  UICollectionViewDataSource, UICollectionViewDelegate,UICollectionViewDelegateFlowLayout{
    
    var itemArray:NSMutableArray
    var owner:Any
    
    var isDeepAr:Bool = true
    
    func documentsDirectoryURL() -> NSURL {
        let manager = FileManager.default
        let URLs = manager.urls(for: .documentDirectory, in: .userDomainMask)
        return URLs[0] as NSURL
    }
    init(items: NSMutableArray,owner:Any) {
        self.itemArray = items
        self.owner = owner
        // var items:[String] //= self.dataDict["item"]
       /*
        for i in 0 ... self.itemArray.count-1
        {
            let dict:FilterData =  itemArray[i] as! FilterData
            if( dict.type == "ToneCurve")
            {
                 let f_manager = FileManager.default
                
                let URLs = f_manager.urls(for: .documentDirectory, in: .userDomainMask)
                let path2 = URLs[0] as NSURL
               // manager.image
                var appendPath:String = String(format:"filter/%@",dict.name)
                let path = path2.appendingPathComponent(appendPath)! as NSURL
                let t_path = path2.appendingPathComponent(dict.name)! as NSURL
                
                let toneData = f_manager.contents(atPath: path.path!)
                
                let filter:GPUImageToneCurveFilter = GPUImageToneCurveFilter(acvData: toneData as Data!)
                
                manager.processStillImage(UIImage(named: "g1_0"), filter: filter)
            
                
                let imgData = UIImagePNGRepresentation(manager.image)
                
                let ret = f_manager.createFile(atPath: t_path.path!, contents: imgData, attributes: nil)
                
                
                print(ret)
                
            }
            if( dict.type == "Lookup")
            {
                let f_manager = FileManager.default
                
                let URLs = f_manager.urls(for: .documentDirectory, in: .userDomainMask)
                let path2 = URLs[0] as NSURL
                // manager.image
                var appendPath:String = String(format:"filter/%@",dict.name)
                let path = path2.appendingPathComponent(appendPath)! as NSURL
                let t_path = path2.appendingPathComponent(dict.name)! as NSURL
                
                let toneData = f_manager.contents(atPath: path.path!)
                
                var jFaceLookup = JFaceLookupFilter()
                jFaceLookup = (jFaceLookup.process(dict.name) as? JFaceLookupFilter)!
                
                
                manager.processStillImage(UIImage(named: "g1_0"), filter: jFaceLookup)
                
                
                let imgData = UIImagePNGRepresentation(manager.image)
                
                let ret = f_manager.createFile(atPath: t_path.path!, contents: imgData, attributes: nil)
                
                
                print(ret)
                
            }
            
        }
    */
 
        
 
        super.init()
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        numberOfItemsInSection section: Int) -> Int
    {
        return self.itemArray.count
    }
    
    /*
     - (UIImage*)processStillImage:(UIImage*)inputImage filter:(GPUImageFilter*)stillImageFilter
     {
     
     GPUImagePicture *stillImageSource = [[GPUImagePicture alloc] initWithImage:inputImage];
     
     [stillImageSource addTarget:stillImageFilter];
     
     [stillImageFilter useNextFrameForImageCapture];
     [stillImageSource processImage];
     
     UIImage *currentFilteredVideoFrame = [stillImageFilter imageFromCurrentFramebuffer];
     
     UIImage *rotatedImage = [[UIImage alloc]initWithCGImage:currentFilteredVideoFrame.CGImage scale:1.0 orientation:UIImageOrientationUp];
     
     return currentFilteredVideoFrame;
     }
 
    */
    
   
    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell
    {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ThumbCell", for: indexPath) as! ThumbCell;

        cell.index = indexPath.row
        cell.imgView?.layer.masksToBounds = true;
        cell.imgView?.layer.borderColor = UIColor.white.cgColor;
        cell.imgView?.layer.borderWidth = 1;
        cell.imgView?.layer.cornerRadius = (cell.imgView?.frame.size.width)! / 2;
         
      
        cell.indicator?.isHidden = true
        
      //  cell.indicator?.color = UIColor(red: 243.0/255.0, green: 188.0/255.0, blue: 81.0/255.0, alpha: 1.0)
       cell.indicator?.color = UIColor(red: 255, green: 199, blue: 44, alpha: 1)
           
        
        let dict:FilterData =  itemArray[indexPath.row] as! FilterData
        
      //  cell.imgView?.layer.zPosition = 100
       // cell.imgView?.image = manager.image
        let thumbStr:String = String(format: "http://www.junsoft.org/thumb/%@", dict.name as! CVarArg)
        let thumbURL:URL = URL(string: thumbStr)!
      //  cell.imgView?.setImageWith(thumbURL as URL ,placeholderImage:nil)
           
        cell.imgView!.kf.setImage(with: thumbURL)

      
        
        var bBuyVIP:Bool = UserDefaults.standard.bool(forKey: "BUY_VIP")
        cell.indicator?.isHidden = true
        
      //  cell.indicator?.color = UIColor(red: 243.0/255.0, green: 188.0/255.0, blue: 81.0/255.0, alpha: 1.0)
        cell.indicator?.color = UIColor(red: 255, green: 199, blue: 44, alpha: 1)
    
     //   bBuyVIP = false
        /*
        if(indexPath.row < 4)
        {
            
            cell.vip!.isHidden = true
            
        }
        else
        {
            if(bBuyVIP == false)
                 {
                 
                     cell.vip!.isHidden = false
                 }
                 else
                 {
                       
                         cell.vip!.isHidden = true
                     
                 }
        }
        */
     //   cell.vip!.isHidden = true
        
        
        return cell
    }
    func collectionView(_ collectionView: UICollectionView,
                        didSelectItemAt indexPath: IndexPath)
    {
        let filterData:FilterData =  itemArray[indexPath.row] as! FilterData
        
        let cell:ThumbCell = collectionView.cellForItem(at: indexPath) as! ThumbCell
    
        
        cell.indicator?.isHidden = false
        
        cell.indicator?.startAnimating()
     //   cell.indicator?.layer.zPosition =
        
        (self.owner as! ViewController).processFilter(item: filterData.name, type: filterData.type, cell: cell)

        
        
        collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 30, left: 16, bottom: 16, right: 16);
        
    }
   
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 10
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 10
    }
}
