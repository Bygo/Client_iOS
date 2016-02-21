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
    @IBOutlet var sharedBarButtonItem: UIBarButtonItem!
    
    private var focusIndex:NSIndexPath?
    
    var model:Model?
    var type:ListingsListType = .All
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView.backgroundColor = kCOLOR_THREE

        title = "Your Listings"
        sharedBarButtonItem.tintColor = UIColor(colorLiteralRed: 1.0, green: 1.0, blue: 1.0, alpha: 0.5)
        configureNoListingsLabel()
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    private func configureNoListingsLabel() {
        switch type {
        case .All:
            noListingsLabel.text = "You have not created any Listings"
        case .Shared:
            noListingsLabel.text = "You are not sharing any Items"
        default:
            break
        }
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
        case .Shared:
            return "(ownerID == \"\(userID)\") AND (renterID != nil)"
        case .Rented:
            return "(renterID == \"\(userID)\")"
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
        cell.renterImageView.layer.cornerRadius     = cell.renterImageView.bounds.width/2.0
        cell.mainImageImageView.layer.cornerRadius  = 5.0
        cell.mainImageImageView.contentMode         = UIViewContentMode.ScaleAspectFill
        cell.mainImageImageView.clipsToBounds       = true
        cell.mainImageImageView.backgroundColor     = .lightGrayColor()
        cell.renterImageView.hidden = true
        
        if type == .All {
            cell.meetingDetailLabel.hidden  = true
            cell.rentalValueLabel.hidden    = true
        }
        
        dispatch_async(GlobalUserInteractiveQueue, {
            let realm   = try! Realm()
            let results = realm.objects(Listing).filter(self.getQueryFilter()).sorted("name", ascending: true)
            let listing = results[indexPath.item]
            
            guard let name = listing.name else { return }
            let renterID = listing.renterID
            
            dispatch_async(GlobalMainQueue, {
                cell.itemTitleLabel.text    = name
                if let _ = renterID {
                    // TOOD: Grab the image of the renter
                    cell.renterImageView.hidden = false
                }
            })
        })
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        guard let cell = collectionView.dequeueReusableCellWithReuseIdentifier("ListingCell", forIndexPath: indexPath) as? ListingsCollectionViewCell else { return UICollectionViewCell() }
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

    
    // MARK: - UI Actions
    @IBAction func backButtonTapped(sender: AnyObject) {
        navigationController?.popViewControllerAnimated(true)
    }
    
    @IBAction func sharedButtonTapped(sender: AnyObject) {
        switch type {
        case .All:
            sharedBarButtonItem.tintColor = .whiteColor()
            type = .Shared
        case .Shared:
            sharedBarButtonItem.tintColor = UIColor(colorLiteralRed: 1.0, green: 1.0, blue: 1.0, alpha: 0.5)
            type = .All
        default: break
        }
        
        configureNoListingsLabel()
        collectionView.reloadData()
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
        return CGSizeMake(view.bounds.width, view.bounds.height/6.0)
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAtIndex section: Int) -> UIEdgeInsets {
        return UIEdgeInsetsMake(8.0, 0.0, 8.0, 0.0)
    }
}
