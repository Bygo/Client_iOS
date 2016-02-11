//
//  ListingsVC.swift
//  Bygo_Client
//
//  Created by Nicholas Garfield on 4/2/16.
//  Copyright © 2016 Nicholas Garfield. All rights reserved.
//

import UIKit
import RealmSwift

private let kSHAPE_1_WIDTH_FACTOR:CGFloat   = 2.0
private let kSHAPE_1_HEIGHT_FACTOR:CGFloat  = 2.0
private let kSHAPE_2_WIDTH_FACTOR:CGFloat   = 2.0
private let kSHAPE_2_HEIGHT_FACTOR:CGFloat  = 1.0
private let kSHAPE_3_WIDTH_FACTOR:CGFloat   = 1.0
private let kSHAPE_3_HEIGHT_FACTOR:CGFloat  = 1.0
private let kSHAPE_4_WIDTH_FACTOR:CGFloat   = 1.0
private let kSHAPE_4_HEIGHT_FACTOR:CGFloat  = 2.0

class ListingsVC: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, EditListingsDelegate {
    
    @IBOutlet var collectionView: UICollectionView!
    @IBOutlet var noListingsLabel: UILabel!
    
    private var focusIndex:NSIndexPath?
    
    var model:Model?
    var type:ListingsListType = .All
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        switch type {
        case .All:
            title = "ALL MY LISTINGS"
            noListingsLabel.text = "You have not created any Listings"
        case .Shared:
            title = "SHARED ITEMS"
            noListingsLabel.text = "You are not sharing any Items"
        case .Rented:
            title = "RENTED ITEMS"
            noListingsLabel.text = "You are not renting any Items"
        }
        
        if let navBarHeight = navigationController?.navigationBar.bounds.height {
            let statusBarHeight = UIApplication.sharedApplication().statusBarFrame.height
            collectionView?.contentInset             = UIEdgeInsetsMake(navBarHeight+statusBarHeight, 0, 0, 0)
            collectionView?.scrollIndicatorInsets    = UIEdgeInsetsMake(navBarHeight+statusBarHeight, 0, 0, 0)
        }
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
    // MARK: - UICollectionViewDataSource
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    
    private func getQueryFilter() -> String {
        let nullFilter = "ownerID == nil"
        guard let localUser = model?.userServiceProvider.getLocalUser() else { return nullFilter }
        guard let userID    = localUser.userID else { return nullFilter }
        
        switch type {
        case .All:
            return "ownerID == \"\(userID)\""
        default:
            return nullFilter
        }
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let realm = try! Realm()
        let count = realm.objects(Listing).filter(self.getQueryFilter()).count
        
        if count == 0 {
            noListingsLabel.hidden = false
            view.bringSubviewToFront(noListingsLabel)
        } else {
            noListingsLabel.hidden = true
            view.sendSubviewToBack(noListingsLabel)
        }
        
        return count
    }
    
    func configureCell(cell:ListingsCollectionViewCell, atIndexPath indexPath:NSIndexPath) {
        dispatch_async(GlobalUserInteractiveQueue, {
            let realm   = try! Realm()
            let results = realm.objects(Listing).filter(self.getQueryFilter()).sorted("name", ascending: true)
            let listing = results[indexPath.item]
            
            guard let name = listing.name else { return }

            dispatch_async(GlobalMainQueue, {
                cell.itemTitleLabel.text = name
                cell.rentalRateLabel.text = nil
                
                cell.mainImageImageView.contentMode = UIViewContentMode.ScaleAspectFill
                cell.mainImageImageView.clipsToBounds = true
                cell.mainImageImageView.backgroundColor = .lightGrayColor()
                cell.ratingImageView.backgroundColor = .lightGrayColor()
                
                // FIXME: Does not display the Renter if non nil
                cell.rentedByLabel.hidden           = true
                cell.renterNameLabel.hidden         = true
                cell.renterImageImageView.hidden    = true
                cell.renterRatingImageView.hidden   = true
                cell.blackTintView.hidden           = true
            })
        })
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        guard let cell = collectionView.dequeueReusableCellWithReuseIdentifier("ListingCell", forIndexPath: indexPath) as? ListingsCollectionViewCell else { return UICollectionViewCell() }
        
        // FIXME: Pull from global repo
        cell.layer.borderColor  = UIColor.lightGrayColor().CGColor
        cell.layer.borderWidth  = 1.0
        cell.layer.cornerRadius = 0.0
        
        configureCell(cell, atIndexPath: indexPath)
        
        return cell
    }
    
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        focusIndex = indexPath
        if type == .All {
            performSegueWithIdentifier("ShowEditListing", sender: nil)
        }
    }
    
    
    // MARK: - EditListingsDelegate
    func didEditListing() {
        if let focusIndex = focusIndex {
            collectionView.reloadItemsAtIndexPaths([focusIndex])
        }
    }

    
    // MARK: - Navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "ShowEditListing" {
            guard let navVC     = segue.destinationViewController as? UINavigationController else { return }
            guard let destVC    = navVC.topViewController as? EditListingVC else { return }
            destVC.delegate     = self
            destVC.model        = model
            if let focusIndex   = focusIndex {
                let realm       = try! Realm()
                destVC.listing  = realm.objects(Listing).filter(getQueryFilter()).sorted("name", ascending: true)[focusIndex.item]
            }
        }
    }
}


// MARK: - UICollectionViewDelegate
extension ListingsVC : UICollectionViewDelegateFlowLayout {
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        return CGSizeMake(view.bounds.width-16.0, view.bounds.height/2.0)
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAtIndex section: Int) -> UIEdgeInsets {
        return UIEdgeInsetsMake(0.0, 0.0, 0.0, 0.0)
    }
}
