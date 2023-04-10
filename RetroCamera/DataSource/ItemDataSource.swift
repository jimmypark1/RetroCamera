//
//  ItemDataSource.swift
//  RetroCamera
//
//  Created by Junsung Park on 2022/04/20.
//

import UIKit
import Kingfisher

class ItemDataSource: NSObject  ,  UICollectionViewDataSource, UICollectionViewDelegate{
    var array:Array<String>!

    var parentCon:StoreViewController!
    var itemDict:NSDictionary!
    var itemArray:NSArray!

    func initData(data:Array<String>)
    {
        
      //  let Array =  self.itemDict["item"] as! NSArray
      //  let itemDict1 = Array[0] as! NSDictionary
        // var items:[String] //= self.dataDict["item"]
        itemArray =  self.itemDict["item"] as! NSArray

    
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
        
        
        let dict:NSDictionary =  itemArray[indexPath.row] as! NSDictionary
        let thumb = dict["thumb"]
     
        let thumbStr:String = String(format: "http://www.junsoft.org/thumb/%@.png", thumb as! CVarArg)
        let thumbURL:URL = URL(string: thumbStr)!
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
        let dict:NSDictionary =  itemArray[indexPath.row] as! NSDictionary
        let thumb = dict["thumb"]
        let cell:ItemCell = collectionView.cellForItem(at: indexPath) as! ItemCell
    
        
        cell.indicator?.isHidden = false
        cell.indicator?.startAnimating()
        parentCon.processImage(name: thumb as! String, cell:cell)
    }
}
