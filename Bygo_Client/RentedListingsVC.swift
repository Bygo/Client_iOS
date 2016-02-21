//
//  RentedListingsVC.swift
//  Bygo_Client
//
//  Created by Nicholas Garfield on 15/2/16.
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

class RentedListingsVC: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    
    @IBOutlet var collectionView: UICollectionView!
    @IBOutlet var noListingsLabel: UILabel!
    
    private var focusIndex:NSIndexPath?
    
    var model:Model?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Rented Items"
        
        noListingsLabel.text = "You are not renting any Items"
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "rentRequestWasAccepted:", name: Notifications.RentRequestWasAccepted.rawValue, object: nil)
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
        guard let userID = model?.userServiceProvider.getLocalUser()?.userID else { return nullFilter }
        return "(renterID == \"\(userID)\")"
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
    
    func configureCell(cell:RentedListingsCollectionViewCell, atIndexPath indexPath:NSIndexPath) {
        dispatch_async(GlobalUserInteractiveQueue, {
            let realm   = try! Realm()
            let results = realm.objects(Listing).filter(self.getQueryFilter()).sorted("name", ascending: true)
            let listing = results[indexPath.item]
            
//            guard let rentEvent = realm.objects(RentEvent).filter("listingID == \"\(listing.listingID!)\"").first else { return }
//            guard let rentalStatus = rentEvent.status else { return }
            guard let name = listing.name else { return }
            
            dispatch_async(GlobalMainQueue, {
                cell.listingNameLabel.text              = name
                cell.rentalDetailLabel.text             = "Some meeting details"
                cell.mainImageImageView.contentMode     = UIViewContentMode.ScaleAspectFill
                cell.mainImageImageView.clipsToBounds   = true
                cell.mainImageImageView.backgroundColor = .lightGrayColor()
                cell.mainImageImageView.layer.cornerRadius = 5.0
            })
        })
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        guard let cell = collectionView.dequeueReusableCellWithReuseIdentifier("ListingCell", forIndexPath: indexPath) as? RentedListingsCollectionViewCell else { return UICollectionViewCell() }
        

        
        configureCell(cell, atIndexPath: indexPath)
        
        return cell
    }
    
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        focusIndex = indexPath
//        if type == .All {
//            performSegueWithIdentifier("ShowEditListing", sender: nil)
//        }
    }
    
    
    // MARK: - Notification Handlers
    func rentRequestWasAccepted(notification:NSNotification) {
        collectionView.reloadData()
    }
    
    
    // MARK: - UI Actions
    @IBAction func backButtonTapped(sender: AnyObject) {
        navigationController?.popViewControllerAnimated(true)
    }
    
    
    // MARK: - Navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
//        if segue.identifier == "ShowEditListing" {
//            guard let navVC     = segue.destinationViewController as? UINavigationController else { return }
//            guard let destVC    = navVC.topViewController as? EditListingVC else { return }
//            destVC.delegate     = self
//            destVC.model        = model
//            if let focusIndex   = focusIndex {
//                let realm       = try! Realm()
//                destVC.listing  = realm.objects(Listing).filter(getQueryFilter()).sorted("name", ascending: true)[focusIndex.item]
//            }
//        }
    }
}


// MARK: - UICollectionViewDelegate
extension RentedListingsVC : UICollectionViewDelegateFlowLayout {
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        return CGSizeMake(view.bounds.width, view.bounds.height/6.0)
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAtIndex section: Int) -> UIEdgeInsets {
        return UIEdgeInsetsMake(8.0, 0.0, 8.0, 0.0)
    }
}
