//
//  FilterDemoDataSource.swift
//  RetroCamera
//
//  Created by Junsung Park on 2022/04/19.
//

import UIKit

class FilterDemoDataSource: NSObject  ,  UICollectionViewDataSource, UICollectionViewDelegate{
    
    var array:Array<String>!

    var parentCon:HomeViewController!
 
    func initData(data:Array<String>)
    {
        self.array = data
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        numberOfItemsInSection section: Int) -> Int
    {
        return self.array.count
    }
    
   
    
   
    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell
    {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "FilterCell", for: indexPath) as! FilterCell;
        
        let name = array[indexPath.row] as! String
        cell.img.image = UIImage(named: name)
   
        return cell
    }
    func collectionView(_ collectionView: UICollectionView,
                        didSelectItemAt indexPath: IndexPath)
    {
       
        
        collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
        
        parentCon.showStore()
    }
    
   
}
