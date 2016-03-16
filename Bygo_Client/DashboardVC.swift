//
//  DashboardVC.swift
//  Bygo_Client
//
//  Created by Nicholas Garfield on 4/2/16.
//  Copyright © 2016 Nicholas Garfield. All rights reserved.
//

import UIKit
import RealmSwift

private let kALL_MY_LISTINGS_INDEX = 0
//private let kSHARED_ITEMS_INDEX = 1
private let kRENTED_ITEMS_INDEX = 1//2
private let kRENT_REQUESTS_INDEX = 2//3
private let kMEETINGS_INDEX = 3//4
//private let kCREATE_LISTING_INDEX = 4//5


class DashboardVC: UITableViewController, RentRequestsDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    var model:Model?
    var delegate:DashboardDelegate?
    var targetListType:ListingsListType?
    @IBOutlet var headerView: UIView!
    @IBOutlet var infoTextVerticalOffset: NSLayoutConstraint!
    
//    var imagePicker:UIImagePickerController = UIImagePickerController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        
        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        
        // UI Design
        navigationController?.navigationBar.barTintColor    = kCOLOR_ONE
        navigationController?.navigationBar.translucent     = false
        navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.whiteColor()]
        
        headerView.backgroundColor  = kCOLOR_THREE
        tableView.backgroundColor   = kCOLOR_THREE
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "didFetchNewRentRequest:", name: Notifications.DidFetchNewRentRequest.rawValue, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "rentRequestWasAccepted:", name: Notifications.RentRequestWasAccepted.rawValue, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "rentRequestWasRejected:", name: Notifications.RentRequestWasRejected.rawValue, object: nil)

        tableView.reloadData()
        
//        refreshData({
//            (success:Bool) in
//            if success {
//                self.tableView.reloadData()
//            }
//        })
        
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
        return 2
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return 4
        case 1:
            return 1
        default:
            return 0
        }
    }
    
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("DashboardCell", forIndexPath: indexPath)
        cell.textLabel?.font = UIFont.systemFontOfSize(16.0)
        
        switch indexPath.section {
        case 0:
            switch indexPath.row {
            case kALL_MY_LISTINGS_INDEX:
                cell.textLabel?.text = "Your Listings"
                cell.accessoryType = .DisclosureIndicator
                
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
                            if numRentRequests == 1 { cell.textLabel?.text = "1 Rent Request" }
                            else { cell.textLabel?.text = "\(numRentRequests) Rent Requests" }
                        })
                    }
                })
                
            case kMEETINGS_INDEX:
                cell.textLabel?.text    = "No Upcoming Meetings"
                cell.accessoryType      = .DisclosureIndicator
                
                // Configure the cell
                guard let userID = model?.userServiceProvider.getLocalUser()?.userID else { return cell }
                dispatch_async(GlobalBackgroundQueue, {
                    let realm = try! Realm()
                    let numMeetings = realm.objects(MeetingEvent).filter("(ownerID == \"\(userID)\" OR renterID == \"\(userID)\") AND (status == \"Scheduled\" OR status == \"Delayed\")").count
                    if numMeetings > 0 {
                        dispatch_async(GlobalMainQueue, {
                            if numMeetings == 1 { cell.textLabel?.text = "1 Upcoming Meeting" }
                            else { cell.textLabel?.text = "\(numMeetings) Upcoming Meetings" }
                        })
                    }
                })
 
            default:
                break
            }
            
        case 1:
            cell.textLabel?.text            = "Create New Listing"
            cell.textLabel?.font            = UIFont.systemFontOfSize(16.0, weight: UIFontWeightMedium)
            cell.textLabel?.textAlignment   = .Center
            cell.textLabel?.textColor       = .whiteColor()
            cell.backgroundColor            = kCOLOR_FIVE
            
        default: break
        }
        
        return cell
    }
    
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        tableView.reloadSections(NSIndexSet(index: 0), withRowAnimation: .None)
        
        switch indexPath.section {
        case 0:
            switch indexPath.row {
            case kALL_MY_LISTINGS_INDEX:
                targetListType = .All
                performSegueWithIdentifier("ShowListings", sender: nil)
                
            case kRENTED_ITEMS_INDEX:
                performSegueWithIdentifier("ShowRentedListings", sender: nil)
                
            case kRENT_REQUESTS_INDEX:
                performSegueWithIdentifier("ShowRentRequests", sender: nil)
                
            case kMEETINGS_INDEX:
                performSegueWithIdentifier("ShowMeetings", sender: nil)
                
            default:
                break
            }
        case 1:
            performSegueWithIdentifier("ShowCreateNewListing", sender: nil)
//            if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.Camera) {
//                imagePicker.sourceType     = .Camera
//                imagePicker.cameraDevice   = UIImagePickerControllerCameraDevice.Rear
//                imagePicker.cameraCaptureMode = UIImagePickerControllerCameraCaptureMode.Photo
////                imagePicker.delegate       = self
//                imagePicker.allowsEditing  = true
//                imagePicker.showsCameraControls = true
//                
//                let sb = UIStoryboard(name: "Dashboard", bundle: NSBundle.mainBundle())
//                guard let overlay = sb.instantiateViewControllerWithIdentifier("OverlayVC") as? NewListingVC else { return }
//                
//                overlay.imagePicker = imagePicker
//                imagePicker.cameraOverlayView = overlay.view
//                
//                imagePicker.view.addSubview(overlay.view)
//                imagePicker.view.bringSubviewToFront(overlay.view)
//                imagePicker.delegate = overlay
//                
//                let photoLibraryButton = UIButton(frame: CGRectMake(100, 100, 80, 80))
//                photoLibraryButton.backgroundColor = .orangeColor()
//                photoLibraryButton.setImage(UIImage(named: "Photos")?.imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate), forState: .Normal)
//                photoLibraryButton.tintColor = .whiteColor()
//                        view.addSubview(photoLibraryButton)
//                photoLibraryButton.addTarget(self, action: "adsf:", forControlEvents: .TouchUpInside)
//                imagePicker.view.addSubview(photoLibraryButton)
//                
//                presentViewController(imagePicker, animated: true, completion: nil)
//                
//            } else if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.PhotoLibrary) {
//                imagePicker.sourceType     = .PhotoLibrary
//                imagePicker.delegate       = self
//                imagePicker.allowsEditing  = false
//                presentViewController(imagePicker, animated: true, completion: nil)
//            }


        default:
            break
        }
    }
    
    @IBAction func adsf(sender: AnyObject) {
        print("asdf")
    }
    
    func rentRequestsDidUpdate() {
        tableView.reloadRowsAtIndexPaths([NSIndexPath(forRow: kRENT_REQUESTS_INDEX, inSection: 0), NSIndexPath(forRow: kMEETINGS_INDEX, inSection: 0)], withRowAnimation: .Fade)
    }
    
    
    override func scrollViewDidScroll(scrollView: UIScrollView) {
        if scrollView == tableView {
            if scrollView.contentOffset.y < 0.0 {
                infoTextVerticalOffset.constant = 50.0 + scrollView.contentOffset.y/2.0
            }
        }
    }
    
    // MARK: - Notification Handlers
    func didFetchNewRentRequest(notification:NSNotification) {
        dispatch_async(GlobalMainQueue, {
            self.tableView.reloadRowsAtIndexPaths([NSIndexPath(forRow: kRENT_REQUESTS_INDEX, inSection: 0)], withRowAnimation: .Fade)
        })
    }
    
    func rentRequestWasAccepted(notification:NSNotification) {
        dispatch_async(GlobalMainQueue, {
            self.tableView.reloadRowsAtIndexPaths([NSIndexPath(forRow: kRENT_REQUESTS_INDEX, inSection: 0), NSIndexPath(forRow: kMEETINGS_INDEX, inSection: 0), NSIndexPath(forRow: kRENTED_ITEMS_INDEX, inSection: 0)], withRowAnimation: .Fade)
        })
    }
    
    func rentRequestWasRejected(notification:NSNotification) {
        dispatch_async(GlobalMainQueue, {
            self.tableView.reloadRowsAtIndexPaths([NSIndexPath(forRow: kRENT_REQUESTS_INDEX, inSection: 0), NSIndexPath(forRow: kMEETINGS_INDEX, inSection: 0), NSIndexPath(forRow: kRENTED_ITEMS_INDEX, inSection: 0)], withRowAnimation: .Fade)
        })
    }
    
    
    // MARK: - UI Actions
    @IBAction func menuButtonTapped(sender: AnyObject) {
        delegate?.openMenu()
    }
    
    
    // MARK: - Navigation
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "ShowListings" {
            guard let destVC            = segue.destinationViewController as? ListingsVC else { return }
            guard let targetListType    = targetListType else { return }
            destVC.model                = model
            destVC.type                 = targetListType
            
        } else if segue.identifier == "ShowRentedListings" {
            guard let destVC = segue.destinationViewController as? RentedListingsVC else { return }
            destVC.model = model
            
        } else if segue.identifier == "ShowCreateNewListing" {
//            guard let navVC     = segue.destinationViewController as? UINavigationController else { return }
//            guard let destVC    = navVC.topViewController as? NewListingNameVC else { return }
//            destVC.model        = model
            
        } else if segue.identifier == "ShowRentRequests" {
            guard let destVC    = segue.destinationViewController as? RentRequestsVC else { return }
            destVC.model        = model
            destVC.delegate     = self

        } else if segue.identifier == "ShowMeetings" {
            guard let destVC    = segue.destinationViewController as? MeetingsVC else { return }
            destVC.model        = model
        }
        delegate?.didMoveOneLevelIntoNavigation()
    }
    
}


protocol DashboardDelegate {
    func openMenu()
    func didMoveOneLevelIntoNavigation()
    func didReturnToBaseLevelOfNavigation()
}


// MARK: - Items List Type
enum ListingsListType {
    case All
    case Shared
    case Rented
}

