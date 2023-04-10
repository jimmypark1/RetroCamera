//
//  StickerDelegate.swift
//  RetroCamera
//
//  Created by Junsung Park on 2022/04/19.
//

import Kingfisher

class StickerDelegate : NSObject,  UICollectionViewDataSource, UICollectionViewDelegate,UICollectionViewDelegateFlowLayout{
    
    var dataDict:NSDictionary!
    var itemArray:NSArray!
    var owner:Any!
    var isDeepAr:Bool = true
    
    var select:Int = 0
    
    init(items: NSDictionary,owner:Any) {
        self.dataDict = items
        self.owner = owner
     
              itemArray =  self.dataDict["item"] as! NSArray
        
       // var items:[String] //= self.dataDict["item"]
    
        super.init()
    }
    override init() {
        
        super.init()
        
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        numberOfItemsInSection section: Int) -> Int
    {
        return self.itemArray.count
    }
   

    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell
    {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ThumbCell", for: indexPath) as! ThumbCell;

        
        cell.imgView?.layer.masksToBounds = true;
        cell.imgView?.layer.borderColor = UIColor.white.cgColor;
        cell.imgView?.layer.borderWidth = 1;
        cell.imgView?.layer.cornerRadius = (cell.imgView?.frame.size.width)! / 2;

        
        cell.indicator?.isHidden = true
        
      //  cell.indicator?.color = UIColor(red: 243.0/255.0, green: 188.0/255.0, blue: 81.0/255.0, alpha: 1.0)
        cell.indicator?.color = UIColor(red: 255, green: 199, blue: 44, alpha: 1)
     
        
        var thumbStr:String = ""
        /*
        if(isDeepAr == false)
        {
            let dict:NSDictionary =  itemArray[indexPath.row] as! NSDictionary
             
            let thumb = dict["name"]
             
            thumbStr = String(format: "http://www.junsoft.org/youmake/thumb/mask/%@.png", thumb as! CVarArg)
            
        }
        else
        {
                 
            thumbStr = String(format: "http://www.junsoft.org/youmake/thumb/mask/%d.png", indexPath.row as CVarArg)
            
        }
 */
        let dict:NSDictionary =  itemArray[indexPath.row] as! NSDictionary
                  
        let thumb = dict["thumb"]
           /*
        if(select == 0)
        {
            thumbStr = String(format: "http://www.junsoft.org/youmake/thumb/mask/%@.png", thumb as! CVarArg)
        }
        else
        {
            thumbStr = String(format: "http://www.junsoft.org/beautycamera/item/thumb/%@_tn.jpg", thumb as! CVarArg)

        }
        */
        thumbStr = String(format: "http://www.junsoft.org/thumb/%@.png", thumb as! CVarArg)

        let thumbURL:URL = URL(string: thumbStr)!
       // cell.imgView?.setImageWith(thumbURL as URL ,placeholderImage:nil)
        
         //cell.imgView?.sd_setImage(with:thumbURL, placeholderImage:nil)
        
        cell.imgView!.kf.setImage(with: thumbURL)

        return cell
    }
    func collectionView(_ collectionView: UICollectionView,
                        didSelectItemAt indexPath: IndexPath)
    {
        if(isDeepAr == false)
        {
            let dict:NSDictionary =  itemArray[indexPath.row] as! NSDictionary
                
                let thumb = dict["name"] as! NSString
                
                let cell:ThumbCell = collectionView.cellForItem(at: indexPath) as! ThumbCell
                
                cell.indicator?.isHidden = false
                cell.indicator?.startAnimating()
               (self.owner as! ViewController).processSticker(item: thumb as! String, cell: cell);
                   
            
        }
        else
        {
            
            // let name:String =  itemArray[indexPath.row] as! String
            let dict:NSDictionary =  itemArray[indexPath.row] as! NSDictionary
                                       
            let name = dict["name"] as! NSString
                                 
            let cell:ThumbCell = collectionView.cellForItem(at: indexPath) as! ThumbCell
                  
            
            cell.indicator?.isHidden = false
           // cell.indicator?.color = UIColor(hex:"f64a8a")
         
            cell.indicator?.startAnimating()
        
            (self.owner as! ViewController).processSticker(item: name as! String, cell: cell);
            
        }
        
          
        collectionView.scrollToItem(at: indexPath, at: .centeredVertically, animated: true)
        
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

