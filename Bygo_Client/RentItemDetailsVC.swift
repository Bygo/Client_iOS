//
//  RentItemDetailsVC.swift
//  Bygo_Client
//
//  Created by Nicholas Garfield on 3/2/16.
//  Copyright © 2016 Nicholas Garfield. All rights reserved.
//

import UIKit
import RealmSwift

class RentItemDetailsVC: UITableViewController, UICollectionViewDataSource, UICollectionViewDelegate {
    
    var listing:AdvertisedListing?
    var model:Model?
    
    @IBOutlet var itemTitleLabel: UILabel!
    @IBOutlet var hourlyRateLabel: UILabel!
    @IBOutlet var dailyRateLabel: UILabel!
    @IBOutlet var weeklyRateLabel: UILabel!
    @IBOutlet var ratingImageView: UIImageView!
    @IBOutlet var rentNowButton: UIButton!
    @IBOutlet var itemImagesScrollView: UIScrollView!
    @IBOutlet var headerView: UIView!
    
    private let kITEM_DESCRIPTION_SECTION = 0
    private let kRELATED_ITEMS_SECTION = 1
    private let kOWNER_PROFILE_SECTION = 2
    private let kCOMMENTS_SECTION = 3
    
    let HIDE_STATUS_BAR_ANIMATION_DURATION = 0.2
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // TODO: Load scroll view with item images
        itemImagesScrollView.backgroundColor = UIColor.lightGrayColor()
        ratingImageView.backgroundColor = UIColor.lightGrayColor()
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 80.0
        
        // Download the complete AdvertisedListing
        guard let listing   = listing else { return }
        guard let listingID = listing.listingID else { return }
        if listing.isSnapshot {
            model?.advertisedListingServiceProvider.downloadAdvertisedListingComplete(listingID, completionHandler: {
                (success:Bool) in
                if success {
                    self.tableView.reloadData()
                    self.loadHeaderView()
                } else {
                    print("Could not load Listing")
                }
            })
        }
        
        loadHeaderView()
    }
    
    
    // MARK: - Item Specific UI
    func loadHeaderView() {
        guard let listing = listing else { return }
        if listing.isSnapshot { return }
        itemTitleLabel.text     = listing.name
        guard let hourlyRate    = listing.hourlyRate.value else { return }
        guard let dailyRate     = listing.dailyRate.value  else { return }
        guard let weeklyRate    = listing.weeklyRate.value else { return }
        hourlyRateLabel.text    = String(format: "$%.2f/hour", hourlyRate)
        dailyRateLabel.text     = String(format: "$%.2f/day", dailyRate)
        weeklyRateLabel.text    = String(format: "$%.2f/week", weeklyRate)
        
        let imageView = UIImageView(frame: CGRectMake(0, 0, view.bounds.width, itemImagesScrollView.bounds.height))
        imageView.contentMode           = UIViewContentMode.ScaleAspectFill
        imageView.clipsToBounds         = true
        imageView.layer.masksToBounds   = true
        
        self.headerView.addSubview(imageView)
    }
    
    // MARK: - Table view data source
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        guard let listing = listing else { return 0 }
        if listing.isSnapshot { return 0 }
        return 3
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        switch section {
        case kITEM_DESCRIPTION_SECTION:
            return 1
        case kRELATED_ITEMS_SECTION:
            return 1
        case kOWNER_PROFILE_SECTION:
            return 1
        case kCOMMENTS_SECTION:
            return 0
        default:
            return 0
        }
    }
    
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        guard let listing = listing else { return UITableViewCell() }
        if listing.isSnapshot { return UITableViewCell() }
        
        // Configure the cell...
        switch indexPath.section {
        case kITEM_DESCRIPTION_SECTION: // Item description
            guard let cell = tableView.dequeueReusableCellWithIdentifier("DetailsCell", forIndexPath: indexPath) as? RentItemDescriptionTableViewCell else { return UITableViewCell() }
            cell.descriptionLabel.text = listing.itemDescription
            cell.setNeedsUpdateConstraints()
            cell.updateConstraintsIfNeeded()
            return cell
            
            
        case kRELATED_ITEMS_SECTION:
            guard let cell = tableView.dequeueReusableCellWithIdentifier("RelatedItemsCell", forIndexPath: indexPath) as? RelatedRentItemsTableViewCell else { return UITableViewCell() }
            cell.collectionView.delegate = self
            cell.collectionView.dataSource = self
            // TODO: Load top 5 related items from server
            return cell
            
        case kOWNER_PROFILE_SECTION:
            // FIXME: Create an actual user profile cell
            guard let cell = tableView.dequeueReusableCellWithIdentifier("UserProfileCell", forIndexPath: indexPath) as? RentItemUserProfileTableViewCell else { return UITableViewCell() }
            
            cell.profileImageView.contentMode = UIViewContentMode.ScaleAspectFill
            cell.profileImageView.backgroundColor = .lightGrayColor()
            cell.profileImageView.clipsToBounds = true
            cell.profileImageView.layer.cornerRadius = cell.profileImageView.bounds.width/2.0
            cell.profileImageView.layer.masksToBounds = true
            
            if let ownerID = listing.ownerID {
                model?.userServiceProvider.queryForUser(ownerID, completionHandler: {
                    (owner:User?) in
                    if let owner = owner {
                        guard let firstName = owner.firstName else { return }
                        guard let lastName  = owner.lastName  else { return }
                        cell.nameLabel.text = "\(firstName) \(lastName)"
                    }
                })
            }
            
            return cell
            
        case kCOMMENTS_SECTION:
            guard let cell = tableView.dequeueReusableCellWithIdentifier("CommentCell", forIndexPath: indexPath) as? RentItemReviewTableViewCell else { return UITableViewCell() }
            // TODO: Load top 5 comments from server
            cell.commenterNameLabel.text = "Sayan"
            cell.dateLabel.text = "Nov 23"
            cell.commentLabel.text = "Rented this Xbox out for the weekend to game with some friends. Worked perfectly. Nice price. No problems."
            cell.ratingImageView.backgroundColor = .lightGrayColor()
            cell.setNeedsUpdateConstraints()
            cell.updateConstraintsIfNeeded()
            return cell
        default:
            return UITableViewCell()
        }
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        switch indexPath.section {
        case kRELATED_ITEMS_SECTION:
            return 166.0
        default:
            return UITableViewAutomaticDimension
        }
    }
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case kITEM_DESCRIPTION_SECTION:
            return "Description"
        case kOWNER_PROFILE_SECTION:
            return "Owner"
        case kRELATED_ITEMS_SECTION:
            return "Related Items"
        case kCOMMENTS_SECTION:
            return "Reviews"
        default:
            return ""
        }
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
    }
    
    
    // MARK: - CollectionView DataSource
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 5
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCellWithReuseIdentifier("RelatedItemCell", forIndexPath: indexPath) as? RelatedRentItemCollectionViewCell else { return UICollectionViewCell() }
        cell.layer.borderColor = UIColor.lightGrayColor().CGColor
        cell.layer.borderWidth = 1.0
        // FIXME: Pull from global UI repo
        cell.layer.cornerRadius = 0.0
        cell.imageView.backgroundColor = .lightGrayColor()
        cell.itemTitleLabel.text = "PlayStation 4"
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        // focusItem = item.relatedItems[indexPath.row]
        // TODO: Set the focus item
    }
    
    
    // MARK: - UI Actions
    @IBAction func rentNowButtonTapped(sender: AnyObject) {
        // TODO: Send rent request for the item
        // TODO: If success present success pop-up
//        guard let model = model else { return }
//        if model.isLocalUserLoggedIn() {
//            showMeetingProposal()
//        } else {
//            showLoginMenu()
//        }
    }
    
    func showLoginMenu() {
//        guard let loginBundle = NSBundle(identifier: "com.NicholasGarfield.Login-iOS") else {
//            print("Login bundle not found")
//            return
//        }
//        let loginSB = UIStoryboard(name: "Login", bundle: loginBundle)
//        let loginVC = loginSB.instantiateInitialViewController()
//        presentViewController(loginVC!, animated: true, completion: nil)
    }
    
    func showMeetingProposal() {
//        guard let meetingSchedulerBundler = NSBundle(identifier: "com.NicholasGarfield.MeetingScheduler-iOS") else {
//            print("MeetingScheduler bundle not found")
//            return
//        }
//        let meetingSchedulerSB = UIStoryboard(name: "MeetingScheduler", bundle: meetingSchedulerBundler)
//        guard let navVC = meetingSchedulerSB.instantiateViewControllerWithIdentifier("MeetingProposal") as? UINavigationController else {
//            print("Could not get the navVC")
//            return
//        }
//        guard let meetingProposalVC = navVC.topViewController as? MeetingProposalVC else {
//            print("Could not get the meeting proposalVC")
//            return
//        }
//        meetingProposalVC.model = self.model
//        meetingProposalVC.item = self.item
//        meetingProposalVC.rentalRate = self.item?.dailyRate
//        meetingProposalVC.timeFrame = .Day
//        presentViewController(navVC, animated: true, completion: nil)
    }
    
    // MARK: - Navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
//        if segue.identifier == "ShowRelatedItem" {
//            guard let destVC = segue.destinationViewController as? RentItemDetailsVC else { return }
//            destVC.item = item
//        }
    }
}


private let sectionInset:CGFloat = 8.0
extension RentItemDetailsVC : UICollectionViewDelegateFlowLayout {
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        return CGSizeMake(view.bounds.width/2.0, 150.0)
    }
    
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAtIndex section: Int) -> UIEdgeInsets {
        return UIEdgeInsetsMake(sectionInset, sectionInset, sectionInset, sectionInset)
    }
}
