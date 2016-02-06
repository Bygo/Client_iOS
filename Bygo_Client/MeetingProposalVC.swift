//
//  MeetingProposalVC.swift
//  Bygo_Client
//
//  Created by Nicholas Garfield on 4/2/16.
//  Copyright © 2016 Nicholas Garfield. All rights reserved.
//

import UIKit
import RealmSwift

class MeetingProposalVC: UIViewController, UITableViewDataSource, UITableViewDelegate, MeetingTimeProposalViewDelegate, MeetingTimeProposalViewDataSource {
    
    var listing:AdvertisedListing?
    var model:Model?
    var rentalRate:Double?
    var timeFrame:RentalTimeFrame?
    
    //    @IBOutlet var collectionView: UICollectionView!
    @IBOutlet var cancelButton: UIBarButtonItem!
    @IBOutlet var timeProposalView: MeetingTimeProposalView!
    @IBOutlet var tableView: UITableView!
    
    private let kSCHEDULER_SECTION = 0
    private let kYOUR_FAV_PLACES_SECTION = 1
    private let kTHEIR_FAV_PLACES_SECTION = 2
    private let kRECOMMENDED_PLACES_SECTION = -1
    private let kSEND_BUTTON_SECTION = 3
    
//    var proposedLocations:[FavoriteMeetingLocation] = []
//    var ownerFavLocations:[FavoriteMeetingLocation] = []
//    var renterFavLocations:[FavoriteMeetingLocation] = []
//    var numOwnerFavLocations:Int    = 0
//    var ownerFavLocationIDs:[String:String] = [:]
//    var renterFavLocationIDs:[String:String] = [:]
//    var numRenterFavLocations:Int   = 0
    var proposedMeetingLocationIDs:[String] = []

    var proposedMeetingTimes:[ProposedMeetingTime] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        tableView.rowHeight             = UITableViewAutomaticDimension
        tableView.estimatedRowHeight    = 80.0
        
        guard let model = model else { return }
        
//        guard let item = item else { return }
        
        proposedMeetingTimes.appendContentsOf(model.rentServiceProvider.generateNewProposedMeetingTimes())
        
        // Query for the owner's fav meeting locations
        guard let ownerID   = listing?.ownerID else { return }
        guard let userID    = model.userServiceProvider.getLocalUser()?.userID else { return }
        
        model.favoriteMeetingLocationServiceProvider.fetchUsersFavoriteMeetingLocations(ownerID, completionHandler:  {
            (success:Bool) in
            if success {
                model.favoriteMeetingLocationServiceProvider.fetchUsersFavoriteMeetingLocations(userID, completionHandler: {
                    (success:Bool) in
                    if success {
                        self.tableView.reloadData()
                    }
                })
            }
        })
        
//        model.queryUsersFavoriteMeetingLocations(item.ownerID!, completionHandler:{(success:Bool, ownersMeetingLocations:[FavoriteMeetingLocation]) in
//            if success {
//                self.ownerFavLocations.appendContentsOf(ownersMeetingLocations)
//                
//                // Query for the local user's fav meeting locations
//                guard let localUser = model.getLocalUser() else { return }
//                model.queryUsersFavoriteMeetingLocations(localUser.userID, completionHandler: {(success:Bool, rentersMeetingLocations:[FavoriteMeetingLocation]) in
//                    if success {
//                        self.renterFavLocations.appendContentsOf(rentersMeetingLocations)
//                        self.tableView.reloadData()
//                    } else {
//                        print("Error querying for renter's favorite meeting locations")
//                    }
//                })
//            } else {
//                print("Error querying for owner's favorite meeting locations")
//            }
//        })
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    // MARK: - TableView Data Source
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 4
    }
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case kSCHEDULER_SECTION:            return ""
        case kYOUR_FAV_PLACES_SECTION:      return "Your Favorite Places"
        case kTHEIR_FAV_PLACES_SECTION:     return "Their Favorite Places"
        case kRECOMMENDED_PLACES_SECTION:   return "Recommended"
        default: return nil
        }
    }
    
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case kSCHEDULER_SECTION:            return 4
        case kYOUR_FAV_PLACES_SECTION:
            guard let userID = model?.userServiceProvider.getLocalUser()?.userID else { return 0 }
            let realm = try! Realm()
            return realm.objects(FavoriteMeetingLocation).filter("userID == \"\(userID)\"").count
            
        case kTHEIR_FAV_PLACES_SECTION:
            guard let userID = listing?.ownerID else { return 0 }
            let realm = try! Realm()
            return realm.objects(FavoriteMeetingLocation).filter("userID == \"\(userID)\"").count
            
        case kRECOMMENDED_PLACES_SECTION:   return 0
        case kSEND_BUTTON_SECTION:          return 1
        default: return 0
        }
    }

    private func configureLocationCell(cell:MeetingLocationProposalTableViewCell, indexPath:NSIndexPath, userID:String) {
        let realm                       = try! Realm()
        let results                     = realm.objects(FavoriteMeetingLocation).filter("userID == \"\(userID)\"")
        let location                    = results[indexPath.row]
        guard let name                  = location.name else { return }
        guard let locationID            = location.locationID else { return }
        let isSelected                  = proposedMeetingLocationIDs.contains(locationID)
        cell.locationNameLabel.text     = name
        if isSelected {
            cell.selectedMarkerButton.backgroundColor = .greenColor()
        } else {
            cell.selectedMarkerButton.backgroundColor = .clearColor()
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        switch indexPath.section {
        case kSCHEDULER_SECTION:
            switch indexPath.row {
            case 0:
                let cell = UITableViewCell()
                guard let listing       = listing       else { return cell }
                guard let rentalRate    = rentalRate    else { return cell }
                guard let timeFrame     = timeFrame     else { return cell }
                
                var timeFrameString = ""
                if timeFrame == .Hour {
                    timeFrameString = "hour"
                } else if timeFrame == .Day {
                    timeFrameString = "day"
                } else if timeFrame == .Week {
                    timeFrameString = "week"
                }
                
                guard let listingName = listing.name else { return cell }
                cell.textLabel?.numberOfLines = 0
                let formattedRentalRate = String(format: "$%.2f", rentalRate)
                cell.textLabel?.text = "Create a requst to rent \(listingName) for \(formattedRentalRate) per \(timeFrameString)"
                return cell
                
            case 1:
                let cell = UITableViewCell()
                cell.textLabel?.numberOfLines = 0
                cell.textLabel?.text = "1. To begin, propose some times that you are available to pick up the item."
                return cell
                
            case 2:
                guard let cell = tableView.dequeueReusableCellWithIdentifier("TimeProposalCell", forIndexPath: indexPath) as? MeetingTimeProposalTableViewCell else { return UITableViewCell() }
                // FIXME: Pull from UI repo
                cell.timeProposalView.delegate = self
                cell.timeProposalView.dataSource = self
                cell.timeProposalView.layer.cornerRadius = 0.0
                timeProposalView = cell.timeProposalView
                cell.timeProposalView.reload()
                cell.layoutIfNeeded()
                cell.updateConstraintsIfNeeded()
                return cell
                
            case 3:
                let cell = UITableViewCell()
                cell.textLabel?.numberOfLines = 0
                cell.textLabel?.text = "\n\n2. Finally, select some locations where you could pick up the item."
                return cell
                
            default:
                return UITableViewCell()
            }
        case kYOUR_FAV_PLACES_SECTION:
            guard let cell = tableView.dequeueReusableCellWithIdentifier("LocationProposalCell", forIndexPath: indexPath) as? MeetingLocationProposalTableViewCell else { return UITableViewCell() }
            guard let userID = model?.userServiceProvider.getLocalUser()?.userID else { return cell }
            configureLocationCell(cell, indexPath: indexPath, userID: userID)
            return cell
            
        case kTHEIR_FAV_PLACES_SECTION:
            guard let cell = tableView.dequeueReusableCellWithIdentifier("LocationProposalCell", forIndexPath: indexPath) as? MeetingLocationProposalTableViewCell else { return UITableViewCell() }
            guard let userID = listing?.ownerID else { return cell }
            configureLocationCell(cell, indexPath: indexPath, userID: userID)
            return cell
            
        case kSEND_BUTTON_SECTION:
            let cell = UITableViewCell()
            cell.textLabel?.textAlignment   = .Center
            cell.textLabel?.text            = "SEND REQUEST"
            return cell
            
        default:
            return UITableViewCell()
        }
    }
    
    private func didSelectLocationCellAtIndexPath(indexPath: NSIndexPath, userID: String) {
        let realm               = try! Realm()
        let loc                 = realm.objects(FavoriteMeetingLocation).filter("userID == \"\(userID)\"")[indexPath.row]
        guard let locationID    = loc.locationID else { return }
        if let idx = self.proposedMeetingLocationIDs.indexOf(locationID) {
            proposedMeetingLocationIDs.removeAtIndex(idx)
        } else {
            proposedMeetingLocationIDs.append(locationID)
        }
        tableView.reloadRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        switch indexPath.section {
        case kSCHEDULER_SECTION:
            break
            
        case kYOUR_FAV_PLACES_SECTION:
            guard let userID = model?.userServiceProvider.getLocalUser()?.userID else { return }
            didSelectLocationCellAtIndexPath(indexPath, userID: userID)

            
        case kTHEIR_FAV_PLACES_SECTION:
            guard let userID = listing?.ownerID else { return }
            didSelectLocationCellAtIndexPath(indexPath, userID: userID)

            
        case kSEND_BUTTON_SECTION:
            guard let renterID      = model?.userServiceProvider.getLocalUser()?.userID else { return }
            guard let listingID     = listing?.listingID    else { return }
            guard let ownerID       = listing?.ownerID      else { return }
            guard let rentalRate    = rentalRate            else { return }
            guard let timeFrame     = timeFrame             else { return }
            if proposedMeetingLocationIDs.count < 1 { return }
            var isAvailable = false
            for time in proposedMeetingTimes {
                if time.isAvailable {
                    isAvailable = true
                }
            }
            if !isAvailable { return }
            let status      = "Proposed"
            let proposedBy  = "Renter"
            
            // NOTE: Disabled for demo
            model?.rentServiceProvider.createRentRequest(ownerID, renterID: renterID, listingID: listingID, status: status, proposedBy: proposedBy, message: nil, rentalRate: rentalRate, timeFrame: timeFrame.rawValue, proposedMeetingTimes: proposedMeetingTimes, proposedMeetingLocationIDs: proposedMeetingLocationIDs, completionHandler: {
                (success:Bool) in
                if success {
                    self.dismissViewControllerAnimated(true, completion: nil)
                } else {
                    print("Error creating Rent Request")
                }
            })
            //            model?.proposeRentEvent(itemID, ownerID: ownerID, rentalRate: rentalRate, timeFrame: timeFrame, proposedMeetingTimes: proposedMeetingTimes, proposedMeetingLocations: proposedLocations, message: message, completionHandler: {(success:Bool)->Void in
            //                if success {
            //                    print("Success proposing new rent event")
            //                    self.dismissViewControllerAnimated(true, completion: nil)
            //                } else {
            //                    print("Could not propose new rent event")
            //                }
            //            })
            
//            self.dismissViewControllerAnimated(true, completion: nil)
            
            
        default: break
        }
    }
    
    
    private func isDataValid() -> Bool {
        if listing?.listingID   == nil          { return false }
        if listing?.ownerID     == nil          { return false }
        if rentalRate           == nil          { return false }
        if timeFrame            == nil          { return false }
        if proposedMeetingLocationIDs.count < 1 { return false }
        var isAvailable = false
        for time in proposedMeetingTimes {
            if time.isAvailable { isAvailable = true }
        }
        if !isAvailable { return false }
        return true
    }
    
    // MARK: - TableView Delegate
    func tableView(tableView: UITableView, willSelectRowAtIndexPath indexPath: NSIndexPath) -> NSIndexPath? {
        switch indexPath.section {
        case kSCHEDULER_SECTION: return nil
        case kYOUR_FAV_PLACES_SECTION, kTHEIR_FAV_PLACES_SECTION, kRECOMMENDED_PLACES_SECTION, kSEND_BUTTON_SECTION: return indexPath
        default: return nil
        }
    }
    
    func tableView(tableView: UITableView, shouldHighlightRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        switch indexPath.section {
        case kSCHEDULER_SECTION: return false
        case kYOUR_FAV_PLACES_SECTION, kTHEIR_FAV_PLACES_SECTION, kRECOMMENDED_PLACES_SECTION, kSEND_BUTTON_SECTION: return true
        default: return false
        }
    }
    
    // MARK: - MeetingTimeProposalViewDataSource
    func numProposedMeetingTimes() -> Int {
        return proposedMeetingTimes.count
    }
    
    func timeForProposedMeetingTime(atIndex index: Int) -> NSDate {
        return proposedMeetingTimes[index].time!
    }
    
    func availabilityForProposedMeetingTime(atIndex index: Int) -> Bool {
        return proposedMeetingTimes[index].isAvailable
    }
    
    func durationForProposedMeetingTime(atIndex index: Int) -> Double {
        return proposedMeetingTimes[index].duration
    }
    
    // MARK: - MeetingTimeProposalViewDelegate
    func didChangeAvailability(atIndex index: Int) {
        let realm = try! Realm()
        try! realm.write {
            proposedMeetingTimes[index].isAvailable = !proposedMeetingTimes[index].isAvailable
        }
    }
    
    
    // MARK: - UI Actions
    @IBAction func panGestureRecognized(recognizer: UIPanGestureRecognizer) {
        switch recognizer.state {
        case .Began:
            timeProposalView.panBeganAtLocation(recognizer.locationInView(timeProposalView))
        case .Changed:
            timeProposalView.panMovedToLocation(recognizer.locationInView(timeProposalView))
        default:
            break
        }
    }
    
    @IBAction func tapGestureRecognized(recognizer: UITapGestureRecognizer) {
        timeProposalView.tapAtLocation(recognizer.locationInView(timeProposalView))
    }
    
    @IBAction func cancelButtonTapped(sender: AnyObject) {
        dismissViewControllerAnimated(true, completion: nil)
    }
}
