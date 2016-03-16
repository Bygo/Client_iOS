//
//  RentRequestsVC.swift
//  Bygo_Client
//
//  Created by Nicholas Garfield on 4/2/16.
//  Copyright © 2016 Nicholas Garfield. All rights reserved.
//

import UIKit
import RealmSwift

class RentRequestsVC: UICollectionViewController, MeetingResponderDelegate {
    
    var model:Model?
    var delegate:RentRequestsDelegate?
    
    var listingIDsWithRentRequests:[String] = []
    
    @IBOutlet var noRentRequestsLabel:UILabel!
    @IBOutlet var meetingResponderContainer:UINavigationController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "didFetchNewRentRequest:", name: Notifications.DidFetchNewRentRequest.rawValue, object: nil)
        
        configureNoRentRequestsLabel()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    private func configureNoRentRequestsLabel() {
        noRentRequestsLabel                 = UILabel(frame: CGRectMake(12.0, 0, view.bounds.width-24.0, view.bounds.height))
        noRentRequestsLabel.font            = UIFont.systemFontOfSize(18.0)
        noRentRequestsLabel.textColor       = .darkGrayColor()
        noRentRequestsLabel.textAlignment   = .Center
        noRentRequestsLabel.numberOfLines   = 0
        noRentRequestsLabel.text            = "None of your Listings\nhave any Rent Requests"
        noRentRequestsLabel.hidden          = true
        view.addSubview(noRentRequestsLabel)
        view.sendSubviewToBack(noRentRequestsLabel)
    }
    
    // MARK: UICollectionViewDataSource
    
    override func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        // FIXME: Should be the number of different Items that have RentRequests
        listingIDsWithRentRequests = []
        
        guard let userID    = model?.userServiceProvider.getLocalUser()?.userID else { return 1 }
        let realm           = try! Realm()
        let rentEvents      = realm.objects(RentEvent).filter("ownerID == \"\(userID)\"  AND (status == \"Proposed\" OR status == \"Inquired\")")
        for i in 0..<rentEvents.count {
            let event = rentEvents[i]
            if let listingID = event.listingID {
                if !listingIDsWithRentRequests.contains(listingID) {
                    listingIDsWithRentRequests.append(listingID)
                }
            }
        }
        print(listingIDsWithRentRequests)
        
        if listingIDsWithRentRequests.count == 0 {
            noRentRequestsLabel.hidden = false
            view.bringSubviewToFront(noRentRequestsLabel)
            return 0
        } else {
            noRentRequestsLabel.hidden = true
            view.sendSubviewToBack(noRentRequestsLabel)
            return listingIDsWithRentRequests.count
        }
    }
    
    
    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let realm           = try! Realm()
        let count           = realm.objects(RentEvent).filter("listingID == \"\(listingIDsWithRentRequests[section])\" AND (status == \"Proposed\" OR status == \"Inquired\")").count
        
        if count == 0 { return 0 }
        else { return count + 1 }
    }
    
    
    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        if indexPath.row == 0 {
            guard let cell = collectionView.dequeueReusableCellWithReuseIdentifier("HeaderCell", forIndexPath: indexPath) as? RentRequestsHeaderCollectionViewCell else { return UICollectionViewCell() }
            
            dispatch_async(GlobalUserInitiatedQueue, {
                let realm           = try! Realm()
                let listingID       = self.listingIDsWithRentRequests[indexPath.section]
                guard let listing   = realm.objects(Listing).filter("listingID == \"\(listingID)\"").first else { return }
                guard let name      = listing.name else { return }
                let numRequests     = realm.objects(RentEvent).filter("listingID == \"\(listingID)\" AND (status == \"Proposed\" OR status == \"Inquired\")").count
                
                dispatch_async(GlobalMainQueue, {
                    cell.listingNameLabel.text = name
                    if numRequests == 1 { cell.numRequestsLabel.text = "1 Request" }
                    else                { cell.numRequestsLabel.text = "\(numRequests) Requests" }
                })
            })

            
            return cell
        } else {
            guard let cell = collectionView.dequeueReusableCellWithReuseIdentifier("RequestCell", forIndexPath: indexPath) as? RentRequestsCollectionViewCell else { return UICollectionViewCell() }
            
            // Configure cell image user image
            cell.userProfileImageView.layer.cornerRadius    = cell.userProfileImageView.bounds.width/2.0
            cell.userProfileImageView.contentMode           = UIViewContentMode.ScaleAspectFill
            cell.userProfileImageView.clipsToBounds         = true
            cell.userProfileImageView.layer.masksToBounds   = true
            cell.userProfileImageView.layer.borderWidth     = 0.0
            
            dispatch_async(GlobalUserInteractiveQueue, {
                let realm                   = try! Realm()
                let listingID               = self.listingIDsWithRentRequests[indexPath.section]
                let rentEvent               = realm.objects(RentEvent).filter("listingID == \"\(listingID)\"").sorted("dateCreated")[indexPath.row-1]
                guard let rentalRate        = rentEvent.rentalRate.value else { return }
                
                guard let renterID  = rentEvent.renterID else { return }
                self.model?.userServiceProvider.fetchUser(renterID, completionHandler: {
                    (success:Bool) in
                    let realm                   = try! Realm()
                    let renter                  = realm.objects(User).filter("userID == \"\(renterID)\"").first
                    guard let renterFirstName   = renter?.firstName else { return }
                    guard let renterLastName    = renter?.lastName  else { return }
                    
                    
                    dispatch_async(GlobalMainQueue, {
                        // Configure cell text labels
                        cell.userNameLabel.text     = "\(renterFirstName) \(renterLastName)"
                        cell.rentalRateLabel.text   = String(format: "$%.2f", rentalRate)
                        cell.userProfileImageView.image = UIImage(named: "sayan")
                    })
                })
            })
            
            return cell
        }
    }
    
    override func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
//        if indexPath.row != 0 {
//            showMeetingResponder(indexPath)
//        }
    }
    
//    func showMeetingResponder(focusItemID:String, proposalIndex:Int) {
//        guard let meetingSchedulerBundler = NSBundle(identifier: "com.NicholasGarfield.MeetingScheduler-iOS") else {
//            print("MeetingScheduler bundle not found")
//            return
//        }
//        let meetingSchedulerSB = UIStoryboard(name: "MeetingScheduler", bundle: meetingSchedulerBundler)
//        guard let navVC = meetingSchedulerSB.instantiateViewControllerWithIdentifier("MeetingResponse") as? UINavigationController else {
//            print("Could not get the navVC")
//            return
//        }
//        guard let meetingResponderVC = navVC.topViewController as? MeetingResponderVC else {
//            print("Could not get the meeting proposalVC")
//            return
//        }
//        
//        meetingResponderVC.model = self.model
//        meetingResponderVC.initialProposalIndex = proposalIndex
//        meetingResponderVC.focusItemID = focusItemID
//        
//        presentViewController(navVC, animated: true, completion: {
//            meetingResponderVC.reload()
//        })
//    }
    
    private func showMeetingResponder(indexPath:NSIndexPath) {
        let meetingSB               = UIStoryboard(name: "Meetings", bundle: NSBundle.mainBundle())
        meetingResponderContainer   = meetingSB.instantiateViewControllerWithIdentifier("MeetingResponse") as? UINavigationController
        let listingID               = listingIDsWithRentRequests[indexPath.section]
        (meetingResponderContainer?.topViewController as? MeetingResponderVC)?.listingID = listingID
        if (meetingResponderContainer?.topViewController as? MeetingResponderVC)?.model == nil {
            (meetingResponderContainer?.topViewController as? MeetingResponderVC)?.model = model
        }
        (meetingResponderContainer?.topViewController as? MeetingResponderVC)?.currentPage = indexPath.row-1
        (meetingResponderContainer?.topViewController as? MeetingResponderVC)?.delegate = self
        presentViewController(meetingResponderContainer, animated: true, completion: nil)
    }
    
    
    // MARK: - MeetingResponderDelegate
    func didRejectProposal() {
        collectionView?.reloadData()
        delegate?.rentRequestsDidUpdate()
    }
    
    func didAcceptProposal() {
        collectionView?.reloadData()
        delegate?.rentRequestsDidUpdate()
    }
    
    
    // MARK: - Notification Handlers
    func didFetchNewRentRequest(notification:NSNotification) {
        dispatch_async(GlobalMainQueue, {
            self.collectionView?.reloadData()
        })
    }
    
    
    // MARK: - UI Actions
    @IBAction func backButtonTapped(sender: AnyObject) {
        navigationController?.popViewControllerAnimated(true)
    }
    
    // MARK: - Navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
    }
    
}


// MARK: - UICollectionViewDelegate
extension RentRequestsVC : UICollectionViewDelegateFlowLayout {
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        if indexPath.row == 0 {
            return CGSizeMake(view.bounds.width, 80.0)
        } else {
            return CGSizeMake(view.bounds.width, view.bounds.height/5.0)
        }
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAtIndex section: Int) -> UIEdgeInsets {
        return UIEdgeInsetsMake(0, 0, 0, 0)
    }
}

protocol RentRequestsDelegate {
    func rentRequestsDidUpdate()
}