//
//  RentVC.swift
//  Bygo_Client
//
//  Created by Nicholas Garfield on 3/2/16.
//  Copyright © 2016 Nicholas Garfield. All rights reserved.
//

import UIKit
import RealmSwift
import Haneke

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
    @IBOutlet var refreshControl:UIRefreshControl!
    
    lazy var searchBar: UISearchBar = UISearchBar(frame: CGRectMake(0,0,0,0))
    
    var delegate:RentDelegate?
    var model:Model?
    var focusListing:AdvertisedListing?
    
    
    // MARK: - View Controller Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()

        // Add refresh control
        refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: "refreshListings", forControlEvents: .ValueChanged)
        collectionView.addSubview(refreshControl)
        
        // UI Design
        navigationController?.navigationBar.barTintColor    = kCOLOR_ONE
        navigationController?.navigationBar.translucent     = false
        navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.whiteColor()]
        collectionView.backgroundColor = kCOLOR_THREE
        
        refreshListings()
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent
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
        model?.advertisedListingServiceProvider.refreshAdvertisedListingsSnapshots({
            (success:Bool) in
            if success {
                self.refreshControl.endRefreshing()
                self.collectionView.reloadData()
            }
            else { print("Error loading AdvertisedListing snapshots") }
        })
//        model?.advertisedListingServiceProvider.refreshAdvertisedListingsPartialSnapshots({
//            (success:Bool) in
//            if success { self.collectionView.reloadData() }
//            else { print("Error loading AdvertisedListing snapshot") }
//        })
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
        dispatch_async(GlobalUserInteractiveQueue, {
            let realm           = try! Realm()
            let listings = realm.objects(AdvertisedListing).sorted("score", ascending: false)
            let listing  = listings[indexPath.item]
            
            guard let name          = listing.name else { return }
            guard let rentalRate    = listing.dailyRate.value else { return }
            let distance            = listing.distance
            guard let rating        = listing.rating.value else { return }
            
            
            dispatch_async(GlobalMainQueue, {
                cell.rentalRateLabel.text               = String(format: "$%0.2f", rentalRate)
                cell.distanceLabel.text                 = String(format: "%0.1f miles", distance)
                cell.titleLabel.text                    = name
                if rating < 0.0 {
                    cell.noRatingLabel.hidden = false
                    cell.ratingImageView.image = nil
                } else if rating >= 0.0 && rating < 1.0 {
                    cell.ratingImageView.image = UIImage(named: "1-Star")
                } else if rating >= 1.0 && rating < 2.0 {
                    cell.ratingImageView.image = UIImage(named: "2-Star")
                } else if rating >= 2.0 && rating < 3.0 {
                    cell.ratingImageView.image = UIImage(named: "3-Star")
                } else if rating >= 3.0 && rating < 4.0 {
                    cell.ratingImageView.image = UIImage(named: "4-Star")
                } else if rating >= 4.0 {
                    cell.ratingImageView.image = UIImage(named: "5-Star")
                }
            })
        })
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCellWithReuseIdentifier("AdvertisedListingSnapshot", forIndexPath: indexPath) as? RentCollectionViewCell else { return UICollectionViewCell() }
        
        // FIXME: Pull UI elements from centralized repo
        cell.layer.cornerRadius = 0.0
        
        cell.mainImageImageView.backgroundColor     = UIColor.lightGrayColor()
        cell.noRatingLabel.hidden                   = true
        cell.mainImageImageView.layer.cornerRadius  = kCORNER_RADIUS
        cell.mainImageImageView.contentMode         = UIViewContentMode.ScaleAspectFill
        cell.mainImageImageView.clipsToBounds       = true
        cell.mainImageImageView.layer.masksToBounds = true
        
        // Make an asynchronous request to grab the Listing data from the local cache
//        dispatch_async(GlobalUserInteractiveQueue, {
//            let realm               = try! Realm()
//            let advertisedListings  = realm.objects(AdvertisedListing).sorted("score", ascending: false)
//            let listing             = advertisedListings[indexPath.item]
            
            // If the Listing is a partial snapshot, grab more data to advertise the Listing
//            if listing.isPartialSnapshot {
//                guard let listingID = listing.listingID else { return }
//                self.model?.advertisedListingServiceProvider.downloadAdvertisedListingSnapshot(listingID, completionHandler: {
//                    (success:Bool) in
//                    if success {
        configureCell(cell, indexPath: indexPath)
//                    }
//                })
//            } else {
//                self.configureCell(cell, indexPath: indexPath)
//            }
//        })
    
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        let realm               = try! Realm()
        let advertisedListings  = realm.objects(AdvertisedListing).sorted("score", ascending: false)
        focusListing            = advertisedListings[indexPath.item]
        performSegueWithIdentifier("ShowRentItemDetails", sender: nil)
    }
    
    // MARK: - UI Actions
    @IBAction func menuButtonTapped(sender: AnyObject) {
        delegate?.openMenu()
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
        return CGSizeMake(view.bounds.width, view.bounds.height/6.0)
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAtIndex section: Int) -> UIEdgeInsets {
        return UIEdgeInsetsMake(8.0, 0.0, 8.0, 0.0)
    }
    
}


public protocol RentDelegate {
    func showLoginMenu()
    func openMenu()
}