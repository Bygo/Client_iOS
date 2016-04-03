//
//  Discovery_0_CollectionViewCell.swift
//  Bygo_Client
//
//  Created by Nicholas Garfield on 26/3/16.
//  Copyright © 2016 Nicholas Garfield. All rights reserved.
//

import UIKit
import RealmSwift

// TODO: Rename to GalleryWithTitleCollectionViewCell
class Discovery_0_CollectionViewCell: UICollectionViewCell, UICollectionViewDelegate, UICollectionViewDataSource {
    
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var collectionView: UICollectionView!
    
    var delegate:DiscoveryDelegate?
    var itemTypeIDs:[String]? = nil
    var model:Model? = nil
    
    // MARK: - UICollectionViewDataSource
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        if itemTypeIDs == nil {
            return 0
        } else {
            return 1
        }
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard let itemTypeIDs = itemTypeIDs else { return 0 }
        return itemTypeIDs.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCellWithReuseIdentifier("ItemTypeCell", forIndexPath: indexPath) as? ItemTypeCollectionViewCell else { return UICollectionViewCell() }
        cell.backgroundColor = .whiteColor()
        cell.imageView.backgroundColor = .clearColor()
        cell.imageView.contentMode = UIViewContentMode.ScaleAspectFit
        cell.imageView.clipsToBounds = true
        
        guard let model = model else { return cell }
        guard let itemTypeIDs = itemTypeIDs else { return cell }
        let typeID = itemTypeIDs[indexPath.row]
        dispatch_async(GlobalBackgroundQueue, {
            model.itemTypeServiceProvider.fetchItemType(typeID, completionHandler: {
                (success:Bool) in
                
                if success {
                    let realm = try! Realm()
                    let itemType = realm.objects(ItemType).filter("typeID == \"\(typeID)\"")[0]
                    let name = itemType.name
                    let mediaLink = NSURL(string: itemType.imageLinks[0].value!)!
                    dispatch_async(GlobalMainQueue, {
                        cell.nameLabel.text = name
                        cell.imageView.hnk_setImageFromURL(mediaLink)
                    })
                }
            })
        })
        return cell
    }
    
    
    // MARK: - UICollectionViewDelegate
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        guard let itemTypeIDs = itemTypeIDs else { return }
        let typeID = itemTypeIDs[indexPath.row]
        delegate?.didSelectItemType(typeID)
    }
    
    func collectionView(collectionView: UICollectionView, shouldHighlightItemAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    
    func collectionView(collectionView: UICollectionView, didHighlightItemAtIndexPath indexPath: NSIndexPath) {
        guard let cell = collectionView.cellForItemAtIndexPath(indexPath) else { return }
        cell.alpha = 0.75
    }
    
    func collectionView(collectionView: UICollectionView, didUnhighlightItemAtIndexPath indexPath: NSIndexPath) {
        guard let cell = collectionView.cellForItemAtIndexPath(indexPath) else { return }
        cell.alpha = 1.0
    }
}

// MARK: - UICollectionViewDelegate
extension Discovery_0_CollectionViewCell : UICollectionViewDelegateFlowLayout {
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        return CGSizeMake((bounds.width/2.0), collectionView.bounds.height)
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAtIndex section: Int) -> UIEdgeInsets {
        return UIEdgeInsetsMake(0.0, 8.0, 0.0, 8.0)
    }
}


protocol DiscoveryDelegate {
    func didSelectItemType(typeID: String?)
}