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
    
    @IBOutlet var meetingProposalContainer:UINavigationController!
    var listing:AdvertisedListing?
    var delegate:RentDelegate?
    var model:Model?
    
    @IBOutlet var itemTitleLabel: UILabel!
    @IBOutlet var hourlyRateLabel: UILabel!
    @IBOutlet var dailyRateLabel: UILabel!
    @IBOutlet var weeklyRateLabel: UILabel!
    @IBOutlet var ratingImageView: UIImageView!
    @IBOutlet var noRatingLabel: UILabel!
    @IBOutlet var rentNowButton: UIButton!
    @IBOutlet var inquireButton: UIButton!
    @IBOutlet var listingImagesCollectionView: UICollectionView!
    @IBOutlet var headerView: UIView!
    
    private let kITEM_DESCRIPTION_SECTION = 0
    private let kRELATED_ITEMS_SECTION = 1
    private let kOWNER_PROFILE_SECTION = 2
    private let kCOMMENTS_SECTION = 3
    
    let HIDE_STATUS_BAR_ANIMATION_DURATION = 0.2
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // TODO: Load scroll view with item images
        tableView.rowHeight             = UITableViewAutomaticDimension
        tableView.estimatedRowHeight    = 80.0
        
        rentNowButton.backgroundColor   = kCOLOR_SIX
        inquireButton.backgroundColor   = kCOLOR_FIVE
        tableView.backgroundColor       = .whiteColor()
        
        loadHeaderView()
        tableView.reloadData()
        
        // Download the complete AdvertisedListing
        guard let listing   = listing           else { return }
        guard let listingID = listing.listingID else { return }
        if listing.isSnapshot {
            model?.advertisedListingServiceProvider.downloadAdvertisedListingComplete(listingID, completionHandler: {
                (success:Bool) in
                if success {
                    self.loadHeaderView()
                    self.tableView.reloadData()
                } else {
                    print("Could not load Listing")
                }
            })
        }
    }
    
    
    // MARK: - Item Specific UI
    func loadHeaderView() {
        headerView.heightAnchor.constraintEqualToConstant(rentNowButton.frame.origin.y + rentNowButton.bounds.height + 8.0)
        
        guard let listing = listing else { return }
        if listing.isSnapshot { return }
        itemTitleLabel.text = listing.name
        
        noRatingLabel.hidden = true
        if let rating = listing.rating.value {
            if rating < 0.0 {
                noRatingLabel.hidden = false
            }else if rating >= 0.0 && rating < 1.0 {
                ratingImageView.image = UIImage(named: "1-Star")
            } else if rating >= 1.0 && rating < 2.0 {
                ratingImageView.image = UIImage(named: "2-Star")
            } else if rating >= 2.0 && rating < 3.0 {
                ratingImageView.image = UIImage(named: "3-Star")
            } else if rating >= 3.0 && rating < 4.0 {
                ratingImageView.image = UIImage(named: "4-Star")
            } else if rating >= 4.0 {
                ratingImageView.image = UIImage(named: "5-Star")
            }
        } else {
            noRatingLabel.hidden = false
        }
        
//        guard let hourlyRate    = listing.hourlyRate.value else { return }
//        guard let dailyRate     = listing.dailyRate.value  else { return }
//        guard let weeklyRate    = listing.weeklyRate.value else { return }
//        hourlyRateLabel.text    = String(format: "$%.2f/hour", hourlyRate)
//        dailyRateLabel.text     = String(format: "$%.2f/day", dailyRate)
//        weeklyRateLabel.text    = String(format: "$%.2f/week", weeklyRate)
        
        headerView.bringSubviewToFront(listingImagesCollectionView)
    }
    
    // MARK: - Table view data source
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
//        guard let listing = listing else { return 0 }
//        if listing.isSnapshot { return 0 }
//        return 3
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
//        switch section {
//        case kITEM_DESCRIPTION_SECTION:
//            return 1
//        case kRELATED_ITEMS_SECTION:
//            return 1
//        case kOWNER_PROFILE_SECTION:
//            return 1
//        case kCOMMENTS_SECTION:
//            return 0
//        default:
//            return 0
//        }
        return 3
    }
    
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        guard let listing = listing else { return UITableViewCell() }
        if listing.isSnapshot { return UITableViewCell() }
        
        // Configure the cell...
        switch indexPath.row {
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
            
            cell.profileImageView.contentMode           = UIViewContentMode.ScaleAspectFill
            cell.profileImageView.backgroundColor       = .lightGrayColor()
            cell.profileImageView.clipsToBounds         = true
            cell.profileImageView.layer.cornerRadius    = cell.profileImageView.bounds.width/2.0
            cell.profileImageView.layer.masksToBounds   = true
            
            if let ownerID = listing.ownerID {
                print("OWNER PROFILE: \(ownerID)")
                model?.userServiceProvider.fetchUser(ownerID, completionHandler: {
                    (success:Bool) in
                    if success {
                        print("Got the user!")
                        let realm           = try! Realm()
                        let owner           = realm.objects(User).filter("userID == \"\(ownerID)\"").first
                        guard let firstName = owner?.firstName  else { return }
                        guard let lastName  = owner?.lastName   else { return }
                        
                        dispatch_async(GlobalMainQueue, {
                            cell.nameLabel.text = "\(firstName) \(lastName)"
                            cell.profileImageView.image = UIImage(named: "sayan")
                        })
                        
//                        guard let imageMediaLink = owner?.profileImageLink else { return }
//                        guard let url = NSURL(string: imageMediaLink) else { return }
//                        
//                        dispatch_async(GlobalMainQueue, {
//                            cell.profileImageView.hnk_setImageFromURL(url)
//                        })
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
        switch indexPath.row {
        case kRELATED_ITEMS_SECTION:
            return 150.0
        default:
            return UITableViewAutomaticDimension
        }
    }
    

    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
    }
    
    
    // MARK: - CollectionView DataSource
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        if collectionView == listingImagesCollectionView {
            if let count = listing?.imageLinks.count {
                return 1
//                return count
            } else {
                return 0
            }
        } else {
            return 5
        }
        
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        if collectionView == listingImagesCollectionView {
            
            guard let cell = collectionView.dequeueReusableCellWithReuseIdentifier("ListingImageCell", forIndexPath: indexPath) as? ListingImageCollectionViewCell else { return UICollectionViewCell() }
            
            
//            guard let imgLink = listing?.imageLinks[indexPath.row].value else { return cell }
//            guard let url = NSURL(string: imgLink) else { return cell }
            cell.imageView.contentMode          = UIViewContentMode.ScaleAspectFill
            cell.imageView.clipsToBounds        = true
            cell.imageView.layer.masksToBounds  = true
            cell.layer.cornerRadius             = kCORNER_RADIUS
            
//            cell.imageView.hnk_setImageFromURL(url)
            
            if let id = listing?.listingID {
                switch id {
                case "2": cell.imageView.image = UIImage(named: "tent")
                case "3": cell.imageView.image = UIImage(named: "xbox")
                case "4": cell.imageView.image = UIImage(named: "board")
                default: break
                }
            }
            
            return cell
            
        } else {
            
            guard let cell = collectionView.dequeueReusableCellWithReuseIdentifier("RelatedItemCell", forIndexPath: indexPath) as? RelatedRentItemCollectionViewCell else { return UICollectionViewCell() }
            
            // FIXME: Pull from global UI repo
            cell.imageView.layer.cornerRadius = kCORNER_RADIUS * 4.0
            cell.imageView.clipsToBounds = true
            cell.imageView.backgroundColor  = .lightGrayColor()
            cell.itemTitleLabel.text        = "Related Item \(indexPath.row)"
            cell.itemTitleLabel.backgroundColor = kCOLOR_THREE
            return cell
            
        }
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        // focusItem = item.relatedItems[indexPath.row]
        // TODO: Set the focus item
    }
    
    
    // MARK: - UI Actions
    @IBAction func rentNowButtonTapped(sender: AnyObject) {
        // TODO: Send rent request for the item
        // TODO: If success present success pop-up
        guard let model = model else { return }
        if model.userServiceProvider.isLocalUserLoggedIn() {
            showMeetingProposal()
        } else {
            showMeetingProposal()
        }
    }
    
    private func showLoginMenu() {
        delegate?.showLoginMenu()
    }
    
    private func showMeetingProposal() {
        let meetingSB = UIStoryboard(name: "Meetings", bundle: NSBundle.mainBundle())
        meetingProposalContainer = meetingSB.instantiateViewControllerWithIdentifier("MeetingProposal") as? UINavigationController
        guard let rentalRate = listing?.dailyRate.value else {
            return
        }
        
        (meetingProposalContainer?.topViewController as? MeetingProposalVC)?.model      = model
        (meetingProposalContainer?.topViewController as? MeetingProposalVC)?.listing    = listing
        (meetingProposalContainer?.topViewController as? MeetingProposalVC)?.rentalRate = rentalRate
        (meetingProposalContainer?.topViewController as? MeetingProposalVC)?.timeFrame  = .Day
        presentViewController(meetingProposalContainer, animated: true, completion: nil)
    }
    
    
    // MARK: - UI Actions
    @IBAction func backButtonTapped(sender: AnyObject) {
        navigationController?.popToRootViewControllerAnimated(true)
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
        
        if collectionView == listingImagesCollectionView {
            return CGSizeMake(collectionView.bounds.width-16.0, collectionView.bounds.width-16.0)
        } else {
            return CGSizeMake(view.bounds.width/2.0, view.bounds.width/2.0)
        }
    }
    
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAtIndex section: Int) -> UIEdgeInsets {
        
        if collectionView == listingImagesCollectionView {
            return UIEdgeInsetsMake(8.0, 8.0, 8.0, 8.0)
        } else {
            return UIEdgeInsetsMake(0.0, sectionInset, 0.0, sectionInset)
        }
    }
    
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAtIndex section: Int) -> CGFloat {
        return 16.0
    }
}
