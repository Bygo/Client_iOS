//
//  EditListingCategoryVC.swift
//  Bygo_Client
//
//  Created by Nicholas Garfield on 4/2/16.
//  Copyright © 2016 Nicholas Garfield. All rights reserved.
//

import UIKit
import RealmSwift

class EditListingCategoryVC: UITableViewController {
    
    var model:Model?
    var delegate:EditListingCategoryDelegate?
    var listing:Listing?
    
    var listingDepartment:Department?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        model?.categoryServiceProvider.refreshCategories({
            (success:Bool) in
            if success { self.tableView.reloadData() }
            else { print("Error refreshing all Categories") }
        })
        
        title = listingDepartment?.name
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Table view data source
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    private func getQueryFilter() -> String {
        let nullQuery = "departmentID == nil"
        guard let departmentID = listingDepartment?.departmentID else { return nullQuery }
        return "departmentID == \"\(departmentID)\""
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let realm = try! Realm()
        return realm.objects(Category).filter(getQueryFilter()).count
    }
    
    func configureCell(cell: UITableViewCell, atIndexPath indexPath: NSIndexPath) {
        let queryFilter = self.getQueryFilter()
        dispatch_async(GlobalUserInteractiveQueue, {
            let realm       = try! Realm()
            let categories  = realm.objects(Category).filter(queryFilter).sorted("name", ascending: true)
            guard let name  = categories[indexPath.row].name else { return }
            dispatch_async(GlobalMainQueue, { cell.textLabel?.text = name })
        })
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("CategoryCell", forIndexPath: indexPath)
        configureCell(cell, atIndexPath: indexPath)
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        let realm       = try! Realm()
        let listingCategory = realm.objects(Category).filter(self.getQueryFilter()).sorted("name", ascending: true)[indexPath.row]
        
        guard let listingID         = listing?.listingID            else { return }
        guard let name              = listing?.name                 else { return }
        guard let categoryID        = listingCategory.categoryID    else { return }
        guard let totalValue        = listing?.totalValue.value     else { return }
        guard let hourlyRate        = listing?.hourlyRate.value     else { return }
        guard let dailyRate         = listing?.dailyRate.value      else { return }
        guard let weeklyRate        = listing?.weeklyRate.value     else { return }
        guard let itemDescription   = listing?.itemDescription      else { return }
        
        model?.listingServiceProvider.updateListing(listingID, name: name, categoryID: categoryID, totalValue: totalValue, hourlyRate: hourlyRate, dailyRate: dailyRate, weeklyRate: weeklyRate, itemDescription: itemDescription, completionHandler: {
            (success:Bool) in
            if success {
                self.delegate?.didUpdateCategory()
                self.navigationController?.popToRootViewControllerAnimated(true)
            } else {
                print("Error updating the Listing")
            }
        })
    }
}


protocol EditListingCategoryDelegate {
    func didUpdateCategory()
}