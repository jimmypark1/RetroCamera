//
//  StickerMenuDelegate.swift
//  RetroCamera
//
//  Created by Junsung Park on 2022/04/19.
//
import UIKit

class StickerMenuDelegate: NSObject,  UICollectionViewDataSource, UICollectionViewDelegate,UICollectionViewDelegateFlowLayout {

    var owner:Any
    var oldIndex:IndexPath
    
    init(owner:Any) {
        self.owner = owner
        self.oldIndex = IndexPath(row: 0, section: 0)
        super.init()
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        numberOfItemsInSection section: Int) -> Int
    {
        return 2//self.itemArray.count
    }
    
    
    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell
    {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! ThumbCell;
        
        let index = indexPath.row
        
        
        cell.indicator?.isHidden = true
        
        if(index == 0)
        {
             cell.imgView?.image = UIImage(named: "carnival")
        }
        if(index == 1)
        {
            cell.imgView?.image = UIImage(named: "mask_rev")
        }
        
        let user:UserDefaults = UserDefaults.standard
        
        let s_index:Int = user.integer(forKey: "STICKER_MENU")
        
        if(index == s_index && index == 0)
        {
            cell.imgView?.image = UIImage(named: "carnival_on")
            
        }
        if(index == s_index && index == 1)
        {
            cell.imgView?.image = UIImage(named: "mask_rev_on")
            
        }
        
        return cell;
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        didSelectItemAt indexPath: IndexPath)
    {
        let index = indexPath.row
        let user:UserDefaults = UserDefaults.standard
        user.set(index, forKey: "STICKER_MENU")
        
        let cell:ThumbCell = collectionView.cellForItem(at: indexPath) as! ThumbCell
        
        
        
        
        if(index == 0)
        {
            cell.imgView?.image = UIImage(named: "carnival_on")
             (self.owner as! ViewController).showStickerStatic()
            
        }
        if(index == 1)
        {
        
            cell.imgView?.image = UIImage(named: "mask_rev_on")
            (self.owner as! ViewController).showMask()
        }
        
       
        oldIndex = indexPath
        collectionView.reloadData()
        
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
     //   return UIEdgeInsetsMake(3, 8, 8, 8);
        return UIEdgeInsets(top: 3, left: 8, bottom: 3, right: 3);
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 15
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 15
    }
}
