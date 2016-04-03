//
//  ListingsVC.swift
//  Bygo_Client
//
//  Created by Nicholas Garfield on 4/2/16.
//  Copyright © 2016 Nicholas Garfield. All rights reserved.
//

import UIKit
import RealmSwift
import Haneke


private let kSHAPE_1_WIDTH_FACTOR:CGFloat   = 2.0
private let kSHAPE_1_HEIGHT_FACTOR:CGFloat  = 2.0
private let kSHAPE_2_WIDTH_FACTOR:CGFloat   = 2.0
private let kSHAPE_2_HEIGHT_FACTOR:CGFloat  = 1.0
private let kSHAPE_3_WIDTH_FACTOR:CGFloat   = 1.0
private let kSHAPE_3_HEIGHT_FACTOR:CGFloat  = 1.0
private let kSHAPE_4_WIDTH_FACTOR:CGFloat   = 1.0
private let kSHAPE_4_HEIGHT_FACTOR:CGFloat  = 2.0

class ListingsVC: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    
    @IBOutlet var collectionView: UICollectionView!
    @IBOutlet var noListingsLabel: UILabel!
    
    private var focusIndex:NSIndexPath?
    
    var model:Model?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView.backgroundColor = kCOLOR_THREE
        
        title = "Your Listings"
        configureNoListingsLabel()
        

        guard let userID = model?.userServiceProvider.getLocalUser()?.userID else { return }
        model?.listingServiceProvider.fetchUsersListings(userID, completionHandler: {
            (success:Bool) in
            print("SUCCESS")
            dispatch_async(GlobalMainQueue, {
                self.collectionView.reloadData()
            })
        })
    }
    
    private func configureNoListingsLabel() {
        noListingsLabel.text = "You have not created any Listings"
        noListingsLabel.font = UIFont.systemFontOfSize(16.0, weight: UIFontWeightMedium)
        noListingsLabel.backgroundColor = kCOLOR_THREE
    }
    
    
    // MARK: - UICollectionViewDataSource
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    
    private func getQueryFilter() -> String {
        let nullFilter = "ownerID == nil"
        guard let userID = model?.userServiceProvider.getLocalUser()?.userID else { return nullFilter }
        return "ownerID == \"\(userID)\""
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        print("Num items in section")
        let realm = try! Realm()
        let count = realm.objects(Listing).filter(self.getQueryFilter()).count
        
        print("COUNT: \(count)")
        
        if count == 0 {
            noListingsLabel.hidden = false
            view.bringSubviewToFront(noListingsLabel)
        } else {
            noListingsLabel.hidden = true
            view.sendSubviewToBack(noListingsLabel)
        }
        
        return count
    }
    
    func configureCell(cell:ItemTypeCollectionViewCell, atIndexPath indexPath:NSIndexPath) {
        
        cell.backgroundColor = .whiteColor()
        
        dispatch_async(GlobalBackgroundQueue, {
            let realm   = try! Realm()
            let results = realm.objects(Listing).filter(self.getQueryFilter()).sorted("typeID", ascending: true)
            let listing = results[indexPath.item]
            
            print(listing)
            guard let typeID = listing.typeID else { return }
            print(typeID)
            
            // Set the cell's image
            if let imageMediaLink = listing.imageLinks.first {
                if let link = imageMediaLink.value {
                    if let url = NSURL(string: link) {
                        dispatch_async(GlobalMainQueue, {
                            cell.imageView.hnk_setImageFromURL(url)
                        })
                    }
                }
            }
            
            // Set the cell's title label
            self.model?.itemTypeServiceProvider.fetchItemType(typeID, completionHandler: {
                (success:Bool) in
                let realm = try! Realm()
                let itemType = realm.objects(ItemType).filter("typeID == \"\(typeID)\"")[0]
                guard let name = itemType.name else { return }
                dispatch_async(GlobalMainQueue, {
                    cell.nameLabel.text = name
                })
            })
            
//            if let renterID = listing.renterID {
//                // TOOD: Grab the image of the renter
//                cell.renterImageView.hidden = false
//            }
        })
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCellWithReuseIdentifier("ItemTypeCell", forIndexPath: indexPath) as? ItemTypeCollectionViewCell else { return UICollectionViewCell() }
        
        configureCell(cell, atIndexPath: indexPath)
        
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        focusIndex = indexPath
    }
    
    // MARK: - EditListingsDelegate
    func didEditListing() {
        if let focusIndex = focusIndex {
            collectionView.reloadItemsAtIndexPaths([focusIndex])
        }
    }

    
    // MARK: - UI Actions
    @IBAction func backButtonTapped(sender: AnyObject) {
        navigationController?.popViewControllerAnimated(true)
    }
    

    // MARK: - Navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "ShowEditListing" {
//            guard let navVC     = segue.destinationViewController as? UINavigationController else { return }
//            guard let destVC    = navVC.topViewController as? EditListingVC else { return }
//            destVC.delegate     = self
//            destVC.model        = model
//            if let focusIndex   = focusIndex {
//                let realm       = try! Realm()
//                destVC.listing  = realm.objects(Listing).filter(getQueryFilter()).sorted("name", ascending: true)[focusIndex.item]
//            }
        }
    }
}


// MARK: - UICollectionViewDelegate
extension ListingsVC : UICollectionViewDelegateFlowLayout {
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        return CGSizeMake((view.bounds.width/2.0)-13.0, 252.0)
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAtIndex section: Int) -> UIEdgeInsets {
        return UIEdgeInsetsMake(8.0, 8.0, 8.0, 8.0)
    }
}
