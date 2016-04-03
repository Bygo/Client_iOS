//
//  DashboardVC.swift
//  Bygo_Client
//
//  Created by Nicholas Garfield on 4/2/16.
//  Copyright © 2016 Nicholas Garfield. All rights reserved.
//

import UIKit
import RealmSwift

class DashboardVC: UITableViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    
    var model:Model?
    var delegate:DashboardDelegate?
    
    
    @IBOutlet var headerView: UIView!
    @IBOutlet var collectionView: UICollectionView!
    @IBOutlet var notificationsVerticalOffset: NSLayoutConstraint!
    
    private var notificationData: AnyObject?
    
    
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
        
        collectionView.backgroundColor = .clearColor()
        
        refreshControl = UIRefreshControl()
        refreshControl?.addTarget(self, action: #selector(DashboardVC.refreshNotifications), forControlEvents: .ValueChanged)
        tableView.addSubview(refreshControl!)
        
        refreshNotifications()
        refreshOpenOrders()
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
        
    }
    
    func userDidLogout() {
        
    }
    
    
    private func refreshOpenOrders() {
        guard let userID = model?.userServiceProvider.getLocalUser()?.userID else { return }
        model?.listingServiceProvider.fetchUsersRentedListings(userID, completionHandler: {
            (success:Bool) in
            if success {
                dispatch_async(GlobalMainQueue, {
                    self.tableView.reloadSections(NSIndexSet(index: 1), withRowAnimation: .Fade)
                })
            }
        })
    }
    
    func refreshNotifications() {
        guard let userID = model?.userServiceProvider.getLocalUser()?.userID else { return }
        model?.notificationServiceProvider.fetchUsersNotificationData(userID, completionHandler: {
            (data: AnyObject?) in
            self.refreshControl?.endRefreshing()
            self.notificationData = data
            dispatch_async(GlobalMainQueue, {
                self.collectionView.reloadData()
                self.collectionView.layoutIfNeeded()
            })
        })
    }
    
    // MARK: - Table view data source
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 3
    }

    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0:
            return "Open Orders"
        case 1:
            return "Pending Orders"
        default:
            return nil
        }
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            guard let userID = model?.userServiceProvider.getLocalUser()?.userID else { return 1 }
            let realm = try! Realm()
            let count = realm.objects(Listing).filter("renterID == \"\(userID)\"").count
            if count == 0 {
                return 1
            } else {
                return count
            }
            
        case 1:
            return 1
        case 2:
            return 2
        default:
            return 0
        }
    }
    
    
    private func configureNoOpenOrdersCell(indexPath: NSIndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCellWithIdentifier("DashboardCell", forIndexPath: indexPath) as? BygoGeneralTableViewCell else { return UITableViewCell() }
        cell.titleLabel.text = "You are not using anything from Bygo"
        cell.backgroundColor = .clearColor()
        return cell
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0:
            guard let userID = model?.userServiceProvider.getLocalUser()?.userID else {
                return configureNoOpenOrdersCell(indexPath)
            }
            let realm = try! Realm()
            let listings = realm.objects(Listing).filter("renterID == \"\(userID)\"")
            
            if listings.count == 0 {
                return configureNoOpenOrdersCell(indexPath)
            } else {
                let listing = listings[indexPath.row]
                guard let cell = tableView.dequeueReusableCellWithIdentifier("DashboardCell", forIndexPath: indexPath) as? BygoGeneralTableViewCell else { return UITableViewCell() }
                guard let typeID = listing.typeID else { return cell }
                model?.itemTypeServiceProvider.fetchItemType(typeID, completionHandler: {
                    (success:Bool) in
                    if success {
                        let realm = try! Realm()
                        guard let name = realm.objects(ItemType).filter("typeID == \"\(typeID)\"")[0].name else { return }
                        dispatch_async(GlobalMainQueue, {
                            cell.titleLabel.text = name
                        })
                    }
                })
                return cell
            }
            
        case 1:
            // TODO: Populate with data
            guard let cell = tableView.dequeueReusableCellWithIdentifier("DashboardCell", forIndexPath: indexPath) as? BygoGeneralTableViewCell else { return UITableViewCell() }
            cell.titleLabel.text = "You have not placed any orders"
            cell.backgroundColor = .clearColor()
            return cell
            
        case 2:
            guard let cell = tableView.dequeueReusableCellWithIdentifier("DashboardCell", forIndexPath: indexPath) as? BygoGeneralTableViewCell else { return UITableViewCell() }
            
            switch indexPath.row {
            case 0:
                cell.titleLabel.text = "Your Listings"
                cell.accessoryType = UITableViewCellAccessoryType.DisclosureIndicator
                
            case 1:
                cell.titleLabel.text = "Your History"
                cell.accessoryType = UITableViewCellAccessoryType.DisclosureIndicator
                
            default:
                return cell
            }
            return cell
            
        default:
            return UITableViewCell()
        }
    }
    
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        switch indexPath.section {
        case 0:
            break
        case 1:
            break
        case 2:
            if indexPath.row == 0 {
                performSegueWithIdentifier("ShowListings", sender: nil)
            } else if indexPath.row == 1 {
                performSegueWithIdentifier("ShowHistory", sender: nil)
            }
        default:
            break
        }
    }
    
    
    
    
    // MARK: - CollectionViewDataSource
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard let notificationData = notificationData as? [[String:AnyObject]] else { return 1 }
        let count = notificationData.count
        if count == 0 {
            return 1
        } else {
            return count
        }
    }
    
    private func configureNoNotificationsCell(indexPath: NSIndexPath) -> UICollectionViewCell {
        guard let noNotificationsCell = collectionView.dequeueReusableCellWithReuseIdentifier("InfoCell", forIndexPath: indexPath) as? BygoInfoCollectionViewCell else { return UICollectionViewCell() }
        noNotificationsCell.backgroundColor = .whiteColor()
        noNotificationsCell.infoLabel.text = "No Notifications!\n\nPull down to refresh"
        return noNotificationsCell
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        guard let notificationData = notificationData as? [[String:AnyObject]] else {
            return configureNoNotificationsCell(indexPath)
        }
        let count = notificationData.count
        if count == 0 {
            return configureNoNotificationsCell(indexPath)
        }

        guard let cell = collectionView.dequeueReusableCellWithReuseIdentifier("NotificationCell", forIndexPath: indexPath) as? NotificationCollectionViewCell else { return UICollectionViewCell() }
        cell.imageView.image = UIImage(named: "DeliveryTruck")?.imageWithRenderingMode(.AlwaysTemplate)
        cell.imageView.tintColor = kCOLOR_ONE
        cell.imageView.alpha = 0.75
        cell.titleLabel.text = "1 Delivery"
        cell.detailLabel.text = "The Xbox One Console will be delivered in approximately 20 minutes."
        cell.backgroundColor = .whiteColor()
        return cell
    }
    
    
    // MARK: - CollectionViewDelegate
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        
    }
    
    
    // MARK: - Scrollview Delegate
    override func scrollViewDidScroll(scrollView: UIScrollView) {
        if scrollView == tableView {
            if scrollView.contentOffset.y < 0.0 {
                notificationsVerticalOffset.constant = scrollView.contentOffset.y/2.0
            }
        }
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
            destVC.model                = model
        } else if segue.identifier == "ShowHistory" {
            guard let destVC = segue.destinationViewController as? HistoryVC else { return }
            destVC.model = model
        }
        
        delegate?.didMoveOneLevelIntoNavigation()
    }
    
}


// MARK: - UICollectionViewDelegate
extension DashboardVC : UICollectionViewDelegateFlowLayout{
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        return CGSizeMake(headerView.bounds.width-16.0, headerView.bounds.height-16.0)
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAtIndex section: Int) -> UIEdgeInsets {
        return UIEdgeInsetsMake(8.0, 8.0, 8.0, 8.0)
    }
}



protocol DashboardDelegate {
    func openMenu()
    func didMoveOneLevelIntoNavigation()
    func didReturnToBaseLevelOfNavigation()
}

