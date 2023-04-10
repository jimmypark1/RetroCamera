//
//  FiterItemSource.swift
//  RetroCamera
//
//  Created by Junsung Park on 2022/04/21.
//

import UIKit
import Kingfisher

class FiterItemSource: NSObject ,  UICollectionViewDataSource, UICollectionViewDelegate{
    var array:Array<String>!

    var parentCon:StoreViewController!
    var itemDict:NSDictionary!
    var itemArray:NSArray!

    func initData(data:NSMutableArray)
    {
        
      //  let Array =  self.itemDict["item"] as! NSArray
      //  let itemDict1 = Array[0] as! NSDictionary
        // var items:[String] //= self.dataDict["item"]
      //  itemArray =  self.itemDict["item"] as! NSArray

        self.itemArray = data
    
        //self.array = data
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        numberOfItemsInSection section: Int) -> Int
    {
        return itemArray.count
    }
    
   
    
   
    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell
    {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ItemCell", for: indexPath) as! ItemCell;
        
       
                 
        
        let dict:FilterData =  itemArray[indexPath.row] as! FilterData
        
      //  cell.imgView?.layer.zPosition = 100
       // cell.imgView?.image = manager.image
        let thumbStr:String = String(format: "http://www.junsoft.org/thumb/%@", dict.name as! CVarArg)
        let thumbURL:URL = URL(string: thumbStr)!
      //  cell.imgView?.setImageWith(thumbURL as URL ,placeholderImage:nil)
        cell.indicator?.isHidden = true
        
      //  cell.indicator?.color = UIColor(red: 243.0/255.0, green: 188.0/255.0, blue: 81.0/255.0, alpha: 1.0)
        cell.indicator?.color = UIColor(red: 255, green: 199, blue: 44, alpha: 1)
    
      //  cell.img.sd_setImage(with:thumbURL, placeholderImage:nil)
    
        cell.img!.kf.setImage(with: thumbURL)

        return cell
    }
    func collectionView(_ collectionView: UICollectionView,
                        didSelectItemAt indexPath: IndexPath)
    {
       
        
        collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
        let data:FilterData =  itemArray[indexPath.row] as! FilterData
     
      //  let dict:NSDictionary =  itemArray[indexPath.row] as! NSDictionary
      //  let thumb = dict["thumb"]
        let cell:ItemCell = collectionView.cellForItem(at: indexPath) as! ItemCell
    
        
        cell.indicator?.isHidden = false
        
        cell.indicator?.startAnimating()
        parentCon.processFilter(item: data.name, type: data.type, cell:cell)


       // parentCon.processImage(name: thumb as! String)
    }
}
