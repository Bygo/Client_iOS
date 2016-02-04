//
//  EditListingVC.swift
//  Bygo_Client
//
//  Created by Nicholas Garfield on 4/2/16.
//  Copyright © 2016 Nicholas Garfield. All rights reserved.
//


import UIKit

class EditListingVC: UITableViewController { //, EditItemNameDelegate, EditItemCategoryDelegate, EditItemValueDelegate, EditItemRatesDelegate, EditItemDescriptionDelegate {
    
    @IBOutlet var doneButton:UIBarButtonItem!
    @IBOutlet var headerView: UIView!
    //    @IBOutlet var headerScrollView: UIScrollView!
    
    var listing:Listing?
    var model:Model?
    
    private let kNAME_SECTION_INDEX         = 0
    private let kCATEGORY_SECTION_INDEX     = 1
    private let kTOTAL_VALUE_SECTION_INDEX  = 2
    private let kHOURLY_RATE_SECTION_INDEX  = 3
    private let kDAILY_RATE_SECTION_INDEX   = 4
    private let kWEEKLY_RATE_SECTION_INDEX  = 5
    private let kDESCRIPTION_SECTION_INDEX  = 6
    private let kDELETE_SECTION_INDEX       = 7
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        
        tableView.rowHeight             = UITableViewAutomaticDimension
        tableView.estimatedRowHeight    = 44.0
        headerView.backgroundColor      = .lightGrayColor()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Table view data source
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 8
    }
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case kNAME_SECTION_INDEX:           return "NAME"
        case kCATEGORY_SECTION_INDEX:       return "CATEGORY"
        case kTOTAL_VALUE_SECTION_INDEX:    return "VALUE"
        case kHOURLY_RATE_SECTION_INDEX:    return "HOURLY RATE"
        case kDAILY_RATE_SECTION_INDEX:     return "DAILY RATE"
        case kWEEKLY_RATE_SECTION_INDEX:    return "WEEKLY RATE"
        case kDESCRIPTION_SECTION_INDEX:    return "DESCRIPTION"
        default: return nil
        }
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        guard let listing = listing else { return UITableViewCell() }
        
        switch indexPath.section {
        case kNAME_SECTION_INDEX:
            guard let cell = tableView.dequeueReusableCellWithIdentifier("ItemInfoCell", forIndexPath: indexPath) as? EditListingTableViewCell else { return UITableViewCell() }
            cell.infoLabel.text = listing.name
            return cell
            
        case kCATEGORY_SECTION_INDEX:
            guard let cell = tableView.dequeueReusableCellWithIdentifier("ItemInfoCell", forIndexPath: indexPath) as? EditListingTableViewCell else { return UITableViewCell() }
//            model?.queryForCategories([item.categoryID], completionHandler: {(success:Bool, categories:[Model_iOS.Category])->Void in
//                if success {
//                    print("Success fetching category")
//                    let category = categories.first!
//                    cell.infoLabel.text = "\(category.name)"
//                } else {
//                    print("Error fetching category")
//                }
//            })
            return cell
            
        case kTOTAL_VALUE_SECTION_INDEX:
            guard let cell = tableView.dequeueReusableCellWithIdentifier("ItemInfoCell", forIndexPath: indexPath) as? EditListingTableViewCell else { return UITableViewCell() }
            if let totalValue = listing.totalValue.value {
                cell.infoLabel.text = String(format: "$%0.2f", totalValue)
            }
            return cell
            
        case kHOURLY_RATE_SECTION_INDEX:
            guard let cell = tableView.dequeueReusableCellWithIdentifier("ItemInfoCell", forIndexPath: indexPath) as? EditListingTableViewCell else { return UITableViewCell() }
            if let hourlyRate = listing.hourlyRate.value {
                cell.infoLabel.text = String(format: "$%0.2f", hourlyRate)
            }
            return cell
            
        case kDAILY_RATE_SECTION_INDEX:
            guard let cell = tableView.dequeueReusableCellWithIdentifier("ItemInfoCell", forIndexPath: indexPath) as? EditListingTableViewCell else { return UITableViewCell() }
            if let dailyRate = listing.dailyRate.value {
                cell.infoLabel.text = String(format: "$%0.2f", dailyRate)
            }
            return cell
            
        case kWEEKLY_RATE_SECTION_INDEX:
            guard let cell = tableView.dequeueReusableCellWithIdentifier("ItemInfoCell", forIndexPath: indexPath) as? EditListingTableViewCell else { return UITableViewCell() }
            if let weeklyRate = listing.weeklyRate.value {
                cell.infoLabel.text = String(format: "$%0.2f", weeklyRate)
            }
            return cell
            
        case kDESCRIPTION_SECTION_INDEX:
            guard let cell = tableView.dequeueReusableCellWithIdentifier("ItemInfoCell", forIndexPath: indexPath) as? EditListingTableViewCell else { return UITableViewCell() }
            if let itemDescription = listing.itemDescription {
                cell.infoLabel.text = itemDescription
            }
            return cell
            
        case kDELETE_SECTION_INDEX:
            let cell = tableView.dequeueReusableCellWithIdentifier("DeleteButtonCell", forIndexPath: indexPath)
            cell.textLabel?.textAlignment = .Center
            cell.textLabel?.textColor = .redColor()
            cell.textLabel?.text = "DELETE ITEM"
            return cell
            
        default:
            return UITableViewCell()
        }
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        switch indexPath.section {
        case kNAME_SECTION_INDEX:
            performSegueWithIdentifier("ShowEditName", sender: nil)
        case kCATEGORY_SECTION_INDEX:
            performSegueWithIdentifier("ShowEditCategory", sender: nil)
        case kTOTAL_VALUE_SECTION_INDEX:
            performSegueWithIdentifier("ShowEditValue", sender: nil)
        case kHOURLY_RATE_SECTION_INDEX, kDAILY_RATE_SECTION_INDEX, kWEEKLY_RATE_SECTION_INDEX:
            performSegueWithIdentifier("ShowEditRates", sender: nil)
        case kDESCRIPTION_SECTION_INDEX:
            performSegueWithIdentifier("ShowEditDescription", sender: nil)
        case kDELETE_SECTION_INDEX:
            // NOTE: Disabled for DEMO mode
            self.dismissViewControllerAnimated(true, completion: nil)
        default:
            break
        }
    }
    
    
    // MARK: - Editing Delegates
    func didUpdateItemName() {
        tableView.beginUpdates()
        tableView.reloadRowsAtIndexPaths([NSIndexPath(forRow: 0, inSection: kNAME_SECTION_INDEX)], withRowAnimation: .Fade)
        tableView.endUpdates()
    }
    
    func didUpdateCategory() {
        tableView.beginUpdates()
        tableView.reloadRowsAtIndexPaths([NSIndexPath(forRow: 0, inSection: kCATEGORY_SECTION_INDEX)], withRowAnimation: .Fade)
        tableView.endUpdates()
    }
    
    func didUpdateValue() {
        tableView.beginUpdates()
        tableView.reloadRowsAtIndexPaths([NSIndexPath(forRow: 0, inSection: kTOTAL_VALUE_SECTION_INDEX)], withRowAnimation: .Fade)
        tableView.endUpdates()
    }
    
    func didUpdateRates() {
        tableView.beginUpdates()
        tableView.reloadRowsAtIndexPaths([NSIndexPath(forRow: 0, inSection: kHOURLY_RATE_SECTION_INDEX), NSIndexPath(forRow: 0, inSection: kDAILY_RATE_SECTION_INDEX), NSIndexPath(forRow: 0, inSection: kWEEKLY_RATE_SECTION_INDEX)], withRowAnimation: .Fade)
        tableView.endUpdates()
    }
    
    func didUpdateDescription() {
        tableView.beginUpdates()
        tableView.reloadRowsAtIndexPaths([NSIndexPath(forRow: 0, inSection: kDESCRIPTION_SECTION_INDEX)], withRowAnimation: .Fade)
        tableView.endUpdates()
    }
    
    // MARK: - UIActions
    @IBAction func doneButtonTapped(sender:AnyObject) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    
    // MARK: - Navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
//        if segue.identifier == "ShowEditName" {
//            guard let destVC = segue.destinationViewController as? EditItemNameVC else { return }
//            destVC.model = model
//            destVC.item = item
//            destVC.delegate = self
//        } else if segue.identifier == "ShowEditCategory" {
//            guard let destVC = segue.destinationViewController as? EditItemDepartmentVC else { return }
//            destVC.model = model
//            destVC.item = item
//            destVC.delegate = self
//        } else if segue.identifier == "ShowEditValue" {
//            guard let destVC = segue.destinationViewController as? EditItemValueVC else { return }
//            destVC.delegate = self
//            destVC.model = model
//            destVC.item = item
//        } else if segue.identifier == "ShowEditRates" {
//            guard let destVC = segue.destinationViewController as? EditItemRatesVC else { return }
//            destVC.delegate = self
//            destVC.model = model
//            destVC.item = item
//        } else if segue.identifier == "ShowEditDescription" {
//            guard let destVC = segue.destinationViewController as?EditItemDescriptionVC else { return }
//            destVC.delegate = self
//            destVC.model = model
//            destVC.item = item
//        }
//        
    }
}
