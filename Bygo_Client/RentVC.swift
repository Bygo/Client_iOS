//
//  RentVC.swift
//  Bygo_Client
//
//  Created by Nicholas Garfield on 3/2/16.
//  Copyright © 2016 Nicholas Garfield. All rights reserved.
//

import UIKit
import RealmSwift

private let kSHAPE_1_WIDTH_FACTOR:CGFloat = 2.0
private let kSHAPE_1_HEIGHT_FACTOR:CGFloat = 2.0
private let kSHAPE_2_WIDTH_FACTOR:CGFloat = 2.0
private let kSHAPE_2_HEIGHT_FACTOR:CGFloat = 1.0
private let kSHAPE_3_WIDTH_FACTOR:CGFloat = 1.0
private let kSHAPE_3_HEIGHT_FACTOR:CGFloat = 1.0
private let kSHAPE_4_WIDTH_FACTOR:CGFloat = 1.0
private let kSHAPE_4_HEIGHT_FACTOR:CGFloat = 2.0


class RentVC: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {
    
    // MARK: - Outlets
    @IBOutlet var collectionView:UICollectionView!
    lazy var searchBar: UISearchBar = UISearchBar(frame: CGRectMake(0,0,0,0))
    
    var delegate:RentDelegate?
    var model:Model?
    var focusListing:AdvertisedListing?
    
    
    // MARK: - View Controller Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()

        refreshListings()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func userDidLogin() {
        refreshListings()
    }
    
    func userDidLogout() {
        refreshListings()
    }
    
    func refreshListings() {
        model?.advertisedListingServiceProvider.refreshAdvertisedListingsPartialSnapshots({
            (success:Bool) in
            if success { self.collectionView.reloadData() }
            else { print("Error loading AdvertisedListing snapshot") }
        })
    }
    
    
    // MARK: - UICollectionViewDataSource
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let realm = try! Realm()
        let num = realm.objects(AdvertisedListing).count
        return num
    }
    
    
    private func configureCell(cell:RentCollectionViewCell, indexPath:NSIndexPath) {
        let realm = try! Realm()
        let updatedListings = realm.objects(AdvertisedListing).sorted("score", ascending: false)
        let updatedListing = updatedListings[indexPath.item]
        
        guard let name = updatedListing.name else { return }
        
        dispatch_async(GlobalMainQueue, {
            cell.titleLabel.text = name
        })
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCellWithReuseIdentifier("AdvertisedListingSnapshot", forIndexPath: indexPath) as? RentCollectionViewCell else { return UICollectionViewCell() }
        
        // FIXME: Pull UI elements from centralized repo
        cell.layer.borderColor = UIColor.lightGrayColor().CGColor
        cell.layer.borderWidth = 1.0
        cell.layer.cornerRadius = 0.0
        
        cell.mainImageImageView.backgroundColor = UIColor.lightGrayColor()
        cell.mainImageImageView.contentMode = UIViewContentMode.ScaleAspectFill
        cell.mainImageImageView.clipsToBounds = true
        cell.mainImageImageView.layer.masksToBounds = true
        
        // Make an asynchronous request to grab the Listing data from the local cache
        dispatch_async(GlobalUserInteractiveQueue, {
            let realm = try! Realm()
            let advertisedListings = realm.objects(AdvertisedListing).sorted("score", ascending: false)
            let listing = advertisedListings[indexPath.item]
            
            // If the Listing is a partial snapshot, grab more data to advertise the Listing
            if listing.isPartialSnapshot {
                guard let listingID = listing.listingID else { return }
                self.model?.advertisedListingServiceProvider.downloadAdvertisedListingSnapshot(listingID, completionHandler: {
                    (success:Bool) in
                    if success { self.configureCell(cell, indexPath: indexPath) }
                })
            } else {
                self.configureCell(cell, indexPath: indexPath)
            }
        })
    
        cell.ratingImageView.backgroundColor = UIColor.lightGrayColor()
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        let realm               = try! Realm()
        let advertisedListings  = realm.objects(AdvertisedListing).sorted("score", ascending: false)
        focusListing            = advertisedListings[indexPath.item]
        performSegueWithIdentifier("ShowRentItemDetails", sender: nil)
    }
    
    // MARK: - Navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "ShowRentItemDetails" {
            guard let destVC = segue.destinationViewController as? RentItemDetailsVC else { return }
            destVC.listing  = focusListing
            destVC.delegate = delegate
            destVC.model    = model
        }
    }
}

// MARK: - UICollectionViewDelegate
extension RentVC : UICollectionViewDelegateFlowLayout{
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        return CGSizeMake(view.bounds.width-16.0, view.bounds.height/2.0)
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAtIndex section: Int) -> UIEdgeInsets {
        return UIEdgeInsetsMake(0.0, 0.0, 0.0, 0.0)
    }
    
}


public protocol RentDelegate {
    func showLoginMenu()
}