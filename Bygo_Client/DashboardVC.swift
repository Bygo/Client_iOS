//
//  DashboardVC.swift
//  Bygo_Client
//
//  Created by Nicholas Garfield on 4/2/16.
//  Copyright © 2016 Nicholas Garfield. All rights reserved.
//

import UIKit
import RealmSwift

class DashboardVC: UITableViewController {
    
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
        
        fetchListings()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func userDidLogin() {
        fetchListings()
    }
    
    
    private func fetchListings() {
        guard let localUser = model?.getLocalUser() else { return }
        guard let userID    = localUser.userID else { return }
        model?.listingServiceProvider.fetchUsersListings(userID, completionHandler: {
            (success:Bool) in
            if success {
                self.tableView.reloadData()
            } else {
                print("Error fetching user's Listings")
            }
        })
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
            guard let localUser = model?.userServiceProvider.getLocalUser() else { return cell }
            guard let userID    = localUser.userID else { return cell }
            dispatch_async(GlobalUserInteractiveQueue, {
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
            cell.textLabel?.text = "No Rented Items"
            cell.accessoryType = .DisclosureIndicator
            
            // Configure the Cell
            guard let localUser = model?.userServiceProvider.getLocalUser() else { return cell }
            guard let userID    = localUser.userID else { return cell }
            dispatch_async(GlobalUserInteractiveQueue, {
                let realm       = try! Realm()
                let sharedListings = realm.objects(Listing).filter("renterID == \"\(userID)\"")
                let count = sharedListings.count
                
                if count > 0 {
                    dispatch_async(GlobalMainQueue, {
                        if count == 1 { cell.textLabel?.text = "1 Rented Item" }
                        else { cell.textLabel?.text = "\(count) Rented Items" }
                    })
                }
            })
            
        case kRENT_REQUESTS_INDEX:
            cell.textLabel?.text = "No New Rent Requests"
            cell.accessoryType = .DisclosureIndicator
//            if let localUser = model?.getLocalUser() {
//                let fetchRequest = NSFetchRequest(entityName: "RentEvent")
//                fetchRequest.predicate = NSPredicate(format: "(ownerID = %@) AND (status = %@)", localUser.userID, "Proposed")
//                do {
//                    let events = try model?.managedObjectContext?.executeFetchRequest(fetchRequest)
//                    if events?.count > 0 {
//                        cell.textLabel?.text = "\(events!.count) Rent Requests"
//                    }
//                } catch {
//                    print("Error fetching proposed rent events")
//                }
//            }
            
        case kMEETINGS_INDEX:
            cell.textLabel?.text = "No Upcoming Meetings"
            cell.accessoryType = .DisclosureIndicator
            
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
            break
//            targetListType = .Shared
//            performSegueWithIdentifier("ShowItems", sender: nil)
            
        case kRENTED_ITEMS_INDEX:
            break
//            targetListType = .Rented
//            performSegueWithIdentifier("ShowItems", sender: nil)
            
        case kRENT_REQUESTS_INDEX:
            break
//            performSegueWithIdentifier("ShowRentRequests", sender: nil)
            
        case kMEETINGS_INDEX:
            break
            
        case kCREATE_LISTING_INDEX:
            break
//            performSegueWithIdentifier("ShowCreateNewItem", sender: nil)
            
        default:
            break
        }
    }
    
    
    // MARK: - Navigation
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "ShowListings" {
            guard let destVC            = segue.destinationViewController as? ListingsVC else { return }
            guard let targetListType    = targetListType else { return }
            destVC.model                = model
            destVC.type                 = targetListType
//
//        } else if segue.identifier == "ShowCreateNewItem" {
//            guard let navVC = segue.destinationViewController as? UINavigationController else { return }
//            guard let destVC = navVC.topViewController as? NewItemNameVC else { return }
//            destVC.model = model
//            
//        } else if segue.identifier == "ShowRentRequests" {
//            guard let destVC = segue.destinationViewController as? RentRequestsVC else { return }
//            destVC.model = model
        }
    }
    
}



// MARK: - Items List Type
enum ListingsListType {
    case All
    case Shared
    case Rented
}

