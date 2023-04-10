//
//  MaskDemoItemSource.swift
//  RetroCamera
//
//  Created by Junsung Park on 2022/04/22.
//

import UIKit
import Kingfisher

class MaskDemoItemSource: NSObject ,  UICollectionViewDataSource, UICollectionViewDelegate,UICollectionViewDelegateFlowLayout{
    
      var itemArray:NSArray!

    var parentCon:StoreViewController!
    var parentCon2:EditViewController!
   
    func initData(data:NSDictionary)
    {
        
        itemArray =  data["images"] as! NSArray
    
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        numberOfItemsInSection section: Int) -> Int
    {
        return self.itemArray.count
    }
    
    
    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell
    {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ItemCell", for: indexPath) as! ItemCell;
        
   
        
        let dict:NSDictionary =  itemArray[indexPath.row] as! NSDictionary
        let thumb = dict["name"]
         
        let thumbStr:String = String(format: "http://www.junsoft.org/mask/thumb/%@", thumb as! CVarArg)
        let thumbURL:URL = URL(string: thumbStr)!
     //   cell.imgView?.setImageWith(thumbURL as URL ,placeholderImage:nil)
        cell.indicator?.isHidden = true
        
      //  cell.indicator?.color = UIColor(red: 243.0/255.0, green: 188.0/255.0, blue: 81.0/255.0, alpha: 1.0)
        cell.indicator?.color = UIColor(red: 255, green: 199, blue: 44, alpha: 1)
    
       // cell.img?.sd_setImage(with:thumbURL, placeholderImage:nil)
        cell.img!.kf.setImage(with: thumbURL)

        
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        didSelectItemAt indexPath: IndexPath)
    {
        let dict:NSDictionary =  itemArray[indexPath.row] as! NSDictionary
        
        let thumb = dict["name"] as! NSString
        let cell:ItemCell = collectionView.cellForItem(at: indexPath) as! ItemCell
    
        
        cell.indicator?.isHidden = false
        cell.indicator?.startAnimating()
   
        if(parentCon != nil)
        {
            parentCon.processMask(item: thumb as! String, cell:cell)
        
        }
        else
        {
            parentCon2.processMask(item: thumb as! String, cell:cell)
        
        }
        
        
        collectionView.scrollToItem(at: indexPath, at: .centeredVertically, animated: true)
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 3, left: 3, bottom: 3, right: 3);
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 10
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 10
    }
}
