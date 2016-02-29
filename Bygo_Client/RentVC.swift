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
    @IBOutlet var collectionView: UICollectionView!
    @IBOutlet var refreshControl: UIRefreshControl! = UIRefreshControl()
    @IBOutlet var searchButton: UIBarButtonItem!
    
    var isSearching:Bool = false
    @IBOutlet var searchBar: SearchBar!
    
    var delegate:RentDelegate?
    var model:Model?
    var focusListing:AdvertisedListing?
    
    
    // MARK: - View Controller Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()

        // Add refresh control
        // refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: "refreshListings", forControlEvents: .ValueChanged)
        collectionView.addSubview(refreshControl)
        
        // UI Design
        navigationController?.navigationBar.barTintColor    = kCOLOR_ONE
        navigationController?.navigationBar.translucent     = false
        navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.whiteColor()]
        collectionView.backgroundColor = kCOLOR_THREE
        
        // SearchBar
        searchBar = SearchBar(frame: CGRectMake(view.bounds.width-40.0, 8.0, 30.0, 30.0))
        searchBar.alpha = 0.0
        navigationController?.navigationBar.addSubview(searchBar)
        
        refreshListings()
    }
    
    override func viewDidAppear(animated: Bool) {
        delegate?.didReturnToBaseLevelOfNavigation()
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
            let imageLink           = listing.imageLinks.first?.value
            
            
            dispatch_async(GlobalMainQueue, {
                cell.rentalRateLabel.text   = String(format: "$%0.2f", rentalRate)
                cell.distanceLabel.text     = String(format: "%0.1f miles", distance)
                cell.markerImageView.image  = UIImage(named: "Marker")?.imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate)
                cell.markerImageView.tintColor = .blackColor()
                cell.markerImageView.alpha  = 0.5
                cell.titleLabel.text        = name
                

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
                
                if let imageLink = imageLink {
                    let imageURL = NSURL(string: imageLink)!
                    cell.mainImageImageView.hnk_setImageFromURL(imageURL)
                    
                    guard let request = URLServiceProvider().getNewGETRequest(withURL: "\(imageLink)") else { return }
                    let session = NSURLSession.sharedSession()
                    let task = session.dataTaskWithRequest(request, completionHandler: { (data:NSData?, response:NSURLResponse?, error:NSError?) -> Void in
                        if error != nil {
                            return
                        }
                        
                        print("google: \(response)")
                        let d = String(data: data!, encoding: NSUTF8StringEncoding)
                        print(d)
                    })
                    task.resume()

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
        
        configureCell(cell, indexPath: indexPath)

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
    
    @IBAction func searchButtonTapped(sender: AnyObject) {
        if isSearching {
            hideSearchBar()
        } else {
            revealSearchBar()
        }
        isSearching = !isSearching
    }
    
    func revealSearchBar() {
        searchButton.title = "Cancel"
        searchButton.image = nil
        searchBar.becomeFirstResponder()
        searchBar.text = nil

        
        let targetWidth = self.view.bounds.width - 8.0 - 50.0 - 8.0 - 8.0 - 8.0
        navigationController?.navigationBar.bringSubviewToFront(searchBar)
        
        UIView.animateWithDuration(0.3, animations: {
            self.searchBar.frame = CGRectMake(8.0, self.searchBar.frame.origin.y, targetWidth, self.searchBar.bounds.height)
            self.searchBar.alpha = 1.0
            }, completion: {
                (complete:Bool) in
                if complete {
                self.navigationController?.navigationBar.layoutIfNeeded()
            }
        })
    }
    
    func hideSearchBar() {
        searchBar.resignFirstResponder()
        
        searchButton.title = nil
        searchButton.image = UIImage(named: "Search")
        
        UIView.animateWithDuration(0.3, animations: {
            self.searchBar.frame = CGRectMake(self.view.bounds.width-40.0, self.searchBar.frame.origin.y, self.searchBar.bounds.height, self.searchBar.bounds.height)
            self.searchBar.alpha = 0.0
            }, completion:  {
                (complete:Bool) in
                if complete {
                    self.navigationController?.navigationBar.layoutIfNeeded()
            }
        })
    }
    
    // MARK: - Navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "ShowRentItemDetails" {
            guard let destVC = segue.destinationViewController as? RentItemDetailsVC else { return }
            destVC.listing  = focusListing
            destVC.delegate = delegate
            destVC.model    = model
        }
        delegate?.didMoveOneLevelIntoNavigation()
    }
}

// MARK: - UICollectionViewDelegate
extension RentVC : UICollectionViewDelegateFlowLayout{
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        return CGSizeMake(view.bounds.width, view.bounds.height/6.0)
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAtIndex section: Int) -> UIEdgeInsets {
        return UIEdgeInsetsMake(8.0, 8.0, 8.0, 8.0)
    }
    
}


public protocol RentDelegate {
    func showLoginMenu()
    func openMenu()
    func didMoveOneLevelIntoNavigation()
    func didReturnToBaseLevelOfNavigation()
}