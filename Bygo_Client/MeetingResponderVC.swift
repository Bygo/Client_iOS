//
//  MeetingResponderVC.swift
//  Bygo_Client
//
//  Created by Nicholas Garfield on 5/2/16.
//  Copyright © 2016 Nicholas Garfield. All rights reserved.
//

import UIKit
import RealmSwift

private let kTIME_PROPOSAL_SECTION      = 0
private let kLOCATION_PROPOSAL_SECTION  = 1
private let kRESPONSE_BUTTONS_SECTION   = 2

class MeetingResponderVC: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UITableViewDataSource, UITableViewDelegate, MeetingTimeResponderViewDataSource, MeetingTimeResponderViewDelegate {

    var model:Model?
    var listingID:String?
    var currentPage:Int?
    var delegate:MeetingResponderDelegate?
    
    @IBOutlet var noRentRequestsLabel:UILabel!
    @IBOutlet var collectionView: UICollectionView!
    @IBOutlet var itemRequestIndicatorLabel: UILabel!
    @IBOutlet var cancelButton: UIBarButtonItem!
    
//    var proposedLocations:[String:[FavoriteMeetingLocation]]    = [:]
    var acceptedLocations:[String:String]           = [:]
    var acceptedTimes:[String:ProposedMeetingTime]  = [:]
    
    // MARK: - View Controller Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // UI Design
        navigationController?.navigationBar.barTintColor    = kCOLOR_ONE
        navigationController?.navigationBar.translucent     = false
        navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.whiteColor()]
        
        configureNoRentRequestsLabel()
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent
    }
    
    override func viewDidAppear(animated: Bool) {
        if let currentPage = currentPage {
            collectionView.scrollToItemAtIndexPath(NSIndexPath(forItem: currentPage, inSection: 0), atScrollPosition: .CenteredHorizontally, animated: true)
        }
    }

    private func configureNoRentRequestsLabel() {
        noRentRequestsLabel                 = UILabel(frame: CGRectMake(12.0, 0, view.bounds.width-24.0, view.bounds.height))
        noRentRequestsLabel.font            = UIFont.systemFontOfSize(18.0)
        noRentRequestsLabel.textColor       = .darkGrayColor()
        noRentRequestsLabel.textAlignment   = .Center
        noRentRequestsLabel.numberOfLines   = 0
        noRentRequestsLabel.text            = "This Listing does not\nhave any Rent Requests"
        noRentRequestsLabel.hidden          = true
        view.addSubview(noRentRequestsLabel)
        view.sendSubviewToBack(noRentRequestsLabel)
    }
    
    // MARK: - CollectionView Data Source
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    private func getNumberOfProposals() -> Int {
        guard let listingID = listingID else { return 0 }
        let realm           = try! Realm()
        return realm.objects(RentEvent).filter("listingID == \"\(listingID)\" AND (status == \"Proposed\" OR status == \"Inquired\")").count
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let count = getNumberOfProposals()
        if count == 0 {
            noRentRequestsLabel.hidden = false
            view.bringSubviewToFront(noRentRequestsLabel)
            return 0
        } else {
            noRentRequestsLabel.hidden = true
            view.sendSubviewToBack(noRentRequestsLabel)
            return count
        }
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCellWithReuseIdentifier("ItemRequestCell", forIndexPath: indexPath) as? MeetingResponderCollectionViewCell else { return UICollectionViewCell() }
        
        print("Collection view cell")
        cell.tableView.heightAnchor.constraintEqualToConstant(view.bounds.height).active    = true
        cell.tableView.widthAnchor.constraintEqualToConstant(view.bounds.width).active      = true
        cell.tableView.dataSource           = self
        cell.tableView.delegate             = self
        cell.tableView.rowHeight            = UITableViewAutomaticDimension
        cell.tableView.estimatedRowHeight   = 80.0
        cell.tableView.tag                  = indexPath.item
        cell.tableView.reloadData()
        
        if let navBarHeight = navigationController?.navigationBar.bounds.height {
            let statusBarHeight = UIApplication.sharedApplication().statusBarFrame.height
            cell.tableView.contentInset             = UIEdgeInsetsMake(navBarHeight+statusBarHeight, 0, 0, 0)
            cell.tableView.scrollIndicatorInsets    = UIEdgeInsetsMake(navBarHeight+statusBarHeight, 0, 0, 0)
        }
        
        cell.tableView.contentOffset.y = -200.0
        
        guard let currentPage   = currentPage   else { return cell }
        guard let listingID     = listingID     else { return cell }
        let realm               = try! Realm()
        let rentEvent           = realm.objects(RentEvent).filter("listingID == \"\(listingID)\"")[currentPage]
        guard let renterID      = rentEvent.renterID else { return cell }
        model?.userServiceProvider.fetchUser(renterID, completionHandler: {
            (success:Bool) in
            if success {
                let realm           = try! Realm()
                let renter          = realm.objects(User).filter("userID == \"\(renterID)\"").first
                guard let firstName = renter?.firstName else { return }
                guard let lastName  = renter?.lastName  else { return }
                
                dispatch_async(GlobalMainQueue, {
                    cell.renterImageImageView.layer.cornerRadius    = cell.renterImageImageView.bounds.width/2.0
                    cell.renterImageImageView.contentMode           = UIViewContentMode.ScaleAspectFill
                    cell.renterImageImageView.clipsToBounds         = true
                    cell.renterImageImageView.layer.masksToBounds   = true
                    cell.renterImageImageView.layer.borderWidth     = 0.0
                    cell.renterImageImageView.backgroundColor       = .lightGrayColor()
                    cell.renterNameLabel.text                       = "\(firstName) \(lastName)"
                })
            }
        })
        print(cell.tableView.contentOffset)
        
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, didEndDisplayingCell cell: UICollectionViewCell, forItemAtIndexPath indexPath: NSIndexPath) {
        guard let cell = cell as? MeetingResponderCollectionViewCell else { return }
        cell.tableView.contentOffset.y = 0.0
    }
    
    // MARK: - TableView Data Source
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 3
    }
    
    private func isDataValid(proposalIndex:Int) -> Bool {
        guard let listingID     = listingID else { return false }
        let realm               = try! Realm()
        let rentEvents          = realm.objects(RentEvent).filter("listingID == \"\(listingID)\" AND (status == \"Proposed\" OR status == \"Inquired\")").sorted("dateCreated")
        guard let meetingID     = rentEvents[proposalIndex].startMeetingEventID                             else { return false }
        guard let meetingEvent  = realm.objects(MeetingEvent).filter("meetingID == \"\(meetingID)\"").first else { return false }
        if meetingEvent.time == nil         { return false }
        if meetingEvent.locationID == nil   { return false }
        return true
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case kTIME_PROPOSAL_SECTION:    return 1
        case kLOCATION_PROPOSAL_SECTION:
            guard let listingID     = listingID else { return 0 }
            let realm               = try! Realm()
            let rentEvents          = realm.objects(RentEvent).filter("listingID == \"\(listingID)\" AND (status == \"Proposed\" OR status == \"Inquired\")").sorted("dateCreated")
            guard let meetingID     = rentEvents[tableView.tag].startMeetingEventID                             else { return 0 }
            guard let meetingEvent  = realm.objects(MeetingEvent).filter("meetingID == \"\(meetingID)\"").first else { return 0 }
            return meetingEvent.proposedMeetingLocations.count
        case kRESPONSE_BUTTONS_SECTION: return 2
        default:                        return 0
        }
    }
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case kTIME_PROPOSAL_SECTION:        return ""
        case kLOCATION_PROPOSAL_SECTION:    return "Prefered Locations"
        default:                            return nil
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        switch indexPath.section {
        case kTIME_PROPOSAL_SECTION:
            guard let cell = tableView.dequeueReusableCellWithIdentifier("TimeProposalCell", forIndexPath: indexPath) as? MeetingTimeResponderTableViewCell else { return UITableViewCell() }
            tableView.rowHeight                             = UITableViewAutomaticDimension
            cell.timeConfirmationView.dataSource            = self
            cell.timeConfirmationView.delegate              = self
            cell.timeConfirmationView.layer.cornerRadius    = 0.0
            cell.timeConfirmationView.proposalIndex         = tableView.tag
            let tapGestureRecognizer                        = UITapGestureRecognizer(target: self, action: #selector(MeetingResponderVC.tapGestureRecognized(_:)))
            let panGestureRecognizer                        = UIPanGestureRecognizer(target: self, action: #selector(MeetingResponderVC.panGestureRecognized(_:)))
            cell.timeConfirmationView.addGestureRecognizer(tapGestureRecognizer)
            cell.timeConfirmationView.addGestureRecognizer(panGestureRecognizer)
            cell.timeConfirmationView.reload()
            return cell
            
        case kLOCATION_PROPOSAL_SECTION:
            guard let cell = tableView.dequeueReusableCellWithIdentifier("LocationProposalCell", forIndexPath: indexPath) as? MeetingLocationProposalTableViewCell else { return UITableViewCell() }
            configureLocationCell(cell, indexPath: indexPath, proposalIndx: tableView.tag)
            return cell
            
        case kRESPONSE_BUTTONS_SECTION:
            let cell = UITableViewCell()
            cell.textLabel?.textAlignment = .Center
            switch indexPath.row {
            case 0:
                cell.textLabel?.text = "Accept Item Request"
                cell.backgroundColor = .blueColor()
                cell.textLabel?.textColor = .whiteColor()
            case 1:
                cell.textLabel?.text = "Reject"
                cell.textLabel?.textColor = .redColor()
            default:
                return cell
            }
            return cell
            
        default:
            return UITableViewCell()
        }
    }
    
    private func configureLocationCell(cell:MeetingLocationProposalTableViewCell, indexPath:NSIndexPath, proposalIndx:Int) {
        guard let listingID     = listingID else { return }
        let realm               = try! Realm()
        let rentEvents          = realm.objects(RentEvent).filter("listingID == \"\(listingID)\" AND (status == \"Proposed\" OR status == \"Inquired\")").sorted("dateCreated")
        guard let meetingID     = rentEvents[proposalIndx].startMeetingEventID                             else { return }
        guard let meetingEvent  = realm.objects(MeetingEvent).filter("meetingID == \"\(meetingID)\"").first else { return }
        guard let locationID    = meetingEvent.proposedMeetingLocations[indexPath.row].value                   else { return }
        let isSelected          = acceptedLocations[meetingID] == locationID
        
        model?.favoriteMeetingLocationServiceProvider.fetchFavoriteMeetingLocations([locationID], completionHandler: {
            (success:Bool) in
            if success {
                let realm = try! Realm()
                guard let location = realm.objects(FavoriteMeetingLocation).filter("locationID == \"\(locationID)\"").first else { return }
                guard let name = location.name else { return }
                
                dispatch_async(GlobalMainQueue, {
                    cell.locationNameLabel.text = name
                    if isSelected {
                        cell.selectedMarkerButton.backgroundColor = .greenColor()
                    } else {
                        cell.selectedMarkerButton.backgroundColor = .clearColor()
                    }
                })
            }
        })
    }
    
    // MARK: - TableView Delegate
    func tableView(tableView: UITableView, willSelectRowAtIndexPath indexPath: NSIndexPath) -> NSIndexPath? {
        switch indexPath.section {
        case kTIME_PROPOSAL_SECTION:        return nil
        case kLOCATION_PROPOSAL_SECTION:
            guard let listingID     = listingID else { return indexPath }
            let realm               = try! Realm()
            let rentEvents          = realm.objects(RentEvent).filter("listingID == \"\(listingID)\" AND (status == \"Proposed\" OR status == \"Inquired\")").sorted("dateCreated")
            guard let meetingID     = rentEvents[tableView.tag].startMeetingEventID                             else { return indexPath }
            guard let meetingEvent  = realm.objects(MeetingEvent).filter("meetingID == \"\(meetingID)\"").first else { return indexPath }
            guard let locationID    = meetingEvent.proposedMeetingLocations[indexPath.row].value                else { return indexPath }
            
            if let currentlyAcceptedLocationID = acceptedLocations[meetingID] {
                if currentlyAcceptedLocationID == locationID {
                    acceptedLocations.removeValueForKey(meetingID)
                } else {
                    acceptedLocations.updateValue(locationID, forKey: meetingID)
                }
            } else {
                acceptedLocations[meetingID] = locationID
            }
            
            for i in 0..<tableView.numberOfRowsInSection(kLOCATION_PROPOSAL_SECTION) {
                let cell = tableView.cellForRowAtIndexPath(NSIndexPath(forRow: i, inSection: kLOCATION_PROPOSAL_SECTION)) as? MeetingLocationProposalTableViewCell
                if i == indexPath.row && acceptedLocations[meetingID] != nil {
                    cell?.selectedMarkerButton.backgroundColor = .greenColor()
                } else {
                    cell?.selectedMarkerButton.backgroundColor = .clearColor()
                }
            }
            return indexPath
            
        case kRESPONSE_BUTTONS_SECTION:     return indexPath
        default:                            return nil
        }
    }
    
    func tableView(tableView: UITableView, shouldHighlightRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        switch indexPath.section {
        case kTIME_PROPOSAL_SECTION:        return false
        case kLOCATION_PROPOSAL_SECTION:    return true
        case kRESPONSE_BUTTONS_SECTION:     return true
        default:                            return false
        }
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        switch indexPath.section {
        case kLOCATION_PROPOSAL_SECTION:
            guard let listingID     = listingID else { return }
            let realm               = try! Realm()
            let rentEvents          = realm.objects(RentEvent).filter("listingID == \"\(listingID)\" AND (status == \"Proposed\" OR status == \"Inquired\")").sorted("dateCreated")
            guard let meetingID     = rentEvents[tableView.tag].startMeetingEventID else { return }
            
            for i in 0..<tableView.numberOfRowsInSection(kLOCATION_PROPOSAL_SECTION) {
                let cell = tableView.cellForRowAtIndexPath(NSIndexPath(forRow: i, inSection: kLOCATION_PROPOSAL_SECTION)) as? MeetingLocationProposalTableViewCell
                if i == indexPath.row && acceptedLocations[meetingID] != nil {
                    cell?.selectedMarkerButton.backgroundColor = .greenColor()
                } else {
                    cell?.selectedMarkerButton.backgroundColor = .clearColor()
                }
            }
            
            tableView.deselectRowAtIndexPath(indexPath, animated: false)

        case kRESPONSE_BUTTONS_SECTION:
            // Send request to model
            guard let listingID     = listingID else { return }
            let realm               = try! Realm()
            let rentEvent          = realm.objects(RentEvent).filter("listingID == \"\(listingID)\" AND (status == \"Proposed\" OR status == \"Inquired\")").sorted("dateCreated")[tableView.tag]
            guard let eventID       = rentEvent.eventID             else { return }
            guard let meetingID     = rentEvent.startMeetingEventID else { return }
//            guard let meetingEvent  = realm.objects(MeetingEvent).filter("meetingID == \"\(meetingID)\"").first else { return }
            
            
            // TODO: Should probably also auto-reject all other rentEvents on this same Listing
            // Could solve this by iterating for-loop over rentEvents on this listing in the indexPath.row == 0
            // For the rentEvent at [tableView.tag], accept
            // For all else, reject
            
            if indexPath.row == 0 {
                print("Time")
                guard let time          = acceptedTimes[meetingID]?.time    else { return }
                print("Loc")
                guard let locationID    = acceptedLocations[meetingID]      else { return }
                print("Gotem")
                model?.rentServiceProvider.acceptRentRequest(eventID, listingID: listingID, time: time, locationID: locationID, completionHandler: {
                    (success:Bool) in
                    if success {
                        // TODO: Update UI based on new accepted RentEvent
                        dispatch_async(GlobalMainQueue, {
                            self.delegate?.didAcceptProposal()
                            self.dismissViewControllerAnimated(true, completion: nil)
                        })
                    }
                })
            } else if indexPath.row == 1 {
                model?.rentServiceProvider.rejectRentRequest(eventID, completionHandler: {
                    (success:Bool) in
                    if success {
                        
                        // Update UI based on new rejected RentEvent
                        dispatch_async(GlobalMainQueue, {
                            self.delegate?.didRejectProposal()
                            self.collectionView.performBatchUpdates({
                                self.collectionView.deleteItemsAtIndexPaths([NSIndexPath(forItem: tableView.tag, inSection: 0)])
                            }, completion: nil)
                        })
                    }
                })
            }
            
        default: break
        }
    }
    
    
    
    // MARK: - ScrollView Delegate
    func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
        if scrollView == collectionView {
            currentPage = Int(collectionView.contentOffset.x / collectionView.bounds.width)
        }
    }
    
    // TODO: Add paging functionality to chance the request counter in the top bar
    // MARK: - UI Actions
    @IBAction func panGestureRecognized(recognizer: UIPanGestureRecognizer) {
        guard let timeConfirmationView = recognizer.view as? MeetingTimeResponderView else { return }
        timeConfirmationView.selectTimeAtLocation(recognizer.locationInView(timeConfirmationView))
    }
    
    @IBAction func tapGestureRecognized(recognizer: UITapGestureRecognizer) {
        guard let timeConfirmationView = recognizer.view as? MeetingTimeResponderView else { return }
        timeConfirmationView.selectTimeAtLocation(recognizer.locationInView(timeConfirmationView))
    }
    
    @IBAction func cancelButtonTapped(sender: AnyObject) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    // MARK: - MeetingTimeResponderViewDataSource
    func numProposedMeetingTimes(proposalIndex:Int) -> Int {
        guard let listingID     = listingID else { return 0 }
        let realm               = try! Realm()
        let rentEvents          = realm.objects(RentEvent).filter("listingID == \"\(listingID)\" AND (status == \"Proposed\" OR status == \"Inquired\")").sorted("dateCreated")
        guard let meetingID     = rentEvents[proposalIndex].startMeetingEventID                             else { return 0 }
        guard let meetingEvent  = realm.objects(MeetingEvent).filter("meetingID == \"\(meetingID)\"").first else { return 0 }
        return meetingEvent.proposedMeetingTimes.count
    }
    
    func timeForProposedMeetingTime(atIndex index: Int, proposalIndex:Int) -> NSDate {
        guard let listingID     = listingID else { return NSDate() }
        let realm               = try! Realm()
        let rentEvents          = realm.objects(RentEvent).filter("listingID == \"\(listingID)\" AND (status == \"Proposed\" OR status == \"Inquired\")").sorted("dateCreated")
        guard let meetingID     = rentEvents[proposalIndex].startMeetingEventID                             else { return NSDate() }
        guard let meetingEvent  = realm.objects(MeetingEvent).filter("meetingID == \"\(meetingID)\"").first else { return NSDate() }
        guard let time          = meetingEvent.proposedMeetingTimes[index].time else { return NSDate() }
        return time
    }
    
    func availabilityForProposedMeetingTime(atIndex index: Int, proposalIndex:Int) -> Bool {
        guard let listingID     = listingID else { return false }
        let realm               = try! Realm()
        let rentEvents          = realm.objects(RentEvent).filter("listingID == \"\(listingID)\" AND (status == \"Proposed\" OR status == \"Inquired\")").sorted("dateCreated")
        guard let meetingID     = rentEvents[proposalIndex].startMeetingEventID                             else { return false }
        guard let meetingEvent  = realm.objects(MeetingEvent).filter("meetingID == \"\(meetingID)\"").first else { return false }
        return meetingEvent.proposedMeetingTimes[index].isAvailable
    }
    
    func durationForProposedMeetingTime(atIndex index: Int, proposalIndex:Int) -> Double {
        guard let listingID     = listingID else { return 0.0 }
        let realm               = try! Realm()
        let rentEvents          = realm.objects(RentEvent).filter("listingID == \"\(listingID)\" AND (status == \"Proposed\" OR status == \"Inquired\")").sorted("dateCreated")
        guard let meetingID     = rentEvents[proposalIndex].startMeetingEventID                             else { return 0.0 }
        guard let meetingEvent  = realm.objects(MeetingEvent).filter("meetingID == \"\(meetingID)\"").first else { return 0.0 }
        return meetingEvent.proposedMeetingTimes[index].duration
    }
    
    func isSelectedMeetingTime(atIndex index: Int, proposalIndex: Int) -> Bool {
        guard let listingID     = listingID else { return false }
        let realm               = try! Realm()
        let rentEvents          = realm.objects(RentEvent).filter("listingID == \"\(listingID)\" AND (status == \"Proposed\" OR status == \"Inquired\")").sorted("dateCreated")
        guard let meetingID     = rentEvents[proposalIndex].startMeetingEventID                             else { return false }
        guard let meetingEvent  = realm.objects(MeetingEvent).filter("meetingID == \"\(meetingID)\"").first else { return false }
        guard let proposedTime  = meetingEvent.proposedMeetingTimes[index].time                             else { return false }
        guard let acceptedTime  = acceptedTimes[meetingID]?.time                                            else { return false }
        return proposedTime.compare(acceptedTime) == .OrderedSame
    }
    
    // MARK: - MeetingTimeResponderViewDelegate
    func didSelectTime(forProposal proposalIndex: Int, atIndex index: Int) {
        guard let listingID     = listingID else { return }
        let realm               = try! Realm()
        let rentEvents          = realm.objects(RentEvent).filter("listingID == \"\(listingID)\" AND (status == \"Proposed\" OR status == \"Inquired\")").sorted("dateCreated")
        guard let meetingID     = rentEvents[proposalIndex].startMeetingEventID                             else { return }
        guard let meetingEvent  = realm.objects(MeetingEvent).filter("meetingID == \"\(meetingID)\"").first else { return }
        let isAvailable         = meetingEvent.proposedMeetingTimes[index].isAvailable
        if isAvailable {
            acceptedTimes[meetingID]    = meetingEvent.proposedMeetingTimes[index]
        }
    }
}

extension MeetingResponderVC : UICollectionViewDelegateFlowLayout {
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        return collectionView.bounds.size
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAtIndex section: Int) -> UIEdgeInsets {
        return UIEdgeInsetsMake(0.0, 0.0, 0.0, 0.0)
    }
}


protocol MeetingResponderDelegate {
    func didRejectProposal()
    func didAcceptProposal()
}
