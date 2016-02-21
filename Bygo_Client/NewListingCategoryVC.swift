//
//  NewListingCategoryVC.swift
//  Bygo_Client
//
//  Created by Nicholas Garfield on 4/2/16.
//  Copyright © 2016 Nicholas Garfield. All rights reserved.
//

import UIKit
import RealmSwift

class NewListingCategoryVC: UITableViewController {
    
    var model:Model?
    
    var listingName:String?
    var listingDepartment:Department?
    var listingCategory:Category?
    
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
        let realm       = try! Realm()
        listingCategory = realm.objects(Category).filter(self.getQueryFilter()).sorted("name", ascending: true)[indexPath.row]
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        performSegueWithIdentifier("ShowTakePhotos", sender: nil)
    }
    
    // MARK: - UI Actions
    @IBAction func backButtonTapped(sender: AnyObject) {
        navigationController?.popViewControllerAnimated(true)
    }
    
    // MARK: - Navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "ShowTakePhotos" {
            guard let destVC = segue.destinationViewController as? NewListingPhotosVC else { return }
            destVC.model                = model
            destVC.listingName          = listingName
            destVC.listingDepartment    = listingDepartment
            destVC.listingCategory      = listingCategory
        }
    }
}
