//
//  DashboardVC.swift
//  Bygo_Client
//
//  Created by Nicholas Garfield on 4/2/16.
//  Copyright © 2016 Nicholas Garfield. All rights reserved.
//

import UIKit
import RealmSwift

class DashboardVC: UITableViewController, RentRequestsDelegate {
    
    var model:Model?
    
    private let kALL_MY_LISTINGS_INDEX = 0
    private let kSHARED_ITEMS_INDEX = 1
    private let kRENTED_ITEMS_INDEX = 2
    private let kRENT_REQUESTS_INDEX = 3
    private let kMEETINGS_INDEX = 4
    private let kCREATE_LISTING_INDEX = 5
    
    var targetListType:ListingsListType?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        
        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        
        refreshData({
            (success:Bool) in
            if success {
                self.tableView.reloadData()
            }
        })
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func userDidLogin() {
        refreshData({
            (success:Bool) in
            if success {
                self.tableView.reloadData()
            }
        })
    }
    
    func userDidLogout() {
        tableView.reloadData()
    }
    
    private func refreshData(completionHandler:(success:Bool)->Void) {
        fetchListings({
            (success:Bool) in
            if success {
                self.fetchRentRequests({
                    (success:Bool) in
                    if success {
                        self.fetchMeetings(completionHandler)
                    } else {
                        print("Error fetching meetings")
                    }
                })
            } else {
                print("Error fetching listings")
            }
        })
    }
    
    private func fetchListings(completionHandler:(success:Bool)->Void) {
        guard let userID = model?.getLocalUser()?.userID else { return }
        model?.listingServiceProvider.fetchUsersListings(userID, completionHandler: completionHandler)
    }
    
    private func fetchRentRequests(completionHandler:(success:Bool)->Void) {
        guard let userID = model?.getLocalUser()?.userID else { return }
        model?.rentServiceProvider.fetchUsersRentEvents(userID, completionHandler: completionHandler)
    }
    
    private func fetchMeetings(completionHandler:(success:Bool)->Void) {
        guard let userID = model?.getLocalUser()?.userID else { return }
        model?.meetingServiceProvider.fetchUsersMeetingEvents(userID, completionHandler: completionHandler)
    }
    
    // MARK: - Table view data source
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 6
    }
    
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("DashboardCell", forIndexPath: indexPath)
        
        switch indexPath.row {
        case kALL_MY_LISTINGS_INDEX:
            cell.textLabel?.text = "All My Listings"
            cell.accessoryType = .DisclosureIndicator
            
        case kSHARED_ITEMS_INDEX:
            cell.textLabel?.text = "No Shared Items"
            cell.accessoryType = .DisclosureIndicator
            
            // Configure the Cell
            guard let userID = model?.userServiceProvider.getLocalUser()?.userID else { return cell }
            dispatch_async(GlobalBackgroundQueue, {
                let realm       = try! Realm()
                let sharedListings = realm.objects(Listing).filter("(ownerID == \"\(userID)\") AND (renterID != nil)")
                let count = sharedListings.count
                
                if count > 0 {
                    dispatch_async(GlobalMainQueue, {
                        if count == 1 { cell.textLabel?.text = "1 Shared Item" }
                        else { cell.textLabel?.text = "\(count) Shared Items" }
                    })
                }
            })
            
        case kRENTED_ITEMS_INDEX:
            cell.textLabel?.text    = "No Rented Items"
            cell.accessoryType      = .DisclosureIndicator
            
            // Configure the cell
            guard let userID = model?.userServiceProvider.getLocalUser()?.userID else { return cell }
            dispatch_async(GlobalBackgroundQueue, {
                let realm               = try! Realm()
                let numSharedListings   = realm.objects(Listing).filter("renterID == \"\(userID)\"").count
                if numSharedListings > 0 {
                    dispatch_async(GlobalMainQueue, {
                        if numSharedListings == 1 { cell.textLabel?.text = "1 Rented Item" }
                        else { cell.textLabel?.text = "\(numSharedListings) Rented Items" }
                    })
                }
            })
            
        case kRENT_REQUESTS_INDEX:
            cell.textLabel?.text    = "No Rent Requests"
            cell.accessoryType      = .DisclosureIndicator
            
            // Configure the cell
            guard let userID = model?.userServiceProvider.getLocalUser()?.userID else { return cell }
            dispatch_async(GlobalBackgroundQueue, {
                let realm           = try! Realm()
                let numRentRequests = realm.objects(RentEvent).filter("ownerID == \"\(userID)\" AND (status == \"Proposed\" OR status == \"Inquired\")").count
                if numRentRequests > 0 {
                    dispatch_async(GlobalMainQueue, {
                        if numRentRequests == 1 { cell.textLabel?.text = "1 Rent Reqeust" }
                        else { cell.textLabel?.text = "\(numRentRequests) Rent Requests" }
                    })
                }
            })
            
        case kMEETINGS_INDEX:
            cell.textLabel?.text    = "No Upcoming Meetings"
            cell.accessoryType      = .DisclosureIndicator
            
        case kCREATE_LISTING_INDEX:
            cell.textLabel?.text            = "Create New Listing"
            cell.textLabel?.textAlignment   = .Center
            cell.textLabel?.textColor       = .whiteColor()
            cell.backgroundColor            = .blueColor()
            
        default:
            break
        }
        
        return cell
    }
    
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        switch indexPath.row {
        case kALL_MY_LISTINGS_INDEX:
            targetListType = .All
            performSegueWithIdentifier("ShowListings", sender: nil)
            
        case kSHARED_ITEMS_INDEX:
            targetListType = .Shared
            performSegueWithIdentifier("ShowListings", sender: nil)
            
        case kRENTED_ITEMS_INDEX:
            targetListType = .Rented
            performSegueWithIdentifier("ShowListings", sender: nil)
            
        case kRENT_REQUESTS_INDEX:
            performSegueWithIdentifier("ShowRentRequests", sender: nil)
            
        case kMEETINGS_INDEX:
            break
            
        case kCREATE_LISTING_INDEX:
            performSegueWithIdentifier("ShowCreateNewListing", sender: nil)
            
        default:
            break
        }
    }
    
    func rentRequestsDidUpdate() {
        print("Dashboard: RentRequestsDidUpdate")
        tableView.reloadRowsAtIndexPaths([NSIndexPath(forRow: kRENT_REQUESTS_INDEX, inSection: 0)], withRowAnimation: .Fade)
    }
    
    
    // MARK: - Navigation
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "ShowListings" {
            guard let destVC            = segue.destinationViewController as? ListingsVC else { return }
            guard let targetListType    = targetListType else { return }
            destVC.model                = model
            destVC.type                 = targetListType
            
        } else if segue.identifier == "ShowCreateNewListing" {
            guard let navVC     = segue.destinationViewController as? UINavigationController else { return }
            guard let destVC    = navVC.topViewController as? NewListingNameVC else { return }
            destVC.model        = model
            
        } else if segue.identifier == "ShowRentRequests" {
            guard let destVC    = segue.destinationViewController as? RentRequestsVC else { return }
            destVC.model        = model
            destVC.delegate     = self
        }
    }
    
}



// MARK: - Items List Type
enum ListingsListType {
    case All
    case Shared
    case Rented
}

